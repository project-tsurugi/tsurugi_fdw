/*
 * Copyright 2019-2025 Project Tsurugi.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Portions Copyright (c) 1996-2023, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, The Regents of the University of California
 *
 *	@file	tsurugi_fdw.cpp
 *	@brief 	Foreign Data Wrapper for Tsurugi.
 */
#include "postgres.h"
#include "fdw/tsurugi_fdw.h"

#include "commands/explain.h"
#include "foreign/fdwapi.h"
#include "miscadmin.h"
#include "nodes/pg_list.h"
#if PG_VERSION_NUM >= 160000
#include "utils/acl.h"
#endif  // PG_VERSION_NUM >= 160000
#include "utils/lsyscache.h"
#include "utils/rel.h"

#include "fdw/tsurugi_utils.h"
#include "tg_common/connection.h"

PG_MODULE_MAGIC;

/*
 * Indexes of FDW-private information stored in fdw_private lists.
 *
 * These items are indexed with the enum FdwScanPrivateIndex, so an item
 * can be fetched with list_nth().  For example, to get the SELECT statement:
 *		sql = strVal(list_nth(fdw_private, FdwScanPrivateSelectSql));
 */
enum FdwScanPrivateIndex
{
	/* SQL statement to execute remotely (as a String node) */
	FdwScanPrivateSelectSql,
	/* Integer list of attribute numbers retrieved by the SELECT */
	FdwScanPrivateRetrievedAttrs,
	/* Integer representing the desired fetch_size */
	FdwScanPrivateFetchSize,

	/*
	 * String describing join i.e. names of relations being joined and types
	 * of join, added when the scan is join
	 */
	FdwScanPrivateRelations
};

/*
 * Similarly, this enum describes what's kept in the fdw_private list for
 * a ForeignScan node that modifies a foreign table directly.  We store:
 *
 * 1) UPDATE/DELETE statement text to be sent to the remote server
 * 2) Boolean flag showing if the remote query has a RETURNING clause
 * 3) Integer list of attribute numbers retrieved by RETURNING, if any
 * 4) Boolean flag showing if we set the command es_processed
 */
enum FdwDirectModifyPrivateIndex
{
	/* SQL statement to execute remotely (as a String node) */
	FdwDirectModifyPrivateUpdateSql,
	/* has-returning flag (as an integer Value node) */
	FdwDirectModifyPrivateHasReturning,
	/* Integer list of attribute numbers retrieved by RETURNING */
	FdwDirectModifyPrivateRetrievedAttrs,
	/* set-processed flag (as an integer Value node) */
	FdwDirectModifyPrivateSetProcessed
};

/** ===========================================================================
 * 
 * 	Prototype Declarations.
 * 
 */
#ifdef __cplusplus
extern "C" {
#endif

PG_FUNCTION_INFO_V1(tsurugi_fdw_handler);

/*
 * FDW callback routines (Scan)
 */
static void tsurugiBeginForeignScan(ForeignScanState *node, int eflags);
static TupleTableSlot* tsurugiIterateForeignScan(ForeignScanState *node);
static void tsurugiReScanForeignScan(ForeignScanState *node);
static void tsurugiEndForeignScan(ForeignScanState *node);

/*
 * FDW callback routines (Modify)
 */
static void tsurugiBeginDirectModify(ForeignScanState *node, int eflags);
static TupleTableSlot* tsurugiIterateDirectModify(ForeignScanState *node);
static void tsurugiEndDirectModify(ForeignScanState *node);

static void tsurugiBeginForeignModify(ModifyTableState *mtstate,
                                        ResultRelInfo *rinfo,
                                        List *fdw_private,
                                        int subplan_index,
                                        int eflags);									
static TupleTableSlot* tsurugiExecForeignInsert(EState *estate, 
                                                ResultRelInfo *resultRelInfo, 
                                                TupleTableSlot *slot, 
                                                TupleTableSlot *planSlot);
static TupleTableSlot* tsurugiExecForeignUpdate(EState *estate, 
                                                ResultRelInfo *resultRelInfo, 
                                                TupleTableSlot *slot, 
                                                TupleTableSlot *planSlot);
static TupleTableSlot* tsurugiExecForeignDelete(EState *estate, 
                                                ResultRelInfo *resultRelInfo, 
                                                TupleTableSlot *slot, 
                                                TupleTableSlot *planSlot);
static void tsurugiEndForeignModify(EState *estate,
                                    ResultRelInfo *rinfo);

/*
 * FDW callback routines (Others)
 */
static void tsurugiExplainForeignScan(ForeignScanState *node, 
									    ExplainState *es);
static void tsurugiExplainDirectModify(ForeignScanState *node, 
										 ExplainState *es);
static bool tsurugiAnalyzeForeignTable(Relation relation, 
										AcquireSampleRowsFunc *func, 
										BlockNumber* totalpages);
static List* tsurugiImportForeignSchema(ImportForeignSchemaStmt *stmt, 
										  Oid serverOid);
#ifdef __cplusplus
}
#endif

/*
 * Helper functions
 */
extern PGDLLIMPORT PGPROC *MyProc;
static void make_retrieved_attrs(List* telist, List **retrieved_attrs);
static void store_pg_data_type(TgFdwForeignScanState *fsstate, 
								List *tlist, List **retrieved_attrs);

#if PG_VERSION_NUM >= 160000
static bool has_table_privilege(Oid relid, ForeignScan *fsplan);
#endif  // PG_VERSION_NUM >= 160000

/** ===========================================================================
 * 
 * 	FDW Handlers.
 *
 */
/*
 * Foreign-data wrapper handler function: return a struct with pointers
 * to my callback routines.
 */
Datum
tsurugi_fdw_handler(PG_FUNCTION_ARGS)
{
	FdwRoutine *routine = makeNode(FdwRoutine);

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	/*Functions for scanning foreign tables*/
	routine->BeginForeignScan = tsurugiBeginForeignScan;
	routine->IterateForeignScan = tsurugiIterateForeignScan;
	routine->ReScanForeignScan = tsurugiReScanForeignScan;
	routine->EndForeignScan = tsurugiEndForeignScan;

	/*Functions for updating foreign tables*/
	routine->BeginDirectModify = tsurugiBeginDirectModify;
	routine->IterateDirectModify = tsurugiIterateDirectModify;
	routine->EndDirectModify = tsurugiEndDirectModify;

	/*Support functions for EXPLAIN*/
	routine->ExplainForeignScan = tsurugiExplainForeignScan;
	routine->ExplainDirectModify = tsurugiExplainDirectModify;
	/*Support functions for ANALYZE*/
	routine->AnalyzeForeignTable = tsurugiAnalyzeForeignTable;

	/*Support functions for IMPORT FOREIGN SCHEMA*/
	routine->ImportForeignSchema = tsurugiImportForeignSchema;

	/*Functions for foreign modify*/
	routine->BeginForeignModify = tsurugiBeginForeignModify;
	routine->ExecForeignInsert = tsurugiExecForeignInsert;
	routine->ExecForeignUpdate = tsurugiExecForeignUpdate;
	routine->ExecForeignDelete = tsurugiExecForeignDelete;
	routine->EndForeignModify = tsurugiEndForeignModify;

	PG_RETURN_POINTER(routine);
}

/** ===========================================================================
 *
 * 	FDW Scan functions. 
 * 
 */
/**
 *  @brief  Preparation for scanning foreign tables.
 */
static void 
tsurugiBeginForeignScan(ForeignScanState *node, int eflags)
{
	ForeignScan *fsplan = (ForeignScan *) node->ss.ps.plan;
	TgFdwForeignScanState *fsstate;
	RangeTblEntry *rte;
	ForeignTable *table;
	ForeignServer *server;
	int rtindex;
	EState *estate = node->ss.ps.state;

	elog(DEBUG1, "tsurugi_fdw : %s\nquery:\n%s", __func__, estate->es_sourceText);

	/*
	 * Do nothing in EXPLAIN (no ANALYZE) case.  node->fdw_state stays NULL.
	 */
	if (eflags & EXEC_FLAG_EXPLAIN_ONLY)
		return;

	if (fsplan->scan.scanrelid > 0)
		rtindex = fsplan->scan.scanrelid;
	else
		rtindex = bms_next_member(fsplan->fs_relids, -1);

	/* Get the server object from the ForeignTable associated with the relation. */
	rte = exec_rt_fetch(rtindex, estate);
	table = GetForeignTable(rte->relid);
	server = GetForeignServer(table->serverid);

#if PG_VERSION_NUM >= 160000
	/* Permission check */
	if (!has_table_privilege(rte->relid, fsplan))
	{
		ereport(ERROR, (errcode(ERRCODE_INSUFFICIENT_PRIVILEGE),
						errmsg("permission denied for foreign table %s",
							   get_rel_name(table->relid))));
	}
#endif  // PG_VERSION_NUM >= 160000

	/*
	 * We'll save private state in node->fdw_state.
	 */
	fsstate = (TgFdwForeignScanState*) palloc0(sizeof(TgFdwForeignScanState));
    node->fdw_state = (void*) fsstate;
    fsstate->rowidx = 0;
	fsstate->number_of_columns = 0;
	fsstate->query_string = estate->es_sourceText;
	make_retrieved_attrs(fsplan->scan.plan.targetlist, &fsstate->retrieved_attrs);
  	fsstate->cursor_exists = false;
	fsstate->param_linfo = estate->es_param_list_info;

	/*
	 * Get info we'll need for converting data fetched from the foreign server
	 * into local representation and error reporting during that process.
	 */
	if (fsplan->scan.scanrelid > 0)
	{
		fsstate->rel = node->ss.ss_currentRelation;
		fsstate->tupdesc = RelationGetDescr(fsstate->rel);
	}
	else
	{
		fsstate->rel = ExecOpenScanRelation(estate, rtindex, eflags);
		fsstate->tupdesc = node->ss.ss_ScanTupleSlot->tts_tupleDescriptor;
	}
	fsstate->attinmeta = TupleDescGetAttInMetadata(fsstate->tupdesc);

	handle_remote_xact(server);
}

/*
 * tsurugiIterateForeignScan
 *      Scanning row data from foreign tables.
 */
static TupleTableSlot* 
tsurugiIterateForeignScan(ForeignScanState *node)
{
	TgFdwForeignScanState *fsstate = (TgFdwForeignScanState *) node->fdw_state;
	TupleTableSlot* tupleSlot = node->ss.ss_ScanTupleSlot;

	elog(DEBUG3, "tsurugi_fdw : %s\nquery:\n%s", __func__, fsstate->query_string);

	if (!fsstate->cursor_exists)
	{
		create_cursor(node);
		fsstate->num_tuples = 0;
	    fsstate->cursor_exists = true;
	}
	ExecClearTuple(tupleSlot);
	execute_foreign_scan(fsstate, tupleSlot);

	elog(DEBUG5, "tsurugi_fdw : %s is done.", __func__);

	return tupleSlot;
}

/*
 *	tsurugiReScanForeignScan
 */
static void 
tsurugiReScanForeignScan(ForeignScanState *node)
{
	TgFdwForeignScanState *fsstate = (TgFdwForeignScanState *) node->fdw_state;

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	/* If we haven't created the cursor yet, nothing to do. */
	if (!fsstate->cursor_exists)
		return;
	
	fsstate->cursor_exists = false;
	fsstate->rowidx = 0;
	fsstate->num_tuples = 0;
}

/*
 *	tsurugiEndForeignScan
 *      Clean up for scanning foreign tables.
 */
static void 
tsurugiEndForeignScan(ForeignScanState *node)
{
	elog(DEBUG1, "tsurugi_fdw : %s", __func__);
}

/** ===========================================================================
 *
 * 	FDW Modify functions.
 *
 */
/*
 * tsurugiBeginDirectModify
 *      Preparation for modifying foreign tables.
 */
static void 
tsurugiBeginDirectModify(ForeignScanState *node, int eflags)
{
	RangeTblEntry *rte;
    ForeignTable *table;
    ForeignServer *server;
	ForeignScan *fsplan = (ForeignScan *) node->ss.ps.plan;
	int rtindex;
	EState *estate = node->ss.ps.state;
	TgFdwDirectModifyState *dmstate;

	Assert(node != NULL);
	Assert(fsplan != NULL);

	elog(DEBUG1, "tsurugi_fdw : %s\nquery:\n%s", __func__, estate->es_sourceText);

	/* Initialize state variable */
	dmstate = (TgFdwDirectModifyState *) palloc0(sizeof(TgFdwDirectModifyState));
	dmstate->num_tuples = -1;	/* -1 means not set yet */	
	dmstate->orig_query = estate->es_sourceText;

	if (fsplan->scan.scanrelid > 0)
    	rtindex = fsplan->scan.scanrelid;
  	else
    	rtindex = bms_next_member(fsplan->fs_relids, -1);

	/* Get the server object from the ForeignTable associated with the relation. */
	rte = exec_rt_fetch(rtindex, estate);
	table = GetForeignTable(rte->relid);
	server = GetForeignServer(table->serverid);

#if PG_VERSION_NUM >= 160000
	/* Permission check */
	if (!has_table_privilege(rte->relid, fsplan))
	{
		ereport(ERROR, (errcode(ERRCODE_INSUFFICIENT_PRIVILEGE),
						errmsg("permission denied for foreign table %s",
							   get_rel_name(table->relid))));
	}
#endif  // PG_VERSION_NUM >= 160000

	if (fsplan->scan.scanrelid == 0)
		dmstate->rel = ExecOpenScanRelation(estate, rtindex, eflags);
	else
		dmstate->rel = node->ss.ss_currentRelation;
	dmstate->param_types = NULL;
	dmstate->prep_name = NULL;
	dmstate->param_linfo = estate->es_param_list_info;
	dmstate->server = server;
	node->fdw_state = dmstate;

	if (is_prepare_statement(dmstate->orig_query))
		prepare_direct_modify(dmstate);

	handle_remote_xact(server);
}

/*
 * tsurugiIterateDirectModify
 *      Execute Insert/Upate/Delete command to foreign tables.
 */
static TupleTableSlot * 
tsurugiIterateDirectModify(ForeignScanState *node)
{
	TgFdwDirectModifyState *dmstate = (TgFdwDirectModifyState *) node->fdw_state;
	EState *estate = node->ss.ps.state;
	TupleTableSlot *slot = node->ss.ss_ScanTupleSlot;
	dmstate->slot = node->ss.ss_ScanTupleSlot;

	elog(DEBUG1, "tsurugi_fdw : %s\nquery:\n%s", __func__, estate->es_sourceText);

	if (dmstate->num_tuples == (size_t) -1)
		execute_direct_modify(node);

	/* Increment the command es_processed count if necessary. */
	if (dmstate->set_processed)
		estate->es_processed += dmstate->num_tuples;

	return ExecClearTuple(slot);	
}

/*
 * tsurugiEndDirectModify
 *      Clean up for modifying foreign tables.
 */
static void 
tsurugiEndDirectModify(ForeignScanState *node)
{
	elog(DEBUG1, "tsurugi_fdw : %s", __func__);
}
/*
 * tsurugiBeginForeignModify
 */
static void 
tsurugiBeginForeignModify(ModifyTableState *mtstate,
                        ResultRelInfo *resultRelInfo,
                        List *fdw_private,
                        int subplan_index,
                        int eflags)
{
	elog(DEBUG1, "tsurugi_fdw : %s", __func__);
}

/*
 * tsurugiExecForeignInsert
 */
static TupleTableSlot *
tsurugiExecForeignInsert(
	EState *estate, 
	ResultRelInfo *rinfo, 
	TupleTableSlot *slot, 
	TupleTableSlot *planSlot)
{
	elog(DEBUG1, "tsurugi_fdw : %s", __func__);
	slot = NULL;

	elog(ERROR, "tsurugi_fdw does not support execForeignInsert().");

    return slot;
}

/*
 * tsurugiExecForeignUpdate
 */
static TupleTableSlot *
tsurugiExecForeignUpdate(
	EState *estate, 
	ResultRelInfo *rinfo, 
	TupleTableSlot *slot, 
	TupleTableSlot *planSlot)
{
	elog(DEBUG1, "tsurugi_fdw : %s", __func__);
	slot = NULL;

	elog(ERROR, "tsurugi_fdw does not support execForeignUpdate().");

    return slot;
}

/*
 * tsurugiExecForeignDelete
 */
static TupleTableSlot *
tsurugiExecForeignDelete(
	EState *estate, 
	ResultRelInfo *rinfo, 
	TupleTableSlot *slot, 
	TupleTableSlot *planSlot)
{
	elog(DEBUG1, "tsurugi_fdw : %s", __func__);
	slot = NULL;

	elog(ERROR, "tsurugi_fdw does not support execForeignDelete().");

	return slot;
}

/*
 * tsurugiEndForeignModify
 */
static void 
tsurugiEndForeignModify(EState *estate,
                        ResultRelInfo *resultRelInfo)
{
	elog(DEBUG1, "tsurugi_fdw : %s", __func__);
}

/** ===========================================================================
 *
 * 	FDW Explain functions.
 *
 */
/*
 * tsurugiExplainForeignScan
 *		Produce extra output for EXPLAIN of a ForeignScan on a foreign table
 */
static void 
tsurugiExplainForeignScan(ForeignScanState *node,
						   	ExplainState *es)
{
	List	   *fdw_private;
	char	   *sql;
	char	   *relations;

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	fdw_private = ((ForeignScan *) node->ss.ps.plan)->fdw_private;

	/*
	 * Add names of relation handled by the foreign scan when the scan is a
	 * join
	 */
	if (list_length(fdw_private) > FdwScanPrivateRelations)
	{
		relations = strVal(list_nth(fdw_private, FdwScanPrivateRelations));
		ExplainPropertyText("Relations", relations, es);
	}

	/*
	 * Add remote query, when VERBOSE option is specified.
	 */
	if (es->verbose)
	{
		sql = strVal(list_nth(fdw_private, FdwScanPrivateSelectSql));
		ExplainPropertyText("Remote SQL", sql, es);
	}
}

/*
 * tsurugiExplainDirectModify
 *      Not in use.
 */
static void 
tsurugiExplainDirectModify(ForeignScanState *node,
							ExplainState *es)
{
	elog(DEBUG1, "tsurugi_fdw : %s", __func__);
}

/*
 * tsurugiAnalyzeForeignTable
 *      Not in use.
 */
static bool 
tsurugiAnalyzeForeignTable(Relation relation,
    AcquireSampleRowsFunc *func,
    BlockNumber* totalpages)
{
	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	return true;
}

/** ===========================================================================
 *
 * 	FDW Import Foreign Schema function.
 *
 */
/*
 * tsurugiImportForeignSchema
 *      Import table metadata from a foreign server.
 */
static List *tsurugiImportForeignSchema(ImportForeignSchemaStmt *stmt, Oid serverOid)
{
	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	return execute_import_foreign_schema(stmt, serverOid);
}

/** ===========================================================================
 *
 * 	Helper functions.
 * 
 */

static void
make_retrieved_attrs(List *telist, List **retrieved_attrs)
{
	ListCell *lc;
	int i;

	elog(DEBUG3, "tsurugi_fdw : %s", __func__);

	*retrieved_attrs = NIL;

	i = 0;
	foreach (lc, telist)
	{
		TargetEntry* entry = (TargetEntry*) lfirst(lc);
		elog(DEBUG5, "tsurugi_fdw : %s : attr_number: %d, res_name: %s, resno: %d, resorigcol: %d", 
			__func__, i, entry->resname, entry->resno, entry->resorigcol);
		*retrieved_attrs = lappend_int(*retrieved_attrs, i + 1);
		i++;
	}
}

/*
 * 	@biref	Scanning data type of target list from PG tables.
 * 	@param	[in/out] Store data type information.
 * 	@param	[in] target list. (Assuming that TargetEntry->Expr are all Vars)
 * 	@note	target list: Column to SELECT
 *
 * 	This function was prepared because we decided that it would be better to
 * 	understand PostgreSQL data types.
 */
[[maybe_unused]] static void 
store_pg_data_type(TgFdwForeignScanState *fsstate, List *tlist, List **retrieved_attrs)
{
	ListCell* lc = NULL;

	elog(DEBUG3, "tsurugi_fdw : %s", __func__);

	*retrieved_attrs = NIL;

	if (tlist != NULL)
	{
		Oid *data_types = (Oid *) palloc(sizeof(Oid) * tlist->length + 1);


		int i = 0;
		int count = 0;
		foreach (lc, tlist)
		{
			TargetEntry *entry = (TargetEntry *) lfirst(lc);
			Node *node = (Node *) entry->expr;
			count++;

			if (nodeTag(node) == T_Var || nodeTag(node) == T_OpExpr)
			{
				Var *var = (Var *) node;
				data_types[i] = var->vartype;
				elog(DEBUG5, "tsurugi_fdw :  (att_number: %d, nodeTag: %u, vartype: %d)", 
					 i, (unsigned int) nodeTag(node), (int) var->vartype);
			}
			else if (nodeTag(node) == T_Const)
			{
				// When generating placeholders in a SELECT query expression.
				elog(DEBUG5, "Skip the data type placeholders. (index: %d, type: %u)",
					 i, (unsigned int) nodeTag(node));
			}
			else
			{
				elog(ERROR, "Unexpected data type in target list. (index: %d, type: %u)",
					i, (unsigned int) nodeTag(node));
			}
			elog(DEBUG1, "tsurugi_fdw : %s : attr_number: %d", __func__, i);
			*retrieved_attrs = lappend_int(*retrieved_attrs, i + 1);
			i++;
		}
		fsstate->column_types = data_types;
		fsstate->number_of_columns = count;
	}
}

#if PG_VERSION_NUM >= 160000
/**
 * @brief Check table privileges for a specific operation.
 * @param relid OID of the relation (table) to check.
 * @param fsplan ForeignScan node for the foreign table access plan.
 * @retval true if the user has the required privileges.
 * @retval false otherwise.
 */
static bool has_table_privilege(Oid relid, ForeignScan *fsplan)
{
	AclMode check_modes[3];
	int mode_count = 0;
	bool res = false;
	List *has_where_clause = NULL;

	/* Privilege check for main operation. */
	switch (fsplan->operation)
	{
		case CMD_SELECT:
			check_modes[mode_count++] = ACL_SELECT;
			break;
		case CMD_INSERT:
			check_modes[mode_count++] = ACL_INSERT;
			break;
		case CMD_UPDATE:
		{
			check_modes[mode_count++] = ACL_UPDATE;

			/* Additional SELECT privilege check for condition evaluation. */
			has_where_clause = fsplan->fdw_private;
			if (has_where_clause != NULL)
			{
				check_modes[mode_count++] = ACL_SELECT;
			}
			break;
		}
		case CMD_DELETE:
		{
			check_modes[mode_count++] = ACL_DELETE;

			/* Additional SELECT privilege check for condition evaluation. */
			has_where_clause = fsplan->fdw_private;
			if (has_where_clause != NULL)
			{
				check_modes[mode_count++] = ACL_SELECT;
			}
			break;
		}
		default:
			check_modes[mode_count++] = N_ACL_RIGHTS;
			break;
	}

	res = false;
	for (int i = 0; i < mode_count; i++)
	{
		res = pg_class_aclcheck(relid, GetUserId(), check_modes[i]) == ACLCHECK_OK;
		if (res == false) {
			break;
		}
	}

	return res;
}
#endif  /* PG_VERSION_NUM >= 160000 */

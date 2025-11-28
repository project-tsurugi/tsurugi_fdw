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
#include <boost/format.hpp>

#include "common/tsurugi.h"
#include "fdw/tsurugi_utils.h"

#ifdef __cplusplus
extern "C" {
#endif
#include "postgres.h"
#include "fdw/tsurugi_fdw.h"

#include "access/xact.h"
#include "access/htup_details.h"
#include "access/sysattr.h"
#include "access/table.h"
#include "access/tupdesc.h"
#include "catalog/pg_class.h"
#include "catalog/pg_type.h"
#include "commands/defrem.h"
#include "commands/explain.h"
#include "commands/vacuum.h"
#include "fmgr.h"
#include "foreign/fdwapi.h"
#include "miscadmin.h"
#include "nodes/makefuncs.h"
#include "nodes/nodeFuncs.h"
#include "nodes/nodes.h"
#include "nodes/primnodes.h"
#if PG_VERSION_NUM >= 120000
	#include "optimizer/appendinfo.h"	// get_translated_update_targetlist
#endif  // PG_VERSION_NUM >= 140000
#if (PG_VERSION_NUM < 140000)
	#include "optimizer/clauses.h"
#endif
#include "optimizer/cost.h"
#if PG_VERSION_NUM >= 160000
#include "optimizer/inherit.h"
#endif
#include "optimizer/optimizer.h"
#include "optimizer/pathnode.h"
#include "optimizer/paths.h"
#include "optimizer/planmain.h"
#include "optimizer/planner.h"
#include "optimizer/restrictinfo.h"
#include "optimizer/tlist.h"
#include "parser/parsetree.h"
#include "parser/parse_coerce.h"
#include "parser/parse_type.h"
#include "utils/builtins.h"
#include "utils/float.h"
#include "utils/guc.h"
#include "utils/lsyscache.h"
#include "utils/memutils.h"
#include "utils/numeric.h"
#include "utils/rel.h"
#include "utils/sampling.h"
#include "utils/selfuncs.h"
#include "utils/syscache.h"
#include "nodes/pg_list.h"

PG_MODULE_MAGIC;

#ifdef __cplusplus
}
#endif

int unused PG_USED_FOR_ASSERTS_ONLY;

/* Default CPU cost to start up a foreign query. */
#define DEFAULT_FDW_STARTUP_COST	100.0

/* Default CPU cost to process 1 row (above and beyond cpu_tuple_cost). */
#define DEFAULT_FDW_TUPLE_COST		0.01

/* If no remote estimates, assume a sort costs 20% extra */
#define DEFAULT_FDW_SORT_MULTIPLIER 1.2

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
 * a ModifyTable node referencing a postgres_fdw foreign table.  We store:
 *
 * 1) INSERT/UPDATE/DELETE statement text to be sent to the remote server
 * 2) Integer list of target attribute numbers for INSERT/UPDATE
 *	  (NIL for a DELETE)
 * 3) Length till the end of VALUES clause for INSERT
 *	  (-1 for a DELETE/UPDATE)
 * 4) Boolean flag showing if the remote query has a RETURNING clause
 * 5) Integer list of attribute numbers retrieved by RETURNING, if any
 */
enum FdwForeignModifyPrivateIndex
{
	/* SQL statement to execute remotely (as a String node) */
	FdwModifyPrivateUpdateSql,
	/* Integer list of target attribute numbers for INSERT/UPDATE */
	FdwModifyPrivateTargetAttnums,
	/* Length till the end of VALUES clause (as an integer Value node) */
	FdwModifyPrivateLen,
	/* has-returning flag (as an integer Value node) */
	FdwModifyPrivateHasReturning,
	/* Integer list of attribute numbers retrieved by RETURNING */
	FdwModifyPrivateRetrievedAttrs
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

/*
 * This enum describes what's kept in the fdw_private list for a ForeignPath.
 * We store:
 *
 * 1) Boolean flag showing if the remote query has the final sort
 * 2) Boolean flag showing if the remote query has the LIMIT clause
 */
enum FdwPathPrivateIndex
{
	/* has-final-sort flag (as an integer Value node) */
	FdwPathPrivateHasFinalSort,
	/* has-limit flag (as an integer Value node) */
	FdwPathPrivateHasLimit
};

/* ===========================================================================
 * 
 * Prototype declarations
 * 
 */
#ifdef __cplusplus
extern "C" {
#endif

PG_FUNCTION_INFO_V1(tsurugi_fdw_handler);

/*
 * FDW callback routines (Scan)
 */
static void tsurugiBeginForeignScan(ForeignScanState* node, int eflags);
static TupleTableSlot* tsurugiIterateForeignScan(ForeignScanState* node);
static void tsurugiReScanForeignScan(ForeignScanState* node);
static void tsurugiEndForeignScan(ForeignScanState* node);

/*
 * FDW callback routines (Insert/Update/Delete)
 */
static void tsurugiBeginDirectModify(ForeignScanState* node, int eflags);
static TupleTableSlot* tsurugiIterateDirectModify(ForeignScanState* node);
static void tsurugiEndDirectModify(ForeignScanState* node);

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
static void tsurugiExplainForeignScan(ForeignScanState* node, 
									    ExplainState* es);
static void tsurugiExplainDirectModify(ForeignScanState* node, 
										 ExplainState* es);
static bool tsurugiAnalyzeForeignTable(Relation relation, 
										AcquireSampleRowsFunc* func, 
										BlockNumber* totalpages);
static List* tsurugiImportForeignSchema(ImportForeignSchemaStmt* stmt, 
										  Oid serverOid);
#ifdef __cplusplus
}
#endif

/*
 * Helper functions
 */
extern PGDLLIMPORT PGPROC *MyProc;
extern void handle_remote_xact(ForeignServer *server);

static void make_retrieved_attrs(List* telist, List** retrieved_attrs);
static void store_pg_data_type(TgFdwForeignScanState* fsstate, List* tlist, List** );

/* ===========================================================================
 * 
 * FDW Handler
 *
 */
/*
 * Foreign-data wrapper handler function: return a struct with pointers
 * to my callback routines.
 */
Datum
tsurugi_fdw_handler(PG_FUNCTION_ARGS)
{
	FdwRoutine* routine = makeNode(FdwRoutine);

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
#if 1
	/*Functions for foreign modify*/
	routine->BeginForeignModify = tsurugiBeginForeignModify;
	routine->ExecForeignInsert = tsurugiExecForeignInsert;
	routine->ExecForeignUpdate = tsurugiExecForeignUpdate;
	routine->ExecForeignDelete = tsurugiExecForeignDelete;
	routine->EndForeignModify = tsurugiEndForeignModify;
#endif
	PG_RETURN_POINTER(routine);
}

/* ===========================================================================
 *
 * FDW Scan functions. 
 * 
 */

/**
 *  @brief  Preparation for scanning foreign tables.
 */
static void 
tsurugiBeginForeignScan(ForeignScanState* node, int eflags)
{
	Assert(node != nullptr);

	ForeignScan* fsplan = (ForeignScan*) node->ss.ps.plan;
	TgFdwForeignScanState* fsstate;
	RangeTblEntry *rte;
	ForeignTable *table;
	ForeignServer *server;
	int			rtindex;
	EState* 	estate = node->ss.ps.state;

	elog(DEBUG1, "tsurugi_fdw : %s\nquery:\n%s", __func__, estate->es_sourceText);

	/*
	 * Do nothing in EXPLAIN (no ANALYZE) case.  node->fdw_state stays NULL.
	 */
	if (eflags & EXEC_FLAG_EXPLAIN_ONLY)
		return;

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

	if (fsplan->scan.scanrelid > 0)
		rtindex = fsplan->scan.scanrelid;
	else
		rtindex = bms_next_member(fsplan->fs_relids, -1);

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

	/* Get the server object from the ForeignTable associated with the relation. */
	rte = exec_rt_fetch(rtindex, estate);
	table = GetForeignTable(rte->relid);
	server = GetForeignServer(table->serverid);

	handle_remote_xact(server);
}

/*
 * tsurugiIterateForeignScan
 *      Scanning row data from foreign tables.
 */
static TupleTableSlot* 
tsurugiIterateForeignScan(ForeignScanState* node)
{
	Assert(node != nullptr);

	TgFdwForeignScanState* fsstate = (TgFdwForeignScanState*) node->fdw_state;
	TupleTableSlot* tupleSlot = node->ss.ss_ScanTupleSlot;

	elog(DEBUG3, "tsurugi_fdw : %s\nquery:\n%s", __func__, fsstate->query_string);

	if (!fsstate->cursor_exists)
	{
		create_cursor(node);
		fsstate->num_tuples = 0;
	    fsstate->cursor_exists = true;
	}

	ExecClearTuple(tupleSlot);

	ERROR_CODE error = Tsurugi::result_set_next_row();
	if (error == ERROR_CODE::OK)
	{
		make_tuple_from_result_row(Tsurugi::get_result_set(), 
  								   tupleSlot->tts_tupleDescriptor,
								   fsstate->retrieved_attrs,
								   tupleSlot->tts_values,
								   tupleSlot->tts_isnull);
		ExecStoreVirtualTuple(tupleSlot);
		fsstate->num_tuples++;
	}
	else if (error == ERROR_CODE::END_OF_ROW) 
	{
		/* No more rows/data exists */
		Tsurugi::init_result_set();
		elog(DEBUG1, "tsurugi_fdw : End of rows. (rows: %d)", 
			(int) fsstate->num_tuples);
	}
	else
	{
		Tsurugi::init_result_set();
		Tsurugi::report_error("Failed to retrieve result set from Tsurugi.", 
								error, fsstate->query_string);
	}

	elog(DEBUG5, "tsurugi_fdw : %s is done.", __func__);

	return tupleSlot;
}

/*
 *	tsurugiReScanForeignScan
 */
static void 
tsurugiReScanForeignScan(ForeignScanState* node)
{
	TgFdwForeignScanState *fsstate = (TgFdwForeignScanState *) node->fdw_state;

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	/* If we haven't created the cursor yet, nothing to do. */
	if (!fsstate->cursor_exists)
		return;
	
	Tsurugi::deallocate();
	Tsurugi::init_result_set();

	fsstate->cursor_exists = false;
	fsstate->rowidx = 0;
	fsstate->num_tuples = 0;
}

/*
 *	tsurugiEndForeignScan
 *      Clean up for scanning foreign tables.
 */
static void 
tsurugiEndForeignScan(ForeignScanState* node)
{
	elog(DEBUG1, "tsurugi_fdw : %s", __func__);
}

/* ===========================================================================
 *
 * FDW Modify functions.
 *
 */

/*
 * tsurugiBeginDirectModify
 *      Preparation for modifying foreign tables.
 */
static void 
tsurugiBeginDirectModify(ForeignScanState* node, int eflags)
{
	RangeTblEntry *rte;
    ForeignTable *table;
    ForeignServer *server;
	ForeignScan* fsplan = (ForeignScan*) node->ss.ps.plan;
	int      	rtindex;
	EState* estate = node->ss.ps.state;

	Assert(node != nullptr);
	Assert(fsplan != nullptr);

	elog(DEBUG1, "tsurugi_fdw : %s\nquery:\n%s", __func__, estate->es_sourceText);

	/* Initialize state variable */
	TgFdwDirectModifyState* dmstate = 
		(TgFdwDirectModifyState *) palloc0(sizeof(TgFdwDirectModifyState));
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
static TupleTableSlot* 
tsurugiIterateDirectModify(ForeignScanState* node)
{
	Assert(node != nullptr);

	TgFdwDirectModifyState* dmstate = (TgFdwDirectModifyState*) node->fdw_state;
	EState* estate = node->ss.ps.state;
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
tsurugiEndDirectModify(ForeignScanState* node)
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
static TupleTableSlot*
tsurugiExecForeignInsert(
	EState *estate, 
	ResultRelInfo *rinfo, 
	TupleTableSlot *slot, 
	TupleTableSlot *planSlot)
{
	elog(DEBUG1, "tsurugi_fdw : %s", __func__);
	slot = nullptr;

	elog(ERROR, "tsurugi_fdw does not support execForeignInsert().");

    return slot;
}

/*
 * tsurugiExecForeignUpdate
 */
static TupleTableSlot*
tsurugiExecForeignUpdate(
	EState *estate, 
	ResultRelInfo *rinfo, 
	TupleTableSlot *slot, 
	TupleTableSlot *planSlot)
{
	elog(DEBUG1, "tsurugi_fdw : %s", __func__);
	slot = nullptr;

	elog(ERROR, "tsurugi_fdw does not support execForeignUpdate().");

    return slot;
}

/*
 * tsurugiExecForeignDelete
 */
static TupleTableSlot*
tsurugiExecForeignDelete(
	EState *estate, 
	ResultRelInfo *rinfo, 
	TupleTableSlot *slot, 
	TupleTableSlot *planSlot)
{
	elog(DEBUG1, "tsurugi_fdw : %s", __func__);
	slot = nullptr;

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

/* ===========================================================================
 *
 * FDW Explain functions.
 *
 */
/*
 * tsurugiExplainForeignScan
 *		Produce extra output for EXPLAIN of a ForeignScan on a foreign table
 */
static void 
tsurugiExplainForeignScan(ForeignScanState* node,
						   	ExplainState* es)
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
tsurugiExplainDirectModify(ForeignScanState* node,
							ExplainState* es)
{
	elog(DEBUG1, "tsurugi_fdw : %s", __func__);
}

/*
 * tsurugiAnalyzeForeignTable
 *      Not in use.
 */
static bool 
tsurugiAnalyzeForeignTable(Relation relation,
    AcquireSampleRowsFunc* func,
    BlockNumber* totalpages)
{
	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	return true;
}

/* ===========================================================================
 *
 * FDW Import Foreign Schema functions.
 *
 */

/*
 * tsurugiImportForeignSchema
 *      Import table metadata from a foreign server.
 */
static List* tsurugiImportForeignSchema(ImportForeignSchemaStmt* stmt, Oid serverOid)
{
	ERROR_CODE error = ERROR_CODE::UNKNOWN;

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	/*
	 * Checking the options of the Import Foreign Schema statement.
	 * If the option is specified, an error is assumed.
	 */
	if ((stmt->options != nullptr) && (stmt->options->length > 0))
	{
#if PG_VERSION_NUM >= 130000
		auto def = static_cast<DefElem*>(lfirst(stmt->options->elements));
#else
		auto def = static_cast<DefElem*>(lfirst(stmt->options->head));
#endif
		ereport(ERROR,
				(errcode(ERRCODE_FDW_INVALID_OPTION_NAME),
				 errmsg(R"(unsupported import foreign schema option "%.64s")", def->defname)));
	}

	/* Get information about foreign server and user mapping. */
	ForeignServer* server = GetForeignServer(serverOid);
	//UserMapping* mapping = GetUserMapping(GetUserId(), server->serverid);

	elog(DEBUG2, "ForeignServer::fdwid: %u", server->fdwid);
	elog(DEBUG2, "ForeignServer::serverid: %u", server->serverid);
	elog(DEBUG2, R"(ForeignServer::servername: "%s")", server->servername);

	TableListPtr tg_table_list;
	/* Get a list of table names from Tsurugi. */
	error = Tsurugi::get_list_tables(server->serverid, tg_table_list);
	if (error != ERROR_CODE::OK)
	{
		ereport(ERROR,
			(errcode(ERRCODE_FDW_UNABLE_TO_CREATE_REPLY),
			 errmsg("Failed to retrieve table list from Tsurugi. (error: %d)",
				static_cast<int>(error)),
			 errdetail("%s", Tsurugi::get_error_message(error).c_str())));
	}

	auto tg_table_names = tg_table_list->get_table_names();

#ifdef ENABLE_IMPORT_TABLE_LIMITS
	/* The basic behavior regarding the restriction of tables to be imported is handled
	 * by PostgreSQL functions.
	 * FDW does not need to handle this and should be disabled.
	 */
	if ((stmt->list_type == FDW_IMPORT_SCHEMA_LIMIT_TO) || (stmt->list_type == FDW_IMPORT_SCHEMA_EXCEPT))
	{
		std::unordered_set<std::string> _table_list;
		ListCell* lc;
		foreach (lc, stmt->table_list)
		{
			_table_list.insert(((RangeVar*)lfirst(lc))->relname);
		}

		for (auto ite = tg_table_names.begin(); ite != tg_table_names.end();)
		{
			bool is_exclude_table = false;

			if (stmt->list_type == FDW_IMPORT_SCHEMA_LIMIT_TO)
			{
				/* include only listed tables in import */
				is_exclude_table = (_table_list.find(*ite) == _table_list.end());
			}
			else if (stmt->list_type == FDW_IMPORT_SCHEMA_EXCEPT)
			{
				/* exclude listed tables from import */
				is_exclude_table = (_table_list.find(*ite) != _table_list.end());
			}

			if (is_exclude_table)
			{
				elog(DEBUG2, R"(exclude table "%s" from import.)", (*ite).c_str());
				ite = tg_table_names.erase(ite);
			}
			else
			{
				++ite;
			}
		}
	}
#endif	// ENABLE_IMPORT_TABLE_LIMITS

	List* result_commands = NIL;
	/* CREATE FOREIGN TABLE statments */
	for (const auto& table_name : tg_table_names)
	{
		TableMetadataPtr tg_table_metadata;

		/* Get table metadata from Tsurugi. */
		error = Tsurugi::get_table_metadata(server->serverid, table_name, tg_table_metadata);
		if (error != ERROR_CODE::OK)
		{
			ereport(ERROR,
				(errcode(ERRCODE_FDW_UNABLE_TO_CREATE_REPLY),
				errmsg("Failed to retrieve table metadata from Tsurugi. (error: %d)",
					static_cast<int>(error)),
				errdetail("%s", Tsurugi::get_error_message(error).c_str())));
		}

		/* Get table metadata from Tsurugi. */
		const auto &tg_columns = tg_table_metadata->columns();

		elog(DEBUG2, R"(table: "%.64s")", table_name.c_str());

		std::ostringstream col_def;  /* columns definition */
		/* Create PostgreSQL column definitions based on Tsurugi column definitions. */
		for (const auto& column : tg_columns)
		{
			/* Convert from Tsurugi datatype to PostgreSQL datatype. */
			auto pg_type = Tsurugi::convert_type_to_pg(column.atom_type());
			if (!pg_type)
			{
				ereport(ERROR,
					(errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
					 errmsg(R"(unsupported tsurugi data type "%d")",
					 	static_cast<int>(column.atom_type())),
					 errdetail(R"(table:"%s" column:"%s" type:%d)",
					 	table_name.c_str(),
					 	column.name().c_str(),
					 	static_cast<int>(column.atom_type()))));
			}
			std::string type_name(*pg_type);

			elog(DEBUG2,
				R"(column: {"name":"%.64s", "tsurugi_atom_type":%d, "postgres_type":"%s"})",
				column.name().c_str(), static_cast<int>(column.atom_type()), type_name.c_str());

			/* Create a column definition. */
			if (col_def.tellp() != 0)
			{
				col_def << ",";
			}
			col_def << "\"" << column.name() << "\" " << type_name;
		}

		/* Create a CREATE FOREIGN TABLE statement. */
		auto table_def =
			(boost::format(R"(CREATE FOREIGN TABLE "%s" (%s) SERVER %s)")
				% table_name.c_str() % col_def.str() % server->servername).str();

		elog(DEBUG1, "%.512s", table_def.c_str());

		result_commands = lappend(result_commands, pstrdup(table_def.c_str()));
	}

	return result_commands;
}

/* ===========================================================================
 *
 * Helper functions.
 * 
 */

static void
make_retrieved_attrs(List* telist, List** retrieved_attrs)
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
store_pg_data_type(TgFdwForeignScanState* fsstate, List* tlist, List** retrieved_attrs)
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
			TargetEntry* entry = (TargetEntry*) lfirst(lc);
			Node* node = (Node*) entry->expr;
			count++;

			if (nodeTag(node) == T_Var || nodeTag(node) == T_OpExpr)
			{
				Var* var = (Var*) node;
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

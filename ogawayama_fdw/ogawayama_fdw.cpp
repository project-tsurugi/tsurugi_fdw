/*
 * Copyright 2019-2019 tsurugi project.
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
 *	@file	ogawayama_fdw.cpp
 *	@brief 	Foreign Data Wrapper for Ogawayama.
 */
#ifdef __cplusplus
extern "C" {
#endif

#include "postgres.h"
#include "storage/proc.h"

#include "ogawayama_fdw.h"

#include "foreign/fdwapi.h"
#include "catalog/pg_type.h"
#include "utils/fmgrprotos.h"
#include "utils/memutils.h"
#include "access/xact.h"
#include "access/htup.h"
#include "access/htup_details.h"
#include "utils/syscache.h"

PG_MODULE_MAGIC;

#ifdef __cplusplus
}
#endif

#include <string>
#include <memory>
#include "ogawayama/stub/error_code.h"
#include "ogawayama/stub/api.h"
#include "stub_manager.h"

using namespace ogawayama;

#define DEFAULT_FETCH_SIZE (10000)
typedef struct row_data_
{
	size_t 		number_of_columns;		/* SELECT対象の列数 */
	Oid* 		column_data_types; 		/* SELECT予定の列のデータ型(Oid)用のポインタ */
} RowData;
/*
 *	@brief	クエリー実行毎のFDWの状態
 */
typedef struct ogawayama_fdw_state_
{
	bool 			cursor_exists;			
	const char* 	query_string;		/* SQL Query Text */
	size_t 			number_of_columns;	/* SELECT対象の列数 */
	Oid* 			column_types; 		/* SELECT予定の列のデータ型(Oid)用のポインタ */
	RowData			row;
	MemoryContext 	batch_cxt;			
	std::vector<TupleTableSlot*> tuples;
	decltype(tuples)::iterator tuple_ite;
	size_t			fetch_size;
	size_t			num_tuples;
	size_t			next_tuple;
	bool			eof_reached;
} OgawayamaFdwState;

/*
 *	@brief 	セッションごとのFDWの状態
 */
typedef struct
{
	stub::Transaction*	transaction = nullptr;
 	ResultSetPtr 		result_set = nullptr;
	MetadataPtr 		metadata = nullptr;
	int 				xact_level = 0;		/* FDWが自認する現在のトランザクションレベル */
} OgawayamaFdwInfo;

#ifdef __cplusplus
extern "C" {
#endif
/*
 * SQL functions
 */
PG_FUNCTION_INFO_V1(ogawayama_fdw_handler);

/*
 * FDW callback routines
 */
static void ogawayamaGetForeignRelSize(PlannerInfo* root, 
									   RelOptInfo* baserel, 
								   	   Oid foreigntableid);
static void ogawayamaBeginForeignScan(ForeignScanState* node, int eflags);
static TupleTableSlot* ogawayamaIterateForeignScan(ForeignScanState* node);
static void ogawayamaReScanForeignScan(ForeignScanState* node);
static void ogawayamaEndForeignScan(ForeignScanState* node);

static void ogawayamaBeginDirectModify(ForeignScanState* node, int eflags);
static TupleTableSlot* ogawayamaIterateDirectModify(ForeignScanState* node);
static void ogawayamaEndDirectModify(ForeignScanState* node);

static void ogawayamaExplainForeignScan(ForeignScanState* node, 
									    ExplainState* es);
static void ogawayamaExplainDirectModify(ForeignScanState* node, 
										 ExplainState* es);
static bool ogawayamaAnalyzeForeignTable(
	Relation relation, AcquireSampleRowsFunc* func, BlockNumber* totalpages);
static List* ogawayamaImportForeignSchema(ImportForeignSchemaStmt* stmt, 
										  Oid serverOid);

static TupleTableSlot* ogawayamaExecForeignInsert(EState *estate,
												 ResultRelInfo *rinfo,
												 TupleTableSlot *slot,
												 TupleTableSlot *planSlot);
static TupleTableSlot* ogawayamaExecForeignUpdate(EState *estate,
												 ResultRelInfo *rinfo,
												 TupleTableSlot *slot,
												 TupleTableSlot *planSlot);
static TupleTableSlot* ogawayamaExecForeignDelete(EState *estate,
												 ResultRelInfo *rinfo,
												 TupleTableSlot *slot,
												 TupleTableSlot *planSlot);

#ifdef __cplusplus
}
#endif

/*
 * Helper functions
 */
static OgawayamaFdwState* create_fdwstate();
static void free_fdwstate(OgawayamaFdwState* fdw_state);
static void store_pg_data_type(OgawayamaFdwState* fdw_state, List* tlist);
static bool confirm_columns(MetadataPtr metadata, ForeignScanState* node);
static void create_cursor(ForeignScanState* node);
static void fetch_more_data(ForeignScanState* node);
static void make_virtual_tuple(TupleTableSlot* slot, ForeignScanState* node);
static TupleTableSlot* make_tuple_from_result_set(ResultSetPtr result_set, 
												  OgawayamaFdwState* fdw_state);
static void begin_backend_xact(void);
static void ogawayama_xact_callback (XactEvent event, void *arg);

extern PGDLLIMPORT PGPROC *MyProc;

static OgawayamaFdwInfo fdw_info_;

/*
 * Foreign-data wrapper handler function: return a struct with pointers
 * to my callback routines.
 */
Datum
ogawayama_fdw_handler(PG_FUNCTION_ARGS)
{
	elog(DEBUG2, "ogawayama_fdw_handler() started.");

	FdwRoutine* routine = makeNode(FdwRoutine);

	routine->GetForeignRelSize = ogawayamaGetForeignRelSize;

	/*Functions for scanning foreign tables*/
	routine->BeginForeignScan = ogawayamaBeginForeignScan;
	routine->IterateForeignScan = ogawayamaIterateForeignScan;
	routine->ReScanForeignScan = ogawayamaReScanForeignScan;
	routine->EndForeignScan = ogawayamaEndForeignScan;

	/*Functions for updating foreign tables*/
	routine->BeginDirectModify = ogawayamaBeginDirectModify;
	routine->IterateDirectModify = ogawayamaIterateDirectModify;
	routine->EndDirectModify = ogawayamaEndDirectModify;

	/*Support functions for EXPLAIN*/
	routine->ExplainForeignScan = ogawayamaExplainForeignScan;
	routine->ExplainDirectModify = ogawayamaExplainDirectModify;

	/*Support functions for ANALYZE*/
	routine->AnalyzeForeignTable = ogawayamaAnalyzeForeignTable;

	/*Support functions for IMPORT FOREIGN SCHEMA*/
	routine->ImportForeignSchema = ogawayamaImportForeignSchema;

    /*Functions for foreign modify*/
	routine->ExecForeignInsert = ogawayamaExecForeignInsert;
	routine->ExecForeignUpdate = ogawayamaExecForeignUpdate;
	routine->ExecForeignDelete = ogawayamaExecForeignDelete;

	ERROR_CODE error = StubManager::init();
	if (error != ERROR_CODE::OK) 
	{
		elog(ERROR, "StubManager::init() failed. (%d)", (int) error);
	}

	elog(DEBUG2, "ogawayama_fdw_handler() done.");

	PG_RETURN_POINTER(routine);
}

/*
 *	@note	Not in use.
 */
static void ogawayamaGetForeignRelSize(
	PlannerInfo* root, RelOptInfo* baserel, Oid foreigntableid)
{
	elog(DEBUG2, "ogawayamaGetForeignRelSize() started.");

	elog(DEBUG2, "ogawayamaGetForeignRelSize() done.");
}

/*
 *	@brief	Preparation for scanning foreign tables.
 *	@param	[in] Foreign scan inforamtion.
 *	@param	[in] Some flag parameters. (e.g. EXEC_FLAG_EXPLAIN_ONLY)
 */
static void 
ogawayamaBeginForeignScan(ForeignScanState* node, int eflags)
{
	elog(DEBUG2, "ogawayamaBeginForeignScan() started.");

	Assert(node != nullptr);

	ForeignScan* fsplan = (ForeignScan*) node->ss.ps.plan;
	EState*	estate = node->ss.ps.state;
	OgawayamaFdwState* fdw_state = create_fdwstate();

	fdw_state->fetch_size = DEFAULT_FETCH_SIZE;

	/* Create MemoryContext for tuple data */
	fdw_state->batch_cxt = AllocSetContextCreate(
		estate->es_query_cxt, "ogawayama_fdw tuple data", ALLOCSET_DEFAULT_SIZES);

	/* トランザクション開始 */
	begin_backend_xact();

	/* SELECT対象の列のデータ型を格納 */
	store_pg_data_type(fdw_state, fsplan->scan.plan.targetlist);
	
    fdw_state->query_string = estate->es_sourceText;

	 /* fdw_stateをnode->fdw_stateに格納する */
	 node->fdw_state = fdw_state;

	elog(DEBUG2, "ogawayamaBeginForeignScan() done.");
}

/*
 *	@briref	Scanning row data from foreign tables.
 *	@param	[in] Foreign scan inforamtion.
 *	@return	Scaned row data.
 */
static TupleTableSlot* 
ogawayamaIterateForeignScan(ForeignScanState* node)
{
	elog(DEBUG2, "ogawayamaIterateForeignScan() started.");

	Assert(node != nullptr);
	Assert(fdw_info_.transaction != nullptr);

	TupleTableSlot* slot = node->ss.ss_ScanTupleSlot;
	OgawayamaFdwState* fdw_state = (OgawayamaFdwState*) node->fdw_state;

	if (!fdw_state->cursor_exists)
		create_cursor(node);

	if (fdw_state->next_tuple >= fdw_state->num_tuples)
	{
		/* No point in another fetch if we already detected EOF, though. */
		if (!fdw_state->eof_reached)
			fetch_more_data(node);

		/* If we didn't get any tuples, must be end of data */		
		if (fdw_state->next_tuple >= fdw_state->num_tuples)
		{
			ExecClearTuple(slot);
			goto EXIT;
		}
	}
	make_virtual_tuple(slot, node);
	ExecStoreVirtualTuple(slot);

	fdw_state->tuple_ite++;
	fdw_state->next_tuple = std::distance(
		fdw_state->tuples.begin(), fdw_state->tuple_ite);

EXIT:
	elog(DEBUG2, "ogawayamaIterateForeignScan() done.");

	return slot;
}

/*
 *	@note	Not in use.
 */
static void 
ogawayamaReScanForeignScan(ForeignScanState* node)
{
	elog(DEBUG2, "ogawayamaReScanForeignScan() started.");
	elog(DEBUG2, "ogawayamaReScanForeignScan() done.");
}

/*
 *	@brief	Clean up for scanning foreign tables.
 *	@param	[in] Foreign scan information.
 */
static void 
ogawayamaEndForeignScan(ForeignScanState* node)
{
	elog(DEBUG2, "ogawayamaEndForeignScan() started.");

	OgawayamaFdwState* fdw_state = (OgawayamaFdwState*) node->fdw_state;

	/* close cursor */
	fdw_info_.result_set = nullptr;

	StubManager::end();
	fdw_info_.transaction = nullptr;
	fdw_info_.xact_level--;
	elog(DEBUG2, "xact_level: (%d)", fdw_info_.xact_level);

	if (fdw_state != nullptr)
		free_fdwstate(fdw_state);
	
	/* MemoryContexts will be deleted automatically. */

	elog(DEBUG2, "ogawayamaEndForeignScan() done.");
}

/*
 * 	@brief	Preparation for modifying foreign tables.
 *	@param	[in] Foreign scan information.
 *	@param	[in] Some flags. (e.g. EXEC_FLAG_EXPLAIN_ONLY)
 */
static void 
ogawayamaBeginDirectModify(ForeignScanState* node, int eflags)
{
	elog(DEBUG2, "ogawayamaBeginDirectModify() started.");

	Assert(node != nullptr);

	EState* estate = node->ss.ps.state;

	OgawayamaFdwState* fdw_state = create_fdwstate();
	if (fdw_state == nullptr)
	{
		elog(ERROR, "create_fdw_state() failed.");
	}

	begin_backend_xact();

 	fdw_state->query_string = estate->es_sourceText;
	 
	 node->fdw_state = fdw_state;

 	elog(DEBUG2, "ogawayamaBeginDirectModify() done.");
}

/*
 *	@biref	Execute Insert/Upate/Delete command to foreign tables.
 *	@param	[in] Foreign scan information.
 *	@return	only nullptr.
 */
static TupleTableSlot* 
ogawayamaIterateDirectModify(ForeignScanState* node)
{
	elog(DEBUG2, "ogawayamaIterateDirectModify() started.");

	Assert(node != nullptr);
	Assert(fdw_info_.transaction != nullptr);

	OgawayamaFdwState* fdw_state = (OgawayamaFdwState*) node->fdw_state;
	TupleTableSlot* slot = nullptr;
	ERROR_CODE error;

	elog(DEBUG1, "statement string: \"%s\"", fdw_state->query_string);

  	std::string query(fdw_state->query_string);
	// trim terminal semi-column.
	if (query.back() == ';')
	{
		query.pop_back();
	}
	elog(DEBUG1, "statement string: \"%s\"", query.c_str());
	elog(DEBUG2, "transaction::execute_statement() start.");
	error = fdw_info_.transaction->execute_statement(query);
	elog(DEBUG2, "transaction::execute_statement() done.");
	if (error != ERROR_CODE::OK) 
    {
		elog(ERROR, "transaction::execute_statement() failed. (%d)", (int) error);	
	}
	
	elog(DEBUG2, "ogawayamaIterateDirectModify() done.");

	return slot;	
}

/*
 * 	@biref	Clean up for modifying foreign tables.
 *	@param	[in] foreign scan information.
 */
static void 
ogawayamaEndDirectModify(ForeignScanState* node)
{
	elog(DEBUG2, "ogawayamaEndDirectModify() started.");

	StubManager::end();
	fdw_info_.transaction = nullptr;
	fdw_info_.xact_level--;
	elog(DEBUG2, "xact_level: (%d)", fdw_info_.xact_level);

	if (node->fdw_state != nullptr)
		free_fdwstate((OgawayamaFdwState*) node->fdw_state);

	elog(DEBUG2, "ogawayamaEndDirectModify() done.");
}

/*
 * 	@note	Not in use.
 */
static TupleTableSlot*
ogawayamaExecForeignInsert(
	EState *estate, 
	ResultRelInfo *rinfo, 
	TupleTableSlot *slot, 
	TupleTableSlot *planSlot)
{
	elog(DEBUG2, "ogawayamaExecForeignInsert() started.");
	slot = nullptr;
	elog(DEBUG2, "ogawayamaExecForeignInsert() done.");

	return slot;
}

/*
 * 	@note	Not in use.
 */
static TupleTableSlot*
ogawayamaExecForeignUpdate(
	EState *estate, 
	ResultRelInfo *rinfo, 
	TupleTableSlot *slot, 
	TupleTableSlot *planSlot)
{
	elog(DEBUG2, "ogawayamaExecForeignUpdate() started.");
	slot = nullptr;
	elog(DEBUG2, "ogawayamaExecForeignUpdate() done.");

	return slot;
}

/*
 * 	@note	Not in use.
 */
static TupleTableSlot*
ogawayamaExecForeignDelete(
	EState *estate, 
	ResultRelInfo *rinfo, 
	TupleTableSlot *slot, 
	TupleTableSlot *planSlot)
{
	elog(DEBUG2, "ogawayamaExecForeignDelete() started.");
	slot = nullptr;
	elog(DEBUG2, "ogawayamaExecForeignDelete() done.");

	return slot;
}

/*
 * Functions to be implemented in the future are below.  
 * 
 */

/*
 *	@note	Not in use.
 */
static void 
ogawayamaExplainForeignScan(ForeignScanState* node,
						   	ExplainState* es)
{
	elog(DEBUG2, "ogawayamaExplainForeignScan() started.");
	elog(DEBUG2, "ogawayamaExplainForeignScan() done.");
}

/*
 *	@note	Not in use.
 */
static void 
ogawayamaExplainDirectModify(ForeignScanState* node,
							ExplainState* es)
{
	elog(DEBUG2, "ogawayamaExplainDirectModify() started.");
	elog(DEBUG2, "ogawayamaExplainDirectModify() done.");
}

/*
 *	@note	Not in use.
 */
static bool ogawayamaAnalyzeForeignTable(Relation relation,
							AcquireSampleRowsFunc* func,
							BlockNumber* totalpages)
{
	elog(DEBUG2, "ogawayamaAnalyzeForeignTable() started.");
	elog(DEBUG2, "ogawayamaAnalyzeForeignTable() done.");

	return true;
}

/*
 *	@note	Not in use.
 */
static List* 
ogawayamaImportForeignSchema(ImportForeignSchemaStmt* stmt,
							Oid serverOid)
{
	elog(DEBUG2, "ogawayamaImportForeignSchema() started.");
	List	*commands = NIL;
	elog(DEBUG2, "ogawayamaImportForeignSchema() done.");

	return commands;
}

/*
 *	@brief:	Create OgawayamaFdwState structure.
 */
static OgawayamaFdwState* 
create_fdwstate()
{
	OgawayamaFdwState* fdw_state = 
		(OgawayamaFdwState*) palloc0(sizeof(OgawayamaFdwState));
	
	fdw_state->cursor_exists = false;
	fdw_state->number_of_columns = 0;
	fdw_state->column_types = nullptr;

	return fdw_state;
}

/*
 *	@brief:	free allocated memories.
 *	@param:	[in] Ogawayama-fdw state.
 */
static void 
free_fdwstate(OgawayamaFdwState* fdw_state)
{
	if (fdw_state->column_types != nullptr) 
	{
		pfree(fdw_state->column_types);
		fdw_state->column_types = nullptr;
	}

	if (!fdw_state->tuples.empty())
	{
		for (auto ite = fdw_state->tuples.begin(); ite == fdw_state->tuples.end(); ite++)
		{
			TupleTableSlot* tuple = *ite;
			free(tuple->tts_values);
			free(tuple->tts_isnull);
			free(tuple);
		}
	}

 	pfree(fdw_state);
}

/*
 * 	@biref	Scanning data type of target list from PG tables.
 * 	@param	[in/out] Store data type information.
 * 	@param	[in] target list. (TargetEntry->Exprは全てVarとなっている前提)
 * 	@note	target list: SELECT対象の列
 *
 * 	oracle_fdwのconvertTupleに影響を受け、PostgreSQLでのデータ型も把握した方が良いと
 * 	判断したため用意した関数。
 */
static void 
store_pg_data_type(OgawayamaFdwState* fdw_state, List* tlist)
{
	ListCell* lc;

	if (tlist != NULL)
	{
		Oid *data_types = (Oid *)palloc(sizeof(Oid) * tlist->length);

		int i = 0;
		int count = 0;
		foreach (lc, tlist)
		{
			TargetEntry *entry = (TargetEntry *)lfirst(lc);
			Node *node = (Node *)entry->expr;
			if (entry->resjunk == false)
			{
				count++;
			}

			if (nodeTag(node) == T_Var)
			{
				Var *var = (Var *)node;
				data_types[i] = var->vartype;
			}
			else
			{
				elog(ERROR, "Unexpected data type in target list. (index: %d, type:%u)",
					 i, (unsigned int)nodeTag(node));
			}
			i++;
		}

		fdw_state->column_types = data_types;
		fdw_state->number_of_columns = count;
	}
}

/*
 *	@brief	dispatch the query to ogawayama stub.
 */
static void 
create_cursor(ForeignScanState* node)
{
	Assert(node!= nullptr);

	OgawayamaFdwState* fdw_state = (OgawayamaFdwState*) node->fdw_state;

	elog(DEBUG1, "query string: \"%s\"", fdw_state->query_string);

	// trim terminal semi-column.
	std::string query(fdw_state->query_string);
	if (query.back() == ';') 
	{
		query.pop_back();	// trim the trailing colon.
	}
	fdw_info_.result_set = nullptr;

	/* dispatch query */
	elog(DEBUG1, "query string: \"%s\"", query.c_str());
	elog(DEBUG2, "transaction::execute_query() start.");
	ERROR_CODE error = fdw_info_.transaction->execute_query(query, fdw_info_.result_set);
	elog(DEBUG2, "transaction::execute_query() done.");
	if (error != ERROR_CODE::OK)
	{
		elog(ERROR, "Transaction::execute_query() failed. (%d)", (int) error);
		fdw_info_.result_set = nullptr;
		fdw_info_.transaction->rollback();
		fdw_info_.xact_level--;
	}
	
	error = fdw_info_.result_set->get_metadata(fdw_info_.metadata);
	if (error != ERROR_CODE::OK)
	{
		elog(ERROR, "result_set::get_metadata() failed. (%d)", (int) error);
	}
	if (!confirm_columns(fdw_info_.metadata, node))
	{
		elog(ERROR, "NOT matched columns between PostgreSQL and Ogawayama.");
	}

	fdw_state->cursor_exists = true;
	fdw_state->tuples.clear();
	fdw_state->num_tuples = 0;
	fdw_state->next_tuple = 0;
	fdw_state->eof_reached = false;
}

/*
 * 	@brief	Confirm column information between PostgreSQL and Ogawayama.
 * 	@param	[in] Ogawayama column information.
 * 	@param	[in] PostgreSQL column information.
 * 	@return true if matched column information.
 * 	@note	This function may be eliminated for performance improvement in the future.
 */
static bool
confirm_columns(MetadataPtr metadata, ForeignScanState* node)
{
	elog(DEBUG4, "confirm_columns() started.");

	OgawayamaFdwState* fdw_state = (OgawayamaFdwState*) node->fdw_state;
	bool ret = true;

	if (metadata->get_types().size() != fdw_state->number_of_columns)
	{
		elog(ERROR, "Number of columns do NOT match. (og: %d), (pg: %lu)",
			(int) metadata->get_types().size(), fdw_state->number_of_columns);
	}

	Size i = 0;
	for (auto types: metadata->get_types())
	{
		switch (static_cast<stub::Metadata::ColumnType::Type>(types.get_type()))
		{
			case stub::Metadata::ColumnType::Type::INT16:
				if (fdw_state->column_types[i] != INT2OID)
				{
					elog(ERROR, 
						"Don't match data type of the column. " 
						"(column: %lu) (og: %d) (pg: %u)", 
						i, (int) types.get_type(), fdw_state->column_types[i] );
					ret = false;
				}
				break;

			case stub::Metadata::ColumnType::Type::INT32:
				if (fdw_state->column_types[i] != INT4OID)
				{
					elog(ERROR, 
						"Don't match data type of the column. " 
						"(column: %lu) (og: %d) (pg: %u)", 
						i, (int) types.get_type(), fdw_state->column_types[i] );
					ret = false;
				}
				break;

			case stub::Metadata::ColumnType::Type::INT64:
				if (fdw_state->column_types[i] != INT8OID)
				{
					elog(ERROR, 
						"Don't match data type of the column. " 
						"(column: %lu) (og: %d) (pg: %u)", 
						i, (int) types.get_type(), fdw_state->column_types[i] );
					ret = false;
				}
				break;

			case stub::Metadata::ColumnType::Type::FLOAT32:
				if (fdw_state->column_types[i] != FLOAT4OID)
				{
					elog(ERROR, 
						"Don't match data type of the column. " 
						"(column: %lu) (og: %d) (pg: %u)", 
						i, (int) types.get_type(), fdw_state->column_types[i] );
					ret = false;
				}
				break;

			case stub::Metadata::ColumnType::Type::FLOAT64:
				if (fdw_state->column_types[i] != FLOAT8OID)
				{
					elog(ERROR, 
						"Don't match data type of the column. " 
						"(column: %lu) (og: %d) (pg: %u)", 
						i, (int) types.get_type(), fdw_state->column_types[i] );
				}
				break;

			case stub::Metadata::ColumnType::Type::TEXT:
				if (fdw_state->column_types[i] != BPCHAROID &&
					fdw_state->column_types[i] != VARCHAROID &&
					fdw_state->column_types[i] != TEXTOID)
				{
					elog(ERROR, 
						"Don't match data type of the column. " 
						"(column: %lu) (og: %d) (pg: %u)", 
						i, (int) types.get_type(), fdw_state->column_types[i] );
					ret = false;
				}
				break;

			case stub::Metadata::ColumnType::Type::NULL_VALUE:
				elog(DEBUG1, "nullptr_VALUE found. (column: %lu)", i);
				ret = false;
				break;

			default:
				elog(ERROR, "Unexpected data type of the column. " 
					"(column: %lu, Og type: %u)", i, (int) types.get_type());
				ret = false;
				break;
		}
		i++;
	}

	elog(DEBUG4, "confirm_columns() done.");

	return ret;
}

/*
 *	@breif	make virtual tuple from result set.
 */
static void
make_virtual_tuple(TupleTableSlot* slot, ForeignScanState* node)
{
	OgawayamaFdwState* fdw_state = (OgawayamaFdwState*) node->fdw_state;

	TupleTableSlot* tuple = *fdw_state->tuple_ite;
	for (size_t i = 0; i < fdw_state->number_of_columns; i++)
	{
		slot->tts_values[i] = tuple->tts_values[i];
		slot->tts_isnull[i] = tuple->tts_isnull[i];
	}
}

/*
 *	@brief	fetch result set from ogawayama stub.
 */
static void
fetch_more_data(ForeignScanState* node)
{
	OgawayamaFdwState* fdw_state = (OgawayamaFdwState*) node->fdw_state;
	MemoryContext oldcontext = nullptr;

	fdw_state->tuples.clear();
	MemoryContextReset(fdw_state->batch_cxt);
	oldcontext = MemoryContextSwitchTo(fdw_state->batch_cxt);

	PG_TRY();
	{
		/* fetch result set */
		ERROR_CODE error = fdw_info_.result_set->next();
		while (error == ERROR_CODE::OK)
		{
			TupleTableSlot* tuple = make_tuple_from_result_set(fdw_info_.result_set, fdw_state);
			fdw_state->tuples.push_back(tuple);
			error = fdw_info_.result_set->next();
		}
		if (error == ERROR_CODE::END_OF_ROW) 
		{
			elog(DEBUG2, "End of row.");
		}
		else
		{
			elog(ERROR, "result_set::next() failed. (%d)", (int) error);
		}
		fdw_state->tuple_ite = fdw_state->tuples.begin();
		fdw_state->num_tuples = fdw_state->tuples.size();
		fdw_state->eof_reached = (fdw_state->num_tuples < fdw_state->fetch_size);

		elog(DEBUG1, "result set count: %d", (int) fdw_state->num_tuples);
	}
	PG_CATCH();
	{
		PG_RE_THROW();
	}
	PG_END_TRY();

	MemoryContextSwitchTo(oldcontext);
}

/*
 *	@breif	obtain tuple data from Ogawayama and convert data type.
 *	@param	[in] result set of query.
 *	@param	[in] FDW state.
 */
static TupleTableSlot* 
make_tuple_from_result_set(ResultSetPtr result_set, OgawayamaFdwState* fdw_state)
{
	elog(DEBUG4, "make_tuple_from_result_set() started.");

	TupleTableSlot* tuple = (TupleTableSlot*) palloc(sizeof(TupleTableSlot));
	tuple->tts_values = (Datum *) palloc0(fdw_state->number_of_columns * sizeof(Datum));
	tuple->tts_isnull = (bool *) palloc0(fdw_state->number_of_columns * sizeof(bool));

	for (size_t i = 0; i < fdw_state->number_of_columns; i++)
	{
		tuple->tts_values[i] = PointerGetDatum(nullptr);
		tuple->tts_isnull[i] = true;

		switch (fdw_state->column_types[i])
		{
			case INT2OID:
				{
					std::int16_t value;
					if (result_set->next_column(value) == ERROR_CODE::OK)
					{
						tuple->tts_values[i] = Int16GetDatum(value);
						tuple->tts_isnull[i] = false;
					}
				}
				break;

			case INT4OID:
				{
					std::int32_t value;
					if (result_set->next_column(value) == ERROR_CODE::OK)
					{
						tuple->tts_values[i] = Int32GetDatum(value);
						tuple->tts_isnull[i] = false;
					}
				}
				break;

			case INT8OID:
				{
					std::int64_t value;
					if (result_set->next_column(value) == ERROR_CODE::OK) 
					{
						tuple->tts_values[i] = Int64GetDatum(value);
						tuple->tts_isnull[i] = false;
					}
				}
				break;

			case FLOAT4OID:
				{
					float4 value;
					if (result_set->next_column(value) == ERROR_CODE::OK)
					{
						tuple->tts_values[i] = Float4GetDatum(value);
						tuple->tts_isnull[i] = false;
					}
				}
				break;

			case FLOAT8OID:
				{
					float8 value;
					if (result_set->next_column(value) == ERROR_CODE::OK)
					{
						tuple->tts_values[i] = Float8GetDatum(value);
						tuple->tts_isnull[i] = false;
					}
				}
				break;
			
			case BPCHAROID:
			case VARCHAROID:
			case TEXTOID:
				{
					Datum dat;
					std::string_view value;
					result_set->next_column(value);
					dat = CStringGetDatum(value.data());				
					if (dat == (Datum) nullptr)
					{
						break;
					}
					else
					{
						HeapTuple 	heap_tuple;
						regproc 	typinput;
						int 		typemod;

						heap_tuple = SearchSysCache1(
							TYPEOID, ObjectIdGetDatum(fdw_state->column_types[i]));
						if (!HeapTupleIsValid(heap_tuple))
						{
							elog(ERROR, "cache lookup failed for type %u",
								 fdw_state->column_types[i]);
						}
						typinput = ((Form_pg_type)GETSTRUCT(heap_tuple))->typinput;
						typemod = ((Form_pg_type)GETSTRUCT(heap_tuple))->typtypmod;
						ReleaseSysCache(heap_tuple);
						tuple->tts_values[i] = OidFunctionCall3(typinput, dat, ObjectIdGetDatum(InvalidOid), Int32GetDatum(typemod));
						tuple->tts_isnull[i] = false;
					}
				}
				break;
				
			default:
				elog(ERROR, "Invalid data type of column.");
				break;
		}
	}

	elog(DEBUG4, "make_tuple_from_result_set() done.");

	return tuple;
}

/*
 * @biref	Begin transaction.
 * 
 * V0版では、フロントエンド側のトランザクション(ローカルトランザクション)が
 * ネストされている場合はエラーとする。
 */
static void
begin_backend_xact(void)
{
	/* ローカルトランザクションのネストレベルを取得する */
    int local_xact_level = GetCurrentTransactionNestLevel();
	elog(DEBUG1, "Local transaction level: (%d)", local_xact_level);

	if (local_xact_level <= 0)
	{
		elog(WARNING, "local_xact_level (%d)", local_xact_level);
	}
	else if (local_xact_level == 1)
	{
		if (fdw_info_.xact_level == 0)
		{	
			if (fdw_info_.transaction == nullptr)
			{
				ERROR_CODE error = StubManager::begin(&fdw_info_.transaction);
				if (error != ERROR_CODE::OK) 
				{
					elog(ERROR, "Connection::begin() failed. (%d)", (int) error);
				}
			}
			else
			{
				elog(ERROR, "transaction alreayd started.");
			}
			fdw_info_.xact_level++;
			elog(DEBUG1, "StubManager::begin() done. (xact_level: %d)", 
			fdw_info_.xact_level);
		}
	}
	else if (local_xact_level >= 2)
	{
		elog(ERROR, "Nested transaction is NOT supported.");
	}
}

/*
 * 	@biref	Callback function for transaction events.
 *	@param	Transaction event.
 */
static void
ogawayama_xact_callback (XactEvent event, void *arg)
{
	elog(DEBUG4, "ogawayama_xact_callback() started. ");

    int local_xact_level = GetCurrentTransactionNestLevel();
	elog(DEBUG1, "Local transaction level: (%d)", local_xact_level);

	if (fdw_info_.xact_level > 0)
	{
		/* 入力されるeventの内容は、xact.hに記載あり */
		switch (event)
		{
			case XACT_EVENT_PRE_COMMIT:
				elog(DEBUG1, "XACT_EVENT_PRE_COMMIT");
				break;

			case XACT_EVENT_COMMIT:
				elog(DEBUG1, "XACT_EVENT_COMMIT");
				fdw_info_.transaction->commit();
				fdw_info_.transaction = nullptr;
				StubManager::end();
				fdw_info_.xact_level--;
				elog(DEBUG1, "Transaction::commit() done. (xact_level: %d)", 
					fdw_info_.xact_level);
				break;

			case XACT_EVENT_ABORT:
				elog(DEBUG1, "XACT_EVENT_ABORT (xact_level: %d)", fdw_info_.xact_level);
				fdw_info_.transaction->rollback();
				fdw_info_.transaction = nullptr;
				StubManager::end();
				fdw_info_.xact_level--;
				elog(DEBUG1, "Transaction::rollback() done. (xact_level: %d)", 
					fdw_info_.xact_level);
				break;

			case XACT_EVENT_PRE_PREPARE:
				elog(DEBUG1, "XACT_EVENT_PRE_PREPARE");
				break;

			case XACT_EVENT_PREPARE:
				elog(DEBUG1, "XACT_EVENT_PREPARE");
				break;

			case XACT_EVENT_PARALLEL_COMMIT:
			case XACT_EVENT_PARALLEL_ABORT:
			case XACT_EVENT_PARALLEL_PRE_COMMIT:
				elog(DEBUG1, "Unexpected XACT event occurred. (%d)", event);
				break;

			default:
				elog(WARNING, "Unexpected XACT event occurred. (Unknown event)");
				break;
		}
	}

	elog(DEBUG4, "ogawayama_xact_callback() done.");
}

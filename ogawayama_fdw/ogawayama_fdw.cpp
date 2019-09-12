/*
 * Copyright 2019-2019 tsurugi project.
<<<<<<< HEAD
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
=======
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
>>>>>>> 9d5b16f474cab972798c5594cb8b222ea52dc2c1
 */
#ifdef __cplusplus
extern "C" {
#endif

#include "postgres.h"

#include "ogawayama_fdw.h"

#include "foreign/fdwapi.h"
#include "catalog/pg_type.h"
#include "utils/fmgrprotos.h"
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
#include "ogawayama/stub/api.h"

/*
 *	@brief	クエリー実行毎のFDWの状態
 */
typedef struct ogawayama_fdw_state_
{
	bool 		cursor_exists;			
	const char* query_string;	/* SQL Query Text */
	size_t 		num_columns;	/* SELECT対象の列数 */
	Oid* 		pgtype; 		/* SELECT予定の列のデータ型(Oid)用のポインタ */
} OgawayamaFdwState;

/*
 *	@brief 	セッションごとのFDWの状態
 */
typedef struct ogawayama_fdw_info_
{
	bool		connected;		/* ogawayama-stubとのコネクション */
	int 		xact_level;		/* FDWが自認する現在のトランザクションレベル */
	int			pid;			/* process ID */
} OgawayamaFdwInfo;

#ifdef __cplusplus
extern "C" {
#endif
/*
 * SQL functions
 */
PG_FUNCTION_INFO_V1( ogawayama_fdw_handler );

/*
 * FDW callback routines
 */
static void ogawayamaGetForeignRelSize( PlannerInfo* root, 
							RelOptInfo* baserel, 
							Oid foreigntableid );
static void ogawayamaBeginForeignScan( ForeignScanState* node, int eflags );
static TupleTableSlot* ogawayamaIterateForeignScan( ForeignScanState* node );
static void ogawayamaReScanForeignScan( ForeignScanState* node );
static void ogawayamaEndForeignScan( ForeignScanState* node );

static void ogawayamaBeginDirectModify( ForeignScanState* node, int eflags );
static TupleTableSlot* ogawayamaIterateDirectModify( ForeignScanState* node );
static void ogawayamaEndDirectModify( ForeignScanState* node );

static void ogawayamaExplainForeignScan( ForeignScanState* node, 
							ExplainState* es );
static void ogawayamaExplainDirectModify( ForeignScanState* node, 
							ExplainState* es );
static bool ogawayamaAnalyzeForeignTable( 
	Relation relation, AcquireSampleRowsFunc* func, BlockNumber* totalpages );
static List* ogawayamaImportForeignSchema( ImportForeignSchemaStmt* stmt, 
							Oid serverOid );

static TupleTableSlot* ogawayamaExecForeignInsert( EState *estate,
                  ResultRelInfo *rinfo,
                  TupleTableSlot *slot,
                  TupleTableSlot *planSlot );
static TupleTableSlot* ogawayamaExecForeignUpdate( EState *estate,
                  ResultRelInfo *rinfo,
                  TupleTableSlot *slot,
                  TupleTableSlot *planSlot );
static TupleTableSlot* ogawayamaExecForeignDelete( EState *estate,
                  ResultRelInfo *rinfo,
                  TupleTableSlot *slot,
                  TupleTableSlot *planSlot );

#ifdef __cplusplus
}
#endif

/*
 * Helper functions
 */
static void init_fdw_info( FunctionCallInfo fcinfo  );
static OgawayamaFdwState* create_fdwstate();
static void free_fdwstate( OgawayamaFdwState* fdw_tate );
static bool get_connection( int pid );
static void store_pg_data_type( OgawayamaFdwState* fdw_state, List* tlist );
static bool confirm_columns( MetadataPtr metadata, OgawayamaFdwState* fdw_state );
static void convert_tuple( 
	OgawayamaFdwState* fdw_state, ResultSetPtr resultset, Datum* values, bool* nulls );
static void begin_backend_xact( void );
static void ogawayama_xact_callback ( XactEvent event, void *arg );

using namespace ogawayama::stub;

static StubPtr stub_;
static ConnectionPtr connection_;
static TransactionPtr transaction_;
static ResultSetPtr resultset_;
static MetadataPtr metadata_;
static OgawayamaFdwInfo fdw_info_;

/*
 * Foreign-data wrapper handler function: return a struct with pointers
 * to my callback routines.
 */
Datum
ogawayama_fdw_handler( PG_FUNCTION_ARGS )
{
	elog( DEBUG3, "ogawayama_fdw_handler() started." );

	FdwRoutine* routine = makeNode( FdwRoutine );

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

	init_fdw_info( fcinfo );

	fdw_info_.connected = get_connection( fdw_info_.pid );
	if ( !fdw_info_.connected ) 
	{
		elog( ERROR, "Connecting to Ogawayama failed." );
	}

	elog( DEBUG3, "ogawayama_fdw_handler() done." );

	PG_RETURN_POINTER( routine );
}

/*
 *	@note	Not in use.
 */
static void ogawayamaGetForeignRelSize( 
	PlannerInfo* root, RelOptInfo* baserel, Oid foreigntableid )
{
	elog( DEBUG3, "ogawayamaGetForeignRelSize() started." );

	elog( DEBUG3, "ogawayamaGetForeignRelSize() done." );
}

/*
 *	@brief	Preparation for scanning foreign tables.
 *	@param	[in] Foreign scan inforamtion.
 *	@param	[in] Some flag parameters. (e.g. EXEC_FLAG_EXPLAIN_ONLY)
 */
static void 
ogawayamaBeginForeignScan( ForeignScanState* node, int eflags )
{
	elog( DEBUG3, "ogawayamaBeginForeignScan() started." );

	ForeignScan* fsplan = (ForeignScan*) node->ss.ps.plan;
	EState*	estate = node->ss.ps.state;
	OgawayamaFdwState* fdw_state = create_fdwstate();

	/* コネクション接続確認 */
	if ( !fdw_info_.connected ) 
	{
		fdw_info_.connected = get_connection( fdw_info_.pid );
		if ( !fdw_info_.connected ) 
		{
			elog( ERROR, "Connecting to Ogawayama failed." );
		}
	}

	/* トランザクションの開始(確認) */
	begin_backend_xact();

	/* SELECT対象の列数を設定 */
	fdw_state->num_columns = fsplan->scan.plan.targetlist->length;

	/* SELECT対象の列のデータ型を格納 */
	store_pg_data_type( fdw_state, fsplan->scan.plan.targetlist );
	
    fdw_state->query_string = estate->es_sourceText;

	 /* fdw_stateをnode->fdw_stateに格納する */
	 node->fdw_state = fdw_state;

	elog( DEBUG3, "ogawayamaBeginForeignScan() done." );
}

/*
 *	@briref	Scanning row data from foreign tables.
 *	@param	[in] Foreign scan inforamtion.
 *	@return	Scaned row data.
 */
static TupleTableSlot* 
ogawayamaIterateForeignScan( ForeignScanState* node )
{
	elog( DEBUG3, "ogawayamaIterateForeignScan() started." );

	TupleTableSlot* slot = node->ss.ss_ScanTupleSlot;
	OgawayamaFdwState* fdw_state = (OgawayamaFdwState*) node->fdw_state;
	ErrorCode error;

	//* initialize virtual tuple */
	ExecClearTuple( slot );

	if ( !fdw_state->cursor_exists )
	{
		/* open cursor */
		try {
			elog( DEBUG3, "query string: \"%s\"", fdw_state->query_string );

			std::string query( fdw_state->query_string );
			query.pop_back();	// セミコロンを取り除く
			error = transaction_->execute_query( query, resultset_ );
			if ( error != ErrorCode::OK )
            {
				elog( ERROR, "Connection::execute_query() failed. (%d)", (int) error );
			}
			error = resultset_->get_metadata( metadata_ );
			if ( error != ErrorCode::OK )
            {
				elog( ERROR, "Connection::get_metadata() failed. (%d)", (int) error );
			}
			if ( !confirm_columns( metadata_, fdw_state ) )
			{
				elog( ERROR, "Data type of columns do NOT match." );
			}			
		}
		catch(...) {
			elog( ERROR, "Unexpected exception caught." );
		}
		fdw_state->cursor_exists = true;
	}

	error = resultset_->next();
	if ( error == ErrorCode::OK ) 
	{
		/* 1行分fetchする */
		convert_tuple( fdw_state, resultset_, slot->tts_values, slot->tts_isnull );
		ExecStoreVirtualTuple( slot );
	}
	else if ( error == ErrorCode::END_OF_ROW )
	{
		/* 読み込み完了 */
		elog( DEBUG3, "End of row." );
	}
	else 
	{
		elog( ERROR, "ResultSet::next() failed. (%d)", (int) error );
	}

	elog( DEBUG3, "ogawayamaIterateForeignScan() done." );

	return slot;
}

/*
 *	@note	Not in use.
 */
static void 
ogawayamaReScanForeignScan( ForeignScanState* node )
{
	elog( DEBUG3, "ogawayamaReScanForeignScan() started." );
	elog( DEBUG3, "ogawayamaReScanForeignScan() done." );
}

/*
 *	@brief	Clean up for scanning foreign tables.
 *	@param	[in] Foreign scan information.
 */
static void 
ogawayamaEndForeignScan( ForeignScanState* node )
{
	elog( DEBUG3, "ogawayamaEndForeignScan() started." );

	resultset_ = NULL;
	free_fdwstate( (OgawayamaFdwState*) node->fdw_state );
		
	elog( DEBUG3, "ogawayamaEndForeignScan() done." );
}

/*
 * 	@brief	Preparation for modifying foreign tables.
 *	@param	[in] Foreign scan information.
 *	@param	[in] Some flags. (e.g. EXEC_FLAG_EXPLAIN_ONLY)
 */
static void 
ogawayamaBeginDirectModify( ForeignScanState* node, int eflags )
{
	elog( DEBUG3, "ogawayamaBeginDirectModify() started." );

	EState* estate = node->ss.ps.state;

	OgawayamaFdwState* fdw_state = create_fdwstate();

	/* コネクション接続確認 */
	if ( !fdw_info_.connected ) 
	{
		fdw_info_.connected = get_connection( fdw_info_.pid );
		if ( !fdw_info_.connected ) 
		{
			elog( ERROR, "Connecting to Ogawayama failed." );
		}
	}

	begin_backend_xact();

 	fdw_state->query_string = estate->es_sourceText;
	 
	 /*fdw_stateをnode->fdw_stateに格納する*/
	 node->fdw_state = fdw_state;

 	elog( DEBUG3, "ogawayamaBeginDirectModify() done." );
}

/*
 *	@biref	Execute Insert/Upate/Delete command to foreign tables.
 *	@param	[in] Foreign scan information.
 *	@return	only NULL.
 */
static TupleTableSlot* 
ogawayamaIterateDirectModify( ForeignScanState* node )
{
	elog( DEBUG3, "ogawayamaIterateDirectModify() started." );

	OgawayamaFdwState* fdw_state = (OgawayamaFdwState*) node->fdw_state;
	TupleTableSlot* slot = NULL;
	ErrorCode error;

	elog( DEBUG3, "query string: \"%s\"", fdw_state->query_string );
    std::string_view query( fdw_state->query_string );
	query.remove_suffix(1);
	error = transaction_->execute_statement( query );
	if ( error != ErrorCode::OK ) 
    {
		elog( ERROR, "Connection::execute_statement() failed. (%d)", (int) error );	
	}

	elog( DEBUG3, "ogawayamaIterateDirectModify() done." );

	return slot;	
}

/*
 * 	@note	Not in use.
 */
static TupleTableSlot*
ogawayamaExecForeignInsert( 
	EState *estate, 
	ResultRelInfo *rinfo, 
	TupleTableSlot *slot, 
	TupleTableSlot *planSlot )
{
	elog( DEBUG3, "ogawayamaExecForeignInsert() started." );
	slot = NULL;
	elog( DEBUG3, "ogawayamaExecForeignInsert() started." );

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
	TupleTableSlot *planSlot )
{
	elog( DEBUG3, "ogawayamaExecForeignUpdate() started." );
	slot = NULL;
	elog( DEBUG3, "ogawayamaExecForeignUpdate() started." );

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
	TupleTableSlot *planSlot )
{
	elog( DEBUG3, "ogawayamaExecForeignDelete() started." );
	slot = NULL;
	elog( DEBUG3, "ogawayamaExecForeignDelete() started." );

	return slot;
}

/*
 * 	@biref	Clean up for modifying foreign tables.
 *	@param	[in] foreign scan information.
 */
static void 
ogawayamaEndDirectModify( ForeignScanState* node )
{
	elog( DEBUG3, "ogawayamaEndDirectModify() started." );

	free_fdwstate( (OgawayamaFdwState*) node->fdw_state );

	elog( DEBUG3, "ogawayamaEndDirectModify() done." );
}

/*
 * Functions to be implemented in the future are below.  
 * 
 */

/*
 *	@note	Not in use.
 */
static void 
ogawayamaExplainForeignScan( ForeignScanState* node,
						   	ExplainState* es )
{
	elog( DEBUG3, "ogawayamaExplainForeignScan() started." );
	elog( DEBUG3, "ogawayamaExplainForeignScan() started." );
}

/*
 *	@note	Not in use.
 */
static void 
ogawayamaExplainDirectModify( ForeignScanState* node,
							ExplainState* es )
{
	elog( DEBUG3, "ogawayamaExplainDirectModify() started." );
	elog( DEBUG3, "ogawayamaExplainDirectModify() started." );
}

/*
 *	@note	Not in use.
 */
static bool ogawayamaAnalyzeForeignTable( Relation relation,
							AcquireSampleRowsFunc* func,
							BlockNumber* totalpages )
{
	elog( DEBUG3, "ogawayamaAnalyzeForeignTable() started." );
	elog( DEBUG3, "ogawayamaAnalyzeForeignTable() started." );

	return true;
}

/*
 *	@note	Not in use.
 */
static List* 
ogawayamaImportForeignSchema( ImportForeignSchemaStmt* stmt,
							Oid serverOid )
{
	elog( DEBUG3, "ogawayamaImportForeignSchema() started." );
	List	*commands = NIL;
	elog( DEBUG3, "ogawayamaImportForeignSchema() started." );

	return commands;
}

/*
 *	@brief	initialize global variables.
 * 	@param	[in] Argument of fdw handler function.
 */
static void
init_fdw_info( FunctionCallInfo fcinfo )
{
	fdw_info_.connected = false;
	fdw_info_.xact_level = 0;
	fdw_info_.pid = pg_backend_pid( fcinfo );
	elog( DEBUG1, "PostgreSQL worker process ID: (%d)", fdw_info_.pid );
}

/*
 *	@brief	Create OgawayamaFdwState structure.
 */
static OgawayamaFdwState* 
create_fdwstate()
{
	OgawayamaFdwState* fdw_state = 
		(OgawayamaFdwState*) palloc0( sizeof( OgawayamaFdwState ) );
	
	fdw_state->cursor_exists = false;
	fdw_state->num_columns = 0;
	fdw_state->pgtype = NULL;

	return fdw_state;
}

/*
 *	@brief	free allocated memories.
 *	@param	[in] Ogawayama fdw state.
 */
static void 
free_fdwstate( OgawayamaFdwState* fdw_state )
{
	if ( fdw_state->pgtype != NULL ) 
	{
		pfree( fdw_state->pgtype );
		fdw_state->pgtype = NULL;
	}

 	pfree( fdw_state );
}

/*
 *	@brief	initialize stub and connect to stub.
 *	@param	[in] Proecess ID of PostgreSQL worker.
 *	@return	true if success.
 */
static bool 
get_connection( int pid )
{
	bool ret = false;

	/* COMMIT, ROLLBACK時の動作を登録 */
	RegisterXactCallback( ogawayama_xact_callback, NULL );

	try {
		// connect to ogawayama-stub
		std::string name = "ogawayama_" + std::to_string( pid );	// 暫定処置
		elog( DEBUG1, "stub name: (%s)", name.c_str() );
		stub_ = make_stub( name );
		ErrorCode error = stub_->get_connection( pid , connection_ );
		if ( error != ErrorCode::OK )
		{
			elog( ERROR, "Stub::get_connection() failed. (%d)", (int) error );
			goto Error;
		}
	}
	catch (...) {
		elog( ERROR, "Unexpected exception caught." );
		goto Error;
	}

	ret = true;

Error:
	return ret; 
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
store_pg_data_type( OgawayamaFdwState* fdw_state, List* tlist )
{
	ListCell* lc;

	Oid* data_types = (Oid*) palloc( sizeof( Oid ) * tlist->length );

	int i = 0;
	foreach( lc, tlist )
	{
		TargetEntry* entry = (TargetEntry*) lfirst( lc );
		Node* node = (Node*) entry->expr;

		if ( nodeTag( node ) == T_Var )
		{
			Var* var = (Var*) node;
			data_types[i] = var->vartype;
		}
		else
		{
			elog( ERROR, "Unexpected data type in target list. (index: %d, type:%u)",
				i, (unsigned int) nodeTag( node ) );
		}
		i++;
	}

	fdw_state->pgtype = data_types;
}

/*
 * 	@brief	Confirm column information between PostgreSQL and Ogawayama.
 * 	@param	[in] Ogawayama column information.
 * 	@param	[in] PostgreSQL column information.
 * 	@return true if matched column information.
 * 	@note	This function may be eliminated for performance improvement in the future.
 */
static bool
confirm_columns( MetadataPtr metadata, OgawayamaFdwState* fdw_state )
{
	elog( DEBUG3, "confirm_columns() started." );

	bool ret = true;

	if ( metadata->get_types().size() != fdw_state->num_columns )
	{
		elog( ERROR, "Number of columns do NOT match. (og: %d), (pg: %lu)",
			(int) metadata->get_types().size(), fdw_state->num_columns );
	}

	size_t i = 0;
	for ( auto types: metadata->get_types() )
	{
		switch ( static_cast<Metadata::ColumnType::Type>( types.get_type() ) )
		{
			case Metadata::ColumnType::Type::INT16:
				if ( fdw_state->pgtype[i] != INT2OID )
				{
					elog( ERROR, 
						"Don't match data type of the column. " 
						"(column: %lu) (og: %d) (pg: %u)", 
						i, (int) types.get_type(), fdw_state->pgtype[i]  );
					ret = false;
				}
				break;

			case Metadata::ColumnType::Type::INT32:
				if ( fdw_state->pgtype[i] != INT4OID )
				{
					elog( ERROR, 
						"Don't match data type of the column. " 
						"(column: %lu) (og: %d) (pg: %u)", 
						i, (int) types.get_type(), fdw_state->pgtype[i]  );
					ret = false;
				}
				break;

			case Metadata::ColumnType::Type::FLOAT32:
				if ( fdw_state->pgtype[i] != FLOAT4OID )
				{
					elog( ERROR, 
						"Don't match data type of the column. " 
						"(column: %lu) (og: %d) (pg: %u)", 
						i, (int) types.get_type(), fdw_state->pgtype[i]  );
					ret = false;
				}
				break;

			case Metadata::ColumnType::Type::FLOAT64:
				if ( fdw_state->pgtype[i] != FLOAT8OID )
				{
					elog( ERROR, 
						"Don't match data type of the column. " 
						"(column: %lu) (og: %d) (pg: %u)", 
						i, (int) types.get_type(), fdw_state->pgtype[i]  );
				}
				break;

			case Metadata::ColumnType::Type::TEXT:
				if ( fdw_state->pgtype[i] != BPCHAROID &&
					fdw_state->pgtype[i] != VARCHAROID &&
					fdw_state->pgtype[i] != TEXTOID )
				{
					elog( ERROR, 
						"Don't match data type of the column. " 
						"(column: %lu) (og: %d) (pg: %u)", 
						i, (int) types.get_type(), fdw_state->pgtype[i]  );
					ret = false;
				}
				break;

			case Metadata::ColumnType::Type::NULL_VALUE:
				elog( DEBUG3, "NULL_VALUE found. (column: %lu)", i );
				ret = false;
				break;

			default:
				elog( ERROR, "Unexpected data type of the column. " 
					"(column: %lu, Og type: %u)", i, (int) types.get_type() );
				ret = false;
				break;
		}
		i++;
	}

	elog( DEBUG3, "confirm_columns() done." );

	return ret;
}

/*
 *	@brief	Convert tuple data from Ogawayama to PostgreSQL.
 *	@param	[in] Ogawayama fdw information.
 *	@param	[in] Ogawayama tuple data.
 *	@param	[out] Store PostgreSQL tuple data.
 *	@param	[out] true if PostgreSQL tuple is NULL.
 */
static void 
convert_tuple( 
	OgawayamaFdwState* fdw_state, ResultSetPtr resultset, Datum* values, bool* nulls )
{
	elog( DEBUG3, "convert_tuple() started." );

	for ( size_t i = 0; i < fdw_state->num_columns; i++ )
	{
		values[i] = PointerGetDatum( NULL );
		nulls[i] = true;

		switch ( fdw_state->pgtype[i] )
		{
			case INT2OID:
				try {							
					std::int16_t value;
					if ( resultset->next_column( value ) == ErrorCode::OK )
					{
						values[i] = Int16GetDatum( value );
						nulls[i] = false;
					}
				}
				catch (...) {
					elog( ERROR, "Unexpected exception caught." );
				}
				break;

			case INT4OID:
				try {
					std::int32_t value;
					if ( resultset->next_column( value ) == ErrorCode::OK )
					{
						values[i] = Int32GetDatum( value );
						nulls[i] = false;
					}
				} 
				catch (...) {
					elog( ERROR, "Unexpected exception caught." );
				}
				break;

			case INT8OID:
				try {
					std::int64_t value;
					if ( resultset->next_column( value ) == ErrorCode::OK ) 
					{
						values[i] = Int64GetDatum( value );
						nulls[i] = false;
					}
				} 
				catch (...) {
					elog( ERROR, "Unexpected exception caught." );
				}
				break;

			case FLOAT4OID:
				try {
					float4 value;
					if ( resultset->next_column( value ) == ErrorCode::OK )
					{
						values[i] = Float4GetDatum( value );
						nulls[i] = false;
					}
				}
				catch (...) {
					elog( ERROR, "Unexpected exception caught." );
				}
				break;

			case FLOAT8OID:
				float8 value;
				try {
					if ( resultset->next_column( value ) == ErrorCode::OK )
					{
						values[i] = Float8GetDatum( value );
						nulls[i] = false;
					}
				}
				catch (...) {
					elog( ERROR, "Unexpected exception caught." );
				}
				break;
			
			case BPCHAROID:
			case VARCHAROID:
			case TEXTOID:
				Datum dat;
				try {
					std::string_view value;
					ErrorCode error = resultset->next_column( value );
					if ( error != ErrorCode::OK )
					{
						elog( DEBUG3, "ResultSet::next_column() is NOT OK. (%d)", 
							(int) error );
						break;
					}
					dat = CStringGetDatum( value.data() );				
				}
				catch (...) {
					elog( ERROR, "Unexpected exception caught." );
				}
				{
					HeapTuple tuple = SearchSysCache1( 
						TYPEOID, ObjectIdGetDatum( fdw_state->pgtype[i] ) );
					if ( !HeapTupleIsValid( tuple ) )
					{
						elog( ERROR, "cache lookup failed for type %u", 
							fdw_state->pgtype[i] );
					}
					regproc typinput = ((Form_pg_type) GETSTRUCT( tuple ))->typinput;
					ReleaseSysCache( tuple );
					values[i] = OidFunctionCall1( typinput, dat );
					nulls[i] = false;
				}
				break;
				
			default:
				elog( ERROR, "Invalid data type of column." );
				break;
		}
	}

	elog( DEBUG3, "convert_tuple() done." );
}

/*
 * @biref	Begin transaction.
 * 
 * V0版では、フロントエンド側のトランザクション(ローカルトランザクション)が
 * ネストされている場合はエラーとする。
 */
static void
begin_backend_xact( void )
{
	/* ローカルトランザクションのネストレベルを取得する */
	ErrorCode error;
    int local_xact_level = GetCurrentTransactionNestLevel();
	elog( DEBUG3, "Local transaction level: (%d)", local_xact_level );

	if ( local_xact_level <= 0 )
	{
		elog( WARNING, "local_xact_level (%d)", local_xact_level );
	}
	else if ( local_xact_level == 1 )
	{
		if ( fdw_info_.xact_level == 0 )
		{
			error = connection_->begin( transaction_ );
			if ( error != ErrorCode::OK ) 
			{
				elog( ERROR, "Connection::begin() failed. (%d)", (int) error );
			}
			fdw_info_.xact_level++;
			elog( DEBUG1, "Connection::begin() done. (xact_level: %d)", 
			fdw_info_.xact_level );
		}
	}
	else if ( local_xact_level >= 2 )
	{
		elog( ERROR, "Nested transaction is NOT supported." );
	}
}

/*
 * 	@biref	Callback function for transaction events.
 *	@param	Transaction event.
 */
static void
ogawayama_xact_callback ( XactEvent event, void *arg )
{
	elog( DEBUG3, "ogawayama_xact_callback() started. " );

    int local_xact_level = GetCurrentTransactionNestLevel();
	elog( DEBUG3, "Local transaction level: (%d)", local_xact_level );

	if ( fdw_info_.xact_level > 0 )
	{
		/* 入力されるeventの内容は、xact.hに記載あり */
		switch ( event )
		{
			case XACT_EVENT_PRE_COMMIT:
				elog( DEBUG1, "XACT_EVENT_PRE_COMMIT" );
				break;

			case XACT_EVENT_COMMIT:
				elog( DEBUG1, "XACT_EVENT_COMMIT" );
				transaction_->commit();
				fdw_info_.xact_level--;
				elog( DEBUG1, "Transaction::commit() done. (xact_level: %d)", 
					fdw_info_.xact_level );
				break;

			case XACT_EVENT_ABORT:
				elog( DEBUG1, "XACT_EVENT_ABORT (xact_level: %d)", fdw_info_.xact_level );
				transaction_->rollback();
				fdw_info_.xact_level--;
				elog( DEBUG1, "Transaction::rollback() done. (xact_level: %d)", 
					fdw_info_.xact_level );
				break;

			case XACT_EVENT_PRE_PREPARE:
				elog( DEBUG1, "XACT_EVENT_PRE_PREPARE" );
				break;

			case XACT_EVENT_PREPARE:
				elog( DEBUG1, "XACT_EVENT_PREPARE" );
				break;

			case XACT_EVENT_PARALLEL_COMMIT:
			case XACT_EVENT_PARALLEL_ABORT:
			case XACT_EVENT_PARALLEL_PRE_COMMIT:
				elog( DEBUG1, "Unexpected XACT event occurred. (%d)", event );
				break;

			default:
				elog( WARNING, "Unexpected XACT event occurred. (Unknown event)" );
				break;
		}
	}

	elog( DEBUG3, "ogawayama_xact_callback() done." );
}

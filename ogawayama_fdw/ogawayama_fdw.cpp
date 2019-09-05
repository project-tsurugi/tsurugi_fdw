/*-------------------------------------------------------------------------
 *
 * ogawayama_fdw.c
 *		  Foreign-data wrapper for nedo db
 *
 * IDENTIFICATION
 *		  contrib/frontend/ogawayama_fdw.c
 *
 *-------------------------------------------------------------------------
 */
#ifdef __cplusplus
extern "C" {
#endif

#include "postgres.h"

#include "ogawayama_fdw.h"

#include "commands/explain.h"
#include "foreign/fdwapi.h"
#include "catalog/pg_type.h"
#include "utils/fmgrprotos.h"

PG_MODULE_MAGIC;

#ifdef __cplusplus
}
#endif

#include <string>
#include <memory>
#include "ogawayama/stub/api.h"

typedef struct OgawayamaFdwState
{
	bool isCursorOpen;			/* SQLのカーソルをOPENしているかどうか*/
	bool connected;						
	bool cursor_exists;			
	const char* query_string;	/* SQL Query Text */
	int pid;   					/* ワーカプロセスのPID */
	int num_columns;			/* SELECT対象の列数 */
	Oid* pgtype; 				/* SELECT予定の列のデータ型(Oid)用のポインタ */
	int xact_level;				/* FDWが自認する現在のトランザクションレベル */
} OgawayamaFdwState;

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
static void ogawayamaGetForeignRelSize( 
	PlannerInfo* root, RelOptInfo* baserel, Oid foreigntableid );
static void ogawayamaBeginForeignScan( ForeignScanState* node, int eflags );
static TupleTableSlot* ogawayamaIterateForeignScan( ForeignScanState* node );
static void ogawayamaReScanForeignScan( ForeignScanState* node );
static void ogawayamaEndForeignScan( ForeignScanState* node );

static void ogawayamaBeginDirectModify( ForeignScanState* node, int eflags );
static TupleTableSlot* ogawayamaIterateDirectModify( ForeignScanState* node );
static void ogawayamaEndDirectModify( ForeignScanState* node );

static void ogawayamaExplainForeignScan( ForeignScanState* node, ExplainState* es );
static void ogawayamaExplainDirectModify( ForeignScanState* node, ExplainState* es );
static bool ogawayamaAnalyzeForeignTable( 
	Relation relation, AcquireSampleRowsFunc* func, BlockNumber* totalpages );
static List* ogawayamaImportForeignSchema( ImportForeignSchemaStmt* stmt, Oid serverOid );

#ifdef __cplusplus
}
#endif

/*
 * Helper functions
 */
OgawayamaFdwState* createOgawayamaFdwState();
static void store_pg_data_type( OgawayamaFdwState* fdw_state, List* tlist );
static void convert_tuple( OgawayamaFdwState* fdw_state, Datum* values, bool* nulls );

using namespace ogawayama::stub;

static StubPtr stub_;
static ConnectionPtr connection_;
static TransactionPtr transaction_;
static ResultSetPtr resultset_;
static MetadataPtr metadata_;

#ifdef __cplusplus
extern "C" {
#endif

/*
 * Foreign-data wrapper handler function: return a struct with pointers
 * to my callback routines.
 */
Datum
ogawayama_fdw_handler( PG_FUNCTION_ARGS )
{
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

	// connect to ogawayama-stub
	stub_ = make_stub( "ogawayama" );
	stub_->get_connection( 10 /*dummy*/, connection_ );

	PG_RETURN_POINTER( routine );
}

static void ogawayamaGetForeignRelSize( 
	PlannerInfo* root, RelOptInfo* baserel, Oid foreigntableid )
{

}

/*
 *ogawayamaBeginForeignScan
 *
 *
 */
static void 
ogawayamaBeginForeignScan( ForeignScanState* node, int eflags )
{
	ForeignScan* fsplan = (ForeignScan*) node->ss.ps.plan;
	EState*	estate = node->ss.ps.state;

	elog( INFO, "ogawayamaBeginForeignScan() started." );

	OgawayamaFdwState* fdw_state = createOgawayamaFdwState();

	/*SELECT対象の列数を設定*/
	fdw_state->num_columns = fsplan->scan.plan.targetlist->length;

	/*SELECT対象の列のデータ型を格納*/
	store_pg_data_type( fdw_state, fsplan->scan.plan.targetlist );

	/*コミット、ロールバック時のコールバック関数を登録*/

	/*トランザクションの開始(確認)*/
		
	/*
	* estate->es_sourceTextに格納されているSQL文を取り出し、
	* OgawayamaFdwState構造体に格納する
	*/
     fdw_state->query_string = estate->es_sourceText;

	 /*fdw_stateをnode->fdw_stateに格納する*/
	 node->fdw_state = fdw_state;

	elog( INFO, "ogawayamaBeginForeignScan() done." );
}

/*
 * ogawayamaIterateForeignScan
 *		
 *
 */
static TupleTableSlot* 
ogawayamaIterateForeignScan( ForeignScanState* node )
{
	TupleTableSlot* slot = node->ss.ss_ScanTupleSlot;
	OgawayamaFdwState* fdw_state = (OgawayamaFdwState*) node->fdw_state;
	
	elog( INFO, "ogawayamaIterateForeignScan() started." );

	if ( fdw_state->connected )
	{
		if ( resultset_->next() == ErrorCode::OK ) 
		{
			// 1行分fetchする
			ExecClearTuple( slot );
			convert_tuple( fdw_state, slot->tts_values, slot->tts_isnull );
			ExecStoreVirtualTuple( slot );
		}
		else
		{
			/* 次の結果セットはないので、slotをnullにする */
			slot = (TupleTableSlot*) NULL;
		}
	}
	else
	{
		// open cursor
		ErrorCode error = connection_->begin( transaction_ );
		if ( error != ErrorCode::OK ) {
		}

		std::string query( fdw_state->query_string );
		error = transaction_->execute_query( query, resultset_ );
		if ( error != ErrorCode::OK ) {
		}

		fdw_state->cursor_exists = true;
	}

	elog( INFO, "ogawayamaIterateForeignScan() done." );

	return slot;
}

/*
 * ogawayamaReScanForeignScan
 *		
 *
 */
static void 
ogawayamaReScanForeignScan( ForeignScanState* node )
{
	elog( INFO, "ogawayamaReScanForeignScan() started." );
	/*一旦スキップ。*/
	elog( INFO, "ogawayamaReScanForeignScan() done." );
}

/*
 * ogawayamaEndForeignScan
 *		
 *
 */
static void 
ogawayamaEndForeignScan( ForeignScanState* node )
{
	OgawayamaFdwState* fdw_state = (OgawayamaFdwState*) node->fdw_state;

	elog( INFO, "ogawayamaEndForeignScan() started." );

	pfree( fdw_state );

	elog( INFO, "ogawayamaEndForeignScan() done." );
}

/*
 * ogawayamaBeginDirectModify
 *		
 *
 */
static void 
ogawayamaBeginDirectModify( ForeignScanState* node, int eflags )
{
//	ForeignScan* fsplan = (ForeignScan*) node->ss.ps.plan;
	EState* estate = node->ss.ps.state;

	elog( INFO, "ogawayamaBeginDirectModify() started." );

	OgawayamaFdwState* fdw_state = createOgawayamaFdwState();

	/*
	* estate->es_sourceTextに格納されているSQL文を取り出し、
	* OgawayamaFdwState構造体に格納する
	*/

	 fdw_state->query_string = estate->es_sourceText;
	 
	 /*fdw_stateをnode->fdw_stateに格納する*/
	 node->fdw_state = fdw_state;

 	elog( INFO, "ogawayamaBeginDirectModify() done." );
}

/*
 * ogawayamaIterateDirectModify
 *		
 *
 */
static TupleTableSlot* 
ogawayamaIterateDirectModify( ForeignScanState* node )
{
	TupleTableSlot* slot = NULL;
	OgawayamaFdwState* fdw_state = (OgawayamaFdwState*) node->fdw_state;

	elog( INFO, "ogawayamaIterateDirectModify() started." );

	ErrorCode error = connection_->begin( transaction_ );
	if ( error != ErrorCode::OK ) {

	}

	std::string query( fdw_state->query_string );
	error = transaction_->execute_query( query, resultset_ );
	if ( error != ErrorCode::OK ) {
		
	}

	elog( INFO, "ogawayamaIterateDirectModify() done." );

	return slot;	
}

/*
 * ogawayamaEndDirectModify
 *		
 *
 */
static void 
ogawayamaEndDirectModify( ForeignScanState* node )
{
	OgawayamaFdwState* fdw_state = (OgawayamaFdwState*) node->fdw_state;

	elog( INFO, "ogawayamaEndDirectModify() started." );

	pfree( fdw_state );

	elog( INFO, "ogawayamaEndDirectModify() done." );
}

/*
 * Functions to be implemented in the future are below.  
 * 
 */

/*
 * ogawayamaExplainForeignScan
 *		
 *
 */
static void 
ogawayamaExplainForeignScan( ForeignScanState* node,
						   ExplainState* es )
{
						   
}

/*
 * ogawayamaExplainDirectModify
 *		
 *
 */
static void 
ogawayamaExplainDirectModify( ForeignScanState* node,
							ExplainState* es )
{

}

/*
 * ogawayamaAnalyzeForeignTable
 *		
 *
 */
static bool ogawayamaAnalyzeForeignTable( Relation relation,
							AcquireSampleRowsFunc* func,
							BlockNumber* totalpages )
{
	return true;
}

/*
 * ogawayamaImportForeignSchema
 *		
 *
 */
static List* 
ogawayamaImportForeignSchema( ImportForeignSchemaStmt* stmt,
							Oid serverOid )
{
	List	*commands = NIL;

	return commands;
}

#ifdef __cplusplus
}
#endif

/*
 * createOgawayamaFdwState
 * OgawayamaFdwState構造体の初期化を行い、そのポインタを返却する。
 * ★検討中★
 * Stubの各種オブジェクトを参照するための何らかの処理を行う。
 * 
 * 
 * ■input
 *   今のところはなし
 *
 * ■output
 *   OgawayamaFdwStateへのポインタ
 *
 */
OgawayamaFdwState* 
createOgawayamaFdwState()
{
	OgawayamaFdwState* fdw_state;
	
	fdw_state = (OgawayamaFdwState*) palloc0( sizeof( OgawayamaFdwState ) );
	
	fdw_state->isCursorOpen = false;
	fdw_state->cursor_exists = false;
//	fdw_state->pid = pg_backend_pid();
	fdw_state->num_columns = 0;
	fdw_state->pgtype = NULL;
	fdw_state->xact_level = 0;

	return fdw_state;
}

/*
 * store_pg_data_type
 * SELECT対象の列のデータ型を確認し、fdw_state->pgtypeに格納していく。
 * fdw_state->NumColsに値を格納した後に呼び出す。
 * 
 * ★コメント★ 
 * oracle_fdwのconvertTupleに影響を受け、PostgreSQLでのデータ型も把握した方が良いと
 * 判断したため用意した関数。
 * 本当は同様の処理はalt_plannerで実施してもいいのかもしれない。
 * 
 * ■input
 *  OgawayamaFdwState* fdw_state ... 設定するpgtypeがあるfdw_state
 *  List* tlist ... ForeignScanのtargetlist。
 *                  alt_plannerを通った結果、TargetEntry->Exprは全てVarとなっている
 *                  前提。
 */
static void 
store_pg_data_type( OgawayamaFdwState* fdw_state, List* tlist )
{
	ListCell* lc;
	TargetEntry* te;
	Var* var;
	Oid* dataType;
	Node* node;
	int count;

	dataType = (Oid*) palloc( fdw_state->num_columns* sizeof( Oid ) );

	count = 0;
	foreach( lc, tlist )
	{
		te = (TargetEntry*) lfirst( lc );
		node = (Node*) te->expr;

		if ( nodeTag( node ) == T_Var )
		{
			var = (Var*) node;
			dataType[count] = var->vartype;
		}
		else
		{
			/*Var以外であるパターンは考えていないのでエラーにします*/
			elog( NOTICE, "Error : stpre_pg_data_type : Var以外" );
		}
		count ++;
	}

	fdw_state->pgtype = dataType;
}

/*
 * convert_tuple
 * 仮想タプルとして格納する前段階として、slot->tts_valuesとslot->tts_nullsを
 * 手動で編集する。
 * 処理内容については、oracle_fdwのconvaertTuple関数を参考にする。
 *
 * ■input
 *  OgawayamaFdwState* fdw_state ... 中のNumColsとpgtypeを使用する
 *  Datum* values ... slot->valuesのポインタ
 *  bool* nulls ... slot->nullsのポインタ
 */
static void 
convert_tuple( OgawayamaFdwState* fdw_state, Datum* values, bool* nulls )
{
	int i = 0;
	for ( auto t: metadata_->get_types() )
	{
		switch ( t.get_type() )
		{
			case Metadata::ColumnType::ColumnType::Type::NULL_VALUE:
				nulls[i] = true;
				values[i] = PointerGetDatum( NULL );
				break;

			case Metadata::ColumnType::Type::INT16:
				/*PostgreSQLでのsmallint*/
				if ( fdw_state->pgtype[i] != INT2OID )
				{
					elog ( NOTICE, "データ型不一致" );
					break;
				}
				else
				{							
					std::int16_t int16_value;
					resultset_->next_column( int16_value );
					values[i] = Int16GetDatum( int16_value );
					nulls[i] = false;
				}
				break;

			case Metadata::ColumnType::Type::INT32:
				/*PostgreSQLでのinteger*/
				if ( fdw_state->pgtype[i] != INT4OID )
				{
					elog (NOTICE, "データ型不一致");
				}
				else
				{			
					std::int32_t int32_value;
					resultset_->next_column( int32_value );
					values[i] = Int32GetDatum( int32_value );
					nulls[i] = false;
				}
				break;

			case Metadata::ColumnType::Type::INT64:
				/*PostgreSQLでのbigint*/
				if ( fdw_state->pgtype[i] != INT8OID )
				{
					elog( NOTICE, "データ型不一致" );
				}
				else
				{			
					std::int64_t int64_value;
					resultset_->next_column( int64_value );
					values[i] = Int64GetDatum( int64_value );
					nulls[i] = false;
				}
				break;

			case Metadata::ColumnType::Type::FLOAT32:
				/*PostgreSQLでのreal*/
				if ( fdw_state->pgtype[i] != FLOAT4OID )
				{
					elog( NOTICE, "データ型不一致" );
				}
				else
				{		
					float4 float4_value;
					resultset_->next_column( float4_value );
					values[i] = Float4GetDatum( float4_value );
					nulls[i] = false;
				}
				break;

			case Metadata::ColumnType::Type::FLOAT64:
				/*PostgreSQLでのdouble precision*/
				if ( fdw_state->pgtype[i] != FLOAT8OID )
				{
					elog ( NOTICE, "データ型不一致" );
					break;
				}
				else
				{			
					float8 float8_value;
					resultset_->next_column( float8_value );
					values[i] = Float8GetDatum( float8_value );
					nulls[i] = false;
				}
				break;
			
			case Metadata::ColumnType::Type::TEXT:
				/*PostgreSQLでのcharacter, character varying, text*/
				if ( fdw_state->pgtype[i] != BPCHAROID &&
					fdw_state->pgtype[i] != VARCHAROID &&
					fdw_state->pgtype[i] != TEXTOID )
				{
						elog( NOTICE, "データ型不一致" );
				}
				else
				{
					std::string_view value;
					resultset_->next_column( value );
					values[i] = CStringGetDatum( value.data() );
					nulls[i] = false;
				}
				break;
				
			default:
				/*サポート対象外の型の場合*/
				elog( NOTICE, "サポート対象外の型が返されました。" );
				break;
		}
		i++;
	}
}


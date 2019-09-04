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

/*
 * SQL functions
 */
PG_FUNCTION_INFO_V1( ogawayama_fdw_handler );

#include <cstddef>

#ifdef __cplusplus
}
#endif

#include <memory.h>
#include <cassert>
#include <string>
#include <memory>
#include "ogawayama/stub/error_code.h"
#include "ogawayama/stub/metadata.h"
#include "ogawayama/stub/api.h"

//#ifdef __cplusplus
//extern "C" {
//#endif

typedef struct OgFdwScanState
{
	bool isCursorOpen;			/*SQLのカーソルをOPENしているかどうか*/
	bool connected_stub;						
	bool cursor_exists;			
	const char *query_string;	/*SQL Query Text*/
	int pid;   					/*ワーカプロセスのPID*/
	int num_columns;			/*SELECT対象の列数*/
	Oid *pgtype; 				/*SELECT予定の列のデータ型(Oid)用のポインタ*/
	int xact_level;				/*FDWが自認する現在のトランザクションレベル*/
	int myconnection;			/*コネクション情報*/
} OgFdwScanState;

/*
 * FDW callback routines
 */
static void ogawayamaGetForeignRelSize( 
	PlannerInfo *root, RelOptInfo *baserel, Oid foreigntableid );
static void ogawayamaBeginForeignScan( ForeignScanState *node, int eflags );
static TupleTableSlot *ogawayamaIterateForeignScan( ForeignScanState *node );
static void ogawayamaReScanForeignScan( ForeignScanState *node );
static void ogawayamaEndForeignScan( ForeignScanState *node );

static void ogawayamaBeginDirectModify( ForeignScanState *node, int eflags );
static TupleTableSlot *ogawayamaIterateDirectModify( ForeignScanState *node );
static void ogawayamaEndDirectModify( ForeignScanState *node );

static void ogawayamaExplainForeignScan( ForeignScanState *node, ExplainState *es );
static void ogawayamaExplainDirectModify( ForeignScanState *node, ExplainState *es );
static bool ogawayamaAnalyzeForeignTable( 
	Relation relation, AcquireSampleRowsFunc *func, BlockNumber *totalpages );
static List *ogawayamaImportForeignSchema( ImportForeignSchemaStmt *stmt, Oid serverOid );

/*
 * Foreign-data wrapper handler function: return a struct with pointers
 * to my callback routines.
 */
Datum
ogawayama_fdw_handler( PG_FUNCTION_ARGS )
{
	FdwRoutine *routine = makeNode( FdwRoutine );

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

	PG_RETURN_POINTER( routine );
}

/*
 * Helper function
 *
 */
OgFdwScanState *createOgFdwScanState();
//char *init_query( char *sourceText );
static void store_pg_data_type( OgFdwScanState *osstate, List *tlist );
static void convert_tuple( OgFdwScanState *osstate, Datum *values, bool *nulls );
static bool is_get_connection ( OgFdwScanState *osstate );

using namespace ogawayama::stub;

static StubPtr stub_;
static ConnectionPtr connection_;
static TransactionPtr transaction_;
static ResultSetPtr resultset_;
static MetadataPtr metadata_;

/*
 * ogawayamaBeginForeignScan
 *
 *
 */
static void 
ogawayamaBeginForeignScan( ForeignScanState *node, int eflags )
{
	ForeignScan *fsplan = (ForeignScan*) node->ss.ps.plan;
	EState*	estate = node->ss.ps.state;
	OgFdwScanState *osstate = createOgFdwScanState();

	stub_ = make_stub( "ogawayama" );
	stub_->get_connection( 10 /*dummy*/, connection_ );
	transaction_ = NULL;
	resultset_ = NULL;
	metadata_ = NULL;

	/*SELECT対象の列数を設定*/
	osstate->num_columns = fsplan->scan.plan.targetlist->length;

	/*SELECT対象の列のデータ型を格納*/
	store_pg_data_type( osstate, fsplan->scan.plan.targetlist );

	/*コミット、ロールバック時のコールバック関数を登録*/

	/*トランザクションの開始(確認)*/
		
	/*
	* estate->es_sourceTextに格納されているSQL文を取り出し、
	* OgawayamaScanState構造体に格納する
	*/
     osstate->query_string = estate->es_sourceText;

	 /*osstateをnode->fdw_stateに格納する*/
	 node->fdw_state = osstate;
}

/*
 * ogawayamaIterateForeignScan
 *		
 *
 */
static TupleTableSlot *
ogawayamaIterateForeignScan( ForeignScanState *node )
{
	TupleTableSlot *slot;
	OgFdwScanState *osstate;
	ErrorCode error = ErrorCode::OK;
	
	osstate = (OgFdwScanState*) node->fdw_state;
	
	slot = node->ss.ss_ScanTupleSlot;
	
	if ( osstate->connected_stub )
	{
		if ( resultset_->next() == ErrorCode::OK ) 
		{
			ExecClearTuple( slot );

			/*結果セットをTupleTableSlotに合うように整形しつつフェッチ*/
			convert_tuple( osstate, slot->tts_values, slot->tts_isnull );
		
			ExecStoreVirtualTuple( slot );
		}
		else
		{
			/*次の結果セットはないので、slotをnullにする*/
			slot = (TupleTableSlot *) NULL;
		}
	}
	else
	{
		// open cursor
		error = connection_->begin( transaction_ );

		std::string query( osstate->query_string );
		error = transaction_->execute_query( query, resultset_ );

		osstate->cursor_exists = true;
	}

	return slot;
}

/*
 * ogawayamaReScanForeignScan
 *		
 *
 */
static void 
ogawayamaReScanForeignScan( ForeignScanState *node )
{
	/*一旦スキップ。*/
}

/*
 * ogawayamaEndForeignScan
 *		
 *
 */
static void 
ogawayamaEndForeignScan( ForeignScanState *node )
{
	OgFdwScanState *osstate = (OgFdwScanState*) node->fdw_state;

	pfree( osstate );
}

/*
 * ogawayamaBeginDirectModify
 *		
 *
 */
static void 
ogawayamaBeginDirectModify( ForeignScanState *node, int eflags )
{
	ForeignScan *fsplan;
	EState *estate;
	OgFdwScanState *osstate;

	osstate = createOgFdwScanState();

	/*
	* estate->es_sourceTextに格納されているSQL文を取り出し、
	* OgawayamaScanState構造体に格納する
	*/

	 osstate->query_string = estate->es_sourceText;
	 
	 /*osstateをnode->fdw_stateに格納する*/
	 node->fdw_state = osstate;
}

/*
 * ogawayamaIterateDirectModify
 *		
 *
 */
static TupleTableSlot *
ogawayamaIterateDirectModify( ForeignScanState *node )
{
	TupleTableSlot *slot = NULL;
	OgFdwScanState *osstate = (OgFdwScanState*) node->fdw_state;
	ErrorCode error = ErrorCode::OK;

	error = connection_->begin( transaction_ );

	std::string query( osstate->query_string );
	error = transaction_->execute_query( query, resultset_ );

	return slot;	
}

/*
 * ogawayamaEndDirectModify
 *		
 *
 */
static void 
ogawayamaEndDirectModify( ForeignScanState *node )
{
	OgFdwScanState *osstate = (OgFdwScanState*) node->fdw_state;

	pfree( osstate );
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
ogawayamaExplainForeignScan( ForeignScanState *node,
						   ExplainState *es )
{
						   
}

/*
 * ogawayamaExplainDirectModify
 *		
 *
 */
static void 
ogawayamaExplainDirectModify( ForeignScanState *node,
							ExplainState *es )
{

}

/*
 * ogawayamaAnalyzeForeignTable
 *		
 *
 */
static bool ogawayamaAnalyzeForeignTable( Relation relation,
							AcquireSampleRowsFunc *func,
							BlockNumber *totalpages )
{
	return true;
}

/*
 * ogawayamaImportForeignSchema
 *		
 *
 */
static List *
ogawayamaImportForeignSchema( ImportForeignSchemaStmt *stmt,
							Oid serverOid )
{
	List	*commands = NIL;

	return commands;
}



/*
 * createOgFdwScanState
 * OgawayamaScanState構造体の初期化を行い、そのポインタを返却する。
 * ★検討中★
 * Stubの各種オブジェクトを参照するための何らかの処理を行う。
 * 
 * 
 * ■input
 *   今のところはなし
 *
 * ■output
 *   OgawayamaScanStateへのポインタ
 *
 */
OgFdwScanState *
createOgFdwScanState()
{
	OgFdwScanState *osstate;
	
	osstate = (OgFdwScanState*) palloc0( sizeof( OgFdwScanState ) );
	
	osstate->isCursorOpen = false;
	osstate->cursor_exists = false;
//	osstate->pid = pg_backend_pid();
	osstate->num_columns = 0;
	osstate->pgtype = NULL;
	osstate->xact_level = 0;

	/*9/2現在は、一旦ここで初期化(-1とする)しておく*/
	osstate->myconnection = -1;

	return osstate;
}


/*
 * init_query
 * 入力されたSQL文を取り出し、終了文字を添付したうえで呼び出し元にポインタを返却する
 * 
 * ■input
 *  char *sourceText
 *       EState->es_sourceTextのポインタ
 * ■output
 *  cahr *
 *  終了文字を添付したSQL文の先頭ポインタ 
 */
char *init_query(char *sourceText)
{
    int len;
    char *p;
    char *res;

	len=1;
	for ( p = sourceText ; *p != ';' ; p++ )
	{
		len++;
	}
	
	res = ( char* )malloc( len );
	memcpy( res, sourceText, len-1 );
	res[ len-1 ] = '\0';

    return res;
}

/*
 * store_pg_data_type
 * SELECT対象の列のデータ型を確認し、osstate->pgtypeに格納していく。
 * osstate->NumColsに値を格納した後に呼び出す。
 * 
 * ★コメント★ 
 * oracle_fdwのconvertTupleに影響を受け、PostgreSQLでのデータ型も把握した方が良いと
 * 判断したため用意した関数。
 * 本当は同様の処理はalt_plannerで実施してもいいのかもしれない。
 * 
 * ■input
 *  OgFdwScanState *osstate ... 設定するpgtypeがあるosstate
 *  List *tlist ... ForeignScanのtargetlist。
 *                  alt_plannerを通った結果、TargetEntry->Exprは全てVarとなっている
 *                  前提。
 */
static void 
store_pg_data_type( OgFdwScanState *osstate, List *tlist )
{
	ListCell *lc;
	TargetEntry *te;
	Var *var;
	Oid *dataType;
	Node *node;
	int count;

	dataType = (Oid*) palloc( osstate->num_columns* sizeof( Oid ) );

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

	osstate->pgtype = dataType;
}

/*
 * convert_tuple
 * 仮想タプルとして格納する前段階として、slot->tts_valuesとslot->tts_nullsを
 * 手動で編集する。
 * 処理内容については、oracle_fdwのconvaertTuple関数を参考にする。
 *
 * ■input
 *  OgFdwScanState *osstate ... 中のNumColsとpgtypeを使用する
 *  Datum *values ... slot->valuesのポインタ
 *  bool *nulls ... slot->nullsのポインタ
 */
static void 
convert_tuple( OgFdwScanState *osstate, Datum *values, bool *nulls )
{
	int i, dummy;
	int otype; /*Stub側のデータ型を格納する*/

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
					if ( osstate->pgtype[i] != INT2OID )
					{
						elog ( NOTICE, "データ型不一致" );

						break;
					}
					else
					{
						std::int16 value;
						resultset_->next_column( value );
						values[i] = Int16GetDatum( value );
						nulls[i] = false;

						break;
					}

				case Metadata::ColumnType::Type::INT32:
					/*PostgreSQLでのinteger*/
					if ( osstate->pgtype[i] != INT4OID )
					{
						elog (NOTICE, "データ型不一致");
					}
					else
					{
						std::int32 value;

						dummy = resultset_->next_column( value );
						values[i] = Int32GetDatum( value );
						nulls[i] = false;
					}
					break;

				case Metadata::ColumnType::Type::INT64:
					/*PostgreSQLでのbigint*/
					if ( osstate->pgtype[i] != INT8OID )
					{
						elog( NOTICE, "データ型不一致" );
					}
					else
					{
						std::int64 value;

						dummy = resultset_->next_column( value );
						values[i] = Int64GetDatum( value );
						nulls[i] = false;					
					}
					break;

				case Metadata::ColumnType::Type::FLOAT32:
					/*PostgreSQLでのreal*/
					if ( osstate->pgtype[i] != FLOAT4OID )
					{
						elog( NOTICE, "データ型不一致" );
					}
					else
					{
						float4 value;

						dummy = resultset_->next_column( value );
						values[i] = Float4GetDatum( value );
						nulls[i] = false;
					}
					break;

				case Metadata::ColumnType::Type::FLOAT64:
					/*PostgreSQLでのdouble precision*/
					if ( osstate->pgtype[i] != FLOAT8OID )
					{
						elog ( NOTICE, "データ型不一致" );
					}
					else
					{
						float8 value;

						dummy = resultset_->next_column( value );
						values[i] = Float8GetDatum( value );
						nulls[i] = false;
					}
					break;

				case Metadata::ColumnType::Type::TEXT:
					/*PostgreSQLでのcharacter, character varying, text*/
					if ( osstate->pgtype[i] != BPCHAROID &&
					     osstate->pgtype[i] != VARCHAROID &&
						 osstate->pgtype[i] != TEXTOID )
					{
						 elog( NOTICE, "データ型不一致" );

						 break;
					}
					else
					{
						char *char_val;
						size_t char_len;

						dummy = resultset_->get_length( i + 1, &char_len );
						char_val = (char*) palloc0( char_len );
						dummy = resultset_->get_text( i + 1, char_val, char_len );
						nulls[i] = false;
						values[i] = CStringGetDatum( char_val );

						break;
					}
					break;
					
				default:
					/*サポート対象外の型の場合*/
					elog( NOTICE, "サポート対象外の型が返されました。" );
					break;
			}
			
		}

	
}

/*
 * is_get_connection
 * dispacher.hのget_connection関数を呼び出すための関数。
 * 近い将来は、ワーキングプロセスが存続している間はコネクションを保てるようにする
 * 機能を入れたい。
 * 
 * ■input
 *   OgFdwScanState *osstate ... 事前に取得済みのMyPidを使用。
 * 
 * ■output
 *   bool ... コネクションが存在するか、コネクションを取得できたらtrueを返却する。
 */
static bool
is_get_connection( OgFdwScanState *osstate )
{
	/*現在接続があるかどうかを確認する*/
	if ( osstate->myconnection == 0 )
	{
		return true;
	}
	else
	{
		/*接続が無い場合は接続を試行する*/
//		osstate->myconnection = get_connection( osstate->MyPid );
		
		if ( osstate->myconnection == 0 )
		{
			return true;
		}
		else
		{
			return false;
		}
	}
}

//#ifdef __cplusplus
//}
//#endif

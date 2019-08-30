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
#include "postgres.h"

#include "ogawayama_fdw.h"
#include <stdbool.h>

#include "dispatcher.h"
#include "commands/explain.h"
#include "foreign/fdwapi.h"
#include "catalog/pg_type.h"
#include <stddef.h>

PG_MODULE_MAGIC;

/* 取り扱いデータ型一覧 */
#define NULL_VALUE 0 
#define INT16 1
#define INT32 2
#define INT64 3
#define FLOAT32 4
#define FLOAT64 5
#define TEXT 6

/* 構造体定義 */
typedef struct OgawayamaScanState
{
	/* SQLのカーソルをOPENしているかどうか */
	bool isCursorOpen;

	/* SQL文そのもの */
	char *query;
	
    /* ワーカプロセスのPID */
	int MyPid;

	/* SELECT対象の列数 */
	int NumCols;

	/* SELECT予定の列のデータ型(Oid)用のポインタ */
	Oid *pgtype; 

} OgawayamaScanState;


/*
 * SQL functions
 */
PG_FUNCTION_INFO_V1( ogawayama_fdw_handler );

/*
 * FDW callback routines
 */
static void ogawayamaGetForeignRelSize( PlannerInfo *root, RelOptInfo *baserel, Oid foreigntableid );
static void ogawayamaBeginForeignScan( ForeignScanState *node, int eflags );
static TupleTableSlot *ogawayamaIterateForeignScan( ForeignScanState *node );
static void ogawayamaReScanForeignScan( ForeignScanState *node );
static void ogawayamaEndForeignScan( ForeignScanState *node );

static void ogawayamaBeginDirectModify( ForeignScanState *node, int eflags );
static TupleTableSlot *ogawayamaIterateDirectModify( ForeignScanState *node );
static void ogawayamaEndDirectModify( ForeignScanState *node );

static void ogawayamaExplainForeignScan( ForeignScanState *node,
						   ExplainState *es );
static void ogawayamaExplainDirectModify( ForeignScanState *node,
							ExplainState *es );
static bool ogawayamaAnalyzeForeignTable( Relation relation,
							AcquireSampleRowsFunc *func,
							BlockNumber *totalpages );
static List *ogawayamaImportForeignSchema( ImportForeignSchemaStmt *stmt,
							Oid serverOid );


/*
 * Helper function
 *
 */

OgawayamaScanState *init_osstate();
char *init_query( char *sourceText );
void store_pg_data_type( OgawayamaScanState *osstate, List *tlist );
void convert_tuple( OgawayamaScanState *osstate, Datum *values, bool *nulls );

/*
 * Foreign-data wrapper handler function: return a struct with pointers
 * to my callback routines.
 */
Datum
ogawayama_fdw_handler( PG_FUNCTION_ARGS )
{
	FdwRoutine *routine = makeNode( FdwRoutine );

	routine->GetForeignRelSize = ogawayamaGetForeignRelSize;

	/* Functions for scanning foreign tables */
	routine->BeginForeignScan = ogawayamaBeginForeignScan;
	routine->IterateForeignScan = ogawayamaIterateForeignScan;
	routine->ReScanForeignScan = ogawayamaReScanForeignScan;
	routine->EndForeignScan = ogawayamaEndForeignScan;

	/* Functions for updating foreign tables */
	routine->BeginDirectModify = ogawayamaBeginDirectModify;
	routine->IterateDirectModify = ogawayamaIterateDirectModify;
	routine->EndDirectModify = ogawayamaEndDirectModify;

	/* Support functions for EXPLAIN */
	routine->ExplainForeignScan = ogawayamaExplainForeignScan;
	routine->ExplainDirectModify = ogawayamaExplainDirectModify;

	/* Support functions for ANALYZE */
	routine->AnalyzeForeignTable = ogawayamaAnalyzeForeignTable;

	/* Support functions for IMPORT FOREIGN SCHEMA */
	routine->ImportForeignSchema = ogawayamaImportForeignSchema;

	PG_RETURN_POINTER( routine );
}


/*
 * ogawayamaGetForeignRelSize
 *		
 *
 */

void
ogawayamaGetForeignRelSize( PlannerInfo *root, RelOptInfo *baserel, Oid foreigntableid )
{
	/* dummy */
}
/*
 * ogawayamaBeginForeignScan
 *		
 *
 */
static void 
ogawayamaBeginForeignScan( ForeignScanState *node, int eflags )
{
	/* 変数宣言 */
	ForeignScan			*fsplan;
	EState	   			*estate;
	OgawayamaScanState	*osstate;
	
	/* 変数の初期化処理 */
	fsplan = (ForeignScan *) node->ss.ps.plan;
	estate = node->ss.ps.state;
	
	/* FDW実行中にnode->fdw_stateに入れる構造体を初期化 */
	
	osstate = init_osstate(); /* ★初期化 */
	
	/* SELECT対象の列数を設定 */
	osstate->NumCols = fsplan->scan.plan.targetlist->length;

	/* SELECT対象の列のデータ型を格納 */
	store_pg_data_type(osstate, fsplan->scan.plan.targetlist);

	/* コネクションの確立(確認) */
	
	
	/* コミット、ロールバック時のコールバック関数を登録 */
	
	
	
	/* トランザクションの開始(確認) */
	
	
	/* 
	 * estate->es_sourceTextに格納されているSQL文を取り出し、
	 * OgawayamaScanState構造体に格納する
	 */

     osstate->query = init_query(estate->es_sourceText);

	 /* osstateをnode->fdw_stateに格納する */
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
	OgawayamaScanState *osstate;
	
	osstate = (OgawayamaScanState *)node->fdw_state;
	
	slot = node->ss.ss_ScanTupleSlot;
	
	/* 初回実行ではない場合 */
	if ( osstate->isCursorOpen )
	{

		if ( resultset_next_row() == 0 ) 
		{
			/* 次の結果セットがある場合…？ */
			/* 仮想タプルの初期化 */
			ExecClearTuple(slot);

			/* 結果セットをTupleTableSlotに合うように整形しつつフェッチ */
			convert_tuple( osstate, slot->tts_values, slot->tts_isnull );
		
			/* 仮想タプルを格納 */
			ExecStoreVirtualTuple(slot);
		}
		else
		{
			/* 次の結果セットはないので、slotをnullにする */
			slot = null;
		}
	}
	else
	{
		/* 初回実行なので、カーソルをオープンする */
		if ( dispatch_query( osstate->query ) == 0 )
		{
			osstate->isCursorOpen = true;
		}
		else
		{
			elog ( NOTICE, "dispatch_queryに失敗しました" );
			osstate->isCursorOpen = false;
		}		
	}


	/* 結果セットをタプルに入れる */
	if ( true ) /* ★結果セットが存在するようであれば */
	{

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
	/* 一旦スキップ。 */
}

/*
 * ogawayamaEndForeignScan
 *		
 *
 */
static void 
ogawayamaEndForeignScan( ForeignScanState *node )
{
	/* 変数類の解放 */

}

/*
 * ogawayamaBeginDirectModify
 *		
 *
 */
static void 
ogawayamaBeginDirectModify( ForeignScanState *node, int eflags )
{

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
 * init_osstate
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
OgawayamaScanState 
*init_osstate()
{
	OgawayamaScanState *osstate;
	
	osstate = ( OgawayamaScanState *) palloc0( sizeof( OgawayamaScanState ) );
	
	osstate->isCursorOpen = false;
	osstate->MyPid = pg_backend_pid();
	osstate->NumCols = 0;
	osstate->pgtype = NULL;

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
	
	res = ( char * )malloc( len );
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
 *  OgawayamaScanState *osstate ... 設定するpgtypeがあるosstate
 *  List *tlist ... ForeignScanのtargetlist。
 *                  alt_plannerを通った結果、TargetEntry->Exprは全てVarとなっている
 *                  前提。
 */

void 
store_pg_data_type( OgawayamaScanState *osstate, List *tlist )
{
	ListCell *lc;
	TargetEntry *te;
	Var *var;
	Oid *dataType;
	Node *node;
	int count;

	/* メモリ領域の確保 */
	dataType = (Oid *) palloc( osstate->NumCols * sizeof( Oid ) );

	count = 0;
	foreach( lc, tlist )
	{
		te = (TargetEntry *) lfirst( lc );
		node = (Node *) te->expr;

		if ( nodeTag( node ) == T_Var )
		{
			var = (Var *) node;
			dataType[count] = var->vartype;
		}
		else
		{
			/* Var以外であるパターンは考えていないのでエラーにします */
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
 *  OgawayamaScanState *osstate ... 中のNumColsとpgtypeを使用する
 *  Datum *values ... slot->valuesのポインタ
 *  bool *nulls ... slot->nullsのポインタ
 */
void 
convert_tuple( OgawayamaScanState *osstate, Datum *values, bool *nulls )
{
	/* 変数宣言 */
	int i, dummy;
	int otype; /* Stub側のデータ型を格納する */

	for ( i = 0; i < osstate->NumCols; i++ )
	{
		/* Stub側のデータ型を取得する */
		if ( resultset_get_type( i + 1, &otype) != 0 )
		{
			elog ( NOTICE, "結果セットのデータ型を取得できませんでした。" );
		}
		else
		{
			/* データ型毎に処理を変える(かもしれない) */
			switch ( otype )
			{
				case NULL_VALUE:
					/* NULL値が返ってきた場合 */
					nulls[i] = true;
					values[i] = PointerGetDatum( NULL );
					break;

				case INT16:
					/* PostgreSQLでのsmallint */
					if ( osstate->pgtype[i] != INT2OID )
					{
						elog ( NOTICE, "データ型不一致" );

						break;
					}
					else
					{
						int16 int16_val;

						dummy = resultset_get_int16( i + 1, &int16_val );
						nulls[i] = false;
						values[i] = Int16GetDatum( int16_val );

						break;
					}

				case INT32:
					/* PostgreSQLでのinteger */
					if ( osstate->pgtype[i] != INT4OID )
					{
						elog (NOTICE, "データ型不一致");
						
						break;
					}
					else
					{
						int32 int32_val;

						dummy = resultset_get_int32( i + 1, &int32_val );
						nulls[i] = false;
						values[i] = Int32GetDatum( int32_val );

						break;
					}

				case INT64:
					/* PostgreSQLでのbigint */
					if ( osstate->pgtype[i] != INT8OID )
					{
						elog( NOTICE, "データ型不一致" );

						break;
					}
					else
					{
						int64 int64_val;

						dummy = resultset_get_int64( i + 1, &int64_val );
						nulls[i] = false;
						values[i] = Int64GetDatum( int64_val );
						
						break;
					}
				case FLOAT32:
					/* PostgreSQLでのreal */
					if ( osstate->pgtype[i] != FLOAT4OID )
					{
						elog( NOTICE, "データ型不一致" );

						break;
					}
					else
					{
						float4 float4_val;

						dummy = resultset_get_float32( i + 1, &float4_val );
						nulls[i] = false;
						values[i] = Float4GetDatum( float4_val );

						break;
					}

				case FLOAT64:
					/* PostgreSQLでのdouble precision */
					if ( osstate->pgtype[i] != FLOAT8OID )
					{
						elog ( NOTICE, "データ型不一致" );

						break;
					}
					else
					{
						float8 float8_val;

						dummy = resultset_get_float64( i + 1, &float8_val );
						nulls[i] = false;
						values[i] = Float8GetDatum( float8_val );

						break;
					}
				case TEXT:
					/* PostgreSQLでのcharacter, character varying, text */
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

						dummy = resultset_get_length( i + 1, &char_len );
						char_val = (char *) palloc0( char_len );
						dummy = resultset_get_text( i + 1, char_val, char_len );
						nulls[i] = false;
						values[i] = CStringGetDatum( char_val );

						break;
					}
					
				default:
					/* サポート対象外の型の場合 */
					elog( NOTICE, "サポート対象外の型が返されました。" );
					break;
			}
			
		}

	}
}
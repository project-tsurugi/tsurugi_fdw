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

/* #include "ogawayama_fdw.h" */
#include <stdbool.h>

/* #include "dispatcher.h" */
#include "commands/explain.h"
#include "foreign/fdwapi.h"

PG_MODULE_MAGIC;


/* 構造体定義 */
typedef struct OgawayamaScanState
{
	/* Stubオブジェクト */
	
	
	/* Transactionオブジェクト */


	/* ResultSetオブジェクト */
	
	
	/* ResultSetMetaDataオブジェクト */
	
	
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
	if ( true )
	{
		/* フェッチ */

	}
	else
	{
		/* 初回実行なので、カーソルをオープンする */

	}


	/* 結果セットをタプルに入れる */
	if ( true ) /* ★結果セットが存在するようであれば */
	{
		/* 仮想タプルの初期化 */
		ExecClearTuple(slot);

		/* 結果セットをTupleTableSlotに合うように整形 */
		convert_tuple( osstate, slot->tts_values, slot->tts_isnull );
		
		/* 仮想タプルを格納 */
		ExecStoreVirtualTuple(slot);
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
	/* これから記述します。 */
}
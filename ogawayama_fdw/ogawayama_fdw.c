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
	
	
	/* Connectionオブジェクト */
	
	
	/* Transactionオブジェクト */
	
	
	/* ResultSetオブジェクト */
	
	
	/* ResultSetMetaDataオブジェクト */
	
	
	/* SQL文そのもの */
	char *query;
	
} OgawayamaScanState;


/*
 * SQL functions
 */
PG_FUNCTION_INFO_V1( ogawayama_fdw_handler );

/*
 * FDW callback routines
 */
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


/*
 * Foreign-data wrapper handler function: return a struct with pointers
 * to my callback routines.
 */
Datum
ogawayama_fdw_handler( PG_FUNCTION_ARGS )
{
	FdwRoutine *routine = makeNode( FdwRoutine );

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
	
	int					len;
    char                *p;
	
	
	/* 変数の初期化処理 */
	fsplan = (ForeignScan *) node->ss.ps.plan;
	estate = node->ss.ps.state;
	
	/* FDW実行中にnode->fdw_stateに入れる構造体を初期化 */
	
	osstate = init_osstate(); /* ★初期化 */
	
	/* コネクションの確立(確認) */
	
	
	/* コミット、ロールバック時のコールバック関数を登録 */
	
	
	
	/* トランザクションの開始(確認) */
	
	
	/* 
	 * estate->es_sourceTextに格納されているSQL文を取り出し、
	 * OgawayamaScanState構造体に格納する
	 */
	
	len=1;
	for ( p = estate->es_sourceText ; *p != ';' ; p++ )
	{
		len++;
	}
	
	osstate->query = ( char * )malloc( len );
	memcpy( osstate->query, estate->es_sourceText, len-1 );
	osstate->query[ len-1 ] = '\0';
	

}

/*
 * ogawayamaIterateForeignScan
 *		
 *
 */
static TupleTableSlot *
ogawayamaIterateForeignScan( ForeignScanState *node )
{
	TupleTableSlot *slot = NULL;


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
	
	
	return osstate;
}
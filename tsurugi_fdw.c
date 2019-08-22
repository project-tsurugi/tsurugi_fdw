/*-------------------------------------------------------------------------
 *
 * tsurugi_fdw.c
 *		  Foreign-data wrapper for nedo db
 *
 * IDENTIFICATION
 *		  contrib/frontend/tsurugi_fdw.c
 *
 *-------------------------------------------------------------------------
 */
#include "postgres.h"

#include "tsurugi_fdw.h"
#include <stdbool.h>

#include "dispatcher.h"
#include "commands/explain.h"
#include "foreign/fdwapi.h"

PG_MODULE_MAGIC;

/*
 * SQL functions
 */
PG_FUNCTION_INFO_V1( tsurugi_fdw_handler );

/*
 * FDW callback routines
 */
static void tsurugiBeginForeignScan( ForeignScanState *node, int eflags );
static TupleTableSlot *tsurugiIterateForeignScan( ForeignScanState *node );
static void tsurugiReScanForeignScan( ForeignScanState *node );
static void tsurugiEndForeignScan( ForeignScanState *node );

static void tsurugiBeginDirectModify( ForeignScanState *node, int eflags );
static TupleTableSlot *tsurugiIterateDirectModify( ForeignScanState *node );
static void tsurugiEndDirectModify( ForeignScanState *node );

static void tsurugiExplainForeignScan( ForeignScanState *node,
						   ExplainState *es );
static void tsurugiExplainDirectModify( ForeignScanState *node,
							ExplainState *es );
static bool tsurugiAnalyzeForeignTable( Relation relation,
							AcquireSampleRowsFunc *func,
							BlockNumber *totalpages );
static List *tsurugiImportForeignSchema( ImportForeignSchemaStmt *stmt,
							Oid serverOid );

/*
 * Foreign-data wrapper handler function: return a struct with pointers
 * to my callback routines.
 */
Datum
tsurugi_fdw_handler( PG_FUNCTION_ARGS )
{
	FdwRoutine *routine = makeNode( FdwRoutine );

	/* Functions for scanning foreign tables */
	routine->BeginForeignScan = tsurugiBeginForeignScan;
	routine->IterateForeignScan = tsurugiIterateForeignScan;
	routine->ReScanForeignScan = tsurugiReScanForeignScan;
	routine->EndForeignScan = tsurugiEndForeignScan;

	/* Functions for updating foreign tables */
	routine->BeginDirectModify = tsurugiBeginDirectModify;
	routine->IterateDirectModify = tsurugiIterateDirectModify;
	routine->EndDirectModify = tsurugiEndDirectModify;

	/* Support functions for EXPLAIN */
	routine->ExplainForeignScan = tsurugiExplainForeignScan;
	routine->ExplainDirectModify = tsurugiExplainDirectModify;

	/* Support functions for ANALYZE */
	routine->AnalyzeForeignTable = tsurugiAnalyzeForeignTable;

	/* Support functions for IMPORT FOREIGN SCHEMA */
	routine->ImportForeignSchema = tsurugiImportForeignSchema;

	PG_RETURN_POINTER( routine );
}

/*
 * tsurugiBeginForeignScan
 *		
 *
 */
static void 
tsurugiBeginForeignScan( ForeignScanState *node, int eflags )
{
	
}

/*
 * tsurugiIterateForeignScan
 *		
 *
 */
static TupleTableSlot *
tsurugiIterateForeignScan( ForeignScanState *node )
{
	TupleTableSlot *slot = NULL;

	dispatch_query( "SELECT * FROM table_name;" );

	return slot;
}

/*
 * tsurugiReScanForeignScan
 *		
 *
 */
static void 
tsurugiReScanForeignScan( ForeignScanState *node )
{

}

/*
 * tsurugiEndForeignScan
 *		
 *
 */
static void 
tsurugiEndForeignScan( ForeignScanState *node )
{

}

/*
 * tsurugiBeginDirectModify
 *		
 *
 */
static void 
tsurugiBeginDirectModify( ForeignScanState *node, int eflags )
{

}

/*
 * tsurugiIterateDirectModify
 *		
 *
 */
static TupleTableSlot *
tsurugiIterateDirectModify( ForeignScanState *node )
{
	TupleTableSlot *slot = NULL;

	return slot;	
}

/*
 * tsurugiEndDirectModify
 *		
 *
 */
static void 
tsurugiEndDirectModify( ForeignScanState *node )
{

}

/* 
 * Functions to be implemented in the future are below.  
 * 
 */

/*
 * tsurugiExplainForeignScan
 *		
 *
 */
static void 
tsurugiExplainForeignScan( ForeignScanState *node,
						   ExplainState *es )
{
						   
}

/*
 * tsurugiExplainDirectModify
 *		
 *
 */
static void 
tsurugiExplainDirectModify( ForeignScanState *node,
							ExplainState *es )
{

}

/*
 * tsurugiAnalyzeForeignTable
 *		
 *
 */
static bool tsurugiAnalyzeForeignTable( Relation relation,
							AcquireSampleRowsFunc *func,
							BlockNumber *totalpages )
{
	return true;
}

/*
 * tsurugiImportForeignSchema
 *		
 *
 */
static List *
tsurugiImportForeignSchema( ImportForeignSchemaStmt *stmt,
							Oid serverOid )
{
	List	*commands = NIL;

	return commands;
}

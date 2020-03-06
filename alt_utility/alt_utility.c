/*-------------------------------------------------------------------------
 *
 * alt_utility.c
 *	  Contains functions which control the execution of the POSTGRES utility
 *	  commands.  
 *
 *-------------------------------------------------------------------------
 */
#include "postgres.h"

#include "tcop/utility.h"
#include "catalog/objectaddress.h"
#include "catalog/pg_class_d.h"
#include "access/reloptions.h"
#include "commands/tablecmds.h"

PG_MODULE_MAGIC;

extern PGDLLIMPORT ProcessUtility_hook_type ProcessUtility_hook;

extern void _PG_init(void);
extern bool IsTransactionBlock(void);
extern void check_stack_depth(void);
extern void check_xact_readonly(Node *parsetree);
extern ParseState *make_parsestate(ParseState *parentParseState);
extern int CommandCounterIncrement(void);
extern List *transformCreateStmt(CreateStmt *stmt, const char *queryString);
extern void standard_ProcessUtility(PlannedStmt *pstmt,
					            	const char *queryString,
						            ProcessUtilityContext context,
						            ParamListInfo params,
						            QueryEnvironment *queryEnv,
						            DestReceiver *dest,
						            char *completionTag);

void tsurugi_ProcessUtility(PlannedStmt *pstmt, 
                            const char *query_string, ProcessUtilityContext context, 
                            ParamListInfo params, 
                            QueryEnvironment *queryEnv, 
                            DestReceiver *dest, char *completionTag);

static void tsurugi_ProcessUtilitySlow(ParseState *pstate,
			        	               PlannedStmt *pstmt,
				                       const char *queryString,
				                       ProcessUtilityContext context,
				                       ParamListInfo params,
				                       QueryEnvironment *queryEnv,
				                       DestReceiver *dest,
				                       char *completionTag);

void
_PG_init(void)
{
  ProcessUtility_hook = tsurugi_ProcessUtility;
}

/*
 *
 */
void 
tsurugi_ProcessUtility(PlannedStmt *pstmt, 
                       const char *queryString, ProcessUtilityContext context, 
                       ParamListInfo params, 
                       QueryEnvironment *queryEnv, 
                       DestReceiver *dest, char *completionTag)
{
	Node	   *parsetree = pstmt->utilityStmt;
	bool		isTopLevel = (context == PROCESS_UTILITY_TOPLEVEL);
	bool		isAtomicContext = 
                    (!(context == PROCESS_UTILITY_TOPLEVEL || context == PROCESS_UTILITY_QUERY_NONATOMIC) 
                    || IsTransactionBlock());
	ParseState *pstate;

	/* This can recurse, so check for excessive recursion */
	check_stack_depth();

	check_xact_readonly(parsetree);

	if (completionTag)
		completionTag[0] = '\0';

	pstate = make_parsestate(NULL);
	pstate->p_sourcetext = queryString;

	tsurugi_ProcessUtilitySlow(pstate, pstmt, queryString,
					           context, params, queryEnv,
					           dest, completionTag);

}

static void 
tsurugi_ProcessUtilitySlow(ParseState *pstate,
				           PlannedStmt *pstmt,
				           const char *queryString,
				           ProcessUtilityContext context,
				           ParamListInfo params,
				           QueryEnvironment *queryEnv,
				           DestReceiver *dest,
				           char *completionTag)
{
    Node    *parsetree = pstmt->utilityStmt;
    bool    isTopLevel = (context == PROCESS_UTILITY_TOPLEVEL);
    bool    commandCollected = false;
    ObjectAddress address;
    ObjectAddress secondaryObject = InvalidObjectAddress;

    switch (nodeTag(parsetree))
    {
        case T_CreateStmt:
        {
            List	   *stmts;
            ListCell   *l;

            /* Run parse analysis ... */
            stmts = transformCreateStmt((CreateStmt *) parsetree, queryString);

            /* ... and do it */
            foreach(l, stmts)
            {
                Node    *stmt = (Node *) lfirst(l);

                if (IsA( stmt, CreateStmt))
                {
                    /* Create the table itself */
                    
                }
                else
                {
                    /* e.g. foreign table */
                }
                
                /* Need CCI between commands */
                if (lnext(l) != NULL)
                    CommandCounterIncrement();
            }

            /*
             * The multiple commands generated here are stashed
             * individually, so disable collection below.
             */
            commandCollected = true;
        }

        default:
        {
		    standard_ProcessUtility(pstmt, queryString,
			    					context, params, queryEnv,
				    				dest, completionTag);
        }
        break;
    }
}
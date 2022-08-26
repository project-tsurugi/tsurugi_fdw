#include "create_stmt.h"

#include "postgres.h"
#include "tcop/utility.h"
#include "access/reloptions.h"
#include "access/xact.h"
#include "catalog/objectaddress.h"
#include "catalog/pg_class_d.h"
#include "catalog/toasting.h"
#include "commands/tablecmds.h"
#include "commands/defrem.h"
#include "commands/event_trigger.h"

#include "create_table/create_table_executor.h"
#include "create_index/create_index_executor.h"

static const char *TSURUGI_TABLESPACE_NAME = "tsurugi";
static const char *TSURUGI_TABLE_SUFFIX = "_tsurugi";

void do_create_stmt(PlannedStmt *pstmt,
                    const char *queryString,
                    Node *stmt);

void execute_create_stmt(PlannedStmt *pstmt,
                          const char *queryString,
                          ParamListInfo params,
                          List *stmts)
{
    ListCell  *l;
//    bool		  needCleanup;
//    bool		  commandCollected = false;
    ObjectAddress address;
    ObjectAddress secondaryObject = InvalidObjectAddress;

    /* ... and do it */
    foreach(l, stmts)
    {
        Node *stmt = (Node *) lfirst(l);

        if (IsA(stmt, CreateStmt))
        {
            /* relation is an object looks like bellow.
              table, foreign table, partition table, TOAST table, 
              index, partioned index, 
              view, materialized-view, complex type, */
            do_create_stmt(pstmt, queryString, stmt);
        }
        else if (IsA(stmt, IndexStmt))
        {
          	Node	   *parsetree = pstmt->utilityStmt;
   					IndexStmt  *index_stmt = (IndexStmt *) parsetree;
            execute_create_index(index_stmt);
        }
        else if (IsA(stmt, CreateForeignTableStmt))
        {
            /* Create the table itself */
            address = DefineRelation((CreateStmt *) stmt,
                                      RELKIND_FOREIGN_TABLE,
                                      InvalidOid, NULL,
                                      queryString);
            CreateForeignTable((CreateForeignTableStmt *) stmt,
                                address.objectId);
            EventTriggerCollectSimpleCommand(address,
                                              secondaryObject,
                                              stmt);
        }
        else
        {
            /*
              * Recurse for anything else.  Note the recursive
              * call will stash the objects so created into our
              * event trigger context.
              */
            PlannedStmt *wrapper;

            wrapper = makeNode(PlannedStmt);
            wrapper->commandType = CMD_UTILITY;
            wrapper->canSetTag = false;
            wrapper->utilityStmt = stmt;
            wrapper->stmt_location = pstmt->stmt_location;
            wrapper->stmt_len = pstmt->stmt_len;

            ProcessUtility(wrapper,
                            queryString,
                            PROCESS_UTILITY_SUBCOMMAND,
                            params,
                            NULL,
                            None_Receiver,
                            NULL);
        }

        /* Need CCI between commands */
        if (lnext(l) != NULL)
          CommandCounterIncrement();
    }

    /*
      * The multiple commands generated here are stashed
      * individually, so disable collection below.
      */
//    commandCollected = true;
}

/**
 * 
 * 
 * 
 */
void do_create_stmt(PlannedStmt *pstmt,
                    const char *queryString,
                    Node *stmt)
{
    bool success;
    ObjectAddress address;
    ObjectAddress secondaryObject = InvalidObjectAddress;

    /* relation is an object looks like bellow.
      table, foreign table, partition table, TOAST table, 
      index, partioned index, 
      view, materialized-view, complex type, */
    Datum		toast_options;
    static char *validnsps[] = HEAP_RELOPT_NAMESPACES;

    CreateStmt *create_stmt = ((CreateStmt *) stmt);
    if (create_stmt->tablespacename != NULL
        && !strcmp(create_stmt->tablespacename, TSURUGI_TABLESPACE_NAME)) 
    {
        success = execute_create_table(create_stmt);
        if (!success) 
        {
            if (create_stmt->if_not_exists) 
            {
                elog(NOTICE, "create_table() failed.");
            } 
            else
            {
                elog(ERROR, "create_table() failed.");
            }
        }
        strcat(create_stmt->relation->relname, TSURUGI_TABLE_SUFFIX);
    }
    /* Create the table itself */
    address = DefineRelation((CreateStmt *) stmt,
                              RELKIND_RELATION,
                              InvalidOid, NULL,
                              queryString);
    EventTriggerCollectSimpleCommand(address,
                                      secondaryObject,
                                      stmt);
    /*
      * Let NewRelationCreateToastTable decide if this
      * one needs a secondary relation too.
      */
    CommandCounterIncrement();

    /*
      * parse and validate reloptions for the toast
      * table
      */
    toast_options = transformRelOptions((Datum) 0,
                                        ((CreateStmt *) stmt)->options,
                                        "toast",
                                        validnsps,
                                        true,
                                        false);
    (void) heap_reloptions(RELKIND_TOASTVALUE,
                            toast_options,
                            true);

    NewRelationCreateToastTable(address.objectId,
                                toast_options);
}
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

#include "create_table_executor.h"
#include "create_index_executor.h"

static const char *TSURUGI_TABLESPACE_NAME = "tsurugi";
static const char *TSURUGI_TABLE_SUFFIX = "_tsurugi";

int64_t do_create_stmt(PlannedStmt *pstmt,
                      const char *queryString,
                      CreateStmt *create_stmt);

/**
 * 
 * 
 * 
 */
void execute_create_stmt(PlannedStmt *pstmt,
                          const char *queryString,
                          ParamListInfo params,
                          List *stmts)
{
    ListCell  *l;
    ObjectAddress address;
    ObjectAddress secondaryObject = InvalidObjectAddress;
    int64_t  object_id = -1;

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
            object_id = do_create_stmt(pstmt, queryString, (CreateStmt *) stmt);
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
            ereport(ERROR,
                (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                  errmsg("Tsurugi supports only PRIMARY KEY constraint in table constraint"),
                  errdetail("Tsurugi does not support FOREIGN KEY table constraint")));
        }
    }

    send_create_table_message(object_id);
}

/**
 * 
 * 
 * 
 */
int64_t do_create_stmt(PlannedStmt *pstmt,
                      const char *queryString,
                      CreateStmt *create_stmt)
{
    int64_t object_id = 0;
    ObjectAddress address;

    if (create_stmt->tablespacename != NULL
        && !strcmp(create_stmt->tablespacename, TSURUGI_TABLESPACE_NAME))
    {
        object_id = execute_create_table(create_stmt);
        if (object_id == -1) 
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
    address = DefineRelation((CreateStmt *) create_stmt,
                              RELKIND_RELATION,
                              InvalidOid, NULL,
                              queryString);
    /*
      * Let NewRelationCreateToastTable decide if this
      * one needs a secondary relation too.
      */
    CommandCounterIncrement();

    return object_id;
}
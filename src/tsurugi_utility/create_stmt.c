/*
 * Copyright 2023 Project Tsurugi.
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
 * Portions Copyright (c) 1996-2023, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, The Regents of the University of California
 *
 *	@file	create_stmt.c
 */
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
#include "alter_table_executor.h"

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
    int64_t  table_id = -1;

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
            table_id = do_create_stmt(pstmt, queryString, (CreateStmt *) stmt);
            if (table_id == -1)
            {
                elog(ERROR, "Failed to create a table.");
            }
        }
        else if (IsA(stmt, IndexStmt))
        {
            int64_t index_id = -1;
            index_id = execute_create_index((IndexStmt*) stmt);
            if (index_id == -1)
            {
                elog(ERROR, "Failed to create a index in creating a table.");
            }           
        }
        else if (IsA(stmt, AlterTableStmt))
        {
            table_id = execute_alter_table((AlterTableStmt*) stmt);
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
    send_create_table_message(table_id);
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

    return object_id;
}
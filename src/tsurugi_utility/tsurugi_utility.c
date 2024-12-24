/*
 * Copyright 2019-2023 Project Tsurugi.
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
 */

#include "postgres.h"

#include "access/reloptions.h"
#include "catalog/objectaddress.h"
#include "catalog/pg_class_d.h"
#include "commands/event_trigger.h"
#include "commands/tablecmds.h"
#include "tcop/utility.h"

#include <string.h>
#include "create_stmt.h"
#include "create_index_executor.h"
#include "drop_stmt.h"
#include "drop_table_executor.h"
#include "drop_index_executor.h"
#include "create_role/create_role.h"
#include "drop_role/drop_role.h"
#include "alter_role/alter_role.h"
#include "grant_revoke_role/grant_revoke_role.h"
#include "grant_revoke_table/grant_revoke_table.h"
#include "prepare_execute/prepare_execute.h"
#include "utility_common.h"
#include "foreign/foreign.h"
#include "utils/builtins.h"
#include "utils/rel.h"
#include "access/table.h"
#include "access/heapam.h"
#include "catalog/namespace.h"
#include "catalog/pg_namespace.h"
#include "catalog/pg_class.h"
#include "catalog/pg_foreign_table.h"
#include "catalog/pg_extension.h"
#include "catalog/indexing.h"
#include "utils/lsyscache.h"
#include "utils/syscache.h"
#include "utils/fmgroids.h"
#include "executor/spi.h"

#ifndef PG_MODULE_MAGIC
PG_MODULE_MAGIC;
#endif

/* ProcessUtility_hook function */
void tsurugi_ProcessUtility(PlannedStmt* pstmt, const char* query_string,
                            ProcessUtilityContext context, ParamListInfo params,
                            QueryEnvironment* queryEnv, DestReceiver* dest,
                            char* completionTag);
bool noTablesInDatabase(void);
bool IsTsurugifdwInstalled(void);

#define EXTENSION_NAME "tsurugi_fdw"

extern bool IsTransactionBlock(void);
extern void check_stack_depth(void);
extern void check_xact_readonly(Node* parsetree);
extern ParseState* make_parsestate(ParseState* parentParseState);
extern int CommandCounterIncrement(void);
extern List *transformCreateStmt(CreateStmt *stmt, const char *queryString);
extern void standard_ProcessUtility(PlannedStmt *pstmt,
					            	const char *queryString,
						            ProcessUtilityContext context,
						            ParamListInfo params,
						            QueryEnvironment *queryEnv,
						            DestReceiver *dest,
						            char *completionTag);


/*
 *  @brief:
 */
void
tsurugi_ProcessUtility(PlannedStmt *pstmt,
                       const char *queryString, 
                       ProcessUtilityContext context,
                       ParamListInfo params,
                       QueryEnvironment *queryEnv,
                       DestReceiver *dest, char *completionTag)
{
	Node	   *parsetree = pstmt->utilityStmt;
	ParseState *pstate;

	/* This can recurse, so check for excessive recursion */
	check_stack_depth();

	if (completionTag)
		completionTag[0] = '\0';

	pstate = make_parsestate(NULL);
	pstate->p_sourcetext = queryString;

	switch (nodeTag(parsetree))
	{
        case T_CreateStmt:
		{
			if (IsTsurugifdwInstalled())
			{
				elog(ERROR, "This database is for Tsurugi, so CREATE TABLE is not supported");
			}
			standard_ProcessUtility(pstmt, queryString,context, params, queryEnv,
									dest, completionTag);
            break;
		}

		case T_CreateTableAsStmt:
		{
			if (IsTsurugifdwInstalled())
			{
				switch (((CreateTableAsStmt *) parsetree)->relkind)
            	{
                	case OBJECT_TABLE:
						elog(ERROR, "This database is for Tsurugi, so CREATE TABLE AS is not supported");
				}
			}
			standard_ProcessUtility(pstmt, queryString,context, params, queryEnv,
									dest, completionTag);
            break;
		}

		case T_CreateForeignTableStmt:
		{
			if (IsTsurugifdwInstalled())
			{
				ForeignServer *server;
				ForeignDataWrapper *fdw;
				CreateForeignTableStmt *stmt = (CreateForeignTableStmt *) pstmt->utilityStmt;

				server = GetForeignServerByName(stmt->servername, false);
				fdw = GetForeignDataWrapper(server->fdwid);
				if (strcmp(fdw->fdwname, "tsurugi_fdw") != 0){
					elog(ERROR, "This database is for Tsurugi, so CREATE FOREIGN TABLE for non-Tsurugi foreign table is not supported");
				}
			}
			standard_ProcessUtility(pstmt, queryString,
									context, params, queryEnv,
									dest, completionTag);
			break;
		}

		case T_CreateExtensionStmt:
		{
			CreateExtensionStmt *stmt = (CreateExtensionStmt *) pstmt->utilityStmt;
			if (strcmp(stmt->extname, "tsurugi_fdw") == 0) {
				if(!noTablesInDatabase()){
					elog(ERROR, "tsurugi_fdw extension cannot be installed in the non-empty database. Please make sure there are no tables by using the \\d command.");
				}
			}
			standard_ProcessUtility(pstmt, queryString, context, params, queryEnv,
									dest, completionTag);
			break;
		}

#if 0 // Since user and access control is not implemented in Tsurugi, it runs on the standard.
		case T_CreateRoleStmt:
		{
			standard_ProcessUtility(pstmt, queryString, context, params, queryEnv,
									dest, completionTag);
			if (!after_create_role((CreateRoleStmt*)parsetree))
			{
				elog(ERROR, "failed after_create_role() function.");
			}
			break;
		}

		case T_DropRoleStmt: 
		{
			int64_t* objectIdList;
			bool befor_function_success = false;
			DropRoleStmt* tmpDropStmt = (DropRoleStmt*) parsetree;
			objectIdList = malloc(sizeof(int64_t) * tmpDropStmt->roles->length);
			if (objectIdList == NULL) 
			{
				/*
				 * If malloc fails, display an error message and exit.
				 */
				elog(ERROR,
					"abort DROP ROLE statement because malloc function failed.");
				break;
			}

			befor_function_success =
				before_drop_role((DropRoleStmt*) parsetree, objectIdList);
			if (!befor_function_success) 
			{
				elog(ERROR, "failed before_drop_role() function.");
			}
			/*
 			 * No skip PostgreSQL processing even if preprocessing fails.
			 * Because PostgreSQL error messages are no longer output.
			 */
			standard_ProcessUtility(pstmt, queryString, context, params, queryEnv,
									dest, completionTag);

			/*
			 * The message is sent in post-processing.
			 * Because sending a DROP message even though DROP has failed
			 * may cause problems.
			 * If pre-processing fails, the object ID cannot be obtained,
			 * so post-processing is skipped.
			 */
			if (befor_function_success) 
			{
				if (!after_drop_role((DropRoleStmt*)parsetree, objectIdList))
				elog(ERROR, "failed after_drop_role() function.");
			}
			/*
			* Delete dynamically allocated area.
			*/
			free(objectIdList);
			break;
		}	

		case T_AlterRoleStmt:
		{
			standard_ProcessUtility(pstmt, queryString, context, params, queryEnv,
									dest, completionTag);
			/*
			* The message will be sent in post-processing.
			*/
			if (!after_alter_role((AlterRoleStmt*)parsetree))
				elog(ERROR, "failed after_alter_role() function.");
			break;
		}

		case T_GrantStmt:
		{
			/*
			* GRANT/REVOKE
			* For TABLE, grant privileges to the foreign table using PostgreSQL functionality.
			* Therefore, similar to GRANT/REVOKE ROLE, send the message in post-processing.
			*/
			GrantStmt* stmts = (GrantStmt*) parsetree;

			/* When ACL_TARGET_OBJECT and other than OBJECT_TABLE, normal operation only */
			if (stmts->targtype == ACL_TARGET_OBJECT &&
				stmts->objtype == OBJECT_TABLE) 
			{
				standard_ProcessUtility(pstmt, queryString, context, params, queryEnv,
										dest, completionTag);
				if (!after_grant_revoke_table((GrantStmt*)parsetree))
				{
					elog(ERROR, "failed after_grant_revoke_table() function.");
				}
			} 
			else 
			{
				standard_ProcessUtility(pstmt, queryString, context, params, queryEnv,
										dest, completionTag);
			}
			break;
		}

		case T_GrantRoleStmt: 
		{
			/*
			 * Both GRANT and REVOKE are the same function.
			 * Judge the message sent with stmt->is_grant.
			 */
			standard_ProcessUtility(pstmt, queryString, context, params, queryEnv,
									dest, completionTag);
			if (!after_grant_revoke_role((GrantRoleStmt*)parsetree))
			{
				elog(ERROR, "failed after_grant_revoke_role() function.");
			}
			break;
		}
#endif // Since user and access control is not implemented in Tsurugi, it runs on the standard.

		case T_PrepareStmt:
		{
			standard_ProcessUtility(pstmt, queryString, context, params, queryEnv,
									dest, completionTag);
			if (!after_prepare_stmt((PrepareStmt*)parsetree, queryString))
			{
				elog(ERROR, "failed after_prepare_stmt() function.");
			}
			break;
		}

		case T_ExecuteStmt:
		{
			if (!befor_execute_stmt((ExecuteStmt*)parsetree, queryString))
			{
				elog(ERROR, "failed befor_execute_stmt() function.");
			}
			standard_ProcessUtility(pstmt, queryString, context, params, queryEnv,
									dest, completionTag);
			if (!after_execute_stmt((ExecuteStmt*)parsetree))
			{
				elog(ERROR, "failed after_execute_stmt() function.");
			}
			break;
		}

		default:
		{
		    standard_ProcessUtility(pstmt, queryString,
			    					context, params, queryEnv,
				    				dest, completionTag);
			break;
		}
	}

	free_parsestate(pstate);
}


bool noTablesInDatabase(void)
{
	int ret;
    bool result_exists = true;

    const char *query = 
        "SELECT c.oid, n.nspname, c.relname "
        "FROM pg_catalog.pg_class c "
        "LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace "
        "WHERE n.nspname NOT IN ('pg_catalog', 'information_schema') "
        "AND pg_catalog.pg_table_is_visible(c.oid)";

    if (SPI_connect() != SPI_OK_CONNECT){
        elog(ERROR, "SPI_connect failed");
	}

    ret = SPI_exec(query, 1);
    if (ret != SPI_OK_SELECT){
        elog(ERROR, "SPI_exec failed: %s", query);
	}

    if (SPI_processed > 0) {
        result_exists = false;
    }

    SPI_finish();

    return result_exists;
}

bool IsTsurugifdwInstalled(void)
{
	bool found = false;
    HeapTuple tuple;

    tuple = SearchSysCache1(FOREIGNDATAWRAPPERNAME, CStringGetDatum(EXTENSION_NAME));
    if (HeapTupleIsValid(tuple))
    {
        found = true;
        ReleaseSysCache(tuple);
    }

    return found;
}
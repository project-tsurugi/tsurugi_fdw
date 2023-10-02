/*
 * Copyright 2019-2022 tsurugi project.
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

#ifndef PG_MODULE_MAGIC
PG_MODULE_MAGIC;
#endif

/* ProcessUtility_hook function */
void tsurugi_ProcessUtility(PlannedStmt* pstmt, const char* query_string,
                            ProcessUtilityContext context, ParamListInfo params,
                            QueryEnvironment* queryEnv, DestReceiver* dest,
                            char* completionTag);

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

static void tsurugi_ProcessUtilitySlow(ParseState *pstate,
			        	               PlannedStmt *pstmt,
				                       const char *queryString,
				                       ProcessUtilityContext context,
				                       ParamListInfo params,
				                       QueryEnvironment *queryEnv,
				                       DestReceiver *dest,
				                       char *completionTag);

const char *TSURUGI_TABLESPACE_NAME = "tsurugi";

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
			CreateStmt* create_stmt = (CreateStmt*) pstmt->utilityStmt;
			if (create_stmt->tablespacename != NULL && 
					!strcmp(create_stmt->tablespacename, TSURUGI_TABLESPACE_NAME))
			{
				tsurugi_ProcessUtilitySlow(pstate, pstmt, queryString,
										context, params, queryEnv,
										dest, completionTag);
			}
			else
			{
				standard_ProcessUtility(pstmt, queryString,
										context, params, queryEnv,
										dest, completionTag);
			}
            break;
		}

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

		case T_IndexStmt: 
		{
			IndexStmt* index_stmt = (IndexStmt*) pstmt->utilityStmt;
			if (index_stmt->tableSpace != NULL && 
					!strcmp(index_stmt->tableSpace, TSURUGI_TABLESPACE_NAME))
			{
				tsurugi_ProcessUtilitySlow(pstate, pstmt, queryString,
										context, params, queryEnv,
										dest, completionTag);
			}
			else
			{
				standard_ProcessUtility(pstmt, queryString,
										context, params, queryEnv,
										dest, completionTag);
			}
			break;
		}

        case T_DropStmt:
		{
			RangeVar rel;
			DropStmt *drop_stmt = (DropStmt *) parsetree;
			switch (drop_stmt->removeType) 
			{
				case OBJECT_TABLE:
				{
					bool exists_in_tsurugi = false;
					ListCell *listptr;
					foreach(listptr, drop_stmt->objects) 
					{
						List *names = (List *) lfirst(listptr);
						get_relname(names, &rel);
						if (table_exists_in_tsurugi(rel.relname)) 
						{
							exists_in_tsurugi = true;
							break;
						}
					}
					if (exists_in_tsurugi) 
					{
						tsurugi_ProcessUtilitySlow(pstate, pstmt, queryString,
												context, params, queryEnv,
												dest, completionTag);
					}
					else
					{
						standard_ProcessUtility(pstmt, queryString,
									context, params, queryEnv,
									dest, completionTag);
					}
					break;
				}
				case OBJECT_INDEX:
				{
					bool exists_in_tsurugi = false;
					ListCell *listptr;
					foreach(listptr, drop_stmt->objects) 
					{
						List *names = (List *) lfirst(listptr);
						get_relname(names, &rel);
						if (index_exists_in_tsurugi(rel.relname)) 
						{
							exists_in_tsurugi = true;
							break;
						}
					}
					if (exists_in_tsurugi) 
					{
						tsurugi_ProcessUtilitySlow(pstate, pstmt, queryString,
												context, params, queryEnv,
												dest, completionTag);
					}
					else
					{
						standard_ProcessUtility(pstmt, queryString,
									context, params, queryEnv,
									dest, completionTag);
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
			if (!befor_execute_stmt((ExecuteStmt*)parsetree))
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

/**
 * @brief 	
 * @param	psatte
 * @param	pstmt
 * @param	queryString
 * @param	context
 * @param	params
 * @param	queryEnv
 * @param	dest
 * @param	completionTag
 */
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
    Node	*parsetree = pstmt->utilityStmt;
    bool	isCompleteQuery = (context <= PROCESS_UTILITY_QUERY);
    bool	needCleanup;
    bool	commandCollected = false;
    ObjectAddress address;
    ObjectAddress secondaryObject = InvalidObjectAddress;

    /* All event trigger calls are done only when isCompleteQuery is true */
    needCleanup = isCompleteQuery && EventTriggerBeginCompleteQuery();

    /* PG_TRY block is to ensure we call EventTriggerEndCompleteQuery */
    PG_TRY();
	{
		if (isCompleteQuery)
		EventTriggerDDLCommandStart(parsetree);

		switch (nodeTag(parsetree))
		{
			case T_CreateStmt:
			{
				Node	  *parsetree = pstmt->utilityStmt;    
				List      *stmts;

				/* Run parse analysis ... */
				stmts = transformCreateStmt((CreateStmt *) parsetree,
											queryString);
				execute_create_stmt(pstmt, queryString, params, stmts);
				break;
			}

			case T_IndexStmt:	/* CREATE INDEX */
			{
				IndexStmt* index_stmt = (IndexStmt*) pstmt->utilityStmt;
				execute_create_index(index_stmt);
				break;
			}

			case T_DropStmt:
			{
				DropStmt *drop = (DropStmt *) parsetree;
				execute_drop_stmt(drop);

				/* no commands stashed for DROP */
				commandCollected = true;
				break;
			}

            default:
			{
				elog(ERROR, "unrecognized node type: %d",
					 (int) nodeTag(parsetree));
                break;
			}
        }
		/*
		 * Remember the object so that ddl_command_end event triggers have
		 * access to it.
		 */
		if (!commandCollected)
			EventTriggerCollectSimpleCommand(address, secondaryObject,
											 parsetree);

		if (isCompleteQuery)
		{
			EventTriggerSQLDrop(parsetree);
			EventTriggerDDLCommandEnd(parsetree);
		}
	}
	PG_CATCH();
	{
		if (needCleanup)
			EventTriggerEndCompleteQuery();
		PG_RE_THROW();
	}
	PG_END_TRY();

    if (needCleanup)
      EventTriggerEndCompleteQuery();
}

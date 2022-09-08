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
 *	@file	create_table.h
 *	@brief  Dispatch the create-table command to ogawayama.
 */
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
#include "commands/event_trigger.h"
#include "commands/tablecmds.h"

#include "create_stmt.h"
#include "drop_table_executor.h"

#ifndef PG_MODULE_MAGIC
PG_MODULE_MAGIC;
#endif

/* ProcessUtility_hook function */
void tsurugi_ProcessUtility(PlannedStmt *pstmt,
                            const char *query_string, ProcessUtilityContext context,
                            ParamListInfo params,
                            QueryEnvironment *queryEnv,
                            DestReceiver *dest, char *completionTag);

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

static void tsurugi_ProcessUtilitySlow(ParseState *pstate,
			        	               PlannedStmt *pstmt,
				                       const char *queryString,
				                       ProcessUtilityContext context,
				                       ParamListInfo params,
				                       QueryEnvironment *queryEnv,
				                       DestReceiver *dest,
				                       char *completionTag);

const char *TSURUGI_TABLESPACE_NAME = "tsurugi";
const char *TSURUGI_TABLE_SUFFIX = "_tsurugi";

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
//	bool		isTopLevel = (context == PROCESS_UTILITY_TOPLEVEL);
	bool		isAtomicContext =
                    (!(context == PROCESS_UTILITY_TOPLEVEL || context == PROCESS_UTILITY_QUERY_NONATOMIC)
                    || IsTransactionBlock());
	ParseState *pstate;

	/* This can recurse, so check for excessive recursion */
	check_stack_depth();

//	check_xact_readonly(parsetree);

	if (completionTag)
		completionTag[0] = '\0';

	pstate = make_parsestate(NULL);
	pstate->p_sourcetext = queryString;

	switch (nodeTag(parsetree))
	{
        case T_CreateStmt:
        case T_IndexStmt: 
            tsurugi_ProcessUtilitySlow(pstate, pstmt, queryString,
                                       context, params, queryEnv,
                                       dest, completionTag);
            break;

        case T_DropStmt:
            {
                DropStmt   *stmt = (DropStmt *) parsetree;

                if (stmt->removeType == OBJECT_TABLE)
                    tsurugi_ProcessUtilitySlow(pstate, pstmt, queryString,
                                       context, params, queryEnv,
                                       dest, completionTag);
                else
                    standard_ProcessUtility(pstmt, queryString,
                                            context, params, queryEnv,
                                            dest, completionTag);
            }
            break;

		default:
		    standard_ProcessUtility(pstmt, queryString,
			    					context, params, queryEnv,
				    				dest, completionTag);
			break;
	}

	free_parsestate(pstate);
}

/**
 * @brief
 * 
 * 
 * 
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
    Node	   *parsetree = pstmt->utilityStmt;
    bool		isTopLevel = (context == PROCESS_UTILITY_TOPLEVEL);
    bool		isCompleteQuery = (context <= PROCESS_UTILITY_QUERY);
    bool		needCleanup;
    bool		commandCollected = false;
    ObjectAddress address;
    ObjectAddress secondaryObject = InvalidObjectAddress;
    bool    success;

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
                      Node	    *parsetree = pstmt->utilityStmt;    
                      List      *stmts;
                   
                      /* Run parse analysis ... */
                      stmts = transformCreateStmt((CreateStmt *) parsetree,
                                                  queryString);
                      execute_create_stmt(pstmt, queryString, params, stmts);
                  }
                  break;

              case T_IndexStmt:	/* CREATE INDEX */
                  {
                  }
                  break;

              case T_DropStmt:
                  {
                      DropStmt *drop = (DropStmt *) parsetree;
                      ListCell *cell;
                      foreach(cell, drop->objects)
                      {
                          RangeVar rel;
                          int nameLen, suffixLen;
                          List *names = (List *) lfirst(cell);

                          switch (list_length(names))
                          {
                              case 1:
                                  rel.relname = strVal(linitial(names));
                                  break;
                              case 2:
                                  rel.schemaname = strVal(linitial(names));
                                  rel.relname = strVal(lsecond(names));
                                  break;
                              case 3:
                                  rel.catalogname = strVal(linitial(names));
                                  rel.schemaname = strVal(lsecond(names));
                                  rel.relname = strVal(lthird(names));
                                  break;
                              default:
                                  elog(ERROR, "improper relation name (too many dotted names).");
                                  break;
                          }

                          nameLen = strlen(rel.relname);
                          suffixLen = strlen(TSURUGI_TABLE_SUFFIX);
                          if (nameLen > suffixLen) {
                              int index = nameLen - suffixLen;
                              if (0 == strncmp(&rel.relname[index], TSURUGI_TABLE_SUFFIX, suffixLen)) {
                                  char relname[64];
                                  strncpy(relname, rel.relname, nameLen);
                                  relname[index] = '\0';
                                  success = drop_table(drop, relname);
                                  if (!success) {
                                      elog(ERROR, "drop_table() failed.");
                                  }
                              }
                          }
                      }
                      RemoveRelations(drop);

                      /* no commands stashed for DROP */
                      commandCollected = true;
                  }
                  break;

              default:
                  elog(ERROR, "unrecognized node type: %d",
                    (int) nodeTag(parsetree));
                  break;
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

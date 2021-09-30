/*-------------------------------------------------------------------------
 *
 * alt_utility.c
 *	  Contains functions which control the execution of the POSTGRES utility
 *	  commands.
 *
 *-------------------------------------------------------------------------
 */

#include "postgres.h"

#include "access/reloptions.h"
#include "catalog/objectaddress.h"
#include "catalog/pg_class_d.h"
#include "commands/event_trigger.h"
#include "commands/tablecmds.h"
#include "tcop/utility.h"

#include "alter_role.h"
#include "create_role.h"
#include "create_table.h"
#include "drop_role.h"
#include "grant_revoke_role.h"
#include "grant_revoke_table.h"

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
extern List* transformCreateStmt(CreateStmt* stmt, const char* queryString);
extern void standard_ProcessUtility(PlannedStmt* pstmt, const char* queryString,
                                    ProcessUtilityContext context,
                                    ParamListInfo params,
                                    QueryEnvironment* queryEnv,
                                    DestReceiver* dest, char* completionTag);

static void tsurugi_ProcessUtilitySlow(ParseState* pstate, PlannedStmt* pstmt,
                                       const char* queryString,
                                       ProcessUtilityContext context,
                                       ParamListInfo params,
                                       QueryEnvironment* queryEnv,
                                       DestReceiver* dest, char* completionTag);

const char* TSURUGI_TABLESPACE_NAME = "tsurugi";

/*
 *  @brief:
 */
void tsurugi_ProcessUtility(PlannedStmt* pstmt, const char* queryString,
                            ProcessUtilityContext context, ParamListInfo params,
                            QueryEnvironment* queryEnv, DestReceiver* dest,
                            char* completionTag) {
  Node* parsetree = pstmt->utilityStmt;
  //	bool		isTopLevel = (context == PROCESS_UTILITY_TOPLEVEL);
  bool isAtomicContext = (!(context == PROCESS_UTILITY_TOPLEVEL ||
                            context == PROCESS_UTILITY_QUERY_NONATOMIC) ||
                          IsTransactionBlock());
  ParseState* pstate;

  /* This can recurse, so check for excessive recursion */
  check_stack_depth();

  //	check_xact_readonly(parsetree);

  if (completionTag) completionTag[0] = '\0';

  pstate = make_parsestate(NULL);
  pstate->p_sourcetext = queryString;

  switch (nodeTag(parsetree)) {
    case T_CreateStmt:
      tsurugi_ProcessUtilitySlow(pstate, pstmt, queryString, context, params,
                                 queryEnv, dest, completionTag);
      break;
    case T_CreateRoleStmt:
      standard_ProcessUtility(pstmt, queryString, context, params, queryEnv,
                              dest, completionTag);
      if (!after_create_role((CreateRoleStmt*)parsetree))
        elog(ERROR, "failed after_create_role() function.");
      break;
    case T_DropRoleStmt: {
      uint64_t* objectIdList;
      bool befor_function_success = false;
      DropRoleStmt* tmpDropStmt = (DropRoleStmt*)parsetree;
      objectIdList = malloc(sizeof(uint64_t) * tmpDropStmt->roles->length);

      /*
       * mallocに失敗した場合、エラーメッセージを表示して終了。
       */
      if (objectIdList == NULL) {
        elog(ERROR,
             "abort DROP ROLE statement because malloc function failed.");
        break;
      }

      befor_function_success =
          before_drop_role((DropRoleStmt*)parsetree, objectIdList);
      if (!befor_function_success) {
        elog(ERROR, "failed before_drop_role() function.");
      }
      /*
       * 前処理で失敗した場合も、PostgreSQLの処理をスキップしない。
       * PostgreSQLでのエラーメッセージが出力されなくなるため。
       */
      standard_ProcessUtility(pstmt, queryString, context, params, queryEnv,
                              dest, completionTag);

      /*
       * メッセージは、後処理で送信する。
       * DROPに失敗したのに、DROPのメッセージを送信していると問題になる可能性があるため。
       * 前処理で失敗した場合は、オブジェクトIDを取得できていないため、後処理をスキップ。
       */
      if (befor_function_success) {
        if (!after_drop_role((DropRoleStmt*)parsetree, objectIdList))
          elog(ERROR, "failed after_drop_role() function.");
      }
      /*
       * 動的に確保した領域を削除する。
       */
      free(objectIdList);
    } break;
    case T_AlterRoleStmt:
      standard_ProcessUtility(pstmt, queryString, context, params, queryEnv,
                              dest, completionTag);
      /*
       * メッセージは、後処理で送信する。
       */
      if (!after_alter_role((AlterRoleStmt*)parsetree))
        elog(ERROR, "failed after_alter_role() function.");
      break;
    case T_GrantStmt:
      /*
       * GRANT/REVOKE
       * TABLEについては、外部テーブルにPostgreSQLの機能で権限を付与する。
       * そのため、GRANT/REVOKE
       * ROLEと同じように後処理でメッセージを送信する。
       */
      {
        GrantStmt* stmts = (GrantStmt*)parsetree;
        /*ACL_TARGET_OBJECTかつ、OBJECT_TABLE以外の時は通常の動作のみ*/
        if (stmts->targtype == ACL_TARGET_OBJECT &&
            stmts->objtype == OBJECT_TABLE) {
          standard_ProcessUtility(pstmt, queryString, context, params, queryEnv,
                                  dest, completionTag);
          if (!after_grant_revoke_table((GrantStmt*)parsetree))
            elog(ERROR, "failed after_grant_revoke_table() function.");
        } else {
          standard_ProcessUtility(pstmt, queryString, context, params, queryEnv,
                                  dest, completionTag);
        }
      }
      break;
    case T_GrantRoleStmt:
      /*
       * GRANT/REVOKE両方ともに変更のため同一の関数としている。
       * 内部でstmt->is_grantで送信するメッセージを変更する。
       */
      standard_ProcessUtility(pstmt, queryString, context, params, queryEnv,
                              dest, completionTag);
      if (!after_grant_revoke_role((GrantRoleStmt*)parsetree))
        elog(ERROR, "failed after_grant_revoke_role() function.");
      break;
    default:
      standard_ProcessUtility(pstmt, queryString, context, params, queryEnv,
                              dest, completionTag);
      break;
  }

  free_parsestate(pstate);
}

static void tsurugi_ProcessUtilitySlow(
    ParseState* pstate, PlannedStmt* pstmt, const char* queryString,
    ProcessUtilityContext context, ParamListInfo params,
    QueryEnvironment* queryEnv, DestReceiver* dest, char* completionTag) {
  Node* parsetree = pstmt->utilityStmt;
  bool isTopLevel = (context == PROCESS_UTILITY_TOPLEVEL);
  bool isCompleteQuery = (context <= PROCESS_UTILITY_QUERY);
  bool needCleanup;
  bool commandCollected = false;
  ObjectAddress address;
  ObjectAddress secondaryObject = InvalidObjectAddress;
  bool success;

  /* All event trigger calls are done only when isCompleteQuery is true */
  needCleanup = isCompleteQuery && EventTriggerBeginCompleteQuery();

  /* PG_TRY block is to ensure we call EventTriggerEndCompleteQuery */
  PG_TRY();
  {
    if (isCompleteQuery) EventTriggerDDLCommandStart(parsetree);

    switch (nodeTag(parsetree)) {
      case T_CreateStmt: {
        List* stmts;
        ListCell* l;

        /* Run parse analysis ... */
        stmts = transformCreateStmt((CreateStmt*)parsetree, queryString);

        /* ... and do it */
        foreach (l, stmts) {
          Node* stmt = (Node*)lfirst(l);

          if (IsA(stmt, CreateStmt)) {
            Datum toast_options;
            static char* validnsps[] = HEAP_RELOPT_NAMESPACES;

            CreateStmt* create_stmt = ((CreateStmt*)stmt);

            if (create_stmt->tablespacename != NULL &&
                !strcmp(create_stmt->tablespacename, TSURUGI_TABLESPACE_NAME)) {
              success = create_table(stmts);
              if (!success) {
                if (create_stmt->if_not_exists) {
                  elog(NOTICE, "create_table() failed.");
                } else {
                  elog(ERROR, "create_table() failed.");
                }
              }
              strcat(create_stmt->relation->relname, "_dummy");
            }
            /* Create the table itself */
            address = DefineRelation((CreateStmt*)stmt, RELKIND_RELATION,
                                     InvalidOid, NULL, queryString);
            EventTriggerCollectSimpleCommand(address, secondaryObject, stmt);
            /*
             * Let NewRelationCreateToastTable decide if this
             * one needs a secondary relation too.
             */
            CommandCounterIncrement();

            /*
             * parse and validate reloptions for the toast
             * table
             */
            toast_options =
                transformRelOptions((Datum)0, ((CreateStmt*)stmt)->options,
                                    "toast", validnsps, true, false);
            (void)heap_reloptions(RELKIND_TOASTVALUE, toast_options, true);

            NewRelationCreateToastTable(address.objectId, toast_options);
          } else if (IsA(stmt, CreateForeignTableStmt)) {
            /* Create the table itself */
            address = DefineRelation((CreateStmt*)stmt, RELKIND_FOREIGN_TABLE,
                                     InvalidOid, NULL, queryString);
            CreateForeignTable((CreateForeignTableStmt*)stmt, address.objectId);
            EventTriggerCollectSimpleCommand(address, secondaryObject, stmt);
          } else {
            /*
             * Recurse for anything else.  Note the recursive
             * call will stash the objects so created into our
             * event trigger context.
             */
            PlannedStmt* wrapper;

            wrapper = makeNode(PlannedStmt);
            wrapper->commandType = CMD_UTILITY;
            wrapper->canSetTag = false;
            wrapper->utilityStmt = stmt;
            wrapper->stmt_location = pstmt->stmt_location;
            wrapper->stmt_len = pstmt->stmt_len;

            ProcessUtility(wrapper, queryString, PROCESS_UTILITY_SUBCOMMAND,
                           params, NULL, None_Receiver, NULL);
          }

          /* Need CCI between commands */
          if (lnext(l) != NULL) CommandCounterIncrement();
        }

        /*
         * The multiple commands generated here are stashed
         * individually, so disable collection below.
         */
        commandCollected = true;
      } break;

      default:
        elog(ERROR, "unrecognized node type: %d", (int)nodeTag(parsetree));
        break;
    }
    /*
     * Remember the object so that ddl_command_end event triggers have
     * access to it.
     */
    if (!commandCollected)
      EventTriggerCollectSimpleCommand(address, secondaryObject, parsetree);

    if (isCompleteQuery) {
      EventTriggerSQLDrop(parsetree);
      EventTriggerDDLCommandEnd(parsetree);
    }
  }
  PG_CATCH();
  {
    if (needCleanup) EventTriggerEndCompleteQuery();
    PG_RE_THROW();
  }
  PG_END_TRY();

  if (needCleanup) EventTriggerEndCompleteQuery();
}

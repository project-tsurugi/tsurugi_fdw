/*
 * Copyright 2019-2025 Project Tsurugi.
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
#if PG_VERSION_NUM >= 140000
void tsurugi_ProcessUtility(PlannedStmt* pstmt, const char* query_string, bool readOnlyTree,
                            ProcessUtilityContext context, ParamListInfo params,
                            QueryEnvironment* queryEnv, DestReceiver* dest,
                            QueryCompletion *qc);
#elif PG_VERSION_NUM >= 130000
void tsurugi_ProcessUtility(PlannedStmt* pstmt, const char* query_string,
                            ProcessUtilityContext context, ParamListInfo params,
                            QueryEnvironment* queryEnv, DestReceiver* dest,
                            QueryCompletion *qc);
#else
void tsurugi_ProcessUtility(PlannedStmt* pstmt, const char* query_string,
                            ProcessUtilityContext context, ParamListInfo params,
                            QueryEnvironment* queryEnv, DestReceiver* dest,
                            char* completionTag);
#endif  // PG_VERSION_NUM >= 140000
bool noTablesInDatabase(void);
bool IsTsurugifdwInstalled(void);

#define EXTENSION_NAME "tsurugi_fdw"

extern bool IsTransactionBlock(void);
extern void check_stack_depth(void);
extern void check_xact_readonly(Node* parsetree);
extern ParseState* make_parsestate(ParseState* parentParseState);
#if PG_VERSION_NUM < 140000
extern int CommandCounterIncrement(void);
#endif  // PG_VERSION_NUM < 140000
extern List *transformCreateStmt(CreateStmt *stmt, const char *queryString);

/*
 *  @brief:
 */
#if PG_VERSION_NUM >= 140000
void
tsurugi_ProcessUtility(PlannedStmt *pstmt,
                       const char *queryString,
                       bool readOnlyTree,
                       ProcessUtilityContext context,
                       ParamListInfo params,
                       QueryEnvironment *queryEnv,
                       DestReceiver *dest, QueryCompletion *qc)
#elif PG_VERSION_NUM >= 130000
void
tsurugi_ProcessUtility(PlannedStmt *pstmt,
                       const char *queryString,
                       ProcessUtilityContext context,
                       ParamListInfo params,
                       QueryEnvironment *queryEnv,
                       DestReceiver *dest, QueryCompletion *qc)
#else
void
tsurugi_ProcessUtility(PlannedStmt *pstmt,
                       const char *queryString, 
                       ProcessUtilityContext context,
                       ParamListInfo params,
                       QueryEnvironment *queryEnv,
                       DestReceiver *dest, char *completionTag)
#endif  // PG_VERSION_NUM >= 140000
{
	Node	   *parsetree = pstmt->utilityStmt;
	ParseState *pstate;

	/* This can recurse, so check for excessive recursion */
	check_stack_depth();

#if PG_VERSION_NUM < 130000
	if (completionTag)
		completionTag[0] = '\0';
#endif

	pstate = make_parsestate(NULL);
	pstate->p_sourcetext = queryString;

	switch (nodeTag(parsetree))
	{
        case T_CreateStmt:
		{
			elog(LOG, "tsurugi_fdw : %s : T_CreateStmt", __func__);

			if (IsTsurugifdwInstalled())
			{
				elog(ERROR, "This database is for Tsurugi, so CREATE TABLE is not supported");
			}
#if PG_VERSION_NUM >= 140000
			standard_ProcessUtility(pstmt, queryString, readOnlyTree, context, params, queryEnv,
									dest, qc);
#elif PG_VERSION_NUM >= 130000
			standard_ProcessUtility(pstmt, queryString, context, params, queryEnv,
									dest, qc);
#else
			standard_ProcessUtility(pstmt, queryString, context, params, queryEnv,
									dest, completionTag);
#endif
            break;
		}

		case T_CreateTableAsStmt:
		{
			elog(LOG, "tsurugi_fdw : %s : T_CreateTableAsStmt", __func__);

			if (IsTsurugifdwInstalled())
			{
#if PG_VERSION_NUM >= 140000
				switch (((CreateTableAsStmt *) parsetree)->objtype)
#else
				switch (((CreateTableAsStmt *) parsetree)->relkind)
#endif  // PG_VERSION_NUM >= 140000
            	{
                	case OBJECT_TABLE:
						elog(ERROR, "This database is for Tsurugi, so CREATE TABLE AS is not supported");
						break;
					default:
						break;
				}
			}
#if PG_VERSION_NUM >= 140000
			standard_ProcessUtility(pstmt, queryString, readOnlyTree, context, params, queryEnv,
									dest, qc);
#elif PG_VERSION_NUM >= 130000
			standard_ProcessUtility(pstmt, queryString, context, params, queryEnv,
									dest, qc);
#else
			standard_ProcessUtility(pstmt, queryString, context, params, queryEnv,
									dest, completionTag);
#endif  // PG_VERSION_NUM >= 140000
            break;
		}

		case T_CreateForeignTableStmt:
		{
			elog(LOG, "tsurugi_fdw : %s : T_CreateForeignTableStmt", __func__);
						
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
#if PG_VERSION_NUM >= 140000
			standard_ProcessUtility(pstmt, queryString, readOnlyTree,
									context, params, queryEnv,
									dest, qc);
#elif PG_VERSION_NUM >= 130000
			standard_ProcessUtility(pstmt, queryString,
									context, params, queryEnv,
									dest, qc);
#else
			standard_ProcessUtility(pstmt, queryString,
									context, params, queryEnv,
									dest, completionTag);
#endif  // PG_VERSION_NUM >= 140000
			break;
		}

		case T_CreateExtensionStmt:
		{
			CreateExtensionStmt *stmt = (CreateExtensionStmt *) pstmt->utilityStmt;

			elog(LOG, "tsurugi_fdw : %s : T_CreateExtensionStmt", __func__);

			if (strcmp(stmt->extname, "tsurugi_fdw") == 0) {
				if(!noTablesInDatabase()){
					elog(ERROR, "tsurugi_fdw extension cannot be installed in the non-empty database. Please make sure there are no tables by using the \\d command.");
				}
			}
#if PG_VERSION_NUM >= 140000
			standard_ProcessUtility(pstmt, queryString, readOnlyTree, context, params, queryEnv,
									dest, qc);
#elif PG_VERSION_NUM >= 130000
			standard_ProcessUtility(pstmt, queryString, context, params, queryEnv,
									dest, qc);
#else
			standard_ProcessUtility(pstmt, queryString, context, params, queryEnv,
									dest, completionTag);
#endif  // PG_VERSION_NUM >= 140000
			break;
		}

		default:
		{
#if PG_VERSION_NUM >= 140000
			standard_ProcessUtility(pstmt, queryString, readOnlyTree,
				   					context, params, queryEnv,
									dest, qc);
#elif PG_VERSION_NUM >= 130000
			standard_ProcessUtility(pstmt, queryString,
									context, params, queryEnv,
									dest, qc);
#else
		    standard_ProcessUtility(pstmt, queryString,
			    					context, params, queryEnv,
				    				dest, completionTag);
#endif  // PG_VERSION_NUM >= 140000
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

	elog(DEBUG3, "tsurugi_fdw : %s", __func__);

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

	elog(DEBUG3, "tsurugi_fdw : %s", __func__);

    tuple = SearchSysCache1(FOREIGNDATAWRAPPERNAME, CStringGetDatum(EXTENSION_NAME));
    if (HeapTupleIsValid(tuple))
    {
        found = true;
        ReleaseSysCache(tuple);
    }

    return found;
}

/*
 * Copyright 2023-2025 Project Tsurugi.
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
 *	@file	init.c
 */
#include "postgres.h"
#include "optimizer/planner.h"
#include "tcop/utility.h"
#include "tsurugi_fdw.h"

extern PGDLLIMPORT planner_hook_type planner_hook;
extern PGDLLIMPORT ProcessUtility_hook_type ProcessUtility_hook;
extern void _PG_init(void);
#if PG_VERSION_NUM >= 130000
extern PlannedStmt *tsurugi_planner(Query *parse2, const char *query_string, int cursorOptions, ParamListInfo boundParams);
#else
extern PlannedStmt *tsurugi_planner(Query *parse2, int cursorOptions, ParamListInfo boundParams);
#endif  // PG_VERSION_NUM >= 130000
#if PG_VERSION_NUM >= 140000
extern void tsurugi_ProcessUtility(PlannedStmt *pstmt, const char *query_string,
                                   bool readOnlyTree, ProcessUtilityContext context,
                                   ParamListInfo params,
                                   QueryEnvironment *queryEnv,
                                   DestReceiver *dest, QueryCompletion *qc);
#elif PG_VERSION_NUM >= 130000
extern void tsurugi_ProcessUtility(PlannedStmt *pstmt,
                                   const char *query_string, ProcessUtilityContext context,
                                   ParamListInfo params,
                                   QueryEnvironment *queryEnv,
                                   DestReceiver *dest, QueryCompletion *qc);
#else
extern void tsurugi_ProcessUtility(PlannedStmt *pstmt, 
                            	   const char *query_string, ProcessUtilityContext context, 
                            	   ParamListInfo params, 
                            	   QueryEnvironment *queryEnv, 
                            	   DestReceiver *dest, char *completionTag);
#endif  // PG_VERSION_NUM >= 140000

void
_PG_init(void)
{
#ifdef __TSURUGI_PLANNER__
  	planner_hook = tsurugi_planner;
#else
	planner_hook = NULL;
#endif
  ProcessUtility_hook = tsurugi_ProcessUtility;
}

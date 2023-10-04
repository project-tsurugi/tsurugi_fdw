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
 *	@file	init.c
 */
#include "postgres.h"
#include "optimizer/planner.h"
#include "tcop/utility.h"

extern PGDLLIMPORT planner_hook_type planner_hook;
extern PGDLLIMPORT ProcessUtility_hook_type ProcessUtility_hook;
extern void _PG_init(void);
extern PlannedStmt *alt_planner(Query *parse2, int cursorOptions, ParamListInfo boundParams);
extern void tsurugi_ProcessUtility(PlannedStmt *pstmt, 
                            	   const char *query_string, ProcessUtilityContext context, 
                            	   ParamListInfo params, 
                            	   QueryEnvironment *queryEnv, 
                            	   DestReceiver *dest, char *completionTag);

void
_PG_init(void)
{
  planner_hook = alt_planner;
  ProcessUtility_hook = tsurugi_ProcessUtility;
}

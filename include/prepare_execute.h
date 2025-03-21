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
 *	@file	prepare_execute.h
 *	@brief  Dispatch the prepare command to ogawayama.
 */

#ifndef PREPARE_EXECUTE_H
#define PREPARE_EXECUTE_H

#include "tg_common.h"

#ifdef __cplusplus
extern "C" {

#endif

bool after_prepare_stmt(const PrepareStmt* stmts, const char* queryString);
bool before_execute_stmt(const ExecuteStmt* stmts, const char *queryString);
bool after_execute_stmt(const ExecuteStmt* stmts);

extern bool IsTsurugifdwInstalled(void);
#ifdef __cplusplus
}
#endif

#endif  // PREPARE_EXECUTE_H

/*
 * Copyright 2022-2023 Project Tsurugi.
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
 *	@file	drop_index_executor.h
 */
#ifndef DROP_INDEX_EXECUTOR_H
#define DROP_INDEX_EXECUTOR_H

#ifdef __cplusplus
extern "C" {
#endif

#include "nodes/parsenodes.h"

bool index_exists_in_tsurugi(const char* index_name);
bool execute_drop_index(DropStmt* drop_stmt, const char* index_name);

#ifdef __cplusplus
}
#endif

#endif // DROP_INDEX_EXECUTOR_H

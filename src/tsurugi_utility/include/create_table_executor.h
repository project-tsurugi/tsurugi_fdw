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
 *	@file	create_table_executor.h
 *	@brief  Dispatch the create-table command to ogawayama.
 */
#pragma once

#ifdef __cplusplus
extern "C" {
#endif
#include "postgres.h"
#include "nodes/parsenodes.h"

int64_t execute_create_table(CreateStmt* stmt);
bool send_create_table_message(const int64_t object_id);
bool remove_table_metadata(const int64_t object_id);
bool add_index_to_table(const int64_t table_id, const int64_t index_id);

#ifdef __cplusplus
}
#endif

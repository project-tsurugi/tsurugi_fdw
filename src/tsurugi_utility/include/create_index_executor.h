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
#pragma once

#ifdef __cplusplus
extern "C" {
#endif
#include "postgres.h"
#include "nodes/parsenodes.h"

int64_t execute_create_index(IndexStmt* index_stmt);
void send_create_index_message(int64_t index_id);

#ifdef __cplusplus
}
#endif

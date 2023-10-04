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
 *	@file	alter_table_executor.h
 *	@brief  Create constraint metadata from alter table statement.
 */
#pragma once

#ifdef __cplusplus
extern "C" {
#endif
#include "postgres.h"
#include "nodes/parsenodes.h"

int64_t execute_alter_table(AlterTableStmt* alter_table_stmt);

#ifdef __cplusplus
}
#endif

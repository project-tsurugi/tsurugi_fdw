/*
 * Copyright 2022 tsurugi project.
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
 *	@file	drop_table.h
 *	@brief  Dispatch the create-table command to ogawayama.
 */

#ifndef DROP_TABLE_H
#define DROP_TABLE_H

#ifdef __cplusplus
extern "C" {
#endif

#include "nodes/parsenodes.h"

bool drop_table(DropStmt *drop, char *relname);

#ifdef __cplusplus
}
#endif

#endif // DROP_TABLE_H

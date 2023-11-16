/*
 * Copyright 2021-2023 Project Tsurugi.
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
 *	@file	drop_role.h
 *	@brief  Dispatch the drop-role command to ogawayama.
 */

#ifndef DROP_ROLE_H
#define DROP_ROLE_H

#include "tg_common.h"

#ifdef __cplusplus
extern "C" {

#endif
bool before_drop_role(const DropRoleStmt* stmts, int64_t objectIdList[]);

bool after_drop_role(const DropRoleStmt* stmts, const int64_t objectIdList[]);

#ifdef __cplusplus
}
#endif

#endif  // DROP_ROLE_H

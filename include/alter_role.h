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
 *	@file	alter_role.h
 *	@brief  Dispatch the alter-role command to ogawayama.
 */

#ifndef ALTER_ROLE_H
#define ALTER_ROLE_H

#include "tg_common.h"

#ifdef __cplusplus
extern "C" {

#endif

bool after_alter_role(const AlterRoleStmt* stmts);

#ifdef __cplusplus
}
#endif

#endif  // ALTER_ROLE_H

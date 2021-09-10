/*
 * Copyright 2021 tsurugi project.
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
 *	@file	grant_table.h
 *	@brief  Dispatch the grant-table,revoke-table command to ogawayama.
 */

#ifndef GRANT_TABLE_H
#define GRANT_TABLE_H

#ifdef __cplusplus
extern "C" {

#endif
bool before_grant_role(GrantStmt* stmts);

bool after_grant_role(GrantStmt* stmts);

bool before_revoke_role(GrantStmt* stmts);

bool after_revoke_role(GrantStmt* stmts);

#ifdef __cplusplus
}
#endif

#endif  // GRANT_TABLE_H

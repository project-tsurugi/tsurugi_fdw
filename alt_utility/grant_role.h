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
 *	@file	grant_role.h
 *	@brief  Dispatch the grant-role,revoke-role command to ogawayama.
 */

#ifndef GRANT_ROLE_H
#define GRANT_ROLE_H

#ifdef __cplusplus
extern "C" {

#endif
bool before_grant_role(GrantRoleStmt* stmts);

bool after_grant_role(GrantRoleStmt* stmts);

#ifdef __cplusplus
}
#endif

#endif  // GRANT_ROLE_H
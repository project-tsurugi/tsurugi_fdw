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
 *	@file	create_role.cpp
 *	@brief  Dispatch the create-role command to ogawayama.
 */
#include <regex>
#include <string>
#include <string_view>
#include <iostream>

#include "ogawayama/stub/api.h"
#include "manager/message/ddl_message.h"
#include "manager/message/broker.h"
#include "manager/message/status.h"
#include "manager/metadata/metadata.h"

#ifdef USE_ROLE_MOCK
#include "mock/metadata/roles.h"
#else
#include "manager/metadata/roles.h"
#endif

#ifdef __cplusplus
extern "C" {
#endif

#include "postgres.h"
#include "nodes/parsenodes.h"

#ifdef __cplusplus
}
#endif

using namespace boost::property_tree;
using namespace manager;
using namespace ogawayama;

#include "syscachecmds.h"
#include "send_message.h"
#include "create_role.h"

/**
 *  @brief Calls the function to get ID and send created role ID to ogawayama.
 *  @param [in] stmts of statements.
 *  @return true if operation was successful, false otherwize.
 */
bool after_create_role(const CreateRoleStmt* stmts) {
  Assert(stmts != nullptr);

  bool result = false;

  /* The object id stored if new table was successfully created */
  metadata::ObjectId object_id = 0;

  /* Call the function sending metadata to metadata-manager. */
  bool success = get_roleid_by_rolename_from_syscache(stmts->role, &object_id);
  if (!success) {
    return result;
  }

  message::CreateRole create_role{object_id};
  success = send_message(create_role);
  if (!success) {
      ereport(ERROR,
          (errcode(ERRCODE_INTERNAL_ERROR), 
          errmsg("Communication error occurred. (send_message:CreateRole)")));
      return result;
  }

  result = true;

  return result;
}

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
#include "create_role.h"

static bool send_message(message::Message* message,
                  std::unique_ptr<metadata::Metadata>& objects);

/**
 *  @brief Calls the function to get ID and send created role ID to ogawayama.
 *  @param [in] stmts of statements.
 *  @return true if operation was successful, false otherwize.
 */
bool after_create_role(const CreateRoleStmt* stmts) {
  Assert(stmts != nullptr);

  /* The object id stored if new table was successfully created */
  metadata::ObjectId object_id = 0;

  /* Call the function sending metadata to metadata-manager. */
  bool success = get_roleid_by_rolename_from_syscache(stmts->role, &object_id);

  if (success) {
    message::CreateRole cr_msg{object_id};
    std::unique_ptr<metadata::Metadata> roles{new metadata::Roles(TSURUGI_DB_NAME)};
    success = send_message(&cr_msg, roles);
  }

  return success;
}

/**
 *  @brief Calls the function to send Message to ogawayama.
 *  @param [in] message Message object to be sent.
 *  @param [in] objects Role object to call funciton.
 *  @return true if operation was successful, false otherwize.
 */
static bool send_message(message::Message* message,
                  std::unique_ptr<metadata::Metadata>& objects) {
  Assert(message != nullptr);

  bool ret_value = false;
  ret_value = true;

  return ret_value;
}

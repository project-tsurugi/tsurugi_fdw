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

#include "ogawayama/stub/api.h"
#include "stub_manager.h"
#include "manager/message/message.h"
#include "manager/message/message_broker.h"
#include "manager/message/status.h"
#include "manager/metadata/metadata.h"

#if 0
#include "manager/metadata/roles.h"
#else
#include "mock/metadata/roles.h"
#include "mock/message/message.h"
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

#include "role_managercmds.h"
#include "create_role.h"

/* DB name metadata-manager manages */
const std::string DBNAME = "Tsurugi";

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
  uint64_t object_id = 0;

  /* Call the function sending metadata to metadata-manager. */
  bool success = get_roleid_by_rolename(DBNAME,stmts->role,&object_id);

  if (success) {
    message::CreateRoleMessage cr_msg{object_id};
    std::unique_ptr<metadata::Metadata> roles{new metadata::Roles(DBNAME)};
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
  ERROR_CODE error = ERROR_CODE::UNKNOWN;

  /* sends message to ogawayama */
  stub::Transaction* transaction;
  error = StubManager::begin(&transaction);
  if (error != ERROR_CODE::OK) {
    ereport(ERROR, (errcode(ERRCODE_INTERNAL_ERROR),
                    errmsg("StubManager::begin() failed.")));
    return ret_value;
  }
  message::MessageBroker broker;
  message->set_receiver(transaction);
  message::Status status = broker.send_message(message);

  if (status.get_error_code() != message::ErrorCode::SUCCESS) {
    ereport(ERROR, (errcode(ERRCODE_INTERNAL_ERROR),
                    errmsg("transaction::receive_message() %s failed. (%d)",
                           message->get_message_type_name().c_str(),
                           (int)status.get_sub_error_code())));

    return ret_value;
  }

  error = transaction->commit();
  if (error != ERROR_CODE::OK) {
    elog(ERROR, "transaction::commit() failed. (%d)", (int)error);
    return ret_value;
  }
  StubManager::end();

  ret_value = true;

  return ret_value;
}

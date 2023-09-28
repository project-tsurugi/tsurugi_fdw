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
 *	@file	drop_role.cpp
 *	@brief  Dispatch the drop-role command to ogawayama.
 */

#include <regex>
#include <string>
#include <string_view>

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

using namespace boost::property_tree;
using namespace manager;
using namespace ogawayama;

#ifdef __cplusplus
extern "C" {
#endif
#include "postgres.h"

#include "nodes/parsenodes.h"
#ifdef __cplusplus
}
#endif

#include "role_managercmds.h"
#include "syscachecmds.h"

#include "drop_role.h"

static bool send_message(message::Message* message,
                         std::unique_ptr<metadata::Metadata>& objects);

/**
 *  @brief Call the function to get the IDs of DROP ROLE.
 *  @param [in] stmts DROP ROLE statements.
 *  @param [out] objectIdList Get object IDs of ROLE that is the target
 * of DROP ROLE statements.
 *  @return true if operation was successful, false otherwize.
 */
bool before_drop_role(const DropRoleStmt* stmts, int64_t objectIdList[]) {
  Assert(stmts != nullptr);
  ListCell* item;
  int listArrayNum = 0;
  bool success = false;

  foreach (item, stmts->roles) {
    RoleSpec* rolspec = (RoleSpec*) lfirst(item);
    char* role;
    metadata::ObjectId object_id;

    if (rolspec->roletype != ROLESPEC_CSTRING)
      ereport(ERROR,
              (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
               errmsg("cannot use special role specifier in DROP ROLE")));
    role = rolspec->rolename;
    success = get_roleid_by_rolename_from_syscache(role, &object_id);
    if (!success) {
      /* Failed getting role id.*/
      return success;
    }
    objectIdList[listArrayNum++] = object_id;
  }

  return success;
}

/**
 *  @brief Calls the function to confirm IDs and send IDs of droped role to
 * ogawayama.
 *  @param [in] stmts of statements.
 *  @param [in] objectIdList Object IDs of ROLE that is the target of DROP ROLE
 * statements.
 *  @return true if operation was successful, false otherwize.
 */
bool after_drop_role(const DropRoleStmt* stmts, const int64_t objectIdList[]) {
  Assert(stmts != nullptr);

  bool send_message_success = true;
  bool ret_value = false;

  /* Confirm that all ROLEs are dropped. */
  for (auto i = 0; i < stmts->roles->length; i++) {
    if (confirm_roleid_from_syscache(objectIdList[i])) {
      ereport(ERROR, (errcode(ERRCODE_INTERNAL_ERROR),
                      errmsg("canceled to send message because DROP ROLE "
                             "statements failed.")));
      return ret_value;
    }
  }

  for (auto i = 0; i < stmts->roles->length; i++) {
    message::DropRole drop_table{objectIdList[i]};
    std::unique_ptr<metadata::Metadata> roles{new metadata::Roles(TG_DATABASE_NAME)};
    if (!send_message(&drop_table, roles)) {
      send_message_success = false;
    }
  }

  ret_value = send_message_success;
  return ret_value;
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
#if 0
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
#endif
  ret_value = true;

  return ret_value;
}

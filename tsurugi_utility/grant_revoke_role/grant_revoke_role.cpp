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
 *	@file	grant_revoke_role.cpp
 *	@brief  Dispatch the grant/revoke-role command to ogawayama.
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

#include "grant_revoke_role.h"

/* DB name metadata-manager manages */
const std::string DBNAME = "Tsurugi";

static bool send_message(message::Message* message,
                  std::unique_ptr<metadata::Metadata>& objects);

/**
 *  @brief Calls the function sending metadata of created role parameters sended
 * to ogawayama.
 *  @param stmts [in] DROP ROLE statements.
 *  @param objectIdList [out] Get the object ID of the ROLE that is the target
 * of DROP ROLE statements.
 *  @return true if operation was successful, false otherwize.
 */
bool after_grant_revoke_role(const GrantRoleStmt* stmts) {
  Assert(stmts != nullptr);
  ListCell* item;
  std::vector<metadata::ObjectId> objectIds;
  bool send_message_success = true;
  bool ret_value = false;

  /* Get granted role IDs.*/
  foreach (item, stmts->granted_roles) {
    AccessPriv* priv = (AccessPriv*)lfirst(item);
    char* rolename = priv->priv_name;
    metadata::ObjectId object_id;

    if (rolename == NULL || priv->cols != NIL)
      ereport(ERROR,
              (errcode(ERRCODE_INVALID_GRANT_OPERATION),
               errmsg("column names cannot be included in GRANT/REVOKE ROLE")));
    if (get_roleid_by_rolename(DBNAME, rolename, &object_id)) {
      objectIds.push_back(object_id);
    } else {
      /* Failed getting role id.*/
      return ret_value;
    }
  }

  /* Send message containing granted role ID.*/
  for (auto object_id : objectIds) {
    if (stmts->is_grant) {
      message::GrantRole grant_role{object_id};
      std::unique_ptr<metadata::Metadata> roles{new metadata::Roles(DBNAME)};
      if (!send_message(&grant_role, roles)) {
        send_message_success = false;
      }
    } else {
      message::RevokeRole revoke_role{object_id};
      std::unique_ptr<metadata::Metadata> roles{new metadata::Roles(DBNAME)};
      if (!send_message(&revoke_role, roles)) {
        send_message_success = false;
      }
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
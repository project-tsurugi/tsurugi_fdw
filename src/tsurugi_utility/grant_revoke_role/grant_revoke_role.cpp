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

#include "tg_common.h"

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
    if (get_roleid_by_rolename(TSURUGI_DB_NAME, rolename, &object_id)) {
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
      std::unique_ptr<metadata::Metadata> roles{new metadata::Roles(TSURUGI_DB_NAME)};
      if (!send_message(&grant_role, roles)) {
        send_message_success = false;
      }
    } else {
      message::RevokeRole revoke_role{object_id};
      std::unique_ptr<metadata::Metadata> roles{new metadata::Roles(TSURUGI_DB_NAME)};
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
  ret_value = true;

  return ret_value;
}

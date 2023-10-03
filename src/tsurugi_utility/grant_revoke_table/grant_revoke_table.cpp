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
 *	@file	grant_revoke_table.cpp
 *	@brief  Dispatch the grant/revoke-table command to ogawayama.
 */

#include <regex>
#include <string>
#include <string_view>

#include "ogawayama/stub/api.h"

#include "manager/message/ddl_message.h"
#include "manager/message/broker.h"
#include "manager/message/status.h"
#include "manager/metadata/metadata.h"
#include "manager/metadata/tables.h"

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

#include "table_managercmds.h"

#include "grant_revoke_table.h"

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
bool after_grant_revoke_table(const GrantStmt* stmts) {
  Assert(stmts != nullptr);
  ListCell* item;
  std::vector<metadata::ObjectId> objectIds;
  bool send_message_success = true;
  bool ret_value = false;

  foreach (item, stmts->objects) {
    RangeVar* relvar = (RangeVar*) lfirst(item);
    metadata::ObjectId object_id;

    if (get_tableid_by_tablename(TSURUGI_DB_NAME, relvar->relname, &object_id)) {
      objectIds.push_back(object_id);
    }
  }

  /* Send message containing target table ID.*/
  for (auto object_id : objectIds) {
    if (stmts->is_grant) {
      message::GrantTable grant_table{object_id};
      std::unique_ptr<metadata::Metadata> tables{new metadata::Tables(TSURUGI_DB_NAME)};
      if (!send_message(&grant_table, tables)) {
        send_message_success = false;
      }
    } else {
      message::RevokeTable revoke_table{object_id};
      std::unique_ptr<metadata::Metadata> tables{new metadata::Tables(TSURUGI_DB_NAME)};
      if (!send_message(&revoke_table, tables)) {
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
 *  @param [in] objects Table object to call funciton.
 *  @return true if operation was successful, false otherwize.
 */
static bool send_message(message::Message* message,
                         std::unique_ptr<metadata::Metadata>& objects) {
  Assert(message != nullptr);

  bool ret_value = false;
  ret_value = true;

  return ret_value;
}

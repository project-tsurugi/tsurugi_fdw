/*
 * Copyright 2019-2020 tsurugi project.
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
 *	@file	create_table.cpp
 *	@brief  Dispatch the create-table command to ogawayama.
 */

#include <regex>
#include <string>
#include <string_view>

#include "ogawayama/stub/api.h"

#include "manager/message/message.h"
#include "manager/message/message_broker.h"
#include "manager/message/status.h"
#include "manager/metadata/datatypes.h"
#include "manager/metadata/metadata.h"
#include "manager/metadata/tables.h"

using namespace boost::property_tree;
using namespace ogawayama;
using namespace manager;

#ifdef __cplusplus
extern "C"
{
#endif
#include "postgres.h"
#include "nodes/parsenodes.h"
#ifdef __cplusplus
}
#endif

#include "stub_manager.h"
#include "tablecmds.h"
#include "create_table.h"

/* DB name metadata-manager manages */
const std::string DBNAME = "Tsurugi";

bool remove_metadata(std::unique_ptr<metadata::Metadata> &object, metadata::ObjectIdType);
bool send_message(message::Message* message);

/**
 *  @brief Calls the function sending metadata to metadata-manager and creates parameters sended to ogawayama.
 *  @param [in] List of statements.
 */
bool create_table(List *stmts)
{
  Assert(stmts != nullptr);

  bool ret_value{false};

  CreateTable cmds{stmts, DBNAME};

  // Create metadata of table.
  metadata::ObjectIdType object_id = 0;
  bool success = cmds.define_relation(&object_id);
  if (!success) {
    ereport(ERROR,
            (errcode(ERRCODE_INTERNAL_ERROR), 
            errmsg("CreateTable::define_relation() failed.")));
    return  ret_value;
  }

  /* sends message to ogawayama */
  stub::Connection* connection;
  stub::ErrorCode error = StubManager::get_connection(&connection);
  if (error != ERROR_CODE::OK) {
    elog(NOTICE, "StubManager::get_connection() failed.");
    return ret_value;
  }

  message::BeginDDL begin_ddl{};
  begin_ddl.set_receiver(connection);

  message::CreateTable create_table{object_id};
  create_table.set_receiver(connection);

  message::EndDDL end_ddl{};
  end_ddl.set_receiver(connection);

  std::unique_ptr<metadata::Metadata> tables = std::make_unique<metadata::Tables>(DBNAME);

  success = send_message(&begin_ddl);
  if (!success) {
    remove_metadata(tables, object_id);
    send_message(&end_ddl);
    ereport(ERROR,
            (errcode(ERRCODE_INTERNAL_ERROR), 
            errmsg("send_message() failed. (BeginDDLMessage)")));
    return ret_value;
  }

  success = send_message(&create_table);
  if (!success) {
    remove_metadata(tables, object_id);
    send_message(&end_ddl);
    ereport(ERROR,
            (errcode(ERRCODE_INTERNAL_ERROR), 
            errmsg("send_message() failed. (CreateTableMessage)")));
    return ret_value;
  }

  success = send_message(&end_ddl);
  if (!success) {
    remove_metadata(tables, object_id);
    ereport(ERROR,
            (errcode(ERRCODE_INTERNAL_ERROR), 
            errmsg("send_message() failed. (EndDDLMessage)")));
    return ret_value;
  }

  ret_value = true;

  return ret_value;
}

/*
 *  @brief:
 */
bool send_message(message::Message* message)
{
  Assert(message != nullptr);

  bool ret_value = false;

  message::Status status = message::MessageBroker::send_message(message); 
  if (status.get_error_code() != message::ErrorCode::SUCCESS) {
    ereport(WARNING,
            (errcode(ERRCODE_INTERNAL_ERROR),
            errmsg("Execute DDL failed. (%s) (%d)",
            message->string(), status.get_sub_error_code())));
    return ret_value;
  }

  ret_value = true;

  return ret_value;
}

/*
 *  @brief:
 */
bool remove_metadata(std::unique_ptr<metadata::Metadata> &objects, metadata::ObjectIdType object_id)
{
  bool ret_value = false;
  ptree data;

  metadata::ErrorCode error = objects->get(object_id, data);

  if (error == metadata::ErrorCode::OK) {
    error = objects->remove(object_id);
    if (error != metadata::ErrorCode::OK) {
      ereport(WARNING,
              (errcode(ERRCODE_INTERNAL_ERROR),
              errmsg("remove metadata() failed. (code: %u) (oid: %d)", 
              error, object_id)));
      return ret_value;
    }
  }

  ret_value = true;

  return ret_value;
}

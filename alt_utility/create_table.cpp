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
using namespace manager::metadata;

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

void remove_metadata(message::Message *message, std::unique_ptr<metadata::Metadata> &objects);
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

    // Credate Messages.
    message::BeginDDLMessage begin_msg{0};
    message::EndDDLMessage end_msg{0};

    // Define a table.
    ObjectIdType object_id = 0;
    bool success = cmds.define_relation(&object_id);
    if (!success) {
      ereport(ERROR,
              (errcode(ERRCODE_INTERNAL_ERROR), 
              errmsg("CreateTable::define_relation() failed.")));
      return  ret_value;
    }

    // Send message to Ogawayama.
    success = send_message(&begin_msg);
    if (!success) {
        ereport(ERROR,
                (errcode(ERRCODE_INTERNAL_ERROR), 
                errmsg("send_message() failed. (BeginDDLMessage)")));
        return ret_value;
    }

    std::unique_ptr<metadata::Metadata> tables = std::make_unique<Tables>(DBNAME);
    message::CreateTableMessage create_msg{(uint64_t) object_id};
    success = send_message(&create_msg);
    if (!success) {
        remove_metadata(&create_msg, tables);
        send_message(&end_msg);
        ereport(ERROR,
                (errcode(ERRCODE_INTERNAL_ERROR), 
                errmsg("send_message() failed. (CreateTableMessage)")));
        return ret_value;
    }

    success = send_message(&end_msg);
    if (!success) {
        remove_metadata(&create_msg, tables);
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
  ERROR_CODE error = ERROR_CODE::UNKNOWN;

  /* sends message to ogawayama */
  stub::Connection* connection;
  error = StubManager::get_connection(&connection);
  if (error != ERROR_CODE::OK) {
    elog(NOTICE, "StubManager::get_connection() failed.");
    return ret_value;
  }

  message::MessageBroker broker;
  message->set_receiver(connection);
  message::Status status = broker.send_message(message);

  if (status.get_error_code() != message::ErrorCode::SUCCESS) {
    ereport(WARNING,
            (errcode(ERRCODE_INTERNAL_ERROR),
              errmsg("connection::receive_message() %s failed. (%d)",
            message->get_message_type_name().c_str(), (int)status.get_sub_error_code())));
    return ret_value;
  }

  ret_value = true;

  return ret_value;
}

/*
 *  @brief:
 */
void remove_metadata(message::Message *message, std::unique_ptr<metadata::Metadata> &objects)
{
  ErrorCode error = objects->remove(message->get_object_id());
  if (error != ErrorCode::OK) {
    ereport(WARNING,
            (errcode(ERRCODE_INTERNAL_ERROR),
              errmsg("remove metadata() failed. (error: %d) (oid: %d)", 
              (int)error, (int)message->get_object_id())));
  }
}

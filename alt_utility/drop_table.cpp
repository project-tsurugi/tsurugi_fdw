/*
 * Copyright 2022 tsurugi project.
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
#include "stub_manager.h"

#include "manager/message/message.h"
#include "manager/message/message_broker.h"
#include "manager/message/status.h"
#include "manager/metadata/datatypes.h"
#include "manager/metadata/metadata.h"
#include "manager/metadata/tables.h"

using namespace boost::property_tree;
using namespace manager;
using namespace ogawayama;

#ifdef __cplusplus
extern "C"
{
#endif
#include "postgres.h"
#include "nodes/parsenodes.h"
#ifdef __cplusplus
}
#endif

#include "tablecmds.h"

#include "drop_table.h"

/* DB name metadata-manager manages */
const std::string DBNAME = "Tsurugi";

bool send_drop_message(message::Message *message, std::unique_ptr<metadata::Metadata> &objects);

using namespace manager::metadata;

/**
 *  @brief Calls the function sending metadata to metadata-manager and drops parameters sended to ogawayama.
 *  @param [in] Table name to remove.
 */
bool drop_table(DropStmt *drop, char *relname)
{
    Assert(drop != nullptr);
    bool success = false;

    if (drop->behavior == DROP_CASCADE) {
        ereport(ERROR,
                (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                 errmsg("Tsurugi does not support CASCADE clause")));
        return success;
    }

    /* Get the object ID of the table to be deleted */
    ptree remove_table;
    std::unique_ptr<metadata::Metadata> tables = std::make_unique<Tables>(DBNAME);
    ErrorCode error = tables->get(relname, remove_table);
    if (error != ErrorCode::OK) {
        if (error == ErrorCode::NAME_NOT_FOUND && drop->missing_ok) {
            success = true;
        } else {
            ereport(ERROR,
                    (errcode(ERRCODE_INTERNAL_ERROR),
                     errmsg("drop_table() get metadata failed.")));
        }
        return success;
    }
    boost::optional<ObjectIdType> remove_table_id = remove_table.get_optional<ObjectIdType>(Tables::ID);
    ObjectIdType object_id = remove_table_id.get();

    /* BEGIN_DDL message to ogawayama */
    message::BeginDDLMessage bd_msg{0};
    success = send_drop_message(&bd_msg, tables);
    if (false == success) {
        return success;
    }

    /* DROP_TABLE message to ogawayama */
    message::DropTableMessage dt_msg{(uint64_t)object_id};
    success = send_drop_message(&dt_msg, tables);

    /* END_DDL message to ogawayama */
    message::EndDDLMessage ed_msg{0};
    success &= send_drop_message(&ed_msg, tables);
    if (false == success) {
        return success;
    }

    /* remobe metadata */
    error = tables->remove(object_id);
    if (error != ErrorCode::OK)
    {
        ereport(ERROR,
                (errcode(ERRCODE_INTERNAL_ERROR),
                 errmsg("drop_table() remove metadata failed.")));
        success = false;
        return success;
    }

    return success;
}

/*
 *  @brief:
 */
bool send_drop_message(message::Message *message, std::unique_ptr<metadata::Metadata> &objects)
{
    Assert(message != nullptr);

    bool ret_value = false;
    ERROR_CODE error = ERROR_CODE::UNKNOWN;

    /* sends message to ogawayama */
    stub::Connection* connection;
    error = StubManager::get_connection(&connection);
    if (error != ERROR_CODE::OK)
    {
        ereport(ERROR,
                (errcode(ERRCODE_INTERNAL_ERROR),
                 errmsg("StubManager::get_connection() failed.")));
        return ret_value;
    }

    message::MessageBroker broker;
    message->set_receiver(connection);
    message::Status status = broker.send_message(message);

    if (status.get_error_code() != message::ErrorCode::SUCCESS)
    {
        ereport(ERROR,
                (errcode(ERRCODE_INTERNAL_ERROR),
                 errmsg("connection::receive_message() %s failed. (%d)",
                message->get_message_type_name().c_str(), (int)status.get_sub_error_code())));

        return ret_value;
    }

    ret_value = true;

    return ret_value;
}

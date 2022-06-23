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

#include "create_table.h"

/* DB name metadata-manager manages */
const std::string DBNAME = "Tsurugi";

void remove_metadata(message::Message *message, std::unique_ptr<metadata::Metadata> &objects);
bool send_message(message::Message *message, std::unique_ptr<metadata::Metadata> &objects);
#if 0
static std::string rewrite_query(std::string_view query_string);
static bool execute_create_table(std::string_view query_string);
#endif

using namespace manager::metadata;

/**
 *  @brief Calls the function sending metadata to metadata-manager and creates parameters sended to ogawayama.
 *  @param [in] List of statements.
 */
bool create_table(List *stmts)
{
    Assert(stmts != nullptr);

    /* The object id stored if new table was successfully created */
    ObjectIdType object_id = 0;

    /* Call the function sending metadata to metadata-manager. */
    CreateTable cmds{stmts, DBNAME};
    std::unique_ptr<metadata::Metadata> tables = std::make_unique<Tables>(DBNAME);

    /* BEGIN_DDL message to ogawayama */
    message::BeginDDLMessage bd_msg{0};
    bool success = send_message(&bd_msg, tables);
    if (false == success) {
        return success;
    }

    /* CREATE_TABLE message to ogawayama */
    if (success) {
        success = cmds.define_relation( &object_id );
    }
    if (success) {
        message::CreateTableMessage ct_msg{(uint64_t)object_id};
        success = send_message(&ct_msg, tables);
    }

    /* END_DDL message to ogawayama */
    if (success) {
        message::EndDDLMessage ed_msg{0};
        success = send_message(&ed_msg, tables);
    }

    return success;
}


/*
 *  @brief:
 */
bool send_message(message::Message *message, std::unique_ptr<metadata::Metadata> &objects)
{
    Assert(message != nullptr);

    bool ret_value = false;
    ERROR_CODE error = ERROR_CODE::UNKNOWN;

    /* sends message to ogawayama */
    stub::Connection* connection;
    error = StubManager::get_connection(&connection);
    if (error != ERROR_CODE::OK)
    {
        remove_metadata(message, objects);
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
        remove_metadata(message, objects);
        ereport(ERROR,
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
    if (error != ErrorCode::OK)
    {
        ereport(ERROR,
                (errcode(ERRCODE_INTERNAL_ERROR),
                 errmsg("remove_metadata() failed.")));
    }
}

#if 0
/*
 *  @brief:
 */
bool create_table(const char* query_string)
{
    Assert(query_string != nullptr);

    std::string query{query_string};

    bool success = execute_create_table(query);
    if (!success)
    {
        elog(ERROR, "execute_create_table() failed.");
    }

    return success;
}

/*
 *  @brief:
 */
bool execute_create_table(std::string_view query_string)
{
    bool ret_value = false;
    ERROR_CODE error = ERROR_CODE::UNKNOWN;

    const std::string rewrited_query = rewrite_query(query_string);

    // dispatch create_table query.
    stub::Transaction* transaction;
    error = StubManager::begin(&transaction);
    if (error != ERROR_CODE::OK)
    {
        std::cerr << "begin() failed." << std::endl;
        return ret_value;
    }

    elog(DEBUG2, "rewrited query string : \"%s\"", rewrited_query.c_str());
    error = transaction->execute_create_table(rewrited_query);
    if (error != ERROR_CODE::OK)
    {
        elog(ERROR, "transaction::execute_create_table() failed. (%d)", (int) error);
        return ret_value;
    }

    error = transaction->commit();
    if (error != ERROR_CODE::OK)
    {
        elog(ERROR, "transaction::commit() failed. (%d)", (int) error);
        return ret_value;
    }
    StubManager::end();

    ret_value = true;

    return ret_value;
}

/*
 *  @brief:
 */
static std::string rewrite_query(std::string_view query_string)
{
    std::string rewrited_query{query_string};

    std::unique_ptr<metadata::Metadata> datatypes{new metadata::DataTypes("NEDO DB")};

    metadata::ErrorCode error = datatypes->load();
    if (error != metadata::ErrorCode::OK) {
        std::cout << "DataTypes::load() error." << std::endl;
    }

    // trim a terminal semi-column.
    if (rewrited_query.back() == ';' ) {
        rewrited_query.pop_back();
    }

    ptree datatype;

    while ((error = datatypes->next(datatype)) == metadata::ErrorCode::OK) {
        boost::optional<std::string> pg_type_name =
            datatype.get_optional<std::string>(metadata::DataTypes::PG_DATA_TYPE_NAME);
        boost::optional<std::string> og_type_name =
            datatype.get_optional<std::string>(metadata::DataTypes::NAME);
        if (!pg_type_name.get().empty() && !og_type_name.get().empty()) {
            try {
                rewrited_query = std::regex_replace(
                    rewrited_query,
                    std::regex("(\\s)(" + pg_type_name.get() + ")([\\s,)])", std::regex_constants::icase),
                    "$1" + og_type_name.get() + "$3");
            } catch (std::regex_error e) {
                std::cout << "regex_replace() error. " << e.what() << std::endl;
            }
        }
    }

    try {
        rewrited_query = std::regex_replace(
            rewrited_query, std::regex("\\sTABLESPACE\\sTsurugi", std::regex_constants::icase), "");
    } catch (std::regex_error e) {
        std::cout << "regex_replace() error. " << e.what() << std::endl;
    }

    return rewrited_query;
}
#endif

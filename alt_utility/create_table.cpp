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

#include <string>
#include <string_view>
#include <regex>

#include "ogawayama/stub/api.h"
#include "stub_manager.h"
#include "manager/metadata/metadata.h"
#include "manager/metadata/datatypes.h"

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

#include "tablecmds.h"
#include "create_table.h"

static std::string rewrite_query(std::string_view query_string);
static bool execute_create_table(std::string_view query_string);

/*
 *  @brief:
 */
bool create_table(CreateStmt *stmt)
{
    Assert(stmt != nullptr);

    TableCommands table_commands;
    bool success = table_commands.define_relation(stmt);
    if (!success)
    {
        elog(ERROR, "execute_create_table() failed.");
    }

    return success;
}

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

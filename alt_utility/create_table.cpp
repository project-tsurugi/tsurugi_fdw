/*
 * Copyright 2019-2019 tsurugi project.
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
#include "manager/metadata/metadata.h"
#include "manager/metadata/datatype_metadata.h"
#include "ogawayama/stub/api.h"
#include "stub_connector.h"

#include "create_table.h"

using namespace boost::property_tree;
using namespace manager;
using namespace ogawayama;

#ifdef __cplusplus
extern "C" {
#endif

static std::string rewrite_query(std::string_view query_string);
static bool execute_create_table(std::string_view query_string);

#ifdef __cplusplus
}
#endif

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

    // omit terminal semi-column.
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

/*
 *  @brief: 
 */
bool create_table(const char* query_string)
{
    assert(query_string != nullptr);

    
    std::string query{query_string};

    bool success = execute_create_table(query);

    return success;
}

/*
 *  @brief: 
 */
bool execute_create_table(std::string_view query_string)
{
    bool ret_value = false;
    
    const std::string rewrited_query = rewrite_query(query_string);

    // dispatch create_table query.
    stub::Connection* connection;
    ERROR_CODE error = StubConnector::get_connection(&connection);
    if (error != ERROR_CODE::OK) {
        std::cerr << "StubConnector::get_connection() failed." << std::endl;
        return ret_value;
    }

    TransactionPtr transaction;
    error = connection->begin(transaction);
    if (error != ERROR_CODE::OK) {
        std::cerr << "begin() failed." << std::endl;
        return ret_value;
    }

    std::cerr << "rewrited query string : \"" << rewrited_query << "\"" << std::endl;
    error = transaction->execute_create_table(rewrited_query);
    if (error != ERROR_CODE::OK) {
        std::cerr << "execute_create_table() failed." << std::endl;        
        return ret_value;
    }

    ret_value = true;

    return ret_value;
}

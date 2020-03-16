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
#ifdef __cplusplus
extern "C" {
#endif

//#include "postgres.h"
//#include "storage/proc.h"
//PG_MODULE_MAGIC;

#ifdef __cplusplus
}
#endif

#include <string>
#include <string_view>
#include <regex>
#include "manager/metadata/metadata.h"
#include "manager/metadata/datatype_metadata.h"
#include "ogawayama/stub/api.h"

#include "create_table.h"

using namespace boost::property_tree;
using namespace manager;
using namespace ogawayama;

namespace metadata = manager::metadata_manager;

struct stub_connection {
    bool exist_stub = false;
    bool connected = false;
    std::size_t pid = 0;
};

static stub_connection conn_;

StubPtr stub_ = NULL;
ConnectionPtr connection_ = NULL;
TransactionPtr transaction_ = NULL;
// extern PGDLLIMPORT PGPROC *MyProc;

/*
 *  @brief: 
 */
std::string rewrite_query(const std::string query_string)
{
    std::string rewrited_query{query_string};

    std::unique_ptr<metadata::Metadata> datatypes{new metadata::DataTypeMetadata("NEDO DB")};

    metadata::ErrorCode error = datatypes->load();
    if (error != metadata::ErrorCode::OK) {
        std::cout << "load() error." << std::endl;
    }

    ptree datatype;

    while ((error = datatypes->next(datatype)) == metadata::ErrorCode::OK) {
        boost::optional<std::string> pg_type_name = 
            datatype.get_optional<std::string>(metadata::DataTypeMetadata::PG_DATA_TYPE_NAME);
        boost::optional<std::string> og_type_name = 
            datatype.get_optional<std::string>(metadata::DataTypeMetadata::NAME);
        try {
            rewrited_query = std::regex_replace(
                rewrited_query, 
                std::regex("(\\s)(" + pg_type_name.get() + ")([\\s,])", std::regex_constants::icase), 
                "$1" + og_type_name.get() + "$3");
        } catch (std::regex_error e) {
            std::cout << "regex_replace() error. " << e.what() << std::endl;
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
    std::string query{query_string};
    bool success = false;
    
    //std::size_t pid = MyProc->pgprocno;
    conn_.pid = getpid();

    std::string rewrited_query = rewrite_query(query);
    std::cout << "rewrited query string : \"" << rewrited_query << "\"" << std::endl;

    // dispatch create_table query.
    stub::ErrorCode error = stub::ErrorCode::UNKNOWN;
    if (!stub_) {
        error = make_stub(stub_);
        if (error != stub::ErrorCode::OK) {
            std::cout << "make_stub() failed." << std::endl;
            return success;
        }
    }
    if (!connection_) {
        error = stub_->get_connection(conn_.pid, connection_);
        if (error != stub::ErrorCode::OK) {
            std::cout << "get_connection() failed." << std::endl;
            return success;
        }
    }
    if (!transaction_) {
        error = connection_->begin(transaction_);
        if (error != stub::ErrorCode::OK) {
            std::cout << "begin() failed." << std::endl;
            return success;
        }
    }
    error = transaction_->execute_create_table(rewrited_query);
    if (error != stub::ErrorCode::OK) {
        std::cout << "execute_create_table() failed." << std::endl;
        return success;
    }

    success = true;

    return success;
}

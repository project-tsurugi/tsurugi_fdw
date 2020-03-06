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
#include "ogawayama/stub/api.h"

#include "create_table.h"

using namespace ogawayama;

//extern PGDLLIMPORT PGPROC *MyProc;
static StubPtr stub_ = NULL;
static ConnectionPtr connection_ = NULL;
static TransactionPtr transaction_ = NULL;

/*
 *  @brief: 
 */
std::string rewrite_query(const std::string query_string)
{
    std::string rewrited_query;

    try {
        rewrited_query = std::regex_replace(
            query_string, std::regex("(\\s)(INTEGER)([\\s,])",std::regex_constants::icase), "$1INT32$3");

    } catch (...) {
        std::cout << "regex_replace() error." << std::endl;
    }

    return rewrited_query;
}

/*
 *  @brief: 
 */
int create_table(const char* query_string)
{
    std::string query{query_string};
    
//    std::size_t pid = MyProc->pgprocno;

    std::string rewrited_query = rewrite_query(query);
    std::cout << "rewrited query string : \"" << rewrited_query << "\"" << std::endl;

#if 0
    // dispatch query.
    stub::ErrorCode error = make_stub(stub_);
    error = stub_->get_connection(pid, connection_);
    error = connection_->begin(transaction_);
    error = transaction_->execute_statement(rewrited_query);
#endif

    return 0;
}

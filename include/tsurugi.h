/*
 * Copyright 2023-2025 Project Tsurugi.
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
 *	@file	tsurugi.h
 */
#pragma once

#include <string>
#include <string_view>

#include "ogawayama/stub/error_code.h"
#include "ogawayama/stub/api.h"

class Tsurugi {
public:
	static ERROR_CODE init();
    static ERROR_CODE get_connection(ogawayama::stub::Connection** connection);
    static ERROR_CODE prepare(std::string_view sql,
                              ogawayama::stub::placeholders_type& placeholders,
                              PreparedStatementPtr& prepared_statement);
    static ERROR_CODE start_transaction();
    static ERROR_CODE execute_query(std::string_view query, 
                                    ResultSetPtr& result_set);
    static ERROR_CODE execute_statement(std::string_view statement, std::size_t& num_rows);
    static ERROR_CODE commit();
    static ERROR_CODE rollback();

    static ERROR_CODE begin(ogawayama::stub::Transaction** transaction);
    static void end();
    static ERROR_CODE tsurugi_error(ogawayama::stub::tsurugi_error_code& code);
    static std::string get_error_detail(ERROR_CODE error);
    static std::string get_error_message(ERROR_CODE error_code);

    static ERROR_CODE get_list_tables(TableListPtr& table_list);
    static ERROR_CODE get_table_metadata(std::string_view table_name, TableMetadataPtr& table_metadata);

    Tsurugi() = delete;

private:
	static StubPtr stub_;
	static ConnectionPtr connection_;
	static TransactionPtr transaction_;
};
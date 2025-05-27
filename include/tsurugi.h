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

#include <optional>
#include <string>
#include <string_view>
#include <unordered_map>

#include "ogawayama/stub/error_code.h"
#include "ogawayama/stub/api.h"

#ifdef __cplusplus
extern "C" {
#endif
#include "postgres.h"
#include "postgres_ext.h"
#include "catalog/pg_type_d.h"
#ifdef __cplusplus
}
#endif

class Tsurugi {
public:
	static ERROR_CODE init();
    static ERROR_CODE get_connection(ogawayama::stub::Connection** connection);
    static ERROR_CODE prepare(std::string_view sql,
                              ogawayama::stub::placeholders_type& placeholders,
                              PreparedStatementPtr& prepared_statement);
    static ERROR_CODE prepare(std::string_view name, std::string_view statement,
                              ogawayama::stub::placeholders_type& placeholders);
    static ERROR_CODE prepare(std::string_view statement,
                              ogawayama::stub::placeholders_type& placeholders);
	static ERROR_CODE deallocate(std::string_view prep_name);
    static void deallocate();
    static ERROR_CODE start_transaction();
    static ERROR_CODE execute_query(std::string_view query);
    static ERROR_CODE execute_query(std::string_view query, 
                                    ResultSetPtr& result_set);
    static ERROR_CODE execute_statement(std::string_view statement, 
                                        std::size_t& num_rows);
    static ERROR_CODE execute_statement(std::string_view prep_name, 
                                        ogawayama::stub::parameters_type& params, 
                                        std::size_t& num_rows);
    static ERROR_CODE execute_statement(ogawayama::stub::parameters_type& params, 
                                        std::size_t& num_rows);
    static ERROR_CODE commit();
    static ERROR_CODE rollback();

    static void init_result_set() { result_set_ = nullptr; }
    static ResultSetPtr get_result_set() { return result_set_; }
    static ERROR_CODE result_set_next() { return result_set_->next(); }
    static void init_metadata() { metadata_ = nullptr; }
    static MetadataPtr get_metadata() { return metadata_; }

    static ERROR_CODE tsurugi_error(ogawayama::stub::tsurugi_error_code& code);
    static std::string get_error_detail(ERROR_CODE error);
    static std::string get_error_message(ERROR_CODE error_code);
    static void log2(int level, std::string_view message, ERROR_CODE error);
    static void log3(int level, std::string_view message, ERROR_CODE error);
    static void log(int level, std::string_view message, ERROR_CODE error,
            std::string_view error_name) {
	    elog(level, message.data(), (int) error, error_name.data());
    }
    static void log(int level, std::string_view message, ERROR_CODE error, 
			std::string_view error_name, std::string_view error_detail) {
	    elog(level, message.data(), (int) error, error_name.data(), 
		    error_detail.data());
    }
    static ERROR_CODE get_list_tables(TableListPtr& table_list);
    static ERROR_CODE get_table_metadata(std::string_view table_name, 
            TableMetadataPtr& table_metadata);

	static std::optional<std::string_view> convert_type_to_pg(
		jogasaki::proto::sql::common::AtomType tg_type);

    static ogawayama::stub::Metadata::ColumnType::Type
            get_tg_column_type(const Oid pg_type);

    static ogawayama::stub::value_type
            convert_type_to_tg(const Oid pg_type, Datum value);
/*
    static ogawayama::stub::value_type
            get_tg_value_type(const Oid pg_type, Datum value);
*/
	Tsurugi() = delete;

private:
	static StubPtr stub_;
	static ConnectionPtr connection_;
	static TransactionPtr transaction_;
    static std::unordered_map<std::string, PreparedStatementPtr> prepared_statements_;
    static PreparedStatementPtr prepared_statement_;
    static ResultSetPtr result_set_;
    static MetadataPtr metadata_;

    static ogawayama::stub::timestamptz_type convert_timestamptz_to_tg(Datum value);
    static takatori::decimal::triple convert_decimal_to_tg(Datum value);
};
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
#include "nodes/pg_list.h"
#ifdef __cplusplus
}
#endif

/**
 * @class ConnectionInfo
 * @brief A class that stores Tsurugi connection information.
 * 
 * This class is used to manage and validate connection options for the Tsurugi.
 * It provides methods to parse options, check for matches, and retrieve individual server option values.
 * 
 * The supported options include:
 * 
 * - endpoint: Specifies the connection endpoint type.
 * 
 * - dbname: The name of the database to connect to.
 * 
 * - address: The address of the database server.
 * 
 * - port: The port number for the database connection.
 */
class ConnectionInfo {
public:
	ConnectionInfo() {}
	ConnectionInfo(const List* server_opts) { parse(server_opts); }
	ConnectionInfo(const ConnectionInfo& server_opts) {
		endpoint_ = server_opts.endpoint_;
		dbname_ = server_opts.dbname_;
		address_ = server_opts.address_;
		port_ = server_opts.port_;
	};

	bool operator==(const ConnectionInfo& server_opts) const {
		if (server_opts.endpoint_ != endpoint_) {
			return false;
		} else if (is_ipc()) {
			// For IPC, all options are compared.
			return (server_opts.dbname_ == dbname_);
		} else if (is_stream()) {
			// For TCP, all options are compared.
			return (server_opts.address_ == address_) &&
			       (server_opts.port_ == port_);
		}

		return true;
	}

	bool operator!=(const ConnectionInfo& server_opts) const {
		return !(*this == server_opts);
	}

	/**
	 * @brief Returns the value of the endpoint option.
	 * @return value of the endpoint.
	 */
	std::string_view endpoint() const { return endpoint_; }

	/**
	 * @brief Returns the value of the dbname option.
	 * @return value of the dbname.
	 */
	std::string_view dbname() const { return dbname_; }

	/**
	 * @brief Returns the value of the address option.
	 * @return value of the address.
	 */
	std::string_view address() const { return address_; }

	/**
	 * @brief Returns the value of the port option.
	 * @return value of the port.
	 */
	std::string_view port() const { return port_; }

	/**
	 * @brief Parse the server options.
	 * @param server_opts server options.
	 */
	void parse(const List* server_opts);

	/**
	 * @brief Returns whether the endpoint is IPC.
	 * @retval true if the endpoint is "ipc".
	 * @retval false otherwise.
	 */
	bool is_ipc() const { return endpoint_ == kValEndpointIpc; }

	/**
	 * @brief Returns whether the endpoint is stream.
	 * @retval true if the endpoint is "stream".
	 * @retval false otherwise.
	 */
	bool is_stream() const { return endpoint_ == kValEndpointTcp; }

private:
	/* Endpoint values */
	static constexpr const char* const kValEndpointIpc = "ipc";
	static constexpr const char* const kValEndpointTcp = "stream";
	/* Option names */
	static constexpr const char* const kOptEndpoint = "endpoint";
	static constexpr const char* const kOptDbname = "dbname";
	static constexpr const char* const kOptAddress = "address";
	static constexpr const char* const kOptPort = "port";
	/* Default values */
	static constexpr const char* const kDefEndpoint = kValEndpointIpc;
	static constexpr const char* const kDefDbname =
		ogawayama::common::param::SHARED_MEMORY_NAME.data();
	static constexpr const char* const kDefAddress = "";
	static constexpr const char* const kDefPort = "";

	std::string endpoint_;
	std::string dbname_;
	std::string address_;
	std::string port_;
	std::unordered_map<std::string, std::string*> opt_values_ = {
		{kOptEndpoint, &endpoint_},
		{kOptDbname, &dbname_},
		{kOptAddress, &address_},
		{kOptPort, &port_},
	};
};

class Tsurugi {
public:
    static ERROR_CODE start_transaction(Oid server_oid);
    static bool in_transaction_block() { return (transaction_ != nullptr); }
    static ERROR_CODE commit();
    static ERROR_CODE rollback();

    static bool exists_prepared_statement(std::string_view name);
#if 0  // Not used
    static ERROR_CODE prepare(std::string_view sql,
                              ogawayama::stub::placeholders_type& placeholders,
                              PreparedStatementPtr& prepared_statement);
    static ERROR_CODE prepare(std::string_view name, std::string_view statement,
                              ogawayama::stub::placeholders_type& placeholders);
#endif  // Not used
	static ERROR_CODE prepare(Oid server_oid, std::string_view statement,
							  ogawayama::stub::placeholders_type& placeholders);
	static ERROR_CODE deallocate(std::string_view prep_name);
	static void deallocate();
    static ERROR_CODE execute_query(std::string_view query);
    static ERROR_CODE execute_query(ogawayama::stub::parameters_type& params);
    static ERROR_CODE execute_statement(std::string_view statement,
                                        std::size_t& num_rows);
    static ERROR_CODE execute_statement(std::string_view prep_name,
                                        ogawayama::stub::parameters_type& params,
                                        std::size_t& num_rows);
    static ERROR_CODE execute_statement(ogawayama::stub::parameters_type& params, 
                                        std::size_t& num_rows);

    static void init_result_set() { result_set_.reset(); }
    static ResultSetPtr get_result_set() { return result_set_; }
    static ERROR_CODE result_set_next_row() { return result_set_->next(); }
    static void init_metadata() { metadata_ = nullptr; }
    static MetadataPtr get_metadata() { return metadata_; }

    static ERROR_CODE tsurugi_error(ogawayama::stub::tsurugi_error_code& code);
    static std::string get_error_detail(ERROR_CODE error);
    static std::string get_error_message(ERROR_CODE error_code);
    static void error_log2(int level, std::string_view message, ERROR_CODE error);
    static void error_log3(int level, std::string_view message, ERROR_CODE error);
    static void report_error(const char* message, ERROR_CODE error, const char* sql);
    static void report_error(const char* message, ERROR_CODE error, std::string_view sql);

	static ERROR_CODE get_list_tables(Oid server_oid, TableListPtr& table_list);
	static ERROR_CODE get_table_metadata(Oid server_oid, std::string_view table_name,
										 TableMetadataPtr& table_metadata);

	static std::optional<std::string_view> 
        convert_type_to_pg(jogasaki::proto::sql::common::AtomType tg_type);
    static std::pair<bool, Datum> convert_type_to_pg(ResultSetPtr result_set, 
                                                     const Oid pgtype);
    static ogawayama::stub::Metadata::ColumnType::Type 
        get_tg_column_type(const Oid pg_type);
    static ogawayama::stub::value_type convert_type_to_tg(const Oid pg_type, 
                                                          Datum value);
/*
    static ogawayama::stub::value_type
            get_tg_value_type(const Oid pg_type, Datum value);
*/
    Tsurugi() = delete;

private:
    static ERROR_CODE init(Oid server_oid);
    static bool is_initialized(Oid server_oid);

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
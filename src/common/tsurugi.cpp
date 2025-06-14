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
 *	@file	tsurugi.cpp
 */
#include <iostream>
#include <string>
#include <string_view>
#include <unordered_map>

#include <boost/property_tree/ini_parser.hpp>
#include <boost/filesystem.hpp>
#include <boost/format.hpp>

#include "ogawayama/stub/error_code.h"
#include "ogawayama/stub/api.h"
#include "tsurugi.h"

using namespace ogawayama;

namespace tg_metadata = jogasaki::proto::sql::common;

#ifdef __cplusplus
extern "C" {
#endif

#include "postgres.h"
#include "utils/elog.h"
#include "storage/proc.h"

#ifdef PG_MODULE_MAGIC
PG_MODULE_MAGIC;
#endif

#ifdef __cplusplus
}
#endif

StubPtr Tsurugi::stub_ = nullptr;
ConnectionPtr Tsurugi::connection_ = nullptr;
TransactionPtr Tsurugi::transaction_ = nullptr;

bool GetTransactionOption(boost::property_tree::ptree&);
bool IsTransactionProgress();

extern PreparedStatementPtr prepared_statement;
extern stub::parameters_type parameters;
extern std::string stmts_name;
extern std::map<std::string, PreparedStatementPtr> stored_prepare_statment;

/*
 *  get_shared_memory_name
 */
std::string get_shared_memory_name()
{
    std::string name(ogawayama::common::param::SHARED_MEMORY_NAME);  
    boost::property_tree::ptree pt;
    const boost::filesystem::path conf_file("tsurugi_fdw.conf");
    boost::system::error_code error;
    if (boost::filesystem::exists(conf_file, error)) 
    {
        boost::property_tree::read_ini("tsurugi_fdw.conf", pt);
        boost::optional<std::string> str = 
            pt.get_optional<std::string>("Configurations.SHARED_MEMORY_NAME");
        if (str) 
        {
            name = str.get();
        }
    }

    return name;
}

/*
 * init
 */
ERROR_CODE Tsurugi::init()
{
	ERROR_CODE error = ERROR_CODE::UNKNOWN;

    if (stub_ == nullptr)
	{
        std::string shared_memory_name(get_shared_memory_name());
		elog(DEBUG1, "Attempt to call make_stub(). (shared memory: %s)", 
            shared_memory_name.c_str());

		error = make_stub(stub_, shared_memory_name);
		if (error != ERROR_CODE::OK) 
        {
            elog(ERROR, "Failed to make the Ogawayama Stub. (error: %d)",
                (int) error);
            stub_ = nullptr;
			return error;
		}

		elog(LOG, "make_stub() succeeded. (shared memory: %s)",
            shared_memory_name.c_str());
	}

	if (connection_ == nullptr) 
    {
		elog(DEBUG1, "Attempt to call Stub::get_connection(). (pid: %d)", getpid());

		error = stub_->get_connection(getpid(), connection_);
		if (error != ERROR_CODE::OK)
		{
            elog(ERROR, "Failed to connect to Tsurugi. (error: %d)",
                (int) error);
            connection_ = nullptr;
			return error;
		}

        elog(LOG, "Stub::get_connection() succeeded. (pid: %d)", 
            getpid());
	}

	error = ERROR_CODE::OK;

	return error;
}

/*
 * get_connection
 */
ERROR_CODE Tsurugi::get_connection(stub::Connection** connection) 
{
    ERROR_CODE error = init();
    if (error == ERROR_CODE::OK)
    {
        *connection = connection_.get();
    }
    return error;
}

/*
 *	prepare
 */
ERROR_CODE Tsurugi::prepare(std::string_view sql, stub::placeholders_type& placeholders, PreparedStatementPtr& prepared_statement)
{
    ERROR_CODE error = ERROR_CODE::UNKNOWN;

    if (connection_ == nullptr)
    {
        elog(DEBUG1, "Attempt to call Tsurugi::init(). (pid: %d)", getpid());

        error = init();

        if (error != ERROR_CODE::OK)
        {
            elog(ERROR, "there can not connect to Tsurugi.");
            return error;
        }
    }

    elog(DEBUG1, "Attempt to call Connection::prepare(). (pid: %d)", getpid());
    elog(LOG, "sql = \n%s", sql.data());

    error = connection_->prepare(sql, placeholders, prepared_statement);

    elog(LOG, "Connection::prepare() done. (error: %d)", (int) error);

    return error;
}

/*
 *	start_transaction
 */
ERROR_CODE Tsurugi::start_transaction()
{
	ERROR_CODE error = ERROR_CODE::UNKNOWN;

	if (IsTransactionProgress()) {
	    elog(LOG, "there is tsurugi transaction block in progress.");
	    return ERROR_CODE::OK;
	}

    if (connection_ != nullptr)
    {
        boost::property_tree::ptree option;
        GetTransactionOption(option);

        elog(DEBUG1, "Attempt to call Connection::begin(). (pid: %d)", getpid());

        error = connection_->begin(option, transaction_);

        elog(LOG, "Connection::begin() done. (error: %d)", (int) error);
    }
    else
    {
        elog(WARNING, "there is no connection to Tsurugi.");
    }

	return error;
}

/*
 * execute_query
 */
ERROR_CODE 
Tsurugi::execute_query(std::string_view query, ResultSetPtr& result_set)
{
    ERROR_CODE error = ERROR_CODE::UNKNOWN;

    result_set = nullptr;
	if (prepared_statement.get() != nullptr) {
	    elog(DEBUG1, "Attempt to call Transaction::execute_query(prepared_statement). \n%s",
	        query.data());
	    error = transaction_->execute_query(prepared_statement, parameters, result_set);
	} else {
	    elog(DEBUG1, "Attempt to call Transaction::execute_query(query). \n%s",
	        query.data());
	    error = transaction_->execute_query(query, result_set);
	}

    elog(LOG, "execute_query() done. (error: %d)", (int) error);

    if (error != ERROR_CODE::OK) {
        if (stmts_name.size() != 0) {
            stored_prepare_statment[stmts_name] = std::move(prepared_statement);
            stmts_name = {};
            parameters = {};
        }
    }

    return error;
}

/*
 * execute_statement
 */
ERROR_CODE 
Tsurugi::execute_statement(std::string_view statement, std::size_t& num_rows)
{
    ERROR_CODE error = ERROR_CODE::UNKNOWN;

    if (transaction_ != nullptr)
    {
		if (prepared_statement.get() != nullptr) {
	        elog(DEBUG1, "tsurugi-fdw: Attempt to execute the prepared statement. \n%s",
	            statement.data());
	        error = transaction_->execute_statement(prepared_statement, parameters, num_rows);
		} else {
	        elog(DEBUG1, "tsurugi-fdw: Attempt to execute the statement. \n%s",
	            statement.data());
	        error = transaction_->execute_statement(statement, num_rows);
		}

        elog(LOG, "tsurugi-fdw: execute_statement() done. (error: %d)",
            (int) error);

        if (error != ERROR_CODE::OK) {
            if (stmts_name.size() != 0) {
                stored_prepare_statment[stmts_name] = std::move(prepared_statement);
                stmts_name = {};
                parameters = {};
            }
        }
    }
    else
    {
        elog(WARNING, "there is no transaction in progress.");
      	error = ERROR_CODE::NO_TRANSACTION;
    }

    return error;
}

/*
 * commit
 */
ERROR_CODE Tsurugi::commit()
{
    ERROR_CODE error = ERROR_CODE::UNKNOWN;

	if (IsTransactionProgress()) {
	    elog(LOG, "there is tsurugi transaction block in progress.");
	    return ERROR_CODE::OK;
	}

    if (transaction_ != nullptr) 
    {
        elog(DEBUG1, "Attempt to call Transaction::commit().");

        error = transaction_->commit();
        transaction_ = nullptr;

        elog(LOG, "Transaction::commit() done. (error: %d)", (int) error);
    }
    else
    {
        elog(WARNING, "there is no transaction in progress");
        error = ERROR_CODE::NO_TRANSACTION;
    }

    return error;
}

/*
 * rollback
 */
ERROR_CODE Tsurugi::rollback()
{
    ERROR_CODE error = ERROR_CODE::UNKNOWN;

	if (IsTransactionProgress()) {
	    elog(LOG, "there is tsurugi transaction block in progress.");
	    return ERROR_CODE::OK;
	}

    if (transaction_ != nullptr) 
    {
        elog(DEBUG1, "Attempt to call Transaction::rollback().");

        error = transaction_->rollback();
        transaction_ = nullptr;

        elog(LOG, "Transaction::rollback() done. (error: %d)", (int) error);
    }
    else
    {
        elog(WARNING, "there is no transaction in progress.");
        error = ERROR_CODE::NO_TRANSACTION;
    }

    return error;
}

/*
 *	@brief:	
 */
ERROR_CODE Tsurugi::begin(stub::Transaction** transaction)
{
	ERROR_CODE error = ERROR_CODE::UNKNOWN;

	if (IsTransactionProgress()) {
		elog(DEBUG1, "begin : there is tsurugi transaction block in progress.");
		return ERROR_CODE::OK;
	}

	if (stub_ == nullptr) {
		error = init();
		if (error != ERROR_CODE::OK) {
			std::cerr << "init() failed. " << (int) error << std::endl;
			return error;
		}
	}

	if (connection_ == nullptr) {
		ERROR_CODE error = stub_->get_connection(getpid() , connection_);
		if (error != ERROR_CODE::OK)
		{
			std::cerr << "Failed to connect to Tsurugi. " << (int) error << std::endl;
			return error;
		}
	}

	if (transaction_ == nullptr) {
		boost::property_tree::ptree option;
		GetTransactionOption(option);
		ERROR_CODE error = connection_->begin(option, transaction_);
		if (error != ERROR_CODE::OK)
		{
			std::cerr << "Connection::begin() failed. " << (int) error << std::endl;
			return error;
		}
	}
	*transaction = transaction_.get();

	elog(DEBUG1, "Transaction started.");
	error = ERROR_CODE::OK;

	return error;
}

/*
 * 	@brief: 
 */
void Tsurugi::end()
{
	if (IsTransactionProgress()) {
		elog(DEBUG1, "end : there is tsurugi transaction block in progress.");
		return;
	}
	transaction_ = nullptr;
}

/*
 * @brief request list tables and get table_list class.
 * @param table_list returns a table_list class
 * @return error code defined in error_code.h
 */
ERROR_CODE Tsurugi::get_list_tables(TableListPtr& table_list)
{
	ERROR_CODE error = ERROR_CODE::UNKNOWN;

	if (connection_ == nullptr)
	{
		elog(DEBUG1, "Attempt to call Tsurugi::init(). (pid: %d)", getpid());

		error = init();
		if (error != ERROR_CODE::OK)
		{
			ereport(ERROR,
				(errcode(ERRCODE_FDW_UNABLE_TO_CREATE_REPLY),
				 errmsg(R"(error connecting to server)"),
				 errdetail("%s", get_error_message(error).c_str())));
		}
	}

	elog(DEBUG1, "Attempt to call Connection::get_list_tables(). (pid: %d)", getpid());

	/* Get a list of table names from Tsurugi. */
	error = connection_->get_list_tables(table_list);

	elog(LOG, "Connection::get_list_tables() done. (error: %d)", (int) error);

	return error;
}

/*
 * @brief request table metadata and get TableMetadata class.
 * @param table_name the table name
 * @param table_metadata returns a table_metadata class
 * @return error code defined in error_code.h
 */
ERROR_CODE
Tsurugi::get_table_metadata(std::string_view table_name, TableMetadataPtr& table_metadata)
{
	ERROR_CODE error = ERROR_CODE::UNKNOWN;

	if (connection_ == nullptr)
	{
		elog(DEBUG1, "Attempt to call Tsurugi::init(). (pid: %d)", getpid());

		error = init();
		if (error != ERROR_CODE::OK)
		{
			ereport(ERROR,
				(errcode(ERRCODE_CONNECTION_FAILURE),
				 errmsg("error connecting to server"),
				 errdetail("%s", get_error_message(error).c_str())));
		}
	}

	elog(DEBUG1, "Attempt to call Connection::get_table_metadata(). (pid: %d)", getpid());

	/* Get table metadata from Tsurugi. */
	error = connection_->get_table_metadata(std::string(table_name), table_metadata);

	elog(LOG, "Connection::get_table_metadata() done. (error: %d)", (int) error);

	return error;
}

/*
 * @brief convert Tsurugi data types to PostgreSQL data types.
 * @param tg_type tsurugi data type (AtomType)
 * @return std::optional of PostgreSQL data type
 */
std::optional<std::string_view> Tsurugi::convert_type_to_pg(
		jogasaki::proto::sql::common::AtomType tg_type)
{
	static const std::unordered_map<tg_metadata::AtomType, std::string> type_mapping = {
		{tg_metadata::AtomType::INT4, "integer"},
		{tg_metadata::AtomType::INT8, "bigint"},
		{tg_metadata::AtomType::FLOAT4, "real"},
		{tg_metadata::AtomType::FLOAT8, "double precision"},
		{tg_metadata::AtomType::DECIMAL, "numeric"},
		{tg_metadata::AtomType::CHARACTER, "text"},
		{tg_metadata::AtomType::DATE, "date"},
		{tg_metadata::AtomType::TIME_OF_DAY, "time"},
		{tg_metadata::AtomType::TIME_POINT, "timestamp"},
		{tg_metadata::AtomType::TIME_OF_DAY_WITH_TIME_ZONE, "time with time zone"},
		{tg_metadata::AtomType::TIME_POINT_WITH_TIME_ZONE, "timestamp with time zone"},
	};

	auto pg_type = type_mapping.find(tg_type);
	if (pg_type != type_mapping.end())
	{
		return pg_type->second;
	}

	return std::nullopt;
}

/*
 *	tsurugi_error
 */
ERROR_CODE Tsurugi::tsurugi_error(stub::tsurugi_error_code& code)
{
	ERROR_CODE error = ERROR_CODE::UNKNOWN;
	if (connection_ != nullptr)
	{
		elog(DEBUG1, "Attempt to call Connection::tsurugi_error(). (pid: %d)", getpid());
		error = connection_->tsurugi_error(code);
		elog(LOG, "Connection::tsurugi_error() done. (error: %d)", (int) error);
	}
	else
	{
		elog(ERROR, "tsurugi_error: there is no connection in progress.");
	}
	return error;
}

/*
 *	get_error_detail
 */
std::string Tsurugi::get_error_detail(ERROR_CODE error)
{
	std::string error_detail = "";

	if (error == ERROR_CODE::SERVER_ERROR)
	{
		ERROR_CODE tsurugi_error = ERROR_CODE::UNKNOWN;
		stub::tsurugi_error_code code{};
		tsurugi_error = Tsurugi::tsurugi_error(code);
		if (tsurugi_error == ERROR_CODE::OK)
		{
			elog(LOG, "ERROR_CODE::SERVER_ERROR\n\t"
					  "tsurugi_error_code.type: %d\n\t"
					  "                   code: %d\n\t"
					  "                   name: %s\n\t"
					  "                 detail: %s\n\t"
					  "      supplemental_text: %s",
						(int)code.type, code.code, code.name.c_str(),
						code.detail.c_str(), code.supplemental_text.c_str());

			std::string code_str = std::to_string(code.code);
			size_t digits = 5;
			int precision = digits - std::min(digits, code_str.size());
			code_str.insert(0, precision, '0');

			error_detail += "Tsurugi Server " + code.name;
			switch (code.type)
			{
				case stub::tsurugi_error_code::tsurugi_error_type::sql_error:
					error_detail += " (SQL-" + code_str + ": " + code.detail + ")";
					break;
				case stub::tsurugi_error_code::tsurugi_error_type::framework_error:
					error_detail += " (SCD-" + code_str + ": " + code.detail + ")";
					break;
				default:
					elog(ERROR, "Tsurugi Server Error (type: %d)", (int)code.type);
					break;
			}
		}
		else
		{
			elog(ERROR, "Failed to retrieve error information from Tsurugi. (%d)", (int) tsurugi_error);
		}
	}
	return error_detail;
}

/*
	get detail message of tsurugi server error.
*/
std::string Tsurugi::get_error_message(ERROR_CODE error_code)
{
	std::string message = "No detail message.";

	elog(LOG, "Tsurugi::get_error_message() started");

	if (error_code != ERROR_CODE::SERVER_ERROR)
	{
		elog(LOG, "Error code is not SERVER_ERROR. (error code: %s)", 
			stub::error_name(error_code).data());
		return message;
	}

	if (connection_ == nullptr)
	{
		elog(LOG, "There is no connection for Tsurugi.");
		return message;
	}

	//  get error message from Tsurugi.
	stub::tsurugi_error_code error{};
	ERROR_CODE ret_code = connection_->tsurugi_error(error);
	if (ret_code == ERROR_CODE::OK)
	{
		elog(LOG, "ERROR_CODE::SERVER_ERROR\n\t"
					"tsurugi_error_code.type: %d\n\t"
					"                   code: %d\n\t"
					"                   name: %s\n\t"
					"                 detail: %s\n\t"
					"      supplemental_text: %s",
					(int) error.type, error.code, error.name.c_str(),
					error.detail.c_str(), error.supplemental_text.c_str());

		std::string detail_code;
		switch (error.type)
		{
			case stub::tsurugi_error_code::tsurugi_error_type::sql_error:
				detail_code = "SQL-" + (boost::format("%05d") % error.code).str();
				break;
			case stub::tsurugi_error_code::tsurugi_error_type::framework_error:
				detail_code = "SCD-" + (boost::format("%05d") % error.code).str();
				break;
			default:
				elog(WARNING, "Unknown error type. (type: %d)", (int) error.type);
				detail_code = "UNKNOWN-" + (boost::format("%05d") % error.code).str();
				break;
		}
		// build message.
		message = "Tsurugi Server Error: " + error.name 
									+ " (" + detail_code + ": " + error.detail + ")";
	}
	else
	{
		elog(ERROR, "It failed to get Tsurugi Server Error. (erro code: %s)", 
				stub::error_name(ret_code).data());
	}

	return message;
}

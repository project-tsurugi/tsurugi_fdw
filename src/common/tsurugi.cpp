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

#include <boost/multiprecision/cpp_int.hpp>
#include <boost/property_tree/ini_parser.hpp>
#include <boost/filesystem.hpp>
#include <boost/format.hpp>

#include "common/tsurugi.h"
#include "ogawayama/stub/error_code.h"
#include "ogawayama/stub/api.h"
#include "common/tg_numeric.h"

using namespace ogawayama;

namespace tg_metadata = jogasaki::proto::sql::common;

#ifdef __cplusplus
extern "C" {
#endif
#include "access/htup_details.h"
#include "catalog/pg_type.h"
#include "foreign/foreign.h"
#include "storage/proc.h"
#include "utils/builtins.h"
#include "utils/date.h"
#include "utils/datetime.h"
#include "utils/elog.h"
#include "utils/lsyscache.h"
#include "utils/numeric.h"
#include "utils/syscache.h"
#include "utils/timestamp.h"
#ifdef __cplusplus
}
#endif

StubPtr Tsurugi::stub_ = nullptr;
ConnectionPtr Tsurugi::connection_ = nullptr;
TransactionPtr Tsurugi::transaction_ = nullptr;
ResultSetPtr Tsurugi::result_set_ = nullptr;
MetadataPtr Tsurugi::metadata_ = nullptr;
std::unordered_map<std::string, PreparedStatementPtr> Tsurugi::prepared_statements_;
PreparedStatementPtr Tsurugi::prepared_statement_ = nullptr;
ConnectionInfo connection_info_;

bool GetTransactionOption(boost::property_tree::ptree&);



std::string get_shared_memory_name()
{
	std::string name{ogawayama::common::param::SHARED_MEMORY_NAME};
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

/**
 * @brief Returns key-value pairs from the ListCell format options.
 * @param list option element.
 * @return pair of key and value.
 */
std::pair<std::string, std::string> parse_option(const ListCell* list_cell) {
	auto elem = (DefElem*) lfirst(list_cell);
	auto opt_key = std::string(elem->defname);
	auto opt_val = std::string(strVal(elem->arg));

	std::transform(opt_key.begin(), opt_key.end(), opt_key.begin(),
					[](unsigned char c) { return std::tolower(c); });

	return {opt_key, opt_val};
}

/**
 * @brief Parse the server options.
 * @param server_opts server options.
 */
void ConnectionInfo::parse(const List* server_opts) {
	ListCell *cell;

	/* Initialize. */
	endpoint_ = kDefEndpoint;
	dbname_ = get_shared_memory_name();
	address_ = kDefAddress;
	port_ = kDefPort;

	/* Get foreign server options. */
	foreach (cell, server_opts) {
		auto [key, value] = parse_option(cell);

		auto it = opt_values_.find(key);
		if (it != opt_values_.end()) {
			*(it->second) = value;
		}
	}
}

/**
 *  @brief Checks whether the ogawayama stub has been initialized.
 *  @param server_oid oid of tsurugi server.
 *  @retval true  if the stub is already initialized
 *  @retval false if the stub has not been initialized yet
 */
bool Tsurugi::is_initialized(Oid server_oid)
{
	elog(DEBUG1, "tsurugi_fdw : %s(serverid: %u)", __func__, server_oid);

	/* Check if it is not connected. */
	if ((stub_ == nullptr) || (connection_ == nullptr))
	{
		elog(DEBUG4, "Not connected to Tsurugi.");
		return false;
	}

	/* Checks if it is a transaction block in progress. */
	if (transaction_ != nullptr)
	{
		elog(DEBUG4, "There is a transaction block in progress.");
		return true;
	}

	/* Get ForeignServer object from server OID. */
	auto server = GetForeignServer(server_oid);
	assert(server != nullptr);

	/* Get the latest connection information. */
	ConnectionInfo now_sever_opts(server->options);

	/* Check that the connection information matches. */
	if (connection_info_ != now_sever_opts)
	{
		elog(DEBUG4, "Connection information has been changed.");
		return false;
	}

	elog(DEBUG4, "Already connected to the database.");
	return true;
}

/**
 *  @brief 	Initialize ogawayama stub.
 * 
 *  If connected to the tsurugi database, it will disconnect and attempt to reconnect.
 * 
 *  @param 	server_oid oid of tsurugi server.
 *  @return	error code of ogawayama.
 */
ERROR_CODE Tsurugi::init(Oid server_oid)
{
	auto error{ERROR_CODE::UNKNOWN};

	elog(DEBUG1, "tsurugi_fdw : %s(serverid: %u)", __func__, server_oid);

	/* Get ForeignServer object from server OID. */
	auto server = GetForeignServer(server_oid);
	assert(server != nullptr);

	ConnectionInfo now_sever_opts(server->options);

	/* Set foreign server options. */
	connection_info_ = now_sever_opts;

	if (connection_info_.is_ipc()) {
		elog(DEBUG2, R"(endpoint="%s", dbname="%s")",
				connection_info_.endpoint().data(), connection_info_.dbname().data());
	} else if (connection_info_.is_stream()) {
		elog(DEBUG2, R"(endpoint="%s", host="%s", port="%s")",
				connection_info_.endpoint().data(), connection_info_.address().data(),
				connection_info_.port().data());
	}

	/* Release connection-related resources. */
	stub_ = nullptr;
	connection_ = nullptr;

	/*
	 * Currently, only "ipc" is supported.
	 * "stream" is an option for future use, so even if you specify it,
	 * it will be an "ipc" connection.
	 */

	elog(DEBUG1, "tsurugi_fdw : Attempt to call make_stub(). (name: %s)",
			connection_info_.dbname().data());

	error = make_stub(stub_, connection_info_.dbname());
	Tsurugi::error_log2(DEBUG1, "make_stub() is done.", error);
	if (error != ERROR_CODE::OK)
	{
		stub_ = nullptr;
		Tsurugi::report_error("Failed to make shared memory for Tsurugi.", 
			error, connection_info_.dbname());
	}

	elog(DEBUG1, "tsurugi_fdw : Attempt to call Stub::get_connection(). (pid: %d)", getpid());

	error = stub_->get_connection(getpid(), connection_);
	Tsurugi::error_log2(DEBUG1, "Stub::get_connection() is done.", error);

	if (error != ERROR_CODE::OK)
	{
		connection_ = nullptr;
		Tsurugi::report_error("Failed to connect to Tsurugi.", error, nullptr);
	}
	transaction_ = nullptr;

	return ERROR_CODE::OK;
}

/**
 *  @brief 	Begin a transaction of tsurugidb.
 *  @param 	server_oid oid of tsurugi server.
 *  @return	error code of ogawayama.
 */
ERROR_CODE Tsurugi::start_transaction(Oid server_oid)
{
	auto error{ERROR_CODE::UNKNOWN};

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	if (!Tsurugi::is_initialized(server_oid))
	{
		/* Initializing connection to tsurugi server. */
		auto error = Tsurugi::init(server_oid);
		if (error != ERROR_CODE::OK) {
			ereport(ERROR, (errcode(ERRCODE_FDW_ERROR),
							errmsg("%s", Tsurugi::get_error_message(error).c_str())));
		}
	}

	if (transaction_ != nullptr) {
		elog(NOTICE, "tsurugi_fdw : There is already transaction block in progress.");
		return ERROR_CODE::OK;
	}

	boost::property_tree::ptree option;
	GetTransactionOption(option);

	elog(DEBUG1, "tsurugi_fdw : Attempt to call Connection::begin(). (pid: %d)", 
		getpid());

	// Start the transaction.
	error = connection_->begin(option, transaction_);
	Tsurugi::error_log2(DEBUG1, "Connection::begin() is done.", error);

	return error;
}

/**
 *  @brief 	commit a transaction on tsurugidb.
 *  @param 	none.
 *  @return	error code of ogawayama.
 */
ERROR_CODE Tsurugi::commit()
{
    auto error{ERROR_CODE::UNKNOWN};

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

    if (transaction_ != nullptr) 
    {
        elog(DEBUG1, "tsurugi_fdw : Attempt to call Transaction::commit().");
		/* Commits the transaction. */
        error = transaction_->commit();
		Tsurugi::error_log2(DEBUG1, "Transaction::commit() is done.", error);
        transaction_ = nullptr;
    }
    else
    {
        elog(WARNING, "There is no transaction in progress");
        error = ERROR_CODE::NO_TRANSACTION;
    }

	return error;
}

/**
 *  @brief 	Rollback a transaction on tsurugidb.
 *  @param 	none.
 *  @return	error code of ogawayama.
 */
ERROR_CODE Tsurugi::rollback()
{
    auto error{ERROR_CODE::UNKNOWN};

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

    if (transaction_ != nullptr) 
    {
        elog(DEBUG1, "tsurugi_fdw : Attempt to call Transaction::rollback().");
		/* Rolls back the transaction. */
        error = transaction_->rollback();
		Tsurugi::error_log2(DEBUG1, "Transaction::rollback() is done.", error);
        transaction_ = nullptr;
    }
    else
    {
        elog(WARNING, "There is no transaction in progress.");
        error = ERROR_CODE::NO_TRANSACTION;
    }

    return error;
}

/**
 *  @brief 	Confirm the prepared statement exists.
 *  @param 	(prep_name) prepare name.
 *  @return	Return true if exists.
 */
bool Tsurugi::exists_prepared_statement(std::string_view prep_name)
{
	elog(DEBUG1, "tsurugi_fdw : %s : name: %s", __func__, prep_name.data());

	bool exists{false};

	auto ite = prepared_statements_.find(prep_name.data());
	if (ite != prepared_statements_.end())
	{
		elog(DEBUG3, "Prepared statement \"%s\" exists.", prep_name.data());
		exists = true;
	}

	return exists;
}

#if 0  // Not used
/**
 *  @brief 	Prepare a statement to tsurugidb.
 *  @param 	(prep_name)	prepare name.
 * 			(statement)	SQL statement.
 * 			(placeholders) information of placeholders in statement.
 *  @return	error code of ogawayama.
 */
ERROR_CODE Tsurugi::prepare(std::string_view prep_name, std::string_view statement,
						ogawayama::stub::placeholders_type& placeholders)
{
    auto error{ERROR_CODE::UNKNOWN};

	elog(DEBUG1, "tsurugi_fdw : %s : name: %s", __func__, prep_name.data());

    if (connection_ == nullptr) 
		Tsurugi::init();

	auto ite = prepared_statements_.find(prep_name.data());
	if (ite != prepared_statements_.end())
	{
		elog(WARNING, "Prepared statement \"%s\" already exists.", 
			prep_name.data());
		return ERROR_CODE::INVALID_PARAMETER;
	}

	elog(DEBUG1, "tsurugi_fdw : Attempt to call Connection::prepare().\nname: %s, \nstatement:\n%s", 
		prep_name.data(), statement.data());

	//	Prepare statement.
	PreparedStatementPtr pstmt{};
    error = connection_->prepare(statement, placeholders, pstmt);
	Tsurugi::error_log2(LOG, "Connection::prepare() is done.", error);

	if (error == ERROR_CODE::OK)
	{	
		// Add statement to prepared statements list.
		prepared_statements_.emplace(prep_name, std::move(pstmt));
	}

    return error;	
}
#endif  // Not used

/**
 *  @brief 	Prepare astatement to tsurugidb without name.
 *  @param 	(server_oid) oid of tsurugi server.
 *  @param 	(statement) SQL statement
 *  @param 	(placeholders) information of placeholders in statement.
 *  @return	error code of ogawayama.
 *  @note	Prepared statement has a one-time lifespan.
 */
ERROR_CODE Tsurugi::prepare(Oid server_oid, std::string_view statement,
	            	ogawayama::stub::placeholders_type& placeholders)
{
	auto error{ERROR_CODE::UNKNOWN};

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	if (!Tsurugi::is_initialized(server_oid))
	{
		/* Initializing connection to tsurugi server. */
		auto error = Tsurugi::init(server_oid);
		if (error != ERROR_CODE::OK) {
			ereport(ERROR, (errcode(ERRCODE_FDW_ERROR),
							errmsg("%s", Tsurugi::get_error_message(error).c_str())));
		}
	}

	Tsurugi::deallocate();
	elog(DEBUG1, "tsurugi_fdw : Attempt to call Connection::prepare().\nstatement: \n%s", 
		statement.data());

	//	Prepare the statement.
	error = connection_->prepare(statement, placeholders, prepared_statement_);
	Tsurugi::error_log2(DEBUG1, "Connection::prepare() is done.", error);

	return error;
}

/**
 *  @brief 	Deallocate a prepared statement.
 *  @param 	(prep_name)	prepare name.
 *  @return	error code of ogawayama.
 */
ERROR_CODE Tsurugi::deallocate(std::string_view prep_name)
{
	auto error{ERROR_CODE::OK};

	elog(DEBUG1, "tsurugi_fdw : %s : prep_name:%s", __func__, prep_name.data());

	auto ite = prepared_statements_.find(prep_name.data());
	if (ite != prepared_statements_.end())
	{
		ite->second = nullptr;
		prepared_statements_.erase(ite);
		error = ERROR_CODE::OK;
	}
	else
	{
		elog(WARNING, "Prepared statement \"%s\" does not exist.", 
			prep_name.data());
		error = ERROR_CODE::INVALID_PARAMETER;
	}

	return error;
}

/**
 *  @brief 	Deallocate a unnamed prepared statement.
 *  @param	none.
 *  @return	none.
 */
void Tsurugi::deallocate()
{
	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	prepared_statement_ = nullptr;
}

/**
 *  @brief 	Execute a query on tsurugidb.
 *  @param 	(query)	SQL query.
 *  @return	error code of ogawayama.
 */
ERROR_CODE 
Tsurugi::execute_query(std::string_view query)
{
    auto error{ERROR_CODE::UNKNOWN};

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	if (transaction_ != nullptr)
	{
		elog(DEBUG1, 
			"tsurugi_fdw : Attempt to call Transaction::execute_query(). \nquery:\n%s", 
			query.data());
		result_set_ = nullptr;
		error = transaction_->execute_query(query, result_set_);
		Tsurugi::error_log2(DEBUG1, "Transaction::execute_query() is done.", error);
	}
	else
	{
        elog(WARNING, "There is no transaction in progress.");
      	error = ERROR_CODE::NO_TRANSACTION;
	}

    return error;
}

/**
 *  @brief 	Execute a prepared statement on tsurugidb.
 *  @param 	(query)	SQL query.
 * 			(params) parameters for prepared statement.
 *  @return	error code of ogawayama.
 */
ERROR_CODE 
Tsurugi::execute_query(ogawayama::stub::parameters_type& params)
{
    auto error{ERROR_CODE::UNKNOWN};

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	if (transaction_ != nullptr)
	{
		elog(DEBUG1, "tsurugi_fdw : Attempt to call Transaction::execute_query().");
		result_set_ = nullptr;
		error = transaction_->execute_query(prepared_statement_, params, result_set_);
		Tsurugi::error_log2(DEBUG1, "Transaction::execute_query() is done.", error);
	}
	else
	{
        elog(WARNING, "There is no transaction in progress.");
      	error = ERROR_CODE::NO_TRANSACTION;
	}

    return error;
}

/**
 *  @brief 	Execute a statement on tsurugidb.
 *  @param 	(statement) SQL statement.
 * 			(num_rows) number of rows updated. 
 *  @return	error code of ogawayama.
 */
ERROR_CODE 
Tsurugi::execute_statement(std::string_view statement, std::size_t& num_rows)
{
    auto error{ERROR_CODE::UNKNOWN};

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

    if (transaction_ != nullptr)
    {
		elog(DEBUG1, "tsurugi_fdw : Attempt to execute Transaction::execute_statement()." \
					"\nstatement:\n%s", statement.data());
		// Execute a statement.
		error = transaction_->execute_statement(statement, num_rows);
		Tsurugi::error_log2(DEBUG1, "Transaction::execute_statement() is done.", error);
    }
    else
    {
        elog(WARNING, "There is no transaction in progress.");
      	error = ERROR_CODE::NO_TRANSACTION;
    }

    return error;
}

/**
 *  @brief 	Execute a prepared statement on tsurugidb.
 *  @param 	(prep_name) prepared object name.
 * 			(params) parameters of prepared statement.
 * 			(num_rows) number of rows updated.
 *  @return	error code of ogawayama.
 */
ERROR_CODE 
Tsurugi::execute_statement(std::string_view prep_name, 
							ogawayama::stub::parameters_type& params, 
							std::size_t& num_rows)
{
    auto error{ERROR_CODE::UNKNOWN};

	elog(DEBUG1, "tsurugi_fdw : %s : prep_name:%s ", __func__, prep_name.data());

    if (transaction_ != nullptr)
    {
		// find a prepared object.
		auto ite = prepared_statements_.find(prep_name.data());
		if (ite == prepared_statements_.end())
		{
			elog(WARNING, "Preapred statement \"%s\" does not exist.", 
				prep_name.data());
			return ERROR_CODE::INVALID_PARAMETER;
		}
		elog(DEBUG1, "tsurugi_fdw : Attempt to call Transaction::execute_statement()." \
			" prep_name: %s", ite->first.data());

		// Execute a statement.
		error = transaction_->execute_statement(ite->second, params, num_rows);
		Tsurugi::error_log2(DEBUG1, "Transaction::execute_statement() is done.", error);
	}
    else
    {
        elog(WARNING, "There is no transaction in progress.");
      	error = ERROR_CODE::NO_TRANSACTION;
    }

    return error;
}

/**
 *  @brief 	Execute a unnamed preapred statement.
 *  @param 	(params) parameters of prepared statement.
 * 			(num_rows) number of rows updated.
 *  @return	error code of ogawayama.
 */
ERROR_CODE 
Tsurugi::execute_statement(ogawayama::stub::parameters_type& params, 
							std::size_t& num_rows)
{
    auto error{ERROR_CODE::UNKNOWN};

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

    if (transaction_ != nullptr)
    {
		elog(DEBUG1, "tsurugi_fdw : Attempt to call Transaction::execute_statement().");	

		// Execute a statement.
		error = transaction_->execute_statement(prepared_statement_, params, num_rows);
		Tsurugi::error_log2(DEBUG1, "Transaction::execute_statement() is done.", error);
	}
    else
    {
        elog(WARNING, "There is no transaction in progress.");
      	error = ERROR_CODE::NO_TRANSACTION;
    }

    return error;
}

/**
 * @brief request list tables and get table_list class.
 * @param server_oid oid of tsurugi server.
 * @param table_list returns a table_list class
 * @return error code defined in error_code.h
 */
ERROR_CODE
Tsurugi::get_list_tables(Oid server_oid, TableListPtr& table_list)
{
	ERROR_CODE error = ERROR_CODE::UNKNOWN;

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	if (!Tsurugi::is_initialized(server_oid))
	{
		/* Initializing connection to tsurugi server. */
		auto error = Tsurugi::init(server_oid);
		if (error != ERROR_CODE::OK) {
			ereport(ERROR, (errcode(ERRCODE_FDW_ERROR),
							errmsg("%s", Tsurugi::get_error_message(error).c_str())));
		}
	}

	elog(DEBUG1, "tsurugi_fdw : Attempt to call Connection::get_list_tables(). (pid: %d)",
		 getpid());

	/* Get a list of table names from Tsurugi. */
	error = connection_->get_list_tables(table_list);

	elog(DEBUG1, "Connection::get_list_tables() done. (error: %d)", (int) error);

	return error;
}

/**
 * @brief request table metadata and get TableMetadata class.
 * @param server_oid oid of tsurugi server.
 * @param table_name the table name
 * @param table_metadata returns a table_metadata class
 * @return error code defined in error_code.h
 */
ERROR_CODE
Tsurugi::get_table_metadata(Oid server_oid, std::string_view table_name,
							TableMetadataPtr& table_metadata)
{
	ERROR_CODE error = ERROR_CODE::UNKNOWN;

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	if (!Tsurugi::is_initialized(server_oid))
	{
		/* Initializing connection to tsurugi server. */
		auto error = Tsurugi::init(server_oid);
		if (error != ERROR_CODE::OK) {
			ereport(ERROR, (errcode(ERRCODE_FDW_ERROR),
							errmsg("%s", Tsurugi::get_error_message(error).c_str())));
		}
	}

	elog(DEBUG1, "Attempt to call Connection::get_table_metadata(). (pid: %d)", getpid());

	/* Get table metadata from Tsurugi. */
	error = connection_->get_table_metadata(std::string(table_name), table_metadata);

	elog(DEBUG1, "Connection::get_table_metadata() done. (error: %d)", (int) error);

	return error;
}

/**
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
		elog(DEBUG1, "Connection::tsurugi_error() done. (error: %d)", (int) error);
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
			elog(DEBUG1, "ERROR_CODE::SERVER_ERROR\n\t"
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

/**
 *  @brief 	Get detail message of tsurugi server.
 *  @param 	(error_code) error code of ogawayama.
 *  @return	detail error message.
 */
std::string Tsurugi::get_error_message(ERROR_CODE error_code)
{
	std::string message = "No detail message.";

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	if (error_code != ERROR_CODE::SERVER_ERROR)
	{
		Tsurugi::error_log2(LOG, "Error code is not SERVER_ERROR.", error_code);
		return message;
	}

	if (connection_ == nullptr)
	{
		elog(DEBUG1, "tsurugi_fdw : There is no connection to Tsurugi.");
		return message;
	}

	//  get error message from Tsurugi.
	stub::tsurugi_error_code error{};
	auto ret_code = connection_->tsurugi_error(error);
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
		message = "Tsurugi Error: " + error.name 
					+ " (" + detail_code + ": " + error.detail + ")";
	}
	else
	{
		Tsurugi::error_log2(ERROR, "Failed to get Tsurugi Server Error.", ret_code);
	}

	return message;
}

/**
 *  @brief 	Output error log which has a error message and error code.
 *  @param 	(level) log level.
 * 			(message) error message.
 * 			(error) error code of ogawayama.
 *  @return	none.
 */
void Tsurugi::error_log2(int level, std::string_view message, ERROR_CODE error)
{
	std::string ext_message{"tsurugi_fdw : "};

	ext_message += message;
	ext_message += " (error: %s{%d})";
	elog(level, ext_message.data(),  stub::error_name(error).data(), (int)error);	
}

/**
 *  @brief 	Output error log which has a error message, error code and a detail message.
 *  @param 	(level) log level.
 * 			(message) error message.
 * 			(error) error code of ogawayama.
 *  @return	none.
 */
void Tsurugi::error_log3(int level, std::string_view message, ERROR_CODE error)
{
	std::string ext_message{"tsurugi_fdw : "};

	ext_message += message;
	ext_message += " (error: %s{%d})\n%s";
	elog(level, ext_message.data(), stub::error_name(error).data(), (int)error, 
		Tsurugi::get_error_message(error).data());	
}

/**
 *  @brief 	Report the error information of tsurugi_fdw.
 *  @param 	(message) error message.
 * 			(error) error code.
 * 			(sql) the statement that was attempted to be sent to tsurugidb.
 *  @return	
 */
void 
Tsurugi::report_error(const char* message, ERROR_CODE error, const char* sql)
{
	int			sqlstate = ERRCODE_FDW_ERROR;
	std::string	detail = Tsurugi::get_error_message(error);

	ereport(ERROR,
			(errcode(sqlstate),
			 errmsg("Failed to execute remote SQL."),
			 errcontext("SQL query: %s", sql ? sql : ""),
			 errhint("%s error: %s(%d)\n%s", 
					message, stub::error_name(error).data(), (int) error, 
					detail.data())
			));	
}

/**
 *  @brief 	Report the error information of tsurugi_fdw.
 *  @param 	(message) error message.
 * 			(error) error code.
 * 			(sql) the statement that was attempted to be sent to tsurugidb.
 *  @return	
 */
void 
Tsurugi::report_error(const char* message, ERROR_CODE error, std::string_view sql)
{
	Tsurugi::report_error(message, error, sql.data());
}

/**
 *  @brief 	Convert a data type id from PostgreSQL to tsurugidb.
 *  @param 	(pg_type) oid of PostgreSQL data type.
 *  @return	data type id of tsurugidb.
 */
ogawayama::stub::Metadata::ColumnType::Type 
Tsurugi::get_tg_column_type(const Oid pg_type)
{
	auto tg_type = stub::Metadata::ColumnType::Type::NULL_VALUE;

	elog(DEBUG5, "tsurugi_fdw : %s : pg_type: %d", __func__, (int) pg_type);

	switch (pg_type)
	{
		case INT2OID:
			tg_type = stub::Metadata::ColumnType::Type::INT16;
			break;
		case INT4OID:
			tg_type = stub::Metadata::ColumnType::Type::INT32;
			break;
		case INT8OID:
			tg_type = stub::Metadata::ColumnType::Type::INT64;
			break;
		case FLOAT4OID:
			tg_type = stub::Metadata::ColumnType::Type::FLOAT32;
			break;
		case FLOAT8OID:
			tg_type = stub::Metadata::ColumnType::Type::FLOAT64;
			break;
		case BPCHAROID:
		case VARCHAROID:
		case TEXTOID:
			tg_type = stub::Metadata::ColumnType::Type::TEXT;
			break;
		case DATEOID:
			tg_type = stub::Metadata::ColumnType::Type::DATE;
			break;
		case TIMEOID:
			tg_type = stub::Metadata::ColumnType::Type::TIME;
			break;
		case TIMESTAMPOID:
			tg_type = stub::Metadata::ColumnType::Type::TIMESTAMP;
			break;
		case TIMETZOID:
			tg_type = stub::Metadata::ColumnType::Type::TIMETZ;
			break;
		case TIMESTAMPTZOID:
			tg_type = stub::Metadata::ColumnType::Type::TIMESTAMPTZ;
			break;
		case NUMERICOID:
			tg_type = stub::Metadata::ColumnType::Type::DECIMAL;
			break;
		default:
			elog(ERROR, "tsurugi_fdw : unrecognized type oid: %d", (int) pg_type);
			break;
	}

	return tg_type;
}


/**
 *  @brief 	Convert value from tsurugidb to PostgreSQL.
 *  @param 	(resultset)	Pointer to ResultSet object.
 * 			(pgtype) OID of PostgreSQL data type.
 *  @return	(first)	flag of null value.
 * 			(second) PG value.
 */
std::pair<bool, Datum>
Tsurugi::convert_type_to_pg(ResultSetPtr result_set, const Oid pgtype) 
{
	bool is_null = true;
	Datum row_value;

	switch (pgtype)
	{
		case INT2OID:
			{
				std::int16_t value;
				elog(DEBUG5, "tsurugi_fdw : %s : pgtype is INT2OID.", __func__);
				if (result_set->next_column(value) == ERROR_CODE::OK)
				{
					elog(DEBUG5, "tsurugi_fdw : %s : value = %d", __func__, value);
					is_null = false;
					row_value = Int16GetDatum(value);
				}
			}
			break;

		case INT4OID:
			{
				std::int32_t value = 0;
				elog(DEBUG5, "tsurugi_fdw : %s : pgtype is INT4OID.", __func__);
				if (result_set->next_column(value) == ERROR_CODE::OK)
				{
					elog(DEBUG5, "tsurugi_fdw : %s : value = %d", __func__, value);
					is_null = false;
					row_value =  Int32GetDatum(value);
				}
			}
			break;

		case INT8OID:
			{
				std::int64_t value;
				elog(DEBUG5, "tsurugi_fdw : %s : pgtype is INT8OID.", __func__);
				if (result_set->next_column(value) == ERROR_CODE::OK)
				{
					elog(DEBUG5, "tsurugi_fdw : %s : value = %ld", __func__, value);
					is_null = false;
					row_value = Int64GetDatum(value);
				}
			}
			break;

		case FLOAT4OID:
			{
				float4 value;
				elog(DEBUG5, "tsurugi_fdw : %s : pgtype is FLOAT4OID.", __func__);
				if (result_set->next_column(value) == ERROR_CODE::OK)
				{
					is_null = false;
					row_value = Float4GetDatum(value);
				}
			}
			break;

		case FLOAT8OID:
			{
				float8 value;
				elog(DEBUG5, "tsurugi_fdw : %s : pgtype is FLOAT8OID.", __func__);
				if (result_set->next_column(value) == ERROR_CODE::OK)
				{
					is_null = false;
					row_value = Float8GetDatum(value);
				}
			}
			break;

		case BPCHAROID:
		case VARCHAROID:
		case TEXTOID:
			{
				elog(DEBUG5, "tsurugi_fdw : %s : pgtype is BPCHAROID/VARCHAROID/TEXTOID.", __func__);
				std::string value;
				Datum value_datum;
				HeapTuple 	heap_tuple;
				regproc 	typinput;
				int 		typemod;

				heap_tuple = SearchSysCache1(TYPEOID, 
											ObjectIdGetDatum(pgtype));
				if (!HeapTupleIsValid(heap_tuple))
				{
					elog(ERROR, "tsurugi_fdw : cache lookup failed for type %u", pgtype);
				}
				typinput = ((Form_pg_type) GETSTRUCT(heap_tuple))->typinput;
				typemod = ((Form_pg_type) GETSTRUCT(heap_tuple))->typtypmod;
				ReleaseSysCache(heap_tuple);

				ERROR_CODE result = result_set->next_column(value);
				if (result == ERROR_CODE::OK)
				{
					value_datum = CStringGetDatum(value.c_str());
					if (value_datum == (Datum) nullptr)
					{
						break;
					}
					is_null = false;
					row_value = (Datum) OidFunctionCall3(typinput,
												value_datum, 
												ObjectIdGetDatum(InvalidOid),
												Int32GetDatum(typemod));
				}
			}
			break;

		case DATEOID:
			{
				stub::date_type value;
				elog(DEBUG5, "tsurugi_fdw : %s : pgtype is DATEOID.", __func__);
				if (result_set->next_column(value) == ERROR_CODE::OK)
				{
					DateADT date;
					date = value.days_since_epoch();
					date = date - (POSTGRES_EPOCH_JDATE - UNIX_EPOCH_JDATE);
					row_value = DateADTGetDatum(date);
					is_null = false;
				}
			}
			break;

		case TIMEOID:
			{
				stub::time_type value;
				elog(DEBUG5, "tsurugi_fdw : %s : pgtype is TIMEOID.", __func__);
				if (result_set->next_column(value) == ERROR_CODE::OK)
				{
					TimeADT time;
					auto subsecond = value.subsecond().count();
					time = (value.hour() * MINS_PER_HOUR) + value.minute();
					time = (time * SECS_PER_MINUTE) + value.second();
					time = time * USECS_PER_SEC;
					if (subsecond != 0) {
						subsecond = round(subsecond / 1000.0);
						time = time + subsecond;
					}
					row_value = TimeADTGetDatum(time);
					is_null = false;
				}
			}
			break;

		case TIMETZOID:
			{
				stub::timetz_type value;
				elog(DEBUG5, "tsurugi_fdw : %s : pgtype is TIMETZOID.", __func__);
				if (result_set->next_column(value) == ERROR_CODE::OK)
				{
					TimeTzADT timetz;
					auto subsecond = value.first.subsecond().count();
					timetz.time = (value.first.hour() * MINS_PER_HOUR) + value.first.minute();
					timetz.time = (timetz.time * SECS_PER_MINUTE) + value.first.second();
					timetz.time = timetz.time * USECS_PER_SEC;
					if (subsecond != 0) {
						subsecond = round(subsecond / 1000.0);
						timetz.time = timetz.time + subsecond;
					}
					timetz.zone = -value.second * SECS_PER_MINUTE;

					elog(DEBUG5, "time_of_day = %d:%d:%d.%d, time_zone = %d",
									value.first.hour(), value.first.minute(), value.first.second(),
									subsecond, value.second);

					row_value = TimeTzADTPGetDatum(&timetz);
					is_null = false;
				}
			}
			break;

		case TIMESTAMPTZOID:
			{
				stub::timestamptz_type value;
				elog(DEBUG5, "tsurugi_fdw : %s : pgtype is TIMESTAMPTZOID.", __func__);
				if (result_set->next_column(value) == ERROR_CODE::OK)
				{
					Timestamp timestamp;
					auto subsecond = value.first.subsecond().count();
					timestamp = value.first.seconds_since_epoch().count() -
						((POSTGRES_EPOCH_JDATE - UNIX_EPOCH_JDATE) * SECS_PER_DAY);
					timestamp = timestamp * USECS_PER_SEC;
					if (subsecond != 0) {
						subsecond = round(subsecond / 1000.0);
						timestamp = timestamp + subsecond;
					}
					auto time_zone = value.second * SECS_PER_MINUTE;
					timestamp = timestamp - (time_zone * USECS_PER_SEC);

					elog(DEBUG5, "seconds_since_epoch = %ld, subsecond = %d, time_zone = %d",
									value.first.seconds_since_epoch().count(),
									value.first.subsecond().count(),
									value.second);

					row_value = TimestampTzGetDatum(timestamp);
					is_null = false;
				}
			}
			break;

		case TIMESTAMPOID:
			{
				stub::timestamp_type value;
				elog(DEBUG5, "tsurugi_fdw : %s : pgtype is TIMESTAMPOID.", __func__);
				if (result_set->next_column(value) == ERROR_CODE::OK)
				{
					Timestamp timestamp;
					auto subsecond = value.subsecond().count();
					timestamp = value.seconds_since_epoch().count() -
						((POSTGRES_EPOCH_JDATE - UNIX_EPOCH_JDATE) * SECS_PER_DAY);
					timestamp = timestamp * USECS_PER_SEC;
					if (subsecond != 0) {
						subsecond = round(subsecond / 1000.0);
						timestamp = timestamp + subsecond;
					}
					row_value = TimestampGetDatum(timestamp);
					is_null = false;
				}
			}
			break;

		case NUMERICOID:
			{
				stub::decimal_type value;
				elog(DEBUG5, "tsurugi_fdw : %s : pgtype is NUMERICOID.", __func__);
				auto error_code = result_set->next_column(value);
				if (error_code == ERROR_CODE::OK)
				{
					const auto sign = value.sign();
					const auto coefficient_high = value.coefficient_high();
					const auto coefficient_low = value.coefficient_low();
					const auto exponent = value.exponent();
					elog(DEBUG5, "triple(%d, %lu(0x%lX), %lu(0x%lX), %d)",
											sign, coefficient_high, coefficient_high,
											coefficient_low, coefficient_low, exponent);

					int scale = 0;
					if (exponent < 0) {
						scale =- exponent;
					}

					boost::multiprecision::uint128_t mp_coefficient;
					boost::multiprecision::uint128_t mp_high = coefficient_high;
					mp_coefficient = mp_high << 64;
					mp_coefficient |= coefficient_low;

					std::string coefficient;
					coefficient = mp_coefficient.str();
					if (exponent != 0) {
						if (scale >= (int)coefficient.size()) {
							// padding decimal point with zero
							std::stringstream ss;
							ss << std::setw(scale+1) << std::setfill('0') << coefficient;
							coefficient = ss.str();
						}
						coefficient.insert(coefficient.end() + exponent, '.');
					}
					if (sign < 0) {
						coefficient = "-" + coefficient;
					}
					elog(DEBUG5, "numeric_in(%s)", coefficient.c_str());

					row_value = DirectFunctionCall3(numeric_in,
													CStringGetDatum(coefficient.c_str()),
													ObjectIdGetDatum(InvalidOid),
													Int32GetDatum(((NUMERIC_MAX_PRECISION << 16) |
																			scale) + VARHDRSZ));
					is_null = false;

				}
			}
			break;

		default:
			elog(ERROR, "Invalid data type of PG. (%u)", pgtype);
			break;
	}

	return std::make_pair(is_null, row_value);
}

/**
 *  @brief 	Convert value from PostgreSQL to tsurugidb.
 *  @param 	(pg_type) oid of PostgreSQL data type.
 * 			(value) PostgreSQL datum.
 *  @return	value type of tsurugidb.
 */
ogawayama::stub::value_type
Tsurugi::convert_type_to_tg(const Oid pg_type, Datum value)
{
	elog(DEBUG1, "tsurugi_fdw : %s : pg_type: %d", __func__, (int) pg_type);

	ogawayama::stub::value_type param{};
	switch (pg_type)
	{
		case INT2OID:
			param = static_cast<std::int16_t>(DatumGetInt16(value));
			break;
		case INT4OID:
			param = static_cast<std::int32_t>(DatumGetInt32(value));
			break;
		case INT8OID:
			param = static_cast<std::int64_t>(DatumGetInt64(value));
			break;
		case FLOAT4OID:
			param =	static_cast<float>(DatumGetFloat4(value));
			break;
		case FLOAT8OID:
			param = static_cast<double>(DatumGetFloat8(value));
			break;
		case BPCHAROID:
		case VARCHAROID:
		case TEXTOID:
			{
				Oid typoutput;
				bool typisvarlena;
				getTypeOutputInfo(pg_type, &typoutput, &typisvarlena);
				param = OidOutputFunctionCall(typoutput, value);
				break;
			}
		case DATEOID:
			{
				DateADT date = DatumGetDateADT(value);
				struct pg_tm tm;
				j2date(date + POSTGRES_EPOCH_JDATE,
						&(tm.tm_year), &(tm.tm_mon), &(tm.tm_mday));
				auto tg_date = takatori::datetime::date(
										static_cast<std::int32_t>(tm.tm_year),
										static_cast<std::int32_t>(tm.tm_mon),
										static_cast<std::int32_t>(tm.tm_mday));
				param = tg_date;
				break;
			}
		case TIMEOID:
			{
				TimeADT time = DatumGetTimeADT(value);
				struct pg_tm tt, *tm = &tt;
				fsec_t fsec;
				time2tm(time, tm, &fsec);
				auto tg_time_of_day = takatori::datetime::time_of_day(
										static_cast<std::int64_t>(tm->tm_hour),
										static_cast<std::int64_t>(tm->tm_min),
										static_cast<std::int64_t>(tm->tm_sec),
										std::chrono::nanoseconds(fsec*1000));
				param = tg_time_of_day;
				break;
			}
		case TIMETZOID:
			{
				TimeTzADT* timetz = DatumGetTimeTzADTP(value);
				struct pg_tm tt, *tm = &tt;
				fsec_t fsec;
				time2tm(timetz->time, tm, &fsec);
				auto tg_time_of_day = takatori::datetime::time_of_day(
										static_cast<std::int64_t>(tm->tm_hour),
										static_cast<std::int64_t>(tm->tm_min),
										static_cast<std::int64_t>(tm->tm_sec),
										std::chrono::nanoseconds(fsec*1000));
				std::int32_t tg_time_zone = 0;
				if (timetz->zone != 0) {
					tg_time_zone = -timetz->zone / SECS_PER_MINUTE;
				}
				auto tg_time_of_day_with_time_zone =
					std::pair<takatori::datetime::time_of_day, std::int32_t>{tg_time_of_day, tg_time_zone};
				elog(DEBUG5, "time_of_day = %d:%d:%d.%d, time_zone = %d",
								tm->tm_hour, tm->tm_min, tm->tm_sec, fsec, tg_time_zone);
				param = tg_time_of_day_with_time_zone;
				break;
			}
		case TIMESTAMPTZOID:
			{
				TimestampTz timestamptz = DatumGetTimestampTz(value);
				struct pg_tm tt, *tm = &tt;
				fsec_t fsec;
				int tz;
				if (timestamp2tm(timestamptz, &tz, tm, &fsec, NULL, NULL) != 0)
					ereport(ERROR,
							(errcode(ERRCODE_DATETIME_VALUE_OUT_OF_RANGE),
								errmsg("timestamp out of range")));
				auto tg_date = takatori::datetime::date(
										static_cast<std::int32_t>(tm->tm_year),
										static_cast<std::int32_t>(tm->tm_mon),
										static_cast<std::int32_t>(tm->tm_mday));
				auto tg_time_of_day = takatori::datetime::time_of_day(
										static_cast<std::int64_t>(tm->tm_hour),
										static_cast<std::int64_t>(tm->tm_min),
										static_cast<std::int64_t>(tm->tm_sec),
										std::chrono::nanoseconds(fsec*1000));
				auto tg_time_point = takatori::datetime::time_point(
										tg_date,
										tg_time_of_day);
				std::int32_t tg_time_zone = 0;
				if (tz != 0) {
					tg_time_zone = -tz / SECS_PER_MINUTE;
				}
				auto tg_time_point_with_time_zone =
					std::pair<takatori::datetime::time_point, std::int32_t>{tg_time_point, tg_time_zone};
				elog(DEBUG5, "date = %d/%d/%d, time_of_day = %d:%d:%d.%d, time_zone = %d",
								tm->tm_year, tm->tm_mon, tm->tm_mday,
								tm->tm_hour, tm->tm_min, tm->tm_sec, fsec, tg_time_zone);
				param = tg_time_point_with_time_zone;
//				param = convert_timestamptz_to_tg(value);
				break;
			}
		case TIMESTAMPOID:
			{
				Timestamp timestamp = DatumGetTimestamp(value);
				struct pg_tm tt, *tm = &tt;
				fsec_t fsec;
				if (timestamp2tm(timestamp, NULL, tm, &fsec, NULL, NULL) != 0) {
					elog(ERROR, "timestamp out of range");
				}
				auto tg_date = takatori::datetime::date(
										static_cast<std::int32_t>(tm->tm_year),
										static_cast<std::int32_t>(tm->tm_mon),
										static_cast<std::int32_t>(tm->tm_mday));
				auto tg_time_of_day = takatori::datetime::time_of_day(
										static_cast<std::int64_t>(tm->tm_hour),
										static_cast<std::int64_t>(tm->tm_min),
										static_cast<std::int64_t>(tm->tm_sec),
										std::chrono::nanoseconds(fsec*1000));
				auto tg_time_point = takatori::datetime::time_point(
										tg_date,
										tg_time_of_day);
				param = tg_time_point;
				break;
			}
		case NUMERICOID:
			{
				// Convert PostgreSQL NUMERIC type to string.
				std::string pg_numeric = DatumGetCString(
											DirectFunctionCall1(numeric_out, value));
				elog(DEBUG5, "orignal: pg_numeric = %s", pg_numeric.c_str());
				auto pos_period = pg_numeric.find(".");
				if (pos_period != std::string::npos) {
					pg_numeric.erase(pos_period, 1);
				}
				auto pos_negative = pg_numeric.find("-");
				if (pos_negative != std::string::npos) {
					pg_numeric.erase(pos_negative, 1);
				}
				while (pg_numeric.at(0) == '0' && pg_numeric.size() > 1) {
					// The first zero is deleted. Because identified as an octal number.
					pg_numeric.erase(0, 1);
				}
				elog(DEBUG5, "after: pg_numeric = %s", pg_numeric.c_str());

				// Get display scale and sign from NumericData.
				Numeric numeric_data = DatumGetNumeric(value);
				bool numeric_is_short = numeric_data->choice.n_header & 0x8000;
				int numeric_dscale;
				int numeric_sign;
				if (numeric_is_short) {
					numeric_dscale = 
						(numeric_data->choice.n_short.n_header & NUMERIC_SHORT_DSCALE_MASK) 
						>> NUMERIC_SHORT_DSCALE_SHIFT;
					if (numeric_data->choice.n_short.n_header & NUMERIC_SHORT_SIGN_MASK)
						numeric_sign = NUMERIC_NEG;
					else
						numeric_sign = NUMERIC_POS;
				} else {
					numeric_dscale = 
						numeric_data->choice.n_long.n_sign_dscale & NUMERIC_DSCALE_MASK;
					numeric_sign = numeric_data->choice.n_header & NUMERIC_SIGN_MASK;
				}

				// Generate parameters for takatori::decimal::triple.
				std::int64_t sign = 0;
				switch (numeric_sign)
				{
					case NUMERIC_POS:
						sign = 1;
						break;
					case NUMERIC_NEG:
						sign = -1;
						break;
					case NUMERIC_NAN:
						sign = 0;
						break;
					default:
						elog(ERROR, "unrecognized numeric sign = 0x%x", numeric_sign);
						break;
				}

				boost::multiprecision::cpp_int mp_coefficient(pg_numeric);
				if (mp_coefficient > std::numeric_limits<boost::multiprecision::uint128_t>::max()) {
					elog(ERROR, "numeric coefficient field overflow");
				}
				std::uint64_t coefficient_high = static_cast<std::uint64_t>(mp_coefficient >> 64);
				std::uint64_t coefficient_low  = static_cast<std::uint64_t>(mp_coefficient);

				std::int32_t exponent = -numeric_dscale;

				elog(DEBUG5, "triple(%ld, %lu(0x%lX), %lu(0x%lX), %d)",
										sign, coefficient_high, coefficient_high, 
										coefficient_low, coefficient_low, exponent);

				auto tg_decimal = takatori::decimal::triple{
									sign, coefficient_high, coefficient_low, exponent};
				param = tg_decimal;
//				param = convert_decimal_to_tg(value);
				break;
			}
		default:
			elog(ERROR, "unrecognized type oid: %d", (int) pg_type);
			break;
	}

	return param;
}

/**
 *  @brief 	Convert structure of timestamptz value from PostgreSQL to tsurugidb.
 *  @param 	(value) PostgreSQL datum.
 *  @return	timestamptz type of tsurugidb.
 */
ogawayama::stub::timestamptz_type convert_timestamptz_to_tg(Datum value)
{
	TimestampTz timestamptz = DatumGetTimestampTz(value);
	struct pg_tm tt, *tm = &tt;
	fsec_t fsec;
	int tz;
	if (timestamp2tm(timestamptz, &tz, tm, &fsec, NULL, NULL) != 0)
		ereport(ERROR,
				(errcode(ERRCODE_DATETIME_VALUE_OUT_OF_RANGE),
					errmsg("timestamp out of range")));
	auto tg_date = takatori::datetime::date(
							static_cast<std::int32_t>(tm->tm_year),
							static_cast<std::int32_t>(tm->tm_mon),
							static_cast<std::int32_t>(tm->tm_mday));
	auto tg_time_of_day = takatori::datetime::time_of_day(
							static_cast<std::int64_t>(tm->tm_hour),
							static_cast<std::int64_t>(tm->tm_min),
							static_cast<std::int64_t>(tm->tm_sec),
							std::chrono::nanoseconds(fsec*1000));
	auto tg_time_point = takatori::datetime::time_point(
							tg_date,
							tg_time_of_day);
	std::int32_t tg_time_zone = 0;
	if (tz != 0) {
		tg_time_zone = -tz / SECS_PER_MINUTE;
	}
	auto tg_time_point_with_time_zone =
		std::pair<takatori::datetime::time_point, std::int32_t>{tg_time_point, tg_time_zone};
	elog(DEBUG5, "date = %d/%d/%d, time_of_day = %d:%d:%d.%d, time_zone = %d",
					tm->tm_year, tm->tm_mon, tm->tm_mday,
					tm->tm_hour, tm->tm_min, tm->tm_sec, fsec, tg_time_zone);

	return tg_time_point_with_time_zone;
}

/**
 *  @brief 	Convert structure of decimal value from PostgreSQL to tsurugidb.
 *  @param 	(value) PostgreSQL datum.
 *  @return	decimal value of tsurugidb.
 */
takatori::decimal::triple 
Tsurugi::convert_decimal_to_tg(Datum value)
{
	// Convert PostgreSQL NUMERIC type to string.
	std::string pg_numeric = DatumGetCString(DirectFunctionCall1(numeric_out, value));
	elog(DEBUG5, "original: pg_numeric = %s", pg_numeric.c_str());
	auto pos_period = pg_numeric.find(".");
	if (pos_period != std::string::npos) {
		pg_numeric.erase(pos_period, 1);
	}
	auto pos_negative = pg_numeric.find("-");
	if (pos_negative != std::string::npos) {
		pg_numeric.erase(pos_negative, 1);
	}
	while (pg_numeric.at(0) == '0' && pg_numeric.size() > 1) {
		// The first zero is deleted. Because identified as an octal number.
		pg_numeric.erase(0, 1);
	}
	elog(DEBUG5, "after: pg_numeric = %s", pg_numeric.c_str());

	// Get display scale and sign from NumericData.
	Numeric numeric_data = DatumGetNumeric(value);
	bool numeric_is_short = numeric_data->choice.n_header & 0x8000;
	int numeric_dscale;
	int numeric_sign;
	if (numeric_is_short) {
		numeric_dscale = 
			(numeric_data->choice.n_short.n_header & NUMERIC_SHORT_DSCALE_MASK) >>
			NUMERIC_SHORT_DSCALE_SHIFT;
		if (numeric_data->choice.n_short.n_header & NUMERIC_SHORT_SIGN_MASK)
			numeric_sign = NUMERIC_NEG;
		else
			numeric_sign = NUMERIC_POS;
	} else {
		numeric_dscale = 
			numeric_data->choice.n_long.n_sign_dscale & NUMERIC_DSCALE_MASK;
		numeric_sign = numeric_data->choice.n_header & NUMERIC_SIGN_MASK;
	}

	// Generate parameters for takatori::decimal::triple.
	std::int64_t sign = 0;
	switch (numeric_sign)
	{
		case NUMERIC_POS:
			sign = 1;
			break;
		case NUMERIC_NEG:
			sign = -1;
			break;
		case NUMERIC_NAN:
			sign = 0;
			break;
		default:
			elog(ERROR, "unrecognized numeric sign = 0x%x", numeric_sign);
			break;
	}

	boost::multiprecision::cpp_int mp_coefficient(pg_numeric);
	if (mp_coefficient > std::numeric_limits<boost::multiprecision::uint128_t>::max()) {
		elog(ERROR, "numeric coefficient field overflow");
	}
	std::uint64_t coefficient_high = static_cast<std::uint64_t>(mp_coefficient >> 64);
	std::uint64_t coefficient_low  = static_cast<std::uint64_t>(mp_coefficient);

	std::int32_t exponent = -numeric_dscale;

	elog(DEBUG5, "triple(%ld, %lu(0x%lX), %lu(0x%lX), %d)",
							sign, coefficient_high, coefficient_high, 
							coefficient_low, coefficient_low, exponent);

	return takatori::decimal::triple{sign, coefficient_high, coefficient_low, exponent};
}

/*
 * Copyright 2023 tsurugi project.
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
#include <boost/property_tree/ini_parser.hpp>
#include <boost/filesystem.hpp>

#include "ogawayama/stub/error_code.h"
#include "ogawayama/stub/api.h"
#include "tsurugi.h"

using namespace ogawayama;

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
		elog(LOG, "Trying to run make_stub(). (shared memory: %s)", 
            shared_memory_name.c_str());

		error = make_stub(stub_, shared_memory_name);
		if (error != ERROR_CODE::OK) 
        {
            elog(ERROR, "Failed to run make_stub(). (error: %d)",
                (int) error);
            stub_ = nullptr;
			return error;
		}

		elog(LOG, "make_stub() succeeded. (shared memory: %s)",
            shared_memory_name.c_str());
	}

	if (connection_ == nullptr) 
    {
		elog(LOG, "Trying to run Stub::get_connection(). (pid: %d)", getpid());

		error = stub_->get_connection(getpid(), connection_);
		if (error != ERROR_CODE::OK)
		{
            elog(ERROR, "Stub::get_connection() failed. (error: %d)",
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
        elog(LOG, "Trying to run Tsurugi::init(). (pid: %d)", getpid());

        error = init();

        if (error != ERROR_CODE::OK)
        {
            elog(ERROR, "there can not connect to Tsurugi.");
            return error;
        }
    }

    elog(LOG, "Trying to run Connection::prepare(). (pid: %d)", getpid());
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

        elog(LOG, "Trying to run Connection::begin(). (pid: %d)", getpid());

        ERROR_CODE error = connection_->begin(option, transaction_);

        elog(LOG, "Connection::begin() done. (error: %d)", (int) error);
    }
    else
    {
        elog(WARNING, "there is no connection to Tsurugi.");
        return error;
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
	    elog(LOG, "Trying to run Transaction::execute_query(prepared_statement). \n%s",
	        query.data());
	    error = transaction_->execute_query(prepared_statement, parameters, result_set);
	} else {
	    elog(LOG, "Trying to run Transaction::execute_query(query). \n%s",
	        query.data());
	    error = transaction_->execute_query(query, result_set);
	}

    elog(LOG, "execute_query() done. (error: %d)", (int) error);

    return error;
}

/*
 * execute_statement
 */
ERROR_CODE 
Tsurugi::execute_statement(std::string_view statement)
{
    ERROR_CODE error = ERROR_CODE::UNKNOWN;

    if (transaction_ != nullptr)
    {
		if (prepared_statement.get() != nullptr) {
	        elog(LOG, "tsurugi-fdw: Trying to execute the prepared statement. \n%s",
	            statement.data());
	        error = transaction_->execute_statement(prepared_statement, parameters);
		} else {
	        elog(LOG, "tsurugi-fdw: Trying to execute the statement. \n%s",
	            statement.data());
	        error = transaction_->execute_statement(statement);
		}

        elog(LOG, "tsurugi-fdw: execute_statement() done. (error: %d)",
            (int) error);
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
        elog(LOG, "Trying to run Transaction::commit().");

        ERROR_CODE error = transaction_->commit();
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
        elog(LOG, "Trying to run Transaction::rollback().");

        ERROR_CODE error = transaction_->rollback();
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
			std::cerr << "Stub::get_connection() failed. " << (int) error << std::endl;
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
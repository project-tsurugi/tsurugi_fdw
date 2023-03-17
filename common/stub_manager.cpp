#include <iostream>
#include <string>
#include <string_view>
#include <boost/property_tree/ini_parser.hpp>
#include <boost/filesystem.hpp>

#include "ogawayama/stub/error_code.h"
#include "ogawayama/stub/api.h"
#include "stub_manager.h"

using namespace ogawayama;

#if 0
extern PGDLLIMPORT PGPROC *MyProc;
#endif

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

StubPtr StubManager::stub_ = nullptr;
ConnectionPtr StubManager::connection_ = nullptr;
TransactionPtr StubManager::transaction_ = nullptr;

std::string get_shared_memory_name()
{
    std::string name(ogawayama::common::param::SHARED_MEMORY_NAME);  
    boost::property_tree::ptree pt;
    const boost::filesystem::path conf_file("tsurugi_fdw.conf");
    boost::system::error_code error;
    if (boost::filesystem::exists(conf_file, error)) {
        boost::property_tree::read_ini("tsurugi_fdw.conf", pt);
        boost::optional<std::string> str = 
            pt.get_optional<std::string>("Configurations.SHARED_MEMORY_NAME");
        if (str) {
            name = str.get();
        }
    }

    return name;
}

/*
 * 	@brief: 
 */
ERROR_CODE StubManager::init()
{
	ERROR_CODE error = ERROR_CODE::UNKNOWN;

    if (stub_ == nullptr)
	{
        std::string shared_memory_name(get_shared_memory_name());
		error = make_stub(stub_, shared_memory_name);
		if (error != ERROR_CODE::OK) {
			std::cerr << "stub::make_stub() failed. " << (int) error << std::endl;
			return error;
		}
		elog(LOG, "make_stub() succeeded. (shared memory name: %s)", 
            shared_memory_name.c_str());
	}
	
	error = ERROR_CODE::OK;

	return error;
}

/*
 *	@brief:
 */
ERROR_CODE StubManager::get_stub(stub::Stub** stub)
{
	ERROR_CODE error = ERROR_CODE::OK;

	if (stub_ == nullptr) {
		error = init();
		if (error != ERROR_CODE::OK) {
			std::cerr << "init() failed(). " << (int) error << std::endl;
			return error;
		}
	}
	*stub = stub_.get();

	error = ERROR_CODE::OK;

	return error;
}

/*
 * 	@brief: 
 */
ERROR_CODE StubManager::get_connection(stub::Connection** connection)
{
	ERROR_CODE error = ERROR_CODE::UNKNOWN;

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

	*connection = connection_.get();
	error = ERROR_CODE::OK;

	return error;
}

/*
 *	@brief:	
 */
ERROR_CODE StubManager::begin(stub::Transaction** transaction)
{
	ERROR_CODE error = ERROR_CODE::UNKNOWN;

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
		ERROR_CODE error = connection_->begin(transaction_);
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
void StubManager::end()
{
	transaction_ = nullptr;
}

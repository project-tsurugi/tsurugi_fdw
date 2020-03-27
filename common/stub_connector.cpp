
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

#include <iostream>
#include <string>
#include <string_view>

#include "ogawayama/stub/error_code.h"
#include "ogawayama/stub/api.h"

#include "stub_connector.h"

using namespace ogawayama;

#if 0
extern PGDLLIMPORT PGPROC *MyProc;
#endif

StubPtr StubConnector::stub_ = nullptr;
ConnectionPtr StubConnector::connection_ = nullptr;

/*
 * 	@brief: 
 */
ERROR_CODE StubConnector::init()
{
	assert(stub_ == nullptr);

	ERROR_CODE error = make_stub(stub_);
	if (error != ERROR_CODE::OK)
	{
		std::cerr << "stub::make_stub() failed. " << (int) error << std::endl;
	}
	std::cout << "make_stub()" << std::endl;

	return error;
}

/*
 * 	@brief: 
 */
ERROR_CODE StubConnector::get_connection(stub::Connection** connection)
{
	stub::ErrorCode error = stub::ErrorCode::UNKNOWN;

	if (stub_ == nullptr) {
		error = init();
		if (error != ERROR_CODE::OK) {
			std::cerr << "init() failed. " << (int) error << std::endl;
			return error;
		}
	}

	if (connection_ == nullptr) {
		stub::ErrorCode error = stub_->get_connection(getpid() , connection_);
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

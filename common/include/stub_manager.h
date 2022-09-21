#pragma once

#include <string>
#include <string_view>

#include "ogawayama/stub/error_code.h"
#include "ogawayama/stub/api.h"

class StubManager {
public:
	static ERROR_CODE init();
	static ERROR_CODE get_connection(ogawayama::stub::Connection** connection);
	static ERROR_CODE begin(ogawayama::stub::Transaction** transaction);
	static void end();
	StubManager() = delete;

private:
	static StubPtr stub_;
	static ConnectionPtr connection_;
	static TransactionPtr transaction_;

	static ERROR_CODE get_stub(ogawayama::stub::Stub** stub);
};

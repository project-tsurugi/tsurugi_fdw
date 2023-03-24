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
#if 0
    static ogawayama::stub::Connection* get_connection() {
        return connection_.get();
    }
    static ogawayama::stub::Transaction* get_transaction() {
        return transaction_.get();
    }
    static ogawayama::stub::ResultSet* get_result_set() {
        return result_set_.get();
    }
#endif
private:
	static StubPtr stub_;
	static ConnectionPtr connection_;
	static TransactionPtr transaction_;
//    static ResultSetPtr result_set_;

	static ERROR_CODE get_stub(ogawayama::stub::Stub** stub);
};

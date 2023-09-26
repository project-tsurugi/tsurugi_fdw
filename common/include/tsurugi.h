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
    static ERROR_CODE execute_statement(std::string_view statement);
    static ERROR_CODE commit();
    static ERROR_CODE rollback();

    static ERROR_CODE begin(ogawayama::stub::Transaction** transaction);
    static void end();
	Tsurugi() = delete;

private:
	static StubPtr stub_;
	static ConnectionPtr connection_;
	static TransactionPtr transaction_;
};
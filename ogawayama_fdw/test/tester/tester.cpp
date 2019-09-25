#ifdef __cplusplus
extern "C" {
#endif

#include "postgres.h"

#ifdef __cplusplus
}
#endif

#include <iostream>
#include <memory>
#include <unistd.h>
#include <sys/types.h>

#include "ogawayama/stub/api.h"

using namespace ogawayama::stub;

static StubPtr stub_;
static ConnectionPtr connection_;
static TransactionPtr transaction_;
static ResultSetPtr resultset_;
static MetadataPtr metadata_;

const char query_ = "SETLECT c1 FROM t1";

int main( void )
{
    std::cout <<  "tester started." << std::endl;

    ErrorCode ret = ErrorCode::OK;

    stub_ = make_stub();

    ErrorCode ret = stub_->get_connection( getpid(), connection_ );
    if ( ret == ErrorCode::OK ) {
        std::cout << "connection succeeded." << std::endl;
    } else {
        std::cout << "connection failed. " << std::endl;
    }

    ret = connection_->begin( transaction_ );
    if ( ret == ErrorCode::OK ) {
        std::cout << "begin succeeded." << std::endl;
    } else {
        std::cout << "begin failed. " << std::endl;
    }

    ret = transaction_->execute_query( query_, reesultset_ );
    if ( ret == ErrorCode::OK ) {
        std::cout << "execute_query succeeded." << std::endl;
    } else {
        std::cout << "execute_query failed. " << std::endl;
    }

    ret = resultset_->get_metadata( metadata_ );
    if ( ret == ErrorCode::OK ) {
        std::cout << "get_metadata succeeded." << std::endl;
    } else {
        std::cout << "get_metadata failed. " << std::endl;
    }

    std::cout << "tester done." << std::endl;

    return 0;
}

/*-------------------------------------------------------------------------
 *
 * dispatcher.cpp
 *		  Dispatch a query to DB engine.
 *
 * IDENTIFICATION
 *		  contrib/frontend/dispatcher.cpp
 *
 *-------------------------------------------------------------------------
 */
#include "postgres.h"

#include "dispatcher.h"

#include "api.h"

using namespace std;
using namespace ogawayama::stub;

/*
 * dispatch_query
 *		
 *
 */
bool 
dispatch_query( char* query_str )
{
    bool rc = false;
    string query;
    Stub stub;
    unique_ptr<Connection> connection;
    unique_ptr<Transaction> transaction;
    unique_ptr<ResultSet> result_set;
    ErrorCode ec;

    ec = stub.get_connection( connection );
    ec = connection->begin( transaction );

    // SELECT command
    ec = transaction->execute_query( query, result_set );

    return rc;
}

/*
 * dispatch_statement
 *		
 *
 */
bool
dispatch_statement( char* statement_str )
{
    bool rc = false;
    string statement;
    Stub stub;
    unique_ptr<Connection> connection;
    unique_ptr<Transaction> transaction;
    ErrorCode ec;

    ec = stub.get_connection( connection );
    ec = connection->begin( transaction );

    // UPDATE/INSERT/DELETE command
    ec = transaction->execute_statement( statement );
}

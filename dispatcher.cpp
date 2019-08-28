/*
 * Copyright 2019-2019 tsurugi project.
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
 */
#include "postgres.h"
#include <memory>
#include <string>

#include "dispatcher.h"

#include "api.h"
#include "metadata.h"
#include "error_code.h"

using namespace ogawayama::stub;

static StubPtr stub;
static ConnectionPtr connection;
static ResultSetPtr resultset;
static MetadataPtr metadata;

/**
 * @biref   initialize stub.
 * @param   [in] shared memoery name.
 * @return  0 if success. see ErrorCode.h
 */
int 
init_stub( const char* name )
{
    ErrorCode error = ErrorCode::OK;

    stub = make_stub( name );

    return (int) error;
}

/**
 * @biref   initialize and connect to ogawayama.
 * @param   [in] worker process ID.
 * @return  0 if success. see ErrorCode.h
 */
int 
get_connection( size_t pg_procno )
{
    ErrorCode error = ErrorCode::OK;

    error = stub->get_connection( pg_procno, connection );

    return (int) error;
}

/**
 * @brief   dispatch SELECT command to ogawayama.
 * @param   [in] query text.
 * @return  0 if success.
 */
int 
dispatch_query( const char* query_string )
{
    ErrorCode error = ErrorCode::OK;
    std::string query( query_string );
    std::unique_ptr<Transaction> transaction;

    error = connection->begin( transaction );
    if ( error != ErrorCode::OK )
        goto Exit;

    // SELECT command
    error = transaction->execute_query( query, resultset );
    if ( error != ErrorCode::OK )
        goto Exit;

    error = transaction->commit();
    if ( error != ErrorCode::OK )
        goto Exit;

    error = resultset->get_metadata( metadata );
    if ( error != ErrorCode::OK )
        goto Exit;

Exit:
    return (int) error;
}

/**
 * @brief   move current to the next tuple.
 * @return  0 if the ResultSet object has next tupple.
 */
int 
resultset_next_row()
{
    return (int) resultset->next();
}

/**
 * @brief   number of columns in the current row.
 * @return  number of columns.
 */
size_t
resultset_get_column_count()
{
    return (size_t) (metadata->get_types()).size();
}

/**
 * @brief   get current data type.
 * @param   [in] column index. (1 origin)
 * @param   [out] data type. see Metadata.h
 * @return  0 if success.
 */
int
resultset_get_type( int column_index, int* type )
{
    ErrorCode error = ErrorCode::OK;
    try {
        Metadata::SetOfTypeData types = metadata->get_types();
        auto ite = types.begin();
        std::advance( ite, column_index - 1 );

        *type = (int) ite->get_type();
    }
    catch (...) {
        
    }

    return (int) error;
}

/**
 * @brief   get current data length.
 * @param   [in] column index. (1 origin)
 * @param   [out] data length. (bytes)
 * @return  0 if success.
 */
int
resultset_get_length( int column_index, int* length )
{
    ErrorCode error = ErrorCode::OK;
    try {
        Metadata::SetOfTypeData types = metadata->get_types();
        auto ite = types.begin();
        std::advance( ite, column_index - 1 );

        *length = (int) ite->get_length();
    }
    catch (...) {
        
    }

    return (int) error;
}

/**
 * @brief   get column value as int16.
 * @param   [in] column index. (1 origin)
 * @param   [out] column value.
 * @return  0 if success.
 */
int
resultset_get_int16( int column_index, int16* value )
{
    ErrorCode error = ErrorCode::OK;
    try {
        Metadata::SetOfTypeData types = metadata->get_types();
        auto ite = types.begin();
        std::advance( ite, column_index - 1 );

        std::int16_t v;
        resultset->next_column(v);
        *value = (int16) v;
    }
    catch (...) {
        
    }

    return (int) error;    
}

/**
 * @brief   get column value as int32.
 * @param   [in] column index. (1 origin)
 * @param   [out] column value.
 * @return  0 if success.
 */
int
resultset_get_int32( int column_index, int32* value )
{
    ErrorCode error = ErrorCode::OK;
    try {
        Metadata::SetOfTypeData types = metadata->get_types();
        auto ite = types.begin();
        std::advance( ite, column_index - 1 );

        std::int32_t v;
        resultset->next_column(v);
        *value = (int32) v;
    }
    catch (...) {
        
    }

    return (int) error;    
}

/**
 * @brief   get column value as int64.
 * @param   [in] column index. (1 origin)
 * @param   [out] column value.
 * @return  0 if success.
 */
int
resultset_get_int64( int column_index, int64* value )
{
    ErrorCode error = ErrorCode::OK;
    try {
        Metadata::SetOfTypeData types = metadata->get_types();
        auto ite = types.begin();
        std::advance( ite, column_index - 1 );
        std::int64_t v;
        resultset->next_column(v);
        *value = (int64) v;
    }
    catch (...) {
        
    }

    return (int) error;    
}

/**
 * @brief   get column value as float32.
 * @param   [in] column index. (1 origin)
 * @param   [out] column value.
 * @return  0 if success.
 */
int
resultset_get_float32( int column_index, float* value )
{
    ErrorCode error = ErrorCode::OK;
    try {
        Metadata::SetOfTypeData types = metadata->get_types();
        auto ite = types.begin();
        std::advance( ite, column_index - 1 );
        float v;
        resultset->next_column(v);
        *value = (float) v;
    }
    catch (...) {
        
    }

    return (int) error;    
}

/**
 * @brief   get column value as float64.
 * @param   [in] column index. (1 origin)
 * @param   [out] column value.
 * @return  0 if success.
 */
int
resultset_get_float64( int column_index, double* value )
{
    ErrorCode error = ErrorCode::OK;
    try {
        Metadata::SetOfTypeData types = metadata->get_types();
        auto ite = types.begin();
        std::advance( ite, column_index );
        double v;
        resultset->next_column(v);
        *value = (double) v;
    }
    catch (...) {
        
    }

    return (int) error;    
}

/**
 * @brief   get column value as text.
 * @param   [in] column index. (1 origin)
 * @param   [out] column value.
 * @param   [in] buffer size.
 * @return  0 if success.
 */
int
resultset_get_text( int column_index, char** value, size_t bufsize )
{
    ErrorCode error = ErrorCode::OK;
    try {
        Metadata::SetOfTypeData types = metadata->get_types();
        auto ite = types.begin();
        std::advance( ite, column_index );
        std::string_view v;
        resultset->next_column(v);
        v.copy( *value, bufsize - 1 );
    }
    catch (...) {
        
    }

    return (int) error;    
}

/**
 * @brief   dispatch INSERT/UPDATE/DELETE command to ogawayama.
 * @param   [in] statement text.
 * @return  0 if success.
 */
int dispatch_statement( const char* statement_string )
{
    ErrorCode error = ErrorCode::OK;
    std::string statement;
    std::unique_ptr<Transaction> transaction;

     error = connection->begin( transaction );

    // UPDATE/INSERT/DELETE command
    error = transaction->execute_statement( statement );

    return (int) error;
}

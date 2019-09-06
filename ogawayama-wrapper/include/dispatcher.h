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
#ifndef DISPATCHER_H
#define DISPATCHER_H

#ifdef __cplusplus
extern "C" {
#endif

#include "datatype.h"

/**
 * @biref   initialize stub.
 * @param   [in] shared memoery name.
 * @return  0 if success. see ErrorCode.h
 */
int init_stub( const char* name );

/**
 * @biref   connect to ogawayama.
 * @param   [in] worker process ID.
 * @return  0 if success. see ErrorCode.h
 */
int get_connection( size_t pg_procno );

/**
 * @brief   free result set memory.
 */
void close_connection();

/**
 * @brief   dispatch SELECT command to ogawayama.
 * @param   [in] query text.
 * @return  0 if success.
 */
int dispatch_query( const char* query_string );

/**
 * @brief   move current to the next tuple.
 * @return  0 if the ResultSet object has next tupple.
 */
int resultset_next_row();

/**
 * @brief   number of columns in the current row.
 * @return  number of columns.
 */
size_t resultset_get_column_count();

/**
 * @brief   get current data type.
 * @param   [in] column index. (1 origin)
 * @param   [out] data type. see Metadata.h
 * @return  0 if success.
 */
int resultset_get_type( int column_index, int* type );

/**
 * @brief   get current data type.
 * @param   [in] column index. (1 origin)
 * @param   [out] pg data type. see datatype.h
 * @return  0 if success.
 */
int
resultset_get_pgtype( int column_index, PG_TYPE* pg_type );

/**
 * @brief   get current data length.
 * @param   [in] column index. (1 origin)
 * @param   [out] data length. (bytes)
 * @return  0 if success.
 */
int resultset_get_length( int column_index, size_t* length );

/**
 * @brief   get column value as int16.
 * @param   [in] column index. (1 origin)
 * @param   [out] column value.
 * @return  0 if success.
 */
int resultset_get_int16( int column_index, int16* value );

/**
 * @brief   get column value as int32.
 * @param   [in] column index. (1 origin)
 * @param   [out] column value.
 * @return  0 if success.
 */
int resultset_get_int32( int column_index, int32* value );

/**
 * @brief   get column value as int64.
 * @param   [in] column index. (1 origin)
 * @param   [out] column value.
 * @return  0 if success.
 */
int resultset_get_int64( int column_index, int64* value );

/**
 * @brief   get column value as float32.
 * @param   [in] column index. (1 origin)
 * @param   [out] column value.
 * @return  0 if success.
 */
int resultset_get_float32( int column_index, float* value );

/**
 * @brief   get column value as float64.
 * @param   [in] column index. (1 origin)
 * @param   [out] column value.
 * @return  0 if success.
 */
int resultset_get_float64( int column_index, double* value );

/**
 * @brief   get column value as text.
 * @param   [in] column index. (1 origin)
 * @param   [out] column value.
 * @param   [in] buffer size.
 * @return  0 if success.
 */
int resultset_get_text( int column_index, char* value, size_t bufsize );

/**
 * @brief   dispatch INSERT/UPDATE/DELETE command to ogawayama.
 * @param   [in] statement text.
 * @return  0 if success.
 */
int dispatch_statement( const char* statement_string );

#ifdef __cplusplus
}
#endif

#endif // DISPATCHER_H

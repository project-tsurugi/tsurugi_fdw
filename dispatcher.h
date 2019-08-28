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
#ifndef DISPATCH_QUERY_H
#define DISPATCH_QUERY_H

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @biref   initialize and connect to ogawayama.
 * @param   (in) worker process ID.
 * @return  0 if success. see ErrorCode.h
 */
int get_connection( size_t pg_procno );

/**
 * @brief   dispatch SELECT command to ogawayama.
 * @param   (in) query string.
 * @param   (out) pointer to ResultSet object pointer.
 * @return  0 if success.
 */
int dispatch_query( char* query_string );

/**
 * @brief   move current to the next tuple.
 * @return  0 if the ResultSet object has next tupple.
 */
int resultset_next_row();

/**
 * @brief   number of columns in current row.
 * @return  0 if success.
 */
int
resultset_get_column_count();

/**
 * @brief   get current data type.
 * @return  0 if success.
 */
int
resultset_get_type( int column_index, int* type );

/**
 * @brief   get current data length.
 * @return  0 if success.
 */
int
resultset_get_length( int column_index, int* length );

int
resultset_get_int16( int column_index, int16* value );

int
resultset_get_int32( int column_index, int32* value );

int
resultset_get_int64( int column_index, int64* value );

int
resultset_get_float32( int column_index, float* value );

int
resultset_get_float64( int column_index, double* value );

int
resultset_get_text( int column_index, int* value );

/**
 * @brief   dispatch INSERT/UPDATE/DELETE command to ogawayama.
 * @param   (in) statement string.
 * @return  0 if success.
 */
int dispatch_statement( char* statement_string );

#ifdef __cplusplus
}
#endif

#endif // DISPATCH_QUERY_H

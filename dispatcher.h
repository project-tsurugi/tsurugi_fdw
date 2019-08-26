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
 * @brief   dispatch SELECT command to ogawayama.
 * @param   (in)query string of the command.
 * @param   (out)pointer to ResultSet object.
 * @return  0 if success.
 */
int dispatch_query( char* query_string, void** result_set_ptr );

/**
 * @brief get value from the current row.
 * @param   (in)pointer to ResultSet object.
 * @param   (out)value of the column.
 * @param   (out)type of the value.
 * @param   (out)length of the value.
 * @return  0 if success.
 */
int result_set_next_column( void* result_set, void** value,  int* type, int* length );

/**
 * @brief   move current to the next tuple.
 * @param   (in)pointer to ResultSet object.
 * @return  0 if the ResultSet object has next tupple.
 */
int result_set_next_row( void* result_set );

/**
 * @brief   dispatch INSERT/UPDATE/DELETE command to ogawayama.
 * @param   (in)the command string
 * @return  0 if success.
 */
int dispatch_statement( char* statement_string );

#ifdef __cplusplus
}
#endif

#endif // DISPATCH_QUERY_H

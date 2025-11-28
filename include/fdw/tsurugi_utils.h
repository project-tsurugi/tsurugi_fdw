/*
 * Copyright 2023-2025 Project Tsurugi.
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
 *
 */
#ifndef TSURUGI_UTILS_H
#define TSURUGI_UTILS_H

#include <string>
#include <string_view>
#include "ogawayama/stub/api.h"

#ifdef __cplusplus
extern "C" {
#endif
#include "postgres.h"
#ifdef __cplusplus
}
#endif

#include "tsurugi_fdw.h"

#ifdef __cplusplus
extern "C" {
#endif
#if PG_VERSION_NUM >= 140000
extern void rebuildInsertSql(StringInfo buf, Relation rel,
				 			char *orig_query, List *target_attrs,
				 			int values_end_len, int num_params,
				 			int num_rows);
#endif	/* PG_VERSION_NUM >= 140000 */
#ifdef __cplusplus
}
#endif

bool is_prepare_statement(const char* query);
std::string make_tsurugi_query(std::string_view query_string);

void make_tuple_from_result_row(ResultSetPtr result_set, 
                                        TupleDesc tupleDescriptor,
                                        List* retrieved_attrs,
                                        Datum* row,
                                        bool* is_null);
void create_cursor(ForeignScanState* node);					
void prepare_direct_modify(TgFdwDirectModifyState* dmstate);
void execute_direct_modify(ForeignScanState* node);
#endif  //TSURUGI_UTILS_H

/*
 * Copyright 2023 Project Tsurugi.
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

std::string make_tsurugi_query(std::string_view query_string);
// Datum tsurugi_convert_to_pg(Oid pgtype, ResultSetPtr result_set);

void make_tuple_from_result_row(ResultSetPtr result_set, 
                                        TupleDesc tupleDescriptor,
                                        List* retrieved_attrs,
                                        Datum* row,
                                        bool* is_null,
                                        TgFdwForeignScanState* fsstate);

TgFdwForeignModifyState *create_foreign_modify(EState *estate,
											   RangeTblEntry *rte,
											   ResultRelInfo *resultRelInfo,
											   CmdType operation,
											   Plan *subplan,
											   char *query,
											   List *target_attrs,
											   int len,
											   bool has_returning,
											   List *retrieved_attrs);
											   
TupleTableSlot **execute_foreign_modify(EState *estate,
					   							ResultRelInfo *resultRelInfo,
					   							CmdType operation,
					   							TupleTableSlot **slots,
					   							TupleTableSlot **planSlots,
					   							int *numSlots);
#endif  //TSURUGI_UTILS_H

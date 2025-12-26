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

#ifdef __cplusplus
extern "C" {
#endif
#include "postgres.h"
#include "tsurugi_fdw.h"
#ifdef __cplusplus
}
#endif

#ifdef __cplusplus
extern "C" {
#endif
bool is_prepare_statement(const char* query);
bool tg_create_cursor(ForeignScanState* node);
bool tg_execute_foreign_scan(TgFdwForeignScanState *fsstate, TupleTableSlot *tupleSlot);
bool tg_prepare_direct_modify(TgFdwDirectModifyState *dmstate);
bool tg_execute_direct_modify(ForeignScanState *node);
bool tg_execute_import_foreign_schema(ImportForeignSchemaStmt* stmt, Oid serverOid,
									  List** commands);
bool tg_execute_ddl_statement(Oid server_oid, const char* ddl_statement, char** result);
bool tg_execute_show_tables(Oid server_oid, const char* tg_schema, const char* tg_server,
							const char* mode, bool detail, bool pretty, char** result);
bool tg_execute_verify_tables(Oid server_oid, const char* tg_schema, const char* tg_server,
							  Oid pg_schema_oid, const char* pg_schema, const char* mode,
							  bool detail, bool pretty, char** result);
#ifdef __cplusplus
}
#endif
#endif  //	TSURUGI_UTILS_H

/*
 * Copyright 2025 Project Tsurugi.
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
 *	@file	tsurugi_api.h
 */
#ifndef TSURUGI_API_H
#define TSURUGI_API_H

#ifdef __cplusplus
extern "C" {
#endif

#include "postgres.h"

#include "executor/tuptable.h"
#include "nodes/execnodes.h"
#include "nodes/params.h"
#include "nodes/parsenodes.h"
#include "utils/relcache.h"

#ifdef __cplusplus
#define TG_NOEXCEPT noexcept
#else
#define TG_NOEXCEPT
#endif

/* Tsurugi handles */
typedef struct TGconn TGconn;
typedef struct TGtx TGtx;
typedef struct TGstmt TGstmt;
typedef struct TGresult TGresult;
typedef struct TGtables TGtables;
typedef struct TGtable TGtable;
typedef struct TGcolumn TGcolumn;

/* Status codes */
typedef enum
{
	TG_STATUS_OK = 0,
	TG_STATUS_ERROR,
	TG_STATUS_EXCEPTION,
	TG_STATUS_INVALID_ARG,
	TG_STATUS_NOT_OPEN,
	TG_STATUS_NOT_ACTIVE,
	TG_STATUS_NOT_FOUND,
	TG_STATUS_TSURUGI_ERROR,
	TG_STATUS_SPI_ERROR,
	TG_STATUS_END_OF_ROW,
} TG_STATUS;

const char *tg_get_database_name() TG_NOEXCEPT;
const char *tg_global_error_message(void) TG_NOEXCEPT;

/* -------------------------------------------------------------------------
 * Connection/Transaction functions.
 * ------------------------------------------------------------------------- 
 */
/* Connection */
TGconn* tg_conn_open(
		const char* endpoint, const char *user, const char *password) TG_NOEXCEPT;
TG_STATUS tg_conn_close(TGconn *tg_conn) TG_NOEXCEPT;
void tg_conn_destroy(TGconn *tg_conn) TG_NOEXCEPT;

/* Sub Transaction */
void tg_conn_set_subxact_seen(TGconn *tg_conn, int seen) TG_NOEXCEPT;
int tg_conn_get_subxact_seen(const TGconn *tg_conn) TG_NOEXCEPT;

/* Transaction */
bool tg_conn_tx_active(const TGconn *tg_conn) TG_NOEXCEPT;
TG_STATUS tg_conn_tx_begin(TGconn *tg_conn) TG_NOEXCEPT; /* no-op if already active */
TG_STATUS tg_conn_tx_commit(TGconn *tg_conn) TG_NOEXCEPT; /* no-op if not active */
TG_STATUS tg_conn_tx_rollback(TGconn *tg_conn) TG_NOEXCEPT; /* no-op if not active */

/* Error */
const char *tg_conn_error_message(const TGconn *tg_conn) TG_NOEXCEPT;

/* -------------------------------------------------------------------------
 * Statement functions.
 * ------------------------------------------------------------------------- 
 */
/* Prepare */
TGstmt *tg_stmt_prepare(TGconn *tg_conn, const char *sql) TG_NOEXCEPT;
void tg_stmt_destroy(TGstmt *tg_stmt) TG_NOEXCEPT;

/* Bind */
TG_STATUS tg_stmt_bind_parameters(TGstmt *tg_stmt, ParamListInfo param_linfo) TG_NOEXCEPT;
TG_STATUS tg_stmt_bind_params_for_query(TGstmt* tg_stmt, 
		List* fdwexprs, ExprContext* econtext, List* param_exprs) TG_NOEXCEPT;
TG_STATUS tg_stmt_bind_parameters_for_modify(TGstmt* tg_stmt, 
		Relation rel, List* target_attrs, TupleTableSlot **slots,
		TupleTableSlot **planSlots, AttrNumber *junk_idx) TG_NOEXCEPT;

/* Execute */
TGresult *tg_stmt_execute_query(TGstmt *tg_stmt) TG_NOEXCEPT;
TG_STATUS tg_stmt_execute_statement(TGstmt *tg_stmt, size_t *num_rows) TG_NOEXCEPT;

/* Error */
const char *tg_stmt_error_message(const TGstmt *tg_stmt) TG_NOEXCEPT;

/* -------------------------------------------------------------------------
 * ResultSet functions.
 * ------------------------------------------------------------------------- 
 */
void tg_result_destroy(TGresult *tg_result) TG_NOEXCEPT;
TG_STATUS tg_result_next(TGresult *tg_result) TG_NOEXCEPT;
TG_STATUS tg_result_get_tuple(TGresult *tg_result,
					List *retrieved_attrs,
					TupleTableSlot *tupleSlot) TG_NOEXCEPT;
const char *tg_result_error_message(const TGresult *tg_rs) TG_NOEXCEPT;

/* -------------------------------------------------------------------------
 * UDF functions
 * ------------------------------------------------------------------------- 
 */
typedef struct
{
	const char *schema_name;
	const char *server_name;
	char *mode;
	bool detail;
	bool pretty;
} TG_SHOW_TABLE_PARAM;

typedef struct
{
	const char *remote_schema;
	const char *server_name;
	Oid server_id;
	const char *local_schema;
	Oid local_schema_oid;
	char *mode;
	bool detail;
	bool pretty;
} TG_VERIFY_TABLE_PARAM;

TG_STATUS tg_exec_import_foreign_schema(TGconn *tg_conn,
								ImportForeignSchemaStmt *stmt,
								Oid serverOid,
								List **commands) TG_NOEXCEPT;

TG_STATUS tg_exec_show_tables(TGconn *tg_conn,
						TG_SHOW_TABLE_PARAM *param,
						char **result_json) TG_NOEXCEPT;

TG_STATUS tg_exec_verify_tables(TGconn *tg_conn,
						TG_VERIFY_TABLE_PARAM *param,
						char **result_json) TG_NOEXCEPT;
#ifdef __cplusplus
} /* extern "C" */
#endif
#endif /* TSURUGI_API_H */

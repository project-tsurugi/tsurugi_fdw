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

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif
#include "postgres.h"

const char* tg_get_error_message();
bool tg_do_connect(Oid server_oid);
bool tg_do_begin(Oid server_oid);
bool tg_do_commit();
bool tg_do_rollback();

/** ===========================================================================
 * 
 */
#if 0
/* Tsurugi handles */
typedef struct TGconn TGconn;
typedef struct TGtx TGtx;
typedef struct TGstmt TGstmt;
typedef struct TGresult TGresult;

/* Status codes */
typedef enum {
    TG_STATUS_OK = 0,
    TG_STATUS_ERROR = 1,
    TG_STATUS_INVALID_ARG = 2,
    TG_STATUS_NOT_OPEN = 3,
    TG_STATUS_BUSY = 4,
    TG_STATUS_NOT_FOUND = 5,
    TG_STATUS_TSURUGI_ERROR = 6
} TG_STATUS;

/** ===========================================================================
 * 
 *  Connection
 * 
 */
const char*	tg_conn_last_error_message(const TGconn* conn);
bool        tg_conn_is_connect(const TGconn* conn);
TGconn*     tg_conn_new(Oid server_oid, const char* db_name);
TG_STATUS   tg_conn_connect(TGconn* conn);
void        tg_conn_close(TGconn* conn);
void        tg_conn_free(TGconn* conn);

/** ===========================================================================
 * 
 *  Transaction
 * 
 */
/* Transaction (安全のため、free時に未コミットならrollback) */
const char*	tg_tx_last_error_message(const TGtx* tx);
bool        tg_tx_is_active(const TGtx* tx);
TGtx*       tg_tx_new(TGconn* conn);
TG_STATUS   tg_tx_begin(TGtx* tx);
TG_STATUS   tg_tx_execute_statement(TGtx* tx, const char* sql, size_t* num_rows);
TG_STATUS   tg_tx_commit(TGtx* tx);
TG_STATUS   tg_tx_rollback(TGtx* tx);
void        tg_tx_free(TGtx* tx);         /* if active -> rollback */

void        tg_do_begin(TGconn* conn);
void        tg_do_sql_command(TGconn* conn, const char* sql, size_t* num_tuples);
void        tg_do_commit(TGconn* conn);
void        tg_do_rollback(TGconn* conn);

/** ===========================================================================
 * 
 *  Prepared Statement
 * 
 */
TGstmt*		tg_stmt_new(TGconn* conn, const char* sql_utf8);
void        tg_stmt_free(TGstmt* stmt);
TG_STATUS   tg_stmt_reset(TGstmt* stmt);
TG_STATUS   tg_stmt_clear_bindings(TGstmt* stmt);

/* Bind by 1-based index */
TG_STATUS tg_stmt_bind_null  (TGstmt* stmt, int index);
TG_STATUS tg_stmt_bind_int64 (TGstmt* stmt, int index, int64_t v);
TG_STATUS tg_stmt_bind_double(TGstmt* stmt, int index, double v);
TG_STATUS tg_stmt_bind_text  (TGstmt* stmt, int index, const char* s_utf8, size_t len);
TG_STATUS tg_stmt_bind_blob  (TGstmt* stmt, int index, const void* data, size_t len);

/* Named parameters → index解決してから bind を使う */
TG_STATUS tg_stmt_param_index(TGstmt* stmt, const char* name_utf8, int* out_index);

/* Execute */
TG_STATUS tg_stmt_execute_update(TGstmt* stmt, int* out_affected_rows);
TG_STATUS tg_stmt_execute_query (TGstmt* stmt, TGresult** out_rs);

/* Statement last error */
TG_STATUS   tg_stmt_last_error_code(const TGstmt* stmt);
const char* tg_stmt_last_error_message(const TGstmt* stmt);

/** ===========================================================================
 * 
 *  ResultSet
 * 
 */
TG_STATUS   tg_result_next(TGresult* rs, int* out_has_row); /* 1: row, 0: done */
int         tg_result_column_count(const TGresult* rs);
const char* tg_result_column_name(const TGresult* rs, int index);
void        tg_result_free(TGresult* rs);

/* Value getters（nullは is_null で判定。OK時に *out に設定） */
TG_STATUS tg_result_is_null   (const TGresult* rs, int index, int* out_is_null); /* 1/0 */
TG_STATUS tg_result_get_int64 (const TGresult* rs, int index, int64_t* out);
TG_STATUS tg_result_get_double(const TGresult* rs, int index, double* out);

/* テキスト／BLOBは「次の next()/reset まで有効」なビューを返す（必要ならコピー） */
TG_STATUS tg_result_get_text(const TGresult* rs, int index, 
                            const char** out_ptr, size_t* out_len);
TG_STATUS tg_result_get_blob(const TGresult* rs, int index, 
                            const void** out_ptr, size_t* out_len);

/* Result last error */
TG_STATUS   tg_result_last_error_code(const TGresult* rs);
const char* tg_result_last_error_message(const TGresult* rs);
#endif
#ifdef __cplusplus
} /* extern "C" */
#endif

#endif /* TSURUGI_API_H */

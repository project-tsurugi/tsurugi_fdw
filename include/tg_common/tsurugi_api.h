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
#include "executor/tuptable.h"
#include "nodes/params.h"

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
    TG_STATUS_TSURUGI_ERROR = 6,
    TG_STATUS_END_OF_ROW = 7
} TG_STATUS;

/** ===========================================================================
 * 
 *  Connection Functions.
 * 
 */
TGconn*     tg_conn_new(Oid server_oid);
TG_STATUS   tg_conn_connect(TGconn* tg_conn);
bool        tg_conn_is_connected(const TGconn* tg_conn);
void        tg_conn_close(TGconn* tg_conn);
const char*	tg_conn_error_message(const TGconn* tg_conn);

/** ===========================================================================
 * 
 *  Transaction Functions.
 * 
 */
TGtx*       tg_tx_new(TGconn* tg_conn);
void        tg_tx_free(TGtx* tg_tx);         /* if active -> rollback */
TG_STATUS   tg_tx_begin(TGtx* tg_tx);
bool        tg_tx_is_active(const TGtx* tg_tx);
TG_STATUS   tg_tx_commit(TGtx* tg_tx);
TG_STATUS   tg_tx_rollback(TGtx* tg_tx);
const char*	tg_tx_error_message(const TGtx* tg_tx);

/** ===========================================================================
 * 
 *  Statement Functions.
 * 
 */
TGstmt*     tg_stmt_new(TGtx* tg_tx, const char* sql);
void        tg_stmt_free(TGstmt* tg_stmt);

/* Parameters */
TG_STATUS   tg_stmt_bind_parameters(TGstmt* tg_stmt, ParamListInfo param_linfo);
TG_STATUS   tg_stmt_clear_bindings(TGstmt* tg_stmt);

/* Execute */
TG_STATUS   tg_stmt_execute_statement(TGstmt* tg_stmt, size_t* num_rows);
TG_STATUS   tg_stmt_execute_query (TGstmt* tg_stmt, TGresult** tg_result);

const char* tg_stmt_error_message(const TGstmt* tg_stmt);

/** ===========================================================================
 * 
 *  ResultSet Functions.
 * 
 */
void        tg_result_free(TGresult* tg_result);
TG_STATUS   tg_result_next(TGresult* tg_result, bool* has_row); /* 1: row, 0: done */
TG_STATUS   tg_result_get_tuple(TGresult* tg_result, List* retrieved_attrs, 
                                TupleTableSlot* tupleSlot);
const char* tg_result_error_message(const TGresult* tg_rs);

#ifdef __cplusplus
} /* extern "C" */
#endif
#endif /* TSURUGI_API_H */

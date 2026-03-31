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
 *	@file	connection.h
 */
#ifndef CONNECTION_H
#define CONNECTION_H

#include "tsurugi_api.h"
#include "foreign/foreign.h"

#ifdef __cplusplus
exern "C" {
#endif

/*
 * tsurugi_get_connection
 *		Get a connection to the specified foreign server.
 *
 * Returns a cached connection if one exists for the server, otherwise
 * creates a new connection. If no transaction is active on the connection,
 * starts a new remote transaction automatically.
 *
 * The connection is tied to the current PostgreSQL transaction and will
 * be automatically committed or rolled back by transaction callbacks.
 * No explicit release or cleanup is required by the caller.
 *
 * Multiple calls within the same transaction return the same TGconn*.
 *
 * Parameters:
 *   serverid - Oid of the ForeignServer to connect to
 *
 * Returns:
 *   TGconn handle (never NULL; errors are raised)
 *
 * Errors:
 *   - ERRCODE_FDW_OPTION_NAME_NOT_FOUND if required options are missing
 *   - ERRCODE_FDW_UNABLE_TO_ESTABLISH_CONNECTION if connection fails
 *   - ERRCODE_FDW_UNABLE_TO_CREATE_EXECUTION if transaction start fails
 *
 * Example:
 *   BEGIN;
 *     TGconn *conn = tsurugi_get_connection(serverid);
 *     TGstmt *stmt = tg_stmt_prepare(conn, sql);
 *     TGresult *res = tg_stmt_execute_query(stmt);
 *     // ... use result ...
 *     tg_result_destroy(res);
 *     tg_stmt_destroy(stmt);
 *     // No need to release connection
 *   COMMIT; // Connection automatically committed and cleaned up
 */
extern TGconn *tsurugi_get_connection(Oid serverid);

/*
 * Shutdown function (internal use only)
 *
 * Registered as before_shmem_exit callback to clean up all connections
 * on process exit.
 */
extern void tsurugi_connection_exit(int code, Datum arg);

extern void tsurugi_do_sql_command(TGconn *conn, const char *sql);
extern void tsurugi_do_sql_command2(Oid serverid, const char *sql);

#ifdef __cplusplus
}
#endif
#endif	/* CONNECTION_H */
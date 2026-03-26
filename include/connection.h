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

#ifdef __cplusplus
extern "C" {
#endif	

#include "tsurugi_api.h"
#include "foreign/foreign.h"

/*
 * Initialize connection cache and register callbacks.
 *
 * Should be called from _PG_init().
 */
extern void tsurugi_init_connections(void);

/*
 * Get a cached connection and ensure remote tx is started.
 *
 * Key: (serverid, userid) from server/user mapping.
 * Remote tx will be committed/rolled back by xact callback.
 *
 * Automatically starts remote tx if not already started in current xact.
 */
extern TGconn *tsurugi_get_connection(ForeignServer *server,
									  UserMapping *user);

/*
 * Invalidate cached connection for (serverid, userid).
 *
 * Intended for error paths; must not ereport(ERROR) if called from
 * abort callbacks.
 */
extern void tsurugi_invalidate_connection(Oid serverid, Oid userid);

TGconn *tsurugi_get_connection(ForeignServer *server, UserMapping *user);
void tsurugi_do_sql_command(TGconn *conn, const char *sql);

#ifdef __cplusplus
}
#endif
#endif	/* CONNECTION_H */
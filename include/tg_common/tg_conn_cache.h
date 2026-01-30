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
 * Portions Copyright (c) 1996-2023, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, The Regents of the University of California
 *
 * @file tg_conn_cache.h
 */
#ifndef TG_CONN_CACHE_H
#define TG_CONN_CACHE_H

#include "postgres.h"
#include "tg_common/tsurugi_api.h"

extern void tg_conn_cache_init(void);

extern TGconn *tg_get_or_open_connection(Oid serverid, Oid userid,
										 const char *endpoint);

extern TGconn *tg_get_connection_for_xact(Oid serverid, Oid userid,
										 const char *endpoint);

extern void tg_invalidate_connection(Oid serverid, Oid userid);

#endif  /* TG_CONN_CACHE_H */

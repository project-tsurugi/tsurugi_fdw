/*
 * Copyright 2024-2026 Project Tsurugi.
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
 *	@file	connection.c
 */
/*-------------------------------------------------------------------------
 *
 * connection.c
 *    Tsurugi FDW connection management
 *
 * Responsibilities:
 *  - Maintain a per-backend connection cache keyed by ForeignServer Oid.
 *  - Automatically start a remote transaction on the first foreign access
 *    within a PostgreSQL top-level transaction.
 *  - Commit/rollback the remote transaction at PostgreSQL transaction end.
 *  - React to ALTER SERVER / user mapping changes via syscache invalidation:
 *      * If idle, disconnect immediately so new options take effect next time.
 *      * If in-transaction, mark invalidated and disconnect at xact end.
 *  - Prohibit SAVEPOINT/subtransactions for foreign table access:
 *      * Any foreign access while GetCurrentTransactionNestLevel() > 1 ERRORs.
 *
 * Notes:
 *  - Only public function in this file is tsurugi_get_connection(Oid).
 *  - SubXactCallback is intentionally not used (SAVEPOINT is forbidden).
 *  - "endpoint" and "user" options are allowed to be NULL (not an error here).
 *    If the underlying Tsurugi client rejects NULL, connection establishment
 *    fails and we report it as FDW connection failure.
 *
 *-------------------------------------------------------------------------
 */
#include "postgres.h"

#include "access/xact.h"
#include "catalog/pg_foreign_server.h"
#include "catalog/pg_user_mapping.h"
#include "commands/defrem.h"
#include "connection.h"
#include "foreign/foreign.h"
#include "miscadmin.h"
#include "storage/ipc.h"
#include "tsurugi_fdw.h"
#include "utils/hsearch.h"
#include "utils/inval.h"
#include "utils/memutils.h"
#include "utils/syscache.h"

/*-------------------------------------------------------------------------
 * Connection cache structures
 *-------------------------------------------------------------------------
 */

typedef struct ConnCacheKey
{
	Oid serverid; /* ForeignServer Oid */
} ConnCacheKey;

typedef struct ConnCacheEntry
{
	ConnCacheKey key;  /* hash key (must be first) */
	TGconn		*conn; /* Tsurugi connection handle (or NULL) */

	/* Binding of remote transaction state to a local top-level transaction */
	TransactionId xact_id;	 /* InvalidTransactionId if idle */
	int			  xact_level; /* nest level where remote xact began (normally 1) */
	bool		  have_error; /* reserved; currently always false */

	/* Invalidation handling */
	bool	invalidated;		/* reconnect required after xact end */
	uint32	server_hashvalue; /* syscache hash for FOREIGNSERVEROID */
} ConnCacheEntry;

static HTAB *ConnectionHash = NULL;

/* Callback registration guards */
static bool xact_callback_registered  = false;
static bool inval_callback_registered = false;
static bool exit_registered			  = false;

/*-------------------------------------------------------------------------
 * Internal prototypes (non-callback)
 *-------------------------------------------------------------------------
 */
static void			   connection_cache_init(void);
static ConnCacheEntry *get_connection_entry(Oid serverid);
static void			   make_new_connection(ConnCacheEntry *entry, Oid serverid);
static void			   begin_remote_xact(ConnCacheEntry *entry);
static void			   disconnect_connection(ConnCacheEntry *entry);
static void			   reset_xact_state(ConnCacheEntry *entry);
static void			   apply_pending_invalidation(ConnCacheEntry *entry);

static char *get_server_option(ForeignServer *server, const char *optname);
static char *get_user_mapping_option(UserMapping *user, const char *optname);

/*-------------------------------------------------------------------------
 * Callback prototypes (grouped)
 *-------------------------------------------------------------------------
 */
static void tsurugi_fdw_xact_callback(XactEvent event, void *arg);
static void tsurugi_fdw_inval_callback(Datum arg, int cacheid, uint32 hashvalue);
static void tsurugi_fdw_exit_callback(int code, Datum arg);

/*-------------------------------------------------------------------------
 * Public API
 *-------------------------------------------------------------------------
 */

/*
 * tsurugi_get_connection
 *    Return a cached connection for the given foreign server, creating one if
 *    needed. Also ensures a remote transaction exists for the current local
 *    transaction.
 *
 * Policy:
 *  - SAVEPOINT/subtransactions are prohibited. If called within a
 *    subtransaction (nest level > 1), raise ERROR.
 */
TGconn *
tsurugi_get_connection(Oid serverid)
{
	ConnCacheEntry *entry;

	connection_cache_init();
	entry = get_connection_entry(serverid);
	begin_remote_xact(entry);

	return entry->conn;
}

/*-------------------------------------------------------------------------
 * Internal functions
 *-------------------------------------------------------------------------
 */

/*
 * connection_cache_init
 *    Initialize the connection hash table and register required callbacks.
 */
static void
connection_cache_init(void)
{
	HASHCTL ctl;

	if (ConnectionHash != NULL)
		return;

	memset(&ctl, 0, sizeof(ctl));
	ctl.keysize	  = sizeof(ConnCacheKey);
	ctl.entrysize = sizeof(ConnCacheEntry);
	ctl.hcxt	  = TopMemoryContext;

	ConnectionHash = hash_create("tsurugi_fdw connection cache",
								 8,
								 &ctl,
								 HASH_ELEM | HASH_BLOBS | HASH_CONTEXT);

	/*
	 * Register only needed callbacks:
	 * - xact: commit/rollback and deferred disconnect
	 * - inval: react to ALTER SERVER / user mapping changes
	 * - exit: ensure external resources are released
	 */
	if (!xact_callback_registered)
	{
		RegisterXactCallback(tsurugi_fdw_xact_callback, NULL);
		xact_callback_registered = true;
	}

	if (!inval_callback_registered)
	{
		CacheRegisterSyscacheCallback(FOREIGNSERVEROID,
									  tsurugi_fdw_inval_callback,
									  (Datum) 0);
		CacheRegisterSyscacheCallback(USERMAPPINGOID,
									  tsurugi_fdw_inval_callback,
									  (Datum) 0);
		inval_callback_registered = true;
	}

	if (!exit_registered)
	{
		before_shmem_exit(tsurugi_fdw_exit_callback, (Datum) 0);
		exit_registered = true;
	}
}

/*
 * get_connection_entry
 *    Lookup (or create) a cache entry for serverid and ensure entry->conn exists.
 *
 * Important:
 *  - Never disconnect here even if entry->invalidated is set.
 *    Disconnecting mid-transaction can break transaction integrity.
 */
static ConnCacheEntry *
get_connection_entry(Oid serverid)
{
	ConnCacheKey	key;
	ConnCacheEntry *entry;
	bool			found;

	key.serverid = serverid;

	entry = (ConnCacheEntry *) hash_search(ConnectionHash, &key, HASH_ENTER, &found);

	if (!found)
	{
		entry->conn		   = NULL;
		entry->xact_id	   = InvalidTransactionId;
		entry->xact_level  = 0;
		entry->have_error  = false;
		entry->invalidated = false;

		entry->server_hashvalue = GetSysCacheHashValue1(FOREIGNSERVEROID,
														ObjectIdGetDatum(serverid));
	}

	if (entry->conn == NULL)
		make_new_connection(entry, serverid);

	return entry;
}

/*
 * make_new_connection
 *    Establish a new connection using current ForeignServer/UserMapping options.
 *
 * Note:
 *  - endpoint and username are allowed to be NULL by specification.
 *    We pass them as-is to tg_conn_open(). If the client rejects NULL, it will
 *    fail and we report an FDW connection error.
 */
static void
make_new_connection(ConnCacheEntry *entry, Oid serverid)
{
	ForeignServer *server;
	UserMapping	  *um;
	char		  *endpoint;
	char		  *username;
	char		  *password;

	Assert(entry->conn == NULL);

	server = GetForeignServer(serverid);
	um	   = GetUserMapping(GetUserId(), serverid);

	endpoint = get_server_option(server, "dbname");	/* may be NULL */
	username = get_user_mapping_option(um, "user");		/* may be NULL */
	password = get_user_mapping_option(um, "password"); /* may be NULL */

	elog(DEBUG3,
		 "tsurugi_fdw: connecting to server \"%s\" (endpoint=%s, user=%s)",
		 server->servername,
		 endpoint ? endpoint : "(null)",
		 username ? username : "(null)");

	entry->conn = tg_conn_open(endpoint, username, password);
	if (entry->conn == NULL)
	{
		ereport(ERROR,
				(errcode(ERRCODE_FDW_UNABLE_TO_ESTABLISH_CONNECTION),
				 errmsg("%s", tg_global_error_message()),
				 errdetail("Connection options used: dbname=%s, user=%s",
						   endpoint ? endpoint : "(null)",
						   username ? username : "(null)")));
	}
}

/*
 * begin_remote_xact
 *    Start a remote transaction if not yet started for the current local xact.
 *
 * Policy:
 *  - Subtransactions are prohibited. Foreign access at nest level > 1 ERRORs.
 */
static void
begin_remote_xact(ConnCacheEntry *entry)
{
	const int	  curlevel = GetCurrentTransactionNestLevel();
	TransactionId curid;

	if (curlevel > 1)
	{
		ereport(ERROR,
				(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
				 errmsg("cannot access foreign table in a subtransaction"),
				 errdetail("Tsurugi does not support savepoints/subtransactions."),
				 errhint("Do not access foreign tables inside SAVEPOINT blocks "
						 "or exception subtransactions.")));
	}

	curid = GetCurrentTransactionId();

	/* If we already started a remote xact for this local xact, do nothing. */
	if (TransactionIdIsValid(entry->xact_id))
	{
		if (TransactionIdEquals(entry->xact_id, curid))
			return;

		/*
		 * Defensive cleanup: not expected in normal flow.
		 * Reset and start a new remote transaction below.
		 */
		elog(WARNING,
			 "tsurugi_fdw: unexpected transaction state, resetting remote xact binding");
		reset_xact_state(entry);
	}

	elog(DEBUG3, "tsurugi_fdw: starting remote transaction on connection %p", entry->conn);

	if (tg_conn_tx_begin(entry->conn) != TG_STATUS_OK)
	{
		ereport(ERROR,
				(errcode(ERRCODE_FDW_UNABLE_TO_CREATE_EXECUTION),
				 errmsg("%s", tg_conn_error_message(entry->conn))));
	}

	entry->xact_id	  = curid;
	entry->xact_level = curlevel; /* always 1 here */
	entry->have_error = false;
}

/*
 * disconnect_connection
 *    Close/destroy the underlying TGconn and reset local state.
 */
static void
disconnect_connection(ConnCacheEntry *entry)
{
	if (entry->conn != NULL)
	{
		elog(DEBUG3, "tsurugi_fdw: disconnecting connection %p", entry->conn);
		tg_conn_close(entry->conn);
		tg_conn_destroy(entry->conn);
		entry->conn = NULL;
	}

	reset_xact_state(entry);
}

/*
 * reset_xact_state
 *    Clear transaction binding fields. Does not touch entry->invalidated.
 */
static void
reset_xact_state(ConnCacheEntry *entry)
{
	entry->xact_id	  = InvalidTransactionId;
	entry->xact_level = 0;
	entry->have_error = false;
}

/*
 * apply_pending_invalidation
 *    If the entry was marked invalidated during a transaction, disconnect now.
 */
static void
apply_pending_invalidation(ConnCacheEntry *entry)
{
	if (entry->invalidated)
	{
		elog(DEBUG3,
			 "tsurugi_fdw: closing invalidated connection %p at xact end",
			 entry->conn);
		disconnect_connection(entry);
		entry->invalidated = false;
	}
}

/*
 * get_server_option / get_user_mapping_option
 *    Helper functions to read string FDW options from catalog objects.
 */
static char *
get_server_option(ForeignServer *server, const char *optname)
{
	ListCell *lc;

	foreach (lc, server->options)
	{
		DefElem *def = (DefElem *) lfirst(lc);

		if (strcmp(def->defname, optname) == 0)
			return defGetString(def);
	}

	return NULL;
}

static char *
get_user_mapping_option(UserMapping *user, const char *optname)
{
	ListCell *lc;

	foreach (lc, user->options)
	{
		DefElem *def = (DefElem *) lfirst(lc);

		if (strcmp(def->defname, optname) == 0)
			return defGetString(def);
	}

	return NULL;
}

/*-------------------------------------------------------------------------
 * Callbacks
 *-------------------------------------------------------------------------
 */

/*
 * tsurugi_fdw_xact_callback
 *    PostgreSQL transaction end callback.
 *
 * Responsibilities:
 *  - PRE_COMMIT: commit remote transaction (if active)
 *  - ABORT: rollback remote transaction (best-effort)
 *  - COMMIT/ABORT: clear binding and apply deferred invalidation disconnect
 *
 * Requirement:
 *  - Do not use "fall through" to avoid compiler warnings.
 */
static void
tsurugi_fdw_xact_callback(XactEvent event, void *arg)
{
	HASH_SEQ_STATUS scan;
	ConnCacheEntry *entry;

	(void) arg;

	if (ConnectionHash == NULL)
		return;

	hash_seq_init(&scan, ConnectionHash);
	while ((entry = (ConnCacheEntry *) hash_seq_search(&scan)) != NULL)
	{
		/* Only entries participating in the current local transaction. */
		if (!TransactionIdIsValid(entry->xact_id))
			continue;

		/* If connection is gone unexpectedly, just reset and continue. */
		if (entry->conn == NULL)
		{
			reset_xact_state(entry);
			entry->invalidated = false;
			continue;
		}

		switch (event)
		{
			case XACT_EVENT_PRE_COMMIT:
			case XACT_EVENT_PARALLEL_PRE_COMMIT:
				if (!entry->have_error && tg_conn_tx_active(entry->conn))
				{
					elog(DEBUG3,
						 "tsurugi_fdw: committing remote transaction on %p",
						 entry->conn);
					if (tg_conn_tx_commit(entry->conn) != TG_STATUS_OK)
					{
						ereport(ERROR,
								(errcode(ERRCODE_FDW_UNABLE_TO_CREATE_EXECUTION),
								 errmsg("%s", tg_conn_error_message(entry->conn))));
					}
				}
				break;

			case XACT_EVENT_ABORT:
			case XACT_EVENT_PARALLEL_ABORT:
				if (tg_conn_tx_active(entry->conn))
				{
					elog(DEBUG3,
						 "tsurugi_fdw: rolling back remote transaction on %p",
						 entry->conn);
					if (tg_conn_tx_rollback(entry->conn) != TG_STATUS_OK)
					{
						/* Do not fail abort; log warning and continue. */
						ereport(WARNING,
								(errmsg("%s", tg_conn_error_message(entry->conn))));
					}
				}

				reset_xact_state(entry);
				apply_pending_invalidation(entry);
				break;

			case XACT_EVENT_COMMIT:
			case XACT_EVENT_PARALLEL_COMMIT:
				reset_xact_state(entry);
				apply_pending_invalidation(entry);
				break;

			case XACT_EVENT_PREPARE:
				ereport(WARNING,
						(errmsg("tsurugi_fdw does not support two-phase commit")));
				break;

			default:
				break;
		}
	}
}

/*
 * tsurugi_fdw_inval_callback
 *    Syscache invalidation callback for ForeignServer/UserMapping changes.
 *
 * Behavior:
 *  - If idle: disconnect immediately so new options take effect next time.
 *  - If in a transaction: mark invalidated; disconnect at xact end.
 *
 * Note:
 *  - USERMAPPINGOID: invalidate all entries conservatively because the cache
 *    key is only serverid (not per user).
 */
static void
tsurugi_fdw_inval_callback(Datum arg, int cacheid, uint32 hashvalue)
{
	HASH_SEQ_STATUS scan;
	ConnCacheEntry *entry;

	(void) arg;

	Assert(cacheid == FOREIGNSERVEROID || cacheid == USERMAPPINGOID);

	if (ConnectionHash == NULL)
		return;

	elog(DEBUG3,
		 "tsurugi_fdw: inval callback cacheid=%d hashvalue=%u",
		 cacheid,
		 hashvalue);

	hash_seq_init(&scan, ConnectionHash);
	while ((entry = (ConnCacheEntry *) hash_seq_search(&scan)) != NULL)
	{
		bool match = false;

		if (entry->conn == NULL)
			continue;

		if (hashvalue == 0)
		{
			/* Global invalidation */
			match = true;
		}
		else if (cacheid == FOREIGNSERVEROID)
		{
			match = (entry->server_hashvalue == hashvalue);
		}
		else
		{
			/* USERMAPPINGOID change: invalidate all (conservative) */
			match = true;
		}

		if (!match)
			continue;

		entry->invalidated = true;

		if (!TransactionIdIsValid(entry->xact_id))
		{
			elog(DEBUG3,
				 "tsurugi_fdw: closing idle connection %p due to invalidation",
				 entry->conn);
			disconnect_connection(entry);
			entry->invalidated = false;
		}
		else
		{
			elog(DEBUG3,
				 "tsurugi_fdw: deferring disconnect of in-xact connection %p",
				 entry->conn);
		}
	}
}

/*
 * tsurugi_fdw_exit_callback
 *    Backend exit callback. Close all cached connections.
 */
static void
tsurugi_fdw_exit_callback(int code, Datum arg)
{
	HASH_SEQ_STATUS scan;
	ConnCacheEntry *entry;

	(void) code;
	(void) arg;

	if (ConnectionHash == NULL)
		return;

	hash_seq_init(&scan, ConnectionHash);
	while ((entry = (ConnCacheEntry *) hash_seq_search(&scan)) != NULL)
	{
		if (entry->conn != NULL)
		{
			elog(DEBUG3,
				 "tsurugi_fdw: closing connection %p on backend exit",
				 entry->conn);
			tg_conn_close(entry->conn);
			tg_conn_destroy(entry->conn);
			entry->conn = NULL;
		}
	}
}

/*
 * Convenience subroutine to issue a non-data-returning SQL command to remote
 */
void
tsurugi_do_sql_command(TGconn *conn, const char *sql)
{
	TG_STATUS tg_status;
	TGstmt	 *tg_stmt;
	size_t	  num_rows;

	elog(DEBUG3, "tsurugi_fdw: %s\nsql:\n%s", __func__, sql);

	tg_stmt = tg_stmt_prepare(conn, sql);
	if (!tg_stmt)
		elog(ERROR, "%s", tg_global_error_message());

	tg_status = tg_stmt_execute_statement(tg_stmt, &num_rows);
	if (tg_status != TG_STATUS_OK)
		elog(ERROR, "%s", tg_stmt_error_message(tg_stmt));
}

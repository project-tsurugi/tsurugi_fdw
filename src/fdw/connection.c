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
 *		  Tsurugi FDW connection management
 *
 * Manages a cache of TGconn handles, keyed by ForeignServer Oid.
 * Connections are automatically tied to PostgreSQL transaction lifecycle.
 *
 * Connection lifecycle:
 * 1. First tsurugi_get_connection() in a transaction:
 *    - Creates connection if needed
 *    - Starts remote transaction via tg_conn_tx_begin()
 *    - Sets xact_id to current transaction ID
 *
 * 2. Subsequent tsurugi_get_connection() calls:
 *    - Returns same connection
 *    - No additional transaction start
 *
 * 3. On COMMIT:
 *    - Commits remote transaction via tg_conn_tx_commit()
 *    - Resets xact_id to InvalidTransactionId
 *    - Disconnects connection if invalidated
 *
 * 4. On ROLLBACK:
 *    - Rolls back remote transaction via tg_conn_tx_rollback()
 *    - Resets xact_id to InvalidTransactionId
 *    - Disconnects connection if invalidated
 *
 * Invalidation handling:
 * - ALTER SERVER/DROP SERVER triggers syscache invalidation callback
 * - Connections with matching server_hashvalue are marked invalidated
 * - If xact_id is valid (in transaction), connection is ONLY marked
 *   (NOT disconnected immediately to preserve transaction integrity)
 * - If xact_id is invalid (idle), connection is disconnected immediately
 * - Invalidated connections are disconnected at transaction end
 * (COMMIT/ROLLBACK)
 *
 * Example scenario:
 *   BEGIN;
 *     INSERT INTO t1 VALUES (1), (2);        -- connection created, tx started
 *     ALTER SERVER s1 OPTIONS (SET ...);     -- connection marked invalidated
 *     SELECT * FROM t1;                      -- uses SAME connection (sees
 * INSERT) COMMIT;                                  -- connection disconnected
 * here SELECT * FROM t1;                        -- reconnects with new
 * settings
 *
 *-------------------------------------------------------------------------
 */
#include "postgres.h"

#include "access/htup_details.h"
#include "access/xact.h"
#include "catalog/pg_foreign_server.h"
#include "catalog/pg_user_mapping.h"
#include "commands/defrem.h"
#include "connection.h"
#include "foreign/foreign.h"
#include "mb/pg_wchar.h"
#include "miscadmin.h"
#include "storage/ipc.h"
#include "tsurugi_fdw.h"
#include "utils/builtins.h"
#include "utils/hsearch.h"
#include "utils/inval.h"
#include "utils/memutils.h"
#include "utils/syscache.h"

/*
 * Connection cache key
 */
typedef struct ConnCacheKey
{
	Oid serverid; /* foreign server OID */
} ConnCacheKey;

/*
 * Connection cache entry
 *
 * This structure is completely hidden from client code.
 * Only TGconn* is exposed via tsurugi_get_connection().
 */
typedef struct ConnCacheEntry
{
	ConnCacheKey key;  /* hash key (must be first) */
	TGconn		*conn; /* connection to foreign server, or NULL */

	/* Transaction state tracking */
	TransactionId xact_id; /* ID of current transaction (InvalidTransactionId
							  if idle) */
	int	 xact_depth;	   /* transaction nesting level */
	bool have_error;	   /* true if transaction had an error */

	/* Invalidation handling */
	bool   invalidated; /* true if reconnect is needed at transaction end */
	uint32 server_hashvalue; /* hash value of server OID for invalidation */
} ConnCacheEntry;

/* Connection cache (initialized on first use) */
static HTAB *ConnectionHash = NULL;

/* Flags to track callback registration */
static bool xact_callback_registered	= false;
static bool subxact_callback_registered = false;
static bool inval_callback_registered	= false;
static bool exit_registered				= false;

/* Internal function prototypes */
static void make_new_connection(ConnCacheEntry *entry, Oid serverid);
static void begin_remote_xact(ConnCacheEntry *entry);
static void disconnect_connection(ConnCacheEntry *entry);
static ConnCacheEntry *get_connection_entry(Oid serverid);
static void			   connection_cache_init(void);
static void			   tsurugi_xact_callback(XactEvent event, void *arg);
static void			   tsurugi_subxact_callback(
		SubXactEvent	 event,
		SubTransactionId mySubid,
		SubTransactionId parentSubid,
		void			*arg);
static void	 tsurugi_inval_callback(Datum arg, int cacheid, uint32 hashvalue);
static char *get_server_option(ForeignServer *server, const char *optname);
static char *get_user_mapping_option(UserMapping *user, const char *optname);

/*
 * tsurugi_get_connection
 *		Get a connection to foreign server (reuse from cache if available)
 */
TGconn *
tsurugi_get_connection(Oid serverid)
{
	ConnCacheEntry *entry;

	/* Ensure callback registration */
	connection_cache_init();

	/* Get cache entry (creates new entry if not found) */
	entry = get_connection_entry(serverid);

	/* Start remote transaction if not already started in this transaction */
	begin_remote_xact(entry);

	return entry->conn;
}

/*
 * tsurugi_connection_exit
 *		Cleanup all connections on process exit
 */
void
tsurugi_connection_exit(int code, Datum arg)
{
	HASH_SEQ_STATUS scan;
	ConnCacheEntry *entry;

	if (!ConnectionHash)
		return;

	hash_seq_init(&scan, ConnectionHash);
	while ((entry = (ConnCacheEntry *) hash_seq_search(&scan)) != NULL)
	{
		if (entry->conn)
		{
			elog(DEBUG3,
				 "tsurugi_fdw: closing connection %p on exit",
				 entry->conn);
			tg_conn_close(entry->conn);
			tg_conn_destroy(entry->conn);
			entry->conn = NULL;
		}
	}
}

/* ================================================================
 * Internal functions
 * ================================================================ */

/*
 * connection_cache_init
 *		Initialize connection cache and register callbacks
 */
static void
connection_cache_init(void)
{
	HASHCTL ctl;

	/* Already initialized? */
	if (ConnectionHash)
		return;

	/* Create connection cache hash table */
	memset(&ctl, 0, sizeof(ctl));
	ctl.keysize	  = sizeof(ConnCacheKey);
	ctl.entrysize = sizeof(ConnCacheEntry);
	ctl.hcxt	  = TopMemoryContext;

	ConnectionHash = hash_create(
			"Tsurugi FDW connections",
			8,
			&ctl,
			HASH_ELEM | HASH_BLOBS | HASH_CONTEXT);

	/* Register transaction callback */
	if (!xact_callback_registered)
	{
		RegisterXactCallback(tsurugi_xact_callback, NULL);
		xact_callback_registered = true;
	}

	/* Register subtransaction callback */
	if (!subxact_callback_registered)
	{
		RegisterSubXactCallback(tsurugi_subxact_callback, NULL);
		subxact_callback_registered = true;
	}

	/* Register syscache invalidation callbacks */
	if (!inval_callback_registered)
	{
		CacheRegisterSyscacheCallback(
				FOREIGNSERVEROID, tsurugi_inval_callback, (Datum) 0);
		CacheRegisterSyscacheCallback(
				USERMAPPINGOID, tsurugi_inval_callback, (Datum) 0);
		inval_callback_registered = true;
	}

	/* Register exit callback */
	if (!exit_registered)
	{
		before_shmem_exit(tsurugi_connection_exit, (Datum) 0);
		exit_registered = true;
	}
}

/*
 * get_connection_entry
 *		Get cache entry for a foreign server, creating if needed
 *
 * IMPORTANT: Do NOT disconnect connection here even if invalidated.
 * During a transaction (xact_id valid), the connection must remain open
 * to preserve transaction integrity. Disconnection happens only at
 * transaction end (COMMIT/ROLLBACK) in tsurugi_xact_callback().
 */
static ConnCacheEntry *
get_connection_entry(Oid serverid)
{
	ConnCacheKey	key;
	ConnCacheEntry *entry;
	bool			found;

	key.serverid = serverid;

	entry = (ConnCacheEntry *)
			hash_search(ConnectionHash, &key, HASH_ENTER, &found);

	if (!found)
	{
		/* Initialize new entry */
		entry->conn				= NULL;
		entry->xact_id			= InvalidTransactionId;
		entry->xact_depth		= 0;
		entry->have_error		= false;
		entry->invalidated		= false;
		entry->server_hashvalue = GetSysCacheHashValue1(
				FOREIGNSERVEROID, ObjectIdGetDatum(serverid));
	}

	/*
	 * DO NOT check entry->invalidated here!
	 *
	 * If we disconnect here, we would break in-progress transactions:
	 *   BEGIN;
	 *     INSERT INTO t1 VALUES (1);
	 *     ALTER SERVER s1 OPTIONS (...);  -- marks invalidated
	 *     SELECT * FROM t1;               -- if we disconnect here, INSERT is
	 * lost!
	 *
	 * The connection will be disconnected at transaction end.
	 */

	/* Ensure we have a connection */
	if (entry->conn == NULL)
		make_new_connection(entry, serverid);

	return entry;
}

/*
 * make_new_connection
 *		Create a new connection to foreign server
 */
static void
make_new_connection(ConnCacheEntry *entry, Oid serverid)
{
	ForeignServer *server;
	UserMapping	  *user;
	char		  *endpoint;
	char		  *username;
	char		  *password;

	Assert(entry->conn == NULL);

	/* Get server and user mapping */
	server = GetForeignServer(serverid);
	user   = GetUserMapping(GetUserId(), serverid);

	/* Get connection parameters */
	endpoint = get_server_option(server, "dbname");
	username = get_user_mapping_option(user, "user");
	password = get_user_mapping_option(user, "password");

	/* Connect to Tsurugi */
	elog(DEBUG3,
		 "tsurugi_fdw: connecting to server \"%s\" (endpoint: %s, user: %s)",
		 server->servername,
		 endpoint,
		 username);

	entry->conn = tg_conn_open(endpoint, username, password);
	if (entry->conn == NULL)
	{
		ereport(ERROR,
				(errcode(ERRCODE_FDW_UNABLE_TO_ESTABLISH_CONNECTION),
				 errmsg("failed to connect to Tsurugi server: %s",
						tg_global_error_message())));
	}

	elog(DEBUG3, "tsurugi_fdw: new connection %p established", entry->conn);
}

/*
 * begin_remote_xact
 *		Start remote transaction if not already started
 */
static void
begin_remote_xact(ConnCacheEntry *entry)
{
	TransactionId curid	   = GetCurrentTransactionId();
	int			  curlevel = GetCurrentTransactionNestLevel();

	/* Already started transaction in this PostgreSQL transaction? */
	if (TransactionIdIsValid(entry->xact_id))
	{
		if (TransactionIdEquals(entry->xact_id, curid))
		{
			/* Same transaction - handle subtransaction if needed */
			if (curlevel > entry->xact_depth)
			{
				/* Entering subtransaction */
				elog(DEBUG3,
					 "tsurugi_fdw: subtransaction detected (level %d), "
					 "but remote DB does not support savepoints",
					 curlevel);
				entry->xact_depth = curlevel;
				tg_conn_set_subxact_seen(entry->conn, 1);
			}
			return; /* Already have transaction */
		}

		/* Different transaction? This shouldn't happen in normal flow */
		elog(WARNING, "tsurugi_fdw: unexpected transaction ID mismatch");
		entry->xact_id	  = InvalidTransactionId;
		entry->xact_depth = 0;
		entry->have_error = false;
	}

	/* Start new remote transaction */
	elog(DEBUG3,
		 "tsurugi_fdw: starting remote transaction on connection %p",
		 entry->conn);

	if (tg_conn_tx_begin(entry->conn) != TG_STATUS_OK)
	{
		ereport(ERROR,
				(errcode(ERRCODE_FDW_UNABLE_TO_CREATE_EXECUTION),
				 errmsg("%s", tg_conn_error_message(entry->conn))));
	}

	entry->xact_id	  = curid;
	entry->xact_depth = curlevel;
	entry->have_error = false;
	tg_conn_set_subxact_seen(entry->conn, 0);

	elog(DEBUG3,
		 "tsurugi_fdw: remote transaction started (xact_id: %u, depth: %d)",
		 entry->xact_id,
		 entry->xact_depth);
}

/*
 * disconnect_connection
 *		Disconnect a connection
 */
static void
disconnect_connection(ConnCacheEntry *entry)
{
	if (entry->conn)
	{
		elog(DEBUG3, "tsurugi_fdw: disconnecting connection %p", entry->conn);
		tg_conn_close(entry->conn);
		tg_conn_destroy(entry->conn);
		entry->conn = NULL;
	}

	entry->xact_id	  = InvalidTransactionId;
	entry->xact_depth = 0;
	entry->have_error = false;
}

/*
 * get_server_option
 *		Get string value of a server option
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

/*
 * get_user_mapping_option
 *		Get string value of a user mapping option
 */
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

/* ================================================================
 * Callback functions
 * ================================================================ */

/*
 * tsurugi_xact_callback
 *		Transaction end callback
 *
 * Commit or rollback remote transactions based on local transaction outcome.
 * This is also where invalidated connections are disconnected.
 */
static void
tsurugi_xact_callback(XactEvent event, void *arg)
{
	HASH_SEQ_STATUS scan;
	ConnCacheEntry *entry;

	if (!ConnectionHash)
		return;

	hash_seq_init(&scan, ConnectionHash);
	while ((entry = (ConnCacheEntry *) hash_seq_search(&scan)) != NULL)
	{
		/* Skip connections not used in this transaction */
		if (!TransactionIdIsValid(entry->xact_id))
			continue;

		elog(DEBUG3,
			 "tsurugi_fdw: processing transaction event %d for connection %p",
			 event,
			 entry->conn);

		switch (event)
		{
		case XACT_EVENT_PRE_COMMIT:
		case XACT_EVENT_PARALLEL_PRE_COMMIT:
			/*
			 * Commit remote transaction if no error occurred
			 */
			if (!entry->have_error && tg_conn_tx_active(entry->conn))
			{
				elog(DEBUG3,
					 "tsurugi_fdw: committing remote transaction on "
					 "connection %p",
					 entry->conn);

				if (tg_conn_tx_commit(entry->conn) != TG_STATUS_OK)
				{
					ereport(ERROR,
							(errcode(ERRCODE_FDW_UNABLE_TO_CREATE_EXECUTION),
							 errmsg("failed to commit remote transaction: %s",
									tg_conn_error_message(entry->conn))));
				}
			}
			break;

		case XACT_EVENT_COMMIT:
		case XACT_EVENT_PARALLEL_COMMIT:
			/*
			 * Transaction committed successfully.
			 * Reset transaction state and disconnect if invalidated.
			 */
			elog(DEBUG3,
				 "tsurugi_fdw: transaction committed, resetting state for "
				 "connection %p",
				 entry->conn);

			entry->xact_id	  = InvalidTransactionId;
			entry->xact_depth = 0;
			entry->have_error = false;
			tg_conn_set_subxact_seen(entry->conn, 0);

			/*
			 * Disconnect if marked for invalidation during transaction.
			 * This is where ALTER SERVER changes take effect.
			 */
			if (entry->invalidated)
			{
				elog(DEBUG3,
					 "tsurugi_fdw: closing invalidated connection %p after "
					 "commit",
					 entry->conn);
				disconnect_connection(entry);
				entry->invalidated = false;
			}
			break;

		case XACT_EVENT_ABORT:
		case XACT_EVENT_PARALLEL_ABORT:
			/*
			 * Transaction aborted.
			 * Rollback remote transaction.
			 */
			if (tg_conn_tx_active(entry->conn))
			{
				elog(DEBUG3,
					 "tsurugi_fdw: rolling back remote transaction on "
					 "connection %p",
					 entry->conn);

				if (tg_conn_tx_rollback(entry->conn) != TG_STATUS_OK)
				{
					/* Log warning but don't fail abort */
					ereport(WARNING,
							(errmsg("failed to rollback remote transaction: "
									"%s",
									tg_conn_error_message(entry->conn))));
				}
			}

			/* Reset transaction state */
			entry->xact_id	  = InvalidTransactionId;
			entry->xact_depth = 0;
			entry->have_error = false;
			tg_conn_set_subxact_seen(entry->conn, 0);

			/* Disconnect if marked for invalidation */
			if (entry->invalidated)
			{
				elog(DEBUG3,
					 "tsurugi_fdw: closing invalidated connection %p after "
					 "abort",
					 entry->conn);
				disconnect_connection(entry);
				entry->invalidated = false;
			}
			break;

		case XACT_EVENT_PREPARE:
			/*
			 * Two-phase commit not supported
			 */
			ereport(WARNING,
					(errmsg("Tsurugi FDW does not support two-phase commit")));
			break;

		default:
			break;
		}
	}
}

/*
 * tsurugi_subxact_callback
 *		Subtransaction event callback
 *
 * Since Tsurugi does not support savepoints, we track subtransaction
 * events for error handling. On subtransaction abort, mark the
 * connection as having an error, which will cause the entire remote
 * transaction to be rolled back.
 */
static void
tsurugi_subxact_callback(
		SubXactEvent	 event,
		SubTransactionId mySubid,
		SubTransactionId parentSubid,
		void			*arg)
{
	HASH_SEQ_STATUS scan;
	ConnCacheEntry *entry;
	int				curlevel;

	if (!ConnectionHash)
		return;

	curlevel = GetCurrentTransactionNestLevel();

	hash_seq_init(&scan, ConnectionHash);
	while ((entry = (ConnCacheEntry *) hash_seq_search(&scan)) != NULL)
	{
		/* Skip connections not used in this transaction */
		if (!TransactionIdIsValid(entry->xact_id))
			continue;

		/* Skip if this connection isn't involved in current subtransaction */
		if (entry->xact_depth < curlevel)
			continue;

		switch (event)
		{
		case SUBXACT_EVENT_PRE_COMMIT_SUB:
			/* Subtransaction commit - just update depth */
			entry->xact_depth = curlevel - 1;
			break;

		case SUBXACT_EVENT_ABORT_SUB:
			/*
			 * Subtransaction abort.
			 * Mark connection as having error if any operations occurred.
			 * The entire remote transaction will be rolled back.
			 */
			if (tg_conn_get_subxact_seen(entry->conn))
			{
				elog(DEBUG3,
					 "tsurugi_fdw: subtransaction abort detected on "
					 "connection %p, "
					 "marking for rollback",
					 entry->conn);
				entry->have_error = true;
			}
			entry->xact_depth = curlevel - 1;
			break;

		default:
			break;
		}
	}
}

/*
 * tsurugi_inval_callback
 *		Syscache invalidation callback
 *
 * Called when ALTER SERVER or DROP SERVER is executed.
 * Invalidates connections matching the specified server_hashvalue.
 *
 * Key behavior:
 * - hashvalue == 0: invalidate all connections (rare global invalidation)
 * - hashvalue != 0: invalidate only matching connections
 * - If connection is in transaction (xact_id valid): mark as invalidated ONLY
 *   (do NOT disconnect - preserve transaction integrity)
 * - If connection is idle (xact_id invalid): disconnect immediately
 *
 * This ensures:
 * - ALTER SERVER server_a only affects server_a connections
 * - server_b connections are completely unaffected
 * - In-progress transactions are not disrupted
 */
static void
tsurugi_inval_callback(Datum arg, int cacheid, uint32 hashvalue)
{
	HASH_SEQ_STATUS scan;
	ConnCacheEntry *entry;

	Assert(cacheid == FOREIGNSERVEROID || cacheid == USERMAPPINGOID);

	if (!ConnectionHash)
		return;

	elog(DEBUG3,
		 "tsurugi_fdw: invalidation callback (cacheid: %d, hashvalue: %u)",
		 cacheid,
		 hashvalue);

	/* hashvalue == 0 means invalidate all (rare) */
	if (hashvalue == 0)
	{
		hash_seq_init(&scan, ConnectionHash);
		while ((entry = (ConnCacheEntry *) hash_seq_search(&scan)) != NULL)
		{
			if (entry->conn == NULL)
				continue;

			entry->invalidated = true;

			/* Disconnect immediately if not in transaction */
			if (!TransactionIdIsValid(entry->xact_id))
			{
				elog(DEBUG3,
					 "tsurugi_fdw: closing idle connection %p due to global "
					 "invalidation",
					 entry->conn);
				disconnect_connection(entry);
				entry->invalidated = false;
			}
			else
			{
				elog(DEBUG3,
					 "tsurugi_fdw: marking in-transaction connection %p as "
					 "invalidated "
					 "(will disconnect at transaction end)",
					 entry->conn);
			}
		}
		return;
	}

	/* Invalidate connections with matching hashvalue */
	hash_seq_init(&scan, ConnectionHash);
	while ((entry = (ConnCacheEntry *) hash_seq_search(&scan)) != NULL)
	{
		if (entry->conn == NULL)
			continue;

		/* Check if this entry matches the invalidated object */
		if (cacheid == FOREIGNSERVEROID)
		{
			/* Match by server hashvalue */
			if (entry->server_hashvalue != hashvalue)
				continue;

			elog(DEBUG3,
				 "tsurugi_fdw: invalidating connection %p (server hashvalue "
				 "match)",
				 entry->conn);
		}
		else /* USERMAPPINGOID */
		{
			/*
			 * For user mapping changes, we invalidate all connections
			 * since we cache by serverid only, not (serverid, userid).
			 * This is conservative but safe.
			 */
			elog(DEBUG3,
				 "tsurugi_fdw: invalidating connection %p (user mapping "
				 "change)",
				 entry->conn);
		}

		entry->invalidated = true;

		/*
		 * If connection is idle (not in transaction), disconnect immediately.
		 * If in transaction, only mark - disconnection happens at transaction
		 * end.
		 */
		if (!TransactionIdIsValid(entry->xact_id))
		{
			elog(DEBUG3,
				 "tsurugi_fdw: closing idle connection %p immediately",
				 entry->conn);
			disconnect_connection(entry);
			entry->invalidated = false;
		}
		else
		{
			elog(DEBUG3,
				 "tsurugi_fdw: deferring disconnect of in-transaction "
				 "connection %p "
				 "(will disconnect at COMMIT/ROLLBACK)",
				 entry->conn);
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

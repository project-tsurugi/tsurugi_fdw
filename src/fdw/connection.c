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
/* connection.c */
#include "postgres.h"

#include "access/subtrans.h"
#include "access/xact.h"
#include "commands/defrem.h"
#include "foreign/foreign.h"
#include "storage/ipc.h"
#include "utils/hsearch.h"
#include "utils/inval.h"
#include "utils/memutils.h"
#include "utils/syscache.h"

#include "connection.h"
#include "tsurugi_api.h"

/*
 * Connection cache key: server Oid + user Oid
 *
 * We include userid to distinguish different USER MAPPINGs for the same server,
 * as credentials may differ per user.
 */
typedef struct ConnCacheKey
{
	Oid			serverid;
	Oid			userid;
} ConnCacheKey;

/*
 * Connection cache entry.
 *
 * - tx_depth: 0 = no remote tx, 1 = remote tx active
 *             (Tsurugi does not support SAVEPOINT, so only 0/1)
 * - invalidated: marked by ALTER SERVER/USER MAPPING; will be destroyed after xact end
 * - changing_tx_state: guard against re-entrancy during commit/rollback
 * - server_hashvalue / mapping_hashvalue: for matching syscache invalidation callbacks
 */
typedef struct ConnCacheEntry
{
	ConnCacheKey key;
	TGconn	   *conn;

	int			tx_depth;
	bool		invalidated;
	bool		changing_tx_state;

	uint32		server_hashvalue;
	uint32		mapping_hashvalue;
} ConnCacheEntry;

/* Hash table for connection cache */
static HTAB *ConnectionHash = NULL;

/* Flags to track xact (local transaction) state */
static bool xact_callbacks_registered = false;
static bool got_xact_connection = false;
static bool invalidated = false;

/* Subtransaction (SAVEPOINT) detection flag */
static bool subxact_started = false;

/* Static function declarations */
static void init_connection_hash(void);
static ConnCacheEntry *get_connection_entry(ForeignServer *server,
											UserMapping *user);
static void begin_remote_tx(ConnCacheEntry *entry);
static void invalidate_connection_entry(ConnCacheEntry *entry);

static const char *get_server_option(ForeignServer *server, const char *name);
static const char *get_user_option(UserMapping *user, const char *name);
static TGconn *open_connection(ForeignServer *server, UserMapping *user);

/* Public callbacks (keep tsurugfdw_ prefix) */
static void tsurugfdw_xact_callback(XactEvent event, void *arg);
static void tsurugfdw_subxact_callback(SubXactEvent event,
									   SubTransactionId mySubid,
									   SubTransactionId parentSubid,
									   void *arg);
static void tsurugfdw_inval_callback(Datum arg, int cacheid, uint32 hashvalue);
static void tsurugfdw_abort_connections(int code, Datum arg);

/*
 * Initialize connection management.
 * Should be called from _PG_init().
 */
void
tsurugi_init_connections(void)
{
	init_connection_hash();
}

/*
 * Initialize connection hash and register callbacks (once).
 */
static void
init_connection_hash(void)
{
	HASHCTL		ctl;

	if (ConnectionHash != NULL)
		return;

	MemSet(&ctl, 0, sizeof(ctl));
	ctl.keysize = sizeof(ConnCacheKey);
	ctl.entrysize = sizeof(ConnCacheEntry);
	ctl.hcxt = CacheMemoryContext;

	ConnectionHash = hash_create("tsurugi_fdw connections",
								 8,
								 &ctl,
								 HASH_ELEM | HASH_BLOBS | HASH_CONTEXT);

	if (!xact_callbacks_registered)
	{
		/* Register xact callback for commit/abort handling */
		RegisterXactCallback(tsurugfdw_xact_callback, NULL);

		/* Register subxact callback for SAVEPOINT detection */
		RegisterSubXactCallback(tsurugfdw_subxact_callback, NULL);

		/* Register syscache callbacks to detect ALTER SERVER/USER MAPPING */
		CacheRegisterSyscacheCallback(FOREIGNSERVEROID,
									  tsurugfdw_inval_callback,
									  (Datum) 0);
		CacheRegisterSyscacheCallback(USERMAPPINGOID,
									  tsurugfdw_inval_callback,
									  (Datum) 0);

		/*
		 * Register process exit callback to ensure C++ destructors are called
		 * (MemoryContext cleanup does not invoke destructors).
		 */
		before_shmem_exit(tsurugfdw_abort_connections, (Datum) 0);

		xact_callbacks_registered = true;
	}
}

/*
 * Get server option value by name (returns NULL if not found).
 */
static const char *
get_server_option(ForeignServer *server, const char *name)
{
	ListCell   *lc;

	foreach(lc, server->options)
	{
		DefElem    *def = (DefElem *) lfirst(lc);

		if (strcmp(def->defname, name) == 0)
			return defGetString(def);
	}

	return NULL;
}

/*
 * Get user mapping option value by name (returns NULL if not found).
 */
static const char *
get_user_option(UserMapping *user, const char *name)
{
	ListCell   *lc;

	foreach(lc, user->options)
	{
		DefElem    *def = (DefElem *) lfirst(lc);

		if (strcmp(def->defname, name) == 0)
			return defGetString(def);
	}

	return NULL;
}

/*
 * Open connection to Tsurugi server.
 *
 * Extracts endpoint, user, and password from server/user mapping options.
 */
static TGconn *
open_connection(ForeignServer *server, UserMapping *user)
{
	const char *endpoint;
	const char *username;
	const char *password;
	TGconn	   *conn;

	/* Get endpoint from server options (required) */
	endpoint = get_server_option(server, "dbname");
	if (endpoint == NULL || endpoint[0] == '\0')
		endpoint = tg_get_database_name();

	/* Get user/password from user mapping options (required) */
	username = get_user_option(user, "user");
	if (!username) username = "";
	password = get_user_option(user, "password");
	if (!password) password = "";

	/* Open connection */
	conn = tg_conn_open(endpoint, username, password);
	if (conn == NULL)
		ereport(ERROR,
				(errmsg("tsurugi_fdw: connection open failed. (%s)",
						tg_global_error_message())));

	return conn;
}

/*
 * Get or create connection cache entry and ensure connection is open.
 *
 * Performs HASH_ENTER first to avoid losing connection pointer on palloc failure.
 */
static ConnCacheEntry *
get_connection_entry(ForeignServer *server, UserMapping *user)
{
	ConnCacheKey key;
	ConnCacheEntry *entry;
	bool		found;

	init_connection_hash();

	key.serverid = server->serverid;
	key.userid = user->userid;

	entry = (ConnCacheEntry *) hash_search(ConnectionHash,
										   (const void *) &key,
										   HASH_ENTER,
										   &found);

	if (!found)
	{
		/* Initialize new entry */
		entry->conn = NULL;
		entry->tx_depth = 0;
		entry->invalidated = false;
		entry->changing_tx_state = false;

		/* Store hashvalues for syscache invalidation matching */
		entry->server_hashvalue =
			GetSysCacheHashValue1(FOREIGNSERVEROID,
								  ObjectIdGetDatum(server->serverid));
		entry->mapping_hashvalue =
			GetSysCacheHashValue2(USERMAPPINGOID,
								  ObjectIdGetDatum(user->userid),
								  ObjectIdGetDatum(server->serverid));
	}

	/*
	 * If connection is invalidated (by ALTER) and not in use by current xact,
	 * destroy it now so we reconnect with new parameters.
	 */
	if (entry->conn != NULL && entry->invalidated && entry->tx_depth == 0)
	{
		invalidate_connection_entry(entry);
		entry->invalidated = false;
	}

	/* Open connection if needed */
	if (entry->conn == NULL)
	{
		entry->conn = open_connection(server, user);

		/* Clear invalidated flag on successful reconnect */
		entry->invalidated = false;
	}

	return entry;
}

/*
 * Start remote tx if not already started.
 */
static void
begin_remote_tx(ConnCacheEntry *entry)
{
	const char *emsg;

	if (entry->tx_depth > 0)
		return;  /* Already started */

	if (tg_conn_tx_begin(entry->conn) != 0)
	{
		emsg = tg_conn_error_message(entry->conn);

		/*
		 * On tx begin failure, destroy connection to force reconnect
		 * on next attempt.
		 */
		invalidate_connection_entry(entry);
		ereport(ERROR,
				(errmsg("tsurugi_fdw: remote tx begin failed. (%s)",
						emsg ? emsg : "(unknown error)")));
	}

	entry->tx_depth = 1;
}

/*
 * Get a cached connection and ensure remote tx is started.
 *
 * The remote tx will be committed/rolled back by xact callback.
 * Raises ERROR if subtransaction (SAVEPOINT) was started in current xact.
 */
TGconn *
tsurugi_get_connection(ForeignServer *server, UserMapping *user)
{
	ConnCacheEntry *entry;

	/*
	 * Disallow Tsurugi access if SAVEPOINT was used in current xact,
	 * since Tsurugi does not support subtransactions.
	 */
	if (subxact_started)
		ereport(ERROR,
				(errmsg("tsurugi_fdw: subtransaction (SAVEPOINT) is not supported")));

	entry = get_connection_entry(server, user);

	got_xact_connection = true;

	/* Start remote tx if not already started */
	begin_remote_tx(entry);

	return entry->conn;
}

/*
 * Manually invalidate a cached connection (e.g., on protocol error).
 *
 * Note: must not ereport(ERROR) when called from abort callback paths.
 */
void
tsurugi_invalidate_connection(Oid serverid, Oid userid)
{
	ConnCacheKey key;
	ConnCacheEntry *entry;
	bool		found;

	if (ConnectionHash == NULL)
		return;

	key.serverid = serverid;
	key.userid = userid;

	entry = (ConnCacheEntry *) hash_search(ConnectionHash,
										   (const void *) &key,
										   HASH_FIND,
										   &found);
	if (!found)
		return;

	invalidate_connection_entry(entry);
}

/*
 * Invalidate connection entry in place.
 *
 * Safe to call during hash_seq_search as long as we don't HASH_REMOVE.
 */
static void
invalidate_connection_entry(ConnCacheEntry *entry)
{
	if (entry == NULL)
		return;

	entry->tx_depth = 0;
	entry->changing_tx_state = false;

	if (entry->conn != NULL)
	{
		tg_conn_destroy(entry->conn);
		entry->conn = NULL;
	}
}

/*
 * Process exit callback: destroy all connections and hash.
 */
static void
tsurugfdw_abort_connections(int code, Datum arg)
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
		invalidate_connection_entry(entry);
	}

	hash_destroy(ConnectionHash);
	ConnectionHash = NULL;

	/* Reset state flags */
	got_xact_connection = false;
	invalidated = false;
	subxact_started = false;
}

/*
 * Transaction callback.
 *
 * Handles:
 * - PRE_COMMIT: commit remote tx (failure aborts local xact)
 * - ABORT: best-effort rollback + invalidate connections
 * - PREPARE: reject (2PC not supported)
 * - COMMIT/ABORT: cleanup invalidated connections (ALTER reflection)
 */
static void
tsurugfdw_xact_callback(XactEvent event, void *arg)
{
	HASH_SEQ_STATUS scan;
	ConnCacheEntry *entry;

	(void) arg;

	/* Fast path: no connections used and no invalidations pending */
	if (!got_xact_connection && !invalidated)
	{
		if (event == XACT_EVENT_COMMIT || event == XACT_EVENT_ABORT)
			subxact_started = false;
		return;
	}

	switch (event)
	{
		case XACT_EVENT_PREPARE:
			/*
			 * Two-phase commit is not supported.
			 */
			ereport(ERROR,
					(errmsg("tsurugi_fdw: two-phase commit is not supported")));
			break;

		case XACT_EVENT_PRE_COMMIT:
			/*
			 * Commit all active remote tx.
			 * If any commit fails, we raise ERROR to abort local xact.
			 */
			if (ConnectionHash == NULL)
				break;

			hash_seq_init(&scan, ConnectionHash);
			while ((entry = (ConnCacheEntry *) hash_seq_search(&scan)) != NULL)
			{
				if (entry->tx_depth <= 0 || entry->conn == NULL)
					continue;

				/* Skip if already changing state (avoid re-entrancy) */
				if (entry->changing_tx_state)
					continue;

				entry->changing_tx_state = true;

				if (tg_conn_tx_commit(entry->conn) != 0)
				{
					entry->changing_tx_state = false;

					ereport(ERROR,
							(errmsg("tsurugi_fdw: remote tx commit failed. (%s)",
									tg_conn_error_message(entry->conn))));
				}

				entry->tx_depth = 0;
				entry->changing_tx_state = false;
			}
			break;

		case XACT_EVENT_ABORT:
			/*
			 * Rollback all active remote tx (best-effort).
			 * Do not raise ERROR in abort path; invalidate connection instead.
			 */
			if (ConnectionHash == NULL)
				break;

			hash_seq_init(&scan, ConnectionHash);
			while ((entry = (ConnCacheEntry *) hash_seq_search(&scan)) != NULL)
			{
				if (entry->tx_depth <= 0 || entry->conn == NULL)
					continue;

				if (entry->changing_tx_state)
					continue;

				entry->changing_tx_state = true;

				/* Best-effort rollback */
				(void) tg_conn_tx_rollback(entry->conn);

				/* Destroy connection to be safe */
				invalidate_connection_entry(entry);
			}
			break;

		default:
			break;
	}

	/*
	 * Xact end cleanup (after COMMIT or ABORT).
	 *
	 * - Destroy connections marked as invalidated (ALTER reflection)
	 * - Reset xact state flags
	 */
	if (event == XACT_EVENT_COMMIT || event == XACT_EVENT_ABORT)
	{
		bool any_invalidated = false;

		/* Destroy invalidated connections now that xact is done */
		if (ConnectionHash != NULL && invalidated)
		{
			hash_seq_init(&scan, ConnectionHash);
			while ((entry = (ConnCacheEntry *) hash_seq_search(&scan)) != NULL)
			{
				if (entry->invalidated)
				{
					invalidate_connection_entry(entry);
					entry->invalidated = false;
				}
			}
		}

		/* Check if any invalidated connections remain */
		if (ConnectionHash != NULL)
		{
			hash_seq_init(&scan, ConnectionHash);
			while ((entry = (ConnCacheEntry *) hash_seq_search(&scan)) != NULL)
			{
				if (entry->invalidated)
				{
					any_invalidated = true;
					break;
				}
			}
		}
		invalidated = any_invalidated;

		/* Reset xact-level state */
		got_xact_connection = false;
		subxact_started = false;

		/* Reset per-connection xact state */
		if (ConnectionHash != NULL)
		{
			hash_seq_init(&scan, ConnectionHash);
			while ((entry = (ConnCacheEntry *) hash_seq_search(&scan)) != NULL)
			{
				entry->tx_depth = 0;
				entry->changing_tx_state = false;

				if (entry->conn != NULL)
					tg_conn_set_subxact_seen(entry->conn, false);
			}
		}
	}
}

/*
 * Subtransaction callback.
 *
 * Tsurugi does not support subtransactions (SAVEPOINT).
 * We mark that a subtransaction was started and disallow Tsurugi access
 * for the remainder of the current xact.
 */
static void
tsurugfdw_subxact_callback(SubXactEvent event,
						   SubTransactionId mySubid,
						   SubTransactionId parentSubid,
						   void *arg)
{
	HASH_SEQ_STATUS scan;
	ConnCacheEntry *entry;

	(void) mySubid;
	(void) parentSubid;
	(void) arg;

	if (event != SUBXACT_EVENT_START_SUB)
		return;

	/* Mark that subtransaction was started */
	subxact_started = true;

	if (ConnectionHash == NULL)
		return;

	/* Mark all existing connections as having seen subtransaction */
	hash_seq_init(&scan, ConnectionHash);
	while ((entry = (ConnCacheEntry *) hash_seq_search(&scan)) != NULL)
	{
		if (entry->conn != NULL)
			tg_conn_set_subxact_seen(entry->conn, true);
	}
}

/*
 * Syscache invalidation callback.
 *
 * Called when ALTER SERVER or ALTER USER MAPPING is executed.
 * We mark matching connections as invalidated; they will be destroyed
 * after current xact completes.
 */
static void
tsurugfdw_inval_callback(Datum arg, int cacheid, uint32 hashvalue)
{
	HASH_SEQ_STATUS scan;
	ConnCacheEntry *entry;

	(void) arg;

	if (ConnectionHash == NULL)
		return;

	hash_seq_init(&scan, ConnectionHash);
	while ((entry = (ConnCacheEntry *) hash_seq_search(&scan)) != NULL)
	{
		bool match = false;

		/*
		 * hashvalue == 0 means "invalidate all" in some cases.
		 * To be safe, we mark all connections as invalidated.
		 */
		if (hashvalue == 0)
			match = true;
		else if (cacheid == FOREIGNSERVEROID)
			match = (entry->server_hashvalue == hashvalue);
		else if (cacheid == USERMAPPINGOID)
			match = (entry->mapping_hashvalue == hashvalue);

		if (match)
		{
			entry->invalidated = true;
			invalidated = true;
		}
	}
}

/*
 * Convenience subroutine to issue a non-data-returning SQL command to remote
 */
void
tsurugi_do_sql_command(TGconn *conn, const char *sql)
{
	TG_STATUS TG_STATUS;
	TGstmt	 *tg_stmt;
	size_t	  num_rows;

	elog(DEBUG3, "tsurugi_fdw: %s\nsql:\n%s", __func__, sql);

	tg_stmt = tg_stmt_prepare(conn, sql);
	if (!tg_stmt)
		elog(ERROR, "%s", tg_global_error_message());

	TG_STATUS = tg_stmt_execute_statement(tg_stmt, &num_rows);
	if (TG_STATUS != TG_STATUS_OK)
		elog(ERROR, "%s", tg_stmt_error_message(tg_stmt));
}


#if 0
static void
tsurugi_fdw_abort_connections(int code, Datum arg)
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
			tg_conn_destroy(entry->conn);
			entry->conn = NULL;
		}
		entry->used_in_xact	   = false;
		entry->needs_reconnect = false;
	}

	hash_destroy(ConnectionHash);
	ConnectionHash = NULL;
}

/**
 * 	Register callback functions.
 */
void
tsurugi_register_callbacks(void)
{
	if (xact_callbacks_registered)
		return;

	RegisterXactCallback(tsurugifdw_xact_callback, NULL);
	before_shmem_exit(tsurugi_fdw_abort_connections, (Datum) 0);
	CacheRegisterSyscacheCallback(
			FOREIGNSERVEROID, tsurugifdw_inval_callback, (Datum) 0);

	xact_callbacks_registered = true;
}

/**
 * 	tsurugi_mark_all_connections_subxact_seen
 */
static void tsurugi_mark_all_connections_subxact_seen(int seen) {
	HASH_SEQ_STATUS scan;
	ConnCacheEntry *entry;

	if (ConnectionHash == NULL)
		return;

	hash_seq_init(&scan, ConnectionHash);
	while ((entry = (ConnCacheEntry *) hash_seq_search(&scan)) != NULL) {
		if (entry->conn != NULL)
			tg_conn_set_subxact_seen(entry->conn, seen);
	}
}

/**
 * 	@brief	Get connection to Tsurugi.
 * 	@param	(server) Pointer to ForeignServer object.
 * 			(user) Pointer to UserMapping object.
 * 	@return	Pointer to Tsurugi connection object.
 */
TGconn *
tsurugi_get_connection(ForeignServer *server, UserMapping *user)
{
	bool			found;
	ConnCacheEntry *entry = NULL;
	ConnCacheKey	key;

	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	if (!xact_callbacks_registered)
		tsurugi_conn_cache_init();

	tsurugi_init_connection_hash();

	/* Set flag that we did GetConnection during the current transaction */
	xact_got_connection = true;
	key					= server->serverid;

	/* Find or create cached entry for requested connection. */
	entry = (ConnCacheEntry *)
			hash_search(ConnectionHash, &key, HASH_ENTER, &found);
	if (!found)
	{
		entry->conn				   = NULL;
		entry->serverid			   = server->serverid;
		entry->keep_conn		   = true;
		entry->xact_depth		   = 0;
		entry->changing_xact_state = false;
		entry->invalidated		   = false;
		entry->server_hashvalue	   = GetSysCacheHashValue1(
				   FOREIGNSERVEROID, ObjectIdGetDatum(server->serverid));
		entry->mapping_hasvalue = GetSysCacheHashValue1(
				USERMAPPINGOID, ObjectIdGetDatum(user->umid));
	}

	if (entry->conn == NULL)
		tsurugi_make_new_connection(entry, server, user);

	/* Start a new remote transaction if needed. */
	tsurugi_begin_remote_tx(entry);

	if (subxact_started)
		tg_conn_set_subxact_seen(entry->conn, true);

	return entry->conn;
}

static void
tsurugi_make_new_connection(
		ConnCacheEntry *entry, ForeignServer *server, UserMapping *user)
{
	const char *db_name	  = NULL;
	const char *user_name = NULL;
	const char *password  = NULL;
	ListCell   *lc;

	Assert(entry->conn == NULL);

	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	/* Get server options */
	db_name = tg_get_database_name();
	foreach(lc, server->options)
	{
		DefElem *def = (DefElem *) lfirst(lc);
		if (!strcmp(def->defname, "dbname"))
			db_name = defGetString(def);
	}

	/* Get user mapping */
	foreach(lc, user->options)
	{
		DefElem	   *def	  = (DefElem *) lfirst(lc);
		const char *value = (def->arg != NULL) ? defGetString(def) : "";
		if (!strcmp(def->defname, "user"))
			user_name = value;
		else if (!strcmp(def->defname, "password"))
			password = value;
	}
	if (!user_name)
		user_name = "";
	if (!password)
		password = "";

	entry->conn = tg_conn_open(db_name, user_name, password);
	if (!entry->conn)
	{
		(void) hash_search(
				ConnectionHash, (const void *) &entry->key, HASH_REMOVE, NULL);
		elog(ERROR, "%s", tg_global_error_message());
	}
}

/**
 * 	@brief start remote transaction.
 * 	@param (entry)	Pointer to ConnCacheEntry.
 */
static void
tsurugi_begin_remote_tx(ConnCacheEntry *entry)
{
	TG_STATUS TG_STATUS;

	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	if (entry->xact_depth <= 0)
	{
		TG_STATUS = tg_conn_tx_begin(entry->conn);
		if (TG_STATUS != TG_STATUS_OK)
			ereport(ERROR, (errmsg("%s", tg_conn_error_message(entry->conn))));

		entry->xact_depth		   = 1;
		entry->changing_xact_state = false;
	}
}

void
tsurugi_do_sql_command(TGconn *conn, const char *sql)
{
	TG_STATUS TG_STATUS;
	TGstmt	 *tg_stmt;
	size_t	  num_rows;

	elog(DEBUG3, "tsurugi_fdw: %s\nsql:\n%s", __func__, sql);

	tg_stmt = tg_stmt_prepare(conn, sql);
	if (!tg_stmt)
		elog(ERROR, "%s", tg_global_error_message());

	TG_STATUS = tg_stmt_execute_statement(tg_stmt, &num_rows);
	if (TG_STATUS != TG_STATUS_OK)
		elog(ERROR, "%s", tg_stmt_error_message(tg_stmt));
}

/*
 * Terminate remote transactions in sync with the local PostgreSQL transaction.
 *
 * - PRE_COMMIT: Commit the remote transactions for connections used_in_xact (failure raises ERROR)
 * - ABORT: Best-effort rollback; on failure, defer to the next reconnect attempt
 * - PREPARE (2PC): Not supported (ERROR)
 */
static void
tsurugifdw_xact_callback(XactEvent event, void *arg)
{
	HASH_SEQ_STATUS scan;
	ConnCacheEntry *entry;
	TG_STATUS		tg_status;

	elog(DEBUG1, "tsurugi_fdw: %s (event: %d)", __func__, event);

	/* Quick exit if no connections were touched in this transaction. */
	if (!xact_got_connection)
		return;

	/* Scan all connection cache entries to find open remote transactions, and
	 * close them.
	 */
	hash_seq_init(&scan, ConnectionHash);
	while ((entry = (ConnCacheEntry *) hash_seq_search(&scan)))
	{
		/* Ignore cache entry if no open connection right now */
		if (entry->keep_conn == false)
			continue;

		if (entry->xact_depth > 0)
		{
			switch (event)
			{
			case XACT_EVENT_PARALLEL_PRE_COMMIT:
			case XACT_EVENT_PRE_COMMIT:
				/* Commit all remote transactions during pre-commit */
				entry->changing_xact_state = true;
				tg_status = tg_conn_tx_commit(entry->conn);
				if (tg_status != TG_STATUS_OK)
					ereport(ERROR,
							(errmsg("tsurugi_fdw: remote commit failed: \n%s",
									tg_conn_error_message(entry->conn))));
				entry->changing_xact_state = false;
				break;

			case XACT_EVENT_PRE_PREPARE:
				ereport(ERROR,
						(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
						 errmsg("cannot PREPARE a transaction that has "
								"operated on "
								"tsurugi_fdw foreign tables")));
				break;
			case XACT_EVENT_PARALLEL_COMMIT:
			case XACT_EVENT_COMMIT:
			case XACT_EVENT_PREPARE:
				/* Pre-commit should have closed the open transaction */
				elog(ERROR, "missed cleaning up connection during pre-commit");
				break;

			case XACT_EVENT_PARALLEL_ABORT:
			case XACT_EVENT_ABORT:
				/* Don't try to clean up the connection if we're already
				 * in error recursion trouble.*/
				if (in_error_recursion_trouble())
					entry->changing_xact_state = true;

				/* If connection is already unsalvageable, don't touch it
				 * further. */
				if (entry->changing_xact_state)
					break;

				/* Mark this connection as in the process of changing
				 * transaction state. */
				entry->changing_xact_state = true;
				tg_conn_tx_rollback(entry->conn);
				entry->changing_xact_state = false;
				break;
			default:
				break;
			}
			entry->xact_depth = 0;
		}
	}
	xact_got_connection = false;
}

static void
tsurugifdw_subxact_callback(SubXactEvent event,
					SubTransactionId mySubid,
					SubTransactionId parentSubid,
					void *arg)
{
	(void) mySubid;
	(void) parentSubid;
	(void) arg;

	if (event == SUBXACT_EVENT_START_SUB)
	{
		subxact_started = true;
		tsurugi_mark_all_connections_subxact_seen(true);
	}
}

/**
 * 	tsurugifdw_inval_callback
 * 		(arg)
 * 		(cacheid)
 * 		(hashvalue)
 */
static void
tsurugifdw_inval_callback(Datum arg, int cacheid, uint32 hashvalue)
{
	HASH_SEQ_STATUS scan;
	ConnCacheEntry *entry;

	Assert(cacheid == FOREIGNSERVEROID);

	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	/* ConnectionHash must exist already, if we're registered */
	hash_seq_init(&scan, ConnectionHash);
	while ((entry = (ConnCacheEntry *) hash_seq_search(&scan)))
	{
		/* Ignore invalid entries */
		if (entry->keep_conn == false)
			continue;

		/* hashvalue == 0 means a cache reset, must clear all state */
		if (hashvalue == 0 || (cacheid == FOREIGNSERVEROID &&
							   entry->server_hashvalue == hashvalue))
			entry->invalidated = true;
	}
}
#endif
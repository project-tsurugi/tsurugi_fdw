/*
 * Copyright 2024 Project Tsurugi.
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
#ifdef __cplusplus
exern "C" {
#endif
#include "postgres.h"
#include "connection.h"

#include "access/htup_details.h"
#include "access/xact.h"
#include "catalog/pg_user_mapping.h"
#include "commands/defrem.h"
#include "foreign/foreign.h"
#include "lib/stringinfo.h"
#include "mb/pg_wchar.h"
#include "miscadmin.h"
#include "nodes/pathnodes.h"
#include "optimizer/planner.h"
#include "pgstat.h"
#include "storage/ipc.h"
#include "storage/latch.h"
#include "tcop/utility.h"
#include "utils/hsearch.h"
#include "utils/inval.h"
#include "utils/memutils.h"
#include "utils/relcache.h"
#include "utils/syscache.h"

#include "tsurugi_api.h"
#ifdef __cplusplus
}
#endif

typedef Oid ConnCacheKey;

/* Connection cache (initialized on first use) */
static HTAB *ConnectionHash = NULL;

bool xact_got_connection = false;
//static bool TgCallbacksRegistered = false;
//static bool TgSubxactSeen = false;

typedef struct ConnCacheEntry
{
	ConnCacheKey key; /* hash key (must be first) */
	TGconn *conn;  /* connection to foreign server , or NULL */
	Oid serverid;
	bool keep_conn;
	int xact_depth;			  /* 0 = no xact open, 1 = main xact open */
	bool changing_xact_state; /* xact state change in process */
	bool invalidated;		  /* true if reconnect is pending */
	uint32 server_hashvalue;  /* hash value of foreign server OID */
	uint32 mapping_hasvalue;	/* hash value of user mapping OID */
	bool used_in_xact;
	bool needs_reconnect;
} ConnCacheEntry;

static void tsurugifdw_xact_callback(XactEvent event, void *arg);
static void tsurugifdw_inval_callback(Datum arg, int cacheid, uint32 hashvalue);

static void tg_make_new_connection(ConnCacheEntry *entry, 
									ForeignServer *server, 
									UserMapping *user);
static void tg_begin_remote_tx(ConnCacheEntry *entry);
void tg_invalidate_connection(Oid serverid, Oid userid);
static void tg_register_callbacks(void);

/**
 * 	tg_disconnect_all
 */
static void tg_disconnect_all(int code, Datum arg) {
	HASH_SEQ_STATUS scan;
	ConnCacheEntry *entry;

	(void)code;
	(void)arg;

	if (ConnectionHash == NULL)
		return;

	hash_seq_init(&scan, ConnectionHash);
	while ((entry = (ConnCacheEntry *)hash_seq_search(&scan)) != NULL) {
		if (entry->conn != NULL) {
			tg_conn_destroy(entry->conn);
			entry->conn = NULL;
		}
		entry->used_in_xact = false;
		entry->needs_reconnect = false;
	}

	hash_destroy(ConnectionHash);
	ConnectionHash = NULL;
}

static bool CallbacksRegistered = false;
void
tg_register_callbacks(void)
{
	if (CallbacksRegistered)
		return;

//	RegisterXactCallback(tsurugifdw_xact_callback, NULL);
//	RegisterSubXactCallback(subxact_callback, NULL);
//	before_shmem_exit(tg_disconnect_all, (Datum) 0);

	RegisterXactCallback(tsurugifdw_xact_callback, NULL);
	before_shmem_exit(tg_disconnect_all, (Datum) 0);
	CacheRegisterSyscacheCallback(FOREIGNSERVEROID, tsurugifdw_inval_callback,
									(Datum) 0);

	CallbacksRegistered = true;
}

#if 0
/**
 * 	tg_mark_all_connections_subxact_seen
 */
static void tg_mark_all_connections_subxact_seen(int seen) {
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
#endif

/**
 * 	@brief	Get connection to Tsurugi.
 * 	@param	(server) Pointer to ForeignServer object.
 * 			(user) Pointer to UserMapping object.
 * 	@return	Pointer to Tsurugi connection object.
 */
TGconn *
tg_get_connection(ForeignServer *server, UserMapping *user)
{
	bool found;
	ConnCacheEntry *entry = NULL;
	ConnCacheKey key;

	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	if (!CallbacksRegistered)
		tg_register_callbacks();

	if (ConnectionHash == NULL)
	{
		HASHCTL		ctl;

		/* Create the hash table. */
		MemSet(&ctl, 0, sizeof(ctl));
		ctl.keysize = sizeof(ConnCacheKey);
		ctl.entrysize = sizeof(ConnCacheEntry);
		/* allocate ConnectionHash in the cache context */
		ctl.hcxt = CacheMemoryContext;
		ConnectionHash = hash_create("tsurugi_fdw connections", 8, &ctl,
									HASH_ELEM | HASH_BLOBS | HASH_CONTEXT);
	}
	/* Set flag that we did GetConnection during the current transaction */
	xact_got_connection = true;
	key = server->serverid;

	/* Find or create cached entry for requested connection. */
	entry = (ConnCacheEntry *) hash_search(ConnectionHash, &key, HASH_ENTER, &found);
	if (!found)
	{
		entry->conn = NULL;
		entry->keep_conn = true;
		entry->xact_depth = 0;
		entry->changing_xact_state = false;
		entry->invalidated = false;
		entry->server_hashvalue =
			GetSysCacheHashValue1(FOREIGNSERVEROID, ObjectIdGetDatum(server->serverid));
		entry->mapping_hasvalue =
			GetSysCacheHashValue1(USERMAPPINGOID, ObjectIdGetDatum(user->umid));
	}

	if (entry->conn == NULL)
		tg_make_new_connection(entry, server, user);

	/* Start a new remote transaction if needed. */
	tg_begin_remote_tx(entry);

	return entry->conn;
}

static void
tg_make_new_connection(ConnCacheEntry *entry, ForeignServer *server, UserMapping *user)
{
	const char *db_name = NULL;
	const char *user_name = NULL;
	const char *password = NULL;
	ListCell *lc;

	Assert(entry->conn == NULL);

	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	entry->serverid = server->serverid;
	entry->xact_depth = 0;
	entry->invalidated = false;
	entry->keep_conn = true;
	entry->server_hashvalue = GetSysCacheHashValue1(FOREIGNSERVEROID, 
										ObjectIdGetDatum(server->serverid));
	entry->mapping_hasvalue = GetSysCacheHashValue1(USERMAPPINGOID,
							  			ObjectIdGetDatum(user->umid));
	
	/* Get server options */
	db_name = tg_get_database_name();
	foreach(lc, server->options)
	{
		DefElem	*def = (DefElem *) lfirst(lc);
		if (!strcmp(def->defname, "db_name"))
			db_name = defGetString(def);
	}

	/* Get user mapping */
    foreach (lc, user->options) 
	{
        DefElem* def = (DefElem*) lfirst(lc);
        const char* value = (def->arg != NULL) ? defGetString(def) : "";
        if (!strcmp(def->defname, "user")) 
            user_name = value;
		else if (!strcmp(def->defname, "password")) 
            password = value;
    }
	if (!user_name) user_name = "";
	if (!password) password = "";

	entry->conn = tg_conn_open(db_name, user_name, password);
	if (!entry->conn)
	{
		(void) hash_search(ConnectionHash, (const void *) &entry->key, HASH_REMOVE, NULL);		
		elog(ERROR, "%s", tg_global_error_message());
	}
}

/**
 * 	@brief start remote transaction.
 * 	@param (entry)	Pointer to ConnCacheEntry.
 */
static void 
tg_begin_remote_tx(ConnCacheEntry *entry)
{
	TG_STATUS tg_status;

	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	if (entry->xact_depth <= 0)
	{
		tg_status = tg_conn_tx_begin(entry->conn);
		if (tg_status != TG_STATUS_OK)
			ereport(ERROR, (errmsg("%s", tg_conn_error_message(entry->conn))));

		entry->xact_depth = 1;
		entry->changing_xact_state = false;
	}
}

void tg_do_sql_command(TGconn *conn, const char *sql)
{
	TG_STATUS tg_status;
	TGstmt	*tg_stmt;
	size_t num_rows;

	elog(DEBUG3, "tsurugi_fdw: %s\nsql:\n%s", __func__, sql);

	tg_stmt = tg_stmt_prepare(conn, sql);
	if (!tg_stmt)
		elog(ERROR, "%s", tg_global_error_message());

	tg_status = tg_stmt_execute_statement(tg_stmt, &num_rows);
	if (tg_status != TG_STATUS_OK)
		elog(ERROR, "%s", tg_stmt_error_message(tg_stmt));		
}

/*
 * tsurugifdw_xact_callback --- cleanup at main-transaction end.
 */
static void tsurugifdw_xact_callback(XactEvent event, void *arg)
{
	HASH_SEQ_STATUS scan;
	ConnCacheEntry *entry;
	TG_STATUS tg_status;

	elog(DEBUG1, "tsurugi_fdw: %s (event: %d)", __func__, event);

	/* Quick exit if no connections were touched in this transaction. */
	if (!xact_got_connection)
		return;

	/* Scan all connection cache entries to find open remote transactions, and close them.
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
						ereport(ERROR, (errmsg("tsurugi_fdw: remote commit failed: \n%s",
										tg_conn_error_message(entry->conn))));
					entry->changing_xact_state = false;
					break;

				case XACT_EVENT_PRE_PREPARE:
					ereport(ERROR,
							(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
							 errmsg("cannot PREPARE a transaction that has operated on "
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

					/* If connection is already unsalvageable, don't touch it further. */
					if (entry->changing_xact_state)
						break;

					/* Mark this connection as in the process of changing transaction
					 * state. */
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
		if (hashvalue == 0 || 
			(cacheid == FOREIGNSERVEROID && entry->server_hashvalue == hashvalue))
			entry->invalidated = true;
	}
}

/**
 * 	tg_invalidate_connection
 */
void tg_invalidate_connection(Oid serverid, Oid userid) 
{
	ConnCacheKey key;
	ConnCacheEntry *entry;
	bool found;

	if (ConnectionHash == NULL)
		return;

	key = serverid;

	entry = (ConnCacheEntry *) hash_search(ConnectionHash, (const void *) &key,
	                                        HASH_FIND, &found);
	if (!found)
		return;

	if (entry->conn != NULL) {
		tg_conn_destroy(entry->conn);
		entry->conn = NULL;
	}
	entry->used_in_xact = false;
	entry->needs_reconnect = false;
}


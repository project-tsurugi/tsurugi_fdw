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
 *	@file	connection.cpp
 */

#include <iostream>
#include "ogawayama/stub/error_code.h"
#include "common/tsurugi.h"

#ifdef __cplusplus
extern "C" {
#endif

#include "postgres.h"
#include "optimizer/planner.h"
#include "tcop/utility.h"
#include "access/xact.h"

#include "access/htup_details.h"
#include "catalog/pg_user_mapping.h"
#include "mb/pg_wchar.h"
#include "miscadmin.h"
#include "pgstat.h"
#include "storage/latch.h"
#include "utils/hsearch.h"
#include "utils/inval.h"
#include "utils/memutils.h"
#include "utils/syscache.h"

#include "foreign/foreign.h"
#include "lib/stringinfo.h"
#include "nodes/pathnodes.h"
#include "utils/relcache.h"
#include "libpq-fe.h"

#ifdef __cplusplus
}
#endif 

typedef Oid ConnCacheKey;

/* Connection cache (initialized on first use) */
static HTAB *ConnectionHash = NULL;

bool xact_got_connection = false;

typedef struct ConnCacheEntry
{
	ConnCacheKey key;			/* hash key (must be first) */
	bool keep_conn;
	int			xact_depth;		/* 0 = no xact open, 1 = main xact open */
	bool		changing_xact_state;	/* xact state change in process */
	bool            invalidated;    /* true if reconnect is pending */
	uint32          server_hashvalue;       /* hash value of foreign server OID */
} ConnCacheEntry;

void handle_remote_xact(ForeignServer *server);
void begin_remote_xact(ConnCacheEntry *entry);
static void tsurugifdw_xact_callback(XactEvent event, void *arg);
static void tsurugifdw_inval_callback(Datum arg, int cacheid, uint32 hashvalue);

void handle_remote_xact(ForeignServer *server)
{
	bool found;
	ConnCacheEntry *entry;
	ConnCacheKey key;

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	if (ConnectionHash == NULL){
		HASHCTL         ctl;

		/* Create the hash table. */
		MemSet(&ctl, 0, sizeof(ctl));
		ctl.keysize = sizeof(ConnCacheKey);
		ctl.entrysize = sizeof(ConnCacheEntry);
		/* allocate ConnectionHash in the cache context */
		ctl.hcxt = CacheMemoryContext;
		ConnectionHash = hash_create("tsurugi_fdw connections", 8,
									 &ctl,
									 HASH_ELEM | HASH_BLOBS | HASH_CONTEXT);

		RegisterXactCallback(tsurugifdw_xact_callback, NULL);
		CacheRegisterSyscacheCallback(FOREIGNSERVEROID,
									  tsurugifdw_inval_callback, (Datum) 0);
	}

	/* Set flag that we did GetConnection during the current transaction */
	xact_got_connection = true;

	key = server->serverid;

	/* Find or create cached entry for requested connection. */
	entry = static_cast<ConnCacheEntry*>(hash_search(ConnectionHash, &key, HASH_ENTER, &found));

	if (!found) {
		entry->keep_conn = true;
		entry->xact_depth = 0;
		entry->changing_xact_state = false;
		entry->invalidated = false;
		entry->server_hashvalue =
			GetSysCacheHashValue1(FOREIGNSERVEROID, ObjectIdGetDatum(server->serverid));
	}

	/* Start a new remote transaction if needed. */
	begin_remote_xact(entry);
}


void begin_remote_xact(ConnCacheEntry *entry)
{
	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	auto tsurugi = Tsurugi::get_instance();
	/* Start main transaction if we haven't yet */
	if (entry->xact_depth <= 0)
	{
		auto server_oid = entry->key;
		ERROR_CODE error = tsurugi->start_transaction(server_oid);
		if (error != ERROR_CODE::OK)
		{
			elog(ERROR, "Failed to begin the Tsurugi transaction. (%d)\n%s", 
				(int) error, tsurugi->get_error_message(error).c_str());
		}
		entry->xact_depth = 1;
		entry->changing_xact_state = false;
	}
}

/*
 * tsurugifdw_xact_callback --- cleanup at main-transaction end.
 */
static void tsurugifdw_xact_callback(XactEvent event, void *arg)
{
	HASH_SEQ_STATUS scan;
	ConnCacheEntry *entry;
	ERROR_CODE error = ERROR_CODE::UNKNOWN;
	auto tsurugi = Tsurugi::get_instance();

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	/* Quick exit if no connections were touched in this transaction. */
	if (!xact_got_connection)
		return;

	/* Scan all connection cache entries to find open remote transactions, and close them. */
	hash_seq_init(&scan, ConnectionHash);
	while ((entry = (ConnCacheEntry *) hash_seq_search(&scan))){

		/* Ignore cache entry if no open connection right now */
		if (entry->keep_conn == false)
			continue;

		if (entry->xact_depth > 0) {

			switch (event){
				case XACT_EVENT_PARALLEL_PRE_COMMIT:
				case XACT_EVENT_PRE_COMMIT:
					/* Commit all remote transactions during pre-commit */
					entry->changing_xact_state = true;
					error = tsurugi->commit();
					if (error != ERROR_CODE::OK)
					{
						elog(ERROR, "Failed to commit the Tsurugi transaction. (%d)\n%s",
							 (int)error, tsurugi->get_error_message(error).c_str());
					}
					entry->changing_xact_state = false;
					break;

				case XACT_EVENT_PRE_PREPARE:
					ereport(ERROR,
							(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
								errmsg("cannot PREPARE a transaction that has operated on tsurugi_fdw foreign tables")));
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

					/* Mark this connection as in the process of changing transaction state. */
					entry->changing_xact_state = true;
					error = tsurugi->rollback();
					if (error != ERROR_CODE::OK) {
						elog(ERROR, "Failed to rollback the Tsurugi transaction. (%d)\n%s", 
                			(int) error, tsurugi->get_error_message(error).c_str());
					}
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
tsurugifdw_inval_callback(Datum arg, int cacheid, uint32 hashvalue)
{
	HASH_SEQ_STATUS scan;
	ConnCacheEntry *entry;

	Assert(cacheid == FOREIGNSERVEROID);

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	/* ConnectionHash must exist already, if we're registered */
	hash_seq_init(&scan, ConnectionHash);
	while ((entry = (ConnCacheEntry *) hash_seq_search(&scan)))
	{
		/* Ignore invalid entries */
		if (entry->keep_conn == false)
			continue;

		/* hashvalue == 0 means a cache reset, must clear all state */
		if (hashvalue == 0 || (cacheid == FOREIGNSERVEROID && entry->server_hashvalue == hashvalue))
			entry->invalidated = true;
	}
}

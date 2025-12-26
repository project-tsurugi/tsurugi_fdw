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
 * @file tg_show_tables.cpp
 * @brief Tsurugi User-Defined Functions.
 */

/* Primary include file for PostgreSQL (first file to be included). */
#include "postgres.h"
/* Related include files for PostgreSQL. */
#include "catalog/pg_foreign_server.h"
#include "utils/builtins.h"
#include "utils/syscache.h"

#include "fdw/tsurugi_utils.h"

PG_FUNCTION_INFO_V1(tg_show_tables);

/**
 * @brief Get a list of Tsurugi tables.
 * @param PG_FUNCTION_ARGS UDF arguments
 * @return Datum (JSON type) execution result report.
 */
Datum
tg_show_tables(PG_FUNCTION_ARGS)
{
	static const char* const kArgRemoteSchema = "remote_schema";
	static const char* const kArgServerName = "server_name";
	static const char* const kArgMode = "mode";
	static const char* const kArgModeSummary = "summary";
	static const char* const kArgModeDetail = "detail";
	static const char* const kArgPretty = "pretty";

	Oid server_oid = InvalidOid;
	bool detail_mode;
	bool success;
	char* result_json;

	char debug_log[1024];
	HeapTuple srv_tuple;

	// remote_schema argument
	char* arg_remote_schema = (!PG_ARGISNULL(0) ? text_to_cstring(PG_GETARG_TEXT_P(0)) : "");
	// server_name argument
	char* arg_server_name = (!PG_ARGISNULL(1) ? text_to_cstring(PG_GETARG_TEXT_P(1)) : "");
	// mode argument
	char* arg_mode = (!PG_ARGISNULL(2) ? text_to_cstring(PG_GETARG_TEXT_P(2)) : "");
	// pretty argument
	bool arg_pretty = PG_GETARG_BOOL(3);

	// Convert mode argument value to lowercase
	for (char* ptr = arg_mode; *ptr != '\0'; ptr++) {
			*ptr = tolower((unsigned char)*ptr);
	}

	/* Validate remote_schema argument. */
	if (strlen(arg_remote_schema) == 0) {
		ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_ATTRIBUTE_VALUE),
						errmsg("missing required argument \"%s\"", kArgRemoteSchema)));
	}

	/* Validate server_name argument. */
	if (strlen(arg_server_name) == 0) {
		ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_ATTRIBUTE_VALUE),
						errmsg("missing required argument \"%s\"", kArgServerName)));
	}

	/* Validate report mode argument. */
	if ((strcasecmp(arg_mode, kArgModeSummary) != 0) && (strcasecmp(arg_mode, kArgModeDetail) != 0)) {
		ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_ATTRIBUTE_VALUE),
						errmsg("invalid value (\"%s\") for parameter \"%s\"", arg_mode, kArgMode),
						errdetail("expected '%s' or '%s'", kArgModeSummary, kArgModeDetail)));
	}

	/* Validate pretty argument. */
	if (PG_ARGISNULL(3)) {
		ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_ATTRIBUTE_VALUE),
						errmsg("invalid value (NULL) for parameter \"%s\"", kArgPretty),
						errdetail("expected true or false")));
	}

	/* Get the Tsurugi server OID. */
	srv_tuple =
		SearchSysCache1(FOREIGNSERVERNAME, CStringGetDatum(arg_server_name));
	if (!HeapTupleIsValid(srv_tuple)) {
		ereport(ERROR, (errcode(ERRCODE_FDW_UNABLE_TO_ESTABLISH_CONNECTION),
						errmsg("server \"%s\" does not exist", arg_server_name)));
	}
	server_oid = ((Form_pg_foreign_server)GETSTRUCT(srv_tuple))->oid;
	ReleaseSysCache(srv_tuple);

	snprintf(debug_log, sizeof(debug_log),
			 "tsurugi_fdw : %s\n"
			 "Arguments:\n"
			 "  remote_schema: %s\n"
			 "  server_name  : %s (%u)\n"
			 "  mode         : %s\n"
			 "  pretty       : %s",
			 __func__, arg_remote_schema, arg_server_name, server_oid, arg_mode,
			 (arg_pretty ? "true" : "false"));
	elog(DEBUG2, "%s", debug_log);

	detail_mode = (strcasecmp(arg_mode, kArgModeDetail) == 0);
	success = tg_execute_show_tables(server_oid, arg_remote_schema, arg_server_name, arg_mode,
										  detail_mode, arg_pretty, &result_json);
	if (!success) {
		elog(ERROR, "%s", tg_get_error_message());
	}

	PG_RETURN_DATUM(DirectFunctionCall1(json_in, CStringGetDatum(result_json)));
}

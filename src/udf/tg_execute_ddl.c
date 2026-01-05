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
 * @file tg_execute_ddl.cpp
 * @brief Tsurugi User-Defined Functions.
 */

#include <regex.h>

/* Primary include file for PostgreSQL (first file to be included). */
#include "postgres.h"
/* Related include files for PostgreSQL. */
#include "catalog/pg_foreign_server.h"
#include "utils/builtins.h"
#include "utils/syscache.h"

#include "fdw/tsurugi_utils.h"

PG_FUNCTION_INFO_V1(tg_execute_ddl);

/**
 * @brief Execute the DDL in Tsurugi.
 * @param PG_FUNCTION_ARGS UDF arguments
 * @return DDL execution result.
 */
Datum
tg_execute_ddl(PG_FUNCTION_ARGS)
{
	static const char* const kArgServerName = "server_name";
	static const char* const kArgDdlStatement = "ddl_statement";
	static const char* allowed_statement[] = {
		"^[[:space:]]*CREATE[[:space:]]+(TABLE|INDEX)[[:space:]]+",
		"^[[:space:]]*DROP[[:space:]]+(TABLE|INDEX)[[:space:]]+"
	};
	static const size_t allowed_statement_count =
		sizeof(allowed_statement) / sizeof(allowed_statement[0]);

	Oid server_oid = InvalidOid;
	char debug_log[1024];
	HeapTuple srv_tuple;
	bool success;
	char* ddl_command;

	// ddl_statement argument
	char* arg_ddl_statement = (!PG_ARGISNULL(0) ? text_to_cstring(PG_GETARG_TEXT_P(0)) : "");
	// server_name argument
	char* arg_server_name = (!PG_ARGISNULL(1) ? text_to_cstring(PG_GETARG_TEXT_P(1)) : "");

	/* Validate server_name argument. */
	if (strlen(arg_ddl_statement) == 0) {
		ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_ATTRIBUTE_VALUE),
						errmsg("missing required argument %s", kArgServerName)));
	}

	/* Validate ddl_statement argument. */
	if (strlen(arg_server_name) == 0) {
		ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_ATTRIBUTE_VALUE),
						errmsg("missing required argument %s", kArgDdlStatement)));
	}

	/* Validate the DDL statement. */
	for (size_t i = 0; i < allowed_statement_count; ++i) {
		regex_t regex;
		int match;

		regcomp(&regex, allowed_statement[i], REG_EXTENDED | REG_ICASE);
		match = regexec(&regex, arg_ddl_statement, 0, NULL, 0);
		regfree(&regex);

		if (match == 0)
		{
			success = true;
			break;
		}
	}
	if (!success) {
		ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_ATTRIBUTE_VALUE),
						errmsg("\"%s\" is not supported", arg_ddl_statement)));
	}

	/* Get the Tsurugi server OID. */
	srv_tuple = SearchSysCache1(FOREIGNSERVERNAME, CStringGetDatum(arg_server_name));
	if (!HeapTupleIsValid(srv_tuple)) {
		ereport(ERROR, (errcode(ERRCODE_FDW_UNABLE_TO_ESTABLISH_CONNECTION),
						errmsg("server \"%s\" does not exist", arg_server_name)));
	}
	server_oid = ((Form_pg_foreign_server)GETSTRUCT(srv_tuple))->oid;
	ReleaseSysCache(srv_tuple);

	snprintf(debug_log, sizeof(debug_log),
			 "tsurugi_fdw : %s\n"
			 "Arguments:\n"
			 "  server_name  : %s\n"
			 "  ddl_statement: %s",
			 __func__, arg_server_name, arg_ddl_statement);
	elog(DEBUG2, "%s", debug_log);

	success = tg_execute_ddl_statement(server_oid, arg_ddl_statement, &ddl_command);
	if (!success) {
		elog(ERROR, "%s", tg_get_error_message());
	}

	PG_RETURN_TEXT_P(cstring_to_text(ddl_command));
}

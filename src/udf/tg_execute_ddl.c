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
 * @file tg_execute_ddl.c
 * @brief Tsurugi User-Defined Functions.
 */

#include <regex.h>

/* Primary include file for PostgreSQL (first file to be included). */
#include "postgres.h"
/* Related include files for PostgreSQL. */
#include "catalog/pg_foreign_server.h"
#include "miscadmin.h"
#include "nodes/parsenodes.h"
#include "parser/parser.h"
#include "tcop/utility.h"
#include "connection.h"
#include "utils/builtins.h"
#include "utils/syscache.h"

PG_FUNCTION_INFO_V1(tg_execute_ddl);

/**
 * @brief Execute the DDL in Tsurugi.
 * @param PG_FUNCTION_ARGS UDF arguments
 * @return DDL execution result.
 */
Datum
tg_execute_ddl(PG_FUNCTION_ARGS)
{
	static const char *const kArgServerName	  = "server_name";
	static const char *const kArgDdlStatement = "ddl_statement";
	static const char		*allowed_statement[] =
			{"^[[:space:]]*CREATE[[:space:]]+(TABLE|INDEX)[[:space:]]+",
			 "^[[:space:]]*DROP[[:space:]]+(TABLE|INDEX)[[:space:]]+"};
	static const size_t allowed_statement_count = sizeof(allowed_statement) /
												  sizeof(allowed_statement[0]);

	Oid			   server_oid = InvalidOid;
	char		   debug_log[1024];
	bool	success;
	TGconn *tg_conn;

	// ddl_statement argument
	char *arg_ddl =
			(!PG_ARGISNULL(0) ? text_to_cstring(PG_GETARG_TEXT_P(0)) : "");
	// server_name argument
	char *arg_server_name =
			(!PG_ARGISNULL(1) ? text_to_cstring(PG_GETARG_TEXT_P(1)) : "");

	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	/* Validate server_name argument. */
	if (strlen(arg_ddl) == 0)
		ereport(ERROR,
				(errcode(ERRCODE_FDW_INVALID_ATTRIBUTE_VALUE),
				 errmsg("missing required argument %s", kArgServerName)));

	/* Validate ddl_statement argument. */
	if (strlen(arg_server_name) == 0)
		ereport(ERROR,
				(errcode(ERRCODE_FDW_INVALID_ATTRIBUTE_VALUE),
				 errmsg("missing required argument %s", kArgDdlStatement)));

	/* Validate the DDL statement. */
	for (size_t i = 0; i < allowed_statement_count; ++i)
	{
		regex_t regex;
		int		match;

		regcomp(&regex, allowed_statement[i], REG_EXTENDED | REG_ICASE);
		match = regexec(&regex, arg_ddl, 0, NULL, 0);
		regfree(&regex);

		if (match == 0)
		{
			success = true;
			break;
		}
	}
	if (!success)
		ereport(ERROR,
				(errcode(ERRCODE_FDW_INVALID_ATTRIBUTE_VALUE),
				 errmsg("\"%s\" is not supported", arg_ddl)));

	/* Get the Tsurugi server OID. */
	server_oid = get_foreign_server_oid(arg_server_name, false);

	snprintf(
			debug_log,
			sizeof(debug_log),
			"tsurugi_fdw: %s\n"
			"Arguments:\n"
			"  server_name  : %s\n"
			"  ddl_statement: %s",
			__func__,
			arg_server_name,
			arg_ddl);
	elog(DEBUG2, "%s", debug_log);

	tg_conn = tsurugi_get_connection(server_oid);
	tsurugi_do_sql_command(tg_conn, arg_ddl);

	PG_RETURN_TEXT_P(cstring_to_text("execute succeeded"));
}

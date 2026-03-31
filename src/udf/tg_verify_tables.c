/*
 * Copyright 2025 Project tsurugi.
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
 * @file tg_verify_tables.c
 * @brief tsurugi User-Defined Functions.
 */

/* Primary include file for PostgreSQL (first file to be included). */
#include "postgres.h"
/* Related include files for PostgreSQL. */
#include "catalog/namespace.h"
#include "catalog/pg_foreign_server.h"
#include "catalog/pg_type.h"
#include "connection.h"
#include "miscadmin.h"
#include "utils/builtins.h"
#include "utils/syscache.h"

PG_FUNCTION_INFO_V1(tg_verify_tables);

#ifdef __cplusplus
}
#endif

/**
 * @brief Verify remote tables and local external tables.
 * @param PG_FUNCTION_ARGS UDF arguments
 * @return Datum (JSON type) execution result report.
 */
Datum
tg_verify_tables(PG_FUNCTION_ARGS)
{
	static const char *const kArgRemoteSchema = "remote_schema";
	static const char *const kArgServerName	  = "server_name";
	static const char *const kArgLocalSchema  = "local_schema";
	static const char *const kArgMode		  = "mode";
	static const char *const kArgModeSummary  = "summary";
	static const char *const kArgModeDetail	  = "detail";
	static const char *const kArgPretty		  = "pretty";

	TG_VERIFY_TABLE_PARAM param;
	char	 *result_json;
	TG_STATUS tg_status;
	TGconn	 *tg_conn;
	char debug_log[1024];

	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	/* remote_schema argument */
	param.remote_schema =
			(!PG_ARGISNULL(0) ? text_to_cstring(PG_GETARG_TEXT_P(0)) : "");
	/* server_name argument */
	param.server_name =
			(!PG_ARGISNULL(1) ? text_to_cstring(PG_GETARG_TEXT_P(1)) : "");
	/* local_schema argument */
	param.local_schema =
			(!PG_ARGISNULL(2) ? text_to_cstring(PG_GETARG_TEXT_P(2)) : "");
	/* mode argument */
	param.mode =
			(!PG_ARGISNULL(3) ? text_to_cstring(PG_GETARG_TEXT_P(3)) : "");
	/* pretty argument */
	param.pretty = PG_GETARG_BOOL(4);

	/* Convert mode argument value to lowercase. */
	for (char *ptr = param.mode; *ptr != '\0'; ptr++)
	{
		*ptr = tolower((unsigned char) *ptr);
	}

	/* Validate remote_schema argument. */
	if (strlen(param.remote_schema) == 0)
		ereport(ERROR,
				(errcode(ERRCODE_FDW_INVALID_ATTRIBUTE_VALUE),
				 errmsg("missing required argument \"%s\"",
						kArgRemoteSchema)));

	/* Validate server_name argument. */
	if (strlen(param.server_name) == 0)
		ereport(ERROR,
				(errcode(ERRCODE_FDW_INVALID_ATTRIBUTE_VALUE),
				 errmsg("missing required argument \"%s\"", kArgServerName)));

	/* Validate local schema argument. Only if the target is 'verification'. */
	if (strlen(param.local_schema) == 0)
		ereport(ERROR,
				(errcode(ERRCODE_FDW_INVALID_ATTRIBUTE_VALUE),
				 errmsg("missing required argument \"%s\"", kArgLocalSchema)));

	/* Validate report mode argument. */
	if ((strcasecmp(param.mode, kArgModeSummary) != 0) &&
		(strcasecmp(param.mode, kArgModeDetail) != 0))
		ereport(ERROR,
				(errcode(ERRCODE_FDW_INVALID_ATTRIBUTE_VALUE),
				 errmsg("invalid value (\"%s\") for parameter \"%s\"",
						param.mode,
						kArgMode),
				 errdetail(
						 "expected '%s' or '%s'",
						 kArgModeSummary,
						 kArgModeDetail)));

	/* Validate pretty argument. */
	if (PG_ARGISNULL(4))
		ereport(ERROR,
				(errcode(ERRCODE_FDW_INVALID_ATTRIBUTE_VALUE),
				 errmsg("invalid value (NULL) for parameter \"%s\"",
						kArgPretty),
				 errdetail("expected true or false")));

	/* Get the Tsurugi server OID. */
	param.server_id = get_foreign_server_oid(param.server_name, false);
	param.local_schema_oid = InvalidOid;
	/* Get the local schema OID. */
	param.local_schema_oid = get_namespace_oid(param.local_schema, true);
	if (!OidIsValid(param.local_schema_oid))
	{
		ereport(ERROR,
				(errcode(ERRCODE_FDW_SCHEMA_NOT_FOUND),
				 errmsg("local schema \"%s\" does not exist",
						param.local_schema)));
	}

	snprintf(
			debug_log,
			sizeof(debug_log),
			"tsurugi_fdw: %s\n"
			"Arguments:\n"
			"  remote_schema: %s\n"
			"  server_name  : %s (%u)\n"
			"  local_schema : %s\n"
			"  mode         : %s\n"
			"  pretty       : %s",
			__func__,
			param.remote_schema,
			param.server_name,
			param.server_id,
			param.local_schema,
			param.mode,
			(param.pretty ? "true" : "false"));
	elog(DEBUG2, "%s", debug_log);

	param.detail = (strcasecmp(param.mode, kArgModeDetail) == 0);

	tg_conn	  = tsurugi_get_connection(param.server_id);
	tg_status = tg_exec_verify_tables(tg_conn, &param, &result_json);
	if (tg_status != TG_STATUS_OK)
		elog(ERROR, "%s", tg_global_error_message());

	PG_RETURN_DATUM(
			DirectFunctionCall1(json_in, CStringGetDatum(result_json)));
}

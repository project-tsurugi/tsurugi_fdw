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

#include <regex>
#include <string>
#include <vector>

#include "tsurugi.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Primary include file for PostgreSQL (first file to be included). */
#include "postgres.h"
/* Related include files for PostgreSQL. */
#include "utils/builtins.h"
#include "utils/syscache.h"

PG_FUNCTION_INFO_V1(tg_execute_ddl);

#ifdef __cplusplus
}
#endif

/**
 * @brief Execute the DDL in Tsurugi.
 * @param PG_FUNCTION_ARGS UDF arguments
 * @return DDL execution result.
 */
Datum
tg_execute_ddl(PG_FUNCTION_ARGS)
{
	static constexpr const char* const kArgServerName = "server_name";
	static constexpr const char* const kArgDdlStatement = "ddl_statement";
	static std::vector<std::string> allowed_statement = {
			R"_(^\s*CREATE\s+(TABLE|INDEX)\s+)_",
			R"_(^\s*DROP\s+(TABLE|INDEX)\s+)_"
	};

	// server_name argument
	std::string arg_server_name(!PG_ARGISNULL(0) ? text_to_cstring(PG_GETARG_TEXT_P(0)) : "");
	// ddl_statement argument
	std::string arg_ddl_statement(!PG_ARGISNULL(1) ? text_to_cstring(PG_GETARG_TEXT_P(1)) : "");

	/* Validate server_name argument. */
	if (arg_server_name.empty()) {
		ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_ATTRIBUTE_VALUE),
						errmsg(R"(missing required argument "%s")", kArgServerName)));
	}

	/* Validate ddl_statement argument. */
	if (arg_ddl_statement.empty()) {
		ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_ATTRIBUTE_VALUE),
						errmsg(R"(missing required argument "%s")", kArgDdlStatement)));
	}

	/* Validate the DDL statement. */
	std::smatch match;
	for (auto pattern : allowed_statement) {
		if (std::regex_search(arg_ddl_statement, match,
							  std::regex(pattern, std::regex_constants::icase))) {
			break;
		}
	}
	if (match.empty()) {
		ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_ATTRIBUTE_VALUE),
						errmsg(R"("%s" is not supported)", arg_ddl_statement.c_str())));
	}

	/* Get the Tsurugi server OID. */
	HeapTuple srv_tuple =
		SearchSysCache1(FOREIGNSERVERNAME, CStringGetDatum(arg_server_name.c_str()));
	if (!HeapTupleIsValid(srv_tuple)) {
		ereport(ERROR, (errcode(ERRCODE_FDW_UNABLE_TO_ESTABLISH_CONNECTION),
						errmsg(R"(server "%s" does not exist)", arg_server_name.c_str())));
	}
	ReleaseSysCache(srv_tuple);

	std::stringstream debug_log;
	debug_log << "tsurugi_fdw : " << __func__ << "\n"
			  << "Arguments:\n"
			  << "  server_name  : " << arg_server_name << "\n"
			  << "  ddl_statement: " << arg_ddl_statement;
	elog(DEBUG2, "%s", debug_log.str().c_str());

	ERROR_CODE error = ERROR_CODE::UNKNOWN;

	error = Tsurugi::init();
	if (error != ERROR_CODE::OK) {
		ereport(ERROR, (errcode(ERRCODE_FDW_UNABLE_TO_CREATE_REPLY),
						errmsg("%s", Tsurugi::get_error_message(error).c_str())));
	}

	error = Tsurugi::start_transaction();
	if (error != ERROR_CODE::OK) {
		ereport(ERROR, (errcode(ERRCODE_FDW_UNABLE_TO_CREATE_REPLY),
						errmsg("%s", Tsurugi::get_error_message(error).c_str())));
	}

	std::size_t num_rows;
	error = Tsurugi::execute_statement(arg_ddl_statement, num_rows);
	if (error != ERROR_CODE::OK) {
		Tsurugi::rollback();

		ereport(ERROR, (errcode(ERRCODE_FDW_UNABLE_TO_CREATE_REPLY),
						errmsg("%s", Tsurugi::get_error_message(error).c_str())));
	}

	error = Tsurugi::commit();
	if (error != ERROR_CODE::OK) {
		ereport(ERROR, (errcode(ERRCODE_FDW_UNABLE_TO_CREATE_REPLY),
						errmsg("%s", Tsurugi::get_error_message(error).c_str())));
	}

	/* Convert to uppercase for DDL command comparison. */
	std::string ddl_command(std::regex_replace(match.str(), std::regex(R"(^\s+|\s+$)"), ""));
	ddl_command = std::regex_replace(ddl_command, std::regex(R"(\s+)"), " ");
	std::transform(ddl_command.begin(), ddl_command.end(), ddl_command.begin(),
				   [](unsigned char c) { return std::toupper(c); });

	PG_RETURN_TEXT_P(cstring_to_text(ddl_command.c_str()));
}

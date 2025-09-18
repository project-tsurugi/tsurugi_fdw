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

#include <algorithm>
#include <regex>
#include <string>
#include <utility>
#include <vector>

#include <boost/property_tree/ptree.hpp>
#define BOOST_BIND_GLOBAL_PLACEHOLDERS
#include <boost/property_tree/json_parser.hpp>

#include "common/tsurugi.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Primary include file for PostgreSQL (first file to be included). */
#include "postgres.h"
/* Related include files for PostgreSQL. */
#include "access/htup_details.h"
#include "catalog/namespace.h"
#include "catalog/pg_foreign_server.h"
#include "utils/builtins.h"
#include "utils/syscache.h"

PG_FUNCTION_INFO_V1(tg_show_tables);

#ifdef __cplusplus
}
#endif

/**
 * @brief Get a list of Tsurugi tables.
 * @param PG_FUNCTION_ARGS UDF arguments
 * @return Datum (JSON type) execution result report.
 */
Datum
tg_show_tables(PG_FUNCTION_ARGS)
{
	static constexpr const char* const kArgRemoteSchema = "remote_schema";
	static constexpr const char* const kArgServerName = "server_name";
	static constexpr const char* const kArgMode = "mode";
	static constexpr const char* const kArgModeSummary = "summary";
	static constexpr const char* const kArgModeDetail = "detail";
	static constexpr const char* const kArgPretty = "pretty";
	static constexpr const char* const kKeyRootObject = "remote_schema";
	static constexpr const char* const kKeyRemoteSchema = "remote_schema";
	static constexpr const char* const kKeyServerName = "server_name";
	static constexpr const char* const kKeyMode = "mode";
	static constexpr const char* const kKeyRemoteTable = "tables_on_remote_schema";
	static constexpr const char* const kKeyCount = "count";
	static constexpr const char* const kKeyList = "list";

	// remote_schema argument
	std::string arg_remote_schema(!PG_ARGISNULL(0) ? text_to_cstring(PG_GETARG_TEXT_P(0)) : "");
	// server_name argument
	std::string arg_server_name(!PG_ARGISNULL(1) ? text_to_cstring(PG_GETARG_TEXT_P(1)) : "");
	// mode argument
	std::string arg_mode(!PG_ARGISNULL(2) ? text_to_cstring(PG_GETARG_TEXT_P(2)) : "");
	// pretty argument
	auto arg_pretty = PG_GETARG_BOOL(3);

	// Convert mode argument value to lowercase
	std::transform(arg_mode.begin(), arg_mode.end(), arg_mode.begin(),
				   [](unsigned char c) { return std::tolower(c); });

	/* Validate remote_schema argument. */
	if (arg_remote_schema.empty()) {
		ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_ATTRIBUTE_VALUE),
						errmsg(R"(missing required argument "%s")", kArgRemoteSchema)));
	}

	/* Validate server_name argument. */
	if (arg_server_name.empty()) {
		ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_ATTRIBUTE_VALUE),
						errmsg(R"(missing required argument "%s")", kArgServerName)));
	}

	/* Validate report mode argument. */
	if ((arg_mode != kArgModeSummary) && (arg_mode != kArgModeDetail)) {
		ereport(ERROR,
			(errcode(ERRCODE_FDW_INVALID_ATTRIBUTE_VALUE),
			errmsg(R"(invalid value ("%s") for parameter "%s")", arg_mode.c_str(), kArgMode),
			errdetail("expected '%s' or '%s'", kArgModeSummary, kArgModeDetail)));
	}

	/* Validate pretty argument. */
	if (PG_ARGISNULL(3)) {
		ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_ATTRIBUTE_VALUE),
						errmsg(R"(invalid value (NULL) for parameter "%s")", kArgPretty),
						errdetail("expected true or false")));
	}

	Oid server_oid = InvalidOid;
	/* Get the Tsurugi server OID. */
	HeapTuple srv_tuple =
		SearchSysCache1(FOREIGNSERVERNAME, CStringGetDatum(arg_server_name.c_str()));
	if (!HeapTupleIsValid(srv_tuple)) {
		ereport(ERROR, (errcode(ERRCODE_FDW_UNABLE_TO_ESTABLISH_CONNECTION),
						errmsg(R"(server "%s" does not exist)", arg_server_name.c_str())));
	}
	server_oid = ((Form_pg_foreign_server)GETSTRUCT(srv_tuple))->oid;
	ReleaseSysCache(srv_tuple);

	std::stringstream debug_log;
	debug_log << std::boolalpha << "tsurugi_fdw : " << __func__ << "\n"
			  << "Arguments:\n"
			  << "  remote_schema: " << arg_remote_schema << "\n"
			  << "  server_name  : " << arg_server_name << "\n"
			  << "  mode         : " << arg_mode << "\n"
			  << "  pretty       : " << arg_pretty;
	elog(DEBUG2, "%s", debug_log.str().c_str());

	ERROR_CODE error;
	TableListPtr tg_table_list;

	if (!Tsurugi::is_initialized(server_oid)) {
		/* Initializing connection to tsurugi server. */
		error = Tsurugi::init(server_oid);
		if (error != ERROR_CODE::OK) {
			ereport(ERROR, (errcode(ERRCODE_FDW_ERROR),
							errmsg("%s", Tsurugi::get_error_message(error).c_str())));
		}
	}

	/* Get a list of table names from Tsurugi. */
	error = Tsurugi::get_list_tables(tg_table_list);
	if (error != ERROR_CODE::OK) {
		ereport(ERROR,
			(errcode(ERRCODE_FDW_UNABLE_TO_CREATE_REPLY),
			errmsg("Failed to retrieve table list from Tsurugi. (error: %d)",
				static_cast<int>(error)),
			errdetail("%s", Tsurugi::get_error_message(error).c_str())));
	}

	boost::property_tree::ptree table_list;  // table list array
	/* Convert list of table names to ptree. */
	for (const auto& table_name : tg_table_list->get_table_names()) {
		boost::property_tree::ptree item;
		item.put("", table_name);
		table_list.push_back(std::make_pair("", item));
	}

	boost::property_tree::ptree pt_root;  // root object
	boost::property_tree::ptree remote_schema;  // <remote_schema> object
	boost::property_tree::ptree remote_tables;  // <tables_on_remote_schema> object

  /* Add to table count. */
	remote_tables.put(kKeyCount, table_list.size());

	/* If the report level is 'detail', add a table listing. */
	if ((arg_mode == kArgModeDetail)) {
		/* Add to table name list. */
		remote_tables.add_child(kKeyList, table_list);
	}

  /* Add to <remote_schema>. */
	remote_schema.put(kKeyRemoteSchema, arg_remote_schema);
	/* Add to <server_name>. */
	remote_schema.put(kKeyServerName, arg_server_name);
	/* Add to <mode>. */
	remote_schema.put(kKeyMode, arg_mode);
	/* Add to <tables_on_remote_schema> object. */
	remote_schema.add_child(kKeyRemoteTable, remote_tables);

  /* Add to root object. */
	pt_root.add_child(kKeyRootObject, remote_schema);

	std::stringstream ss;
	/* Convert to JSON. */
	try {
		boost::property_tree::json_parser::write_json(ss, pt_root, arg_pretty);
	} catch (const std::exception& e) {
		ereport(ERROR, (errcode(ERRCODE_FDW_ERROR), errmsg("JSON parser error"),
						errdetail("%s", e.what())));
	}
	std::string json_str(ss.str());

	/* Remove trailing newline code. */
	if (json_str.back() == '\n') {
		json_str.erase(json_str.size() - 1);
	}

	std::string separator = (arg_pretty ? " " : "");

	/* Converts the value of a numeric item from a string to a number. */
	auto pattern_num = (boost::format(R"_("%s":\s*"(\d+)")_") % kKeyCount).str();
	auto replace_num = (boost::format(R"("%s":%s$1)") % kKeyCount % separator).str();
	json_str = std::regex_replace(json_str, std::regex(pattern_num), replace_num);

	/* Converts an empty value of an array item from an empty character to an empty array. */
	auto pattern_array = (boost::format(R"("%s":\s*"")") % kKeyList).str();
	auto replace_array = (boost::format(R"("%s":%s[])") % kKeyList % separator).str();
	json_str = std::regex_replace(json_str, std::regex(pattern_array), replace_array);

	PG_RETURN_DATUM(DirectFunctionCall1(json_in, CStringGetDatum(json_str.c_str())));
}

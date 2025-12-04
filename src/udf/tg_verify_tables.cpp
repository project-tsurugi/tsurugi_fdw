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
 * @file tg_verify_tables.cpp
 * @brief Tsurugi User-Defined Functions.
 */

#include <algorithm>
#include <map>
#include <regex>
#include <string>
#include <unordered_map>
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
#include "catalog/namespace.h"
#include "catalog/pg_foreign_server.h"
#include "catalog/pg_type.h"
#include "executor/spi.h"
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
	static constexpr const char* const kArgRemoteSchema = "remote_schema";
	static constexpr const char* const kArgServerName = "server_name";
	static constexpr const char* const kArgLocalSchema = "local_schema";
	static constexpr const char* const kArgMode = "mode";
	static constexpr const char* const kArgModeSummary = "summary";
	static constexpr const char* const kArgModeDetail = "detail";
	static constexpr const char* const kArgPretty = "pretty";
	static constexpr const char* const kKeyRootObject = "verification";
	static constexpr const char* const kKeyRemoteSchema = "remote_schema";
	static constexpr const char* const kKeyServerName = "server_name";
	static constexpr const char* const kKeyLocalSchema = "local_schema";
	static constexpr const char* const kKeyMode = "mode";
	static constexpr const char* const kKeyRemoteOnly = "tables_on_only_remote_schema";
	static constexpr const char* const kKeyLocalOnly = "foreign_tables_on_only_local_schema";
	static constexpr const char* const kKeyAltered = "tables_that_need_to_be_altered";
	static constexpr const char* const kKeyAvailable = "available_foreign_table";
	static constexpr const char* const kKeyCount = "count";
	static constexpr const char* const kKeyList = "list";
	static const std::unordered_map<std::string, std::string> tz_abbreviate_type = {
		{"time without time zone", "time"}, {"timestamp without time zone", "timestamp"}};

	auto tsurugi = Tsurugi::get_instance();

	// remote_schema argument
	std::string arg_remote_schema(!PG_ARGISNULL(0) ? text_to_cstring(PG_GETARG_TEXT_P(0)) : "");
	// server_name argument
	std::string arg_server_name(!PG_ARGISNULL(1) ? text_to_cstring(PG_GETARG_TEXT_P(1)) : "");
	// local_schema argument
	std::string arg_local_schema(!PG_ARGISNULL(2) ? text_to_cstring(PG_GETARG_TEXT_P(2)) : "");
	// mode argument
	std::string arg_mode(!PG_ARGISNULL(3) ? text_to_cstring(PG_GETARG_TEXT_P(3)) : "");
	// pretty argument
	auto arg_pretty = PG_GETARG_BOOL(4);

	/* Convert mode argument value to lowercase. */
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

	/* Validate local schema argument. Only if the target is 'verification'. */
	if (arg_local_schema.empty()) {
		ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_ATTRIBUTE_VALUE),
						errmsg(R"(missing required argument "%s")", kArgLocalSchema)));
	}

	/* Validate report mode argument. */
	if ((arg_mode != kArgModeSummary) && (arg_mode != kArgModeDetail)) {
		ereport(ERROR,
			(errcode(ERRCODE_FDW_INVALID_ATTRIBUTE_VALUE),
			errmsg(R"(invalid value ("%s") for parameter "%s")", arg_mode.c_str(), kArgMode),
			errdetail("expected '%s' or '%s'", kArgModeSummary, kArgModeDetail)));
	}

	/* Validate pretty argument. */
	if (PG_ARGISNULL(4)) {
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

	Oid local_schema_oid = InvalidOid;
	/* Get the local schema OID. */
	local_schema_oid = get_namespace_oid(arg_local_schema.c_str(), true);
	if (!OidIsValid(local_schema_oid)) {
		ereport(ERROR, (errcode(ERRCODE_FDW_SCHEMA_NOT_FOUND),
						errmsg(R"(local schema "%s" does not exist)", arg_local_schema.c_str())));
	}

	std::stringstream debug_log;
	debug_log << std::boolalpha << "tsurugi_fdw : " << __func__ << "\n"
			  << "Arguments:\n"
			  << "  remote_schema: " << arg_remote_schema << "\n"
			  << "  server_name  : " << arg_server_name << "\n"
			  << "  local_schema : " << arg_local_schema << "\n"
			  << "  mode         : " << arg_mode << "\n"
			  << "  pretty       : " << arg_pretty;
	elog(DEBUG2, "%s", debug_log.str().c_str());

	ERROR_CODE error;
	TableListPtr tg_table_list;

	/* Get a list of table names from Tsurugi. */
	error = tsurugi->get_list_tables(server_oid, tg_table_list);
	if (error != ERROR_CODE::OK) {
		ereport(ERROR, (errcode(ERRCODE_FDW_UNABLE_TO_CREATE_REPLY),
						errmsg("Failed to retrieve table list from Tsurugi. (error: %d)",
							   static_cast<int>(error)),
						errdetail("%s", tsurugi->get_error_message(error).c_str())));
	}

	boost::property_tree::ptree list_remote;  // <tables_on_only_remote_schema> <list> array
	boost::property_tree::ptree list_local;  // <foreign_tables_on_only_local_schema> <list> array
	boost::property_tree::ptree list_altered;  // <tables_that_need_to_be_altered> <list> array
	boost::property_tree::ptree list_available;  // <available_foreign_table> <list> array

	if (SPI_connect() != SPI_OK_CONNECT) {
		ereport(ERROR,
				(errcode(ERRCODE_FDW_UNABLE_TO_CREATE_REPLY), errmsg("Failed to SPI_connect.")));
	}

	static const int kValRelname = 1;
	static const int kValAttname = 2;
	static const int kValDatatype = 3;
	static const int kValAtttypmod = 4;
	static constexpr const char* const kMetadataQuery =
		"SELECT "
		"  c.relname, a.attname, format_type(a.atttypid, a.atttypmod) AS datatype, a.atttypmod "
		"FROM pg_foreign_table ft "
		"  JOIN pg_class c ON ft.ftrelid = c.oid "
		"  JOIN pg_namespace n ON c.relnamespace = n.oid "
		"  JOIN pg_attribute a ON a.attrelid = c.oid "
		"WHERE "
		"  (n.oid = $1) AND (ft.ftserver = $2) AND (a.attnum > 0) AND (NOT a.attisdropped) "
		"ORDER BY c.relname, a.attnum";

	Oid argtypes[2] = {OIDOID, OIDOID};
	Datum values[2] = {ObjectIdGetDatum(local_schema_oid), ObjectIdGetDatum(server_oid)};
	char nulls[2] = {' ', ' '};

	/* Refer to the system catalog. */
	int res =
		SPI_execute_with_args(kMetadataQuery, sizeof(values), argtypes, values, nulls, true, 0);
	if (res != SPI_OK_SELECT) {
		ereport(ERROR, (errcode(ERRCODE_FDW_UNABLE_TO_CREATE_REPLY),
						errmsg("Failed to SPI_execute_with_args. (error: %d)", res)));
	}

	// Metadata of foreign tables
	std::unordered_map<std::string, std::vector<std::tuple<std::string, std::string, int, int>>>
		foreign_table_metadata = {};

	// List of Tsurugi table names
	auto tsurugi_table_names = tg_table_list->get_table_names();

	std::string skip_table_name = "";

	/* Verifies whether foreign tables in the local schema exist in the remote schema,
	 * and if so, retrieves metadata for the external tables.
	 */
	for (uint64 i = 0; i < SPI_processed; i++) {
		HeapTuple spi_tuple = SPI_tuptable->vals[i];
		TupleDesc tupdesc = SPI_tuptable->tupdesc;

		// Foreign table name
		std::string rel_name(SPI_getvalue(spi_tuple, tupdesc, kValRelname));

		if (rel_name == skip_table_name) {
			continue;
		}

		/* Add to a table that exists only in the remote schema. */
		auto ite = std::find(tsurugi_table_names.begin(), tsurugi_table_names.end(), rel_name);
		if (ite == tsurugi_table_names.end()) {
			elog(DEBUG2, R"(Tables that do not exist in the remote schema. "%s")",
				 rel_name.c_str());

			/* Add to a table that exists only in the remote schema. */
			list_local.push_back(std::make_pair("", boost::property_tree::ptree(rel_name)));

			skip_table_name = rel_name;
			continue;
		}
		skip_table_name = "";

		// column name
		char* column_name = SPI_getvalue(spi_tuple, tupdesc, kValAttname);

		// data type (string)
		std::string datatype(SPI_getvalue(spi_tuple, tupdesc, kValDatatype));
		std::transform(datatype.begin(), datatype.end(), datatype.begin(), ::tolower);

		bool is_null;
		// precision
		int precision = -1;
		// scale
		int scale = -1;

		Datum typmod_datum = SPI_getbinval(spi_tuple, tupdesc, kValAtttypmod, &is_null);
		int32 typmod = (!is_null ? DatumGetInt32(typmod_datum) : -1);
		if (typmod != -1) {
			precision = ((typmod - VARHDRSZ) >> 16) & 0xFFFF;
			scale = (typmod - VARHDRSZ) & 0xFFFF;
		}

		/* Stores metadata for foreign tables. */
		foreign_table_metadata[rel_name].emplace_back(std::make_tuple(column_name, datatype, precision, scale));
	}

	SPI_finish();

	/* Verifies whether tables in the remote schema exist in the local schema. */
	for (auto ite = tsurugi_table_names.begin(); ite != tsurugi_table_names.end();) {
		/* Verify that a remote table exists on the local. */
		if (foreign_table_metadata.find(*ite) == foreign_table_metadata.end()) {
			elog(DEBUG2, R"(Tables that do not exist in the local schema. "%s")", (*ite).c_str());

			/* Add to a table that exists only in the remote schema. */
			list_remote.push_back(std::make_pair("", boost::property_tree::ptree(*ite)));
			/* Exclude from metadata validation. */
			tsurugi_table_names.erase(ite);

			continue;
		}
		ite++;
	}

	/* Metadata Validation */
	for (const auto& table_name : tsurugi_table_names) {
		elog(DEBUG2, R"(Metadata Validation: table name: "%s")", table_name.c_str());

		TableMetadataPtr tsurugi_table_metadata;
		/* Get table metadata from Tsurugi. */
		error = tsurugi->get_table_metadata(server_oid, table_name, tsurugi_table_metadata);
		if (error != ERROR_CODE::OK) {
			ereport(ERROR, (errcode(ERRCODE_FDW_UNABLE_TO_CREATE_REPLY),
							errmsg("Failed to retrieve table metadata from Tsurugi. (error: %d)",
								   static_cast<int>(error)),
							errdetail("%s", tsurugi->get_error_message(error).c_str())));
		}

		/* Get table metadata from PostgreSQL. */
		const auto& pg_columns = foreign_table_metadata.find(table_name)->second;
		/* Get table metadata from Tsurugi. */
		const auto& tg_columns = tsurugi_table_metadata->columns();

		/* Validate the number of columns. */
		if (pg_columns.size() != static_cast<size_t>(tg_columns.size())) {
			elog(DEBUG2, "Number of columns does not match. local:%lu / remote:%d",
					pg_columns.size(), tg_columns.size());

			boost::property_tree::ptree item;
			item.put("", table_name);
			/* Add to a table with different column definitions. */
			list_altered.push_back(std::make_pair("", item));

			continue;
		}

		bool matched = true;
		int idx = 0;
		/* Validate the column metadata. */
		for (const auto& pg_column : pg_columns) {
			// Foreign table metadata
			const auto& [pg_col_name, pg_col_type, pg_col_precision, pg_col_scale] = pg_column;
			const auto& tg_column = tg_columns.at(idx++);

			elog(DEBUG5, R"(Column Validation: column name: "%s")", pg_col_name.c_str());

			/* Validate the column name. */
			if (pg_col_name != tg_column.name()) {
				elog(DEBUG2,
					R"_(Name of column does not match. position:%d (local:"%s" / remote:"%s"))_",
					idx, pg_col_name.c_str(), tg_column.name().c_str());

				matched = false;
				break;
			}

			/* Convert from Tsurugi datatype to PostgreSQL datatype. */
			auto remote_type_pg = Tsurugi::convert_type_to_pg(tg_column.atom_type());
			if (!remote_type_pg) {
				elog(DEBUG2, "Data type is unknown. %s (atom_type:%d)", pg_col_name.c_str(),
						static_cast<int>(tg_column.atom_type()));

				matched = false;
				break;
			}

			/* Correct time zone date/time type for PostgreSQL. */
			std::vector<std::string> local_type = {pg_col_type};
			const auto& pg_type = tz_abbreviate_type.find(pg_col_type);
			if (pg_type != tz_abbreviate_type.end()) {
				local_type.push_back(pg_type->second);
			}

			/* Validate the data type. */
			auto ite = std::find(local_type.begin(), local_type.end(), *remote_type_pg);
			if (ite == local_type.end()) {
				elog(DEBUG2,
						R"_(Datatype of column does not match. %s (local:"%s" / remote:"%s"))_",
						pg_col_name.c_str(), local_type[0].c_str(), remote_type_pg->data());

				matched = false;
				break;
			}

			/* Validate the precision and scale. */
			if ((pg_col_precision != -1) ||  (pg_col_scale != -1)) {
				elog(
					DEBUG2,
					R"_(Column precision/scale does not match. "%s (local: %s(%d,%d) / remote:%s))_",
					pg_col_name.c_str(), local_type[0].c_str(), pg_col_precision, pg_col_scale,
					remote_type_pg->data());

				matched = false;
				break;
			}
		}

		boost::property_tree::ptree list_item;
		list_item.put("", table_name);
		if (matched) {
			/* Add to the matching table. */
			list_available.push_back(std::make_pair("", list_item));
		} else {
			/* Add to a table with different column definitions. */
			list_altered.push_back(std::make_pair("", list_item));
		}
	}

	boost::property_tree::ptree pt_root;  // root object
	boost::property_tree::ptree verification;  // <verification> object

	/* Add to <remote_schema>. */
	verification.put(kKeyRemoteSchema, arg_remote_schema);
	/* Add to <server_name>. */
	verification.put(kKeyServerName, arg_server_name);
	/* Add to <local_schema>. */
	verification.put(kKeyLocalSchema, arg_local_schema);
	/* Add to <mode>. */
	verification.put(kKeyMode, arg_mode);

	/* Child object of a validation object. */
	std::map<const char*, const boost::property_tree::ptree*> child_object = {
		{kKeyRemoteOnly, &list_remote},
		{kKeyLocalOnly, &list_local},
		{kKeyAltered, &list_altered},
		{kKeyAvailable, &list_available}};

	/* Verification object is configured. */
	for (const auto& object : child_object) {
		const auto key = object.first;
		const auto list = object.second;

		boost::property_tree::ptree child;
		/* Add to table count. */
		child.put(kKeyCount, list->size());

		/* If the report level is 'detail', add a table listing. */
		if ((arg_mode == kArgModeDetail)) {
			/* Add to table name list. */
			child.add_child(kKeyList, *list);
		}

		/* Add to parent object. */
		verification.add_child(key, child);
	}

	/* Add to root object. */
	pt_root.add_child(kKeyRootObject, verification);

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

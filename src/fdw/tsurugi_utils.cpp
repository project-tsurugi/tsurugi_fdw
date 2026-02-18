/*
 * Copyright 2023-2025 Project Tsurugi.
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
 */
#include <string.h>
#include <memory>
#include <regex>
#include <string>
#include <stdexcept>
#include <boost/multiprecision/cpp_int.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/format.hpp>

#define BOOST_BIND_GLOBAL_PLACEHOLDERS
#include <boost/property_tree/json_parser.hpp>

#include <ogawayama/stub/api.h>
#include <ogawayama/stub/error_code.h>

#include "fdw/tsurugi_utils.h"
#include "tg_common/tsurugi.h"

#ifdef __cplusplus
extern "C" {
#endif
#include "postgres.h"
#include "catalog/pg_type.h"
#include "executor/spi.h"
#include "utils/rel.h"

#include "fdw/tsurugi_fdw.h"
#ifdef __cplusplus
}
#endif

/** ===========================================================================
 * 
 *  Import Foreign Schema Functions.
 * 
 */
bool tg_execute_import_foreign_schema(
		ImportForeignSchemaStmt* stmt, Oid serverOid, List **commands) {
	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	ERROR_CODE error = ERROR_CODE::UNKNOWN;
	*commands = nullptr;

	/* Get information about foreign server and user mapping. */
	ForeignServer* server = GetForeignServer(serverOid);
	//UserMapping* mapping = GetUserMapping(GetUserId(), server->serverid);

	elog(DEBUG2, "ForeignServer::fdwid: %u", server->fdwid);
	elog(DEBUG2, "ForeignServer::serverid: %u", server->serverid);
	elog(DEBUG2, R"(ForeignServer::servername: "%s")", server->servername);

	TableListPtr tg_table_list;
	/* Get a list of table names from Tsurugi. */
	error = Tsurugi::tsurugi().get_list_tables(server->serverid, tg_table_list);
	if (error != ERROR_CODE::OK)
	{
		Tsurugi::tsurugi().report_error("Failed to retrieve table list from Tsurugi.", error);
		return false;
	}

	auto tg_table_names = tg_table_list->get_table_names();

#ifdef ENABLE_IMPORT_TABLE_LIMITS
	/* The basic behavior regarding the restriction of tables to be imported is handled
	 * by PostgreSQL functions.
	 * FDW does not need to handle this and should be disabled.
	 */
	if ((stmt->list_type == FDW_IMPORT_SCHEMA_LIMIT_TO) || (stmt->list_type == FDW_IMPORT_SCHEMA_EXCEPT))
	{
		std::unordered_set<std::string> _table_list;
		ListCell* lc;
		foreach (lc, stmt->table_list)
		{
			_table_list.insert(((RangeVar*)lfirst(lc))->relname);
		}

		for (auto ite = tg_table_names.begin(); ite != tg_table_names.end();)
		{
			bool is_exclude_table = false;

			if (stmt->list_type == FDW_IMPORT_SCHEMA_LIMIT_TO)
			{
				/* include only listed tables in import */
				is_exclude_table = (_table_list.find(*ite) == _table_list.end());
			}
			else if (stmt->list_type == FDW_IMPORT_SCHEMA_EXCEPT)
			{
				/* exclude listed tables from import */
				is_exclude_table = (_table_list.find(*ite) != _table_list.end());
			}

			if (is_exclude_table)
			{
				elog(DEBUG2, R"(exclude table "%s" from import.)", (*ite).c_str());
				ite = tg_table_names.erase(ite);
			}
			else
			{
				++ite;
			}
		}
	}
#endif	// ENABLE_IMPORT_TABLE_LIMITS

	// List* result_commands = NIL;
	/* CREATE FOREIGN TABLE statments */
	for (const auto& table_name : tg_table_names)
	{
		TableMetadataPtr tg_table_metadata;

		/* Get table metadata from Tsurugi. */
		error = Tsurugi::tsurugi().get_table_metadata(server->serverid, table_name, tg_table_metadata);
		if (error != ERROR_CODE::OK)
		{
			Tsurugi::tsurugi().report_error(
					"Failed to retrieve table metadata from Tsurugi.", error);
			return false;
		}	

		/* Get table metadata from Tsurugi. */
		const auto &tg_columns = tg_table_metadata->columns();

		elog(DEBUG2, R"(table: "%.64s")", table_name.c_str());

		std::ostringstream col_def;  /* columns definition */
		/* Create PostgreSQL column definitions based on Tsurugi column definitions. */
		for (const auto& column : tg_columns)
		{
			/* Convert from Tsurugi datatype to PostgreSQL datatype. */
			auto pg_type = tsurugi::convert_type_to_pg(column.atom_type());
			if (!pg_type)
			{
				auto err_mesg =
					boost::format(R"(unsupported tsurugi data type "%d". (table:"%s" column:"%s"))") %
					static_cast<int>(column.atom_type()) % table_name % column.name();
				Tsurugi::tsurugi().report_error(err_mesg.str(), ERROR_CODE::UNSUPPORTED);
				return false;
			}
			std::string type_name(*pg_type);

			elog(DEBUG2,
				R"(column: {"name":"%.64s", "tsurugi_atom_type":%d, "postgres_type":"%s"})",
				column.name().c_str(), static_cast<int>(column.atom_type()), type_name.c_str());

			/* Create a column definition. */
			if (col_def.tellp() != 0)
			{
				col_def << ",";
			}
			col_def << "\"" << column.name() << "\" " << type_name;
		}

		/* Create a CREATE FOREIGN TABLE statement. */
		auto table_def =
			(boost::format(R"(CREATE FOREIGN TABLE "%s" (%s) SERVER %s)")
				% table_name.c_str() % col_def.str() % server->servername).str();

		elog(DEBUG1, "%.512s", table_def.c_str());

		*commands = lappend(*commands, pstrdup(table_def.c_str()));
	}

    return true;
}
 
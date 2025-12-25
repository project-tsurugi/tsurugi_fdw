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

using namespace ogawayama;

static std::string make_tsurugi_query(std::string_view query_string);
static std::string trim_query_string(const std::string& orig_query);
static std::pair<std::string, std::string> make_prepare_statement(const char* query);
static ogawayama::stub::placeholders_type make_placeholders(ParamListInfo param_linfo);
static ogawayama::stub::parameters_type make_parameters(ParamListInfo param_linfo);
static std::pair<std::string, std::string> tsurugi_prepare_wrapper(Oid server_oid,
                                                                    const char* query, 
                                                                    ParamListInfo param_linfo);

/** ===========================================================================
 * 
 *  Helper Functions.
 * 
 */

/**
 *  make_tsurugi_query
 *      
 */
static std::string 
make_tsurugi_query(std::string_view query_string)
{
    static const std::string PUBLIC_SCHEMA_NAME = "public\\.";
    static const std::string PUBLIC_DOUBLE_QUOTATION = "\"public\"\\.";

    std::string tsurugi_query(query_string);

	elog(DEBUG3, "tsurugi_fdw : %s", __func__);

	// erase public schema.
	std::smatch regex_match;
	std::regex regex_public(PUBLIC_SCHEMA_NAME, std::regex_constants::icase);
	while(std::regex_search(tsurugi_query, regex_match, regex_public)) {
		std::string::size_type erase_pos = tsurugi_query.find(regex_match.str(0));
		std::size_t erase_size = regex_match.str(0).size();
		tsurugi_query.erase(erase_pos, erase_size);
	}
	std::regex regex_double_quotation(PUBLIC_DOUBLE_QUOTATION);
	while(std::regex_search(tsurugi_query, regex_match, regex_double_quotation)) {
		std::string::size_type erase_pos = tsurugi_query.find(regex_match.str(0));
		std::size_t erase_size = regex_match.str(0).size();
		tsurugi_query.erase(erase_pos, erase_size);
	}

    // trim terminal semi-column.
    if (tsurugi_query.back() == ';') 
    {
        tsurugi_query.pop_back();
    }

    // convert the binary type literal.
    std::regex pattern(R"_(('\\x([0-9a-f]*)'))_", std::regex_constants::icase);
    auto replaced = std::regex_replace(tsurugi_query, pattern, "X'$2'");
    tsurugi_query = replaced;

    elog(DEBUG5, "tsurugi_fdw : Converted to Tsurugi query:\nsrc: %s\ndst: %s",
        query_string.data(), replaced.c_str());

    return tsurugi_query;
}

/**
 *  @brief  Trimming a string to remove comments and newline characters
 *  @param  (orig_query) input query string.
 *  @return	(query) trimmed query string.
 */
static std::string 
trim_query_string(const std::string& orig_query) 
{
 	elog(DEBUG3, "tsurugi_fdw : %s", __func__);

    // remove comments.
    std::regex commentPattern(R"((--[^\n]*)|(/\*[\s\S]*?\*/))");   
    std::string query = std::regex_replace(orig_query, commentPattern, "");

    // replace a line break character to a space.
    std::replace(query.begin(), query.end(), '\n', ' ');

    elog(DEBUG3, "tsurugi_fdw :\ntrimmed query string:\n%s", query.c_str());

    return query;
}

/**
 *  @brief  
 *  @param  
 *  @return	
 */
bool
is_prepare_statement(const char* query)
{
    auto sql = trim_query_string(query);
    return (boost::algorithm::icontains(sql, "PREPARE ") 
                || boost::algorithm::icontains(sql, "$") 
                || boost::algorithm::icontains(sql, ":param"));
}

/**
 *  @brief  Make prepare statement for tsurugidb.
 *  @param  (query)     SQL query.
 *  @return	(first)     prepare name.
 *          (second)    prepare statement.
 */
static std::pair<std::string, std::string>
make_prepare_statement(const char* query)
{
    elog(DEBUG3, "tsurugi_fdw : %s", __func__);

    auto orig_query = trim_query_string(query);
    std::string prep_name{};
    std::string prep_stmt{};
    if (boost::algorithm::icontains(orig_query, "PREPARE "))
    {
        // Remove 'PREPARE' clause.
        std::string prev_token{};
        std::vector<std::string> tokens;
        boost::split(tokens, orig_query, boost::is_any_of(" "));
        for (auto& token : tokens)
        {
            if (!pg_strcasecmp(prev_token.c_str(), "PREPARE"))
                prep_name = token;
            else if (!pg_strcasecmp(prev_token.c_str(), "AS") || !prep_stmt.empty())
                prep_stmt += token + " ";
            prev_token = token;
        }
        if (!prep_stmt.empty()) 
            prep_stmt.pop_back();   // remove a last space character.
    }
    else
    {
        prep_stmt = orig_query;
    }
    elog(DEBUG3, "tsurugi_fdw : prep_name: %s,\nprepare statement = \n%s", 
        prep_name.c_str(), prep_stmt.c_str());

    if (boost::algorithm::icontains(query, "$") )
    {
        try {
            // Replace place holder characters.
            size_t pos = 0;
            size_t offset = 0;
            std::string from{"$"};
            std::string to{":param"};
            while ((pos = prep_stmt.find(from, offset)) != std::string::npos) {
                prep_stmt.replace(pos, from.length(), to);
                offset = pos + to.length();
            }
        } catch (const std::logic_error& e) {
            elog(ERROR, "tsurugi_fdw : A logic_error exception occurred. what: %s", e.what());
        } catch (const std::exception& e) {
            elog(ERROR, "tsurugi_fdw : An exception occurred. what: %s", e.what());          
        }
    }
    elog(DEBUG3, "tsurugi_fdw : prep_name: %s,\nprepare statement = \n%s", 
        prep_name.c_str(), prep_stmt.c_str());

    return std::make_pair(prep_name, prep_stmt);
}

/**
 *  @brief  Prepare a statement to tsurugidb.
 *  @param  (server_oid) oid of tsurugi server.
 *  @param  (query) original query.
 *  @return	(first)     prepare name.
 *          (second)    prepared statement string.
 */
static std::pair<std::string, std::string>
tsurugi_prepare_wrapper(Oid server_oid,
                        const char* query,
                        ParamListInfo param_linfo)
{
 	elog(DEBUG3, "tsurugi_fdw : %s", __func__);

    auto prep = make_prepare_statement(query);
    auto placeholders = make_placeholders(param_linfo);
    auto prep_stmt = make_tsurugi_query(prep.second);
	auto error = Tsurugi::tsurugi().prepare(server_oid, prep_stmt, placeholders);
	if (error != ERROR_CODE::OK) {
		Tsurugi::tsurugi().report_error("Failed to prepare the statement on Tsurugi.", 
				error, query);
		prep.first.clear();
		prep.second.clear();
	}

    return prep;
}

/**
 *  @brief  Make parameters of prepared statement.
 *  @param  (param_linfo) ParamListInfo structure.
 *  @return	parameters_type object.
 */
static ogawayama::stub::parameters_type
make_parameters(ParamListInfo param_linfo)
{
	elog(DEBUG3, "tsurugi_fdw : %s", __func__);

    stub::parameters_type params{};
    if (param_linfo != nullptr)
    {
        for (auto i = 0; i < param_linfo->numParams; i++)
        {	
            /* parameter number is 1 origin. */
            auto param_name = "param" + std::to_string(i+1);
            ParamExternData param = param_linfo->params[i];
            if (param.isnull)
            {
                std::monostate mono{};
                params.emplace_back(param_name, mono);
            }
            else
            {
                auto value = tsurugi::convert_type_to_tg(param.ptype, param.value);
                params.emplace_back(param_name, value);
            }
        }
    }

    return params;
}

/**
 *  @brief  Make placeholders of prepare statement.
 *  @param  (param_linfo) parameter list.
 *  @return	placeholders_type object.
 */
static ogawayama::stub::placeholders_type
make_placeholders(ParamListInfo param_linfo)
{
 	elog(DEBUG3, "tsurugi_fdw : %s", __func__);

    stub::placeholders_type placeholders{};
    if (param_linfo != nullptr)
    {
        for (auto i = 0; i < param_linfo->numParams; i++)
        {
            /* parameter name is 1 origin. */
            std::string param_name = "param" + std::to_string(i+1);
            stub::Metadata::ColumnType::Type tg_type = 
                tsurugi::get_tg_column_type(param_linfo->params[i].ptype);
            placeholders.emplace_back(param_name, tg_type);
        }
        elog(DEBUG1, "tsurugi_fdw : placeholders: %d", param_linfo->numParams);
    }

    return placeholders;
}

/** ===========================================================================
 * 
 *  Scan Functions.
 * 
 */

/**
 *  @brief  Execute the query.
 *  @param  (node) Pointer to ForeignScanState structure.
 *  @return	(true) 	success.
 * 			(false) failure
 */
bool
tg_create_cursor(ForeignScanState* node)
{
 	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	TgFdwForeignScanState* fsstate = (TgFdwForeignScanState*) node->fdw_state;
    
    if (is_prepare_statement(fsstate->query_string))
    {
        ForeignTable* ft = GetForeignTable(fsstate->rel->rd_id);
        // Prepare the statement.
        auto prep = tsurugi_prepare_wrapper(ft->serverid,
                                            fsstate->query_string,
                                            fsstate->param_linfo);
		if (prep.second.empty()) {
			return false;
		}
        // Execute the prepared statement.
        auto params = make_parameters(fsstate->param_linfo);
		elog(DEBUG3, "tsurugi_fdw : Execute the prepared statement \nstmt:\n%s", 
				prep.second.c_str());
		auto error = Tsurugi::tsurugi().execute_query(params);
		if (error != ERROR_CODE::OK) {
			Tsurugi::tsurugi().report_error("Failed to execute the prepared statement", 
					error, fsstate->query_string);
			return false;
		}
    }
    else
    {
        // Execute the query.
        auto query = make_tsurugi_query(fsstate->query_string);
        auto error = Tsurugi::tsurugi().execute_query(query);
		if (error != ERROR_CODE::OK) {
			Tsurugi::tsurugi().report_error("Failed to execute the query on Tsurugi.", 
					error, query);
			return false;
		}
    }

	return true;
}

/**
 * make_tuple_from_result_row
 *      Obtain tuple data from Ogawayama and convert data type.
 */
static void 
make_tuple_from_result_row(ResultSetPtr result_set, 
                            TupleDesc tupleDescriptor,
                            List* retrieved_attrs,
                            Datum* row,
                            bool* is_null)
{
	elog(DEBUG5, "tsurugi_fdw : %s", __func__);

	memset(row, 0, sizeof(Datum) * tupleDescriptor->natts);
	memset(is_null, true, sizeof(bool) * tupleDescriptor->natts);

	ListCell   *lc = NULL;
	foreach(lc, retrieved_attrs)
	{
		int     attnum = lfirst_int(lc) - 1;
        Form_pg_attribute pg_attr =TupleDescAttr(tupleDescriptor, attnum);

		elog(DEBUG5, "tsurugi_fdw : %s : attnum: %d", __func__, attnum + 1);

        auto tsurugi_value = tsurugi::convert_type_to_pg(result_set, pg_attr->atttypid);
        is_null[attnum] = tsurugi_value.first;  // null flag
        if (!is_null[attnum])
            row[attnum] = tsurugi_value.second; // value       
    }
    result_set = nullptr;
}

bool tg_execute_foreign_scan(TgFdwForeignScanState *fsstate, TupleTableSlot *tupleSlot)
{
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);
    
	bool success = false;
    
	ERROR_CODE error = Tsurugi::tsurugi().result_set_next_row();
	if (error == ERROR_CODE::OK)
	{
		make_tuple_from_result_row(Tsurugi::tsurugi().get_result_set(), 
  								   tupleSlot->tts_tupleDescriptor,
								   fsstate->retrieved_attrs,
								   tupleSlot->tts_values,
								   tupleSlot->tts_isnull);
		ExecStoreVirtualTuple(tupleSlot);
		fsstate->num_tuples++;
		success = true;
	}
	else if (error == ERROR_CODE::END_OF_ROW) 
	{
		/* No more rows/data exists */
		Tsurugi::tsurugi().init_result_set();
		elog(DEBUG1, "tsurugi_fdw : End of rows. (rows: %d)", (int) fsstate->num_tuples);
		success = true;
	}
	else
	{
		//	an error occurred.
		Tsurugi::tsurugi().init_result_set();
//		Tsurugi::tsurugi().report_error("Failed to retrieve result set from Tsurugi.", 
//				error, fsstate->query_string);
	}

	return success;
}

/** ===========================================================================
 * 
 *  Modify Functions.
 * 
 */

/**
 *  @brief  Prepare a statement for direct modify.
 *  @param  (dmstate) Pointer to Direct Modify State structre.
 *  @return	none.
 */
bool
tg_prepare_direct_modify(TgFdwDirectModifyState* dmstate)
{
	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	Assert(dmstate->param_linfo != nullptr);
	ParamListInfo param_linfo = dmstate->param_linfo;
	elog(DEBUG3, "tsurugi_fdw :\norig_query:\n%s", dmstate->orig_query);

	auto prep = make_prepare_statement(dmstate->orig_query);
	auto placeholders = make_placeholders(param_linfo);
	auto prep_stmt = make_tsurugi_query(prep.second);
    
	auto error = Tsurugi::tsurugi().prepare(dmstate->server->serverid, prep_stmt, 
											placeholders);
	if (error != ERROR_CODE::OK) {
		Tsurugi::tsurugi().report_error("Failed to prepare the statement on Tsurugi.",
				error, prep_stmt);
		return false;
	}
	dmstate->prep_stmt = strdup(prep_stmt.c_str());

	return true;
}

/**
 *  @brief  Execute a direct modification.
 *  @param  (node) Pointer to ForeignScanStte structure.
 *  @return	none.
 */
bool
tg_execute_direct_modify(ForeignScanState* node)
{
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	TgFdwDirectModifyState *dmstate = (TgFdwDirectModifyState *) node->fdw_state;
    dmstate->set_processed = false;
    ParamListInfo param_linfo = dmstate->param_linfo;
    
    if (dmstate->prep_stmt != nullptr)
    {
        // Execute the prepared statement.
        stub::parameters_type params;
        if (param_linfo != nullptr && param_linfo->numParams > 0)
            params = make_parameters(param_linfo);
        elog(DEBUG3, "tsurugi_fdw : %s\nstatement:\n%s", __func__, dmstate->prep_stmt);                                    
        auto error = Tsurugi::tsurugi().execute_statement(params, dmstate->num_tuples);
		if (error != ERROR_CODE::OK) {
			Tsurugi::tsurugi().report_error(
					"Failed to execute the statement on Tsurugi.", 
					error, dmstate->prep_stmt);
			return false;
		}
    }
    else
    {
        // Execute the original statement.
        auto stmt = make_tsurugi_query(dmstate->orig_query);
      	auto error = Tsurugi::tsurugi().execute_statement(stmt, dmstate->num_tuples);
		if (error != ERROR_CODE::OK) {
			Tsurugi::tsurugi().report_error(
					"Failed to execute the statement on Tsurugi.", error, stmt);
			return false;
		}
    }
    dmstate->set_processed = true;

	return true;
}

/** ===========================================================================
 * 
 *  Import Foreign Schema Functions.
 * 
 */
bool
tg_execute_import_foreign_schema(ImportForeignSchemaStmt* stmt, Oid serverOid, List **commands)
{
	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

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

/**
 * @brief Execute the DDL in Tsurugi.
 * @param server_oid tsurugi server oid.
 * @param ddl_statement ddl statement.
 * @param result execution ddl command.
 * @retval true success.
 * @retval false failure.
 */
bool
tg_execute_ddl_statement(Oid server_oid, const char* ddl_statement, char** result)
{
	ERROR_CODE error = ERROR_CODE::UNKNOWN;

	error = Tsurugi::tsurugi().start_transaction(server_oid);
	if (error != ERROR_CODE::OK) {
		Tsurugi::tsurugi().report_error("Failed to start_transaction().", error, ddl_statement);
		return false;
	}

	std::size_t num_rows;
	error = Tsurugi::tsurugi().execute_statement(ddl_statement, num_rows);
	if (error != ERROR_CODE::OK) {
		Tsurugi::tsurugi().rollback();

		Tsurugi::tsurugi().report_error("Failed to execute_statement().", error, ddl_statement);
		return false;
	}

	error = Tsurugi::tsurugi().commit();
	if (error != ERROR_CODE::OK) {
		Tsurugi::tsurugi().report_error("Failed to commit().", error, ddl_statement);
		return false;
	}

	/* Convert to uppercase for DDL command comparison. */
	std::smatch match;
	std::string ddl_command(ddl_statement);
	std::regex_search(ddl_command, match, std::regex(R"_(^\s*([^\s]+)\s+([^\s]+))_"));

	ddl_command = std::regex_replace(match.str(), std::regex(R"(^\s+|\s+$)"), "");
	ddl_command = std::regex_replace(ddl_command, std::regex(R"(\s+)"), " ");
	std::transform(ddl_command.begin(), ddl_command.end(), ddl_command.begin(),
				   [](unsigned char c) { return std::toupper(c); });

	*result = pstrdup(ddl_command.c_str());

	return true;
}

/**
 * @brief Get a list of Tsurugi tables.
 * @param server_oid tsurugi server oid.
 * @param tg_schema tsurugi schema name.
 * @param tg_server tsurugi server name.
 * @param mode report mode argument string.
 * @param detail detail report flag.
 * @param pretty pretty report flag.
 * @param result execution result report.
 * @retval true success.
 * @retval false failure.
 */
bool
tg_execute_show_tables(Oid server_oid,
	                     const char* tg_schema,
											 const char* tg_server,
											 const char* mode,
											 bool detail,
											 bool pretty,
											 char** result)
{
	static constexpr const char* const kKeyRootObject = "remote_schema";
	static constexpr const char* const kKeyRemoteSchema = "remote_schema";
	static constexpr const char* const kKeyServerName = "server_name";
	static constexpr const char* const kKeyMode = "mode";
	static constexpr const char* const kKeyRemoteTable = "tables_on_remote_schema";
	static constexpr const char* const kKeyCount = "count";
	static constexpr const char* const kKeyList = "list";

	ERROR_CODE error;
	TableListPtr tg_table_list;

	/* Get a list of table names from Tsurugi. */
	error = Tsurugi::tsurugi().get_list_tables(server_oid, tg_table_list);
	if (error != ERROR_CODE::OK) {
		Tsurugi::tsurugi().report_error("Failed to retrieve table list from Tsurugi.", error);
		return false;
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
	if (detail) {
		/* Add to table name list. */
		remote_tables.add_child(kKeyList, table_list);
	}

  /* Add to <remote_schema>. */
	remote_schema.put(kKeyRemoteSchema, tg_schema);
	/* Add to <server_name>. */
	remote_schema.put(kKeyServerName, tg_server);
	/* Add to <mode>. */
	remote_schema.put(kKeyMode, mode);
	/* Add to <tables_on_remote_schema> object. */
	remote_schema.add_child(kKeyRemoteTable, remote_tables);

  /* Add to root object. */
	pt_root.add_child(kKeyRootObject, remote_schema);

	std::stringstream ss;
	/* Convert to JSON. */
	try {
		boost::property_tree::json_parser::write_json(ss, pt_root, pretty);
	} catch (const std::exception& e) {
		Tsurugi::tsurugi().report_error("JSON parser error", ERROR_CODE::UNKNOWN);
		return false;
	}
	std::string json_str(ss.str());

	/* Remove trailing newline code. */
	if (json_str.back() == '\n') {
		json_str.erase(json_str.size() - 1);
	}

	std::string separator = (pretty ? " " : "");

	/* Converts the value of a numeric item from a string to a number. */
	auto pattern_num = (boost::format(R"_("%s":\s*"(\d+)")_") % kKeyCount).str();
	auto replace_num = (boost::format(R"("%s":%s$1)") % kKeyCount % separator).str();
	json_str = std::regex_replace(json_str, std::regex(pattern_num), replace_num);

	/* Converts an empty value of an array item from an empty character to an empty array. */
	auto pattern_array = (boost::format(R"("%s":\s*"")") % kKeyList).str();
	auto replace_array = (boost::format(R"("%s":%s[])") % kKeyList % separator).str();
	json_str = std::regex_replace(json_str, std::regex(pattern_array), replace_array);

	*result = pstrdup(json_str.c_str());

	return true;
}

/**
 * @brief Verify remote tables and local external tables.
 * @param server_oid tsurugi server oid.
 * @param tg_schema tsurugi schema name.
 * @param tg_server tsurugi server name.
 * @param pg_schema_oid postgresql schema oid.
 * @param pg_schema postgresql schema name.
 * @param mode report mode argument string.
 * @param detail detail report flag.
 * @param pretty pretty report flag.
 * @param result execution result report.
 * @retval true success.
 * @retval false failure.
 */
bool
tg_execute_verify_tables(Oid server_oid,
	                     const char* tg_schema,
											 const char* tg_server,
											 Oid pg_schema_oid,
											 const char* pg_schema,
											 const char* mode,
											 bool detail,
											 bool pretty,
											 char** result)
{
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

	ERROR_CODE error = ERROR_CODE::UNKNOWN;
	TableListPtr tg_table_list;

	/* Get a list of table names from tsurugi. */
	error = Tsurugi::tsurugi().get_list_tables(server_oid, tg_table_list);
	if (error != ERROR_CODE::OK) {
		Tsurugi::tsurugi().report_error("Failed to retrieve table list from Tsurugi.", error);
		return false;
	}

	boost::property_tree::ptree list_remote;  // <tables_on_only_remote_schema> <list> array
	boost::property_tree::ptree list_local;  // <foreign_tables_on_only_local_schema> <list> array
	boost::property_tree::ptree list_altered;  // <tables_that_need_to_be_altered> <list> array
	boost::property_tree::ptree list_available;  // <available_foreign_table> <list> array

	if (SPI_connect() != SPI_OK_CONNECT) {
		Tsurugi::tsurugi().report_error("Failed to SPI_connect.", ERROR_CODE::UNKNOWN);
		return false;
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
	Datum values[2] = {ObjectIdGetDatum(pg_schema_oid), ObjectIdGetDatum(server_oid)};
	char nulls[2] = {' ', ' '};

	/* Refer to the system catalog. */
	int res =
		SPI_execute_with_args(kMetadataQuery, sizeof(values), argtypes, values, nulls, true, 0);
	if (res != SPI_OK_SELECT) {
		auto err_mesg = boost::format("Failed to SPI_execute_with_args. (error: %d)") % res;
		Tsurugi::tsurugi().report_error(err_mesg.str(), ERROR_CODE::UNKNOWN);
		return false;
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
		error = Tsurugi::tsurugi().get_table_metadata(server_oid, table_name, tsurugi_table_metadata);
		if (error != ERROR_CODE::OK) {
			Tsurugi::tsurugi().report_error("Failed to retrieve table metadata from tsurugi.",
											error);
			return false;
		}

		/* Get table metadata from PostgreSQL. */
		const auto& pg_columns = foreign_table_metadata.find(table_name)->second;
		/* Get table metadata from tsurugi. */
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

			/* Convert from tsurugi datatype to PostgreSQL datatype. */
			auto remote_type_pg = tsurugi::convert_type_to_pg(tg_column.atom_type());
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
	verification.put(kKeyRemoteSchema, tg_schema);
	/* Add to <server_name>. */
	verification.put(kKeyServerName, tg_server);
	/* Add to <local_schema>. */
	verification.put(kKeyLocalSchema, pg_schema);
	/* Add to <mode>. */
	verification.put(kKeyMode, mode);

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
		if (detail) {
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
		boost::property_tree::json_parser::write_json(ss, pt_root, pretty);
	} catch (const std::exception& e) {
		Tsurugi::tsurugi().report_error("JSON parser error", ERROR_CODE::UNKNOWN);
		return false;
	}
	std::string json_str(ss.str());

	/* Remove trailing newline code. */
	if (json_str.back() == '\n') {
		json_str.erase(json_str.size() - 1);
	}

	std::string separator = (pretty ? " " : "");

	/* Converts the value of a numeric item from a string to a number. */
	auto pattern_num = (boost::format(R"_("%s":\s*"(\d+)")_") % kKeyCount).str();
	auto replace_num = (boost::format(R"("%s":%s$1)") % kKeyCount % separator).str();
	json_str = std::regex_replace(json_str, std::regex(pattern_num), replace_num);

	/* Converts an empty value of an array item from an empty character to an empty array. */
	auto pattern_array = (boost::format(R"("%s":\s*"")") % kKeyList).str();
	auto replace_array = (boost::format(R"("%s":%s[])") % kKeyList % separator).str();
	json_str = std::regex_replace(json_str, std::regex(pattern_array), replace_array);

	*result = pstrdup(json_str.c_str());

	return true;
}

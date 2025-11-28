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
#include "fdw/tsurugi_utils.h"

#include <string.h>
#include <memory>
#include <regex>
#include <string>
#include <stdexcept>
#include <boost/multiprecision/cpp_int.hpp>
#include <boost/algorithm/string.hpp>

#include "fdw/tsurugi_fdw.h"
#include "common/tsurugi.h"

#include "ogawayama/stub/error_code.h"

#ifdef __cplusplus
extern "C" {
#endif
#include "commands/defrem.h"
#include "fmgr.h"
#include "nodes/nodeFuncs.h"
#include "funcapi.h"
#include "utils/date.h"
#include "utils/fmgrprotos.h"
#include "utils/guc.h"
#include "utils/lsyscache.h"
#include "utils/memutils.h"
#include "utils/numeric.h"
#include "utils/rel.h"
#include "utils/timestamp.h"
#ifdef __cplusplus
}
#endif

using namespace ogawayama;

std::string make_tsurugi_query(std::string_view query_string);
static std::string  trim_query_string(const std::string& orig_query) ;
static std::pair<std::string, std::string> make_prepare_statement(const char* query);
static ogawayama::stub::placeholders_type make_placeholders(ParamListInfo param_linfo);
static ogawayama::stub::parameters_type make_parameters(ParamListInfo param_linfo);
static std::pair<std::string, std::string> tsurugi_prepare_wrapper(Oid server_oid,
                                                                    const char* query, 
                                                                    ParamListInfo param_linfo);
/*
 *  make_tsurugi_query
 *      
 */
std::string make_tsurugi_query(std::string_view query_string)
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

    return tsurugi_query;
}

/*
 * make_tuple_from_result_row
 *      Obtain tuple data from Ogawayama and convert data type.
 */
void 
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

        auto tsurugi_value = Tsurugi::convert_type_to_pg(result_set, pg_attr->atttypid);
        is_null[attnum] = tsurugi_value.first;  // null flag
        if (!is_null[attnum])
            row[attnum] = tsurugi_value.second; // value       
    }
    result_set = nullptr;
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
 	elog(DEBUG3, "tsurugi_fdw : %s", __func__);

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
 *  @brief  Set placeholders of prepare statement.
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
                Tsurugi::get_tg_column_type(param_linfo->params[i].ptype);
            placeholders.emplace_back(param_name, tg_type);
        }
        elog(DEBUG1, "tsurugi_fdw : placeholders: %d", param_linfo->numParams);
    }

    return placeholders;
}

/**
 *  @brief  Prepare a statement to tsurugidb.
 *  @param  (server_oid) oid of tsurugi server.
 *  @param  (query) original query.
 *  @return	(first)     prepare name.
 *          (second)    prepare statement.
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
	ERROR_CODE error = Tsurugi::prepare(server_oid, prep_stmt, placeholders);
	if (error != ERROR_CODE::OK)
	{
		Tsurugi::report_error("Failed to prepare the statement to Tsurugi.", 
								error, prep_stmt);
	}

    return prep;
}

/**
 *  @brief  Bind parameters of a prepared statement.
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
                auto value = Tsurugi::convert_type_to_tg(param.ptype, param.value);
                params.emplace_back(param_name, value);
            }
        }
    }

    return params;
}

/**
 *  @brief  Execute the query.
 *  @param  (node) Pointer to ForeignScanState structure.
 *  @return	none.
 */
void
create_cursor(ForeignScanState* node)
{
 	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	TgFdwForeignScanState* fsstate = (TgFdwForeignScanState*) node->fdw_state;
    if (is_prepare_statement(fsstate->query_string))
    {
        ForeignTable *ft = GetForeignTable(fsstate->rel->rd_id);
        // Prepare the statement.
        auto prep = tsurugi_prepare_wrapper(ft->serverid,
                                            fsstate->query_string,
                                            fsstate->param_linfo);
        // Execute the prepared statement.
        auto params = make_parameters(fsstate->param_linfo);

        elog(DEBUG3, "tsurugi_fdw : Execute the prepared statement \nstmt:\n%s", 
            prep.second.c_str());                                    
        ERROR_CODE error =Tsurugi::execute_query(params);
        if (error != ERROR_CODE::OK)
        {
            Tsurugi::report_error("Failed to execute the statement on Tsurugi.", 
                                    error, prep.second);
        }
    }
    else
    {
        // Execute the query.
        auto query = make_tsurugi_query(fsstate->query_string);
        ERROR_CODE error = Tsurugi::execute_query(query);
        if (error != ERROR_CODE::OK)
        {
            Tsurugi::report_error("Failed to execute the query on Tsurugi.", 
                                    error, query.data());
        }
    }
}

/**
 *  @brief  Prepare a statement for direct modify.
 *  @param  (dmstate) Pointer to Direct Modify State structre.
 *  @return	none.
 */
void
prepare_direct_modify(TgFdwDirectModifyState* dmstate)
{
	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	Assert(dmstate->param_linfo != nullptr);
	ParamListInfo param_linfo = dmstate->param_linfo;

	elog(DEBUG3, "tsurugi_fdw :\norig_query:\n%s", dmstate->orig_query);

	auto prep = make_prepare_statement(dmstate->orig_query);
	auto placeholders = make_placeholders(param_linfo);
	auto prep_stmt = make_tsurugi_query(prep.second);

	ERROR_CODE error = Tsurugi::prepare(dmstate->server->serverid, prep_stmt, placeholders);
	if (error != ERROR_CODE::OK)
	{
		Tsurugi::report_error("Failed to prepare the statement to Tsurugi.", 
								error, prep_stmt);
	}
	dmstate->prep_stmt = strdup(prep_stmt.c_str());
}

/**
 *  @brief  Execute a direct modification.
 *  @param  (node) Pointer to ForeignScanStte structure.
 *  @return	none.
 */
void
execute_direct_modify(ForeignScanState* node)
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
        ERROR_CODE error =Tsurugi::execute_statement(params,
                                                    dmstate->num_tuples);
        if (error != ERROR_CODE::OK)
        {
            Tsurugi::report_error("Failed to execute the statement on Tsurugi.", 
                                    error, dmstate->prep_stmt);
        }        
    }
    else
    {
        // Execute the original statement.
        auto stmt = make_tsurugi_query(dmstate->orig_query);
        ERROR_CODE error = Tsurugi::execute_statement(stmt, dmstate->num_tuples);
        if (error != ERROR_CODE::OK)
        {
            Tsurugi::report_error("Failed to execute the statement on Tsurugi.", 
                                    error, stmt.data());
        }
    }
    dmstate->set_processed = true;
}


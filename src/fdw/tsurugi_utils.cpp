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

static const std::string PUBLIC_SCHEMA_NAME = "public\\.";
static const std::string PUBLIC_DOUBLE_QUOTATION = "\"public\"\\.";

#ifdef __TSURUGI_PLANNER__
std::string make_tsurugi_query(std::string_view query_string);
static std::string  trim_query_string(const std::string& orig_query) ;
static std::pair<std::string, std::string> make_prepare_statement(const char* query);
static ogawayama::stub::placeholders_type make_placeholders(ParamListInfo param_linfo);
static ogawayama::stub::parameters_type bind_parameters(ParamListInfo param_linfo);
static std::pair<std::string, std::string> tsurugi_prepare_wrapper(
                                                Oid server_oid,
                                                const char* query, 
                                                ParamListInfo param_linfo);
#else
static ogawayama::stub::parameters_type bind_parameters(Relation rel,
                                                        List* target_attrs,
                                                        FmgrInfo* flinfo,
                                                        TupleTableSlot **slots,
                                                        int numSlots);
#endif

/*
 *  make_tsurugi_query
 *      
 */
std::string make_tsurugi_query(std::string_view query_string)
{
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

#ifdef __TSURUGI_PLANNER__
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
#endif
#ifdef __TSURUGI_PLANNER__
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
    elog(LOG, "tsurugi_fdw : prep_name: %s,\nprepare statement = \n%s", 
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
    elog(LOG, "tsurugi_fdw : prep_name: %s,\nprepare statement = \n%s", 
        prep_name.c_str(), prep_stmt.c_str());

    return std::make_pair(prep_name, prep_stmt);
}
#else
/**
 *  @brief  Make prepare statement for tsurugidb.
 *  @param  (query)     SQL query.
 *  @return	(first)     prepare name.
 *          (second)    prepare statement.
 */
static std::pair<std::string, std::string>
make_prepare_statement(const char* query)
{
    std::string orig_query{query};
    std::string prep_name{};
    std::string prep_stmt{};
    if (boost::algorithm::icontains(orig_query, "prepare "))
    {
        // Remove 'PREPARE' clause.
        std::string prev_token{};
        std::vector<std::string> tokens;
        boost::split(tokens, orig_query, boost::is_any_of(" "));
        for (auto& token : tokens)
        {
            if (!pg_strcasecmp(prev_token.c_str(), "prepare"))
                prep_name = token;
            else if (!pg_strcasecmp(prev_token.c_str(), "as") || !prep_stmt.empty())
                prep_stmt += token + " ";
            prev_token = token;
        }
        prep_stmt.pop_back();  // remove a last space.       
    }
    else
    {
        prep_stmt = orig_query;
    }
    elog(LOG, "tsurugi_fdw : prep_name: %s,\nprepare statement = \n%s", 
        prep_name.c_str(), prep_stmt.c_str());

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
    elog(LOG, "tsurugi_fdw : prep_name: %s,\nprepare statement = \n%s", 
        prep_name.c_str(), prep_stmt.c_str());

    return std::make_pair(prep_name, prep_stmt);
}
#endif
#ifdef __TSURUGI_PLANNER__
/**
 *  @brief  Set placeholders of prepare statement.
 *  @param  (fdw_exprs) parameter node list.
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
#else
/**
 *  @brief  Set placeholders of prepare statement.
 *  @param  (fdw_exprs) parameter node list.
 *  @return	placeholders_type object.
 */
static ogawayama::stub::placeholders_type
make_placeholders(List* fdw_exprs)
{
 	elog(DEBUG3, "tsurugi_fdw : %s", __func__);

    stub::placeholders_type placeholders{};  
	ListCell   *lc;
	int i = 0;
	foreach(lc, fdw_exprs)
	{
		Node*   param_expr = (Node*) lfirst(lc);
    
        /* parameter name is 1 origin. */
        std::string param_name = "param" + std::to_string(i+1);
        placeholders.emplace_back(
            param_name, 
            Tsurugi::get_tg_column_type(exprType(param_expr)));
		i++;
	}
    elog(DEBUG1, "tsurugi_fdw : placeholders: %d", i);

    return placeholders;
}
#endif

#ifdef __TSURUGI_PLANNER__
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
#else
static std::pair<std::string, std::string>
tsurugi_prepare_wrapper(Oid server_oid,
                        const char* query,
                        PlanState* node,
                        List* fdw_exprs)
{
 	elog(DEBUG3, "tsurugi_fdw : %s", __func__);

    auto prep = make_prepare_statement(query);
    auto placeholders = make_placeholders(fdw_exprs);
    auto prep_stmt = make_tsurugi_query(prep.second);
	ERROR_CODE error = Tsurugi::prepare(server_oid, prep_stmt, placeholders);
	if (error != ERROR_CODE::OK)
	{
		Tsurugi::report_error("Failed to prepare the statement to Tsurugi.", 
								error, prep_stmt);
	}

    return prep;
}
#endif
#ifdef __TSURUGI_PLANNER__
/**
 *  @brief  Bind parameters of a prepared statement.
 *  @param  (param_linfo) ParamListInfo structure.
 *  @return	parameters_type object.
 */
static ogawayama::stub::parameters_type
bind_parameters(ParamListInfo param_linfo)
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
#else
/**
 *  @brief  Bind parameters of a prepared statement.
 *  @param  (econtext)  Pointer toExprContext structure.
 *          (param_exprs)   ExprState List.
 *          (param_flinfo)  Pointer to FmgrInfo structure. (for log output)
 *  @return	paramters_type object.
 */
static ogawayama::stub::parameters_type
bind_parameters(ExprContext* econtext,
				List* param_exprs,
				FmgrInfo* param_flinfo)
{
	elog(DEBUG3, "tsurugi_fdw : %s", __func__);

    stub::parameters_type params{};

	auto i = 0;
	ListCell   *lc;
	foreach(lc, param_exprs)
	{
		ExprState*  expr_state = (ExprState*) lfirst(lc);
		bool		isNull;
        
        /* parameter number is 1 origin. */
        auto param_name = "param" + std::to_string(i+1);

        /* Evaluate the parameter expression */
		Datum expr_value = ExecEvalExpr(expr_state, econtext, &isNull);

		/*
		 * Get string representation of each parameter value by invoking
		 * type-specific output function, unless the value is null.
		 */
		if (isNull)
        {
			std::monostate mono{};
            params.emplace_back(param_name, mono);
        }
		else
        {
            Oid typoid = exprType((Node*) expr_state->expr);
 			auto value = Tsurugi::convert_type_to_tg(typoid, expr_value);
            params.emplace_back(param_name, value);

            elog(LOG, "tsurugi_fdw : parameter name: %s, value: %s",
                param_name.c_str(), OutputFunctionCall(&param_flinfo[i], expr_value));
        }
        i++;
	}

    return params;
}
#endif

#ifdef __TSURUGI_PLANNER__
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
        auto params = bind_parameters(fsstate->param_linfo);

        elog(LOG, "tsurugi_fdw : Execute the prepared statement \nstmt:\n%s", 
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
#else
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
	ExprContext *econtext = node->ss.ps.ps_ExprContext;

    ForeignScan* fsplan = (ForeignScan*) node->ss.ps.plan;
    if (fsstate->numParams > 0)
    {
        ForeignTable *ft = GetForeignTable(fsstate->rel->rd_id);
        // Prepare the statement.
        auto prep = tsurugi_prepare_wrapper(ft->serverid,
                                            fsstate->query_string, 
                                            (PlanState *) node,
                                            fsplan->fdw_exprs);
        // Execute the prepared statement.
        auto params = bind_parameters(econtext, 
                                        fsstate->param_exprs,
                                        fsstate->param_flinfo);

        elog(LOG, "tsurugi_fdw : Execute the prepared statement \nstmt:\n%s", 
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
#endif

#ifdef __TSURUGI_PLANNER__
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

	elog(LOG, "tsurugi_fdw :\norig_query:\n%s", dmstate->orig_query);

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
#else
/*
 *	prepare_direct_modify
 *		Prepare a statement for direct modify.
 */
void
prepare_direct_modify(TgFdwDirectModifyState* dmstate, List* fdw_exprs)
{
	TupleDesc	tupdesc = RelationGetDescr(dmstate->rel);
	ListCell   *lc;
    
	Assert(tupdesc != nullptr);

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	/* Prepare for output conversion of parameters used in remote query. */
	dmstate->param_flinfo = (FmgrInfo *) palloc0(sizeof(FmgrInfo) * dmstate->numParams);
	dmstate->param_types = (Oid *) palloc0(sizeof(Oid) * dmstate->numParams);
	int i = 0;
	foreach(lc, fdw_exprs)
	{
		Node	   *param_expr = (Node *) lfirst(lc);
		Oid			typefnoid;
		bool		isvarlena;

		(dmstate->param_types)[i] = exprType(param_expr);
		getTypeOutputInfo(exprType(param_expr), &typefnoid, &isvarlena);
		fmgr_info(typefnoid, &(dmstate->param_flinfo)[i]);
		i++;
	}
    stub::placeholders_type placeholders{};
	for (i = 0; i < tupdesc->natts; i++)
	{
		/* parameter name is 1 origin. */
		std::string param_name = "param" + std::to_string(i+1);
		placeholders.emplace_back(std::make_pair(param_name, 
			Tsurugi::get_tg_column_type(tupdesc->attrs[i].atttypid)));
	}

    std::string prep_stmt = make_tsurugi_query(dmstate->query);
	ERROR_CODE error = Tsurugi::prepare(dmstate->server->serverid, prep_stmt, placeholders);
	if (error != ERROR_CODE::OK)
	{
		Tsurugi::report_error("Failed to prepare the statement on Tsurugi.", 
								error, prep_stmt);
	}
    dmstate->prep_stmt = strdup(prep_stmt.c_str());
}
#endif

#ifdef __TSURUGI_PLANNER__
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
            params = bind_parameters(param_linfo);
        elog(LOG, "tsurugi_fdw : %s\nstmt:\n%s", __func__, dmstate->prep_stmt);                                    
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
#else
/*
 *  execute_direct_modify_with_deparse_sql
 *      Execute a direct UPDATE/DELETE statement using deparesed sql.
 */
void 
execute_direct_modify(ForeignScanState* node)
{
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	TgFdwDirectModifyState *dmstate = (TgFdwDirectModifyState *) node->fdw_state;
//    EState* estate = node->ss.ps.state;
    dmstate->set_processed = false;

    if (dmstate->prep_stmt != nullptr)
    {
        // Execute the prepared statement.
        stub::parameters_type params;
        ExprContext *econtext = node->ss.ps.ps_ExprContext;
        if (dmstate->numParams > 0)
            params = bind_parameters(econtext,
                                    dmstate->param_exprs,
                                    dmstate->param_flinfo);
        elog(LOG, "tsurugi_fdw : %s\nstmt:\n%s", __func__, dmstate->prep_stmt);                                    
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
        std::string stmt = make_tsurugi_query(dmstate->orig_query);
        ERROR_CODE error = Tsurugi::execute_statement(stmt, dmstate->num_tuples);
        if (error != ERROR_CODE::OK)
        {
            Tsurugi::report_error("Failed to execute the statement on Tsurugi.", 
                                    error, stmt.data());
        }
    }
    dmstate->set_processed = true;
}
#endif
#ifndef __TSURUGI_PLANNER__
/*
 *	prepare_foreign_modify
 *		Prepare a statement for foreign modify.
 */
void
prepare_foreign_modify(TgFdwForeignModifyState *fmstate)
{
	TupleDesc	tupdesc = RelationGetDescr(fmstate->rel);
	stub::placeholders_type placeholders{};

	assert(tupdesc != nullptr);

	elog(DEBUG3, "tsurugi_fdw : %s", __func__);

	for (int i = 0; i < tupdesc->natts; i++)
	{
		/* parameter name is 1 origin. */
		std::string param_name = "param" + std::to_string(i+1);
		placeholders.emplace_back(param_name, 
                                Tsurugi::get_tg_column_type(tupdesc->attrs[i].atttypid));
	}

	ForeignTable *ft = GetForeignTable(fmstate->rel->rd_id);
    std::string stmt = make_tsurugi_query(fmstate->query);
	ERROR_CODE error = Tsurugi::prepare(ft->serverid, stmt, placeholders);
	if (error != ERROR_CODE::OK)
	{
		Tsurugi::report_error("Failed to prepare the statement on Tsurugi.", 
								error, fmstate->query);
	}
	fmstate->is_prepared = true;
}

/*
 *	bind_parameters
 *		Bind parameters of prepared statement.
 */
static ogawayama::stub::parameters_type
bind_parameters(Relation rel,
                List* target_attrs,
                FmgrInfo* flinfo,
			 	TupleTableSlot **slots,
			 	int numSlots)
{
	TupleDesc	tupdesc = RelationGetDescr(rel);
	stub::parameters_type params{};

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	if (slots != NULL && target_attrs != NIL)
	{
		int param_num = 0;
		ListCell   *lc;
		foreach(lc, target_attrs)
		{	
			int			attnum = lfirst_int(lc);
			Form_pg_attribute attr = TupleDescAttr(tupdesc, attnum - 1);
			Datum		value;
			bool		isnull;	
			std::string param_name = "param" + std::to_string(++param_num);

			/* Ignore generated columns; they are set to DEFAULT */
			if (attr->attgenerated)
				continue;
			value = slot_getattr(slots[0], attnum, &isnull);
			if (isnull)
			{
				std::monostate mono{};
				params.emplace_back(param_name, mono);
			}
			else
			{
				stub::value_type tg_type = Tsurugi::convert_type_to_tg(attr->atttypid, 
                                                                        value);
				params.emplace_back(param_name, tg_type);
				elog(LOG, "tsurugi_fdw : parameter name: %s, value: %s", 
					param_name.c_str(), 
					OutputFunctionCall(&flinfo[param_num-1], value));
			}
		}
        elog(LOG, "tsurugi_fdw : parameter count: %d", param_num);
	}

	return params;
}

/*
 * 	execute_foreign_modify
 *		Execute a INSERT statement.
 */
TupleTableSlot **
execute_foreign_modify(EState *estate,
					   ResultRelInfo *resultRelInfo,
					   CmdType operation,
					   TupleTableSlot **slots,
					   TupleTableSlot **planSlots,
					   int *numSlots)
{
	TgFdwForeignModifyState *fmstate = 
		(TgFdwForeignModifyState *) resultRelInfo->ri_FdwState;

	/* The operation should be INSERT, UPDATE, or DELETE */
	Assert(operation == CMD_INSERT ||
		   operation == CMD_UPDATE ||
		   operation == CMD_DELETE);

	elog(DEBUG3, "tsurugi_fdw : %s", __func__);

	/* Convert parameters needed by prepared statement to text form */
	//
	stub::parameters_type params = bind_parameters(fmstate->rel,
                                                    fmstate->target_attrs,
                                                    fmstate->p_flinfo, 
                                                    slots, *numSlots);

	/*
	 * Execute the prepared statement.
	 */
	std::size_t	n_rows = 0;
	ERROR_CODE error = Tsurugi::execute_statement(params, n_rows);
	if (error != ERROR_CODE::OK)
	{
		Tsurugi::report_error("Failed to execute the statement on Tsurugi.", 
								error, fmstate->query);
	}

	MemoryContextReset(fmstate->temp_cxt);

	*numSlots = n_rows;

	/*
	 * Return NULL if nothing was inserted/updated/deleted on the remote end
	 */
	return (n_rows > 0) ? slots : NULL;
}
#endif
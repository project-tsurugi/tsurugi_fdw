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
 */
#include <memory>
#include <optional>
#include <regex>
#include <string>

#include <boost/algorithm/string.hpp>
#include <boost/filesystem.hpp>
#include <boost/format.hpp>
#include <boost/property_tree/ini_parser.hpp>
#include <boost/property_tree/json_parser.hpp>
#define BOOST_BIND_GLOBAL_PLACEHOLDERS
#include <ogawayama/stub/api.h>
#include <ogawayama/stub/error_code.h>

#include "tsurugi.hpp"

#ifdef __cplusplus
extern "C" {
#endif
#include "postgres.h"
#include "tsurugi_api.h"

#include "catalog/pg_type_d.h"
#include "commands/defrem.h"
#include "executor/executor.h"
#include "executor/spi.h"
#include "foreign/foreign.h"
#include "miscadmin.h"
#include "nodes/execnodes.h"
#include "nodes/nodeFuncs.h"
#include "nodes/params.h"
#include "utils/rel.h"
#include "utils/relcache.h"
#ifdef __cplusplus
}
#endif

using namespace ogawayama;

namespace {
constexpr size_t kErrMsgSize = 1024;
char g_global_error[kErrMsgSize] = "tsurugi_fdw: no error";

typedef struct {
	char msg[kErrMsgSize];
	TG_STATUS code = TG_STATUS_OK;
} ErrorState;
};	// namespace

struct TGconn {
	static StubPtr stub;
	static ConnectionPtr impl;
	TransactionPtr tx;
	std::string endpoint;
	Oid server_id;
	bool subxact_seen = false;
	ErrorState error;
	TGconn() : tx(nullptr), server_id(InvalidOid) {}
};
StubPtr TGconn::stub = nullptr;
ConnectionPtr TGconn::impl = nullptr;

struct TGstmt {
	TGconn* conn;
	PreparedStatementPtr impl;
	std::string name;
	std::string sql;
	std::string original_sql;
	ogawayama::stub::placeholders_type placeholders;
	ogawayama::stub::parameters_type paramerters;
	ErrorState error;
	TGstmt() : conn(nullptr), impl(nullptr) {}
};

struct TGresult {
	TGstmt* stmt;
	ResultSetPtr impl;
	ErrorState error;
	TGresult() : stmt(nullptr), impl(nullptr) {}
};

struct TGtables {
	TGconn* conn;
	TableListPtr impl;
	boost::property_tree::ptree table_list;
	ErrorState error;
	TGtables() : conn(nullptr), impl(nullptr) {}
};

struct TGtable {
	TGconn* conn;
	TableMetadataPtr impl;
	ErrorState error;
	TGtable() : conn(nullptr), impl(nullptr) {}
};

extern bool GetTransactionOption(boost::property_tree::ptree&);

/* -------------------------------------------------------------------------
 * Error handlings.
 * ------------------------------------------------------------------------- 
 */
namespace {

/**
 *  @brief  Set error message to buffer.
 */
void set_error_msg(char* dest, int size, std::string_view msg) noexcept {
	if (!dest || size <= 0) return;
	if (msg.empty()) msg = "tsurugi_fdw: unknown error";
	pg_snprintf(dest, size, "%s", msg.data());
	dest[size - 1] = '\0';
}

/**
 *  @brief  Set the success status to error object.
 */
inline TG_STATUS set_ok(ErrorState& error) noexcept {
	set_error_msg(error.msg, kErrMsgSize, "tsurugi_fdw: no error");
	error.code = TG_STATUS_OK;
	return error.code;
}

/**
 *  @brief  Set the error message to global error.
 */
inline TG_STATUS set_error(
		const char* msg, const TG_STATUS code = TG_STATUS_ERROR) noexcept {
	try {
		std::ostringstream oss;
		oss << "tsurugi_fdw: " << msg;
		set_error_msg(g_global_error, kErrMsgSize, oss.str());
	} catch (...) {
	}
	return TG_STATUS_ERROR;
}

/**
 *  @brief  Set the error message to global error.
 */
inline TG_STATUS set_error(
		std::string_view msg, const TG_STATUS code = TG_STATUS_ERROR) noexcept {
	try {
		std::ostringstream oss;
		oss << "tsurugi_fdw: " << msg;
		set_error_msg(g_global_error, kErrMsgSize, oss.str());
	} catch (...) {
	}
	return TG_STATUS_ERROR;
}

/**
 *  @brief  Set the error message to error object.
 */
inline TG_STATUS set_error(ErrorState& error, std::string_view msg,
		const TG_STATUS code = TG_STATUS_ERROR) noexcept {
	try {
		std::ostringstream oss;
		oss << "tsurugi_fdw: " << msg;
		set_error_msg(error.msg, kErrMsgSize, oss.str());
	} catch (...) {
	}
	error.code = code;
	return error.code;
}

/**
 *  @brief  Set the expection w/o what to global error.
 */
inline TG_STATUS set_exception() noexcept {
	elog(DEBUG1, "tsurugi_fdw: %s (what: none)", __func__);
	set_error_msg(g_global_error, kErrMsgSize,
			"tsurugi_fdw: Unexpected exception occurred.");
	return TG_STATUS_EXCEPTION;
}

/**
 *  @brief  Set the expection w/ what to global error.
 */
inline TG_STATUS set_exception(const std::exception& e) noexcept {
	elog(DEBUG1, "tsurugi_fdw: %s (what: %s)", __func__, e.what());
	try {
		std::ostringstream oss;
		oss << "tsurugi_fdw: Unexpected exception occurred. (what: " << e.what()
			<< ")";
		set_error_msg(g_global_error, sizeof(g_global_error), oss.str());
	} catch (...) {
	}
	return TG_STATUS_EXCEPTION;
}

/**
 *  @brief  Set the expection w/o what to error object.
 */
inline TG_STATUS set_exception(ErrorState& error) noexcept {
	elog(DEBUG1, "tsurugi_fdw: %s (what: none)", __func__);
	try {
		std::ostringstream oss;
		set_error_msg(error.msg, kErrMsgSize,
				"tsurugi_fdw: Unexpected exception occurred.");
		error.code = TG_STATUS_EXCEPTION;
	} catch (...) {
	}
	return TG_STATUS_EXCEPTION;
}

/**
 *  @brief  Set the expection w/ what to error object.
 */
inline TG_STATUS set_exception(
		ErrorState& error, const std::exception& e) noexcept {
	elog(DEBUG1, "tsurugi_fdw: %s (what: %s)", __func__, e.what());
	try {
		std::ostringstream oss;
		oss << "tsurugi_fdw: Unexpected exception occurred. (what: " << e.what()
			<< ")";
		set_error_msg(error.msg, kErrMsgSize, oss.str());
		error.code = TG_STATUS_EXCEPTION;
	} catch (...) {
	}
	return TG_STATUS_EXCEPTION;
}

/**
 *  @brief 	Output log which has a message and return code.
 *  @param 	(level) log level.
 * 			(message) message.
 * 			(error) return code of ogawayama.
 *  @return	none.
 */
void log2(const int level, std::string_view message,
		const ERROR_CODE error) noexcept {
	assert(level != ERROR);

	try {
		std::ostringstream oss;
		oss << message
			<< "(error: " << error_name(error).data() << "{" << (int) error
			<< "})";
		elog(level, "%s", oss.str().c_str());
	} catch (...) {
	}
}

/**
 *  @brief 	Get detail message of tsurugi server.
 *  @param 	(error_code) error code of ogawayama.
 *  @return	detail error message.
 */
std::string get_detail_message(
		const TGconn* tg_conn, const ERROR_CODE error_code) noexcept {
	std::string message = "No detail message.";
	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	if (error_code != ERROR_CODE::SERVER_ERROR) {
		log2(LOG, "tsurugi_fdw: Error code is not SERVER_ERROR.", error_code);
		return message;
	}

	if (tg_conn->impl == nullptr) {
		elog(DEBUG1, "tsurugi_fdw: There is no connection to Tsurugi.");
		return message;
	}

	//  get detail message from Tsurugi.
	stub::tsurugi_error_code error{};
	auto ret_code = tg_conn->impl->tsurugi_error(error);
	if (ret_code == ERROR_CODE::OK) {
		elog(LOG,
				"ERROR_CODE::SERVER_ERROR\n\t"
				"tsurugi_error_code.type: %d\n\t"
				"                   code: %d\n\t"
				"                   name: %s\n\t"
				"                 detail: %s\n\t"
				"      supplemental_text: %s",
				(int) error.type, error.code, error.name.c_str(),
				error.detail.c_str(), error.supplemental_text.c_str());

		std::string detail_code;
		try {
			switch (error.type) {
				case stub::tsurugi_error_code::tsurugi_error_type::sql_error:
					detail_code =
							"SQL-" + (boost::format("%05d") % error.code).str();
					break;
				case stub::tsurugi_error_code::tsurugi_error_type::
						framework_error:
					detail_code =
							"SCD-" + (boost::format("%05d") % error.code).str();
					break;
				default:
					elog(WARNING, "Unknown error type. (type: %d)",
							(int) error.type);
					detail_code = "UNKNOWN-" +
								  (boost::format("%05d") % error.code).str();
					break;
			}
		} catch (...) {
			elog(LOG, "tsurugi_fdw: Unexpected exception occurred in %s.",
					__func__);
			return message;
		}
		// build error message.
		message = "Tsurugi Error: " + error.name + " (" + detail_code + ": " +
				  error.detail + ")";
	} else {
		log2(LOG, "tsurugi_fdw: Failed to get Tsurugi Server Error.", ret_code);
	}

	return message;
}

/**
 *  @brief 	Make tsurugi error message.
 *  @param 	(tg_conn) pointer to TGconn.
 *          (message) error message.
 * 			(error) error code.
 * 			(sql) the statement that was attempted to be sent to tsurugidb.
 *  @return	none.
 */
std::string tg_make_error_message(TGconn* tg_conn, std::string_view message,
		ERROR_CODE error, std::string_view sql = {}) {
	std::string detail = get_detail_message(tg_conn, error);
	std::ostringstream msg;
	msg << "Failed to execute remote SQL.\n"
		<< "HINT:  " << message << " error: " << stub::error_name(error).data()
		<< "(" << (int) error << ")\n"
		<< detail.data() << "\n"
		<< "CONTEXT:  SQL query: " << sql;
	elog(DEBUG3, "tsurugi_fdw: %s\n%s", __func__, msg.str().c_str());

	return msg.str();
}

}  // namespace

extern "C" {

/**
 *  tg_global_error_message
 */
const char* tg_global_error_message(void) noexcept { return g_global_error; }

}  // extern "C"

/* -------------------------------------------------------------------------
 * Helper functions.
 * ------------------------------------------------------------------------- 
 */
namespace {

/**
 *  get_shared_memory_name
 */
namespace fs = boost::filesystem;
std::string get_shared_memory_name() noexcept {
	std::string shm_name{ogawayama::common::param::SHARED_MEMORY_NAME};
	boost::property_tree::ptree pt;
	try {
		const fs::path conf_file("tsurugi_fdw.conf");
		boost::system::error_code error;
		if (fs::exists(conf_file, error)) {
			boost::property_tree::read_ini("tsurugi_fdw.conf", pt);
			boost::optional<std::string> value = pt.get_optional<std::string>(
					"Configurations.SHARED_MEMORY_NAME");
			if (value) {
				shm_name = value.get();
			}
		}
	} catch (fs::filesystem_error& e) {
		elog(DEBUG1, "tsurugi_fdw: filesystem exception occurred (what: %s)",
				e.what());
	} catch (...) {
		elog(LOG, "tsurugi_fdw: Unexpected exception occurred in %s.",
				__func__);
	}

	return shm_name;
}

/**
 *  @brief  Trimming a string to remove comments and newline characters
 *  @param  (orig_query) input query string.
 *  @return	(query) trimmed query string.
 */
std::string trim_query_string(const std::string& orig_query) noexcept {
	elog(DEBUG3, "tsurugi_fdw: %s", __func__);
	std::string query;

	try {
		// remove comments.
		std::regex commentPattern(R"((--[^\n]*)|(/\*[\s\S]*?\*/))");
		query = std::regex_replace(orig_query, commentPattern, "");

		// replace a line break character to a space.
		std::replace(query.begin(), query.end(), '\n', ' ');
		elog(DEBUG3, "tsurugi_fdw:\ntrimmed query string:\n%s", query.c_str());
	} catch (std::regex_error& e) {
		elog(DEBUG1, "tsurugi_fdw: Regex exception occuuured. (what: %s)",
				e.what());
	} catch (...) {
		elog(LOG, "tsurugi_fdw: Unexpected exception occurred in %s.",
				__func__);
	}
	return query;
}

/**
 *  make_tsurugi_query
 */
static std::string make_tsurugi_query(std::string_view query_string) noexcept {
	static const std::string PUBLIC_remote_schema = "public\\.";
	static const std::string PUBLIC_DOUBLE_QUOTATION = "\"public\"\\.";

	std::string tsurugi_query(query_string);

	elog(DEBUG3, "tsurugi_fdw: %s", __func__);

	try {
		// erase public schema.
		std::smatch regex_match;
		std::regex regex_public(
				PUBLIC_remote_schema, std::regex_constants::icase);
		while (std::regex_search(tsurugi_query, regex_match, regex_public)) {
			std::string::size_type erase_pos =
					tsurugi_query.find(regex_match.str(0));
			std::size_t erase_size = regex_match.str(0).size();
			tsurugi_query.erase(erase_pos, erase_size);
		}
		std::regex regex_double_quotation(PUBLIC_DOUBLE_QUOTATION);
		while (std::regex_search(
				tsurugi_query, regex_match, regex_double_quotation)) {
			std::string::size_type erase_pos =
					tsurugi_query.find(regex_match.str(0));
			std::size_t erase_size = regex_match.str(0).size();
			tsurugi_query.erase(erase_pos, erase_size);
		}

		// trim terminal semi-column.
		if (tsurugi_query.back() == ';') {
			tsurugi_query.pop_back();
		}

		// convert the binary type literal.
		std::regex pattern(
				R"_(('\\x([0-9a-f]*)'))_", std::regex_constants::icase);
		auto replaced = std::regex_replace(tsurugi_query, pattern, "X'$2'");
		tsurugi_query = replaced;
		elog(DEBUG5,
				"tsurugi_fdw: Converted to Tsurugi query:\nsrc: %s\ndst: %s",
				query_string.data(), replaced.c_str());
	} catch (std::regex_error& e) {
		elog(DEBUG1, "tsurugi_fdw: Regex exception occurred. (what:%s)",
				e.what());
	} catch (...) {
		elog(LOG, "tsurugi_fdw: Unexpected exception occurred in %s.",
				__func__);
	}

	return tsurugi_query;
}

/**
 *  is_prepare_statement
 */
bool is_prepare_statement(const char* query) noexcept {
	auto sql = trim_query_string(query);
	return (boost::algorithm::icontains(sql, "PREPARE ") ||
			boost::algorithm::icontains(sql, "$") ||
			boost::algorithm::icontains(sql, ":param"));
}

/**
 *  @brief  Make prepare statement for tsurugidb.
 *  @param  (query)     SQL query.
 *  @return	(first)     prepare name.
 *          (second)    prepare statement.
 */
std::pair<std::string, std::string> extract_prepare_statement(
		const char* query) noexcept {
	elog(DEBUG3, "tsurugi_fdw: %s", __func__);

	auto orig_query = trim_query_string(query);
	std::string prep_name{};
	std::string prep_stmt{};
	if (!is_prepare_statement(query)) {
		prep_stmt = query;
		return std::pair{prep_name, prep_stmt};
	}

	if (boost::algorithm::icontains(orig_query, "PREPARE ")) {
		// Remove 'PREPARE' clause.
		std::string prev_token{};
		std::vector<std::string> tokens;
		boost::split(tokens, orig_query, boost::is_any_of(" "));
		for (auto& token : tokens) {
			if (!pg_strcasecmp(prev_token.c_str(), "PREPARE"))
				prep_name = token;
			else if (!pg_strcasecmp(prev_token.c_str(), "AS") ||
					 !prep_stmt.empty())
				prep_stmt += token + " ";
			prev_token = token;
		}
		if (!prep_stmt.empty())
			prep_stmt.pop_back();  // remove a last space character.
	} else {
		prep_stmt = orig_query;
	}
	elog(DEBUG3, "tsurugi_fdw: prep_name: %s,\nprepare statement = \n%s",
			prep_name.c_str(), prep_stmt.c_str());

	if (boost::algorithm::icontains(query, "$")) {
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
			elog(LOG,
					"tsurugi_fdw: A logic_error exception occurred. (what: %s)",
					e.what());
			return std::pair{"", ""};
		} catch (const std::exception& e) {
			elog(LOG, "tsurugi_fdw: An exception occurred. (what: %s)",
					e.what());
			return std::pair{"", ""};
		}
	}
	elog(DEBUG3, "tsurugi_fdw: prep_name: %s,\nprepare statement = \n%s",
			prep_name.c_str(), prep_stmt.c_str());
	return std::pair{prep_name, prep_stmt};
}

/**
 *  @brief  Make placeholders of prepare statement.
 *  @param  (param_linfo) parameter list.
 *          (placeholders) placeholders_type object.
 *  @return	(0) success
 *          (othes) failure, param number where the error occurred.
 */
size_t make_placeholders(ParamListInfo param_linfo,
		ogawayama::stub::placeholders_type& placeholders) noexcept {
	elog(DEBUG3, "tsurugi_fdw: %s", __func__);

	placeholders.clear();
	size_t param_num = 0;
	if (param_linfo != nullptr) {
		for (auto i = 0; i < param_linfo->numParams; i++) {
			/* parameter number is 1 origin. */
			std::string param_name = "param" + std::to_string(++param_num);
			auto tg_type =
					tg_convert_type_pg_to_tg(param_linfo->params[i].ptype);
			if (!tg_type) {
				return param_num;
			}
			placeholders.emplace_back(param_name, tg_type.value());
		}
		elog(DEBUG1, "tsurugi_fdw: placeholders: %d", param_linfo->numParams);
	}

	return 0;
}

/**
 *  @brief  Make prepare parameters.
 *  @param  (param_linfo) ParamListInfo structure.
 *          (params) parameters_type object.
 *  @return	(0) success
 *          (others) failure, param number where error occurred.
 */
size_t make_parameters(ParamListInfo param_linfo,
		ogawayama::stub::parameters_type& params) noexcept {
	elog(DEBUG3, "tsurugi_fdw: %s", __func__);

	int param_num = 0;
	params.clear();
	if (param_linfo != nullptr) {
		for (auto i = 0; i < param_linfo->numParams; i++) {
			/* parameter number is 1 origin. */
			param_num = i + 1;
			auto param_name = "param" + std::to_string(param_num);
			ParamExternData param = param_linfo->params[i];
			if (param.isnull) {
				std::monostate mono{};
				params.emplace_back(param_name, mono);
			} else {
				auto tg_value =
						tg_convert_value_pg_to_tg(param.ptype, param.value);
				if (!tg_value) {
					return param_num;
				}
				params.emplace_back(param_name, tg_value.value());
			}
		}
	}

	return 0;
}

/**
 *  @brief  Make placeholders of prepare statement. (for query)
 *  @param  (fdw_exprs) parameter node list.
 * 			(placeholders) placeholders_type object.
 *  @return	(0) success
 *          (othes) failure, param number where the error occurred.
 */
size_t make_placeholders(
		List* fdw_exprs, ogawayama::stub::placeholders_type& placeholders) {
	elog(DEBUG3, "tsurugi_fdw : %s", __func__);

	size_t param_num = 0;
	ListCell* lc;
	foreach (lc, fdw_exprs) {
		Node* param_expr = (Node*) lfirst(lc);

		/* parameter name is 1 origin. */
		std::string param_name = "param" + std::to_string(++param_num);
		auto tg_type = tg_convert_type_pg_to_tg(exprType(param_expr));
		if (!tg_type) {
			return param_num;
		}
		placeholders.emplace_back(param_name, tg_type.value());
	}
	elog(DEBUG1, "tsurugi_fdw : placeholders: %d", (int) param_num);

	return 0;
}

/**
 *  @brief  Bind parameters of prepared statement. (for query)
 *  @param  (econtext) Pointer toExprContext structure.
 *          (param_exprs) ExprState List.
 *          (params) paramters_type object.
 *  @return	(0) success.
 *          (others) failure. parameter number which error occurred.
 */
size_t make_parameters(ExprContext* econtext, List* param_exprs,
		stub::parameters_type& params) {
	elog(DEBUG3, "tsurugi_fdw: %s", __func__);

	size_t param_num = 0;
	ListCell* lc;
	foreach (lc, param_exprs) {
		ExprState* expr_state = (ExprState*) lfirst(lc);
		bool isNull;

		/* parameter number is 1 origin. */
		auto param_name = "param" + std::to_string(++param_num);

		/* Evaluate the parameter expression */
		Datum expr_value = ExecEvalExpr(expr_state, econtext, &isNull);

		/*
		 * Get string representation of each parameter value by invoking
		 * type-specific output function, unless the value is null.
		 */
		if (isNull) {
			std::monostate mono{};
			params.emplace_back(param_name, mono);
		} else {
			Oid typoid = exprType((Node*) expr_state->expr);
			auto tg_value = tg_convert_value_pg_to_tg(typoid, expr_value);
			if (!tg_value) {
				return param_num;
			}
			params.emplace_back(param_name, tg_value.value());
		}
	}
	elog(DEBUG1, "tsurugi_fdw: parameters count: %d", (int) param_num);

	return 0;
}

/**
 *  @brief  Append a named parameter to params, converting a PostgreSQL value to TG format.
 *  @param  (params) Destination parameters_type object.
 *          (name) Parameter name.
 *          (atttypid) PostgreSQL type OID of the value.
 *          (pg_value) PostgreSQL Datum value.
 *          (isnull) True if the value is NULL.
 *  @return (true) success.
 *          (false) failure. conversion error occurred.
 */
inline bool append_param(ogawayama::stub::parameters_type& params,
                         const std::string& name,
                         Oid atttypid,
                         Datum pg_value,
                         bool isnull) noexcept
{
	/* If NULL, append a null marker (std::monostate) and return success. */
    if (isnull) {
        params.emplace_back(name, std::monostate{});
        return true;
    }

	/* Convert the PostgreSQL Datum to a Tsurugi value. */
    auto tg_value = tg_convert_value_pg_to_tg(atttypid, pg_value);
    if (!tg_value) {
        return false;
    }

	/* Append the converted value and return success. */
    params.emplace_back(name, tg_value.value());
    return true;
}

inline bool append_param(ogawayama::stub::placeholders_type& placeholders,
                         const std::string& name,
                         Oid atttypid,
                         Datum /*pg_value*/,
                         bool /*isnull*/) noexcept
{
	/* Convert the PostgreSQL Datum to a Tsurugi value. */
    auto tg_type = tg_convert_type_pg_to_tg(atttypid);
    if (!tg_type) {
		return false;
	}

	/* Append the converted value and return success. */
    placeholders.emplace_back(name, tg_type.value());
    return true;
}

/**
 *  @brief  Bind target attributes as parameters for a prepared statement.
 *  @param  (tupdesc) Tuple descriptor which provides attribute metadata.
 *          (target_attrs) List of target attribute numbers (attnum).
 *          (slots) TupleTableSlot array used to fetch attribute values.
 *          (param_num) Parameter counter (incremented while binding).
 *          (params) Destination parameters_type object.
 *  @return (0) success.
 *          (others) failure. parameter number which error occurred.
 */
template <class ParamOut>
size_t bind_target_attrs(TupleDesc tupdesc,
                         List* target_attrs,
                         TupleTableSlot** slots,
                         int& param_num,
                         ParamOut& params) noexcept
{
    ListCell* lc = nullptr;
    foreach (lc, target_attrs) {
        const int attnum = lfirst_int(lc);
        Form_pg_attribute attr = TupleDescAttr(tupdesc, attnum - 1);

        /* Ignore generated columns; they are set to DEFAULT */
        if (attr->attgenerated) {
            continue;
        }

		/* Generate a unique parameter name like "paramN". */
		const std::string param_name = "param" + std::to_string(++param_num);

		/* Fetch the attribute value from the slot and detect NULL. */
        bool isnull = false;
        Datum pg_value = slot_getattr(slots[0], attnum, &isnull);

		/* Append the parameter (with conversion); return the failing param number on error. */
        if (!append_param(params, param_name, attr->atttypid, pg_value, isnull)) {
            return param_num;
        }
    }
    return 0;
}

/**
 *  @brief  Bind key attributes (marked by foreign column option "key") from junk attributes as parameters.
 *  @param  (rel) Target relation.
 *          (slots) TupleTableSlot array which provides tuple descriptor (column metadata).
 *          (planSlots) TupleTableSlot array used to fetch junk attribute values from the plan.
 *          (junk_idx) Mapping from slot attribute index to junk attribute number.
 *          (param_num) Parameter counter (incremented while binding).
 *          (params) Destination parameters_type object.
 *  @return (0) success.
 *          (others) failure. parameter number which error occurred.
 */
template <class ParamOut>
size_t bind_key_attrs_from_junk(Relation rel,
                                TupleTableSlot** slots,
                                TupleTableSlot** planSlots,
                                AttrNumber* junk_idx,
                                int& param_num,
                                ParamOut& params) noexcept
{
    const Oid relid = RelationGetRelid(rel);
    TupleDesc slotdesc = slots[0]->tts_tupleDescriptor;

	/* Scan all attributes in the slot descriptor. */
    for (int i = 0; i < slotdesc->natts; i++) {
        Form_pg_attribute attr = TupleDescAttr(slotdesc, i);

		/* Ignore generated columns; they are set to DEFAULT */
        if (attr->attgenerated) {
            continue;
        }

		/* Get column number and its foreign column options. */
        const AttrNumber attnum = attr->attnum;
        List* options = GetForeignColumnOptions(relid, attnum);

		/* Find option entries that mark this column as a key. */
        ListCell* oc = nullptr;
        foreach (oc, options) {
			/* Check whether the option is "key=true". */
            DefElem* def = (DefElem*) lfirst(oc);
            if (!(strcmp(def->defname, "key") == 0 && defGetBoolean(def))) {
                continue;
            }

			/* Resolve the corresponding junk attribute number for this column. */
            const AttrNumber junk = junk_idx[i];
            if (junk == InvalidAttrNumber) {
                continue;
            }

            /* Generate a unique parameter name like "paramN". */
            const std::string param_name = "param" + std::to_string(++param_num);

			/* Fetch the key value from the plan's junk attribute. */
            bool isnull = false;
            Datum pg_value = ExecGetJunkAttribute(planSlots[0], junk, &isnull);

			/* Append the parameter (with conversion); return the failing param number on error. */
            if (!append_param(params, param_name, attr->atttypid, pg_value, isnull)) {
                return param_num;
            }
        }
    }
    return 0;
}

size_t make_placeholders(Relation rel,
                          List* target_attrs,
                          TupleTableSlot** slots,
                          TupleTableSlot** planSlots,
                          AttrNumber* junk_idx,
                          ogawayama::stub::placeholders_type& placeholders) noexcept
{
    TupleDesc tupdesc = RelationGetDescr(rel);
    int param_num = 0;

	elog(DEBUG3, "tsurugi_fdw: %s", __func__);

    if (!tupdesc || !slots || !slots[0]) {
		return 0;
	} 
    placeholders.clear();

	/* Bind placeholders for target attributes. */
    size_t failed_param = bind_target_attrs(tupdesc, target_attrs, slots, param_num, placeholders);
    if (failed_param != 0){
		return failed_param;
	}

	/* Bind placeholders for key attributes from junk, if available. */
    if (planSlots && planSlots[0] && junk_idx) {
        failed_param = bind_key_attrs_from_junk(rel, slots, planSlots, junk_idx, param_num, placeholders);
        if (failed_param != 0){
			return failed_param;
        }
    }
    return 0;
}

/*
 *  make_parameters_type
 *      Bind parameters of prepared statement.
 */
size_t make_parameters(Relation rel,
                       List* target_attrs,
                       TupleTableSlot** slots,
                       TupleTableSlot** planSlots,
                       AttrNumber* junk_idx,
                       ogawayama::stub::parameters_type& params) noexcept
{
    TupleDesc tupdesc = RelationGetDescr(rel);
	int param_num = 0;

    elog(DEBUG3, "tsurugi_fdw: %s", __func__);

    if (tupdesc == nullptr || slots == nullptr || slots[0] == nullptr) {
        return 0;
    }

	/* 1) Bind values for target attributes (e.g., INSERT/SET clause). */
    size_t failed_param = bind_target_attrs(tupdesc, target_attrs, slots, param_num, params);
    if (failed_param != 0) {
        return failed_param;
    }

	/* 2) Bind key attributes (for WHERE clause) from plan's junk attributes when available. */
	if (planSlots && planSlots[0] && junk_idx) {
        failed_param = bind_key_attrs_from_junk(rel, slots, planSlots, junk_idx, param_num, params);
        if (failed_param != 0) {
            return failed_param;
        }
    }

    elog(DEBUG1, "tsurugi_fdw: parameter count: %d", param_num);
    return 0;
}

/**
 *  @brief Obtain tuple data from Ogawayama, and convert data type to PG data
 * type.
 */
bool make_tuple_from_result_row(ResultSetPtr result_set,
		TupleDesc tupleDescriptor, List* retrieved_attrs, Datum* row,
		bool* is_null) noexcept {
	elog(DEBUG5, "tsurugi_fdw: %s", __func__);
	memset(row, 0, sizeof(*row) * tupleDescriptor->natts);
	memset(is_null, true, sizeof(*is_null) * tupleDescriptor->natts);

	ListCell* lc = NULL;
	foreach (lc, retrieved_attrs) {
		const int attnum = lfirst_int(lc) - 1;
		Form_pg_attribute pg_attr = TupleDescAttr(tupleDescriptor, attnum);
		elog(DEBUG5, "tsurugi_fdw: %s : attnum: %d", __func__, attnum + 1);
		auto pg_value =
				tg_convert_value_tg_to_pg(result_set, pg_attr->atttypid);
		if (!pg_value) {
			result_set = nullptr;
			return false;
		}
		is_null[attnum] = pg_value.value().first;
		row[attnum] = pg_value.value().second;
	}
	return true;
}
}  // namespace

/* -------------------------------------------------------------------------
 * Tsurugi APIs.
 * ------------------------------------------------------------------------- 
 */
extern "C" {

/**
 *  get_database_name
 */
const char* tg_get_database_name() noexcept {
	static std::string shm{get_shared_memory_name()};
	return shm.c_str();
}

/* -------------------------------------------------------------------------
 * Connection/Transaction functions.
 * ------------------------------------------------------------------------- 
 */
/**
 *  tg_conn_connect
 */
TGconn* tg_conn_open(
		const char* endpoint, const char* user, const char* password) noexcept {
	if (!endpoint || endpoint[0] == '\0') {
		endpoint = tg_get_database_name();
	}
	if (!user) user = "";
	if (!password) password = "";
	
	elog(DEBUG1, "tsurugi_fdw: %s (endpoint: %s, user: %s)", __func__, endpoint,
			user);
	
	TGconn* tg_conn = new (std::nothrow) TGconn();
	if (!tg_conn) {
		set_error("out of memory (new TGconn)");
		return nullptr;
	}
	tg_conn->subxact_seen = false;

	try {
		if (!tg_conn->stub) {
			elog(DEBUG1,
					"tsurugi_fdw: Attempt to call make_stub(). (endpoint: %s)",
					endpoint);
			auto error = make_stub(tg_conn->stub, endpoint);
			log2(DEBUG1, "tsurugi_fdw: make_stub() is done.", error);
			if (error != ERROR_CODE::OK) {
				auto msg = tg_make_error_message(tg_conn,
						"Failed to attach the shared memory of Tsurugi "
						"database.",
						error);
				set_error(msg, TG_STATUS_TSURUGI_ERROR);
				delete tg_conn;
				return nullptr;
			}
		}

		if (!tg_conn->impl) {
			ogawayama::stub::Auth auth{user, password};
			elog(DEBUG1,
					"tsurugi_fdw: Attempt to call get_connection(). (pid: %d)",
					MyProcPid);
			auto error = tg_conn->stub->get_connection(
					MyProcPid, tg_conn->impl, auth);
			log2(DEBUG1, "tsurugi_fdw: get_connection() is done.", error);
			if (error != ERROR_CODE::OK) {
				auto msg = tg_make_error_message(tg_conn,
						"Failed to connect to Tsurugi database.", error,
						tg_conn->endpoint);
				set_error(msg, TG_STATUS_TSURUGI_ERROR);
				delete tg_conn;
				return nullptr;
			}
		}
		set_ok(tg_conn->error);
		return tg_conn;
	} catch (const std::exception& e) {
		set_exception(e);
		delete tg_conn;
		return nullptr;
	} catch (...) {
		set_exception();
		delete tg_conn;
		return nullptr;
	}
	tg_conn->endpoint = endpoint;
}

/**
 *  tg_conn_close
 */
TG_STATUS tg_conn_close(TGconn* tg_conn) noexcept {
	elog(DEBUG1, "tsurugi_fdw: %s", __func__);
	if (!tg_conn) {
		return set_error(
				tg_conn->error, "tg_conn_close: null", TG_STATUS_INVALID_ARG);
	};
	try {
		tg_conn->tx = nullptr;
		tg_conn->impl = nullptr;
	} catch (...) {
		return set_exception(tg_conn->error);
	}
	return set_ok(tg_conn->error);
}

/**
 *  tg_conn_destory
 */
void tg_conn_destroy(TGconn* tg_conn) noexcept {
	elog(DEBUG1, "tsurugi_fdw: %s", __func__);
	if (!tg_conn) return;
	try {
		tg_conn->tx = nullptr;
		tg_conn->impl = nullptr;
		tg_conn->stub = nullptr;
		delete tg_conn;
	} catch (...) {
	}
}

/**
 *  tg_conn_set_subxact_seen
 */
void tg_conn_set_subxact_seen(TGconn* tg_conn, int seen) noexcept {
	if (!tg_conn) {
		set_error("tg_conn_set_subxact_seen: null");
		return;
	}
	tg_conn->subxact_seen = (seen != 0);
}

/**
 *  tg_conn_get_subxact_seen
 */
bool tg_conn_get_subxact_seen(const TGconn* tg_conn) noexcept {
	if (!tg_conn) {
		set_error("tg_conn_get_subxact_seen: null");
		return 0;
	}
	return tg_conn->subxact_seen;
}

/**
 *  tg_conn_tx_active
 */
bool tg_conn_tx_active(const TGconn* c) noexcept {
	return (c->tx != nullptr && c->tx != nullptr);
}

/**
 *  tg_tx_begin
 */
TG_STATUS tg_conn_tx_begin(TGconn* tg_conn) noexcept {
	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	if (!tg_conn) {
		return set_error(tg_conn->error,
				"Invalid arguments in tg_conn_tx_begin.",
				TG_STATUS_INVALID_ARG);
	}
	if (!tg_conn->impl) {
		return set_error(tg_conn->error, "Not connected to Tsurugi.",
				TG_STATUS_INVALID_ARG);
	}
	if (tg_conn->subxact_seen) {
		return set_error(tg_conn->error, "Sub transaction is not supported.",
				TG_STATUS_ERROR);
	}
	if (tg_conn->tx) return TG_STATUS_OK;  // tx is already active.

	try {
		boost::property_tree::ptree option;
		GetTransactionOption(option);
		elog(DEBUG1, "tsurugi_fdw: Attempt to call begin().");
		auto error = tg_conn->impl->begin(option, tg_conn->tx);
		log2(DEBUG1, "tsurugi_fdw: begin() is done.", error);
		if (error != ERROR_CODE::OK) {
			auto msg = tg_make_error_message(tg_conn,
					"Failed to start the transaction on Tsurugi.", error);
			return set_error(tg_conn->error, msg);
		}
	} catch (const std::exception& e) {
		return set_exception(tg_conn->error, e);
	}
	set_ok(tg_conn->error);
	return TG_STATUS_OK;
}

/**
 *  tg_conn_tx_commit
 */
TG_STATUS tg_conn_tx_commit(TGconn* tg_conn) noexcept {
	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	if (!tg_conn) {
		return set_error(tg_conn->error,
				"Invalid arguments in tg_conn_tx_begin.",
				TG_STATUS_INVALID_ARG);
	}
	if (!tg_conn_tx_active(tg_conn)) {
		return set_error(tg_conn->error, "Remote transaction is not active.",
				TG_STATUS_INVALID_ARG);
	}
	if (tg_conn->subxact_seen) {
		return set_error(tg_conn->error, "Sub transaction is not supported.",
				TG_STATUS_ERROR);
	}
	
	try {
		elog(DEBUG1, "tsurugi_fdw: Attempt to call commit().");
		auto error = tg_conn->tx->commit();
		log2(DEBUG1, "tsurugi_fdw: commit() is done.", error);
		if (error != ERROR_CODE::OK) {
			auto msg = tg_make_error_message(
					tg_conn, "Failed to commit the transaction.", error);
			return set_error(tg_conn->error, msg);
		}
	} catch (const std::exception& error) {
		return set_exception(tg_conn->error, error);
	}
	tg_conn->tx = nullptr;
	return set_ok(tg_conn->error);
}

/**
 *  tg_conn_tx_rollback
 */
TG_STATUS tg_conn_tx_rollback(TGconn* tg_conn) noexcept {
	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	if (!tg_conn) {
		set_error("tg_tx_rollback: null conn");
		return TG_STATUS_INVALID_ARG;
	}
	if (!tg_conn_tx_active(tg_conn)) {
		return set_error(tg_conn->error, "This transaction is not active.",
				TG_STATUS_INVALID_ARG);
	}
	try {
		auto error = tg_conn->tx->rollback();
		if (error != ERROR_CODE::OK) {
			auto msg = tg_make_error_message(
					tg_conn, "Failed to rollback the transaction.", error);
			return set_error(tg_conn->error, msg);
		}
	} catch (const std::exception& error) {
		return set_exception(tg_conn->error, error);
	}
	tg_conn->tx = nullptr;
	return set_ok(tg_conn->error);
}

/**
 *  tg_conn_error_message()
 */
const char* tg_conn_error_message(const TGconn* tg_conn) noexcept {
	return tg_conn ? tg_conn->error.msg : g_global_error;
}

/* -------------------------------------------------------------------------
 * Statement functions.
 * ------------------------------------------------------------------------- 
 */
/**
 *  tg_stmt_prepare
 */
TGstmt* tg_stmt_prepare(TGconn* tg_conn, const char* sql) noexcept {
	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	if (!tg_conn || !tg_conn->impl) {
		set_error("tsurugi_fdw: tg_stmt_prepare: null conn");
		return nullptr;
	}
	if (!sql || sql[0] == '\0') {
		set_error("tsurugi_fdw: sql is empty.");
		return nullptr;
	}
	if (!tg_conn_tx_active(tg_conn)) {
		set_error(tg_conn->error, "Remote transaction is not active.",
				TG_STATUS_NOT_ACTIVE);
		return nullptr;
	}
	if (tg_conn->subxact_seen) {
		set_error(tg_conn->error, "Sub transaction is not supported.",
				TG_STATUS_ERROR);
		return nullptr;
	}	

	//  Create TGstmt handle.
	TGstmt* tg_stmt = new (std::nothrow) TGstmt;
	if (!tg_stmt) {
		set_error("out of memory (TGstmt)");
		return nullptr;
	}

	if (is_prepare_statement(sql)) {
		auto prep = extract_prepare_statement(sql);
		if (prep.second.empty()) {
			delete tg_stmt;
			set_error("tsurugi_fdw: Invalid statement.");
			return nullptr;
		}
		tg_stmt->name = prep.first;
		tg_stmt->sql = make_tsurugi_query(prep.second);
	} else {
		tg_stmt->sql = make_tsurugi_query(sql);
	}
	tg_stmt->conn = tg_conn;
	tg_stmt->original_sql = sql;
	set_ok(tg_stmt->error);

	return tg_stmt;
}

/**
 *  tg_stmt_destroy
 */
void tg_stmt_destroy(TGstmt* tg_stmt) noexcept {
	elog(DEBUG1, "tsurugi_fdw: %s", __func__);
	if (!tg_stmt) return;
	try {
		tg_stmt->impl = nullptr;
		delete tg_stmt;
	} catch (...) {
	}
}

/**
 *  tg_stmt_set_placeholders
 */
TG_STATUS tg_stmt_bind_parameters(
		TGstmt* tg_stmt, ParamListInfo param_linfo) noexcept {
	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	if (!tg_stmt) {
		set_error("tg_stmt_bind_parameters: null stmt");
		return TG_STATUS_INVALID_ARG;
	}
	auto param_num = make_placeholders(param_linfo, tg_stmt->placeholders);
	if (param_num > 0) {
		std::ostringstream msg;
		msg << "Unsupported parameter found. (param number: " << param_num
			<< ")";
		return set_error(tg_stmt->error, msg.str());
	}
	param_num = make_parameters(param_linfo, tg_stmt->paramerters);
	if (param_num > 0) {
		std::ostringstream msg;
		msg << "Unsupported parameter found. (param number: " << param_num
			<< ")";
		return set_error(tg_stmt->error, msg.str());
	}
	set_ok(tg_stmt->error);
	return TG_STATUS_OK;
}

/**
 *  tg_stmt_bind_params_for_query
 */
TG_STATUS tg_stmt_bind_params_for_query(TGstmt* tg_stmt, List* fdw_exprs,
		ExprContext* econtext, List* param_exprs) noexcept {
	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	if (!tg_stmt) {
		set_error("tg_stmt_bind_parameters: null stmt");
		return TG_STATUS_INVALID_ARG;
	}

	auto param_num = make_placeholders(fdw_exprs, tg_stmt->placeholders);
	if (param_num > 0) {
		std::ostringstream msg;
		msg << "Unsupported placeholder found. (number: " << param_num
			<< ")\nsql query: " << tg_stmt->sql;
		return set_error(tg_stmt->error, msg.str());
	}
	param_num = make_parameters(econtext, param_exprs, tg_stmt->paramerters);
	if (param_num > 0) {
		std::ostringstream msg;
		msg << "Unsupported parameter found. (param number: " << param_num
			<< ")\nsql query: " << tg_stmt->sql;
		return set_error(tg_stmt->error, msg.str());
	}
	set_ok(tg_stmt->error);
	return TG_STATUS_OK;
}

TG_STATUS tg_stmt_bind_parameters_for_modify(TGstmt* tg_stmt, Relation rel,
		List* target_attrs, TupleTableSlot** slots,
		TupleTableSlot** planSlots,AttrNumber* junk_idx) noexcept {
	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	if (!tg_stmt) {
		set_error("tg_stmt_bind_parameters: null stmt");
		return TG_STATUS_INVALID_ARG;
	}

	auto param_num = make_placeholders(rel, target_attrs, slots, planSlots, junk_idx, tg_stmt->placeholders);
	if (param_num > 0) {
		std::ostringstream msg;
		msg << "Unsupported parameter found. (param number: " << param_num
			<< ")\nsql query: " << tg_stmt->sql;
		return set_error(tg_stmt->error, msg.str());
	}
	param_num = make_parameters(rel, target_attrs, slots, planSlots, junk_idx,
                                tg_stmt->paramerters);
	if (param_num > 0) {
		std::ostringstream msg;
		msg << "Unsupported parameter found. (param number: " << param_num
			<< ")\nsql query: " << tg_stmt->sql;
		return set_error(tg_stmt->error, msg.str());
	}
	set_ok(tg_stmt->error);
	return TG_STATUS_OK;
}

/**
 *  tg_stmt_execute_query
 */
TGresult* tg_stmt_execute_query(TGstmt* tg_stmt) noexcept {
	elog(DEBUG1, "tsurugi_fdw: %s\nsql:\n%s", __func__, tg_stmt->sql.c_str());

	if (!tg_stmt) {
		set_error(tg_stmt->error, "tg_stmt_execute_query: null stmt");
		return nullptr;
	}
	TGconn* tg_conn = tg_stmt->conn;
	if (!tg_conn) {
		set_error(tg_stmt->error, "tg_stmt_execute_query: null conn");
		return nullptr;
	}
	if (!tg_conn->tx) {
		set_error(tg_stmt->error, "tg_stmt_execute_query: null tx");
		return nullptr;
	}
	if (tg_conn->subxact_seen) {
		set_error(tg_conn->error, "Sub transaction is not supported.",
				TG_STATUS_ERROR);
		return nullptr;
	}

	TGresult* tg_result = new (std::nothrow) TGresult;
	if (!tg_result) {
		set_error(tg_stmt->error, "out of memory (TGresult)");
		return nullptr;
	}
	tg_result->stmt = tg_stmt;

	elog(DEBUG1, "tsurugi_fdw: \nquery:\n%s", tg_stmt->sql.c_str());
	try {
		//  Prepare the query.
		elog(DEBUG1, "tsurugi_fdw: Attempt to call prepare()");
		auto error = tg_conn->impl->prepare(
				tg_stmt->sql, tg_stmt->placeholders, tg_stmt->impl);
		log2(DEBUG1, "tsurugi_fdw: prepare() is done.", error);
		if (error != ERROR_CODE::OK) {
			auto msg = tg_make_error_message(tg_conn,
					"Failed to execute the query on Tsurugi.", error,
					tg_stmt->sql);
			set_error(tg_stmt->error, msg, TG_STATUS_TSURUGI_ERROR);
			delete tg_result;
			return nullptr;
		}
		//  Execute the prepared query.
		elog(DEBUG1, "tsurugi_fdw: Attempt to call execute_query()");
		error = tg_conn->tx->execute_query(
				tg_stmt->impl, tg_stmt->paramerters, tg_result->impl);
		log2(DEBUG1, "tsurugi_fdw: execute_query() is done.", error);
		if (error != ERROR_CODE::OK) {
			auto msg = tg_make_error_message(tg_conn,
					"Failed to execute the query on Tsurugi.", error,
					tg_stmt->sql);
			set_error(tg_stmt->error, msg, TG_STATUS_TSURUGI_ERROR);
			delete tg_result;
			return nullptr;
		}
	} catch (std::exception& e) {
		set_exception(tg_stmt->error, e);
		delete tg_result;
		return nullptr;
	} catch (...) {
		set_exception(tg_stmt->error);
		delete tg_result;
		return nullptr;
	}
	set_ok(tg_stmt->error);
	return tg_result;
}

/**
 *  tg_stmt_execute_statement
 */
TG_STATUS tg_stmt_execute_statement(
		TGstmt* tg_stmt, size_t* num_rows) noexcept {
	elog(DEBUG1, "tsurugi_fdw: %s\nsql:\n%s", __func__, tg_stmt->sql.c_str());

	if (!tg_stmt) {
		return set_error("tg_stmt_execute_statement: null stmt", TG_STATUS_INVALID_ARG);
	}
	if (num_rows) *num_rows = 0;
	size_t rows = 0;
	TGconn* tg_conn = tg_stmt->conn;
	if (tg_conn->subxact_seen) {
		return set_error(tg_conn->error, "Sub transaction is not supported.",
				TG_STATUS_ERROR);
	}

	try {
		//  Prepare the query.
		elog(DEBUG1, "tsurugi_fdw: Attempt to call prepare()");
		auto error = tg_conn->impl->prepare(
				tg_stmt->sql, tg_stmt->placeholders, tg_stmt->impl);
		log2(DEBUG1, "tsurugi_fdw: prepare() is done.", error);
		if (error != ERROR_CODE::OK) {
			auto msg = tg_make_error_message(tg_conn,
					"Failed to execute the statement on Tsurugi.", error,
					tg_stmt->sql);
			return set_error(tg_stmt->error, msg, TG_STATUS_TSURUGI_ERROR);
		}
		//  Execute the prepared statement.
		elog(DEBUG1, "tsurugi_fdw: Attempt to call execute_statement()");
		error = tg_conn->tx->execute_statement(
				tg_stmt->impl, tg_stmt->paramerters, rows);
		log2(DEBUG1, "tsurugi_fdw: Connection::execute_statement() is done.", error);
		if (error != ERROR_CODE::OK) {
			auto msg = tg_make_error_message(tg_conn,
					"Failed to execute the statement on Tsurugi.", error,
					tg_stmt->sql);
			return set_error(tg_stmt->error, msg, TG_STATUS_TSURUGI_ERROR);
		}
	} catch (std::exception& e) {
		return set_exception(tg_stmt->error, e);
	} catch (...) {
		return set_exception(tg_stmt->error);
	}
	if (num_rows) *num_rows = rows;
	set_ok(tg_stmt->error);
	return TG_STATUS_OK;
}

/**
 *  tg_stmt_error_message
 */
const char* tg_stmt_error_message(const TGstmt* tg_stmt) noexcept {
	return tg_stmt ? tg_stmt->error.msg : g_global_error;
}

/* -------------------------------------------------------------------------
 * ResultSet Functions.
 * ------------------------------------------------------------------------- 
 */

/**
 *  tg_result_destroy
 */
void tg_result_destroy(TGresult* tg_result) noexcept {
	elog(DEBUG1, "tsurugi_fdw: %s", __func__);
	if (!tg_result) return;
	try {
		tg_result->impl = nullptr;
		delete tg_result;
	} catch (...) {
	}
}

/**
 *  tg_result_next
 */
TG_STATUS tg_result_next(TGresult* tg_result) noexcept {
	elog(DEBUG5, "tsurugi_fdw: %s", __func__);

	if (!tg_result) {
		set_error("tg_stmt_execute_statement: null stmt");
		return TG_STATUS_INVALID_ARG;
	}
	TGconn* tg_conn = tg_result->stmt->conn;
	if (tg_conn->subxact_seen) {
		return set_error(tg_conn->error, "Sub transaction is not supported.",
				TG_STATUS_ERROR);
	}
	
	try {
		auto error = tg_result->impl->next();
		switch (error) {
			case ERROR_CODE::OK:
				break;
			case ERROR_CODE::END_OF_ROW:
				return TG_STATUS_END_OF_ROW;
			default:
				return set_error(tg_result->error, "ResultSet::next() failed.",
						TG_STATUS_TSURUGI_ERROR);
		}
	} catch (std::exception& e) {
		return set_exception(tg_result->error, e);
	}
	return set_ok(tg_result->error);
}

/**
 *  tg_result_get_tuple
 */
TG_STATUS tg_result_get_tuple(TGresult* tg_result, List* retrieved_attrs,
		TupleTableSlot* tupleSlot) noexcept {
	assert(tg_result && tupleSlot);
	elog(DEBUG5, "tsurugi_fdw: %s", __func__);

	make_tuple_from_result_row(tg_result->impl, tupleSlot->tts_tupleDescriptor,
			retrieved_attrs, tupleSlot->tts_values, tupleSlot->tts_isnull);
	ExecStoreVirtualTuple(tupleSlot);
	set_ok(tg_result->error);
	return TG_STATUS_OK;
}

/**
 *  tg_result_error_message
 */
const char* tg_result_error_message(const TGresult* tg_result) noexcept {
	return tg_result ? tg_result->error.msg : g_global_error;
}

/* -------------------------------------------------------------------------
 * UDF functions
 * ------------------------------------------------------------------------- 
 */
/**
 *  @brief Wrapper function of Connection::get_list_tables.
 *  @note Use tg_global_error_message() to retrieve the error message.
 */
TG_STATUS tg_get_list_tables(TGconn* tg_conn, TableListPtr& tables) noexcept {
	elog(DEBUG3, "tsurugi_fdw: %s", __func__);
	try {
		elog(DEBUG1,
				"tsurugi_fdw: Attempt to call Connection::get_list_tables().");
		/* Get a list of table names from Tsurugi. */
		auto error = tg_conn->impl->get_list_tables(tables);
		log2(DEBUG1, "tsurugi_fdw: Connection::get_list_tables() is done.", error);
		if (error != ERROR_CODE::OK) {
			auto msg = tg_make_error_message(
					tg_conn, "Failed to execute get_list_table().", error);
			return set_error(msg, TG_STATUS_TSURUGI_ERROR);
		}
	} catch (std::exception& e) {
		return set_exception(e);
	} catch (...) {
		return set_exception();
	}
	return TG_STATUS_OK;
}

/**
 *  @brief Wrapper function of Connection::get_table_metadata().
 *  @note Use tg_global_error_message() to retrieve the error message.
 */
TG_STATUS tg_get_table_metadata(TGconn* tg_conn, const std::string& table_name,
		TableMetadataPtr& table_metadata) noexcept {
	elog(DEBUG3, "tsurugi_fdw: %s", __func__);
	try {
		elog(DEBUG1, "tsurugi_fdw: Attempt to call get_table_metadata().");
		auto error =
				tg_conn->impl->get_table_metadata(table_name, table_metadata);
		log2(DEBUG1, "tsurugi_fdw: get_table_metadata() is done.", error);
		if (error != ERROR_CODE::OK) {
			auto msg = tg_make_error_message(tg_conn,
					"Failed to retrieve table metadata from Tsurugi.", error);
			return set_error(msg, TG_STATUS_TSURUGI_ERROR);
		}
	} catch (std::exception& e) {
		return set_exception(e);
	} catch (...) {
		return set_exception();
	}
	return TG_STATUS_OK;
}

/**
 *  @brief Execute import foreign schema.
 *  @note Use tg_global_error_message() to retrieve the error message.
 */
TG_STATUS tg_exec_import_foreign_schema(TGconn* tg_conn,
		ImportForeignSchemaStmt* stmt, Oid serverOid,
		List** commands) noexcept {
	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	/* Get information about foreign server and user mapping. */
	ForeignServer* server = GetForeignServer(serverOid);

	elog(DEBUG2, "ForeignServer::fdwid: %u", server->fdwid);
	elog(DEBUG2, "ForeignServer::serverid: %u", server->serverid);
	elog(DEBUG2, R"(ForeignServer::servername: "%s")", server->servername);

	TableListPtr table_list;
	auto tg_status = tg_get_list_tables(tg_conn, table_list);
	if (tg_status != TG_STATUS_OK) {
		return tg_status;
	}
	auto tg_table_names = table_list->get_table_names();

#ifdef ENABLE_IMPORT_TABLE_LIMITS
	/* The basic behavior regarding the restriction of tables to be imported is
	 * handled by PostgreSQL functions. FDW does not need to handle this and
	 * should be disabled.
	 */
	if ((stmt->list_type == FDW_IMPORT_SCHEMA_LIMIT_TO) ||
			(stmt->list_type == FDW_IMPORT_SCHEMA_EXCEPT)) {
		std::unordered_set<std::string> _table_list;
		ListCell* lc;
		foreach (lc, stmt->table_list) {
			_table_list.insert(((RangeVar*) lfirst(lc))->relname);
		}

		for (auto ite = tg_table_names.begin(); ite != tg_table_names.end();) {
			bool is_exclude_table = false;

			if (stmt->list_type == FDW_IMPORT_SCHEMA_LIMIT_TO) {
				/* include only listed tables in import */
				is_exclude_table =
						(_table_list.find(*ite) == _table_list.end());
			} else if (stmt->list_type == FDW_IMPORT_SCHEMA_EXCEPT) {
				/* exclude listed tables from import */
				is_exclude_table =
						(_table_list.find(*ite) != _table_list.end());
			}

			if (is_exclude_table) {
				elog(DEBUG2, R"(exclude table "%s" from import.)",
						(*ite).c_str());
				ite = tg_table_names.erase(ite);
			} else {
				++ite;
			}
		}
	}
#endif	// ENABLE_IMPORT_TABLE_LIMITS

	// List* result_commands = NIL;
	/* CREATE FOREIGN TABLE statments */
	for (const auto& table_name : tg_table_names) {
		TableMetadataPtr tg_table_metadata;

		/* Get table metadata from Tsurugi. */
		auto tg_status =
				tg_get_table_metadata(tg_conn, table_name, tg_table_metadata);
		if (tg_status != TG_STATUS_OK) {
			return tg_status;
		}

		/* Get table metadata from Tsurugi. */
		const auto& tg_columns = tg_table_metadata->columns();

		elog(DEBUG2, R"(table: "%.64s")", table_name.c_str());

		std::ostringstream col_def; /* columns definition */
		/* Create PostgreSQL column definitions based on Tsurugi column
		 * definitions. */
		for (const auto& column : tg_columns) {
			/* Convert from Tsurugi datatype to PostgreSQL datatype. */
			auto pg_type = tg_convert_type_tg_to_pg(column.atom_type());
			if (!pg_type) {
				auto msg =
						boost::format(
								R"(unsupported tsurugi data type "%d". (table:"%s" column:"%s"))") %
						static_cast<int>(column.atom_type()) % table_name %
						column.name();
				return set_error(msg.str());
			}
			std::string type_name(pg_type.value());

			elog(DEBUG2,
					R"(column: {"name":"%.64s", "tsurugi_atom_type":%d, "postgres_type":"%s"})",
					column.name().c_str(), static_cast<int>(column.atom_type()),
					type_name.c_str());

			/* Create a column definition. */
			if (col_def.tellp() != 0) {
				col_def << ",";
			}
			col_def << "\"" << column.name() << "\" " << type_name;
		}

		/* Create a CREATE FOREIGN TABLE statement. */
		auto table_def =
				(boost::format(R"(CREATE FOREIGN TABLE "%s" (%s) SERVER %s)") %
						table_name.c_str() % col_def.str() % server->servername)
						.str();

		elog(DEBUG1, "%.512s", table_def.c_str());

		*commands = lappend(*commands, pstrdup(table_def.c_str()));
	}

	return TG_STATUS_OK;
}

/**
 *  @brief Show table list in remote database.
 *  @note Use tg_global_error_message() to retrieve the error message.
 */
TG_STATUS tg_exec_show_tables(
		TGconn* tg_conn, TG_SHOW_TABLE_PARAM* param, char** result) noexcept {
	static constexpr const char* const kKeyRootObject = "remote_schema";
	static constexpr const char* const kKeyRemoteSchema = "remote_schema";
	static constexpr const char* const kKeyServerName = "server_name";
	static constexpr const char* const kKeyMode = "mode";
	static constexpr const char* const kKeyRemoteTable =
			"tables_on_remote_schema";
	static constexpr const char* const kKeyCount = "count";
	static constexpr const char* const kKeyList = "list";

	assert(tg_conn && param && result);

	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	TableListPtr tables;
	auto tg_status = tg_get_list_tables(tg_conn, tables);
	if (tg_status != TG_STATUS_OK) {
		return tg_status;
	}

	boost::property_tree::ptree table_list;	 // table list array
	/* Convert list of table names to ptree. */
	for (const auto& table_name : tables->get_table_names()) {
		boost::property_tree::ptree item;
		item.put("", table_name);
		table_list.push_back(std::make_pair("", item));
	}

	boost::property_tree::ptree pt_root;		// root object
	boost::property_tree::ptree remote_schema;	// <remote_schema> object
	boost::property_tree::ptree
			remote_tables;	// <tables_on_remote_schema> object

	/* Add to table count. */
	remote_tables.put(kKeyCount, table_list.size());

	/* If the report level is 'detail', add a table listing. */
	if (param->detail) {
		/* Add to table name list. */
		remote_tables.add_child(kKeyList, table_list);
	}

	/* Add to <remote_schema>. */
	remote_schema.put(kKeyRemoteSchema, param->schema_name);
	/* Add to <server_name>. */
	remote_schema.put(kKeyServerName, param->server_name);
	/* Add to <mode>. */
	remote_schema.put(kKeyMode, param->mode);
	/* Add to <tables_on_remote_schema> object. */
	remote_schema.add_child(kKeyRemoteTable, remote_tables);

	/* Add to root object. */
	pt_root.add_child(kKeyRootObject, remote_schema);

	std::stringstream ss;
	/* Convert to JSON. */
	try {
		boost::property_tree::json_parser::write_json(
				ss, pt_root, param->pretty);
	} catch (const std::exception& e) {
		return set_exception(e);
	} catch (...) {
		return set_exception();
	}
	std::string json_str(ss.str());

	/* Remove trailing newline code. */
	if (json_str.back() == '\n') {
		json_str.erase(json_str.size() - 1);
	}

	std::string separator = (param->pretty ? " " : "");

	/* Converts the value of a numeric item from a string to a number. */
	auto pattern_num =
			(boost::format(R"_("%s":\s*"(\d+)")_") % kKeyCount).str();
	auto replace_num =
			(boost::format(R"("%s":%s$1)") % kKeyCount % separator).str();
	json_str =
			std::regex_replace(json_str, std::regex(pattern_num), replace_num);

	/* Converts an empty value of an array item from an empty character to an
	 * empty array.
	 */
	auto pattern_array = (boost::format(R"("%s":\s*"")") % kKeyList).str();
	auto replace_array =
			(boost::format(R"("%s":%s[])") % kKeyList % separator).str();
	json_str = std::regex_replace(
			json_str, std::regex(pattern_array), replace_array);

	*result = pstrdup(json_str.c_str());

	return TG_STATUS_OK;
}

/**
 *  @brief Verify table names between local schema and remote schema.
 *  @note Use tg_global_error_message() to retrieve the error message.
 */
TG_STATUS tg_exec_verify_tables(
		TGconn* tg_conn, TG_VERIFY_TABLE_PARAM* param, char** result) noexcept {
	static constexpr const char* const kKeyRootObject = "verification";
	static constexpr const char* const kKeyRemoteSchema = "remote_schema";
	static constexpr const char* const kKeyServerName = "server_name";
	static constexpr const char* const kKeyLocalSchema = "local_schema";
	static constexpr const char* const kKeyMode = "mode";
	static constexpr const char* const kKeyRemoteOnly =
			"tables_on_only_remote_schema";
	static constexpr const char* const kKeyLocalOnly =
			"foreign_tables_on_only_local_schema";
	static constexpr const char* const kKeyAltered =
			"tables_that_need_to_be_altered";
	static constexpr const char* const kKeyAvailable =
			"available_foreign_table";
	static constexpr const char* const kKeyCount = "count";
	static constexpr const char* const kKeyList = "list";
	static const std::unordered_map<std::string, std::string>
			tz_abbreviate_type = {{"time without time zone", "time"},
					{"timestamp without time zone", "timestamp"}};

	ERROR_CODE error = ERROR_CODE::UNKNOWN;
	TableListPtr tables;

	assert(tg_conn && param && result);

	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	boost::property_tree::ptree
			list_remote;  // <tables_on_only_remote_schema> <list> array
	boost::property_tree::ptree
			list_local;	 // <foreign_tables_on_only_local_schema> <list> array
	boost::property_tree::ptree
			list_altered;  // <tables_that_need_to_be_altered> <list> array
	boost::property_tree::ptree
			list_available;	 // <available_foreign_table> <list> array

	if (SPI_connect() != SPI_OK_CONNECT) {
		return set_error("Failed to execute SPI_connect", TG_STATUS_SPI_ERROR);
	}

	static const int kValRelname = 1;
	static const int kValAttname = 2;
	static const int kValDatatype = 3;
	static const int kValAtttypmod = 4;
	static constexpr const char* const kMetadataQuery =
			"SELECT "
			"  c.relname, a.attname, format_type(a.atttypid, a.atttypmod) AS "
			"datatype, "
			"a.atttypmod "
			"FROM pg_foreign_table ft "
			"  JOIN pg_class c ON ft.ftrelid = c.oid "
			"  JOIN pg_namespace n ON c.relnamespace = n.oid "
			"  JOIN pg_attribute a ON a.attrelid = c.oid "
			"WHERE "
			"  (n.oid = $1) AND (ft.ftserver = $2) AND (a.attnum > 0) AND (NOT "
			"a.attisdropped) "
			"ORDER BY c.relname, a.attnum";

	Oid argtypes[2] = {OIDOID, OIDOID};
	Datum values[2] = {ObjectIdGetDatum(param->local_schema_oid),
			ObjectIdGetDatum(param->server_id)};
	char nulls[2] = {' ', ' '};

	/* Refer to the system catalog. */
	int res = SPI_execute_with_args(
			kMetadataQuery, sizeof(values), argtypes, values, nulls, true, 0);
	if (res != SPI_OK_SELECT) {
		auto msg =
				boost::format("Failed to SPI_execute_with_args. (error: %d)") %
				res;
		return set_error(msg.str(), TG_STATUS_SPI_ERROR);
	}

	// Metadata of foreign tables
	std::unordered_map<std::string,
			std::vector<std::tuple<std::string, std::string, int, int>>>
			foreign_table_metadata = {};

	// List of Tsurugi table names
	auto tg_status = tg_get_list_tables(tg_conn, tables);
	if (tg_status != TG_STATUS_OK) {
		return tg_status;
	}
	auto tg_table_names = tables->get_table_names();

	std::string skip_table_name = "";

	/* Verifies whether foreign tables in the local schema exist in the remote
	 * schema, and if so, retrieves metadata for the external tables.
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
		auto ite = std::find(
				tg_table_names.begin(), tg_table_names.end(), rel_name);
		if (ite == tg_table_names.end()) {
			elog(DEBUG2,
					R"(Tables that do not exist in the remote schema. "%s")",
					rel_name.c_str());
			/* Add to a table that exists only in the remote schema. */
			list_local.push_back(
					std::make_pair("", boost::property_tree::ptree(rel_name)));
			skip_table_name = rel_name;
			continue;
		}
		skip_table_name = "";

		// column name
		char* column_name = SPI_getvalue(spi_tuple, tupdesc, kValAttname);

		// data type (string)
		std::string datatype(SPI_getvalue(spi_tuple, tupdesc, kValDatatype));
		std::transform(
				datatype.begin(), datatype.end(), datatype.begin(), ::tolower);

		bool is_null;
		// precision
		int precision = -1;
		// scale
		int scale = -1;

		Datum typmod_datum =
				SPI_getbinval(spi_tuple, tupdesc, kValAtttypmod, &is_null);
		int32 typmod = (!is_null ? DatumGetInt32(typmod_datum) : -1);
		if (typmod != -1) {
			precision = ((typmod - VARHDRSZ) >> 16) & 0xFFFF;
			scale = (typmod - VARHDRSZ) & 0xFFFF;
		}

		/* Stores metadata for foreign tables. */
		foreign_table_metadata[rel_name].emplace_back(
				std::make_tuple(column_name, datatype, precision, scale));
	}

	SPI_finish();

	/* Verifies whether tables in the remote schema exist in the local schema.
	 */
	for (auto ite = tg_table_names.begin(); ite != tg_table_names.end();) {
		/* Verify that a remote table exists on the local. */
		if (foreign_table_metadata.find(*ite) == foreign_table_metadata.end()) {
			elog(DEBUG2,
					R"(Tables that do not exist in the local schema. "%s")",
					(*ite).c_str());

			/* Add to a table that exists only in the remote schema. */
			list_remote.push_back(
					std::make_pair("", boost::property_tree::ptree(*ite)));
			/* Exclude from metadata validation. */
			tg_table_names.erase(ite);

			continue;
		}
		ite++;
	}

	/* Metadata Validation */
	for (const auto& table_name : tg_table_names) {
		elog(DEBUG2, R"(Metadata Validation: table name: "%s")",
				table_name.c_str());

		TableMetadataPtr tg_table_metadata;
		/* Get table metadata from Tsurugi. */
		auto tg_status =
				tg_get_table_metadata(tg_conn, table_name, tg_table_metadata);
		if (tg_status != TG_STATUS_OK) {
			auto msg = tg_make_error_message(tg_conn,
					"Failed to get table metadata from tsurugi.", error);
			return set_error(msg);
		}

		/* Get table metadata from PostgreSQL. */
		const auto& pg_columns =
				foreign_table_metadata.find(table_name)->second;
		/* Get table metadata from tsurugi. */
		const auto& tg_columns = tg_table_metadata->columns();

		/* Validate the number of columns. */
		if (pg_columns.size() != static_cast<size_t>(tg_columns.size())) {
			elog(DEBUG2,
					"Number of columns does not match. local:%lu / remote:%d",
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
			const auto& [pg_col_name, pg_col_type, pg_col_precision,
					pg_col_scale] = pg_column;
			const auto& tg_column = tg_columns.at(idx++);

			elog(DEBUG5, R"(Column Validation: column name: "%s")",
					pg_col_name.c_str());

			/* Validate the column name. */
			if (pg_col_name != tg_column.name()) {
				elog(DEBUG2,
						R"_(Name of column does not match. position:%d (local:"%s" / remote:"%s"))_",
						idx, pg_col_name.c_str(), tg_column.name().c_str());

				matched = false;
				break;
			}

			/* Convert from tsurugi datatype to PostgreSQL datatype. */
			auto remote_type_pg =
					tg_convert_type_tg_to_pg(tg_column.atom_type());
			if (!remote_type_pg) {
				elog(DEBUG2, "Data type is unknown. %s (atom_type:%d)",
						pg_col_name.c_str(),
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
			auto ite = std::find(local_type.begin(), local_type.end(),
					remote_type_pg.value());
			if (ite == local_type.end()) {
				elog(DEBUG2,
						R"_(Datatype of column does not match. %s (local:"%s" / remote:"%s"))_",
						pg_col_name.c_str(), local_type[0].c_str(),
						remote_type_pg->data());

				matched = false;
				break;
			}

			/* Validate the precision and scale. */
			if ((pg_col_precision != -1) || (pg_col_scale != -1)) {
				elog(DEBUG2,
						R"_(Column precision/scale does not match. "%s (local: %s(%d,%d) / remote:%s))_",
						pg_col_name.c_str(), local_type[0].c_str(),
						pg_col_precision, pg_col_scale, remote_type_pg->data());

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

	boost::property_tree::ptree pt_root;	   // root object
	boost::property_tree::ptree verification;  // <verification> object

	/* Add to <remote_schema>. */
	verification.put(kKeyRemoteSchema, param->remote_schema);
	/* Add to <server_name>. */
	verification.put(kKeyServerName, param->server_name);
	/* Add to <local_schema>. */
	verification.put(kKeyLocalSchema, param->local_schema);
	/* Add to <mode>. */
	verification.put(kKeyMode, param->mode);

	/* Child object of a validation object. */
	std::map<const char*, const boost::property_tree::ptree*> child_object = {
			{kKeyRemoteOnly, &list_remote}, {kKeyLocalOnly, &list_local},
			{kKeyAltered, &list_altered}, {kKeyAvailable, &list_available}};

	/* Verification object is configured. */
	for (const auto& object : child_object) {
		const auto key = object.first;
		const auto list = object.second;

		boost::property_tree::ptree child;
		/* Add to table count. */
		child.put(kKeyCount, list->size());

		/* If the report level is 'detail', add a table listing. */
		if (param->detail) {
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
		boost::property_tree::json_parser::write_json(
				ss, pt_root, param->pretty);
	} catch (const std::exception& e) {
		return set_exception(e);
	} catch (...) {
		return set_exception();
	}
	std::string json_str(ss.str());

	/* Remove trailing newline code. */
	if (json_str.back() == '\n') {
		json_str.erase(json_str.size() - 1);
	}

	std::string separator = (param->pretty ? " " : "");

	/* Converts the value of a numeric item from a string to a number. */
	auto pattern_num =
			(boost::format(R"_("%s":\s*"(\d+)")_") % kKeyCount).str();
	auto replace_num =
			(boost::format(R"("%s":%s$1)") % kKeyCount % separator).str();
	json_str =
			std::regex_replace(json_str, std::regex(pattern_num), replace_num);

	/* Converts an empty value of an array item from an empty character to an
	 * empty array.
	 */
	auto pattern_array = (boost::format(R"("%s":\s*"")") % kKeyList).str();
	auto replace_array =
			(boost::format(R"("%s":%s[])") % kKeyList % separator).str();
	json_str = std::regex_replace(
			json_str, std::regex(pattern_array), replace_array);

	*result = pstrdup(json_str.c_str());

	return TG_STATUS_OK;
}

}  // extern "C"

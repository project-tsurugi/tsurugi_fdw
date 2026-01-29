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
#include <string>
#include <memory>
#include <regex>
#include <boost/algorithm/string.hpp>
#include <boost/filesystem.hpp>
#include <boost/format.hpp>
#include <boost/property_tree/ini_parser.hpp>
#include "ogawayama/stub/api.h"
#include "ogawayama/stub/error_code.h"
#include "tg_common/tsurugi.h"

#ifdef __cplusplus
extern "C" {
#endif
#include "postgres.h"
#include "foreign/foreign.h"
#include "miscadmin.h"
#include "nodes/params.h"
#include "tg_common/tsurugi_api.h"
#ifdef __cplusplus
}
#endif

using namespace ogawayama;

typedef struct {
    std::string msg;
    TG_STATUS code = TG_STATUS_OK;
} ErrorState;

struct TGconn { 
    static ConnectionPtr impl;
    ErrorState error;
    static StubPtr db;
    std::string db_name;
    Oid server_oid;
};
ConnectionPtr TGconn::impl = nullptr;
StubPtr TGconn::db = nullptr;

struct TGtx { 
    TGconn* tg_conn;
    TransactionPtr impl;
    ErrorState error;
};

struct TGstmt { 
    TGtx* tg_tx;
    PreparedStatementPtr impl;
    std::string name;
    std::string sql;
    std::string original_sql;
    ogawayama::stub::placeholders_type placeholders;
    ogawayama::stub::parameters_type paramerters;
    ErrorState error;
    bool in_use = false; /* true: resultが使用中（execute_query後にResultSetが生存中） */
};

struct TGresult{ 
    ResultSetPtr impl; 
    ErrorState error;
};

extern bool GetTransactionOption(boost::property_tree::ptree&);

namespace {


/** ===========================================================================
 * 
 *  Error Handling Functions.
 * 
 */
inline void set_ok(ErrorState& error) {
    error.msg.clear();
    error.code = TG_STATUS_OK;
}

inline TG_STATUS set_error(ErrorState& error, std::string_view msg, 
        const TG_STATUS code = TG_STATUS_ERROR) {
    elog(LOG, "tsurugi_fdw : set_error() (code: %d, %s)", code, msg.data());
    error.msg = msg;
    error.code = code;
    return code;
}

inline TG_STATUS set_exception(ErrorState& error, const std::exception& e,
        const TG_STATUS code = TG_STATUS_ERROR) {
    elog(LOG, "tsurugi_fdw : set_exception() (code: %d, %s)", code, e.what());
    std::ostringstream oss;
    oss << "Unexpected exception occurred. (what: " << e.what() << ")";
    error.msg = oss.str();
    error.code = code;
    return code;
}

/**
 *  @brief 	Output error log which has a error message and error code.
 *  @param 	(level) log level.
 * 			(message) error message.
 * 			(error) error code of ogawayama.
 *  @return	none.
 */
void log2(const int level, std::string_view message, const ERROR_CODE error) {
	std::string ext_message{"tsurugi_fdw : "};

	if (level != ERROR) {
		ext_message += message;
		ext_message += " (error: %s{%d})";
		elog(level, ext_message.data(),  stub::error_name(error).data(), (int)error);
	}
}

/**
 *  @brief 	Get detail message of tsurugi server.
 *  @param 	(error_code) error code of ogawayama.
 *  @return	detail error message.
 */
std::string get_detail_message(const TGconn* tg_conn, const ERROR_CODE error_code) {
	std::string message = "No detail message.";

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	if (error_code != ERROR_CODE::SERVER_ERROR)
	{
		log2(LOG, "Error code is not SERVER_ERROR.", error_code);
		return message;
	}

	if (tg_conn->impl == nullptr)
	{
		elog(DEBUG1, "tsurugi_fdw : There is no connection to Tsurugi.");
		return message;
	}

	//  get detail message from Tsurugi.
	stub::tsurugi_error_code error{};
	auto ret_code = tg_conn->impl->tsurugi_error(error);
	if (ret_code == ERROR_CODE::OK)
	{
		elog(LOG, "ERROR_CODE::SERVER_ERROR\n\t"
					"tsurugi_error_code.type: %d\n\t"
					"                   code: %d\n\t"
					"                   name: %s\n\t"
					"                 detail: %s\n\t"
					"      supplemental_text: %s",
					(int) error.type, error.code, error.name.c_str(),
					error.detail.c_str(), error.supplemental_text.c_str());

        std::string detail_code;
        try {
            switch (error.type)
            {
                case stub::tsurugi_error_code::tsurugi_error_type::sql_error:
                    detail_code = "SQL-" + (boost::format("%05d") % error.code).str();
                    break;
                case stub::tsurugi_error_code::tsurugi_error_type::framework_error:
                    detail_code = "SCD-" + (boost::format("%05d") % error.code).str();
                    break;
                default:
                    elog(WARNING, "Unknown error type. (type: %d)", (int) error.type);
                    detail_code = "UNKNOWN-" + (boost::format("%05d") % error.code).str();
                    break;
            }
        } catch (...) {
            return message;
        }
		// build error message.
		message = "Tsurugi Error: " + error.name 
					+ " (" + detail_code + ": " + error.detail + ")";
	}
	else
	{
		log2(LOG, "Failed to get Tsurugi Server Error.", ret_code);
	}

	return message;
}

/**
 *  @brief 	Make error message.
 *  @param 	(tg_conn) pointer to TGconn.
 *          (message) error message.
 * 			(error) error code.
 * 			(sql) the statement that was attempted to be sent to tsurugidb.
 *  @return	none.
 */
std::string make_error_message(TGconn* tg_conn, std::string_view message, 
        ERROR_CODE error, std::string_view sql = {}) {
    std::string detail = get_detail_message(tg_conn, error);
	std::ostringstream msg;
    msg << "Failed to execute remote SQL.\n"
        << "HINT:  " << message << " error: " << stub::error_name(error).data() 
        << "(" << (int) error << ")\n"
        << detail.data() << "\n" 
        << "CONTEXT:  SQL query: " << sql;
    elog(LOG, "tsurugi_fdw : %s\n%s", __func__, msg.str().c_str());
    return msg.str();
}

/** ===========================================================================
 * 
 *  Helper Functions.
 * 
 */
/**
 *  get_database_name
 */
std::string get_database_name(Oid server_oid) {
	auto server = GetForeignServer(server_oid);
	assert(server != nullptr);
	ConnectionInfo conn_info{server->options};
    elog(DEBUG5, "tsurugi_fdw : db_name: %s", conn_info.dbname().data());
    return std::string{conn_info.dbname()};
}

/**
 *  @brief  Trimming a string to remove comments and newline characters
 *  @param  (orig_query) input query string.
 *  @return	(query) trimmed query string.
 */
std::string trim_query_string(const std::string& orig_query) {
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
 *  make_tsurugi_query
 */
static std::string make_tsurugi_query(std::string_view query_string) {
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
    if (tsurugi_query.back() == ';') {
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
 *  is_prepare_statement
 */
bool is_prepare_statement(const char* query) {
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
std::pair<std::string, std::string> extract_prepare_statement(const char* query) {
    elog(DEBUG3, "tsurugi_fdw : %s", __func__);

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
    } else {
        prep_stmt = orig_query;
    }
    elog(DEBUG3, "tsurugi_fdw : prep_name: %s,\nprepare statement = \n%s", 
        prep_name.c_str(), prep_stmt.c_str());

    if (boost::algorithm::icontains(query, "$") ) {
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
            elog(LOG, "tsurugi_fdw : A logic_error exception occurred. what: %s", e.what());
            return std::pair{"", ""};
        } catch (const std::exception& e) {
            elog(LOG, "tsurugi_fdw : An exception occurred. what: %s", e.what());          
            return std::pair{"", ""};
        }
    }
    elog(DEBUG3, "tsurugi_fdw : prep_name: %s,\nprepare statement = \n%s", 
        prep_name.c_str(), prep_stmt.c_str());
    return std::pair{prep_name, prep_stmt};
}

/**
 *  @brief  Make placeholders of prepare statement.
 *  @param  (param_linfo) parameter list.
 *  @return	placeholders_type object.
 */
ogawayama::stub::placeholders_type make_placeholders(ParamListInfo param_linfo) {
 	elog(DEBUG3, "tsurugi_fdw : %s", __func__);

    stub::placeholders_type placeholders{};
    if (param_linfo != nullptr) {
        for (auto i = 0; i < param_linfo->numParams; i++) {
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

/**
 *  @brief  Make parameters of prepared statement.
 *  @param  (param_linfo) ParamListInfo structure.
 *  @return	parameters_type object.
 */
ogawayama::stub::parameters_type make_parameters(ParamListInfo param_linfo) {
	elog(DEBUG3, "tsurugi_fdw : %s", __func__);

    stub::parameters_type params{};
    if (param_linfo != nullptr) {
        for (auto i = 0; i < param_linfo->numParams; i++) {	
            /* parameter number is 1 origin. */
            auto param_name = "param" + std::to_string(i+1);
            ParamExternData param = param_linfo->params[i];
            if (param.isnull) {
                std::monostate mono{};
                params.emplace_back(param_name, mono);
            } else {
                auto value = tsurugi::convert_type_to_tg(param.ptype, param.value);
                params.emplace_back(param_name, value);
            }
        }
    }

    return params;
}

/**
 *  make_tuple_from_result_row
 *      Obtain tuple data from Ogawayama and convert data type.
 */
void make_tuple_from_result_row(ResultSetPtr result_set, TupleDesc tupleDescriptor, 
        List* retrieved_attrs, Datum* row, bool* is_null) {
	elog(DEBUG5, "tsurugi_fdw : %s", __func__);
	memset(row, 0, sizeof(*row) * tupleDescriptor->natts);
	memset(is_null, true, sizeof(*is_null) * tupleDescriptor->natts);

	ListCell   *lc = NULL;
	foreach(lc, retrieved_attrs) {
		const int attnum = lfirst_int(lc) - 1;
        Form_pg_attribute pg_attr =TupleDescAttr(tupleDescriptor, attnum);
		elog(DEBUG5, "tsurugi_fdw : %s : attnum: %d", __func__, attnum + 1);
        const auto tsurugi_value = 
                tsurugi::convert_type_to_pg(result_set, pg_attr->atttypid);
        is_null[attnum] = tsurugi_value.first;  // null flag
        if (!is_null[attnum]) {
            row[attnum] = tsurugi_value.second; // value
        }
    }
    // free unique_ptr
    result_set = nullptr;
}
}   // namespace

extern "C" {
/** ===========================================================================
 * 
 *  Connection Functions.
 * 
 */
/**
 *  tg_conn_new
 */
TGconn* tg_conn_new(Oid server_oid) {
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);
    TGconn* tg_conn = new (std::nothrow) TGconn;
    if (!tg_conn) return nullptr;
    if (server_oid == InvalidOid) {
        std::ostringstream oss;
        oss << "tsurugi_fdw: Invalid server ID. (server_oid: " << server_oid << ")";
        set_error(tg_conn->error, oss.str());
        return nullptr;
    }
    tg_conn->server_oid = server_oid;
    set_ok(tg_conn->error);
    return tg_conn;
}

/**
 *  tg_conn_connect
 */
TG_STATUS tg_conn_connect(TGconn* tg_conn) {
    assert(tg_conn);
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);
    try {
        auto db_name = get_database_name(tg_conn->server_oid);
        if (!tg_conn->db || tg_conn->db_name != db_name) {
            tg_conn->db_name = db_name;
            auto error = make_stub(tg_conn->db, tg_conn->db_name);
            if (error != ERROR_CODE::OK) {
                auto msg = make_error_message(tg_conn, 
                        "Failed to attach the shared memory of Tsurugi database.", 
                        error, tg_conn->db_name);                        
                return set_error(tg_conn->error, msg, TG_STATUS_TSURUGI_ERROR);
            }
        }
        if (!tg_conn->impl) {
            elog(DEBUG1, "tsurugi_fdw : Attempt to call get_connection(). (pid: %d)", 
                    MyProcPid);
            auto error = tg_conn->db->get_connection(MyProcPid, tg_conn->impl);
            log2(DEBUG1, "get_connection() is done.", error);
            if (error != ERROR_CODE::OK) {
                auto msg = make_error_message(tg_conn, 
                        "Failed to connect to Tsurugi database.", 
                        error, tg_conn->db_name);
                return set_error(tg_conn->error, msg, TG_STATUS_TSURUGI_ERROR);
            }
        }
        set_ok(tg_conn->error); 
        return TG_STATUS_OK; 
    } catch (const std::exception& error) { 
        return set_exception(tg_conn->error, error); 
    }
}

/**
 *  tg_conn_is_connected
 */
bool tg_conn_is_connected(const TGconn* tg_conn) {
 	elog(DEBUG3, "tsurugi_fdw : %s", __func__);
	if (!tg_conn || !tg_conn->db || !tg_conn->impl) {
		elog(DEBUG5, "No connection to Tsurugi found.");
		return false;
	}
    elog(DEBUG3, "Connection to Tsurugi found. (server_oid: %d, db_name: %s)", 
            tg_conn->server_oid, tg_conn->db_name.c_str());
	return true;   
}

/**
 *  tg_conn_close
 */
void tg_conn_close(TGconn* tg_conn) {
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);
    if (!tg_conn || !tg_conn->impl) return;
    tg_conn->impl = nullptr;
    tg_conn->db = nullptr;
    delete tg_conn;
}

/**
 *  tg_conn_error_message()
 */
const char*	tg_conn_error_message(const TGconn* tg_conn) {
    if (!tg_conn) return nullptr;
    return tg_conn->error.msg.empty() ? "No detail message." 
                                        : tg_conn->error.msg.c_str();
}

/** ===========================================================================
 * 
 *  Transaction Functions.
 * 
 */
/**
 *  tg_tx_new
 */
TGtx* tg_tx_new(TGconn* tg_conn) {
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);

    if (!tg_conn || !tg_conn->impl || !tg_conn->db) return nullptr;
    TGtx* tg_tx = new (std::nothrow) TGtx;
    if (!tg_tx) return nullptr;
    tg_tx->tg_conn = tg_conn;
    tg_tx->impl = nullptr;
    set_ok(tg_conn->error);
    return tg_tx;
}

/**
 *  tg_tx_free
 */
void tg_tx_free(TGtx* tg_tx) {
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);
    if (!tg_tx) return;
    if (tg_tx->impl) {
        // if the transaction is active, do rollback.
        tg_tx_rollback(tg_tx);
    }
    tg_tx->impl = nullptr;
    delete tg_tx;
    tg_tx = nullptr;
}

/**
 *  tg_tx_begin
 */
TG_STATUS tg_tx_begin(TGtx* tg_tx) {
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);
    assert(tg_tx);
    if (!tg_conn_is_connected(tg_tx->tg_conn) || tg_tx_is_active(tg_tx)) {
        return set_error(tg_tx->error, 
                "Invalid arguments in tg_tx_begin.", TG_STATUS_INVALID_ARG);
    }
    try {
       	boost::property_tree::ptree option;
        GetTransactionOption(option);
        elog(DEBUG1, "tsurugi_fdw : Attempt to call begin().");
        auto error = tg_tx->tg_conn->impl->begin(option, tg_tx->impl);
       	log2(DEBUG1, "tsurugi_fdw : begin() is done.", error);
        if (error != ERROR_CODE::OK) {
            auto msg = make_error_message(tg_tx->tg_conn, 
                    "Failed to start the transaction on Tsurugi.", error);
            return set_error(tg_tx->error, msg, TG_STATUS_TSURUGI_ERROR);
        }
        set_ok(tg_tx->error); 
        return TG_STATUS_OK; 
    } catch (const std::exception& error) { 
        return set_exception(tg_tx->error, error); 
    }
}

/**
 *  tg_tx_is_active
 */
bool tg_tx_is_active(const TGtx* tg_tx) {
    if (!tg_tx || !tg_tx->impl) return false;
    return true;
}

/**
 *  tg_tx_commit
 */
TG_STATUS tg_tx_commit(TGtx* tg_tx) {
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);
    assert(tg_tx && tg_tx->impl);
    if (!tg_tx_is_active(tg_tx)) {
        return set_error(tg_tx->error, 
                "This transaction is not active.", TG_STATUS_INVALID_ARG);
    }
    try {
        elog(DEBUG1, "tsurugi_fdw : Attempt to call commit().");
        auto error = tg_tx->impl->commit();
        log2(DEBUG1, "tsurugi_fdw : commit() is done.", error);
        if (error != ERROR_CODE::OK) {
            auto msg = make_error_message(tg_tx->tg_conn, 
                    "Failed to commit the transaction.", error);
            return set_error(tg_tx->error, msg, TG_STATUS_TSURUGI_ERROR);
        }
        tg_tx->impl = nullptr;
        set_ok(tg_tx->error);
        return TG_STATUS_OK; 
    } catch (const std::exception& error) {
        return set_exception(tg_tx->error, error);
    }
}

/**
 *  tg_tx_rollback
 */
TG_STATUS tg_tx_rollback(TGtx* tg_tx) {
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);
    assert(tg_tx && tg_tx->impl);
    if (!tg_tx_is_active(tg_tx)) {
        return set_error(tg_tx->error, 
                "This transaction is not active.", TG_STATUS_INVALID_ARG);
    }
    try {
        auto error = tg_tx->impl->rollback();
        if (error != ERROR_CODE::OK) {
            auto msg = make_error_message(tg_tx->tg_conn, 
                    "Failed to rollback the transaction.", error);
            return set_error(tg_tx->error, msg, TG_STATUS_TSURUGI_ERROR);
        }
        tg_tx->impl = nullptr;
        set_ok(tg_tx->error);
        return TG_STATUS_OK; 
    } catch (const std::exception& error) {
        return set_exception(tg_tx->error, error);
    }
}

/**
 *  tg_tx_error_message
 */
const char*	tg_tx_error_message(const TGtx* tg_tx) {
    if (!tg_tx) return nullptr;
    return tg_tx->error.msg.empty() ? "" : tg_tx->error.msg.c_str();
}

/** ===========================================================================
 * 
 *  Execute Statement Functions.
 * 
 */
/**
 *  tg_stmt_new
 */
TGstmt* tg_stmt_new(TGtx* tg_tx, const char* sql) {
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);
    if (!tg_tx || !sql) return nullptr;
    if (!tg_tx->tg_conn) {
        set_error(tg_tx->error, "connection is not open", TG_STATUS_NOT_OPEN);
        return nullptr;
    }
    //  Make TGstmt handle.
    TGstmt* tg_stmt = new (std::nothrow) TGstmt;
    if (!tg_stmt) {
        set_error(tg_tx->error, "out of memory (TGstmt)", TG_STATUS_ERROR);
        return nullptr;
    }

    if (is_prepare_statement(sql)) {
        auto prep = extract_prepare_statement(sql);
        if (prep.second.empty()) {
            return nullptr;
        }
        tg_stmt->name = prep.first;
        tg_stmt->sql = make_tsurugi_query(prep.second);
    } else {
    	tg_stmt->sql = make_tsurugi_query(sql);
    }
    tg_stmt->impl = nullptr;
    tg_stmt->original_sql = sql;
    tg_stmt->tg_tx = tg_tx;
    tg_stmt->in_use = false;
    elog(DEBUG1, "tsurugi_fdw : new statement (orig: %s), (name: %s), (sql: %s)",
            tg_stmt->original_sql.c_str(), tg_stmt->name.c_str(), tg_stmt->sql.c_str());
    set_ok(tg_stmt->error);
    return tg_stmt;    
}

/**
 *  tg_stmt_free
 */
void tg_stmt_free(TGstmt* tg_stmt) {
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);
    if (!tg_stmt) return;
    tg_stmt->impl = nullptr;
    delete tg_stmt;
    tg_stmt = nullptr;
}

/**
 *  tg_stmt_set_placeholders
 */
TG_STATUS tg_stmt_bind_parameters(TGstmt* tg_stmt, ParamListInfo param_linfo) {
    assert(tg_stmt);
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);
    tg_stmt->placeholders = make_placeholders(param_linfo);
    tg_stmt->paramerters = make_parameters(param_linfo);
    set_ok(tg_stmt->error);
    return TG_STATUS_OK;
}

/**
 *  tg_stmt_execute_statement
 */
TG_STATUS tg_stmt_execute_statement(TGstmt* tg_stmt, size_t* num_rows) {
    assert(tg_stmt && num_rows);
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);
    TGconn* tg_conn = tg_stmt->tg_tx->tg_conn;
    TGtx* tg_tx = tg_stmt->tg_tx;
    try {
        //  Prepare the statement.
        elog(DEBUG1, "tsurugi_fdw : Attempt to call prepare()");
        auto error = tg_conn->impl->prepare(
                tg_stmt->sql, tg_stmt->placeholders, tg_stmt->impl);
        log2(DEBUG1, "prepare() is done.", error);
        if (error != ERROR_CODE::OK) {
            auto msg = make_error_message(tg_conn, 
                    "Failed to execute the statement on Tsurugi.", 
                    error, tg_stmt->sql);
            return set_error(tg_stmt->error, msg, TG_STATUS_TSURUGI_ERROR);
        }

        //  Execute the prepared statement.
        elog(DEBUG1, "tsurugi_fdw : Attempt to call execute_statement()");
        error = tg_tx->impl->execute_statement(
                tg_stmt->impl, tg_stmt->paramerters, *num_rows);
        log2(DEBUG1, "execute_statement() is done.", error);
        if (error != ERROR_CODE::OK) {
            auto msg = make_error_message(tg_conn, 
                    "Failed to execute the statement on Tsurugi.", 
                    error, tg_stmt->sql);
            return set_error(tg_stmt->error, msg, TG_STATUS_TSURUGI_ERROR);
        }
        set_ok(tg_stmt->error);
        return TG_STATUS_OK;
    } catch (std::exception& e) {
        return set_exception(tg_stmt->error, e);
    }
}

/**
 *  tg_stmt_execute_query
 */
TG_STATUS tg_stmt_execute_query (TGstmt* tg_stmt, TGresult** tg_result) {
    assert(tg_stmt && tg_result);
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);
    elog(DEBUG1, "tsurugi_fdw : query:\n%s", tg_stmt->sql.c_str());
    TGconn* tg_conn = tg_stmt->tg_tx->tg_conn;
    TGtx* tg_tx = tg_stmt->tg_tx;
    *tg_result = new (std::nothrow) TGresult;
    if (!tg_stmt) {
        return set_error(tg_tx->error, "out of memory (TGstmt)");
    }
    try {
        //  Prepare the query.
        elog(DEBUG1, "tsurugi_fdw : Attempt to call prepare()");
        auto error = tg_conn->impl->prepare(
                tg_stmt->sql, tg_stmt->placeholders, tg_stmt->impl);
        elog(DEBUG1, "tsurugi_fdw : prepare() is done.");
        if (error != ERROR_CODE::OK) {
            auto msg = make_error_message(tg_conn, 
                    "Failed to execute the statement on Tsurugi.", 
                    error, tg_stmt->sql);
            return set_error(tg_stmt->error, msg, TG_STATUS_TSURUGI_ERROR);
        }

        //  Execute the prepared query.
        elog(DEBUG1, "tsurugi_fdw : Attempt to call execute_query()");
        error = tg_tx->impl->execute_query(
                tg_stmt->impl, tg_stmt->paramerters, (*tg_result)->impl);
        log2(DEBUG1, "tsurugi_fdw : execute_query() is done.", error);
        if (error != ERROR_CODE::OK) {
            auto msg = make_error_message(tg_conn, 
                    "Failed to execute the statement on Tsurugi.", 
                    error, tg_stmt->sql);
            return set_error(tg_stmt->error, msg, TG_STATUS_TSURUGI_ERROR);
        }
        set_ok(tg_stmt->error);
        return TG_STATUS_OK;
    } catch (std::exception& e) {
        return set_exception(tg_stmt->error, e);
    }
}

/**
 *  tg_stmt_error_message
 */
const char* tg_stmt_error_message(const TGstmt* tg_stmt) {
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);
    if (!tg_stmt) return nullptr;
    return tg_stmt->error.msg.empty() ? "" : tg_stmt->error.msg.c_str();
}

/** ===========================================================================
 * 
 *  ResultSet Functions.
 * 
 */
/**
 *  tg_result_free
 */
void tg_result_free(TGresult* tg_result) {
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);
    if (!tg_result) return;
    tg_result->impl = nullptr;
    delete tg_result;
    tg_result = nullptr;
}

/**
 *  tg_result_next
 */
TG_STATUS tg_result_next(TGresult* tg_result, bool* has_row) {
    assert(tg_result && has_row);
    elog(DEBUG5, "tsurugi_fdw : %s", __func__);
    try {
        *has_row = false;
        auto error = tg_result->impl->next();
        switch (error) {
            case ERROR_CODE::OK:
                *has_row = true;
                break;
            case ERROR_CODE::END_OF_ROW:
                *has_row = false;
                break;
            default:
            return set_error(tg_result->error, 
                    "ResultSet::next() failed.", TG_STATUS_TSURUGI_ERROR);
        }
        set_ok(tg_result->error);
        return TG_STATUS_OK;
    } catch (std::exception& e) {
        return set_exception(tg_result->error, e);
    }
}

/**
 *  tg_result_get_tuple
 */
TG_STATUS tg_result_get_tuple(TGresult* tg_result, 
                                List* retrieved_attrs, 
                                TupleTableSlot* tupleSlot) {
    assert(tg_result && retrieved_attrs && tupleSlot);  
    elog(DEBUG5, "tsurugi_fdw : %s", __func__);
    make_tuple_from_result_row(tg_result->impl, 
                                tupleSlot->tts_tupleDescriptor,
                                retrieved_attrs,
                                tupleSlot->tts_values,
                                tupleSlot->tts_isnull);
    ExecStoreVirtualTuple(tupleSlot);
    set_ok(tg_result->error);
    return TG_STATUS_OK;
}

/**
 *  tg_result_error_message
 */
const char* tg_result_error_message(const TGresult* tg_result) {
    assert(tg_result);
    return tg_result->error.msg.empty() ? "" : tg_result->error.msg.c_str();
}

} /* extern "C" */

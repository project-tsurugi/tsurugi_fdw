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
#include <boost/format.hpp>
#include "ogawayama/stub/api.h"
#include "ogawayama/stub/error_code.h"
#include "tg_common/tsurugi.h"

#ifdef __cplusplus
extern "C" {
#endif
#include "postgres.h"
#include "tg_common/tsurugi_api.h"
#include "foreign/foreign.h"
#ifdef __cplusplus
}
#endif

using namespace ogawayama;

/** ===========================================================================
 *  
 *  
 * 
 */
const char* tg_error_message() {
    return Tsurugi::tsurugi().get_error_message().data();
}

bool tg_do_connect(Oid server_oid) {
    auto error = Tsurugi::tsurugi().init(server_oid);
    return (error == ERROR_CODE::OK) ? true : false;
}

bool tg_do_begin(Oid server_oid) {
    auto error = Tsurugi::tsurugi().start_transaction(server_oid);
    return (error == ERROR_CODE::OK) ? true : false;
}

bool tg_do_commit() {
    auto error = Tsurugi::tsurugi().commit();
    return (error == ERROR_CODE::OK) ? true : false;
}

bool tg_do_rollback() {
    auto error = Tsurugi::tsurugi().rollback();
    return (error == ERROR_CODE::OK) ? true : false;
}

/** ===========================================================================
 * 
 *  
 * 
 */
#if 0
struct ErrorState {
    std::string last_msg;
    TG_STATUS last_code = TG_STATUS_OK;
};

struct TGconn { 
    ConnectionPtr impl;
    ErrorState error;
    static StubPtr db;
    std::string db_name;
    Oid server_oid;
};
StubPtr TGconn::db = nullptr;

struct TGtx { 
    TransactionPtr impl;
    ErrorState error;
    TGconn* conn;
};

struct TGstmt { 
    std::unique_ptr<stub::PreparedStatement> impl; 
    ErrorState error;
    bool in_use = false; 
};

struct TGresult { 
    std::unique_ptr<stub::ResultSet> impl; 
    ErrorState error;
};

/** ===========================================================================
 * 
 *  Error Functions.
 * 
 */
namespace detail {
inline void set_ok(ErrorState& e) {
    e.last_msg.clear();
    e.last_code = TG_STATUS_OK;
}

inline void set_error(ErrorState& e, std::string_view msg, 
        const TG_STATUS code = TG_STATUS_TSURUGI_ERROR) {
    e.last_msg = msg;
    e.last_code = code;
}

inline TG_STATUS set_exception(ErrorState& e, const std::exception& ex,
        const TG_STATUS code = TG_STATUS_ERROR) {
    e.last_msg = ex.what();
    e.last_code = code;
    return code;
}
} // namespace detail

/**
 *  @brief 	Output error log which has a error message and error code.
 *  @param 	(level) log level.
 * 			(message) error message.
 * 			(error) error code of ogawayama.
 *  @return	none.
 */
static void log2(const int level, std::string_view message, const ERROR_CODE error) {
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
static std::string get_detail_message(const TGconn* conn, const ERROR_CODE error_code) {
	std::string message = "No detail message.";

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	if (error_code != ERROR_CODE::SERVER_ERROR)
	{
		log2(LOG, "Error code is not SERVER_ERROR.", error_code);
		return message;
	}

	if (conn->impl == nullptr)
	{
		elog(DEBUG1, "tsurugi_fdw : There is no connection to Tsurugi.");
		return message;
	}

	//  get detail message from Tsurugi.
	stub::tsurugi_error_code error{};
	auto ret_code = conn->impl->tsurugi_error(error);
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
 *  @brief 	Get error message.
 *  @param 	(conn) pointer to TGconn.
 *          (message) error message.
 * 			(error) error code.
 * 			(sql) the statement that was attempted to be sent to tsurugidb.
 *  @return	none.
 */
static std::string get_error_message(TGconn* conn, std::string_view message, 
        ERROR_CODE error, const char* sql = nullptr) {
    std::string detail = get_detail_message(conn, error);
	std::ostringstream err_msg;
	err_msg << "Failed to execute remote SQL.\n" 
			<< "SQL query: " << sql << "\n"
			<< message << "error: " << stub::error_name(error).data() 
			<< "(" << (int) error << ")\n" << detail.data();
    return err_msg.str();
}

extern "C" {

/** ===========================================================================
 * 
 *  Connection Functions.
 * 
 */
const char*	tg_conn_last_error_message(const TGconn* conn) {
    if (!conn) return nullptr;
    return conn->error.last_msg.empty() ? "No detail message." 
                                        : conn->error.last_msg.c_str();
}

bool tg_conn_is_connect(const TGconn* conn) {
 	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	/* Check if it is not connected. */
	if ((!conn->db) || (!conn->impl)) {
		elog(DEBUG4, "No connection to Tsurugi.");
		return false;
	}

	/* Get ForeignServer object from server OID. */
	auto server = GetForeignServer(conn->server_oid);
	assert(server != nullptr);

	elog(DEBUG3, "Already connected to the Tsurugi database. (server: %s, db: %s)", 
            server->servername, conn->db_name.c_str());
	return true;   
}

TGconn* tg_conn_new(Oid server_oid, const char* db_name) {
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);

    if (server_oid == InvalidOid) return nullptr;
    if (!db_name) return nullptr;
    TGconn* conn = new (std::nothrow) TGconn;
    if (!conn) return nullptr;
    try {
        conn->db = nullptr;
        auto error = make_stub(conn->db, db_name);
        if (error != ERROR_CODE::OK) {
            return nullptr;
        }
        conn->db_name = db_name;
        conn->server_oid = server_oid;
        detail::set_ok(conn->error);
        return conn;
    } catch (const std::exception& e) {
        delete conn;
        return nullptr;
    }
}

TG_STATUS tg_conn_connect(TGconn* conn) {
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);

    if (!conn || !conn->db) return TG_STATUS_INVALID_ARG;
    try {
        auto error = conn->db->get_connection(getpid(), conn->impl);
        if (error != ERROR_CODE::OK) {
            detail::set_error(conn->error, 
                    get_error_message(conn, 
                            "Failed to connect to Tsurugi database.", error));
            return TG_STATUS_TSURUGI_ERROR;
        }
        detail::set_ok(conn->error); 
        return TG_STATUS_OK; 
    } catch (const std::exception& e) { 
        return detail::set_exception(conn->error, e); 
    }
}

void tg_conn_close(TGconn* conn) {
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);

    if (conn && conn->impl) conn->impl = nullptr;
}

void tg_conn_free(TGconn* conn) {
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);

    if (!conn) return;
    conn->impl = nullptr;
    conn->db = nullptr;
    delete conn;
}

/** ===========================================================================
 * 
 *  Transaction Functions.
 * 
 */
const char*	tg_tx_last_error_message(const TGtx* tx) {
    if (!tx) return nullptr;
    return tx->error.last_msg.empty() ? "" : tx->error.last_msg.c_str();
}

bool tg_tx_is_active(const TGtx* tx) {
    if (!tx || !tx->impl || tg_conn_is_connect(tx->conn)) return false;
    return true;
}

TGtx* tg_tx_new(TGconn* conn) {
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);

    if (!conn || !conn->db || !conn->impl) return nullptr;
    TGtx* tx = new (std::nothrow) TGtx;
    if (!tx) return nullptr;      
    detail::set_ok(conn->error);
    return tx;
}

TG_STATUS tg_tx_begin(TGtx* tx) {
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);

    if (!tx || !tg_conn_is_connect(tx->conn) || tg_tx_is_active(tx)) 
            return TG_STATUS_INVALID_ARG;
    try {
       	boost::property_tree::ptree option;
        auto error = tx->conn->impl->begin(option, tx->impl);
        if (error != ERROR_CODE::OK) {
            detail::set_error(tx->error, "Failed to start transaction.");
            return TG_STATUS_TSURUGI_ERROR; 
        }
        detail::set_ok(tx->error); 
        return TG_STATUS_OK; 
    } catch (const std::exception& e) { 
        return detail::set_exception(tx->error, e); 
    }
}

TG_STATUS tg_tx_execute_statement(TGtx* tx, const char* sql, size_t* num_rows) {
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);

    if (!tg_tx_is_active(tx) || !sql || !num_rows)
            return TG_STATUS_INVALID_ARG;
    try {
        auto error = tx->impl->execute_statement(sql, *num_rows);
        if (error != ERROR_CODE::OK) {
            auto msg = get_error_message(tx->conn, 
                    "Failed to execute a statement.", error, sql);
            detail::set_error(tx->error, msg);
            return TG_STATUS_TSURUGI_ERROR; 
        }
        detail::set_ok(tx->error); 
        return TG_STATUS_OK; 
    } catch (const std::exception& e) { 
        return detail::set_exception(tx->error, e); 
    }
}

TG_STATUS tg_tx_commit(TGtx* tx) {
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);

    if (!tg_tx_is_active(tx)) return TG_STATUS_INVALID_ARG;
    try {
        auto error = tx->impl->commit();
        if (error != ERROR_CODE::OK) {
            auto msg = get_error_message(tx->conn, 
                    "Failed to commit the transaction.", error);
            detail::set_error(tx->error, msg);
            return TG_STATUS_TSURUGI_ERROR; 
        }
        tx->impl = nullptr;
        detail::set_ok(tx->error);
        return TG_STATUS_OK; 
    } catch (const std::exception& e) {
        return detail::set_exception(tx->error, e);
    }
}

TG_STATUS tg_tx_rollback(TGtx* tx) {
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);

    if (!tg_tx_is_active(tx)) return TG_STATUS_INVALID_ARG;
    try {
        auto error = tx->impl->rollback();
        if (error != ERROR_CODE::OK) {
            auto msg = get_error_message(tx->conn, 
                    "Failed to rollback the transaction.", error);
            detail::set_error(tx->error, msg);
            return TG_STATUS_TSURUGI_ERROR; 
        }
        tx->impl = nullptr;
        detail::set_ok(tx->error);
        return TG_STATUS_OK; 
    } catch (const std::exception& e) {
        return detail::set_exception(tx->error, e);
    }
}

void tg_tx_free(TGtx* tx) {
    if (!tx) return;
    if (tx->impl) tg_tx_rollback(tx);
    tx->impl = nullptr;
    delete tx;
}

void tg_do_begin(TGconn* conn) {
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);

    TGtx* tx = tg_tx_new(conn);
    if (!tx) 
        elog(ERROR, "Failed to create Tsurugi transaction handle.");
    
    TG_STATUS tg_status = tg_tx_begin(tx);
    tg_tx_free(tx);
    if (tg_status != TG_STATUS_OK) 
        elog(ERROR, "Failed to begin Tsurugi transaction. (%d)\n%s", 
                (int) tg_status, tg_tx_last_error_message(tx));
}

void tg_do_sql_command(TGconn* conn, const char *sql, size_t *num_tuples) {
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);

    TGtx* tx = tg_tx_new(conn);
    if (!tx) 
        elog(ERROR, "Failed to create Tsurugi transaction handle.");

    TG_STATUS tg_status = tg_tx_execute_statement(tx, sql, num_tuples);
    tg_tx_free(tx);
    if (tg_status != TG_STATUS_OK) 
        elog(ERROR, "Failed to execute the statement. (%d)\n%s", 
                (int) tg_status, tg_tx_last_error_message(tx));
}

void tg_do_commit(TGconn* conn) {
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);

    TGtx* tx = tg_tx_new(conn);
    if (!tx) 
        elog(ERROR, "Failed to create Tsurugi transaction handle.");
    
    TG_STATUS tg_status = tg_tx_commit(tx);
    tg_tx_free(tx);
    if (tg_status != TG_STATUS_OK) 
        elog(ERROR, "Failed to commit Tsurugi transaction. (%d)\n%s", 
                (int) tg_status, tg_tx_last_error_message(tx));
}

void tg_do_rollback(TGconn* conn) {
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);

    TGtx* tx = tg_tx_new(conn);
    if (!tx)
        elog(ERROR, "Failed to create Tsurugi transaction handle.");

    TG_STATUS tg_status = tg_tx_rollback(tx);
    tg_tx_free(tx);
    if (tg_status != TG_STATUS_OK) 
        elog(ERROR, "Failed to rollback Tsurugi transaction. (%d)\n%s", 
                (int) tg_status, tg_tx_last_error_message(tx));
}
#endif

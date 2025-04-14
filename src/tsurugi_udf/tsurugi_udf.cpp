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
 * Portions Copyright (c) 1996-2023, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, The Regents of the University of California
 *
 *	@file	tsurugi_udf.cpp
 *	@brief	Tsurugi User-Defined Functions.
 */

#include <boost/foreach.hpp>
#include <boost/property_tree/ptree.hpp>
#define BOOST_BIND_GLOBAL_PLACEHOLDERS
#include <boost/property_tree/json_parser.hpp>
#include <iostream>
#include <algorithm>
#include <map>
#include <regex>
#include <string>
#include <unordered_map>
#include <utility>
#include <vector>

#include "ogawayama/stub/transaction_option.h"
#include "manager/metadata/metadata_factory.h"
#include "tg_common.h"
#include "tsurugi.h"

#ifdef __cplusplus
extern "C" {
#endif

#include "postgres.h"
#include "fmgr.h"
#include "catalog/pg_type.h"	// TEXTOID
#include "utils/array.h"		// ArrayType
#include "utils/builtins.h"		// text_to_cstring
#include "access/genam.h"
#include "access/heapam.h"
#include "catalog/namespace.h"
#include "catalog/pg_foreign_server.h"
#include "catalog/pg_foreign_table.h"
#include "utils/fmgroids.h"
#include "utils/lsyscache.h"
#include "utils/syscache.h"

PG_FUNCTION_INFO_V1(tg_set_transaction);
PG_FUNCTION_INFO_V1(tg_set_write_preserve);
PG_FUNCTION_INFO_V1(tg_set_inclusive_read_areas);
PG_FUNCTION_INFO_V1(tg_set_exclusive_read_areas);
PG_FUNCTION_INFO_V1(tg_show_transaction);
PG_FUNCTION_INFO_V1(tg_show_tables);
PG_FUNCTION_INFO_V1(tg_verify_tables);

#ifdef __cplusplus
}
#endif

static constexpr const char* const TYPE_SHORT = "short";
static constexpr const char* const TYPE_SHORT_OCC = "OCC";
static constexpr const char* const TYPE_SHORT_STX = "STX";
static constexpr const char* const TYPE_LONG = "long";
static constexpr const char* const TYPE_LONG_PCC = "PCC";
static constexpr const char* const TYPE_LONG_LTX = "LTX";
static constexpr const char* const TYPE_READ_ONLY = "read_only";
static constexpr const char* const TYPE_READ_ONLY_READ = "read";
static constexpr const char* const TYPE_READ_ONLY_RO = "RO";
static constexpr const char* const TYPE_READ_ONLY_RTX = "RTX";
static constexpr const char* const TYPE_DEFAULT = "default";

static constexpr const char* const PRIORITY_INTERRUPT = "interrupt";
static constexpr const char* const PRIORITY_WAIT = "wait";
static constexpr const char* const PRIORITY_INTERRUPT_EXCLUDE = "interrupt_exclude";
static constexpr const char* const PRIORITY_WAIT_EXCLUDE = "wait_exclude";
static constexpr const char* const PRIORITY_DEFAULT = "default";

static constexpr const char* const LABEL_DEFAULT = "pgsql-transaction";

static int64_t type = ogawayama::stub::TransactionType::SHORT;
static int64_t priority = ogawayama::stub::TransactionPriority::TRANSACTION_PRIORITY_UNSPECIFIED;
static std::string label = LABEL_DEFAULT;
static std::vector<std::string> write_preserve;
static std::vector<std::string> inclusive_read_areas;
static std::vector<std::string> exclusive_read_areas;

static bool specific_transaction = false;
static bool transaction_block = false;

static int64_t save_type;
static int64_t save_priority;
static std::string save_label;
static std::vector<std::string> save_write_preserve;
static std::vector<std::string> save_inclusive_read_areas;
static std::vector<std::string> save_exclusive_read_areas;

class JsonBuilder {
 public:
	explicit JsonBuilder() :
		root_(""), numeric_keys_({}), array_keys_({}) {}

	/**
	 * @brief Add the node to the root object.
	 * @param key [in] key name.
	 * @param child [in] child object.
	*/
	void add_child(const std::string& key, const boost::property_tree::ptree& child) {
		root_.add_child(key, child);
	}

	/**
	 * @brief Converts the value of a numeric item from a string to a number.
	 * @param key [in] key name.
	 * @return JsonBuilder object.
	*/
	JsonBuilder& convert_num(const std::string& key) {
		numeric_keys_.push_back(key);
		return *this;
	}

	/**
	 * @brief Converts an empty value of an array item from an empty character to an empty array.
	 * @param key [in] key name.
	 * @return JsonBuilder object.
	*/
	JsonBuilder& convert_array(const std::string& key) {
		array_keys_.push_back(key);
		return *this;
	}

	/**
	 * @brief Return objects as strings (JSON).
	 * @param pretty [in] pretty JSON print.
	 * @return JsonBuilder object.
	*/
	std::string to_str(bool pretty) const {
		std::stringstream ss;

		/* Convert to JSON. */
		try {
			boost::property_tree::json_parser::write_json(ss, root_, pretty);
		} catch (const std::exception& e) {
			ereport(ERROR, (errcode(ERRCODE_FDW_ERROR), errmsg("JSON parser error"),
							errdetail("%s", e.what())));
		}
		std::string json_str(ss.str());

		/* Remove trailing newline code. */
		if (json_str.back() == '\n') {
			json_str.erase(json_str.size() - 1);
		}

		/* Converts the value of a numeric item from a string to a number. */
		std::string separator = (pretty ? " " : "");
		for (const auto& key : numeric_keys_) {
			auto pattern_num = (boost::format(R"_("%s":\s*"(\d+)")_") % key).str();
			auto replace_num = (boost::format(R"("%s":%s$1)") % key % separator).str();
			json_str = std::regex_replace(json_str, std::regex(pattern_num), replace_num);
		}

		/* Converts an empty value of an array item from an empty character to an empty array. */
		for (const auto& key : array_keys_) {
			auto pattern_array = (boost::format(R"("%s":\s*"")") % key).str();
			auto replace_array = (boost::format(R"("%s":%s[])") % key % separator).str();
			json_str = std::regex_replace(json_str, std::regex(pattern_array), replace_array);
		}

		return json_str;
	}

 private:
	boost::property_tree::ptree root_;
	std::vector<std::string> numeric_keys_;
	std::vector<std::string> array_keys_;
};

/**
 * @brief Save current transaction options.
 */
void
SaveTransactionOption()
{
	save_type = type;
	save_priority = priority;
	save_label = label;
	save_write_preserve = write_preserve;
	save_inclusive_read_areas = inclusive_read_areas;
	save_exclusive_read_areas = exclusive_read_areas;
}

/**
 * @brief Load current transaction options.
 */
void
LoadTransactionOption()
{
	type = save_type;
	priority = save_priority;
	label = save_label;
	write_preserve = save_write_preserve;
	inclusive_read_areas = save_inclusive_read_areas;
	exclusive_read_areas = save_exclusive_read_areas;
}

/**
 * @brief Convert text array to list of strings.
 * @param textArray [in] text array.
 * @return list of strings.
 */
List*
TextArrayToStringList(ArrayType* textArray)
{
	Datum* elems;
	bool* nulls;
	int nelems;
	List* list = NIL;
	deconstruct_array(textArray, TEXTOID, -1, false, 'i',
					  &elems, &nulls, &nelems);
	for (int i = 0; i < nelems; i++)
	{
		if (nulls[i])
			ereport(ERROR,
					(errcode(ERRCODE_INVALID_PARAMETER_VALUE),
					 errmsg("Table lists may not contain nulls.")));
		list = lappend(list, makeString(TextDatumGetCString(elems[i])));
	}
	return list;
}

/**
 * @brief Convert transaction to json char strings.
 * @param transaction [in] transaction of ptree type.
 * @return json char strings.
 */
char*
TransactionToJsonCharString(boost::property_tree::ptree& transaction)
{
	std::stringstream ssJson;
	boost::property_tree::write_json(ssJson, transaction);
	std::string strTransaction = ssJson.str();
	int resSize = strTransaction.size() + 1;
	char* charResult = (char *) palloc(resSize);
	snprintf(charResult, resSize, "%s", strTransaction.c_str());
	return charResult;
}

/**
 * @brief Get current transaction options.
 * @param column [in/out] transaction option.
 * @return true if success, otherwise fault.
 */
void
GetTransactionOption(boost::property_tree::ptree& transaction)
{
	boost::property_tree::ptree pt_write_preserve;
	boost::property_tree::ptree pt_inclusive_read_areas;
	boost::property_tree::ptree pt_exclusive_read_areas;
	boost::property_tree::ptree pt_tables;

	transaction.clear();
	transaction.put<int64_t>(ogawayama::stub::TRANSACTION_TYPE, type);
	transaction.put<int64_t>(ogawayama::stub::TRANSACTION_PRIORITY, priority);
	transaction.put<std::string>(ogawayama::stub::TRANSACTION_LABEL, label);
	if (write_preserve.size()) {
		for (std::string prev_table : write_preserve) {
			pt_tables.put<std::string>(ogawayama::stub::TABLE_NAME, prev_table);
			pt_write_preserve.push_back(std::make_pair("", pt_tables));
		}
	}
	transaction.add_child(ogawayama::stub::WRITE_PRESERVE, pt_write_preserve);
	if (inclusive_read_areas.size()) {
		for (std::string prev_table : inclusive_read_areas) {
			pt_tables.put<std::string>(ogawayama::stub::TABLE_NAME, prev_table);
			pt_inclusive_read_areas.push_back(std::make_pair("", pt_tables));
		}
	}
	transaction.add_child(ogawayama::stub::INCLUSIVE_READ_AREA, pt_inclusive_read_areas);
	if (exclusive_read_areas.size()) {
		for (std::string prev_table : exclusive_read_areas) {
			pt_tables.put<std::string>(ogawayama::stub::TABLE_NAME, prev_table);
			pt_exclusive_read_areas.push_back(std::make_pair("", pt_tables));
		}
	}
	transaction.add_child(ogawayama::stub::EXCLUSIVE_READ_AREA, pt_exclusive_read_areas);
}

bool
IsTransactionProgress()
{
	return transaction_block;
}

/**
 * @brief Set current transaction options.
 * @param TransactionType [in] transaction type.
 * @param TransactionPriority [in] transaction priority.
 * @param TransactionLabel [in] transaction label.
 * @return If you call ereport, the call will not return and
 *         PostgreSQL will report the error information.
 */
void
SetTransactionOption(char* TransactionType, char* TransactionPriority, char* TransactionLabel)
{
	if (TransactionType != nullptr) {
		if (strcasecmp(TransactionType, TYPE_SHORT) == 0 ||
				strcasecmp(TransactionType, TYPE_SHORT_OCC) == 0 ||
				strcasecmp(TransactionType, TYPE_SHORT_STX) == 0) {
			type = ogawayama::stub::TransactionType::SHORT;
		} else if (strcasecmp(TransactionType, TYPE_LONG) == 0 ||
					strcasecmp(TransactionType, TYPE_LONG_PCC) == 0 ||
					strcasecmp(TransactionType, TYPE_LONG_LTX) == 0) {
			type = ogawayama::stub::TransactionType::LONG;
		} else if (strcasecmp(TransactionType, TYPE_READ_ONLY) == 0 ||
					strcasecmp(TransactionType, TYPE_READ_ONLY_READ) == 0 ||
					strcasecmp(TransactionType, TYPE_READ_ONLY_RO) == 0 ||
					strcasecmp(TransactionType, TYPE_READ_ONLY_RTX) == 0) {
			type = ogawayama::stub::TransactionType::READ_ONLY;
		} else {
			type = ogawayama::stub::TransactionType::TRANSACTION_TYPE_UNSPECIFIED;
		}
	}

	if (TransactionPriority != nullptr) {
		if (strcasecmp(TransactionPriority, PRIORITY_INTERRUPT) == 0) {
			priority = ogawayama::stub::TransactionPriority::INTERRUPT;
		} else if (strcasecmp(TransactionPriority, PRIORITY_WAIT) == 0) {
			priority = ogawayama::stub::TransactionPriority::WAIT;
		} else if (strcasecmp(TransactionPriority, PRIORITY_INTERRUPT_EXCLUDE) == 0) {
			priority = ogawayama::stub::TransactionPriority::INTERRUPT_EXCLUDE;
		} else if (strcasecmp(TransactionPriority, PRIORITY_WAIT_EXCLUDE) == 0) {
			priority = ogawayama::stub::TransactionPriority::WAIT_EXCLUDE;
		} else {
			priority = ogawayama::stub::TransactionPriority::TRANSACTION_PRIORITY_UNSPECIFIED;
		}
	}

	if (TransactionLabel != nullptr) {
		label = TransactionLabel;
	} else {
		label = LABEL_DEFAULT;
	}

	if (type != ogawayama::stub::TransactionType::LONG) {
		write_preserve.clear();
		inclusive_read_areas.clear();
		exclusive_read_areas.clear();
	}
}

/**
 * @brief Set current write preserve tables options.
 * @param WritePreserveTables [in] list of write preserve tables.
 * @return If you call ereport, the call will not return and
 *         PostgreSQL will report the error information.
 */
void
SetWritePreserveTables(List* WritePreserveTables)
{
	assert(WritePreserveTables != NIL);

	write_preserve.clear();
	ListCell* listptr;
	foreach(listptr, WritePreserveTables) {
		Node* node = (Node *) lfirst(listptr);
		if (IsA(node, String)) {
			Value* table = (Value*) node;
			write_preserve.emplace_back(strVal(table));
		}
	}
}

/**
 * @brief Set current inclusive read areas tables options.
 * @param InclusiveReadAreasTables [in] list of inclusive read areas tables.
 * @return If you call ereport, the call will not return and
 *         PostgreSQL will report the error information.
 */
void
SetInclusiveReadAreasTables(List* InclusiveReadAreasTables)
{
	assert(InclusiveReadAreasTables != NIL);

	inclusive_read_areas.clear();
	ListCell* listptr;
	foreach(listptr, InclusiveReadAreasTables) {
		Node* node = (Node *) lfirst(listptr);
		if (IsA(node, String)) {
			Value* table = (Value*) node;
			inclusive_read_areas.emplace_back(strVal(table));
		}
	}
}

/**
 * @brief Set current exclusive read areas tables options.
 * @param ExclusiveReadAreasTables [in] list of exclusive read areas tables.
 * @return If you call ereport, the call will not return and
 *         PostgreSQL will report the error information.
 */
void
SetExclusiveReadAreasTables(List* ExclusiveReadAreasTables)
{
	assert(ExclusiveReadAreasTables != NIL);

	exclusive_read_areas.clear();
	ListCell* listptr;
	foreach(listptr, ExclusiveReadAreasTables) {
		Node* node = (Node *) lfirst(listptr);
		if (IsA(node, String)) {
			Value* table = (Value*) node;
			exclusive_read_areas.emplace_back(strVal(table));
		}
	}
}

/**
 * @brief Check the arguments of tg_set_transaction.
 * @param TransactionType [in] transaction type.
 * @param TransactionPriority [in] transaction priority.
 * @param TransactionLabel [in] transaction label.
 * @return If you call ereport, the call will not return and
 *         PostgreSQL will report the error information.
 */
void
CheckTransactionArgs(char* TransactionType, char* TransactionPriority, char* TransactionLabel)
{
	if (TransactionType != nullptr) {
		if (strcasecmp(TransactionType, TYPE_SHORT) != 0 &&
				strcasecmp(TransactionType, TYPE_SHORT_OCC) != 0 &&
				strcasecmp(TransactionType, TYPE_SHORT_STX) != 0 &&
				strcasecmp(TransactionType, TYPE_LONG) != 0 &&
				strcasecmp(TransactionType, TYPE_LONG_PCC) != 0 &&
				strcasecmp(TransactionType, TYPE_LONG_LTX) != 0 &&
				strcasecmp(TransactionType, TYPE_READ_ONLY) != 0 &&
				strcasecmp(TransactionType, TYPE_READ_ONLY_READ) != 0 &&
				strcasecmp(TransactionType, TYPE_READ_ONLY_RO) != 0 &&
				strcasecmp(TransactionType, TYPE_READ_ONLY_RTX) != 0 &&
				strcasecmp(TransactionType, TYPE_DEFAULT) != 0) {
			ereport(ERROR,
					(errcode(ERRCODE_INTERNAL_ERROR),
					errmsg("Invalid Transaction Type parameter. (type: %s)",
					TransactionType)));
		}
	}

	if (TransactionPriority != nullptr) {
		if (strcasecmp(TransactionPriority, PRIORITY_INTERRUPT) != 0 &&
				strcasecmp(TransactionPriority, PRIORITY_WAIT) != 0 &&
				strcasecmp(TransactionPriority, PRIORITY_INTERRUPT_EXCLUDE) != 0 &&
				strcasecmp(TransactionPriority, PRIORITY_WAIT_EXCLUDE) != 0 &&
				strcasecmp(TransactionPriority, PRIORITY_DEFAULT) != 0) {
			ereport(ERROR,
					(errcode(ERRCODE_INTERNAL_ERROR),
					errmsg("Invalid Transaction Priority parameter. (priority: %s)",
					TransactionPriority)));
		}
	}

	if (TransactionLabel != nullptr) {
		if (strlen(TransactionLabel) == 0) {
			ereport(ERROR,
					(errcode(ERRCODE_INTERNAL_ERROR),
					errmsg("Invalid Transaction Label parameter. (label: empty)")));
		}
	}
}

Datum
tg_set_transaction(PG_FUNCTION_ARGS)
{
	char* TransactionType = nullptr;
	char* TransactionPriority = nullptr;
	char* TransactionLabel = nullptr;
	boost::property_tree::ptree transaction;

	if (PG_NARGS() == 1) {
		text* type = PG_GETARG_TEXT_PP(0);
		TransactionType = text_to_cstring(type);
	} else if (PG_NARGS() == 2) {
		text* type = PG_GETARG_TEXT_PP(0);
		text* priority = PG_GETARG_TEXT_PP(1);
		TransactionType = text_to_cstring(type);
		TransactionPriority = text_to_cstring(priority);
	} else if (PG_NARGS() == 3) {
		text* type = PG_GETARG_TEXT_PP(0);
		text* priority = PG_GETARG_TEXT_PP(1);
		text* label = PG_GETARG_TEXT_PP(2);
		TransactionType = text_to_cstring(type);
		TransactionPriority = text_to_cstring(priority);
		TransactionLabel = text_to_cstring(label);
	} else {
		ereport(ERROR,
			(errcode(ERRCODE_INVALID_PARAMETER_VALUE),
			 errmsg("Invalid number of parameters.")));
	}

	CheckTransactionArgs(TransactionType, TransactionPriority, TransactionLabel);

	SetTransactionOption(TransactionType, TransactionPriority, TransactionLabel);

	GetTransactionOption(transaction);
	PG_RETURN_CSTRING(TransactionToJsonCharString(transaction));
}

Datum
tg_set_write_preserve(PG_FUNCTION_ARGS)
{
	List* WritePreserveTables = NIL;
	boost::property_tree::ptree transaction;

	if (PG_NARGS() == 1) {
		ArrayType* tables = PG_GETARG_ARRAYTYPE_P(0);
		WritePreserveTables = TextArrayToStringList(tables);
	} else {
		ereport(ERROR,
			(errcode(ERRCODE_INVALID_PARAMETER_VALUE),
			 errmsg("Invalid number of parameters.")));
	}

	SetWritePreserveTables(WritePreserveTables);

	GetTransactionOption(transaction);
	PG_RETURN_CSTRING(TransactionToJsonCharString(transaction));
}

Datum
tg_set_inclusive_read_areas(PG_FUNCTION_ARGS)
{
	List* InclusiveReadAreasTables = NIL;
	boost::property_tree::ptree transaction;

	if (PG_NARGS() == 1) {
		ArrayType* tables = PG_GETARG_ARRAYTYPE_P(0);
		InclusiveReadAreasTables = TextArrayToStringList(tables);
	} else {
		ereport(ERROR,
			(errcode(ERRCODE_INVALID_PARAMETER_VALUE),
			 errmsg("Invalid number of parameters.")));
	}

	SetInclusiveReadAreasTables(InclusiveReadAreasTables);

	GetTransactionOption(transaction);
	PG_RETURN_CSTRING(TransactionToJsonCharString(transaction));
}

Datum
tg_set_exclusive_read_areas(PG_FUNCTION_ARGS)
{
	List* ExclusiveReadAreasTables = NIL;
	boost::property_tree::ptree transaction;

	if (PG_NARGS() == 1) {
		ArrayType* tables = PG_GETARG_ARRAYTYPE_P(0);
		ExclusiveReadAreasTables = TextArrayToStringList(tables);
	} else {
		ereport(ERROR,
			(errcode(ERRCODE_INVALID_PARAMETER_VALUE),
			 errmsg("Invalid number of parameters.")));
	}

	SetExclusiveReadAreasTables(ExclusiveReadAreasTables);

	GetTransactionOption(transaction);
	PG_RETURN_CSTRING(TransactionToJsonCharString(transaction));
}

Datum
tg_show_transaction(PG_FUNCTION_ARGS)
{
	boost::property_tree::ptree transaction;

	if (PG_NARGS() != 0) {
		ereport(ERROR,
			(errcode(ERRCODE_INVALID_PARAMETER_VALUE),
			 errmsg("Invalid number of parameters.")));
	}

	if (specific_transaction) {
		elog(INFO, "there is a specific tsurugi transaction block is in progress.");
	}

	GetTransactionOption(transaction);
	PG_RETURN_CSTRING(TransactionToJsonCharString(transaction));
}

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

	/* Get the Tsurugi server OID. */
	HeapTuple srv_tuple =
		SearchSysCache1(FOREIGNSERVERNAME, CStringGetDatum(arg_server_name.c_str()));
	if (!HeapTupleIsValid(srv_tuple)) {
		ereport(ERROR,
			(errcode(ERRCODE_FDW_UNABLE_TO_ESTABLISH_CONNECTION),
			errmsg(R"(server "%s" does not exist)", arg_server_name.c_str())));
	}
	ReleaseSysCache(srv_tuple);

	std::stringstream pretty;
	pretty << std::boolalpha << arg_pretty;
	elog(DEBUG5, __func__);
	elog(DEBUG5, "  remote_schema : %s", arg_remote_schema.c_str());
	elog(DEBUG5, "  server_name   : %s", arg_server_name.c_str());
	elog(DEBUG5, "  mode          : %s", arg_mode.c_str());
	elog(DEBUG5, "  pretty        : %s", pretty.str().c_str());

	ERROR_CODE error;
	TableListPtr tg_table_list;

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

	boost::property_tree::ptree remote_tables;  // <tables_on_remote_schema> object
	/* Add to table count. */
	remote_tables.put(kKeyCount, table_list.size());

	/* If the report level is 'detail', add a table listing. */
	if ((arg_mode == kArgModeDetail)) {
		/* Add to table name list. */
		remote_tables.add_child(kKeyList, table_list);
	}

	boost::property_tree::ptree remote_schema;  // <remote_schema> object
	/* Add to <remote_schema>. */
	remote_schema.put(kKeyRemoteSchema, arg_remote_schema);
	/* Add to <server_name>. */
	remote_schema.put(kKeyServerName, arg_server_name);
	/* Add to <mode>. */
	remote_schema.put(kKeyMode, arg_mode);
	/* Add to <tables_on_remote_schema> object. */
	remote_schema.add_child(kKeyRemoteTable, remote_tables);

	JsonBuilder builder;
	/* Build the root object. */
	builder.add_child(kKeyRootObject, remote_schema);
	auto json_str = builder.convert_num(kKeyCount).convert_array(kKeyList).to_str(arg_pretty);

	PG_RETURN_DATUM(DirectFunctionCall1(json_in, CStringGetDatum(json_str.c_str())));
}

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

	if (HeapTupleIsValid(srv_tuple)) {
		server_oid = ((Form_pg_foreign_server) GETSTRUCT(srv_tuple))->oid;
		ReleaseSysCache(srv_tuple);
	} else {
		ereport(ERROR,
			(errcode(ERRCODE_FDW_UNABLE_TO_ESTABLISH_CONNECTION),
			errmsg(R"(server "%s" does not exist)", arg_server_name.c_str())));
	}

	Oid local_schema_oid = InvalidOid;
	/* Verification of table definitions in remote and locus schemas. */
	local_schema_oid = get_namespace_oid(arg_local_schema.c_str(), true);
	if (!OidIsValid(local_schema_oid)) {
		ereport(ERROR,
			(errcode(ERRCODE_FDW_SCHEMA_NOT_FOUND),
			errmsg(R"(local schema "%s" does not exist)", arg_local_schema.c_str())));
	}

	std::stringstream pretty;
	pretty << std::boolalpha << arg_pretty;
	elog(DEBUG5, __func__);
	elog(DEBUG5, "  remote_schema : %s", arg_remote_schema.c_str());
	elog(DEBUG5, "  server_name   : %s", arg_server_name.c_str());
	elog(DEBUG5, "  local_schema  : %s", arg_local_schema.c_str());
	elog(DEBUG5, "  mode          : %s", arg_mode.c_str());
	elog(DEBUG5, "  pretty        : %s", pretty.str().c_str());

	ERROR_CODE error;
	TableListPtr tg_table_list;

	/* Get a list of table names from Tsurugi. */
	error = Tsurugi::get_list_tables(tg_table_list);
	if (error != ERROR_CODE::OK) {
		ereport(ERROR,
			(errcode(ERRCODE_FDW_UNABLE_TO_CREATE_REPLY),
			errmsg("Failed to retrieve table list from Tsurugi. (error: %d)",
				static_cast<int>(error)),
			errdetail("%s", Tsurugi::get_error_message(error).c_str())));
	}

	boost::property_tree::ptree list_remote;  // <tables_on_only_remote_schema> <list> array
	boost::property_tree::ptree list_local;  // <foreign_tables_on_only_local_schema> <list> array
	boost::property_tree::ptree list_altered;  // <tables_that_need_to_be_altered> <list> array
	boost::property_tree::ptree list_available;  // <available_foreign_table> <list> array

	/* Setting the key for the system catalog (pg_foreign_table). */
	ScanKeyData table_scan_key;
	ScanKeyInit(&table_scan_key, Anum_pg_foreign_table_ftserver, BTEqualStrategyNumber, F_OIDEQ,
				ObjectIdGetDatum(server_oid));

	/* Refer to the system catalog (pg_foreign_table). */
	Relation table_rel = table_open(ForeignTableRelationId, AccessShareLock);
	SysScanDesc table_scan = systable_beginscan(table_rel, 0, true, NULL, 1, &table_scan_key);

	// Metadata of foreign tables
	std::unordered_map<std::string, std::vector<std::tuple<std::string, std::string, int, int>>>
		ft_define = {};
	// List of table names
	auto table_names = tg_table_list->get_table_names();

	HeapTuple tuple;
	/* Verifies whether foreign tables in the local schema exist in the remote schema,
			and if so, retrieves metadata for the external tables. */
	while (HeapTupleIsValid(tuple = systable_getnext(table_scan))) {
		Form_pg_foreign_table ft = (Form_pg_foreign_table) GETSTRUCT(tuple);
		Oid rel_oid = ft->ftrelid;

		/* Filtering by schema (namespace). */
		if (get_rel_namespace(rel_oid) != local_schema_oid) {
			elog(DEBUG5,
					"unmatch schema id. local_schema_oid:%d, foreign_table_namespace_oid:%d",
					local_schema_oid, get_rel_namespace(rel_oid));
			continue;
		}
		char* rel_name = get_rel_name(rel_oid);
		elog(DEBUG2, R"(local schema - foreign table id:%d, name:"%s")", rel_oid, rel_name);

		/* Verify that a local foreign table exists on the remote. */
		auto it = std::find(table_names.begin(), table_names.end(), rel_name);
		if (it == table_names.end()) {
			elog(DEBUG2, R"(Tables that do not exist in the remote schema. "%s")", rel_name);

			/* Add to a table that exists only in the remote schema. */
			list_local.push_back(
				std::make_pair("", boost::property_tree::ptree(rel_name)));
			/* Exclude from metadata validation. */
			table_names.erase(std::remove(table_names.begin(), table_names.end(), rel_name),
								table_names.end());
			continue;
		}

		/* Setting the key for the system catalog (pg_attribute). */
		ScanKeyData attr_scan_key;
		ScanKeyInit(&attr_scan_key, Anum_pg_attribute_attrelid, BTEqualStrategyNumber, F_OIDEQ,
					ObjectIdGetDatum(rel_oid));

		/* Refer to the system catalog (pg_attribute). */
		Relation attr_rel = table_open(AttributeRelationId, AccessShareLock);
		TableScanDesc attr_scan = table_beginscan_catalog(attr_rel, 1, &attr_scan_key);

		/* Get column definitions (all scanned cases). */
		HeapTuple attr_tuple;
		while ((attr_tuple = heap_getnext(attr_scan, ForwardScanDirection)) != NULL) {
			Form_pg_attribute attr = (Form_pg_attribute) GETSTRUCT(attr_tuple);
			if (attr->attisdropped || (attr->attnum <= 0)) {
				continue;
			}

			/* column name */
			auto column_name = std::string(NameStr(attr->attname));

			/* data type (string) */
			auto data_type_raw = std::string(format_type_be(attr->atttypid));
			auto data_type = data_type_raw;
			std::transform(data_type_raw.begin(), data_type_raw.end(), data_type.begin(), ::tolower);

			/* precision and scale */
			int precision = -1;
			int scale = -1;
			if (attr->atttypmod != -1) {
				precision = ((attr->atttypmod - VARHDRSZ) >> 16) & 0xFFFF;
				scale = (attr->atttypmod - VARHDRSZ) & 0xFFFF;
			}

			ft_define[rel_name].emplace_back(std::make_tuple(column_name, data_type, precision, scale));
		}

		/* End of system catalog reference (pg_attribute). */
		table_endscan(attr_scan);
		table_close(attr_rel, AccessShareLock);
	}

	/* End of system catalog reference (pg_foreign_table). */
	systable_endscan(table_scan);
	table_close(table_rel, AccessShareLock);

	/* Verifies whether tables in the remote schema exist in the local schema. */
	for (auto it = table_names.begin(); it != table_names.end(); ) {
		/* Verify that a remote table exists on the local. */
		if (ft_define.find(*it) == ft_define.end()) {
			elog(DEBUG2, R"(Tables that do not exist in the local schema. "%s")", (*it).c_str());

			/* Add to a table that exists only in the remote schema. */
			list_remote.push_back(std::make_pair("", boost::property_tree::ptree(*it)));
			/* Exclude from metadata validation. */
			table_names.erase(it);

			continue;
		}
		it++;
	}

	/* Metadata Validation */
	for (const auto& table_name : table_names) {
		elog(DEBUG2, R"(Metadata Validation: table name: "%s")", table_name.c_str());

		TableMetadataPtr tg_table_metadata;
		/* Get table metadata from Tsurugi. */
		error = Tsurugi::get_table_metadata(table_name, tg_table_metadata);
		if (error != ERROR_CODE::OK) {
			ereport(ERROR,
					(errcode(ERRCODE_FDW_UNABLE_TO_CREATE_REPLY),
						errmsg("Failed to retrieve table metadata from Tsurugi. (error: %d)",
							static_cast<int>(error)),
						errdetail("%s", Tsurugi::get_error_message(error).c_str())));
		}

		/* Get table metadata from PostgreSQL. */
		const auto &pg_columns = ft_define.find(table_name)->second;
		/* Get table metadata from Tsurugi. */
		const auto &tg_columns = tg_table_metadata->columns();

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
			auto it = std::find(local_type.begin(), local_type.end(), *remote_type_pg);
			if (it == local_type.end()) {
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

	boost::property_tree::ptree verification;  // verification object

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
		boost::property_tree::ptree child;
		const auto key = object.first;
		const auto list = object.second;

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

	JsonBuilder builder;
	/* Build the root object. */
	builder.add_child(kKeyRootObject, verification);
	auto json_str = builder.convert_num(kKeyCount).convert_array(kKeyList).to_str(arg_pretty);

	PG_RETURN_DATUM(DirectFunctionCall1(json_in, CStringGetDatum(json_str.c_str())));
}

/*
 * Copyright 2023 tsurugi project.
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
 *	@file	tsurugi_udf.cpp
 *	@brief	Tsurugi User-Defined Functions.
 */

#include <boost/foreach.hpp>
#include <boost/property_tree/ptree.hpp>
#define BOOST_BIND_GLOBAL_PLACEHOLDERS
#include <boost/property_tree/json_parser.hpp>
#include <iostream>

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

PG_FUNCTION_INFO_V1(tg_set_transaction);
PG_FUNCTION_INFO_V1(tg_set_write_preserve);
PG_FUNCTION_INFO_V1(tg_show_transaction);
PG_FUNCTION_INFO_V1(tg_start_transaction);
PG_FUNCTION_INFO_V1(tg_commit);
PG_FUNCTION_INFO_V1(tg_rollback);

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

static bool specific_transaction = false;
static bool transaction_block = false;

static int64_t save_type;
static int64_t save_priority;
static std::string save_label;
static std::vector<std::string> save_write_preserve;

#if 0
ogawayama::stub::Transaction* udf_transaction = nullptr;
#endif

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
					 errmsg("Write Preserve Table lists may not contain nulls.")));
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
	} else {
		pt_tables.put<std::string>(ogawayama::stub::TABLE_NAME, "");
		pt_write_preserve.push_back(std::make_pair("", pt_tables));
	}
	transaction.add_child(ogawayama::stub::WRITE_PRESERVE, pt_write_preserve);
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
 * @brief Check the arguments of tg_set_transaction.
 * @param TransactionType [in] transaction type.
 * @param TransactionPriority [in] transaction priority.
 * @param TransactionLabel [in] transaction label.
 * @param WritePreserveTables [in] list of write preserve tables.
 * @return If you call ereport, the call will not return and
 *         PostgreSQL will report the error information.
 */
void
CheckTransactionArgs(char* TransactionType, char* TransactionPriority, char* TransactionLabel, List* WritePreserveTables)
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

	if (WritePreserveTables != NIL) {
		auto tables = manager::metadata::get_tables_ptr(TSURUGI_DB_NAME);
		ListCell* listptr;
		foreach(listptr, WritePreserveTables) {
			Node* node = (Node *) lfirst(listptr);
			if (IsA(node, String)) {
				Value* table = (Value*) node;
				if (!tables->exists(strVal(table))) {
					ereport(ERROR,
							(errcode(ERRCODE_INTERNAL_ERROR),
							errmsg("Write Preserve Table is not exist in Tsurugi. (table: %s)",
							strVal(table))));
				}
			}
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

	CheckTransactionArgs(TransactionType, TransactionPriority, TransactionLabel, NIL);

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

	CheckTransactionArgs(nullptr, nullptr, nullptr, WritePreserveTables);

	SetWritePreserveTables(WritePreserveTables);

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

Datum
tg_start_transaction(PG_FUNCTION_ARGS)
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
	} else if (PG_NARGS() != 0) {
		ereport(ERROR,
			(errcode(ERRCODE_INVALID_PARAMETER_VALUE),
			 errmsg("Invalid number of parameters.")));
	}

	if (IsTransactionProgress()) {
        elog(WARNING, "there is already a tsurugi transaction in progress");
		PG_RETURN_VOID();
	}

	if (PG_NARGS() != 0) {
		specific_transaction = true;
		CheckTransactionArgs(TransactionType, TransactionPriority, TransactionLabel, NIL);

		SaveTransactionOption();
		SetTransactionOption(TransactionType, TransactionPriority, TransactionLabel);
	} else {
		specific_transaction = false;
	}

#if 1
	Tsurugi::start_transaction();
#else
	ERROR_CODE error = Tsurugi::begin(&udf_transaction);
	if (error != ERROR_CODE::OK) 
	{
		elog(ERROR, "Connection::begin() failed. (%d)", (int) error);
	}
#endif
	transaction_block = true;

	PG_RETURN_VOID();
}

Datum
tg_commit(PG_FUNCTION_ARGS)
{
	if (PG_NARGS() != 0) {
		ereport(ERROR,
			(errcode(ERRCODE_INVALID_PARAMETER_VALUE),
			 errmsg("Invalid number of parameters.")));
	}

	transaction_block = false;
#if 1
	Tsurugi::commit();
#else
	if (udf_transaction != nullptr) {
		udf_transaction->commit();
		udf_transaction = nullptr;
		Tsurugi::end();
	} else {
		elog(WARNING, "there is no tsurugi transaction in progress");
	}
#endif

	if (specific_transaction) {
		LoadTransactionOption();
		specific_transaction = false;
	}

    PG_RETURN_VOID();
}

Datum
tg_rollback(PG_FUNCTION_ARGS)
{
	if (PG_NARGS() != 0) {
		ereport(ERROR,
			(errcode(ERRCODE_INVALID_PARAMETER_VALUE),
			 errmsg("Invalid number of parameters.")));
	}

	transaction_block = false;
#if 1
	Tsurugi::rollback();
#else
	if (udf_transaction != nullptr) {
		udf_transaction->rollback();
		udf_transaction = nullptr;
		Tsurugi::end();
	} else {
		elog(WARNING, "there is no tsurugi transaction in progress");
	}
#endif

	if (specific_transaction) {
		LoadTransactionOption();
		specific_transaction = false;
	}

    PG_RETURN_VOID();
}

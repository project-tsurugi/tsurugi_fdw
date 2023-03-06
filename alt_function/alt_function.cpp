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
 *	@file	alt_function.cpp
 *	@brief	Tsurugi User-Defined Functions.
 */

#include <boost/foreach.hpp>
#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/json_parser.hpp>
#include <iostream>

#include "ogawayama/stub/transaction_option.h"
#include "manager/metadata/metadata_factory.h"

#ifdef __cplusplus
extern "C" {
#endif

#include "postgres.h"
#include "fmgr.h"
#include "catalog/pg_type.h"	// TEXTOID
#include "utils/array.h"		// ArrayType
#include "utils/builtins.h"		// text_to_cstring

PG_FUNCTION_INFO_V1(tg_set_transaction);
PG_FUNCTION_INFO_V1(tg_show_transaction);

#ifdef __cplusplus
}
#endif

static int64_t type = ogawayama::stub::TransactionType::SHORT;
static int64_t priority = ogawayama::stub::TransactionPriority::TRANSACTION_PRIORITY_UNSPECIFIED;
static std::string label = "pgsql-transaction";
static std::vector<std::string> write_preserves;

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
bool
GetTransactionOption(boost::property_tree::ptree& transaction)
{
	bool result = false;
	boost::property_tree::ptree pt_write_preserves;
	boost::property_tree::ptree pt_table;

	transaction.clear();
	transaction.put<int64_t>(ogawayama::stub::TRANSACTION_TYPE, type);
	transaction.put<int64_t>(ogawayama::stub::TRANSACTION_PRIORITY, priority);
	transaction.put<std::string>(ogawayama::stub::TRANSACTION_LABEL, label);
	if (write_preserves.size()) {
		for (std::string prev_table : write_preserves) {
			pt_table.put<std::string>(ogawayama::stub::TABLE_NAME, prev_table);
			pt_write_preserves.push_back(std::make_pair("", pt_table));
		}
	} else {
		pt_table.put<std::string>(ogawayama::stub::TABLE_NAME, "");
		pt_write_preserves.push_back(std::make_pair("", pt_table));
	}
	transaction.add_child(ogawayama::stub::WRITE_PRESERVE, pt_write_preserves);

	result = true;
	return result;
}

/**
 * @brief Set current transaction options.
 * @param TransactionType [in] transaction type.
 * @param TransactionPriority [in] transaction priority.
 * @param TransactionLabel [in] transaction label.
 * @param WritePreserveTables [in] list of write preserve tables.
 * @return If you call ereport, the call will not return and
 *         PostgreSQL will report the error information.
 */
void
SetTransactionOption(char* TransactionType, char* TransactionPriority, char* TransactionLabel, List* WritePreserveTables)
{
	assert(TransactionType != nullptr);

	type = ogawayama::stub::TransactionType::TRANSACTION_TYPE_UNSPECIFIED;
	if (strcmp(TransactionType, "short") == 0 || strcmp(TransactionType, "OCC") == 0 || strcmp(TransactionType, "STX") == 0) {
		if (WritePreserveTables != NIL) {
			ereport(ERROR,
					(errcode(ERRCODE_INTERNAL_ERROR),
					errmsg("Invalid Write Preserve Table specified in short transaction.")));
		} else {
			type = ogawayama::stub::TransactionType::SHORT;
		}
	} else if (strcmp(TransactionType, "long") == 0 || strcmp(TransactionType, "PCC") == 0 || strcmp(TransactionType, "LTX") == 0) {
		type = ogawayama::stub::TransactionType::LONG;
	} else if (strcmp(TransactionType, "read_only") == 0 || strcmp(TransactionType, "read") == 0 || strcmp(TransactionType, "RO") == 0) {
		if (WritePreserveTables != NIL) {
			ereport(ERROR,
					(errcode(ERRCODE_INTERNAL_ERROR),
					errmsg("Invalid Write Preserve Table specified in read_only transaction.")));
		} else {
			type = ogawayama::stub::TransactionType::READ_ONLY;
			write_preserves.clear();
		}
	}

	priority = ogawayama::stub::TransactionPriority::TRANSACTION_PRIORITY_UNSPECIFIED;
	if (TransactionPriority != nullptr) {
		if (strcmp(TransactionPriority, "interrupt") == 0) {
			priority = ogawayama::stub::TransactionPriority::INTERRUPT;
		} else if (strcmp(TransactionPriority, "wait") == 0) {
			priority = ogawayama::stub::TransactionPriority::WAIT;
		} else if (strcmp(TransactionPriority, "interrupt_exclude") == 0) {
			priority = ogawayama::stub::TransactionPriority::INTERRUPT_EXCLUDE;
		} else if (strcmp(TransactionPriority, "wait_exclude") == 0) {
			priority = ogawayama::stub::TransactionPriority::WAIT_EXCLUDE;
		}
	}

	label = "pgsql-transaction";
	if (TransactionLabel != nullptr) {
		label = TransactionLabel;
	}

	write_preserves.clear();
	if (WritePreserveTables != NIL) {
		ListCell* listptr;
		foreach(listptr, WritePreserveTables) {
			Node* node = (Node *) lfirst(listptr);
			if (IsA(node, String)) {
				Value* write_preserve = (Value*) node;
				write_preserves.emplace_back(strVal(write_preserve));
			}
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
	assert(TransactionType != nullptr);

	if (strcmp(TransactionType, "short") != 0 && strcmp(TransactionType, "OCC") != 0 && strcmp(TransactionType, "STX") != 0 &&
		strcmp(TransactionType, "long") != 0 && strcmp(TransactionType, "PCC") != 0 && strcmp(TransactionType, "LTX") != 0 &&
		strcmp(TransactionType, "read_only") != 0 && strcmp(TransactionType, "read") != 0 && strcmp(TransactionType, "RO") != 0 &&
		strcmp(TransactionType, "default") != 0) {
		ereport(ERROR,
				(errcode(ERRCODE_INTERNAL_ERROR),
				errmsg("Invalid Transaction Type parameter. (type: %s)",
				TransactionType)));
	}

	if (TransactionPriority != nullptr) {
		if (strcmp(TransactionPriority, "interrupt") != 0 && strcmp(TransactionPriority, "wait") != 0 &&
			strcmp(TransactionPriority, "interrupt_exclude") != 0 && strcmp(TransactionPriority, "wait_exclude") != 0 &&
			strcmp(TransactionPriority, "default") != 0) {
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
		auto tables = manager::metadata::get_tables_ptr("Tsurugi");
		ListCell* listptr;
		foreach(listptr, WritePreserveTables) {
			Node* node = (Node *) lfirst(listptr);
			if (IsA(node, String)) {
				Value* write_preserve = (Value*) node;
				if (!tables->exists(strVal(write_preserve))) {
					ereport(ERROR,
							(errcode(ERRCODE_INTERNAL_ERROR),
							errmsg("Write Preserve Table is not exist in Tsurugi. (table: %s)",
							strVal(write_preserve))));
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
	List* WritePreserveTables = NIL;
	boost::property_tree::ptree transaction;

	if (PG_NARGS() == 1) {
		text* type = PG_GETARG_TEXT_PP(0);
		TransactionType = text_to_cstring(type);
	} else if (PG_NARGS() == 3) {
		text* type = PG_GETARG_TEXT_PP(0);
		text* priority = PG_GETARG_TEXT_PP(1);
		text* label = PG_GETARG_TEXT_PP(2);
		TransactionType = text_to_cstring(type);
		TransactionPriority = text_to_cstring(priority);
		TransactionLabel = text_to_cstring(label);
	} else if (PG_NARGS() == 4) {
		text* type = PG_GETARG_TEXT_PP(0);
		text* priority = PG_GETARG_TEXT_PP(1);
		text* label = PG_GETARG_TEXT_PP(2);
		ArrayType* tables = PG_GETARG_ARRAYTYPE_P(3);
		TransactionType = text_to_cstring(type);
		TransactionPriority = text_to_cstring(priority);
		TransactionLabel = text_to_cstring(label);
		WritePreserveTables = TextArrayToStringList(tables);
	} else {
		ereport(ERROR,
			(errcode(ERRCODE_INVALID_PARAMETER_VALUE),
			 errmsg("Invalid number of parameters.")));
	}

	CheckTransactionArgs(TransactionType, TransactionPriority, TransactionLabel, WritePreserveTables);

	SetTransactionOption(TransactionType, TransactionPriority, TransactionLabel, WritePreserveTables);

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

	GetTransactionOption(transaction);
	PG_RETURN_CSTRING(TransactionToJsonCharString(transaction));
}

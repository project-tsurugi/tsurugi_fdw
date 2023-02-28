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

PG_FUNCTION_INFO_V1(tg_transaction);

#ifdef __cplusplus
}
#endif

// options for beginning transactions
static constexpr const char* const OPTION_TYPE 				= "TransactionType";
static constexpr const char* const OPTION_PRIORITY 			= "TransactionPriority";
static constexpr const char* const OPTION_LABEL 			= "TransactionLabel";
static constexpr const char* const OPTION_WRITE_PRESERVE	= "WritePreserve";
static constexpr const char* const OPTION_TABLE_NAME		= "TableName";

static int64_t type = ogawayama::stub::TransactionType::SHORT;
static int64_t priority = ogawayama::stub::TransactionPriority::TRANSACTION_PRIORITY_UNSPECIFIED;
static std::string label = "pgsql-long-transaction";
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
	transaction.put<int64_t>(OPTION_TYPE, type);
	transaction.put<int64_t>(OPTION_PRIORITY, priority);
	transaction.put<std::string>(OPTION_LABEL, label);
	if (write_preserves.size()) {
		for (std::string prev_table : write_preserves) {
			pt_table.put<std::string>(OPTION_TABLE_NAME, prev_table);
			pt_write_preserves.push_back(std::make_pair("", pt_table));
		}
	} else {
		pt_table.put<std::string>(OPTION_TABLE_NAME, "");
		pt_write_preserves.push_back(std::make_pair("", pt_table));
	}
	transaction.add_child(OPTION_WRITE_PRESERVE, pt_write_preserves);

	result = true;
	return result;
}

/**
 * @brief Check Args to set current transaction options.
 * @param TransactionType [in] transaction type.
 * @param WritePreserveTables [in] list of write preserve tables.
 * @return true if success, otherwise fault.
 */
bool
CheckTransactionArgs(char* TransactionType, List* WritePreserveTables)
{
	assert(TransactionType != nullptr);
	bool result = true;

	if (!strcmp(TransactionType, "short") || !strcmp(TransactionType, "OCC") || !strcmp(TransactionType, "STX")) {
		if (WritePreserveTables != NIL) {
			ereport(ERROR,
					(errcode(ERRCODE_INTERNAL_ERROR),
					errmsg("Invalid Write Preserve Table specified.")));
			result = false;
		} else {
			type = ogawayama::stub::TransactionType::SHORT;
			write_preserves.clear();
		}
	} else if (!strcmp(TransactionType, "long") || !strcmp(TransactionType, "PCC") || !strcmp(TransactionType, "LTX")) {
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
						result = false;
					}
				}
			}
			if (result) {
				type = ogawayama::stub::TransactionType::LONG;
				write_preserves.clear();
				foreach(listptr, WritePreserveTables) {
					Node* node = (Node *) lfirst(listptr);
					if (IsA(node, String)) {
						Value* write_preserve = (Value*) node;
						write_preserves.emplace_back(strVal(write_preserve));
					}
				}
			}
		} else {
#if 1
			type = ogawayama::stub::TransactionType::LONG;
			write_preserves.clear();
#else
			ereport(ERROR,
					(errcode(ERRCODE_INTERNAL_ERROR),
					errmsg("Write Preserve Table is not specified.")));
			result = false;
#endif
		}
	} else if (!strcmp(TransactionType, "read_only") || !strcmp(TransactionType, "read") || !strcmp(TransactionType, "RO")) {
		if (WritePreserveTables != NIL) {
			ereport(ERROR,
					(errcode(ERRCODE_INTERNAL_ERROR),
					errmsg("Invalid Write Preserve Table specified.")));
			result = false;
		} else {
			type = ogawayama::stub::TransactionType::READ_ONLY;
			write_preserves.clear();
		}
	} else {
		ereport(ERROR,
				(errcode(ERRCODE_INTERNAL_ERROR),
				errmsg("Invalid Transaction Type parameter. (type: %s)",
				TransactionType)));
		result = false;
	}
	return result;
}

Datum
tg_transaction(PG_FUNCTION_ARGS)
{
	char* TransactionType;
	List* WritePreserveTables = NIL;
	boost::property_tree::ptree transaction;

	if (PG_NARGS() == 1) {
		text* type = PG_GETARG_TEXT_PP(0);
		TransactionType = text_to_cstring(type);
	} else if (PG_NARGS() == 2) {
		text* type = PG_GETARG_TEXT_PP(0);
		ArrayType* tables = PG_GETARG_ARRAYTYPE_P(1);
		TransactionType = text_to_cstring(type);
		WritePreserveTables = TextArrayToStringList(tables);
	} else {
		GetTransactionOption(transaction);
		PG_RETURN_CSTRING(TransactionToJsonCharString(transaction));
	}

	CheckTransactionArgs(TransactionType, WritePreserveTables);

	GetTransactionOption(transaction);
	PG_RETURN_CSTRING(TransactionToJsonCharString(transaction));
}

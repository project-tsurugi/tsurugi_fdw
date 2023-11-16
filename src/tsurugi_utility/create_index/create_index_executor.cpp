/*
 * Copyright 2019-2023 Project Tsurugi.
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
 *	@file	create_index_executor.cpp
 */
#include <memory>
#include "tg_common.h"
#include "manager/metadata/tables.h"
#include "manager/metadata/index.h"
#include "manager/metadata/indexes.h"
#include "manager/metadata/metadata_factory.h"
#include "manager/message/ddl_message.h"
#include "send_message.h"
#include "create_index.h"
#include "create_index_executor.h"

using namespace manager;
using manager::metadata::ObjectId;
using manager::metadata::ErrorCode;

/**
 * @brief	Create index metadata from index statement.
 * @param	index_stmt	[in] Query tree of index statement.
 * @return	object ID of index metadata.
 */
int64_t execute_create_index(IndexStmt* index_stmt)
{
	assert(index_stmt != NULL);

	ObjectId idnex_id = metadata::INVALID_OBJECT_ID;
    auto indexes = metadata::get_indexes_ptr(TSURUGI_DB_NAME);
    CreateIndex create_index{index_stmt};

    create_index.validate_syntax();
	create_index.validate_data_type();

	// Create index metadata.
	metadata::Index index;
	bool success = create_index.generate_metadata(index);
	if (!success) {
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_TABLE_DEFINITION),
				errmsg("Failed to generate index metadata. " \
				" (table name: %s)",
				(const char*) create_index.get_table_name())));
	}
	ErrorCode error = indexes->add(index, &idnex_id);
	if (error != ErrorCode::OK) {
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_TABLE_DEFINITION),
				errmsg("Failed to add index metadata. " \
				"(table name: %s) (index name: %s) (error:%d)",
				(const char*) create_index.get_table_name(), 
				index.name.c_str(), (int) error)));
	}

	// Create constraint metadata.
	auto tables = metadata::get_tables_ptr(TSURUGI_DB_NAME);
	metadata::Table table_constraint;
	ObjectId constraint_id = metadata::INVALID_OBJECT_ID;
	error = tables->get(create_index.get_table_name(), table_constraint);
	if (error != metadata::ErrorCode::OK) {
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_TABLE_DEFINITION),
				errmsg("The table is not found when registing constraints. (name: %s) (error:%d)",
				(char*) create_index.get_table_name(), (int) error)));
		return constraint_id;
	}
	constraint_id = table_constraint.id;
	error = create_index.generate_constraint_metadata(table_constraint);
	if (error != metadata::ErrorCode::NOT_FOUND) {
		if (error != metadata::ErrorCode::OK) {
			ereport(ERROR,
					(errcode(ERRCODE_INTERNAL_ERROR),
					errmsg("CreateIndex::generate_constraint_metadata() failed.")));
			return constraint_id;
		}
		error = tables->update(constraint_id, table_constraint);
		if (error != metadata::ErrorCode::OK) {
			ereport(ERROR,
					(errcode(ERRCODE_INTERNAL_ERROR),
					errmsg("Update a table metadata failed when registing constraints. " \
					"(name: %s) (error:%d)", table_constraint.name.data(), (int) error)));
			return constraint_id;
		}
	}

	return idnex_id;
}

void send_create_index_message(int64_t index_id)
{
	message::CreateIndex create_index_message{index_id};
	bool success = send_message(create_index_message);
	if (!success) {
		metadata::Index index;
		auto indexes = metadata::get_indexes_ptr(TSURUGI_DB_NAME);
		indexes->remove(index_id);
		ereport(ERROR,
			(errcode(ERRCODE_INTERNAL_ERROR), errmsg("Create Index failed.")));
	}
}
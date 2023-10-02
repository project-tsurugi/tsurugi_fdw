/*
 * Copyright 2019-2022 tsurugi project.
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
 *	@file	create_table.h
 *	@brief  Dispatch the create-table command to ogawayama.
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

#if 0
	// Primary Keys
	auto tables = metadata::get_table_metadata(TSURUGI_DB_NAME);
	metadata::Table table;
	ErrorCode error = tables->get(create_index.get_table_name(), table);
	if (error != metadata::ErrorCode::OK) {
		ereport(NOTICE,
				errmsg("Table not found. (name: %s)", 
				create_index.get_table_name()));
		return object_id;
	}
	object_id = table.id;

	if (table.primary_keys.size() == 0) {
		// Primary keys specified in table constraints.
		auto error = create_index.generate_table_metadata(table);
		if (error != metadata::ErrorCode::OK) {
			ereport(NOTICE,	errmsg("Primary keys not found."));
			return object_id;
		}
		error = tables->remove(table.id);
		if (error != metadata::ErrorCode::OK) {
			ereport(NOTICE,	
					errmsg("Remove a table metadata failed. (name: %s) (error:%d)",
					table.name.data(), (int) error));
		}
		error = tables->add(table, &object_id);
		if (error != metadata::ErrorCode::OK) {
			ereport(NOTICE,	
					errmsg("Add a table metadata failed. (name: %s) (error:%d)",
					table.name.data(), (int) error));
		}
	}
#endif

	// Send a message to ogawayama.
	metadata::Table table;
	tables->get(create_index.get_table_name(), table);
	if (!index.is_primary) {
		manager::message::CreateIndex create_index_message{idnex_id};
		success = send_message(create_index_message);
		if (!success) {
			ereport(ERROR,
				(errcode(ERRCODE_INTERNAL_ERROR), 
				errmsg("Failed to send a message to tsurugi. (CreateIndex)")));
			idnex_id = metadata::INVALID_OBJECT_ID;
		}
	}

	return idnex_id;
}

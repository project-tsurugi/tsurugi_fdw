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
#include "manager/metadata/tables.h"
#include "create_index.h"
#include "create_index_executor.h"

using namespace manager;

int64_t execute_create_index(IndexStmt* index_stmt)
{
	assert(index_stmt != NULL);

	metadata::ObjectId object_id = metadata::INVALID_OBJECT_ID;
//	auto indexes = std::make_unique<metadata::Indexes>("tsurugi");
	CreateIndex create_index{index_stmt};
	
	bool success = create_index.validate_syntax();
	success = create_index.validate_data_type();
	metadata::Index index;
	success = create_index.generate_metadata(index);
//	metadata::ErrorCode error = indexes->add(index, &object_id);

	// Primary Keys
	auto tables = std::make_unique<metadata::Tables>("tsurugi");
	metadata::Table table;
	auto error = tables->get(create_index.get_table_name(), table);
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
	
	return object_id;
}

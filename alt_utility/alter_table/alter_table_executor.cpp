/*
 * Copyright 2022 tsurugi project.
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
 *	@file	alter_table_executor.cpp
 *	@brief  Create constraint metadata from alter table statement.
 */
#include <memory>
#include "manager/metadata/tables.h"
#include "manager/metadata/constraints.h"
#include "manager/metadata/metadata_factory.h"

#include "alter_table.h"
#include "alter_table_executor.h"

using namespace manager;
using manager::metadata::ObjectId;
using manager::metadata::ErrorCode;

/**
 * @brief	Create constraint metadata from alter table statement.
 * @param	index_stmt	[in] Query tree of index statement.
 * @return	object ID of index metadata.
 */
int64_t execute_alter_table(AlterTableStmt* alter_table_stmt)
{
	assert(alter_table_stmt != NULL);

	ObjectId object_id = metadata::INVALID_OBJECT_ID;
	auto tables = metadata::get_tables_ptr("tsurugi");
    AlterTable alter_table{alter_table_stmt};

    alter_table.validate_syntax();
	alter_table.validate_data_type();

	// Constraint metadata
	metadata::Table table_constraint;
	ErrorCode error = tables->get(alter_table.get_table_name(), table_constraint);
	if (error != metadata::ErrorCode::OK) {
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_TABLE_DEFINITION),
				errmsg("The table is not found when registing constraints. (name: %s) (error:%d)",
				(char*) alter_table.get_table_name(), (int) error)));
		return object_id;
	}
	object_id = table_constraint.id;
	error = alter_table.generate_constraint_metadata(table_constraint);
	if (error != metadata::ErrorCode::NOT_FOUND) {
		if (error != metadata::ErrorCode::OK) {
			ereport(ERROR,
					(errcode(ERRCODE_INTERNAL_ERROR),
					errmsg("AlterTable::generate_constraint_metadata() failed.")));
			return object_id;
		}
		error = tables->update(object_id, table_constraint);
		if (error != metadata::ErrorCode::OK) {
			ereport(ERROR,
					(errcode(ERRCODE_INTERNAL_ERROR),
					errmsg("Update a table metadata failed when registing constraints. " \
					"(name: %s) (error:%d)", table_constraint.name.data(), (int) error)));
		}
	}

	return object_id;
}

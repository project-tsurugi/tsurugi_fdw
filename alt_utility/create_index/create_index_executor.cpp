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

void execute_create_index(IndexStmt* index_stmt)
{
	CreateIndex create_index(index_stmt);

	// Primary Keys
	auto tables = std::make_unique<metadata::Tables>("tsurugi");
	metadata::Table table;
	auto error = tables->get(create_index.get_table_name(), table);
	if (error != metadata::ErrorCode::OK) {
		return;
	}
	if (table.primary_keys.size() == 0) {
		create_index.generate_table_metadata(table);
	}
}

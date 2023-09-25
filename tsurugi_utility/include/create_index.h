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
 */
#pragma once

#include <string>
#include <boost/property_tree/ptree.hpp>
#include "manager/metadata/metadata.h"
#include "manager/metadata/tables.h"
#include "command/index_command.h"

class CreateIndex : public IndexCommand {
 public:
	CreateIndex(IndexStmt* index_stmt) : IndexCommand(index_stmt) {}
	virtual bool validate_syntax() const override;
	virtual bool validate_data_type() const override;
	virtual bool generate_metadata(manager::metadata::Object& object) const override;
	manager::metadata::ErrorCode 
	generate_constraint_metadata(manager::metadata::Table& table) const;
	manager::metadata::ErrorCode 
	generate_table_metadata(manager::metadata::Table& table) const;
	/**
	 * @brief
	 */
	const char* get_table_name(void) const {
		IndexStmt* index_stmt = this->index_stmt();
		Assert(index_stmt != NULL);
		return index_stmt->relation->relname;
	}

	CreateIndex() = delete;
	CreateIndex(const CreateIndex&) = delete;
  	CreateIndex& operator=(const CreateIndex&) = delete;
};

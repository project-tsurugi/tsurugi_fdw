/*
 * Copyright 2022-2023 Project Tsurugi.
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
 *	@file	alter_table.h
 *	@brief  Generate metadata from alter table statement.
 */
#pragma once

#include "tg_common.h"
#include "command/alter_table_command.h"

class AlterTable : public AlterTableCommand {
 public:
	AlterTable(AlterTableStmt* alter_table_stmt) : AlterTableCommand(alter_table_stmt) {}

	/**
	 * @brief
	 */
	virtual bool validate_syntax() const override;

	/**
	 * @brief
	 */
	virtual bool validate_data_type() const { return true; }

	/**
	 * @brief
	 */
	const char* get_table_name(void) const {
		AlterTableStmt* alter_table_stmt = this->alter_table_stmt();
		Assert(alter_table_stmt != NULL);
		return alter_table_stmt->relation->relname;
	}

	/**
	 * @brief
	 */
	manager::metadata::ErrorCode 
	generate_constraint_metadata(manager::metadata::Table& table) const;

	AlterTable() = delete;
	AlterTable(const AlterTable&) = delete;
  	AlterTable& operator=(const AlterTable&) = delete;

 private:
	bool get_constraint_metadata(Constraint* constr, 
								manager::metadata::Table& table, 
								manager::metadata::Constraint& constraint) const;
};


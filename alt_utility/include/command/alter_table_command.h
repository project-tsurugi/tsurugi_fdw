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
 *	@file	alter_table_command.h
 *	@brief  alter table statement operations.
 */
#pragma once

#ifdef __cplusplus
extern "C"
{
#endif
#include "postgres.h"
#include "nodes/parsenodes.h"
#ifdef __cplusplus
}
#endif

#include "command/create_command.h"

class AlterTableCommand : public DDLCommand {
 public:
	AlterTableCommand(AlterTableStmt* alter_table_stmt) 
		: DDLCommand((Node*) alter_table_stmt) {}

	/**
	 * @brief
	 */
	AlterTableStmt* alter_table_stmt() const { 
		Node* node = this->statement();
		return IsA(node, AlterTableStmt) ? (AlterTableStmt*) node : nullptr;
	}

	AlterTableCommand() = delete;
	AlterTableCommand(const AlterTableCommand&) = delete;
	DDLCommand& operator=(const AlterTableCommand&) = delete;
};

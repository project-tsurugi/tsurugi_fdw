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
 *	@file	drop_command.h
 *	@brief  For drop commands in DDL.
 */
#pragma once

#include <boost/property_tree/ptree.hpp>
#include "command/ddl_command.h"

#ifdef __cplusplus
extern "C"
{
#endif
#include "postgres.h"
#include "nodes/parsenodes.h"
#ifdef __cplusplus
}
#endif

class DropCommand : public DDLCommand {
 public:
  	DropCommand(DropStmt* drop_stmt) : DDLCommand{(Node*) drop_stmt} {}

	/**
	 * @brief
	 */
	DropStmt* drop_stmt() const { 
		Node* node = this->statement();
		return IsA(node, DropStmt) ? (DropStmt*) node : nullptr;
	}

	DropCommand() = delete;
	DropCommand(const DropCommand&) = delete;
  	DDLCommand& operator=(const DropCommand&) = delete;
};

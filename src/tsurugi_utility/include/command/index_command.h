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
 *	@file	index_command.h
 *	@brief  index statement operations.
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

class IndexCommand : public CreateCommand {
 public:
	IndexCommand(IndexStmt* index_stmt) 
		: CreateCommand((CreateStmt*) index_stmt) {}

	/**
	 * @brief
	 */
	virtual IndexStmt* index_stmt() const { 
		Node* node = this->statement();
		return IsA(node, IndexStmt) ? (IndexStmt*) node : nullptr;
	}

	IndexCommand() = delete;
	IndexCommand(const IndexCommand&) = delete;
  	IndexCommand& operator=(const IndexCommand&) = delete;
};

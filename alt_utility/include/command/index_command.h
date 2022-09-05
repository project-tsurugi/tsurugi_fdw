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

#include "command/ddl_command.h"

class IndexCommand : public DDLCommand{
 public:
	IndexCommand(IndexStmt* index_stmt) 
		: DDLCommand((Node*) index_stmt) {}

	IndexStmt* index_stmt() const { 
		Node* node = this->statement();
		return IsA(node, IndexStmt) ? (IndexStmt*) node : nullptr;
	}

	/**
	 *  @brief  Create metadata from query tree.
	 *  @return true if supported
	 *  @return false otherwise.
	 */
	//  virtual bool generate_metadata(boost::property_tree::ptree& metadata) = 0;
};

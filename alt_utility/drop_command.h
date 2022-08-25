/*
 * Copyright 2019-2020 tsurugi project.
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
 *	@file	  ddl_metadata.h
 *	@brief  DDL metadata operations.
 */
#pragma once

#include <boost/property_tree/ptree.hpp>
#include "DDL_command.h"

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
  DropCommand(DropStmt* drop_stmt) : drop_stmt_{drop_stmt} {}

  DropStmt* drop_stmt() {drop_stmt_;}

 private:
  DropStmt* drop_stmt_; // qeury tree
};

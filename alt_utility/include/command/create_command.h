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

class CreateCommand : public DDLCommand{
 public:
  CreateCommand(CreateStmt* create_stmt) : create_stmt_{create_stmt} {}

  /**
   *  @brief  Create metadata from query tree.
   *  @return true if supported
   *  @return false otherwise.
   */
  virtual bool generate_metadata(boost::property_tree::ptree& metadata) = 0;

  CreateStmt* create_stmt() const { return create_stmt_;}

 private:
  CreateStmt* create_stmt_; // qeury tree
};
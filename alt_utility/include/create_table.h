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
 *	@file	  table_metadata.h
 *	@brief  TABLE metadata operations.
 */
#pragma once
#include <vector>
#include <unordered_set>
#include <boost/property_tree/ptree.hpp>
#include "command/create_command.h"

struct Column {
	Column() {}
  int64_t       format_version;
  int64_t       generation;
  int64_t       id;
  int64_t       table_id;
  std::string   name;
  int64_t       ordinal_position;
  int64_t       data_type_id;
  std::string   data_length;
  int64_t       varing;
  bool          nullable;
  std::string   default_expr;
  int64_t       direction;
};

struct Table {
	Table() {}
  int64_t       format_version;
  int64_t       generation;
  int64_t      	id;
  std::string   namespace_name;
  std::string   name;
  int64_t       owner_role_id;
  std::string   acl;
  int64_t       tuples;
  std::vector<int64_t>	primary_keys;
  std::vector<Column>	columns;
};

class CreateTable : public CreateCommand {
 public:
  CreateTable(CreateStmt* create_stmt) : CreateCommand(create_stmt) {}

  /**
   *  @brief  Check if given syntax supported or not by Tsurugi
   *  @return true if supported
   *  @return false otherwise.
   */
  virtual bool validate_syntax();

  /**
   *  @brief  Check if given syntax supported or not by Tsurugi
   *  @return true if supported
   *  @return false otherwise.
   */
  virtual bool validate_data_type();

  /**
   *  @brief  Create table metadata from query tree.
   *  @return true if supported
   *  @return false otherwise.
   */
  virtual bool generate_metadata(boost::property_tree::ptree& metadata);

 private:

  bool create_column_metadata(ColumnDef* column_def, 
                              int64_t ordinal_position, 
                              boost::property_tree::ptree& column,
                              Column& column_);
  bool put_data_lengths(List* typmods, boost::property_tree::ptree& datalengths);

};

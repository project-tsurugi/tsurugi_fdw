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

#include <boost/property_tree/ptree.hpp>
#include "command/create_command.h"

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
  bool create_column_metadata(ColumnDef* colDef, 
                              int64_t ordinal_position, 
                              boost::property_tree::ptree& column);
  bool put_data_lengths(List* typmods, boost::property_tree::ptree& datalengths);
};

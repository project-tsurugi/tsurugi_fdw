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
 *	@file	create_table.h
 *	@brief  Dispatch the create-table command to ogawayama.
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
	virtual bool validate_syntax() const;
	virtual bool validate_data_type() const;
//	virtual bool generate_metadata(boost::property_tree::ptree& metadata) const;
	manager::metadata::ErrorCode 
	generate_table_metadata(manager::metadata::Table table) const;

	/**
	 * @brief 
	 */
	std::string_view get_table_name(void) const {
		IndexStmt* index_stmt = this->index_stmt();
		return index_stmt->relation->relname;
	}

	private:
	/**
	 *  @brief  Reports error message that given table constraint is not supported by Tsurugi.
	 *  @param  [in] The primary message.
	 */
	void
	show_table_constraint_syntax_error_msg(const char *error_message) const
	{
		ereport(ERROR,
			(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
			errmsg("%s",error_message),
			errdetail("Tsurugi supports only PRIMARY KEY in table constraint")));
	}
};

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
 *	@file	ddl_metadata.h
 *	@brief  DDL metadata operations.
 */
#pragma once

#ifdef __cplusplus
extern "C" {
#endif
#include "postgres.h"
#include "nodes/parsenodes.h"
#ifdef __cplusplus
}
#endif

class DDLCommand {
 public:
	DDLCommand(Node* node) : node_(node) {}
	Node* statement() const {return node_;}

	/**
	 *  @brief  Check if given syntax supported or not by Tsurugi
	 *  @return true if supported
	 *  @return false otherwise.
	 */
	virtual bool validate_syntax() const = 0;

	/**
	 *  @brief  Check if given syntax supported or not by Tsurugi
	 *  @return true if supported
	 *  @return false otherwise.
	 */
	virtual bool validate_data_type() const = 0;

	protected:
	/**
	 *  @brief  Reports error message that given syntax is not supported by Tsurugi.
	 *  @param  [in] The primary message.
	 */
	void show_syntax_error_msg(const char *error_message) const
	{
	ereport(ERROR,
			(errcode(ERRCODE_SYNTAX_ERROR),
			errmsg("%s",error_message),
			errdetail("Tsurugi does not support this syntax")));
	}

	/**
	 *  @brief  Reports error message that given types are not supported by Tsurugi.
	 *  @param  [in] List of TypeName structure's member "names".
	 */
	void show_type_error_msg(List *type_names) const
	{
	ereport(ERROR,
		(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
		errmsg("Tsurugi does not support type %s", nodeToString(type_names))));
	}

	/**
	 *  @brief  Reports error message that given types are not supported by Tsurugi.
	 *  @param  [in] List of TypeName structure's member "typeOid".
	 */
	void show_type_error_msg(std::vector<int> type_oids) const
	{
	std::stringstream type_oid_str;
	std::copy(type_oids.begin(), 
				type_oids.end(), 
				std::ostream_iterator<int>(type_oid_str, ", "));

	ereport(ERROR,
		(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
		errmsg("Tsurugi does not support type oid %s", type_oid_str.str().c_str())));
	}

 private:
	Node* node_ = nullptr;
};

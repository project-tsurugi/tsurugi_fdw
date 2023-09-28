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
 */
#pragma once
#include "command/drop_command.h"

#ifdef __cplusplus
extern "C" {
#endif
#include "nodes/parsenodes.h"
#ifdef __cplusplus
}
#endif

class DropIndex : public DropCommand {
 public:
	DropIndex(DropStmt* drop_stmt) : DropCommand(drop_stmt) {}

	/**
	 * @brief
	 */
	virtual bool validate_syntax() const {
		DropStmt* drop_stmt = this->drop_stmt();
		assert(drop_stmt != nullptr);
		bool result{false};

		if (drop_stmt->behavior == DROP_CASCADE) {
			ereport(ERROR,
					(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
					errmsg("Tsurugi does not support CASCADE clause")));
			return result;
		}
		result = true;

		return result;
	}

	/**
	 * @brief
	 */
	virtual bool validate_data_type() const { return true; }

	DropIndex() = delete;
	DropIndex(const DropIndex&) = delete;
  	DropIndex& operator=(const DropIndex&) = delete;
};

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
#include "tg_common.h"
#include "ogawayama/stub/api.h"

#include "manager/message/ddl_message.h"
#include "manager/metadata/datatypes.h"
#include "manager/metadata/metadata.h"
#include "manager/metadata/index.h"
#include "manager/metadata/indexes.h"
#include "manager/metadata/metadata_factory.h"

#ifdef __cplusplus
extern "C"
{
#endif
#include "postgres.h"
#include "nodes/parsenodes.h"
#ifdef __cplusplus
}
#endif

#include "send_message.h"
#include "drop_index_executor.h"
#include "drop_index.h"
#include "manager/metadata/metadata.h"

/* DB name metadata-manager manages */
const std::string DBNAME = "Tsurugi";

using namespace boost;
using namespace manager;
using namespace manager::metadata;
using namespace ogawayama;

/**
 *  @brief
 *  @param
 */
bool index_exists_in_tsurugi(const char* relname)
{
  	auto indexes = get_indexes_ptr(DBNAME);
  	return indexes->exists(relname);
}

/**
 *  @brief Calls the function sending metadata to metadata-manager and drops parameters sended to ogawayama.
 */
bool execute_drop_index(DropStmt* drop_stmt, const char* relname)
{
    Assert(drop_stmt != nullptr);
	bool result{false};
	DropIndex drop_index(drop_stmt);

	bool success = drop_index.validate_syntax();
	if (!success) {
		return result;
	}

	success = drop_index.validate_data_type();
	if (!success) {
		return result;
	}

    /* Get the object ID of the index to be deleted */
	manager::metadata::Index index;
    auto indexes = get_indexes_ptr(DBNAME);
    metadata::ErrorCode error = indexes->get(relname, index);
	if (error != ErrorCode::OK) {
        if (error == ErrorCode::NAME_NOT_FOUND && drop_stmt->missing_ok) {
            result = true;
        } else {
            ereport(ERROR,
                    (errcode(ERRCODE_INTERNAL_ERROR),
                     errmsg("drop_index() get metadata failed. (table name: %s)", 
                     relname)));
        }
        return result;
    }

	// check constraint
	Table table;
	auto tables = get_tables_ptr(DBNAME);
	error = tables->get(index.table_id, table);
	if (error != ErrorCode::OK) {
		ereport(ERROR,
			(errcode(ERRCODE_INTERNAL_ERROR),
			 errmsg("drop_index() get table metadata failed.")));
		return result;
	}
	for (const auto& constraint : table.constraints) {
		if (index.id == constraint.index_id) {
			ereport(ERROR,
					(errcode(ERRCODE_DEPENDENT_OBJECTS_STILL_EXIST),
					 errmsg("cannot drop index because constraint %s on table %s requires it",
					 index.name.data(), table.name.data())));
			return result;
		}
	}

    /* Send DROP_INDEX message to ogawayama */
    message::DropIndex drop_index_message{index.id};
    success = send_message(drop_index_message);
    if (!success) {
      ereport(ERROR,
              (errcode(ERRCODE_INTERNAL_ERROR), 
              errmsg("send_message() failed. (DROP_INDEX)")));
      return result;
    }

	/* remove index metadata */
    error = indexes->remove(index.id);
    if (error != ErrorCode::OK) {
        ereport(ERROR,
                (errcode(ERRCODE_INTERNAL_ERROR),
                 errmsg("drop_index() remove index metadata failed.")));
        return result;
    }
	result = true;

    return result;
}
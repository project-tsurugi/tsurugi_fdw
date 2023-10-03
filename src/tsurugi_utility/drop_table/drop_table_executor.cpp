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
 *	@file	  drop_table.cpp
 *	@brief  Dispatch drop-message to ogawayama.
 */
#include "ogawayama/stub/api.h"

#include "manager/message/ddl_message.h"
#include "manager/metadata/datatypes.h"
#include "manager/metadata/metadata.h"
#include "manager/metadata/tables.h"
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
#include "drop_table_executor.h"
#include "drop_table.h"
#include "manager/metadata/metadata.h"

using namespace boost;
using namespace manager;
using namespace manager::metadata;
using namespace ogawayama;

/**
 * @brief
 * @param
 * 
 */
bool table_exists_in_tsurugi(const char *relname)
{
  	auto tables = get_tables_ptr(TSURUGI_DB_NAME);
  	return tables->exists(relname);
}

/**
 *  @brief Calls the function sending metadata to metadata-manager and drops parameters sended to ogawayama.
 *  @param [in] Table name to remove.
 */
bool execute_drop_table(DropStmt* drop_stmt, const char* relname)
{
    Assert(drop_stmt != nullptr);
	bool result{false};
	DropTable drop_table(drop_stmt);

	bool success = drop_table.validate_syntax();
	if (!success) {
		return result;
	}

	success = drop_table.validate_data_type();
	if (!success) {
		return result;
	}

    /* Get the object ID of the table to be deleted */
	Table table;
    auto tables = get_tables_ptr(TSURUGI_DB_NAME);
    metadata::ErrorCode error = tables->get(relname, table);
	if (error != ErrorCode::OK) {
        if (error == ErrorCode::NAME_NOT_FOUND && drop_stmt->missing_ok) {
            result = true;
        } else {
            ereport(ERROR,
                    (errcode(ERRCODE_INTERNAL_ERROR),
                     errmsg("drop_table() get metadata failed.")));
        }
        return result;
    }

    /* DROP_TABLE message to ogawayama */
    message::DropTable drop_table_message{table.id};
#if 1
    success = send_message(drop_table_message);
#else
	success = true;
#endif
    if (!success) {
      ereport(ERROR,
              (errcode(ERRCODE_INTERNAL_ERROR), 
              errmsg("send_message() failed. (DROP_TABLE)")));
      return result;
    }

	/* remove index metadata */
#if 1
	auto indexes = metadata::get_indexes_ptr(TSURUGI_DB_NAME);
	std::vector<boost::property_tree::ptree> index_elements = {};
	error = indexes->get_all(index_elements);
    if (error != ErrorCode::OK) {
		ereport(ERROR,
				(errcode(ERRCODE_INTERNAL_ERROR),
				 errmsg("drop_table() get remove all index metadata failed. (error:%d)",
				 (int) error)));
		return result;
	}
	if (index_elements.size() != 0) {
		for (size_t i=0; i<index_elements.size(); i++) {
			auto index_table_id = index_elements[i].get_optional<ObjectIdType>(metadata::Index::TABLE_ID);
			if (table.id == index_table_id.get()) {
				auto remove_id = index_elements[i].get_optional<ObjectIdType>(metadata::Index::ID);
				error = indexes->remove(remove_id.get());
			    if (error != ErrorCode::OK) {
					ereport(ERROR,
							(errcode(ERRCODE_INTERNAL_ERROR),
							 errmsg("drop_table() remove index metadata failed. (error:%d)",
							 (int) error)));
					return result;
				}
			}
		}
	}
#else
	auto indexes = metadata::get_index_metadata(TSURUGI_DB_NAME);
	std::vector<metadata::Index> index_elements = {};
	error = indexes->get_all(index_elements);
    if (error != ErrorCode::OK) {
		ereport(ERROR,
				(errcode(ERRCODE_INTERNAL_ERROR),
				 errmsg("drop_table() get remove all index metadata failed. (error:%d)",
				 (int) error)));
		return result;
	}
	if (index_elements.size() != 0) {
		for (size_t i=0; i<index_elements.size(); i++) {
			if (table.id == index_elements[i].table_id) {
				error = indexes->remove(index_elements[i].id);
			    if (error != ErrorCode::OK) {
					ereport(ERROR,
							(errcode(ERRCODE_INTERNAL_ERROR),
							 errmsg("drop_table() remove index metadata failed. (error:%d)",
							 (int) error)));
					return result;
				}
			}
		}
	}
#endif

    /* remove metadata */
    error = tables->remove(table.id);
    if (error != ErrorCode::OK) {
        ereport(ERROR,
                (errcode(ERRCODE_INTERNAL_ERROR),
                 errmsg("drop_table() remove table metadata failed.")));
        return result;
    }
	result = true;

    return result;
}

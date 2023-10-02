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
 *	@file	  create_table_executor.cpp
 *	@brief  Dispatch create-table message to ogawayama.
 */
#include <string>
#include <string_view>
#include <boost/property_tree/ptree.hpp>

#include "ogawayama/stub/api.h"
#include "manager/message/ddl_message.h"
#include "manager/message/broker.h"
#include "manager/message/status.h"
#include "manager/metadata/datatypes.h"
#include "manager/metadata/metadata.h"
#include "manager/metadata/tables.h"
#include "manager/metadata/metadata_factory.h"

#ifdef __cplusplus
extern "C" {
#endif
#include "postgres.h"
#include "tcop/utility.h"
#ifdef __cplusplus
}
#endif

#include "tsurugi.h"
#include "create_table.h"
#include "send_message.h"
#include "create_table_executor.h"

using namespace boost;
using namespace ogawayama;
using namespace manager;

/**
 *  @brief Calls the function sending metadata to metadata-manager and creates parameters sended to ogawayama.
 *  @param [in] List of statements.
 */
int64_t execute_create_table(CreateStmt* create_stmt)
{
	Assert(create_stmt != nullptr);

	metadata::ObjectIdType object_id = metadata::INVALID_OBJECT_ID;
	CreateTable create_table{create_stmt};

	/* check if given syntax supported or not by Tsurugi */
	if (!create_table.validate_syntax()) {
		return object_id;
	}

	/* check if given type supported or not by Tsurugi */
	if (!create_table.validate_data_type()) {
		return object_id;
	}

	metadata::Table table;
	bool success = create_table.generate_metadata(table);
	if (!success) {
		ereport(ERROR,
				(errcode(ERRCODE_INTERNAL_ERROR), 
				errmsg("CreateTable::generate_metadata() failed.")));
		return  object_id;
	}

	auto tables = metadata::get_tables_ptr(TSURUGI_DB_NAME);
	metadata::ErrorCode error = tables->add(table, &object_id);
	if (error != metadata::ErrorCode::OK ) {
		if (error == metadata::ErrorCode::ALREADY_EXISTS) {
			ereport(ERROR,
					(errcode(ERRCODE_INVALID_TABLE_DEFINITION),
					errmsg("Table already exists. (name: %s)",
					(char*) create_table.get_table_name())));
		} else {
			ereport(ERROR,
					(errcode(ERRCODE_INTERNAL_ERROR),
					errmsg("Failed to store a table metadata." \
							" (error: %d)", (int) error)));
			return object_id;
		}
	}

	// Constraint metadata
	metadata::Table table_constraint;
	error = tables->get(object_id, table_constraint);
	if (error != metadata::ErrorCode::OK) {
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_TABLE_DEFINITION),
				errmsg("Table metadata not found. (name: %s) (id: %ld) (error: %d)",
				(char*) create_table.get_table_name(), object_id, (int) error)));
		return object_id;
	}
	object_id = table_constraint.id;
	error = create_table.generate_constraint_metadata(table_constraint);
	if (error != metadata::ErrorCode::NOT_FOUND) {
		if (error != metadata::ErrorCode::OK) {
			ereport(ERROR,
					(errcode(ERRCODE_INTERNAL_ERROR),
					errmsg("CreateTable::generate_constraint_metadata() failed.")));
			return object_id;
		}
		error = tables->update(object_id, table_constraint);
		if (error != metadata::ErrorCode::OK) {
			ereport(ERROR,
					(errcode(ERRCODE_INTERNAL_ERROR),
					errmsg("Update a table metadata failed when registing constraints. " \
					"(name: %s) (error:%d)", table_constraint.name.data(), (int) error)));
		}
	}

	return object_id;
}

/**
 * @brief	Send create-table message to OLTP.
 * 
 */
bool send_create_table_message(const int64_t object_id)
{
	bool result = false;

	if (object_id == metadata::INVALID_OBJECT_ID) {
		return result;
	}

	/* sends message to ogawayama */
	manager::message::CreateTable create_table_message{object_id};
	bool success = send_message(create_table_message);
	if (!success) {
		ereport(ERROR,
			(errcode(ERRCODE_INTERNAL_ERROR), 
			errmsg("send_message() failed. (CreateTable Message)")));
		return result;
	}
	result = true;

	return result;  
}

/**
 * @brief   Remove metadata from metadata-manager.
 * @param
 * @return
 */
bool remove_table_metadata(const int64_t object_id)
{
  bool result{false};
  auto tables = std::make_unique<metadata::Tables>(TSURUGI_DB_NAME);

  if (tables->exists(object_id)) {
    metadata::ErrorCode error = tables->remove(object_id);
    if (error != metadata::ErrorCode::OK) {
      ereport(WARNING,
              (errcode(ERRCODE_INTERNAL_ERROR),
              errmsg("remove table metadata() failed. (error: %d) (oid: %d)", 
              (int) error, (int) object_id)));
      return result;
    }
  }
  result = true;

  return result;
}

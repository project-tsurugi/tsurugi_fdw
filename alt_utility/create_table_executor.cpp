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

#if 0
#include "frontend/message/ddl_message.h"
#include "frontend/message/message_broker.h"
#include "frontend/message/status.h"
#else
#include "manager/message/ddl_message.h"
#include "manager/message/message_broker.h"
#include "manager/message/status.h"
#endif

#include "manager/metadata/datatypes.h"
#include "manager/metadata/metadata.h"
#include "manager/metadata/tables.h"

#ifdef __cplusplus
extern "C"
{
#endif
#include "postgres.h"
#include "nodes/parsenodes.h"
#ifdef __cplusplus
}
#endif

#include "create_table_executor.h"
#include "stub_manager.h"
#include "create_table.h"
#include "send_message.h"

using namespace boost;
using namespace ogawayama;
using namespace manager;

/* DB name metadata-manager manages */
const std::string DBNAME = "Tsurugi";

manager::metadata::ObjectIdType store_metadata(
    std::unique_ptr<metadata::Metadata>& objects, 
    const property_tree::ptree& object);

bool remove_metadata(
    std::unique_ptr<metadata::Metadata>& objects, 
    const metadata::ObjectIdType object_id);

/**
 *  @brief Calls the function sending metadata to metadata-manager and creates parameters sended to ogawayama.
 *  @param [in] List of statements.
 */
bool create_table(CreateStmt* create_stmt)
{
  Assert(create_stmt != nullptr);

  bool ret_value{false};
  CreateTable create_table{create_stmt};

  /* check if given syntax supported or not by Tsurugi */
  if (!create_table.validate_syntax()) {
      return ret_value;
  }

  /* check if given type supported or not by Tsurugi */
  if (!create_table.validate_data_type()) {
      return ret_value;
  }

  property_tree::ptree table;
  bool success = create_table.generate_metadata(table);
  if (!success) {
    ereport(ERROR,
            (errcode(ERRCODE_INTERNAL_ERROR), 
            errmsg("CreateTable::generate_metadata() failed.")));
    return  ret_value;
  }

  std::unique_ptr<metadata::Metadata> tables = std::make_unique<metadata::Tables>(DBNAME);
  metadata::ObjectIdType object_id = store_metadata(tables, table);
  if (object_id == metadata::INVALID_OBJECT_ID) {
    ereport(ERROR,
            (errcode(ERRCODE_INTERNAL_ERROR),
            errmsg("Tsurugi could not store table metadata.")));
    return object_id;
  }

  /* sends message to ogawayama */
  manager::message::CreateTable create_table_message{object_id};
  success = send_message(create_table_message);
  if (!success) {
    remove_metadata(tables, object_id);
    ereport(ERROR,
            (errcode(ERRCODE_INTERNAL_ERROR), 
            errmsg("send_message() failed. (CreateTable Message)")));
    return ret_value;
  }

  ret_value = true;

  return ret_value;
}

/**
 * @brief   Store metadata to metadata-manager.
 * @param
 * @return
 */
metadata::ObjectIdType store_metadata(
    std::unique_ptr<metadata::Metadata>& objects, 
    const property_tree::ptree& object)
{
  metadata::ObjectIdType object_id = metadata::INVALID_OBJECT_ID;
  metadata::ErrorCode error = objects->add(object, &object_id);
  if (error != metadata::ErrorCode::OK ) {
    ereport(ERROR,
            (errcode(ERRCODE_INTERNAL_ERROR),
              errmsg("Tsurugi could not add metadata to metadata-manager. (error: %d)", 
              (int) error)));
    return object_id;
  }
  return object_id;
}

/**
 * @brief   Remove metadata from metadata-manager.
 * @param
 * @return
 */
bool remove_metadata(
    std::unique_ptr<metadata::Metadata>& objects, 
    const metadata::ObjectIdType object_id)
{
  bool ret_value = false;
  property_tree::ptree data;

  metadata::ErrorCode error = objects->get(object_id, data);  // ToDo: add exists() method.
  if (error == metadata::ErrorCode::OK) {
    error = objects->remove(object_id);
    if (error != metadata::ErrorCode::OK) {
      ereport(WARNING,
              (errcode(ERRCODE_INTERNAL_ERROR),
              errmsg("remove metadata() failed. (error: %d) (oid: %d)", 
              (int) error, (int) object_id)));
      return ret_value;
    }
  }

  ret_value = true;

  return ret_value;
}

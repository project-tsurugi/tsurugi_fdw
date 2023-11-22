/*
 * Copyright 2021-2023 Project Tsurugi.
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
 *	@file	table_managercmds.cpp
 *	@brief  Utility command to operate Table through metadata-manager.
 */

#include <boost/optional.hpp>
#include <iostream>
#include <string>

#include "manager/metadata/metadata.h"
#include "manager/metadata/tables.h"

using namespace manager::metadata;
using namespace boost::property_tree;

#ifdef __cplusplus
extern "C" {
#endif
#include "postgres.h"
#ifdef __cplusplus
}
#endif

#include "table_managercmds.h"

/**
 *  @brief  Get role id from metadata-manager by role name.
 *  @param  [in] dbname DB name metadata-manager manages.
 *  @param  [in] table_name Role name.
 *  @param  [out] object_id The object id getted if role was successfully
 * getted.
 *  @return true if role was successfully loaded, false otherwize.
 */
bool get_tableid_by_tablename(const std::string dbname, const char* table_name,
                            manager::metadata::ObjectId* object_id) {
  /* return value */
  bool ret_value = false;
  ptree object;
  /* Loads role */
  std::unique_ptr<manager::metadata::Metadata> tables =
      std::make_unique<Tables>(dbname);
  ErrorCode error = tables->get(std::string_view(table_name), object);

  if (error == ErrorCode::OK) {
    boost::optional<ObjectIdType> tmp_table_id =
        object.get_optional<ObjectIdType>(Tables::ID);
    if (!tmp_table_id) {
      ereport(ERROR,
              (errcode(ERRCODE_INTERNAL_ERROR), errmsg("Could not get table.")));
      return ret_value;
    }
    *object_id = tmp_table_id.get();
  } else {
    /* Not found metadata of talbe.*/
    return ret_value;
  }

  ret_value = true;
  return ret_value;
}



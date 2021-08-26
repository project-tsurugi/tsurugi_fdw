/*
 * Copyright 2021 tsurugi project.
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
 *	@file	rolecmds.cpp
 *	@brief  Sends metadata to metadata-manager.
 */

#include <boost/optional.hpp>
#include <iostream>
#include <string>

#include "manager/metadata/metadata.h"
#include "manager/metadata/roles.h"

using namespace manager::metadata;
using namespace boost::property_tree;

#ifdef __cplusplus
extern "C" {
#endif
#include "postgres.h"

#include "catalog/pg_class.h"
#include "nodes/nodes.h"
#include "nodes/parsenodes.h"
#include "nodes/value.h"
#ifdef __cplusplus
}
#endif

#include "rolecmds.h"

/**
 * @brief Initialize member variables.
 * @param [in] CreateRoleStmt of CREATE ROLE statements.
 * @param [in] dbname of DBNAME.
 */
CreateRole::CreateRole(CreateRoleStmt* stmts, std::string dbname)
    : create_stmt(stmts), dbname(dbname) {}

/**
 *  @brief  Defines role metadata, syntax check, type check,
 * storing metadata.
 *  @param  [out] The object id stored if new table was successfully created.
 *  @return true if metadata was successfully stored
 *  @return false otherwize
 */
bool CreateRole::check_role(uint64_t* object_id) {
  Assert(create_stmt != nullptr);

  /* return value */
  bool ret_value{false};

  /* get role */
  if (!get_role(object_id)) {
    return ret_value;
  }

  ret_value = true;
  return ret_value;
}

/**
 *  @brief  get role from metadata-manager.
 *  @param  [out] The object id stored if new role was successfully created.
 *  @return true if metadata was successfully loaded
 *  @return false otherwize.
 */
bool CreateRole::get_role(uint64_t* object_id) {
  /* return value */
  bool ret_value{false};
  ptree object;
  /* Loads role */
  roles = std::make_unique<Roles>(dbname);
  ErrorCode error = roles->get(std::string_view(create_stmt->role), object);

  if (error == ErrorCode::OK) {
    boost::optional<ObjectIdType> o_role_id =
        object.get_optional<ObjectIdType>(Roles::ROLE_OID);
    if (!o_role_id) {
      ereport(ERROR,
              (errcode(ERRCODE_INTERNAL_ERROR), errmsg("Could not get role.")));
      return ret_value;
    }
    *object_id = o_role_id.get();
  } else {
    ereport(ERROR,
            (errcode(ERRCODE_INTERNAL_ERROR), errmsg("Could not get role.")));
    return ret_value;
  }

  ret_value = true;
  return ret_value;
}

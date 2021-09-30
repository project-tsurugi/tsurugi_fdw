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
 *	@brief  Utility command to operate Role through metadata-manager.
 */

#include <boost/optional.hpp>
#include <iostream>
#include <string>

#include "manager/metadata/metadata.h"
#if 0
#include "manager/metadata/roles.h"
#else
#include "mock/metadata/roles.h"
#endif

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
 *  @brief  Get role id from metadata-manager by role name.
 *  @param  [in] dbname DB name metadata-manager manages.
 *  @param  [in] role_name Role name.
 *  @param  [out] object_id The object id stored if new role was successfully
 * created.
 *  @return true if role was successfully loaded, false otherwize.
 */
bool get_roleid_by_rolename(const std::string dbname, const char* role_name,
                            uint64_t* object_id) {
  /* return value */
  bool ret_value = false;
  ptree object;
  /* Loads role */
  std::unique_ptr<manager::metadata::Metadata> roles =
      std::make_unique<Roles>(dbname);
  ErrorCode error = roles->get(std::string_view(role_name), object);

  if (error == ErrorCode::OK) {
    boost::optional<ObjectIdType> tmp_role_id =
        object.get_optional<ObjectIdType>(Roles::ROLE_OID);
    if (!tmp_role_id) {
      ereport(ERROR,
              (errcode(ERRCODE_INTERNAL_ERROR), errmsg("Could not get role.")));
      return ret_value;
    }
    *object_id = tmp_role_id.get();
  } else {
    ereport(ERROR,
            (errcode(ERRCODE_INTERNAL_ERROR), errmsg("Could not get role.")));
    return ret_value;
  }

  ret_value = true;
  return ret_value;
}

/**
 *  @brief  Confirm role id from metadata-manager.
 *  @param  [in] dbname DB name metadata-manager manages.
 *  @param  [in] object_id Role id.
 *  @return True if the role exists, false if it does not.
 */
bool confirm_roleid(const std::string dbname, const uint64_t object_id) {
  /* return value */
  bool ret_value = false;
  ptree object;
  /* Loads role */
  std::unique_ptr<manager::metadata::Metadata> roles =
      std::make_unique<Roles>(dbname);
  ErrorCode error = roles->get(object_id, object);

  if (error != ErrorCode::OK) {
    return ret_value;
  }

  ret_value = true;
  return ret_value;
}

/**
 *  @brief: Remove the role object from metadata-manager.
 *  @param  [in] dbname DB name metadata-manager manages.
 *  @param  [in] object_id message object.
 *  @return true if role was successfully removed
 *  @return false otherwize.
 */
bool remove_role_by_roleid(const std::string dbname, const uint64_t object_id) {
  /* return value */
  bool ret_value = false;
  ptree object;

  std::unique_ptr<manager::metadata::Metadata> roles =
      std::make_unique<Roles>(dbname);
  ErrorCode error = roles->get(object_id, object);

  if (error == ErrorCode::OK) {
    error = roles->remove(object_id);
    if (error != ErrorCode::OK) {
      ereport(ERROR, (errcode(ERRCODE_INTERNAL_ERROR),
                      errmsg("Could not remove role.")));
      return ret_value;
    }
  } else {
    ereport(ERROR,
            (errcode(ERRCODE_INTERNAL_ERROR), errmsg("Could not get role.")));
    return ret_value;
  }

  ret_value = true;
  return ret_value;
}

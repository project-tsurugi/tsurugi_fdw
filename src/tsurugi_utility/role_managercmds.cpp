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
 *	@file	rolecmds.cpp
 *	@brief  Utility command to operate Role through metadata-manager.
 */

#include <boost/optional.hpp>
#include <iostream>
#include <string>

#include "manager/metadata/metadata.h"

#ifdef USEROLEMOCK
#include "mock/metadata/roles.h"
#else
#include "manager/metadata/roles.h"
#endif

using namespace manager::metadata;
using ptree = boost::property_tree::ptree;

#ifdef __cplusplus
extern "C" {
#endif
#include "postgres.h"
#ifdef __cplusplus
}
#endif

#include "role_managercmds.h"

/**
 *  @brief  Get role id from metadata-manager by role name.
 *  @param  [in] dbname DB name metadata-manager manages.
 *  @param  [in] role_name Role name.
 *  @param  [out] object_id The object id getted if role was successfully
 * getted.
 *  @return true if role was successfully loaded, false otherwize.
 */
bool get_roleid_by_rolename(const std::string dbname, const char* role_name,
                            manager::metadata::ObjectId* object_id) {
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
bool confirm_roleid(const std::string dbname, const manager::metadata::ObjectId object_id) {
  bool result = false;
  ptree object;
  std::unique_ptr<manager::metadata::Metadata> roles =
      std::make_unique<Roles>(dbname);

  /* Loads role */
  ErrorCode error = roles->get(object_id, object);
  if (error != ErrorCode::OK) {
    return result;
  }
  result = true;

  return result;
}

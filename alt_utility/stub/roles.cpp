/*
 * Copyright 2021 tsurugi project.
 *
 * Licensed under the Apache License, version 2.0 (the "License");
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
 */
#include <string>
#include "roles.h"

// =============================================================================
namespace {

// std::unique_ptr<manager::metadata::db::RolesProvider> provider = nullptr;

}  // namespace

// =============================================================================
namespace manager::metadata {

using manager::metadata::ErrorCode;

/**
 *  @brief  Constructor
 *  @param  (database) [in]  database name.
 *  @param  (component) [in]  component name.
 */
Roles::Roles(std::string_view database, std::string_view component)
    : Metadata(database, component) {
}

/**
 *  @brief  Initialization.
 *  @param  none.
 *  @return  ErrorCode::OK if success, otherwise an error code.
 */
ErrorCode Roles::init() {
  ErrorCode error = ErrorCode::OK;

  return error;
}

void create_object(boost::property_tree::ptree& object) {
  object.add(Roles::ROLE_OID, "1");
  object.add(Roles::ROLE_ROLNAME, "sample_role");
  object.add(Roles::ROLE_ROLSUPER, "true");
  object.add(Roles::ROLE_ROLINHERIT, "flse");
  object.add(Roles::ROLE_ROLCREATEROLE, "true");
  object.add(Roles::ROLE_ROLCREATEDB, "flse");
  object.add(Roles::ROLE_ROLCANLOGIN, "true");
  object.add(Roles::ROLE_ROLREPLICATION, "false");
  object.add(Roles::ROLE_ROLBYPASSRLS, "false");
  object.add(Roles::ROLE_ROLCONNLIMIT, "-1");
  object.add(Roles::ROLE_ROLPASSWORD, "password_secret");
  object.add(Roles::ROLE_ROLVALIDUNTIL, "");
}

/**
 *  @brief  Get role object based on role id.
 *  @param  (object_id) [in]  role id.
 *  @param  (object)    [out] role with the specified ID.
 *  @return ErrorCode::OK if success, otherwise an error code.
 */
ErrorCode Roles::get(const ObjectIdType object_id,
                     boost::property_tree::ptree& object) {
  if (object_id <= 0) {
    return ErrorCode::ID_NOT_FOUND;
  }

  create_object(object);

  boost::optional<int64_t> role_object_id = object.get_optional<int64_t>(ROLE_OID);
  if (role_object_id != object_id) {
    return ErrorCode::ID_NOT_FOUND;
  }

  return ErrorCode::OK;
}

/**
 *  @brief  Get role object based on role name.
 *  @param  (object_name)   [in]  role name.
 *  @param  (object)        [out] role object with the specified name.
 *  @return ErrorCode::OK if success, otherwise an error code.
 */
ErrorCode Roles::get(std::string_view object_name,
                     boost::property_tree::ptree& object) {
  if (object_name.empty()) {
    return ErrorCode::NAME_NOT_FOUND;
  }

  create_object(object);

  boost::optional<std::string> role_name = object.get_optional<std::string>(ROLE_ROLNAME);
  if (role_name.get() != object_name) {
    return ErrorCode::NAME_NOT_FOUND;
  }

  return ErrorCode::OK;
}

}  // namespace manager::metadata

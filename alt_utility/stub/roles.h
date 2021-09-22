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
#ifndef MANAGER_METADATA_ROLES_H_
#define MANAGER_METADATA_ROLES_H_

#include "manager/metadata/metadata.h"

namespace manager::metadata {

class Roles : public Metadata {
 public:
  // root node.
  static constexpr const char* const ROLES_NODE = "Roles";

  // role metadata-object.
  // ID is defined in base class.
  // NAME is defined in base class.
  static constexpr const char* const ROLE_OID = "oid";
  static constexpr const char* const ROLE_ROLNAME = "rolname";
  static constexpr const char* const ROLE_ROLSUPER = "rolsuper";
  static constexpr const char* const ROLE_ROLINHERIT = "rolinherit";
  static constexpr const char* const ROLE_ROLCREATEROLE = "rolcreaterole";
  static constexpr const char* const ROLE_ROLCREATEDB = "rolcreatedb";
  static constexpr const char* const ROLE_ROLCANLOGIN = "rolcanlogin";
  static constexpr const char* const ROLE_ROLREPLICATION = "rolreplication";
  static constexpr const char* const ROLE_ROLBYPASSRLS = "rolbypassrls";
  static constexpr const char* const ROLE_ROLCONNLIMIT = "rolconnlimit";
  static constexpr const char* const ROLE_ROLPASSWORD = "rolpassword";
  static constexpr const char* const ROLE_ROLVALIDUNTIL = "rolvaliduntil";

  Roles(std::string_view database, std::string_view component = "visitor");

  Roles(const Roles&) = delete;
  Roles& operator=(const Roles&) = delete;

  ErrorCode init() override;
  ErrorCode get(const ObjectIdType object_id,
                boost::property_tree::ptree& object) override;
  ErrorCode get(std::string_view object_name,
                boost::property_tree::ptree& object) override;

  ErrorCode add(boost::property_tree::ptree& object) override {
    return ErrorCode::OK;
  }
  ErrorCode add(boost::property_tree::ptree& object, ObjectIdType* object_id) override {
    return ErrorCode::OK;
  }

  ErrorCode remove(const ObjectIdType object_id) override {
    return ErrorCode::OK;
  }
  ErrorCode remove(const char* object_name, ObjectIdType* object_id) override {
    return ErrorCode::OK;
  }
};  // class Roles

}  // namespace manager::metadata

#endif  // MANAGER_METADATA_ROLES_H_

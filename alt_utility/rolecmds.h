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
 *	@file	rolecmds.h
 *	@brief  Sends role to metadata-manager.
 */

#ifndef ROLECMDS_H
#define ROLECMDS_H

class CreateRole {
 public:
  /**
   * @brief Initialize member variables.
   * @param [in] CreateRoleStmt of CREATE ROLE statements.
   * @param [in] dbname of DBNAME.
   */
  CreateRole(CreateRoleStmt* stmts, std::string dbname);

  /**
   *  @brief  Check created role object.
   *  @param  [out] The object id if new role was successfully created.
   *  @return true if role was created successfully
   *  @return false otherwize
   */
  bool check_role(uint64_t* object_id);

 private:
  /* DB name metadata-manager manages */
  const std::string dbname;
  /* Create Role Statement */
  CreateRoleStmt* create_stmt;

  /* role metadata obtained from metadata-manager */
  std::unique_ptr<manager::metadata::Metadata> roles;

  /**
   *  @brief  Get role from metadata-manager.
   *  @param  [out] The object id if new role was successfully created.
   *  @return true if role was successfully created
   *  @return false otherwize.
   */
  bool get_role(uint64_t* object_id);
};

#endif  // ROLECMDS_H

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
 *	@brief  Utility command to operate Role through metadata-manager.
 */

#ifndef ROLECMDS_H
#define ROLECMDS_H

/**
 *  @brief  get role id from metadata-manager by role name.
 *  @param  [in] Role name.
 *  @param  [out] The object id stored if new role was successfully created.
 *  @return true if role was successfully loaded
 *  @return false otherwize.
 */
bool get_roleid_by_rolename(const std::string dbname, const char* role_name,
                            uint64_t* object_id);

/**
 *  @brief: Remove the role object from metadata-manager.
 *  @param  (dbname)  [in]  DB name metadata-manager manages.
 *  @param  (object_id) [in]  message object.
 *  @return true if role was successfully removed
 *  @return false otherwize.
 */
bool remove_role_by_roleid(const std::string dbname, const uint64_t object_id);

#endif  // ROLECMDS_H

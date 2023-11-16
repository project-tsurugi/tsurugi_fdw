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
 * Portions Copyright (c) 1996-2023, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, The Regents of the University of California
 *
 *	@file	role_managercmds.h
 *	@brief  Utility command to operate Role through metadata-manager.
 */

#ifndef ROLEMANAGERCMDS_H
#define ROLEMANAGERCMDS_H

#include "manager/metadata/metadata.h"

/**
 *  @brief  Get role id from metadata-manager by role name.
 *  @param  [in] dbname DB name metadata-manager manages.
 *  @param  [in] role_name Role name.
 *  @param  [out] object_id The object id getted if role was successfully
 * getted.
 *  @return true if role was successfully loaded, false otherwize.
 */
bool get_roleid_by_rolename(const std::string dbname, const char* role_name,
                            manager::metadata::ObjectId* object_id);

/**
 *  @brief  Confirm role id from metadata-manager.
 *  @param  [in] dbname DB name metadata-manager manages.
 *  @param  [in] object_id Role id.
 *  @return True if the role exists, false if it does not.
 */
bool confirm_roleid(const std::string dbname, const manager::metadata::ObjectId object_id);

#endif  // ROLEMANAGERCMDS_H

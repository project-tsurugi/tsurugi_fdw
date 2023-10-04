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
 *	@file	table_managercmds.h
 *	@brief  Utility command to operate Table through metadata-manager.
 */

#ifndef TABLEMANAGERCMDS_H
#define TABLEMANAGERCMDS_H

#include "manager/metadata/metadata.h"

/**
 *  @brief  get table id from metadata-manager by table name.
 *  @param  [in] dbname DB name metadata-manager manages.
 *  @param  [in] table_name Table name.
 *  @param  [out] object_id The object id getted if role was successfully
 * getted.
 *  @return true if role was successfully loaded, false otherwize.
 */
bool get_tableid_by_tablename(const std::string dbname, const char* table_name,
                            	manager::metadata::ObjectId* object_id);
                            
#endif  // TABLEMANAGERCMDS_H

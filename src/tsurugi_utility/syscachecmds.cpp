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
 *	@file	syscachecmds.cpp
 *	@brief  Utility command to operate through SysCache.
 */

#include <iostream>
#include <string>
#include "manager/metadata/metadata.h"

#ifdef __cplusplus
extern "C" {
#endif
#include "postgres.h"

#include "access/htup_details.h"
#include "catalog/pg_authid.h"
#include "nodes/value.h"
#include "utils/syscache.h"
#ifdef __cplusplus
}
#endif

#include "syscachecmds.h"

using namespace manager;

/**
 *  @brief  Get role id by role name from SysCache.
 *  @param  [in] role_name Role name.
 *  @param  [out] object_id The object id getted if role was successfully
 * getted.
 *  @return true if role was successfully loaded, false otherwize.
 */
bool get_roleid_by_rolename_from_syscache(const char* role_name,
                                          manager::metadata::ObjectId* object_id) {
  /* return value */
  bool ret_value = false;
  HeapTuple tuple;
  Form_pg_authid authform;
  /* Loads role */
  tuple = SearchSysCache1(AUTHNAME, PointerGetDatum(role_name));
  if (!HeapTupleIsValid(tuple)) {
    ereport(ERROR,
            (errcode(ERRCODE_INTERNAL_ERROR), errmsg("Could not get role.")));
    return ret_value;
  }
  authform = (Form_pg_authid) GETSTRUCT(tuple);
  *object_id = static_cast<metadata::ObjectId>(authform->oid);

  ReleaseSysCache(tuple);
  ret_value = true;
  return ret_value;
}

/**
 *  @brief  Confirm role id from SysCache.
 *  @param  [in] object_id Role id.
 *  @return True if the role exists, false if it does not.
 */
bool confirm_roleid_from_syscache(const int64_t object_id) {
  /* return value */
  bool ret_value = false;
  HeapTuple tuple;
  tuple = SearchSysCache1(AUTHOID, PointerGetDatum(object_id));

  if (!HeapTupleIsValid(tuple)) {
    return ret_value;
  }

  ret_value = true;
  return ret_value;
}

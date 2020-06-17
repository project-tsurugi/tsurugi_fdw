/*
 * Copyright 2020-2020 tsurugi project.
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
 *	@file	tablecmds.cpp
 *	@brief
 */

#ifdef __cplusplus
extern "C" {
#endif

#include <postgres.h>

#include "nodes/nodes.h"
#include "nodes/parsenodes.h"
#include "utils/palloc.h"

#ifdef __cplusplus
}
#endif

#include <iostream>
#include "tablecmds.h"

/*
 *  @brief:
 */
bool define_relation(CreateStmt *stmt)
{
    Assert(stmt != nullptr);

    char *create_stmt;
    create_stmt = nodeToString(stmt);

    std::cout << "nodeToString: " << create_stmt << "\n" << std::endl;
    pfree(create_stmt);

    bool success = true;
    if (!success)
    {
        elog(ERROR, "define_relation() failed.");
    }

    return success;
}

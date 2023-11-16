/*
 * Copyright 2023 Project Tsurugi.
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
 *	@file	drop_stmt.c
 */
#include "utility_common.h"
#include "drop_table_executor.h"
#include "drop_index_executor.h"
#include "drop_stmt.h"

/**
 * @brief 	Drop statment processing.
 * @param	drop_stmt [in] Pointer of drop statement structure.
 */
void execute_drop_stmt(DropStmt *drop_stmt)
{
	ObjectName obj;
	ListCell *cell;
	foreach(cell, drop_stmt->objects)
	{
		List *names = (List *) lfirst(cell);
		get_object_name(names, &obj);
		
		switch (drop_stmt->removeType)
		{
			case OBJECT_TABLE:
			{
				bool success = execute_drop_table(drop_stmt, obj.object_name);
				if (!success) {
					elog(ERROR, "execute_drop_table() failed.");
				}	
				break;
			}
			case OBJECT_INDEX:
			{
				bool success = execute_drop_index(drop_stmt, obj.object_name);
				if (!success) {
					elog(ERROR, "execute_drop_index() failed.");
				}	
				break;
			}
			default:
			{
				elog(ERROR, "Unexpected removeType. (type: %x)", 
					drop_stmt->removeType);
				break;
			}
		}
	}
}

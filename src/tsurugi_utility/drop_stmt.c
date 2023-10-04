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
 *	@file	drop_stmt.c
 */
#include "drop_stmt.h"
#include "drop_table_executor.h"

/**
 * @brief	Extract table name to drop.
 * @param	names [in] namespace list.
 * @param	rel [out] structre for storing table name.
 */
void get_relname(List *names, RangeVar *rel)
{
	switch (list_length(names))
	{
		case 1:
		{
			// table name only.
			rel->relname = strVal(linitial(names));
			break;
		}
		case 2:
		{
			// schema name and table name.
			rel->schemaname = strVal(linitial(names));
			rel->relname = strVal(lsecond(names));
			break;
		}
		case 3:
		{
			// database naem, schema name and table name.
			rel->catalogname = strVal(linitial(names));
			rel->schemaname = strVal(lsecond(names));
			rel->relname = strVal(lthird(names));
			break;
		}
		default:
		{
			elog(ERROR, "improper relation name (too many dotted names).");
			break;
		}
	}
}

/**
 * @brief 	Drop statment processing.
 * @param	drop_stmt [in] Pointer of drop statement structure.
 */
void execute_drop_stmt(DropStmt *drop_stmt)
{
	bool success;
	RangeVar rel;
	ListCell *cell;
	foreach(cell, drop_stmt->objects)
	{
		List *names = (List *) lfirst(cell);
		get_relname(names, &rel);
		success = execute_drop_table(drop_stmt, rel.relname);
		if (!success) {
			elog(ERROR, "drop_table() failed.");
		}
	}
}

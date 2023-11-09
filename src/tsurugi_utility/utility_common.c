/*
 * Copyright 2019-2022 tsurugi project.
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
 */
#include "postgres.h"
#include "nodes/value.h"
#include "utility_common.h"

void get_object_name(
	List *names, ObjectName *obj)
{
	switch (list_length(names))
	{
		case 1:
		{
			// object name only. e.g. table, index, ...
			obj->object_name = strVal(linitial(names));
			break;
		}
		case 2:
		{
			// schema name and object name.
			obj->schema_name = strVal(linitial(names));
			obj->object_name = strVal(lsecond(names));
			break;
		}
		case 3:
		{
			// database name, schema name and object name.
			obj->database_name = strVal(linitial(names));
			obj->schema_name = strVal(lsecond(names));
			obj->object_name = strVal(lthird(names));
			break;
		}
		default:
		{
			elog(ERROR, "improper names (too many dotted names).");
			break;
		}
	}
}

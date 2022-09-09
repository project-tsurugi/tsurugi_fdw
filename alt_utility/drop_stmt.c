#include "drop_stmt.h"

void execute_drop_stmt(DropStmt *drop_stmt)
{
	bool success;
	ListCell *cell;
	foreach(cell, drop_stmt->objects)
	{
		RangeVar rel;
		List *names = (List *) lfirst(cell);
		switch (list_length(names))
		{
			case 1:
			{
				// table name only.
				rel.relname = strVal(linitial(names));
				break;
			}
			case 2:
			{
				// schema name and table name.
				rel.schemaname = strVal(linitial(names));
				rel.relname = strVal(lsecond(names));
				break;
			}
			case 3:
			{
				// database naem, schema name and table name.
				rel.catalogname = strVal(linitial(names));
				rel.schemaname = strVal(lsecond(names));
				rel.relname = strVal(lthird(names));
				break;
			}
			default:
			{
				elog(ERROR, "improper relation name (too many dotted names).");
				break;
			}
		}

		success = execute_drop_table(drop_stmt, rel.relname);
		if (!success) {
			elog(ERROR, "drop_table() failed.");
		}
	}
//	RemoveRelations(drop);

}
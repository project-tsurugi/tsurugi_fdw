#include "postgres.h"
#include "nodes/parsenodes.h"

void get_relname(List *names, RangeVar *rel);
void execute_drop_stmt(DropStmt *drop_stmt);


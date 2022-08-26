#pragma once

#include "postgres.h"
#include "tcop/utility.h"
#include "catalog/objectaddress.h"
#include "catalog/pg_class_d.h"
#include "access/reloptions.h"
#include "commands/event_trigger.h"
#include "commands/tablecmds.h"

void index_stmt(PlannedStmt *pstmt,
                const char *queryString,
                ParamListInfo params);

#pragma once

#include "postgres.h"
#include "nodes/plannodes.h"
#include "nodes/params.h"
#include "nodes/pg_list.h"

void execute_create_stmt(PlannedStmt* pstmt,
                          const char* queryString,
                          ParamListInfo params,
                          List* stmts);

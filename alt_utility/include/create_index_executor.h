#pragma once

#ifdef __cplusplus
extern "C" {
#endif
#include "postgres.h"
#include "nodes/parsenodes.h"

void execute_create_index(IndexStmt* index_stmt);

#ifdef __cplusplus
}
#endif

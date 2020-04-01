#include "postgres.h"
#include "optimizer/planner.h"
#include "tcop/utility.h"

//#include "catalog/objectaddress.h"
//#include "catalog/pg_class_d.h"
//#include "access/reloptions.h"

extern PGDLLIMPORT planner_hook_type planner_hook;
extern PGDLLIMPORT ProcessUtility_hook_type ProcessUtility_hook;
extern void _PG_init(void);
extern PlannedStmt *alt_planner(Query *parse2, int cursorOptions, ParamListInfo boundParams);
extern void tsurugi_ProcessUtility(PlannedStmt *pstmt, 
                            	   const char *query_string, ProcessUtilityContext context, 
                            	   ParamListInfo params, 
                            	   QueryEnvironment *queryEnv, 
                            	   DestReceiver *dest, char *completionTag);

void
_PG_init(void)
{
  planner_hook = alt_planner;
  ProcessUtility_hook = tsurugi_ProcessUtility;
}

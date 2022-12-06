/*
 * Copyright 2019-2019 tsurugi project.
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
 *	@file	ogawayama_fdw.cpp
 *	@brief 	Foreign Data Wrapper for Ogawayama.
 */
#include <string>
#include <memory>
#include "ogawayama/stub/error_code.h"
#include "ogawayama/stub/api.h"
#include "stub_manager.h"

#ifdef __cplusplus
extern "C" {
#endif

#include "postgres.h"

#include "ogawayama_fdw.h"

#if 0
#include "access/htup.h"
#include "access/htup_details.h"
#include "catalog/pg_type.h"
#include "foreign/fdwapi.h"
#include "optimizer/pathnode.h"
#include "optimizer/planmain.h"
#include "optimizer/restrictinfo.h"
#include "optimizer/cost.h"
#include "storage/proc.h"
#include "utils/fmgrprotos.h"
#include "utils/memutils.h"
#endif

#include "access/xact.h"
#include "utils/syscache.h"

// postgres_fdwから流用
#include "access/htup_details.h"
#include "access/sysattr.h"
#include "access/table.h"
#include "catalog/pg_class.h"
#include "commands/defrem.h"
#include "commands/explain.h"
#include "commands/vacuum.h"
#include "foreign/fdwapi.h"
#include "funcapi.h"
#include "miscadmin.h"
#include "nodes/makefuncs.h"
#include "nodes/nodeFuncs.h"
#include "optimizer/clauses.h"
#include "optimizer/cost.h"
#include "optimizer/optimizer.h"
#include "optimizer/pathnode.h"
#include "optimizer/paths.h"
#include "optimizer/planmain.h"
#include "optimizer/restrictinfo.h"
#include "optimizer/tlist.h"
#include "parser/parsetree.h"
#include "utils/builtins.h"
#include "utils/float.h"
#include "utils/guc.h"
#include "utils/lsyscache.h"
#include "utils/memutils.h"
#include "utils/rel.h"
#include "utils/sampling.h"
#include "utils/selfuncs.h"

PG_MODULE_MAGIC;

#ifdef __cplusplus
}
#endif

using namespace ogawayama;

/* Default CPU cost to start up a foreign query. */
#define DEFAULT_FDW_STARTUP_COST	100.0

/* Default CPU cost to process 1 row (above and beyond cpu_tuple_cost). */
#define DEFAULT_FDW_TUPLE_COST		0.01

/* If no remote estimates, assume a sort costs 20% extra */
#define DEFAULT_FDW_SORT_MULTIPLIER 1.2

/*
 * Indexes of FDW-private information stored in fdw_private lists.
 *
 * These items are indexed with the enum FdwScanPrivateIndex, so an item
 * can be fetched with list_nth().  For example, to get the SELECT statement:
 *		sql = strVal(list_nth(fdw_private, FdwScanPrivateSelectSql));
 */
enum FdwScanPrivateIndex
{
	/* SQL statement to execute remotely (as a String node) */
	FdwScanPrivateSelectSql,
	/* Integer list of attribute numbers retrieved by the SELECT */
	FdwScanPrivateRetrievedAttrs,
	/* Integer representing the desired fetch_size */
	FdwScanPrivateFetchSize,

	/*
	 * String describing join i.e. names of relations being joined and types
	 * of join, added when the scan is join
	 */
	FdwScanPrivateRelations
};

#define DEFAULT_FETCH_SIZE (10000)
typedef struct row_data_
{
	size_t 		number_of_columns;		/* SELECT対象の列数 */
	Oid* 		column_data_types; 		/* SELECT予定の列のデータ型(Oid)用のポインタ */
} RowData;
/*
 *	@brief	クエリー実行毎のFDWの状態
 */
typedef struct ogawayama_fdw_state_
{
	bool 			cursor_exists;			
	const char* 	query_string;		/* SQL Query Text */
	size_t 			number_of_columns;	/* SELECT対象の列数 */
	Oid* 			column_types; 		/* SELECT予定の列のデータ型(Oid)用のポインタ */
	RowData			row;
	MemoryContext 	batch_cxt;			
	std::vector<TupleTableSlot*> tuples;
	decltype(tuples)::iterator tuple_ite;
	size_t			fetch_size;
	size_t			num_tuples;
	size_t			next_tuple;
	bool			eof_reached;
} OgawayamaFdwState;

/*
 *	@brief 	セッションごとのFDWの状態
 */
typedef struct
{
	stub::Transaction*	transaction = nullptr;
 	ResultSetPtr 		result_set = nullptr;
	MetadataPtr 		metadata = nullptr;
	int 				xact_level = 0;		/* FDWが自認する現在のトランザクションレベル */
} OgawayamaFdwInfo;

/*
 * Execution state of a foreign insert/update/delete operation.
 */
typedef struct tsurugiFdwModifyState
{
	Relation	rel;			/* relcache entry for the foreign table */
	AttInMetadata *attinmeta;	/* attribute datatype conversion metadata */

	/* for remote query execution */
//	PGconn	   *conn;			/* connection for the scan */
	char	   *p_name;			/* name of prepared statement, if created */

	/* extracted fdw_private data */
	char	   *query;			/* text of INSERT/UPDATE/DELETE command */
	List	   *target_attrs;	/* list of target attribute numbers */
	bool		has_returning;	/* is there a RETURNING clause? */
	List	   *retrieved_attrs;	/* attr numbers retrieved by RETURNING */

	/* info about parameters for prepared statement */
	AttrNumber	ctidAttno;		/* attnum of input resjunk ctid column */
	int			p_nums;			/* number of parameters to transmit */
	FmgrInfo   *p_flinfo;		/* output conversion functions for them */

	/* working memory context */
	MemoryContext temp_cxt;		/* context for per-tuple temporary data */

	/* for update row movement if subplan result rel */
	struct tsurugiFdwModifyState *aux_fmstate;	/* foreign-insert state, if
											 * created */
} tsurugiFdwModifyState;

/*
 * This enum describes what's kept in the fdw_private list for a ForeignPath.
 * We store:
 *
 * 1) Boolean flag showing if the remote query has the final sort
 * 2) Boolean flag showing if the remote query has the LIMIT clause
 */
enum FdwPathPrivateIndex
{
	/* has-final-sort flag (as an integer Value node) */
	FdwPathPrivateHasFinalSort,
	/* has-limit flag (as an integer Value node) */
	FdwPathPrivateHasLimit
};

/* Callback argument for ec_member_matches_foreign */
typedef struct
{
	Expr	   *current;		/* current expr, or NULL if not yet found */
	List	   *already_used;	/* expressions already dealt with */
} ec_member_foreign_arg;

/* Struct for extra information passed to estimate_path_cost_size() */
typedef struct
{
	PathTarget *target;
	bool		has_final_sort;
	bool		has_limit;
	double		limit_tuples;
	int64		count_est;
	int64		offset_est;
} PgFdwPathExtraData;

#ifdef __cplusplus
extern "C" {
#endif
/*
 * SQL functions
 */
PG_FUNCTION_INFO_V1(ogawayama_fdw_handler);

/*
 * FDW callback routines (Scan)
 */
static void tsurugiGetForeignRelSize(PlannerInfo* root, 
									   RelOptInfo* baserel, 
								   	   Oid foreigntableid);
static void tsurugiGetForeignPaths(PlannerInfo *root,
									RelOptInfo *baserel,
									Oid foreigntableid);
static ForeignScan *tsurugiGetForeignPlan(PlannerInfo *root,
											RelOptInfo *foreignrel,
											Oid foreigntableid,
											ForeignPath *best_path,
											List *tlist,
											List *scan_clauses,
											Plan *outer_plan);
static void tsurugiBeginForeignScan(ForeignScanState* node, int eflags);
static TupleTableSlot* tsurugiIterateForeignScan(ForeignScanState* node);
static void tsurugiReScanForeignScan(ForeignScanState* node);
static void tsurugiEndForeignScan(ForeignScanState* node);

/*
 * FDW callback routines (Insert/Update/Delete)
 */
static void tsurugiAddForeignUpdateTargets(Query *parsetree,
											RangeTblEntry *target_rte,
											Relation target_relation);
static List *tsurugiPlanForeignModify(PlannerInfo *root,
									   ModifyTable *plan,
									   Index resultRelation,
									   int subplan_index);
static void tsurugiBeginForeignModify(ModifyTableState *mtstate,
									   ResultRelInfo *resultRelInfo,
									   List *fdw_private,
									   int subplan_index,
									   int eflags);
static TupleTableSlot* tsurugiExecForeignInsert(EState *estate,
												 ResultRelInfo *rinfo,
												 TupleTableSlot *slot,
												 TupleTableSlot *planSlot);
static TupleTableSlot* tsurugiExecForeignUpdate(EState *estate,
												 ResultRelInfo *rinfo,
												 TupleTableSlot *slot,
												 TupleTableSlot *planSlot);
static TupleTableSlot* tsurugiExecForeignDelete(EState *estate,
												 ResultRelInfo *rinfo,
												 TupleTableSlot *slot,
												 TupleTableSlot *planSlot);
static void tsurugiEndForeignModify(EState *estate,
									 ResultRelInfo *resultRelInfo);
static void tsurugiBeginForeignInsert(ModifyTableState *mtstate,
									   ResultRelInfo *resultRelInfo);
static void tsurugiEndForeignInsert(EState *estate,
									 ResultRelInfo *resultRelInfo);
static int	tsurugiIsForeignRelUpdatable(Relation rel);

static bool tsurugiPlanDirectModify(PlannerInfo *root,
									 ModifyTable *plan,
									 Index resultRelation,
									 int subplan_index);
static void tsurugiBeginDirectModify(ForeignScanState* node, int eflags);
static TupleTableSlot* tsurugiIterateDirectModify(ForeignScanState* node);
static void tsurugiEndDirectModify(ForeignScanState* node);

/*
 * FDW callback routines (Others)
 */
static void tsurugiExplainForeignScan(ForeignScanState* node, 
									    ExplainState* es);
static void tsurugiExplainDirectModify(ForeignScanState* node, 
										 ExplainState* es);
static bool tsurugiAnalyzeForeignTable(
	Relation relation, AcquireSampleRowsFunc* func, BlockNumber* totalpages);
static List* tsurugiImportForeignSchema(ImportForeignSchemaStmt* stmt, 
										  Oid serverOid);

static void tsurugiGetForeignJoinPaths(PlannerInfo *root,
										RelOptInfo *joinrel,
										RelOptInfo *outerrel,
										RelOptInfo *innerrel,
										JoinType jointype,
										JoinPathExtraData *extra);
static void tsurugiGetForeignUpperPaths(PlannerInfo *root,
										 UpperRelationKind stage,
										 RelOptInfo *input_rel,
										 RelOptInfo *output_rel,
										 void *extra);

#ifdef __cplusplus
}
#endif

/*
 * Helper functions
 */
static OgawayamaFdwState* create_fdwstate();
static void free_fdwstate(OgawayamaFdwState* fdw_state);
static void store_pg_data_type(OgawayamaFdwState* fdw_state, List* tlist);
static bool confirm_columns(MetadataPtr metadata, ForeignScanState* node);
static void create_cursor(ForeignScanState* node);
static void fetch_more_data(ForeignScanState* node);
static void make_virtual_tuple(TupleTableSlot* slot, ForeignScanState* node);
static TupleTableSlot* make_tuple_from_result_set(ResultSetPtr result_set, 
												  OgawayamaFdwState* fdw_state);
static void begin_backend_xact(void);
static void tsurugi_xact_callback (XactEvent event, void *arg);

/* 
 * Helper functions of postgres_fdw 
 */
static void estimate_path_cost_size(PlannerInfo *root,
									RelOptInfo *foreignrel,
									List *param_join_conds,
									List *pathkeys,
									PgFdwPathExtraData *fpextra,
									double *p_rows, int *p_width,
									Cost *p_startup_cost, Cost *p_total_cost);
static bool ec_member_matches_foreign(PlannerInfo *root, RelOptInfo *rel,
									  EquivalenceClass *ec, EquivalenceMember *em,
									  void *arg);
static bool foreign_join_ok(PlannerInfo *root, RelOptInfo *joinrel,
							JoinType jointype, RelOptInfo *outerrel, RelOptInfo *innerrel,
							JoinPathExtraData *extra);
static List *get_useful_pathkeys_for_relation(PlannerInfo *root,
											  RelOptInfo *rel);
static void add_paths_with_pathkeys_for_rel(PlannerInfo *root, RelOptInfo *rel,
											Path *epq_path);
static void add_foreign_grouping_paths(PlannerInfo *root,
									   RelOptInfo *input_rel,
									   RelOptInfo *grouped_rel,
									   GroupPathExtraData *extra);
static void add_foreign_ordered_paths(PlannerInfo *root,
									  RelOptInfo *input_rel,
									  RelOptInfo *ordered_rel);
static void add_foreign_final_paths(PlannerInfo *root,
									RelOptInfo *input_rel,
									RelOptInfo *final_rel,
									FinalPathExtraData *extra);
static void apply_table_options(tsurugiFdwRelationInfo *fpinfo);
static void merge_fdw_options(tsurugiFdwRelationInfo *fpinfo,
							  const tsurugiFdwRelationInfo *fpinfo_o,
							  const tsurugiFdwRelationInfo *fpinfo_i);
static List *build_remote_returning(Index rtindex, Relation rel,
									List *returningList);
static void rebuild_fdw_scan_tlist(ForeignScan *fscan, List *tlist);

extern PGDLLIMPORT PGPROC *MyProc;

static OgawayamaFdwInfo fdw_info_;

/*
 * Foreign-data wrapper handler function: return a struct with pointers
 * to my callback routines.
 */
Datum
ogawayama_fdw_handler(PG_FUNCTION_ARGS)
{
	elog(DEBUG2, "tsurugi_fdw : %s", __func__);

	FdwRoutine* routine = makeNode(FdwRoutine);

	/*Functions for scanning foreign tables*/
	routine->GetForeignRelSize = tsurugiGetForeignRelSize;
	routine->GetForeignPaths = tsurugiGetForeignPaths;
	routine->GetForeignPlan = tsurugiGetForeignPlan;
	routine->BeginForeignScan = tsurugiBeginForeignScan;
	routine->IterateForeignScan = tsurugiIterateForeignScan;
	routine->ReScanForeignScan = tsurugiReScanForeignScan;
	routine->EndForeignScan = tsurugiEndForeignScan;

	/*Functions for updating foreign tables*/
	routine->AddForeignUpdateTargets = tsurugiAddForeignUpdateTargets;
	routine->PlanForeignModify = tsurugiPlanForeignModify;
//	routine->BeginForeignModify = tsurugiBeginForeignModify;
	routine->ExecForeignInsert = tsurugiExecForeignInsert;
	routine->ExecForeignUpdate = tsurugiExecForeignUpdate;
	routine->ExecForeignDelete = tsurugiExecForeignDelete;
	routine->EndForeignModify = tsurugiEndForeignModify;
//	routine->BeginForeignInsert = tsurugiBeginForeignInsert;
//	routine->EndForeignInsert = tsurugiEndForeignInsert;
//	routine->IsForeignRelUpdatable = tsurugiIsForeignRelUpdatable;
	routine->PlanDirectModify = tsurugiPlanDirectModify;
	routine->BeginDirectModify = tsurugiBeginDirectModify;
	routine->IterateDirectModify = tsurugiIterateDirectModify;
	routine->EndDirectModify = tsurugiEndDirectModify;

	/*Support functions for EXPLAIN*/
	routine->ExplainForeignScan = tsurugiExplainForeignScan;
	routine->ExplainDirectModify = tsurugiExplainDirectModify;

	/*Support functions for ANALYZE*/
	routine->AnalyzeForeignTable = tsurugiAnalyzeForeignTable;

	/*Support functions for IMPORT FOREIGN SCHEMA*/
	routine->ImportForeignSchema = tsurugiImportForeignSchema;

	/* Support functions for join push-down */
	routine->GetForeignJoinPaths = tsurugiGetForeignJoinPaths;

	/* Support functions for upper relation push-down */
	routine->GetForeignUpperPaths = tsurugiGetForeignUpperPaths;

	ERROR_CODE error = StubManager::init();
	if (error != ERROR_CODE::OK) 
	{
		elog(ERROR, "StubManager::init() failed. (%d)", (int) error);
	}

	PG_RETURN_POINTER(routine);
}

/* FDW Plan functions */

/*
 *	
 */
static void tsurugiGetForeignRelSize(
	PlannerInfo* root, RelOptInfo* baserel, Oid foreigntableid)
{
	tsurugiFdwRelationInfo *fpinfo;
	ListCell   *lc;
	RangeTblEntry *rte = planner_rt_fetch(baserel->relid, root);
	const char *namespace_string;
	const char *relname;
	const char *refname;

	elog(DEBUG2, "tsurugi_fdw : %s", __func__);

	/*
	 * We use tsurugiFdwRelationInfo to pass various information to subsequent
	 * functions.
	 */
	fpinfo = (tsurugiFdwRelationInfo *) palloc0(sizeof(tsurugiFdwRelationInfo));
	baserel->fdw_private = (void *) fpinfo;

	/* Base foreign tables need to be pushed down always. */
	fpinfo->pushdown_safe = true;

	/* Look up foreign-table catalog info. */
	fpinfo->table = GetForeignTable(foreigntableid);
	fpinfo->server = GetForeignServer(fpinfo->table->serverid);

	/*
	 * Extract user-settable option values.  Note that per-table setting of
	 * use_remote_estimate overrides per-server setting.
	 */
	fpinfo->use_remote_estimate = false;
	fpinfo->fdw_startup_cost = DEFAULT_FDW_STARTUP_COST;
	fpinfo->fdw_tuple_cost = DEFAULT_FDW_TUPLE_COST;
	fpinfo->shippable_extensions = NIL;
	fpinfo->fetch_size = 100;

//	apply_server_options(fpinfo);
	apply_table_options(fpinfo);

	/*
	 * If the table or the server is configured to use remote estimates,
	 * identify which user to do remote access as during planning.  This
	 * should match what ExecCheckRTEPerms() does.  If we fail due to lack of
	 * permissions, the query would have failed at runtime anyway.
	 */
	fpinfo->user = NULL;

	/*
	 * Identify which baserestrictinfo clauses can be sent to the remote
	 * server and which can't.
	 */
	classifyConditions(root, baserel, baserel->baserestrictinfo,
					   &fpinfo->remote_conds, &fpinfo->local_conds);

	/*
	 * Identify which attributes will need to be retrieved from the remote
	 * server.  These include all attrs needed for joins or final output, plus
	 * all attrs used in the local_conds.  (Note: if we end up using a
	 * parameterized scan, it's possible that some of the join clauses will be
	 * sent to the remote and thus we wouldn't really need to retrieve the
	 * columns used in them.  Doesn't seem worth detecting that case though.)
	 */
	fpinfo->attrs_used = NULL;
	pull_varattnos((Node *) baserel->reltarget->exprs, baserel->relid,
				   &fpinfo->attrs_used);
	foreach(lc, fpinfo->local_conds)
	{
		RestrictInfo *rinfo = lfirst_node(RestrictInfo, lc);

		pull_varattnos((Node *) rinfo->clause, baserel->relid,
					   &fpinfo->attrs_used);
	}

	/*
	 * Compute the selectivity and cost of the local_conds, so we don't have
	 * to do it over again for each path.  The best we can do for these
	 * conditions is to estimate selectivity on the basis of local statistics.
	 */
	fpinfo->local_conds_sel = clauselist_selectivity(root,
													 fpinfo->local_conds,
													 baserel->relid,
													 JOIN_INNER,
													 NULL);

	cost_qual_eval(&fpinfo->local_conds_cost, fpinfo->local_conds, root);

	/*
	 * Set # of retrieved rows and cached relation costs to some negative
	 * value, so that we can detect when they are set to some sensible values,
	 * during one (usually the first) of the calls to estimate_path_cost_size.
	 */
	fpinfo->retrieved_rows = -1;
	fpinfo->rel_startup_cost = -1;
	fpinfo->rel_total_cost = -1;

	/*
	 * If the table or the server is configured to use remote estimates,
	 * connect to the foreign server and execute EXPLAIN to estimate the
	 * number of rows selected by the restriction clauses, as well as the
	 * average row width.  Otherwise, estimate using whatever statistics we
	 * have locally, in a way similar to ordinary tables.
	 */

	/*
		* If the foreign table has never been ANALYZEd, it will have relpages
		* and reltuples equal to zero, which most likely has nothing to do
		* with reality.  We can't do a whole lot about that if we're not
		* allowed to consult the remote server, but we can use a hack similar
		* to plancat.c's treatment of empty relations: use a minimum size
		* estimate of 10 pages, and divide by the column-datatype-based width
		* estimate to get the corresponding number of tuples.
		*/
	if (baserel->pages == 0 && baserel->tuples == 0)
	{
		baserel->pages = 10;
		baserel->tuples =
			(10 * BLCKSZ) / (baserel->reltarget->width +
								MAXALIGN(SizeofHeapTupleHeader));
	}

	/* Estimate baserel size as best we can with local statistics. */
	set_baserel_size_estimates(root, baserel);

	/* Fill in basically-bogus cost estimates for use later. */
	estimate_path_cost_size(root, baserel, NIL, NIL, NULL,
							&fpinfo->rows, &fpinfo->width,
							&fpinfo->startup_cost, &fpinfo->total_cost);

	/*
	 * Set the name of relation in fpinfo, while we are constructing it here.
	 * It will be used to build the string describing the join relation in
	 * EXPLAIN output. We can't know whether VERBOSE option is specified or
	 * not, so always schema-qualify the foreign table name.
	 */
	fpinfo->relation_name = makeStringInfo();
	namespace_string = get_namespace_name(get_rel_namespace(foreigntableid));
	relname = get_rel_name(foreigntableid);
	refname = rte->eref->aliasname;
	appendStringInfo(fpinfo->relation_name, "%s.%s",
					 quote_identifier(namespace_string),
					 quote_identifier(relname));
	if (*refname && strcmp(refname, relname) != 0)
		appendStringInfo(fpinfo->relation_name, " %s",
						 quote_identifier(rte->eref->aliasname));

	/* No outer and inner relations. */
	fpinfo->make_outerrel_subquery = false;
	fpinfo->make_innerrel_subquery = false;
	fpinfo->lower_subquery_rels = NULL;
	/* Set the relation index. */
	fpinfo->relation_index = baserel->relid;
}


/*
 * get_useful_ecs_for_relation
 *		Determine which EquivalenceClasses might be involved in useful
 *		orderings of this relation.
 *
 * This function is in some respects a mirror image of the core function
 * pathkeys_useful_for_merging: for a regular table, we know what indexes
 * we have and want to test whether any of them are useful.  For a foreign
 * table, we don't know what indexes are present on the remote side but
 * want to speculate about which ones we'd like to use if they existed.
 *
 * This function returns a list of potentially-useful equivalence classes,
 * but it does not guarantee that an EquivalenceMember exists which contains
 * Vars only from the given relation.  For example, given ft1 JOIN t1 ON
 * ft1.x + t1.x = 0, this function will say that the equivalence class
 * containing ft1.x + t1.x is potentially useful.  Supposing ft1 is remote and
 * t1 is local (or on a different server), it will turn out that no useful
 * ORDER BY clause can be generated.  It's not our job to figure that out
 * here; we're only interested in identifying relevant ECs.
 */
static List *
get_useful_ecs_for_relation(PlannerInfo *root, RelOptInfo *rel)
{
	List	   *useful_eclass_list = NIL;
	ListCell   *lc;
	Relids		relids;

	/*
	 * First, consider whether any active EC is potentially useful for a merge
	 * join against this relation.
	 */
	if (rel->has_eclass_joins)
	{
		foreach(lc, root->eq_classes)
		{
			EquivalenceClass *cur_ec = (EquivalenceClass *) lfirst(lc);

			if (eclass_useful_for_merging(root, cur_ec, rel))
				useful_eclass_list = lappend(useful_eclass_list, cur_ec);
		}
	}

	/*
	 * Next, consider whether there are any non-EC derivable join clauses that
	 * are merge-joinable.  If the joininfo list is empty, we can exit
	 * quickly.
	 */
	if (rel->joininfo == NIL)
		return useful_eclass_list;

	/* If this is a child rel, we must use the topmost parent rel to search. */
	if (IS_OTHER_REL(rel))
	{
		Assert(!bms_is_empty(rel->top_parent_relids));
		relids = rel->top_parent_relids;
	}
	else
		relids = rel->relids;

	/* Check each join clause in turn. */
	foreach(lc, rel->joininfo)
	{
		RestrictInfo *restrictinfo = (RestrictInfo *) lfirst(lc);

		/* Consider only mergejoinable clauses */
		if (restrictinfo->mergeopfamilies == NIL)
			continue;

		/* Make sure we've got canonical ECs. */
		update_mergeclause_eclasses(root, restrictinfo);

		/*
		 * restrictinfo->mergeopfamilies != NIL is sufficient to guarantee
		 * that left_ec and right_ec will be initialized, per comments in
		 * distribute_qual_to_rels.
		 *
		 * We want to identify which side of this merge-joinable clause
		 * contains columns from the relation produced by this RelOptInfo. We
		 * test for overlap, not containment, because there could be extra
		 * relations on either side.  For example, suppose we've got something
		 * like ((A JOIN B ON A.x = B.x) JOIN C ON A.y = C.y) LEFT JOIN D ON
		 * A.y = D.y.  The input rel might be the joinrel between A and B, and
		 * we'll consider the join clause A.y = D.y. relids contains a
		 * relation not involved in the join class (B) and the equivalence
		 * class for the left-hand side of the clause contains a relation not
		 * involved in the input rel (C).  Despite the fact that we have only
		 * overlap and not containment in either direction, A.y is potentially
		 * useful as a sort column.
		 *
		 * Note that it's even possible that relids overlaps neither side of
		 * the join clause.  For example, consider A LEFT JOIN B ON A.x = B.x
		 * AND A.x = 1.  The clause A.x = 1 will appear in B's joininfo list,
		 * but overlaps neither side of B.  In that case, we just skip this
		 * join clause, since it doesn't suggest a useful sort order for this
		 * relation.
		 */
		if (bms_overlap(relids, restrictinfo->right_ec->ec_relids))
			useful_eclass_list = list_append_unique_ptr(useful_eclass_list,
														restrictinfo->right_ec);
		else if (bms_overlap(relids, restrictinfo->left_ec->ec_relids))
			useful_eclass_list = list_append_unique_ptr(useful_eclass_list,
														restrictinfo->left_ec);
	}

	return useful_eclass_list;
}

/*
 * get_useful_pathkeys_for_relation
 *		Determine which orderings of a relation might be useful.
 *
 * Getting data in sorted order can be useful either because the requested
 * order matches the final output ordering for the overall query we're
 * planning, or because it enables an efficient merge join.  Here, we try
 * to figure out which pathkeys to consider.
 */
static List *
get_useful_pathkeys_for_relation(PlannerInfo *root, RelOptInfo *rel)
{
	List	   *useful_pathkeys_list = NIL;
	List	   *useful_eclass_list;
	tsurugiFdwRelationInfo *fpinfo = (tsurugiFdwRelationInfo *) rel->fdw_private;
	EquivalenceClass *query_ec = NULL;
	ListCell   *lc;

	/*
	 * Pushing the query_pathkeys to the remote server is always worth
	 * considering, because it might let us avoid a local sort.
	 */
	fpinfo->qp_is_pushdown_safe = false;
	if (root->query_pathkeys)
	{
		bool		query_pathkeys_ok = true;

		foreach(lc, root->query_pathkeys)
		{
			PathKey    *pathkey = (PathKey *) lfirst(lc);
			EquivalenceClass *pathkey_ec = pathkey->pk_eclass;
			Expr	   *em_expr;

			/*
			 * The planner and executor don't have any clever strategy for
			 * taking data sorted by a prefix of the query's pathkeys and
			 * getting it to be sorted by all of those pathkeys. We'll just
			 * end up resorting the entire data set.  So, unless we can push
			 * down all of the query pathkeys, forget it.
			 *
			 * is_foreign_expr would detect volatile expressions as well, but
			 * checking ec_has_volatile here saves some cycles.
			 */
			if (pathkey_ec->ec_has_volatile ||
				!(em_expr = find_em_expr_for_rel(pathkey_ec, rel)) ||
				!is_foreign_expr(root, rel, em_expr))
			{
				query_pathkeys_ok = false;
				break;
			}
		}

		if (query_pathkeys_ok)
		{
			useful_pathkeys_list = list_make1(list_copy(root->query_pathkeys));
			fpinfo->qp_is_pushdown_safe = true;
		}
	}

	/*
	 * Even if we're not using remote estimates, having the remote side do the
	 * sort generally won't be any worse than doing it locally, and it might
	 * be much better if the remote side can generate data in the right order
	 * without needing a sort at all.  However, what we're going to do next is
	 * try to generate pathkeys that seem promising for possible merge joins,
	 * and that's more speculative.  A wrong choice might hurt quite a bit, so
	 * bail out if we can't use remote estimates.
	 */
	if (!fpinfo->use_remote_estimate)
		return useful_pathkeys_list;

	/* Get the list of interesting EquivalenceClasses. */
	useful_eclass_list = get_useful_ecs_for_relation(root, rel);

	/* Extract unique EC for query, if any, so we don't consider it again. */
	if (list_length(root->query_pathkeys) == 1)
	{
		PathKey    *query_pathkey = (PathKey *) linitial(root->query_pathkeys);

		query_ec = query_pathkey->pk_eclass;
	}

	/*
	 * As a heuristic, the only pathkeys we consider here are those of length
	 * one.  It's surely possible to consider more, but since each one we
	 * choose to consider will generate a round-trip to the remote side, we
	 * need to be a bit cautious here.  It would sure be nice to have a local
	 * cache of information about remote index definitions...
	 */
	foreach(lc, useful_eclass_list)
	{
		EquivalenceClass *cur_ec = (EquivalenceClass *) lfirst(lc);
		Expr	   *em_expr;
		PathKey    *pathkey;

		/* If redundant with what we did above, skip it. */
		if (cur_ec == query_ec)
			continue;

		/* If no pushable expression for this rel, skip it. */
		em_expr = find_em_expr_for_rel(cur_ec, rel);
		if (em_expr == NULL || !is_foreign_expr(root, rel, em_expr))
			continue;

		/* Looks like we can generate a pathkey, so let's do it. */
		pathkey = make_canonical_pathkey(root, cur_ec,
										 linitial_oid(cur_ec->ec_opfamilies),
										 BTLessStrategyNumber,
										 false);
		useful_pathkeys_list = lappend(useful_pathkeys_list,
									   list_make1(pathkey));
	}

	return useful_pathkeys_list;
}

/*
 *
 */
static void tsurugiGetForeignPaths(PlannerInfo *root,
									RelOptInfo *baserel,
									Oid foreigntableid)
{
	tsurugiFdwRelationInfo *fpinfo = (tsurugiFdwRelationInfo *) baserel->fdw_private;
	ForeignPath *path;
	List	   *ppi_list;
	ListCell   *lc;

	elog(DEBUG2, "tsurugi_fdw : %s", __func__);

	/*
	 * Create simplest ForeignScan path node and add it to baserel.  This path
	 * corresponds to SeqScan path of regular tables (though depending on what
	 * baserestrict conditions we were able to send to remote, there might
	 * actually be an indexscan happening there).  We already did all the work
	 * to estimate cost and size of this path.
	 *
	 * Although this path uses no join clauses, it could still have required
	 * parameterization due to LATERAL refs in its tlist.
	 */
	path = create_foreignscan_path(root, baserel,
								   NULL,	/* default pathtarget */
								   fpinfo->rows,
								   fpinfo->startup_cost,
								   fpinfo->total_cost,
								   NIL, /* no pathkeys */
								   baserel->lateral_relids,
								   NULL,	/* no extra plan */
								   NIL);	/* no fdw_private list */
	add_path(baserel, (Path *) path);

	/* Add paths with pathkeys */
	add_paths_with_pathkeys_for_rel(root, baserel, NULL);

	/*
	 * If we're not using remote estimates, stop here.  We have no way to
	 * estimate whether any join clauses would be worth sending across, so
	 * don't bother building parameterized paths.
	 */
	if (!fpinfo->use_remote_estimate)
		return;

	/*
	 * Thumb through all join clauses for the rel to identify which outer
	 * relations could supply one or more safe-to-send-to-remote join clauses.
	 * We'll build a parameterized path for each such outer relation.
	 *
	 * It's convenient to manage this by representing each candidate outer
	 * relation by the ParamPathInfo node for it.  We can then use the
	 * ppi_clauses list in the ParamPathInfo node directly as a list of the
	 * interesting join clauses for that rel.  This takes care of the
	 * possibility that there are multiple safe join clauses for such a rel,
	 * and also ensures that we account for unsafe join clauses that we'll
	 * still have to enforce locally (since the parameterized-path machinery
	 * insists that we handle all movable clauses).
	 */
	ppi_list = NIL;
	foreach(lc, baserel->joininfo)
	{
		RestrictInfo *rinfo = (RestrictInfo *) lfirst(lc);
		Relids		required_outer;
		ParamPathInfo *param_info;

		/* Check if clause can be moved to this rel */
		if (!join_clause_is_movable_to(rinfo, baserel))
			continue;

		/* See if it is safe to send to remote */
		if (!is_foreign_expr(root, baserel, rinfo->clause))
			continue;

		/* Calculate required outer rels for the resulting path */
		required_outer = bms_union(rinfo->clause_relids,
								   baserel->lateral_relids);
		/* We do not want the foreign rel itself listed in required_outer */
		required_outer = bms_del_member(required_outer, baserel->relid);

		/*
		 * required_outer probably can't be empty here, but if it were, we
		 * couldn't make a parameterized path.
		 */
		if (bms_is_empty(required_outer))
			continue;

		/* Get the ParamPathInfo */
		param_info = get_baserel_parampathinfo(root, baserel,
											   required_outer);
		Assert(param_info != NULL);

		/*
		 * Add it to list unless we already have it.  Testing pointer equality
		 * is OK since get_baserel_parampathinfo won't make duplicates.
		 */
		ppi_list = list_append_unique_ptr(ppi_list, param_info);
	}

	/*
	 * The above scan examined only "generic" join clauses, not those that
	 * were absorbed into EquivalenceClauses.  See if we can make anything out
	 * of EquivalenceClauses.
	 */
	if (baserel->has_eclass_joins)
	{
		/*
		 * We repeatedly scan the eclass list looking for column references
		 * (or expressions) belonging to the foreign rel.  Each time we find
		 * one, we generate a list of equivalence joinclauses for it, and then
		 * see if any are safe to send to the remote.  Repeat till there are
		 * no more candidate EC members.
		 */
		ec_member_foreign_arg arg;

		arg.already_used = NIL;
		for (;;)
		{
			List	   *clauses;

			/* Make clauses, skipping any that join to lateral_referencers */
			arg.current = NULL;
			clauses = generate_implied_equalities_for_column(root,
															 baserel,
															 ec_member_matches_foreign,
															 (void *) &arg,
															 baserel->lateral_referencers);

			/* Done if there are no more expressions in the foreign rel */
			if (arg.current == NULL)
			{
				Assert(clauses == NIL);
				break;
			}

			/* Scan the extracted join clauses */
			foreach(lc, clauses)
			{
				RestrictInfo *rinfo = (RestrictInfo *) lfirst(lc);
				Relids		required_outer;
				ParamPathInfo *param_info;

				/* Check if clause can be moved to this rel */
				if (!join_clause_is_movable_to(rinfo, baserel))
					continue;

				/* See if it is safe to send to remote */
				if (!is_foreign_expr(root, baserel, rinfo->clause))
					continue;

				/* Calculate required outer rels for the resulting path */
				required_outer = bms_union(rinfo->clause_relids,
										   baserel->lateral_relids);
				required_outer = bms_del_member(required_outer, baserel->relid);
				if (bms_is_empty(required_outer))
					continue;

				/* Get the ParamPathInfo */
				param_info = get_baserel_parampathinfo(root, baserel,
													   required_outer);
				Assert(param_info != NULL);

				/* Add it to list unless we already have it */
				ppi_list = list_append_unique_ptr(ppi_list, param_info);
			}

			/* Try again, now ignoring the expression we found this time */
			arg.already_used = lappend(arg.already_used, arg.current);
		}
	}

	/*
	 * Now build a path for each useful outer relation.
	 */
	foreach(lc, ppi_list)
	{
		ParamPathInfo *param_info = (ParamPathInfo *) lfirst(lc);
		double		rows;
		int			width;
		Cost		startup_cost;
		Cost		total_cost;
#if 0
		/* Get a cost estimate from the remote */
		estimate_path_cost_size(root, baserel,
								param_info->ppi_clauses, NIL, NULL,
								&rows, &width,
								&startup_cost, &total_cost);
#endif
		/*
		 * ppi_rows currently won't get looked at by anything, but still we
		 * may as well ensure that it matches our idea of the rowcount.
		 */
		param_info->ppi_rows = rows;

		/* Make the path */
		path = create_foreignscan_path(root, baserel,
									   NULL,	/* default pathtarget */
									   rows,
									   startup_cost,
									   total_cost,
									   NIL, /* no pathkeys */
									   param_info->ppi_req_outer,
									   NULL,
									   NIL);	/* no fdw_private list */
		add_path(baserel, (Path *) path);
	}
}

/*	tsurugiGetForeignPlan
 *		Create ForeignScan plan node which implements selected best path.
 */
static ForeignScan *
tsurugiGetForeignPlan(PlannerInfo *root,
					   RelOptInfo *foreignrel,
					   Oid foreigntableid,
					   ForeignPath *best_path,
					   List *tlist,
					   List *scan_clauses,
					   Plan *outer_plan)
{
	tsurugiFdwRelationInfo *fpinfo = (tsurugiFdwRelationInfo *) foreignrel->fdw_private;
	Index		scan_relid;
	List	   *fdw_private;
	List	   *remote_exprs = NIL;
	List	   *local_exprs = NIL;
	List	   *params_list = NIL;
	List	   *fdw_scan_tlist = NIL;
	List	   *fdw_recheck_quals = NIL;
	List	   *retrieved_attrs;
	StringInfoData sql;
	bool		has_final_sort = false;
	bool		has_limit = false;
	ListCell   *lc;

	elog(DEBUG2, "tsurugi_fdw : %s", __func__);

	/*
	 * Get FDW private data created by postgresGetForeignUpperPaths(), if any.
	 */
	if (best_path->fdw_private)
	{
		has_final_sort = intVal(list_nth(best_path->fdw_private,
										 FdwPathPrivateHasFinalSort));
		has_limit = intVal(list_nth(best_path->fdw_private,
									FdwPathPrivateHasLimit));
	}

	if (IS_SIMPLE_REL(foreignrel))
	{
		/*
		 * For base relations, set scan_relid as the relid of the relation.
		 */
		scan_relid = foreignrel->relid;

		/*
		 * In a base-relation scan, we must apply the given scan_clauses.
		 *
		 * Separate the scan_clauses into those that can be executed remotely
		 * and those that can't.  baserestrictinfo clauses that were
		 * previously determined to be safe or unsafe by classifyConditions
		 * are found in fpinfo->remote_conds and fpinfo->local_conds. Anything
		 * else in the scan_clauses list will be a join clause, which we have
		 * to check for remote-safety.
		 *
		 * Note: the join clauses we see here should be the exact same ones
		 * previously examined by postgresGetForeignPaths.  Possibly it'd be
		 * worth passing forward the classification work done then, rather
		 * than repeating it here.
		 *
		 * This code must match "extract_actual_clauses(scan_clauses, false)"
		 * except for the additional decision about remote versus local
		 * execution.
		 */
		foreach(lc, scan_clauses)
		{
			RestrictInfo *rinfo = lfirst_node(RestrictInfo, lc);

			/* Ignore any pseudoconstants, they're dealt with elsewhere */
			if (rinfo->pseudoconstant)
				continue;

			if (list_member_ptr(fpinfo->remote_conds, rinfo))
				remote_exprs = lappend(remote_exprs, rinfo->clause);
			else if (list_member_ptr(fpinfo->local_conds, rinfo))
				local_exprs = lappend(local_exprs, rinfo->clause);
			else if (is_foreign_expr(root, foreignrel, rinfo->clause))
				remote_exprs = lappend(remote_exprs, rinfo->clause);
			else
				local_exprs = lappend(local_exprs, rinfo->clause);
		}

		/*
		 * For a base-relation scan, we have to support EPQ recheck, which
		 * should recheck all the remote quals.
		 */
		fdw_recheck_quals = remote_exprs;
	}
	else
	{
		/*
		 * Join relation or upper relation - set scan_relid to 0.
		 */
		scan_relid = 0;

		/*
		 * For a join rel, baserestrictinfo is NIL and we are not considering
		 * parameterization right now, so there should be no scan_clauses for
		 * a joinrel or an upper rel either.
		 */
		Assert(!scan_clauses);

		/*
		 * Instead we get the conditions to apply from the fdw_private
		 * structure.
		 */
		remote_exprs = extract_actual_clauses(fpinfo->remote_conds, false);
		local_exprs = extract_actual_clauses(fpinfo->local_conds, false);

		/*
		 * We leave fdw_recheck_quals empty in this case, since we never need
		 * to apply EPQ recheck clauses.  In the case of a joinrel, EPQ
		 * recheck is handled elsewhere --- see postgresGetForeignJoinPaths().
		 * If we're planning an upperrel (ie, remote grouping or aggregation)
		 * then there's no EPQ to do because SELECT FOR UPDATE wouldn't be
		 * allowed, and indeed we *can't* put the remote clauses into
		 * fdw_recheck_quals because the unaggregated Vars won't be available
		 * locally.
		 */

		/* Build the list of columns to be fetched from the foreign server. */
		fdw_scan_tlist = build_tlist_to_deparse(foreignrel);

		/*
		 * Ensure that the outer plan produces a tuple whose descriptor
		 * matches our scan tuple slot.  Also, remove the local conditions
		 * from outer plan's quals, lest they be evaluated twice, once by the
		 * local plan and once by the scan.
		 */
		if (outer_plan)
		{
			ListCell   *lc;

			/*
			 * Right now, we only consider grouping and aggregation beyond
			 * joins. Queries involving aggregates or grouping do not require
			 * EPQ mechanism, hence should not have an outer plan here.
			 */
			Assert(!IS_UPPER_REL(foreignrel));

			/*
			 * First, update the plan's qual list if possible.  In some cases
			 * the quals might be enforced below the topmost plan level, in
			 * which case we'll fail to remove them; it's not worth working
			 * harder than this.
			 */
			foreach(lc, local_exprs)
			{
				Node	   *qual = (Node *) lfirst(lc);

				outer_plan->qual = list_delete(outer_plan->qual, qual);

				/*
				 * For an inner join the local conditions of foreign scan plan
				 * can be part of the joinquals as well.  (They might also be
				 * in the mergequals or hashquals, but we can't touch those
				 * without breaking the plan.)
				 */
				if (IsA(outer_plan, NestLoop) ||
					IsA(outer_plan, MergeJoin) ||
					IsA(outer_plan, HashJoin))
				{
					Join	   *join_plan = (Join *) outer_plan;

					if (join_plan->jointype == JOIN_INNER)
						join_plan->joinqual = list_delete(join_plan->joinqual,
														  qual);
				}
			}

			/*
			 * Now fix the subplan's tlist --- this might result in inserting
			 * a Result node atop the plan tree.
			 */
			outer_plan = change_plan_targetlist(outer_plan, fdw_scan_tlist,
												best_path->path.parallel_safe);
		}
	}

	/*
	 * Build the query string to be sent for execution, and identify
	 * expressions to be sent as parameters.
	 */
	initStringInfo(&sql);
	deparseSelectStmtForRel(&sql, root, foreignrel, fdw_scan_tlist,
							remote_exprs, best_path->path.pathkeys,
							has_final_sort, has_limit, false,
							&retrieved_attrs, &params_list);

	/* Remember remote_exprs for possible use by tsurugiPlanDirectModify */
	fpinfo->final_remote_exprs = remote_exprs;

	/*
	 * Build the fdw_private list that will be available to the executor.
	 * Items in the list must match order in enum FdwScanPrivateIndex.
	 */
	fdw_private = list_make3(makeString(sql.data),
							 retrieved_attrs,
							 makeInteger(fpinfo->fetch_size));
	if (IS_JOIN_REL(foreignrel) || IS_UPPER_REL(foreignrel))
		fdw_private = lappend(fdw_private,
							  makeString(fpinfo->relation_name->data));

	/*
	 * Create the ForeignScan node for the given relation.
	 *
	 * Note that the remote parameter expressions are stored in the fdw_exprs
	 * field of the finished plan node; we can't keep them in private state
	 * because then they wouldn't be subject to later planner processing.
	 */
	return make_foreignscan(tlist,
							local_exprs,
							scan_relid,
							params_list,
							fdw_private,
							fdw_scan_tlist,
							fdw_recheck_quals,
							outer_plan);
}											

/*
 * postgresGetForeignJoinPaths
 *		Add possible ForeignPath to joinrel, if join is safe to push down.
 */
static void 
tsurugiGetForeignJoinPaths(PlannerInfo *root,
							RelOptInfo *joinrel,
							RelOptInfo *outerrel,
							RelOptInfo *innerrel,
							JoinType jointype,
							JoinPathExtraData *extra)
{
	tsurugiFdwRelationInfo *fpinfo;
	ForeignPath *joinpath;
	double		rows;
	int			width;
	Cost		startup_cost;
	Cost		total_cost;
	Path	   *epq_path;		/* Path to create plan to be executed when
								 * EvalPlanQual gets triggered. */

	elog(DEBUG2, "tsurugi_fdw : %s", __func__);

	/*
	 * Skip if this join combination has been considered already.
	 */
	if (joinrel->fdw_private)
		return;

	/*
	 * This code does not work for joins with lateral references, since those
	 * must have parameterized paths, which we don't generate yet.
	 */
	if (!bms_is_empty(joinrel->lateral_relids))
		return;

	/*
	 * Create unfinished tsurugiFdwRelationInfo entry which is used to indicate
	 * that the join relation is already considered, so that we won't waste
	 * time in judging safety of join pushdown and adding the same paths again
	 * if found safe. Once we know that this join can be pushed down, we fill
	 * the entry.
	 */
	fpinfo = (tsurugiFdwRelationInfo *) palloc0(sizeof(tsurugiFdwRelationInfo));
	fpinfo->pushdown_safe = false;
	joinrel->fdw_private = fpinfo;
	/* attrs_used is only for base relations. */
	fpinfo->attrs_used = NULL;

	/*
	 * If there is a possibility that EvalPlanQual will be executed, we need
	 * to be able to reconstruct the row using scans of the base relations.
	 * GetExistingLocalJoinPath will find a suitable path for this purpose in
	 * the path list of the joinrel, if one exists.  We must be careful to
	 * call it before adding any ForeignPath, since the ForeignPath might
	 * dominate the only suitable local path available.  We also do it before
	 * calling foreign_join_ok(), since that function updates fpinfo and marks
	 * it as pushable if the join is found to be pushable.
	 */
	if (root->parse->commandType == CMD_DELETE ||
		root->parse->commandType == CMD_UPDATE ||
		root->rowMarks)
	{
		epq_path = GetExistingLocalJoinPath(joinrel);
		if (!epq_path)
		{
			elog(DEBUG3, "could not push down foreign join because a local path suitable for EPQ checks was not found");
			return;
		}
	}
	else
		epq_path = NULL;

	if (!foreign_join_ok(root, joinrel, jointype, outerrel, innerrel, extra))
	{
		/* Free path required for EPQ if we copied one; we don't need it now */
		if (epq_path)
			pfree(epq_path);
		return;
	}

	/*
	 * Compute the selectivity and cost of the local_conds, so we don't have
	 * to do it over again for each path. The best we can do for these
	 * conditions is to estimate selectivity on the basis of local statistics.
	 * The local conditions are applied after the join has been computed on
	 * the remote side like quals in WHERE clause, so pass jointype as
	 * JOIN_INNER.
	 */
	fpinfo->local_conds_sel = clauselist_selectivity(root,
													 fpinfo->local_conds,
													 0,
													 JOIN_INNER,
													 NULL);
	cost_qual_eval(&fpinfo->local_conds_cost, fpinfo->local_conds, root);

	/*
	 * If we are going to estimate costs locally, estimate the join clause
	 * selectivity here while we have special join info.
	 */
	if (!fpinfo->use_remote_estimate)
		fpinfo->joinclause_sel = clauselist_selectivity(root, fpinfo->joinclauses,
														0, fpinfo->jointype,
														extra->sjinfo);

	/* Estimate costs for bare join relation */
	estimate_path_cost_size(root, joinrel, NIL, NIL, NULL,
							&rows, &width, &startup_cost, &total_cost);
	/* Now update this information in the joinrel */
	joinrel->rows = rows;
	joinrel->reltarget->width = width;
	fpinfo->rows = rows;
	fpinfo->width = width;
	fpinfo->startup_cost = startup_cost;
	fpinfo->total_cost = total_cost;

	/*
	 * Create a new join path and add it to the joinrel which represents a
	 * join between foreign tables.
	 */
	joinpath = create_foreign_join_path(root,
										joinrel,
										NULL,	/* default pathtarget */
										rows,
										startup_cost,
										total_cost,
										NIL,	/* no pathkeys */
										joinrel->lateral_relids,
										epq_path,
										NIL);	/* no fdw_private */

	/* Add generated path into joinrel by add_path(). */
	add_path(joinrel, (Path *) joinpath);

	/* Consider pathkeys for the join relation */
	add_paths_with_pathkeys_for_rel(root, joinrel, epq_path);

	/* XXX Consider parameterized paths for the join relation */
}										

/*
 * postgresGetForeignUpperPaths
 *		Add paths for post-join operations like aggregation, grouping etc. if
 *		corresponding operations are safe to push down.
 */
static void 
tsurugiGetForeignUpperPaths(PlannerInfo *root,
							UpperRelationKind stage,
							RelOptInfo *input_rel,
							RelOptInfo *output_rel,
							void *extra)
{
	tsurugiFdwRelationInfo *fpinfo;

	elog(DEBUG2, "tsurugi_fdw : %s", __func__);

	/*
	 * If input rel is not safe to pushdown, then simply return as we cannot
	 * perform any post-join operations on the foreign server.
	 */
	if (!input_rel->fdw_private ||
		!((tsurugiFdwRelationInfo *) input_rel->fdw_private)->pushdown_safe)
		return;

	/* Ignore stages we don't support; and skip any duplicate calls. */
	if ((stage != UPPERREL_GROUP_AGG &&
		 stage != UPPERREL_ORDERED &&
		 stage != UPPERREL_FINAL) ||
		output_rel->fdw_private)
		return;

	fpinfo = (tsurugiFdwRelationInfo *) palloc0(sizeof(tsurugiFdwRelationInfo));
	fpinfo->pushdown_safe = false;
	fpinfo->stage = stage;
	output_rel->fdw_private = fpinfo;

	switch (stage)
	{
		case UPPERREL_GROUP_AGG:
			add_foreign_grouping_paths(root, input_rel, output_rel,
									   (GroupPathExtraData *) extra);
			break;
		case UPPERREL_ORDERED:
			add_foreign_ordered_paths(root, input_rel, output_rel);
			break;
		case UPPERREL_FINAL:
			add_foreign_final_paths(root, input_rel, output_rel,
									(FinalPathExtraData *) extra);
			break;
		default:
			elog(ERROR, "unexpected upper relation: %d", (int) stage);
			break;
	}
}										 

/* 
 * 	FDW Executor functions 
 */

/*
 *	@brief	Preparation for scanning foreign tables.
 *	@param	[in] Foreign scan inforamtion.
 *	@param	[in] Some flag parameters. (e.g. EXEC_FLAG_EXPLAIN_ONLY)
 */
static void 
tsurugiBeginForeignScan(ForeignScanState* node, int eflags)
{
	elog(DEBUG2, "tsurugi_fdw : %s", __func__);

	Assert(node != nullptr);

	ForeignScan* fsplan = (ForeignScan*) node->ss.ps.plan;
	EState*	estate = node->ss.ps.state;
	OgawayamaFdwState* fdw_state = create_fdwstate();

	fdw_state->fetch_size = DEFAULT_FETCH_SIZE;

	/* Create MemoryContext for tuple data */
	fdw_state->batch_cxt = AllocSetContextCreate(
		estate->es_query_cxt, "ogawayama_fdw tuple data", ALLOCSET_DEFAULT_SIZES);

	/* トランザクション開始 */
	begin_backend_xact();

	/* SELECT対象の列のデータ型を格納 */
	store_pg_data_type(fdw_state, fsplan->scan.plan.targetlist);
	
//    fdw_state->query_string = estate->es_sourceText;
	fdw_state->query_string = strVal(list_nth(fsplan->fdw_private,
									 FdwScanPrivateSelectSql));

	 /* fdw_stateをnode->fdw_stateに格納する */
	 node->fdw_state = fdw_state;
}

/*
 *	@briref	Scanning row data from foreign tables.
 *	@param	[in] Foreign scan inforamtion.
 *	@return	Scaned row data.
 */
static TupleTableSlot* 
tsurugiIterateForeignScan(ForeignScanState* node)
{
	elog(DEBUG2, "tsurugi_fdw : %s", __func__);

	Assert(node != nullptr);
	Assert(fdw_info_.transaction != nullptr);

	TupleTableSlot* slot = node->ss.ss_ScanTupleSlot;
	OgawayamaFdwState* fdw_state = (OgawayamaFdwState*) node->fdw_state;

	if (!fdw_state->cursor_exists)
		create_cursor(node);

	if (fdw_state->next_tuple >= fdw_state->num_tuples)
	{
		/* No point in another fetch if we already detected EOF, though. */
		if (!fdw_state->eof_reached)
			fetch_more_data(node);

		/* If we didn't get any tuples, must be end of data */		
		if (fdw_state->next_tuple >= fdw_state->num_tuples)
		{
			ExecClearTuple(slot);
			goto EXIT;
		}
	}
	make_virtual_tuple(slot, node);
	ExecStoreVirtualTuple(slot);

	fdw_state->tuple_ite++;
	fdw_state->next_tuple = std::distance(
		fdw_state->tuples.begin(), fdw_state->tuple_ite);

EXIT:
	return slot;
}

/*
 *	@note	Not in use.
 */
static void 
tsurugiReScanForeignScan(ForeignScanState* node)
{
	elog(DEBUG2, "tsurugi_fdw : %s", __func__);
}

/*
 *	@brief	Clean up for scanning foreign tables.
 *	@param	[in] Foreign scan information.
 */
static void 
tsurugiEndForeignScan(ForeignScanState* node)
{
	elog(DEBUG2, "tsurugi_fdw : %s", __func__);

	OgawayamaFdwState* fdw_state = (OgawayamaFdwState*) node->fdw_state;

	/* close cursor */
	fdw_info_.result_set = nullptr;

	ERROR_CODE error;

	if (fdw_info_.transaction != nullptr)
	{
		elog(DEBUG2, "transaction::commit() start.");
		error = fdw_info_.transaction->commit();
		elog(DEBUG2, "transaction::commit() done.");
		if (error != ERROR_CODE::OK)
		{
			elog(ERROR, "transaction::commit() failed. (%d)", (int) error);
		}
	}

	StubManager::end();
	fdw_info_.transaction = nullptr;
	fdw_info_.xact_level--;
	elog(DEBUG2, "xact_level: (%d)", fdw_info_.xact_level);

	if (fdw_state != nullptr)
		free_fdwstate(fdw_state);
	
	/* MemoryContexts will be deleted automatically. */
}

/*
 * 	@brief	Preparation for modifying foreign tables.
 *	@param	[in] Foreign scan information.
 *	@param	[in] Some flags. (e.g. EXEC_FLAG_EXPLAIN_ONLY)
 */
static void 
tsurugiBeginDirectModify(ForeignScanState* node, int eflags)
{
	elog(DEBUG2, "tsurugi_fdw : %s", __func__);

	Assert(node != nullptr);

	EState* estate = node->ss.ps.state;

	OgawayamaFdwState* fdw_state = create_fdwstate();
	if (fdw_state == nullptr)
	{
		elog(ERROR, "create_fdw_state() failed.");
	}

	begin_backend_xact();

 	fdw_state->query_string = estate->es_sourceText;
	 
	 node->fdw_state = fdw_state;
}

/*
 *	@biref	Execute Insert/Upate/Delete command to foreign tables.
 *	@param	[in] Foreign scan information.
 *	@return	only nullptr.
 */
static TupleTableSlot* 
tsurugiIterateDirectModify(ForeignScanState* node)
{
	elog(DEBUG2, "tsurugi_fdw : %s", __func__);

	Assert(node != nullptr);
	Assert(fdw_info_.transaction != nullptr);

	OgawayamaFdwState* fdw_state = (OgawayamaFdwState*) node->fdw_state;
	TupleTableSlot* slot = nullptr;
	ERROR_CODE error;

	elog(DEBUG1, "statement string: \"%s\"", fdw_state->query_string);

  	std::string query(fdw_state->query_string);
	// trim terminal semi-column.
	if (query.back() == ';')
	{
		query.pop_back();
	}
	elog(DEBUG1, "statement string: \"%s\"", query.c_str());
	elog(DEBUG2, "transaction::execute_statement() start.");
	error = fdw_info_.transaction->execute_statement(query);
	elog(DEBUG2, "transaction::execute_statement() done.");
	if (error != ERROR_CODE::OK) 
    {
		elog(ERROR, "transaction::execute_statement() failed. (%d)", (int) error);	
	}
	
	return slot;	
}

/*
 * 	@biref	Clean up for modifying foreign tables.
 *	@param	[in] foreign scan information.
 */
static void 
tsurugiEndDirectModify(ForeignScanState* node)
{
	elog(DEBUG2, "tsurugi_fdw : %s", __func__);

	ERROR_CODE error;

	if (fdw_info_.transaction != nullptr)
	{
		elog(DEBUG2, "transaction::commit() start.");
		error = fdw_info_.transaction->commit();
		elog(DEBUG2, "transaction::commit() done.");
		if (error != ERROR_CODE::OK)
		{
			elog(ERROR, "transaction::commit() failed. (%d)", (int) error);
		}
	}

	StubManager::end();
	fdw_info_.transaction = nullptr;
	fdw_info_.xact_level--;
	elog(DEBUG2, "xact_level: (%d)", fdw_info_.xact_level);

	if (node->fdw_state != nullptr)
		free_fdwstate((OgawayamaFdwState*) node->fdw_state);
}

static void 
tsurugiAddForeignUpdateTargets(Query *parsetree,
											RangeTblEntry *target_rte,
											Relation target_relation)
{
	elog(DEBUG2, "tsurugi_fdw : %s", __func__);

}	

/*
 * tsurugiPlanDirectModify
 *		Consider a direct foreign table modification
 *
 * Decide whether it is safe to modify a foreign table directly, and if so,
 * rewrite subplan accordingly.
 */
static bool 
tsurugiPlanDirectModify(PlannerInfo *root,
						ModifyTable *plan,
						Index resultRelation,
						int subplan_index)
{
	CmdType		operation = plan->operation;
	Plan	   *subplan;
	RelOptInfo *foreignrel;
	RangeTblEntry *rte;
	tsurugiFdwRelationInfo *fpinfo;
	Relation	rel;
	StringInfoData sql;
	ForeignScan *fscan;
	List	   *targetAttrs = NIL;
	List	   *remote_exprs;
	List	   *params_list = NIL;
	List	   *returningList = NIL;
	List	   *retrieved_attrs = NIL;

	elog(DEBUG2, "tsurugi_fdw : %s (operation= %d)", __func__, (int) operation);

	/*
	 * Decide whether it is safe to modify a foreign table directly.
	 */

	/*
	 * The table modification must be an UPDATE or DELETE.
	 */
	if (operation != CMD_UPDATE && operation != CMD_DELETE)
		return false;

	/*
	 * It's unsafe to modify a foreign table directly if there are any local
	 * joins needed.
	 */
	subplan = (Plan *) list_nth(plan->plans, subplan_index);
	if (!IsA(subplan, ForeignScan))
		return false;
	fscan = (ForeignScan *) subplan;

	/*
	 * It's unsafe to modify a foreign table directly if there are any quals
	 * that should be evaluated locally.
	 */
	if (subplan->qual != NIL)
		return false;

	/* Safe to fetch data about the target foreign rel */
	if (fscan->scan.scanrelid == 0)
	{
		foreignrel = find_join_rel(root, fscan->fs_relids);
		/* We should have a rel for this foreign join. */
		Assert(foreignrel);
	}
	else
		foreignrel = root->simple_rel_array[resultRelation];
	rte = root->simple_rte_array[resultRelation];
	fpinfo = (tsurugiFdwRelationInfo *) foreignrel->fdw_private;

	/*
	 * It's unsafe to update a foreign table directly, if any expressions to
	 * assign to the target columns are unsafe to evaluate remotely.
	 */
	if (operation == CMD_UPDATE)
	{
		int			col;

		/*
		 * We transmit only columns that were explicitly targets of the
		 * UPDATE, so as to avoid unnecessary data transmission.
		 */
		col = -1;
		while ((col = bms_next_member(rte->updatedCols, col)) >= 0)
		{
			/* bit numbers are offset by FirstLowInvalidHeapAttributeNumber */
			AttrNumber	attno = col + FirstLowInvalidHeapAttributeNumber;
			TargetEntry *tle;

			if (attno <= InvalidAttrNumber) /* shouldn't happen */
				elog(ERROR, "system-column update is not supported");

			tle = get_tle_by_resno(subplan->targetlist, attno);

			if (!tle)
				elog(ERROR, "attribute number %d not found in subplan targetlist",
					 attno);

			if (!is_foreign_expr(root, foreignrel, (Expr *) tle->expr))
				return false;

			targetAttrs = lappend_int(targetAttrs, attno);
		}
	}

	/*
	 * Ok, rewrite subplan so as to modify the foreign table directly.
	 */
	initStringInfo(&sql);

	/*
	 * Core code already has some lock on each rel being planned, so we can
	 * use NoLock here.
	 */
	rel = table_open(rte->relid, NoLock);

	/*
	 * Recall the qual clauses that must be evaluated remotely.  (These are
	 * bare clauses not RestrictInfos, but deparse.c's appendConditions()
	 * doesn't care.)
	 */
	remote_exprs = fpinfo->final_remote_exprs;

	/*
	 * Extract the relevant RETURNING list if any.
	 */
	if (plan->returningLists)
	{
		returningList = (List *) list_nth(plan->returningLists, subplan_index);

		/*
		 * When performing an UPDATE/DELETE .. RETURNING on a join directly,
		 * we fetch from the foreign server any Vars specified in RETURNING
		 * that refer not only to the target relation but to non-target
		 * relations.  So we'll deparse them into the RETURNING clause of the
		 * remote query; use a targetlist consisting of them instead, which
		 * will be adjusted to be new fdw_scan_tlist of the foreign-scan plan
		 * node below.
		 */
		if (fscan->scan.scanrelid == 0)
			returningList = build_remote_returning(resultRelation, rel,
												   returningList);
	}

	/*
	 * Construct the SQL command string.
	 */
	switch (operation)
	{
		case CMD_UPDATE:
			deparseDirectUpdateSql(&sql, root, resultRelation, rel,
								   foreignrel,
								   ((Plan *) fscan)->targetlist,
								   targetAttrs,
								   remote_exprs, &params_list,
								   returningList, &retrieved_attrs);
			break;
		case CMD_DELETE:
			deparseDirectDeleteSql(&sql, root, resultRelation, rel,
								   foreignrel,
								   remote_exprs, &params_list,
								   returningList, &retrieved_attrs);
			break;
		default:
			elog(ERROR, "unexpected operation: %d", (int) operation);
			break;
	}

	elog(DEBUG2, "tsurugi_fdw : sql = \"%s\"", sql.data);

	/*
	 * Update the operation info.
	 */
	fscan->operation = operation;

	/*
	 * Update the fdw_exprs list that will be available to the executor.
	 */
	fscan->fdw_exprs = params_list;

	/*
	 * Update the fdw_private list that will be available to the executor.
	 * Items in the list must match enum FdwDirectModifyPrivateIndex, above.
	 */
	fscan->fdw_private = list_make4(makeString(sql.data),
									makeInteger((retrieved_attrs != NIL)),
									retrieved_attrs,
									makeInteger(plan->canSetTag));

	/*
	 * Update the foreign-join-related fields.
	 */
	if (fscan->scan.scanrelid == 0)
	{
		/* No need for the outer subplan. */
		fscan->scan.plan.lefttree = NULL;

		/* Build new fdw_scan_tlist if UPDATE/DELETE .. RETURNING. */
		if (returningList)
			rebuild_fdw_scan_tlist(fscan, returningList);
	}

	table_close(rel, NoLock);
	elog(DEBUG2, "tsurugi_fdw : Direct Modify is true.");
	return true;
}

static List 
*tsurugiPlanForeignModify(PlannerInfo *root,
									   ModifyTable *plan,
									   Index resultRelation,
									   int subplan_index)
{
	elog(DEBUG2, "tsurugi_fdw : %s", __func__);

}									   

/*
 * 	@note	Not in use.
 */
static TupleTableSlot*
tsurugiExecForeignInsert(
	EState *estate, 
	ResultRelInfo *rinfo, 
	TupleTableSlot *slot, 
	TupleTableSlot *planSlot)
{
	elog(DEBUG2, "tsurugi_fdw : %s", __func__);
	slot = nullptr;

	return slot;
}

/*
 * 	@note	Not in use.
 */
static TupleTableSlot*
tsurugiExecForeignUpdate(
	EState *estate, 
	ResultRelInfo *rinfo, 
	TupleTableSlot *slot, 
	TupleTableSlot *planSlot)
{
	elog(DEBUG2, "tsurugi_fdw : %s", __func__);
	slot = nullptr;

	return slot;
}

/*
 * 	@note	Not in use.
 */
static TupleTableSlot*
tsurugiExecForeignDelete(
	EState *estate, 
	ResultRelInfo *rinfo, 
	TupleTableSlot *slot, 
	TupleTableSlot *planSlot)
{
	elog(DEBUG2, "tsurugi_fdw : %s", __func__);
	slot = nullptr;

	return slot;
}

/*
 * tsurugiEndForeignModify
 *		Finish an insert/update/delete operation on a foreign table
 */
static void
tsurugiEndForeignModify(EState *estate,
						 ResultRelInfo *resultRelInfo)
{
	tsurugiFdwModifyState *fmstate = (tsurugiFdwModifyState *) resultRelInfo->ri_FdwState;

	elog(DEBUG2, "tsurugi_fdw : %s", __func__);

	/* If fmstate is NULL, we are in EXPLAIN; nothing to do */
	if (fmstate == NULL)
		return;

	/* Destroy the execution state */
//	finish_foreign_modify(fmstate);
}

/*
 * Functions to be implemented in the future are below.  
 * 
 */


/*
 *	@note	Not in use.
 */
static void 
tsurugiExplainForeignScan(ForeignScanState* node,
						   	ExplainState* es)
{
	elog(DEBUG2, "tsurugi_fdw : %s", __func__);
}

/*
 *	@note	Not in use.
 */
static void 
tsurugiExplainDirectModify(ForeignScanState* node,
							ExplainState* es)
{
	elog(DEBUG2, "tsurugi_fdw : %s", __func__);
}

/*
 *	@note	Not in use.
 */
static bool tsurugiAnalyzeForeignTable(Relation relation,
							AcquireSampleRowsFunc* func,
							BlockNumber* totalpages)
{
	elog(DEBUG2, "tsurugi_fdw : %s", __func__);

	return true;
}

/*
 *	@note	Not in use.
 */
static List* 
tsurugiImportForeignSchema(ImportForeignSchemaStmt* stmt,
							Oid serverOid)
{
	elog(DEBUG2, "tsurugi_fdw : %s", __func__);
	List	*commands = NIL;

	return commands;
}

/*
 *	@brief:	Create OgawayamaFdwState structure.
 */
static OgawayamaFdwState* 
create_fdwstate()
{
	OgawayamaFdwState* fdw_state = 
		(OgawayamaFdwState*) palloc0(sizeof(OgawayamaFdwState));
	
	fdw_state->cursor_exists = false;
	fdw_state->number_of_columns = 0;
	fdw_state->column_types = nullptr;

	return fdw_state;
}

/*
 *	@brief:	free allocated memories.
 *	@param:	[in] Ogawayama-fdw state.
 */
static void 
free_fdwstate(OgawayamaFdwState* fdw_state)
{
	if (fdw_state->column_types != nullptr) 
	{
		pfree(fdw_state->column_types);
		fdw_state->column_types = nullptr;
	}

	if (!fdw_state->tuples.empty())
	{
		for (auto ite = fdw_state->tuples.begin(); ite == fdw_state->tuples.end(); ite++)
		{
			TupleTableSlot* tuple = *ite;
			free(tuple->tts_values);
			free(tuple->tts_isnull);
			free(tuple);
		}
	}

 	pfree(fdw_state);
}

/*
 * 	@biref	Scanning data type of target list from PG tables.
 * 	@param	[in/out] Store data type information.
 * 	@param	[in] target list. (TargetEntry->Exprは全てVarとなっている前提)
 * 	@note	target list: SELECT対象の列
 *
 * 	oracle_fdwのconvertTupleに影響を受け、PostgreSQLでのデータ型も把握した方が良いと
 * 	判断したため用意した関数。
 */
static void 
store_pg_data_type(OgawayamaFdwState* fdw_state, List* tlist)
{
	ListCell* lc;

	if (tlist != NULL)
	{
		Oid *data_types = (Oid *)palloc(sizeof(Oid) * tlist->length);

		int i = 0;
		int count = 0;
		foreach (lc, tlist)
		{
			TargetEntry *entry = (TargetEntry *)lfirst(lc);
			Node *node = (Node *)entry->expr;
			if (entry->resjunk == false)
			{
				count++;
			}

			if (nodeTag(node) == T_Var)
			{
				Var *var = (Var *)node;
				data_types[i] = var->vartype;
			}
			else
			{
				elog(ERROR, "Unexpected data type in target list. (index: %d, type:%u)",
					 i, (unsigned int)nodeTag(node));
			}
			i++;
		}

		fdw_state->column_types = data_types;
		fdw_state->number_of_columns = count;
	}
}

/*
 *	@brief	dispatch the query to ogawayama stub.
 */
static void 
create_cursor(ForeignScanState* node)
{
	Assert(node!= nullptr);

	OgawayamaFdwState* fdw_state = (OgawayamaFdwState*) node->fdw_state;

	elog(DEBUG2, "tsurugi_fdw : %s \"%s\"", __func__, fdw_state->query_string);

	// trim terminal semi-column.
	std::string query(fdw_state->query_string);
	if (query.back() == ';') 
	{
		query.pop_back();	// trim the trailing colon.
	}
	fdw_info_.result_set = nullptr;

	/* dispatch query */
	elog(DEBUG1, "query string : \"%s\"\n", query.c_str());
	elog(DEBUG1, "tsurugi_fdw : transaction::execute_query() start.");
	ERROR_CODE error = fdw_info_.transaction->execute_query(query, fdw_info_.result_set);
	elog(DEBUG1, "tsurugi_fdw : transaction::execute_query() done.");
	if (error != ERROR_CODE::OK)
	{
		elog(ERROR, "Transaction::execute_query() failed. (%d)", (int) error);
		fdw_info_.result_set = nullptr;
		fdw_info_.transaction->rollback();
		fdw_info_.xact_level--;
	}
	
	error = fdw_info_.result_set->get_metadata(fdw_info_.metadata);
	if (error != ERROR_CODE::OK)
	{
		elog(ERROR, "result_set::get_metadata() failed. (%d)", (int) error);
	}
	if (!confirm_columns(fdw_info_.metadata, node))
	{
		elog(ERROR, "NOT matched columns between PostgreSQL and Ogawayama.");
	}

	fdw_state->cursor_exists = true;
	fdw_state->tuples.clear();
	fdw_state->num_tuples = 0;
	fdw_state->next_tuple = 0;
	fdw_state->eof_reached = false;
}

/*
 * 	@brief	Confirm column information between PostgreSQL and Ogawayama.
 * 	@param	[in] Ogawayama column information.
 * 	@param	[in] PostgreSQL column information.
 * 	@return true if matched column information.
 * 	@note	This function may be eliminated for performance improvement in the future.
 */
static bool
confirm_columns(MetadataPtr metadata, ForeignScanState* node)
{
	elog(DEBUG4, "confirm_columns() started.");

	OgawayamaFdwState* fdw_state = (OgawayamaFdwState*) node->fdw_state;
	bool ret = true;

	if (metadata->get_types().size() != fdw_state->number_of_columns)
	{
		elog(ERROR, "Number of columns do NOT match. (og: %d), (pg: %lu)",
			(int) metadata->get_types().size(), fdw_state->number_of_columns);
	}

	Size i = 0;
	for (auto types: metadata->get_types())
	{
		switch (static_cast<stub::Metadata::ColumnType::Type>(types.get_type()))
		{
			case stub::Metadata::ColumnType::Type::INT16:
				if (fdw_state->column_types[i] != INT2OID)
				{
					elog(ERROR, 
						"Don't match data type of the column. " 
						"(column: %lu) (og: %d) (pg: %u)", 
						i, (int) types.get_type(), fdw_state->column_types[i] );
					ret = false;
				}
				break;

			case stub::Metadata::ColumnType::Type::INT32:
				if (fdw_state->column_types[i] != INT4OID)
				{
					elog(ERROR, 
						"Don't match data type of the column. " 
						"(column: %lu) (og: %d) (pg: %u)", 
						i, (int) types.get_type(), fdw_state->column_types[i] );
					ret = false;
				}
				break;

			case stub::Metadata::ColumnType::Type::INT64:
				if (fdw_state->column_types[i] != INT8OID)
				{
					elog(ERROR, 
						"Don't match data type of the column. " 
						"(column: %lu) (og: %d) (pg: %u)", 
						i, (int) types.get_type(), fdw_state->column_types[i] );
					ret = false;
				}
				break;

			case stub::Metadata::ColumnType::Type::FLOAT32:
				if (fdw_state->column_types[i] != FLOAT4OID)
				{
					elog(ERROR, 
						"Don't match data type of the column. " 
						"(column: %lu) (og: %d) (pg: %u)", 
						i, (int) types.get_type(), fdw_state->column_types[i] );
					ret = false;
				}
				break;

			case stub::Metadata::ColumnType::Type::FLOAT64:
				if (fdw_state->column_types[i] != FLOAT8OID)
				{
					elog(ERROR, 
						"Don't match data type of the column. " 
						"(column: %lu) (og: %d) (pg: %u)", 
						i, (int) types.get_type(), fdw_state->column_types[i] );
				}
				break;

			case stub::Metadata::ColumnType::Type::TEXT:
				if (fdw_state->column_types[i] != BPCHAROID &&
					fdw_state->column_types[i] != VARCHAROID &&
					fdw_state->column_types[i] != TEXTOID)
				{
					elog(ERROR, 
						"Don't match data type of the column. " 
						"(column: %lu) (og: %d) (pg: %u)", 
						i, (int) types.get_type(), fdw_state->column_types[i] );
					ret = false;
				}
				break;

			case stub::Metadata::ColumnType::Type::NULL_VALUE:
				elog(DEBUG1, "nullptr_VALUE found. (column: %lu)", i);
				ret = false;
				break;

			default:
				elog(ERROR, "Unexpected data type of the column. " 
					"(column: %lu, Og type: %u)", i, (int) types.get_type());
				ret = false;
				break;
		}
		i++;
	}

	elog(DEBUG4, "confirm_columns() done.");

	return ret;
}

/*
 *	@breif	make virtual tuple from result set.
 */
static void
make_virtual_tuple(TupleTableSlot* slot, ForeignScanState* node)
{
	OgawayamaFdwState* fdw_state = (OgawayamaFdwState*) node->fdw_state;

	TupleTableSlot* tuple = *fdw_state->tuple_ite;
	for (size_t i = 0; i < fdw_state->number_of_columns; i++)
	{
		slot->tts_values[i] = tuple->tts_values[i];
		slot->tts_isnull[i] = tuple->tts_isnull[i];
	}
}

/*
 *	@brief	fetch result set from ogawayama stub.
 */
static void
fetch_more_data(ForeignScanState* node)
{
	OgawayamaFdwState* fdw_state = (OgawayamaFdwState*) node->fdw_state;
	MemoryContext oldcontext = nullptr;

	fdw_state->tuples.clear();
	MemoryContextReset(fdw_state->batch_cxt);
	oldcontext = MemoryContextSwitchTo(fdw_state->batch_cxt);

	PG_TRY();
	{
		/* fetch result set */
		ERROR_CODE error = fdw_info_.result_set->next();
		while (error == ERROR_CODE::OK)
		{
			TupleTableSlot* tuple = make_tuple_from_result_set(fdw_info_.result_set, fdw_state);
			fdw_state->tuples.push_back(tuple);
			error = fdw_info_.result_set->next();
		}
		if (error == ERROR_CODE::END_OF_ROW) 
		{
			elog(DEBUG2, "End of row.");
		}
		else
		{
			elog(ERROR, "result_set::next() failed. (%d)", (int) error);
		}
		fdw_state->tuple_ite = fdw_state->tuples.begin();
		fdw_state->num_tuples = fdw_state->tuples.size();
		fdw_state->eof_reached = (fdw_state->num_tuples < fdw_state->fetch_size);

		elog(DEBUG1, "result set count: %d", (int) fdw_state->num_tuples);
	}
	PG_CATCH();
	{
		PG_RE_THROW();
	}
	PG_END_TRY();

	MemoryContextSwitchTo(oldcontext);
}

/*
 *	@breif	obtain tuple data from Ogawayama and convert data type.
 *	@param	[in] result set of query.
 *	@param	[in] FDW state.
 */
static TupleTableSlot* 
make_tuple_from_result_set(ResultSetPtr result_set, OgawayamaFdwState* fdw_state)
{
	elog(DEBUG4, "make_tuple_from_result_set() started.");

	TupleTableSlot* tuple = (TupleTableSlot*) palloc(sizeof(TupleTableSlot));
	tuple->tts_values = (Datum *) palloc0(fdw_state->number_of_columns * sizeof(Datum));
	tuple->tts_isnull = (bool *) palloc0(fdw_state->number_of_columns * sizeof(bool));

	for (size_t i = 0; i < fdw_state->number_of_columns; i++)
	{
		tuple->tts_values[i] = PointerGetDatum(nullptr);
		tuple->tts_isnull[i] = true;

		switch (fdw_state->column_types[i])
		{
			case INT2OID:
				{
					std::int16_t value;
					if (result_set->next_column(value) == ERROR_CODE::OK)
					{
						tuple->tts_values[i] = Int16GetDatum(value);
						tuple->tts_isnull[i] = false;
					}
				}
				break;

			case INT4OID:
				{
					std::int32_t value;
					if (result_set->next_column(value) == ERROR_CODE::OK)
					{
						tuple->tts_values[i] = Int32GetDatum(value);
						tuple->tts_isnull[i] = false;
					}
				}
				break;

			case INT8OID:
				{
					std::int64_t value;
					if (result_set->next_column(value) == ERROR_CODE::OK) 
					{
						tuple->tts_values[i] = Int64GetDatum(value);
						tuple->tts_isnull[i] = false;
					}
				}
				break;

			case FLOAT4OID:
				{
					float4 value;
					if (result_set->next_column(value) == ERROR_CODE::OK)
					{
						tuple->tts_values[i] = Float4GetDatum(value);
						tuple->tts_isnull[i] = false;
					}
				}
				break;

			case FLOAT8OID:
				{
					float8 value;
					if (result_set->next_column(value) == ERROR_CODE::OK)
					{
						tuple->tts_values[i] = Float8GetDatum(value);
						tuple->tts_isnull[i] = false;
					}
				}
				break;
			
			case BPCHAROID:
			case VARCHAROID:
			case TEXTOID:
				{
					Datum dat;
					std::string_view value;
					result_set->next_column(value);
					dat = CStringGetDatum(value.data());				
					if (dat == (Datum) nullptr)
					{
						break;
					}
					else
					{
						HeapTuple 	heap_tuple;
						regproc 	typinput;
						int 		typemod;

						heap_tuple = SearchSysCache1(
							TYPEOID, ObjectIdGetDatum(fdw_state->column_types[i]));
						if (!HeapTupleIsValid(heap_tuple))
						{
							elog(ERROR, "cache lookup failed for type %u",
								 fdw_state->column_types[i]);
						}
						typinput = ((Form_pg_type)GETSTRUCT(heap_tuple))->typinput;
						typemod = ((Form_pg_type)GETSTRUCT(heap_tuple))->typtypmod;
						ReleaseSysCache(heap_tuple);
						tuple->tts_values[i] = OidFunctionCall3(typinput, dat, ObjectIdGetDatum(InvalidOid), Int32GetDatum(typemod));
						tuple->tts_isnull[i] = false;
					}
				}
				break;
				
			default:
				elog(ERROR, "Invalid data type of column.");
				break;
		}
	}

	elog(DEBUG4, "make_tuple_from_result_set() done.");

	return tuple;
}

/*
 * @biref	Begin transaction.
 * 
 * V0版では、フロントエンド側のトランザクション(ローカルトランザクション)が
 * ネストされている場合はエラーとする。
 */
static void
begin_backend_xact(void)
{
	/* ローカルトランザクションのネストレベルを取得する */
    int local_xact_level = GetCurrentTransactionNestLevel();
	elog(DEBUG1, "Local transaction level: (%d)", local_xact_level);

	if (local_xact_level <= 0)
	{
		elog(WARNING, "local_xact_level (%d)", local_xact_level);
	}
	else if (local_xact_level == 1)
	{
		if (fdw_info_.xact_level == 0)
		{	
			if (fdw_info_.transaction == nullptr)
			{
				ERROR_CODE error = StubManager::begin(&fdw_info_.transaction);
				if (error != ERROR_CODE::OK) 
				{
					elog(ERROR, "Connection::begin() failed. (%d)", (int) error);
				}
			}
			else
			{
				elog(ERROR, "transaction alreayd started.");
			}
			fdw_info_.xact_level++;
			elog(DEBUG1, "StubManager::begin() done. (xact_level: %d)", 
			fdw_info_.xact_level);
		}
	}
	else if (local_xact_level >= 2)
	{
		elog(ERROR, "Nested transaction is NOT supported.");
	}
}

/*
 * 	@biref	Callback function for transaction events.
 *	@param	Transaction event.
 */
static void
ogawayama_xact_callback (XactEvent event, void *arg)
{
	elog(DEBUG4, "ogawayama_xact_callback() started. ");

    int local_xact_level = GetCurrentTransactionNestLevel();
	elog(DEBUG1, "Local transaction level: (%d)", local_xact_level);

	if (fdw_info_.xact_level > 0)
	{
		/* 入力されるeventの内容は、xact.hに記載あり */
		switch (event)
		{
			case XACT_EVENT_PRE_COMMIT:
				elog(DEBUG1, "XACT_EVENT_PRE_COMMIT");
				break;

			case XACT_EVENT_COMMIT:
				elog(DEBUG1, "XACT_EVENT_COMMIT");
				fdw_info_.transaction->commit();
				fdw_info_.transaction = nullptr;
				StubManager::end();
				fdw_info_.xact_level--;
				elog(DEBUG1, "Transaction::commit() done. (xact_level: %d)", 
					fdw_info_.xact_level);
				break;

			case XACT_EVENT_ABORT:
				elog(DEBUG1, "XACT_EVENT_ABORT (xact_level: %d)", fdw_info_.xact_level);
				fdw_info_.transaction->rollback();
				fdw_info_.transaction = nullptr;
				StubManager::end();
				fdw_info_.xact_level--;
				elog(DEBUG1, "Transaction::rollback() done. (xact_level: %d)", 
					fdw_info_.xact_level);
				break;

			case XACT_EVENT_PRE_PREPARE:
				elog(DEBUG1, "XACT_EVENT_PRE_PREPARE");
				break;

			case XACT_EVENT_PREPARE:
				elog(DEBUG1, "XACT_EVENT_PREPARE");
				break;

			case XACT_EVENT_PARALLEL_COMMIT:
			case XACT_EVENT_PARALLEL_ABORT:
			case XACT_EVENT_PARALLEL_PRE_COMMIT:
				elog(DEBUG1, "Unexpected XACT event occurred. (%d)", event);
				break;

			default:
				elog(WARNING, "Unexpected XACT event occurred. (Unknown event)");
				break;
		}
	}

	elog(DEBUG4, "ogawayama_xact_callback() done.");
}




/*
 * Detect whether we want to process an EquivalenceClass member.
 *
 * This is a callback for use by generate_implied_equalities_for_column.
 */
static bool
ec_member_matches_foreign(PlannerInfo *root, RelOptInfo *rel,
						  EquivalenceClass *ec, EquivalenceMember *em,
						  void *arg)
{
	ec_member_foreign_arg *state = (ec_member_foreign_arg *) arg;
	Expr	   *expr = em->em_expr;

	/*
	 * If we've identified what we're processing in the current scan, we only
	 * want to match that expression.
	 */
	if (state->current != NULL)
		return equal(expr, state->current);

	/*
	 * Otherwise, ignore anything we've already processed.
	 */
	if (list_member(state->already_used, expr))
		return false;

	/* This is the new target to process. */
	state->current = expr;
	return true;
}

/*
 * Force assorted GUC parameters to settings that ensure that we'll output
 * data values in a form that is unambiguous to the remote server.
 *
 * This is rather expensive and annoying to do once per row, but there's
 * little choice if we want to be sure values are transmitted accurately;
 * we can't leave the settings in place between rows for fear of affecting
 * user-visible computations.
 *
 * We use the equivalent of a function SET option to allow the settings to
 * persist only until the caller calls reset_transmission_modes().  If an
 * error is thrown in between, guc.c will take care of undoing the settings.
 *
 * The return value is the nestlevel that must be passed to
 * reset_transmission_modes() to undo things.
 */
int
set_transmission_modes(void)
{
	int			nestlevel = NewGUCNestLevel();

	/*
	 * The values set here should match what pg_dump does.  See also
	 * configure_remote_session in connection.c.
	 */
	if (DateStyle != USE_ISO_DATES)
		(void) set_config_option("datestyle", "ISO",
								 PGC_USERSET, PGC_S_SESSION,
								 GUC_ACTION_SAVE, true, 0, false);
	if (IntervalStyle != INTSTYLE_POSTGRES)
		(void) set_config_option("intervalstyle", "postgres",
								 PGC_USERSET, PGC_S_SESSION,
								 GUC_ACTION_SAVE, true, 0, false);
	if (extra_float_digits < 3)
		(void) set_config_option("extra_float_digits", "3",
								 PGC_USERSET, PGC_S_SESSION,
								 GUC_ACTION_SAVE, true, 0, false);

	return nestlevel;
}

/*
 * Undo the effects of set_transmission_modes().
 */
void
reset_transmission_modes(int nestlevel)
{
	AtEOXact_GUC(true, nestlevel);
}

/*
 * build_remote_returning
 *		Build a RETURNING targetlist of a remote query for performing an
 *		UPDATE/DELETE .. RETURNING on a join directly
 */
static List *
build_remote_returning(Index rtindex, Relation rel, List *returningList)
{
	bool		have_wholerow = false;
	List	   *tlist = NIL;
	List	   *vars;
	ListCell   *lc;

	Assert(returningList);

	vars = pull_var_clause((Node *) returningList, PVC_INCLUDE_PLACEHOLDERS);

	/*
	 * If there's a whole-row reference to the target relation, then we'll
	 * need all the columns of the relation.
	 */
	foreach(lc, vars)
	{
		Var		   *var = (Var *) lfirst(lc);

		if (IsA(var, Var) &&
			var->varno == rtindex &&
			var->varattno == InvalidAttrNumber)
		{
			have_wholerow = true;
			break;
		}
	}

	if (have_wholerow)
	{
		TupleDesc	tupdesc = RelationGetDescr(rel);
		int			i;

		for (i = 1; i <= tupdesc->natts; i++)
		{
			Form_pg_attribute attr = TupleDescAttr(tupdesc, i - 1);
			Var		   *var;

			/* Ignore dropped attributes. */
			if (attr->attisdropped)
				continue;

			var = makeVar(rtindex,
						  i,
						  attr->atttypid,
						  attr->atttypmod,
						  attr->attcollation,
						  0);

			tlist = lappend(tlist,
							makeTargetEntry((Expr *) var,
											list_length(tlist) + 1,
											NULL,
											false));
		}
	}

	/* Now add any remaining columns to tlist. */
	foreach(lc, vars)
	{
		Var		   *var = (Var *) lfirst(lc);

		/*
		 * No need for whole-row references to the target relation.  We don't
		 * need system columns other than ctid and oid either, since those are
		 * set locally.
		 */
		if (IsA(var, Var) &&
			var->varno == rtindex &&
			var->varattno <= InvalidAttrNumber &&
			var->varattno != SelfItemPointerAttributeNumber)
			continue;			/* don't need it */

		if (tlist_member((Expr *) var, tlist))
			continue;			/* already got it */

		tlist = lappend(tlist,
						makeTargetEntry((Expr *) var,
										list_length(tlist) + 1,
										NULL,
										false));
	}

	list_free(vars);

	return tlist;
}

/*
 * rebuild_fdw_scan_tlist
 *		Build new fdw_scan_tlist of given foreign-scan plan node from given
 *		tlist
 *
 * There might be columns that the fdw_scan_tlist of the given foreign-scan
 * plan node contains that the given tlist doesn't.  The fdw_scan_tlist would
 * have contained resjunk columns such as 'ctid' of the target relation and
 * 'wholerow' of non-target relations, but the tlist might not contain them,
 * for example.  So, adjust the tlist so it contains all the columns specified
 * in the fdw_scan_tlist; else setrefs.c will get confused.
 */
static void
rebuild_fdw_scan_tlist(ForeignScan *fscan, List *tlist)
{
	List	   *new_tlist = tlist;
	List	   *old_tlist = fscan->fdw_scan_tlist;
	ListCell   *lc;

	foreach(lc, old_tlist)
	{
		TargetEntry *tle = (TargetEntry *) lfirst(lc);

		if (tlist_member(tle->expr, new_tlist))
			continue;			/* already got it */

		new_tlist = lappend(new_tlist,
							makeTargetEntry(tle->expr,
											list_length(new_tlist) + 1,
											NULL,
											false));
	}
	fscan->fdw_scan_tlist = new_tlist;
}


/*
 * Prepare for processing of parameters used in remote query.
 */
static void
prepare_query_params(PlanState *node,
					 List *fdw_exprs,
					 int numParams,
					 FmgrInfo **param_flinfo,
					 List **param_exprs,
					 const char ***param_values)
{
	int			i;
	ListCell   *lc;

	Assert(numParams > 0);

	/* Prepare for output conversion of parameters used in remote query. */
	*param_flinfo = (FmgrInfo *) palloc0(sizeof(FmgrInfo) * numParams);

	i = 0;
	foreach(lc, fdw_exprs)
	{
		Node	   *param_expr = (Node *) lfirst(lc);
		Oid			typefnoid;
		bool		isvarlena;

		getTypeOutputInfo(exprType(param_expr), &typefnoid, &isvarlena);
		fmgr_info(typefnoid, &(*param_flinfo)[i]);
		i++;
	}

	/*
	 * Prepare remote-parameter expressions for evaluation.  (Note: in
	 * practice, we expect that all these expressions will be just Params, so
	 * we could possibly do something more efficient than using the full
	 * expression-eval machinery for this.  But probably there would be little
	 * benefit, and it'd require postgres_fdw to know more than is desirable
	 * about Param evaluation.)
	 */
	*param_exprs = ExecInitExprList(fdw_exprs, node);

	/* Allocate buffer for text form of query parameters. */
	*param_values = (const char **) palloc0(numParams * sizeof(char *));
}

/*
 * Construct array of query parameter values in text format.
 */
static void
process_query_params(ExprContext *econtext,
					 FmgrInfo *param_flinfo,
					 List *param_exprs,
					 const char **param_values)
{
	int			nestlevel;
	int			i;
	ListCell   *lc;

	nestlevel = set_transmission_modes();

	i = 0;
	foreach(lc, param_exprs)
	{
		ExprState  *expr_state = (ExprState *) lfirst(lc);
		Datum		expr_value;
		bool		isNull;

		/* Evaluate the parameter expression */
		expr_value = ExecEvalExpr(expr_state, econtext, &isNull);

		/*
		 * Get string representation of each parameter value by invoking
		 * type-specific output function, unless the value is null.
		 */
		if (isNull)
			param_values[i] = NULL;
		else
			param_values[i] = OutputFunctionCall(&param_flinfo[i], expr_value);

		i++;
	}

	reset_transmission_modes(nestlevel);
}

/*
 * Assess whether the join between inner and outer relations can be pushed down
 * to the foreign server. As a side effect, save information we obtain in this
 * function to tsurugiFdwRelationInfo passed in.
 */
static bool
foreign_join_ok(PlannerInfo *root, RelOptInfo *joinrel, JoinType jointype,
				RelOptInfo *outerrel, RelOptInfo *innerrel,
				JoinPathExtraData *extra)
{
	tsurugiFdwRelationInfo *fpinfo;
	tsurugiFdwRelationInfo *fpinfo_o;
	tsurugiFdwRelationInfo *fpinfo_i;
	ListCell   *lc;
	List	   *joinclauses;

	/*
	 * We support pushing down INNER, LEFT, RIGHT and FULL OUTER joins.
	 * Constructing queries representing SEMI and ANTI joins is hard, hence
	 * not considered right now.
	 */
	if (jointype != JOIN_INNER && jointype != JOIN_LEFT &&
		jointype != JOIN_RIGHT && jointype != JOIN_FULL)
		return false;

	/*
	 * If either of the joining relations is marked as unsafe to pushdown, the
	 * join can not be pushed down.
	 */
	fpinfo = (tsurugiFdwRelationInfo *) joinrel->fdw_private;
	fpinfo_o = (tsurugiFdwRelationInfo *) outerrel->fdw_private;
	fpinfo_i = (tsurugiFdwRelationInfo *) innerrel->fdw_private;
	if (!fpinfo_o || !fpinfo_o->pushdown_safe ||
		!fpinfo_i || !fpinfo_i->pushdown_safe)
		return false;

	/*
	 * If joining relations have local conditions, those conditions are
	 * required to be applied before joining the relations. Hence the join can
	 * not be pushed down.
	 */
	if (fpinfo_o->local_conds || fpinfo_i->local_conds)
		return false;

	/*
	 * Merge FDW options.  We might be tempted to do this after we have deemed
	 * the foreign join to be OK.  But we must do this beforehand so that we
	 * know which quals can be evaluated on the foreign server, which might
	 * depend on shippable_extensions.
	 */
	fpinfo->server = fpinfo_o->server;
	merge_fdw_options(fpinfo, fpinfo_o, fpinfo_i);

	/*
	 * Separate restrict list into join quals and pushed-down (other) quals.
	 *
	 * Join quals belonging to an outer join must all be shippable, else we
	 * cannot execute the join remotely.  Add such quals to 'joinclauses'.
	 *
	 * Add other quals to fpinfo->remote_conds if they are shippable, else to
	 * fpinfo->local_conds.  In an inner join it's okay to execute conditions
	 * either locally or remotely; the same is true for pushed-down conditions
	 * at an outer join.
	 *
	 * Note we might return failure after having already scribbled on
	 * fpinfo->remote_conds and fpinfo->local_conds.  That's okay because we
	 * won't consult those lists again if we deem the join unshippable.
	 */
	joinclauses = NIL;
	foreach(lc, extra->restrictlist)
	{
		RestrictInfo *rinfo = lfirst_node(RestrictInfo, lc);
		bool		is_remote_clause = is_foreign_expr(root, joinrel,
													   rinfo->clause);

		if (IS_OUTER_JOIN(jointype) &&
			!RINFO_IS_PUSHED_DOWN(rinfo, joinrel->relids))
		{
			if (!is_remote_clause)
				return false;
			joinclauses = lappend(joinclauses, rinfo);
		}
		else
		{
			if (is_remote_clause)
				fpinfo->remote_conds = lappend(fpinfo->remote_conds, rinfo);
			else
				fpinfo->local_conds = lappend(fpinfo->local_conds, rinfo);
		}
	}

	/*
	 * deparseExplicitTargetList() isn't smart enough to handle anything other
	 * than a Var.  In particular, if there's some PlaceHolderVar that would
	 * need to be evaluated within this join tree (because there's an upper
	 * reference to a quantity that may go to NULL as a result of an outer
	 * join), then we can't try to push the join down because we'll fail when
	 * we get to deparseExplicitTargetList().  However, a PlaceHolderVar that
	 * needs to be evaluated *at the top* of this join tree is OK, because we
	 * can do that locally after fetching the results from the remote side.
	 */
	foreach(lc, root->placeholder_list)
	{
		PlaceHolderInfo *phinfo = (PlaceHolderInfo *) lfirst(lc);
		Relids		relids;

		/* PlaceHolderInfo refers to parent relids, not child relids. */
		relids = IS_OTHER_REL(joinrel) ?
			joinrel->top_parent_relids : joinrel->relids;

		if (bms_is_subset(phinfo->ph_eval_at, relids) &&
			bms_nonempty_difference(relids, phinfo->ph_eval_at))
			return false;
	}

	/* Save the join clauses, for later use. */
	fpinfo->joinclauses = joinclauses;

	fpinfo->outerrel = outerrel;
	fpinfo->innerrel = innerrel;
	fpinfo->jointype = jointype;

	/*
	 * By default, both the input relations are not required to be deparsed as
	 * subqueries, but there might be some relations covered by the input
	 * relations that are required to be deparsed as subqueries, so save the
	 * relids of those relations for later use by the deparser.
	 */
	fpinfo->make_outerrel_subquery = false;
	fpinfo->make_innerrel_subquery = false;
	Assert(bms_is_subset(fpinfo_o->lower_subquery_rels, outerrel->relids));
	Assert(bms_is_subset(fpinfo_i->lower_subquery_rels, innerrel->relids));
	fpinfo->lower_subquery_rels = bms_union(fpinfo_o->lower_subquery_rels,
											fpinfo_i->lower_subquery_rels);

	/*
	 * Pull the other remote conditions from the joining relations into join
	 * clauses or other remote clauses (remote_conds) of this relation
	 * wherever possible. This avoids building subqueries at every join step.
	 *
	 * For an inner join, clauses from both the relations are added to the
	 * other remote clauses. For LEFT and RIGHT OUTER join, the clauses from
	 * the outer side are added to remote_conds since those can be evaluated
	 * after the join is evaluated. The clauses from inner side are added to
	 * the joinclauses, since they need to be evaluated while constructing the
	 * join.
	 *
	 * For a FULL OUTER JOIN, the other clauses from either relation can not
	 * be added to the joinclauses or remote_conds, since each relation acts
	 * as an outer relation for the other.
	 *
	 * The joining sides can not have local conditions, thus no need to test
	 * shippability of the clauses being pulled up.
	 */
	switch (jointype)
	{
		case JOIN_INNER:
			fpinfo->remote_conds = list_concat(fpinfo->remote_conds,
											   list_copy(fpinfo_i->remote_conds));
			fpinfo->remote_conds = list_concat(fpinfo->remote_conds,
											   list_copy(fpinfo_o->remote_conds));
			break;

		case JOIN_LEFT:
			fpinfo->joinclauses = list_concat(fpinfo->joinclauses,
											  list_copy(fpinfo_i->remote_conds));
			fpinfo->remote_conds = list_concat(fpinfo->remote_conds,
											   list_copy(fpinfo_o->remote_conds));
			break;

		case JOIN_RIGHT:
			fpinfo->joinclauses = list_concat(fpinfo->joinclauses,
											  list_copy(fpinfo_o->remote_conds));
			fpinfo->remote_conds = list_concat(fpinfo->remote_conds,
											   list_copy(fpinfo_i->remote_conds));
			break;

		case JOIN_FULL:

			/*
			 * In this case, if any of the input relations has conditions, we
			 * need to deparse that relation as a subquery so that the
			 * conditions can be evaluated before the join.  Remember it in
			 * the fpinfo of this relation so that the deparser can take
			 * appropriate action.  Also, save the relids of base relations
			 * covered by that relation for later use by the deparser.
			 */
			if (fpinfo_o->remote_conds)
			{
				fpinfo->make_outerrel_subquery = true;
				fpinfo->lower_subquery_rels =
					bms_add_members(fpinfo->lower_subquery_rels,
									outerrel->relids);
			}
			if (fpinfo_i->remote_conds)
			{
				fpinfo->make_innerrel_subquery = true;
				fpinfo->lower_subquery_rels =
					bms_add_members(fpinfo->lower_subquery_rels,
									innerrel->relids);
			}
			break;

		default:
			/* Should not happen, we have just checked this above */
			elog(ERROR, "unsupported join type %d", jointype);
	}

	/*
	 * For an inner join, all restrictions can be treated alike. Treating the
	 * pushed down conditions as join conditions allows a top level full outer
	 * join to be deparsed without requiring subqueries.
	 */
	if (jointype == JOIN_INNER)
	{
		Assert(!fpinfo->joinclauses);
		fpinfo->joinclauses = fpinfo->remote_conds;
		fpinfo->remote_conds = NIL;
	}

	/* Mark that this join can be pushed down safely */
	fpinfo->pushdown_safe = true;

	/* Get user mapping */
	if (fpinfo->use_remote_estimate)
	{
		if (fpinfo_o->use_remote_estimate)
			fpinfo->user = fpinfo_o->user;
		else
			fpinfo->user = fpinfo_i->user;
	}
	else
		fpinfo->user = NULL;

	/*
	 * Set # of retrieved rows and cached relation costs to some negative
	 * value, so that we can detect when they are set to some sensible values,
	 * during one (usually the first) of the calls to estimate_path_cost_size.
	 */
	fpinfo->retrieved_rows = -1;
	fpinfo->rel_startup_cost = -1;
	fpinfo->rel_total_cost = -1;

	/*
	 * Set the string describing this join relation to be used in EXPLAIN
	 * output of corresponding ForeignScan.
	 */
	fpinfo->relation_name = makeStringInfo();
	appendStringInfo(fpinfo->relation_name, "(%s) %s JOIN (%s)",
					 fpinfo_o->relation_name->data,
					 get_jointype_name(fpinfo->jointype),
					 fpinfo_i->relation_name->data);

	/*
	 * Set the relation index.  This is defined as the position of this
	 * joinrel in the join_rel_list list plus the length of the rtable list.
	 * Note that since this joinrel is at the end of the join_rel_list list
	 * when we are called, we can get the position by list_length.
	 */
	Assert(fpinfo->relation_index == 0);	/* shouldn't be set yet */
	fpinfo->relation_index =
		list_length(root->parse->rtable) + list_length(root->join_rel_list);

	return true;
}

static void
add_paths_with_pathkeys_for_rel(PlannerInfo *root, RelOptInfo *rel,
								Path *epq_path)
{
	List	   *useful_pathkeys_list = NIL; /* List of all pathkeys */
	ListCell   *lc;

	useful_pathkeys_list = get_useful_pathkeys_for_relation(root, rel);

	/* Create one path for each set of pathkeys we found above. */
	foreach(lc, useful_pathkeys_list)
	{
		double		rows;
		int			width;
		Cost		startup_cost;
		Cost		total_cost;
		List	   *useful_pathkeys = (List *) lfirst(lc);
		Path	   *sorted_epq_path;
#if 0
		estimate_path_cost_size(root, rel, NIL, useful_pathkeys, NULL,
								&rows, &width, &startup_cost, &total_cost);
#endif
		/*
		 * The EPQ path must be at least as well sorted as the path itself, in
		 * case it gets used as input to a mergejoin.
		 */
		sorted_epq_path = epq_path;
		if (sorted_epq_path != NULL &&
			!pathkeys_contained_in(useful_pathkeys,
								   sorted_epq_path->pathkeys))
			sorted_epq_path = (Path *)
				create_sort_path(root,
								 rel,
								 sorted_epq_path,
								 useful_pathkeys,
								 -1.0);

		if (IS_SIMPLE_REL(rel))
			add_path(rel, (Path *)
					 create_foreignscan_path(root, rel,
											 NULL,
											 rows,
											 startup_cost,
											 total_cost,
											 useful_pathkeys,
											 rel->lateral_relids,
											 sorted_epq_path,
											 NIL));
		else
			add_path(rel, (Path *)
					 create_foreign_join_path(root, rel,
											  NULL,
											  rows,
											  startup_cost,
											  total_cost,
											  useful_pathkeys,
											  rel->lateral_relids,
											  sorted_epq_path,
											  NIL));
	}
}

/*
 * Parse options from foreign table and apply them to fpinfo.
 *
 * New options might also require tweaking merge_fdw_options().
 */
static void
apply_table_options(tsurugiFdwRelationInfo *fpinfo)
{
	ListCell   *lc;

	foreach(lc, fpinfo->table->options)
	{
		DefElem    *def = (DefElem *) lfirst(lc);

		if (strcmp(def->defname, "use_remote_estimate") == 0)
			fpinfo->use_remote_estimate = defGetBoolean(def);
		else if (strcmp(def->defname, "fetch_size") == 0)
			fpinfo->fetch_size = strtol(defGetString(def), NULL, 10);
	}
}

/*
 * Merge FDW options from input relations into a new set of options for a join
 * or an upper rel.
 *
 * For a join relation, FDW-specific information about the inner and outer
 * relations is provided using fpinfo_i and fpinfo_o.  For an upper relation,
 * fpinfo_o provides the information for the input relation; fpinfo_i is
 * expected to NULL.
 */
static void
merge_fdw_options(tsurugiFdwRelationInfo *fpinfo,
				  const tsurugiFdwRelationInfo *fpinfo_o,
				  const tsurugiFdwRelationInfo *fpinfo_i)
{
	/* We must always have fpinfo_o. */
	Assert(fpinfo_o);

	/* fpinfo_i may be NULL, but if present the servers must both match. */
	Assert(!fpinfo_i ||
		   fpinfo_i->server->serverid == fpinfo_o->server->serverid);

	/*
	 * Copy the server specific FDW options.  (For a join, both relations come
	 * from the same server, so the server options should have the same value
	 * for both relations.)
	 */
	fpinfo->fdw_startup_cost = fpinfo_o->fdw_startup_cost;
	fpinfo->fdw_tuple_cost = fpinfo_o->fdw_tuple_cost;
	fpinfo->shippable_extensions = fpinfo_o->shippable_extensions;
	fpinfo->use_remote_estimate = fpinfo_o->use_remote_estimate;
	fpinfo->fetch_size = fpinfo_o->fetch_size;

	/* Merge the table level options from either side of the join. */
	if (fpinfo_i)
	{
		/*
		 * We'll prefer to use remote estimates for this join if any table
		 * from either side of the join is using remote estimates.  This is
		 * most likely going to be preferred since they're already willing to
		 * pay the price of a round trip to get the remote EXPLAIN.  In any
		 * case it's not entirely clear how we might otherwise handle this
		 * best.
		 */
		fpinfo->use_remote_estimate = fpinfo_o->use_remote_estimate ||
			fpinfo_i->use_remote_estimate;

		/*
		 * Set fetch size to maximum of the joining sides, since we are
		 * expecting the rows returned by the join to be proportional to the
		 * relation sizes.
		 */
		fpinfo->fetch_size = Max(fpinfo_o->fetch_size, fpinfo_i->fetch_size);
	}
}

/*
 * postgresGetForeignJoinPaths
 *		Add possible ForeignPath to joinrel, if join is safe to push down.
 */
static void
postgresGetForeignJoinPaths(PlannerInfo *root,
							RelOptInfo *joinrel,
							RelOptInfo *outerrel,
							RelOptInfo *innerrel,
							JoinType jointype,
							JoinPathExtraData *extra)
{
	tsurugiFdwRelationInfo *fpinfo;
	ForeignPath *joinpath;
	double		rows;
	int			width;
	Cost		startup_cost;
	Cost		total_cost;
	Path	   *epq_path;		/* Path to create plan to be executed when
								 * EvalPlanQual gets triggered. */

	/*
	 * Skip if this join combination has been considered already.
	 */
	if (joinrel->fdw_private)
		return;

	/*
	 * This code does not work for joins with lateral references, since those
	 * must have parameterized paths, which we don't generate yet.
	 */
	if (!bms_is_empty(joinrel->lateral_relids))
		return;

	/*
	 * Create unfinished tsurugiFdwRelationInfo entry which is used to indicate
	 * that the join relation is already considered, so that we won't waste
	 * time in judging safety of join pushdown and adding the same paths again
	 * if found safe. Once we know that this join can be pushed down, we fill
	 * the entry.
	 */
	fpinfo = (tsurugiFdwRelationInfo *) palloc0(sizeof(tsurugiFdwRelationInfo));
	fpinfo->pushdown_safe = false;
	joinrel->fdw_private = fpinfo;
	/* attrs_used is only for base relations. */
	fpinfo->attrs_used = NULL;

	/*
	 * If there is a possibility that EvalPlanQual will be executed, we need
	 * to be able to reconstruct the row using scans of the base relations.
	 * GetExistingLocalJoinPath will find a suitable path for this purpose in
	 * the path list of the joinrel, if one exists.  We must be careful to
	 * call it before adding any ForeignPath, since the ForeignPath might
	 * dominate the only suitable local path available.  We also do it before
	 * calling foreign_join_ok(), since that function updates fpinfo and marks
	 * it as pushable if the join is found to be pushable.
	 */
	if (root->parse->commandType == CMD_DELETE ||
		root->parse->commandType == CMD_UPDATE ||
		root->rowMarks)
	{
		epq_path = GetExistingLocalJoinPath(joinrel);
		if (!epq_path)
		{
			elog(DEBUG3, "could not push down foreign join because a local path suitable for EPQ checks was not found");
			return;
		}
	}
	else
		epq_path = NULL;

	if (!foreign_join_ok(root, joinrel, jointype, outerrel, innerrel, extra))
	{
		/* Free path required for EPQ if we copied one; we don't need it now */
		if (epq_path)
			pfree(epq_path);
		return;
	}

	/*
	 * Compute the selectivity and cost of the local_conds, so we don't have
	 * to do it over again for each path. The best we can do for these
	 * conditions is to estimate selectivity on the basis of local statistics.
	 * The local conditions are applied after the join has been computed on
	 * the remote side like quals in WHERE clause, so pass jointype as
	 * JOIN_INNER.
	 */
	fpinfo->local_conds_sel = clauselist_selectivity(root,
													 fpinfo->local_conds,
													 0,
													 JOIN_INNER,
													 NULL);
	cost_qual_eval(&fpinfo->local_conds_cost, fpinfo->local_conds, root);

	/*
	 * If we are going to estimate costs locally, estimate the join clause
	 * selectivity here while we have special join info.
	 */
	if (!fpinfo->use_remote_estimate)
		fpinfo->joinclause_sel = clauselist_selectivity(root, fpinfo->joinclauses,
														0, fpinfo->jointype,
														extra->sjinfo);
#if 0
	/* Estimate costs for bare join relation */
	estimate_path_cost_size(root, joinrel, NIL, NIL, NULL,
							&rows, &width, &startup_cost, &total_cost);
#endif
	/* Now update this information in the joinrel */
	joinrel->rows = rows;
	joinrel->reltarget->width = width;
	fpinfo->rows = rows;
	fpinfo->width = width;
	fpinfo->startup_cost = startup_cost;
	fpinfo->total_cost = total_cost;

	/*
	 * Create a new join path and add it to the joinrel which represents a
	 * join between foreign tables.
	 */
	joinpath = create_foreign_join_path(root,
										joinrel,
										NULL,	/* default pathtarget */
										rows,
										startup_cost,
										total_cost,
										NIL,	/* no pathkeys */
										joinrel->lateral_relids,
										epq_path,
										NIL);	/* no fdw_private */

	/* Add generated path into joinrel by add_path(). */
	add_path(joinrel, (Path *) joinpath);

	/* Consider pathkeys for the join relation */
	add_paths_with_pathkeys_for_rel(root, joinrel, epq_path);

	/* XXX Consider parameterized paths for the join relation */
}

/*
 * Assess whether the aggregation, grouping and having operations can be pushed
 * down to the foreign server.  As a side effect, save information we obtain in
 * this function to tsurugiFdwRelationInfo of the input relation.
 */
static bool
foreign_grouping_ok(PlannerInfo *root, RelOptInfo *grouped_rel,
					Node *havingQual)
{
	Query	   *query = root->parse;
	tsurugiFdwRelationInfo *fpinfo = (tsurugiFdwRelationInfo *) grouped_rel->fdw_private;
	PathTarget *grouping_target = grouped_rel->reltarget;
	tsurugiFdwRelationInfo *ofpinfo;
	ListCell   *lc;
	int			i;
	List	   *tlist = NIL;

	/* We currently don't support pushing Grouping Sets. */
	if (query->groupingSets)
		return false;

	/* Get the fpinfo of the underlying scan relation. */
	ofpinfo = (tsurugiFdwRelationInfo *) fpinfo->outerrel->fdw_private;

	/*
	 * If underlying scan relation has any local conditions, those conditions
	 * are required to be applied before performing aggregation.  Hence the
	 * aggregate cannot be pushed down.
	 */
	if (ofpinfo->local_conds)
		return false;

	/*
	 * Examine grouping expressions, as well as other expressions we'd need to
	 * compute, and check whether they are safe to push down to the foreign
	 * server.  All GROUP BY expressions will be part of the grouping target
	 * and thus there is no need to search for them separately.  Add grouping
	 * expressions into target list which will be passed to foreign server.
	 *
	 * A tricky fine point is that we must not put any expression into the
	 * target list that is just a foreign param (that is, something that
	 * deparse.c would conclude has to be sent to the foreign server).  If we
	 * do, the expression will also appear in the fdw_exprs list of the plan
	 * node, and setrefs.c will get confused and decide that the fdw_exprs
	 * entry is actually a reference to the fdw_scan_tlist entry, resulting in
	 * a broken plan.  Somewhat oddly, it's OK if the expression contains such
	 * a node, as long as it's not at top level; then no match is possible.
	 */
	i = 0;
	foreach(lc, grouping_target->exprs)
	{
		Expr	   *expr = (Expr *) lfirst(lc);
		Index		sgref = get_pathtarget_sortgroupref(grouping_target, i);
		ListCell   *l;

		/* Check whether this expression is part of GROUP BY clause */
		if (sgref && get_sortgroupref_clause_noerr(sgref, query->groupClause))
		{
			TargetEntry *tle;

			/*
			 * If any GROUP BY expression is not shippable, then we cannot
			 * push down aggregation to the foreign server.
			 */
			if (!is_foreign_expr(root, grouped_rel, expr))
				return false;

			/*
			 * If it would be a foreign param, we can't put it into the tlist,
			 * so we have to fail.
			 */
			if (is_foreign_param(root, grouped_rel, expr))
				return false;

			/*
			 * Pushable, so add to tlist.  We need to create a TLE for this
			 * expression and apply the sortgroupref to it.  We cannot use
			 * add_to_flat_tlist() here because that avoids making duplicate
			 * entries in the tlist.  If there are duplicate entries with
			 * distinct sortgrouprefs, we have to duplicate that situation in
			 * the output tlist.
			 */
			tle = makeTargetEntry(expr, list_length(tlist) + 1, NULL, false);
			tle->ressortgroupref = sgref;
			tlist = lappend(tlist, tle);
		}
		else
		{
			/*
			 * Non-grouping expression we need to compute.  Can we ship it
			 * as-is to the foreign server?
			 */
			if (is_foreign_expr(root, grouped_rel, expr) &&
				!is_foreign_param(root, grouped_rel, expr))
			{
				/* Yes, so add to tlist as-is; OK to suppress duplicates */
				tlist = add_to_flat_tlist(tlist, list_make1(expr));
			}
			else
			{
				/* Not pushable as a whole; extract its Vars and aggregates */
				List	   *aggvars;

				aggvars = pull_var_clause((Node *) expr,
										  PVC_INCLUDE_AGGREGATES);

				/*
				 * If any aggregate expression is not shippable, then we
				 * cannot push down aggregation to the foreign server.  (We
				 * don't have to check is_foreign_param, since that certainly
				 * won't return true for any such expression.)
				 */
				if (!is_foreign_expr(root, grouped_rel, (Expr *) aggvars))
					return false;

				/*
				 * Add aggregates, if any, into the targetlist.  Plain Vars
				 * outside an aggregate can be ignored, because they should be
				 * either same as some GROUP BY column or part of some GROUP
				 * BY expression.  In either case, they are already part of
				 * the targetlist and thus no need to add them again.  In fact
				 * including plain Vars in the tlist when they do not match a
				 * GROUP BY column would cause the foreign server to complain
				 * that the shipped query is invalid.
				 */
				foreach(l, aggvars)
				{
					Expr	   *expr = (Expr *) lfirst(l);

					if (IsA(expr, Aggref))
						tlist = add_to_flat_tlist(tlist, list_make1(expr));
				}
			}
		}

		i++;
	}

	/*
	 * Classify the pushable and non-pushable HAVING clauses and save them in
	 * remote_conds and local_conds of the grouped rel's fpinfo.
	 */
	if (havingQual)
	{
		ListCell   *lc;

		foreach(lc, (List *) havingQual)
		{
			Expr	   *expr = (Expr *) lfirst(lc);
			RestrictInfo *rinfo;

			/*
			 * Currently, the core code doesn't wrap havingQuals in
			 * RestrictInfos, so we must make our own.
			 */
			Assert(!IsA(expr, RestrictInfo));
			rinfo = make_restrictinfo(expr,
									  true,
									  false,
									  false,
									  root->qual_security_level,
									  grouped_rel->relids,
									  NULL,
									  NULL);
			if (is_foreign_expr(root, grouped_rel, expr))
				fpinfo->remote_conds = lappend(fpinfo->remote_conds, rinfo);
			else
				fpinfo->local_conds = lappend(fpinfo->local_conds, rinfo);
		}
	}

	/*
	 * If there are any local conditions, pull Vars and aggregates from it and
	 * check whether they are safe to pushdown or not.
	 */
	if (fpinfo->local_conds)
	{
		List	   *aggvars = NIL;
		ListCell   *lc;

		foreach(lc, fpinfo->local_conds)
		{
			RestrictInfo *rinfo = lfirst_node(RestrictInfo, lc);

			aggvars = list_concat(aggvars,
								  pull_var_clause((Node *) rinfo->clause,
												  PVC_INCLUDE_AGGREGATES));
		}

		foreach(lc, aggvars)
		{
			Expr	   *expr = (Expr *) lfirst(lc);

			/*
			 * If aggregates within local conditions are not safe to push
			 * down, then we cannot push down the query.  Vars are already
			 * part of GROUP BY clause which are checked above, so no need to
			 * access them again here.  Again, we need not check
			 * is_foreign_param for a foreign aggregate.
			 */
			if (IsA(expr, Aggref))
			{
				if (!is_foreign_expr(root, grouped_rel, expr))
					return false;

				tlist = add_to_flat_tlist(tlist, list_make1(expr));
			}
		}
	}

	/* Store generated targetlist */
	fpinfo->grouped_tlist = tlist;

	/* Safe to pushdown */
	fpinfo->pushdown_safe = true;

	/*
	 * Set # of retrieved rows and cached relation costs to some negative
	 * value, so that we can detect when they are set to some sensible values,
	 * during one (usually the first) of the calls to estimate_path_cost_size.
	 */
	fpinfo->retrieved_rows = -1;
	fpinfo->rel_startup_cost = -1;
	fpinfo->rel_total_cost = -1;

	/*
	 * Set the string describing this grouped relation to be used in EXPLAIN
	 * output of corresponding ForeignScan.
	 */
	fpinfo->relation_name = makeStringInfo();
	appendStringInfo(fpinfo->relation_name, "Aggregate on (%s)",
					 ofpinfo->relation_name->data);

	return true;
}

/*
 * postgresGetForeignUpperPaths
 *		Add paths for post-join operations like aggregation, grouping etc. if
 *		corresponding operations are safe to push down.
 */
static void
postgresGetForeignUpperPaths(PlannerInfo *root, UpperRelationKind stage,
							 RelOptInfo *input_rel, RelOptInfo *output_rel,
							 void *extra)
{
	tsurugiFdwRelationInfo *fpinfo;

	/*
	 * If input rel is not safe to pushdown, then simply return as we cannot
	 * perform any post-join operations on the foreign server.
	 */
	if (!input_rel->fdw_private ||
		!((tsurugiFdwRelationInfo *) input_rel->fdw_private)->pushdown_safe)
		return;

	/* Ignore stages we don't support; and skip any duplicate calls. */
	if ((stage != UPPERREL_GROUP_AGG &&
		 stage != UPPERREL_ORDERED &&
		 stage != UPPERREL_FINAL) ||
		output_rel->fdw_private)
		return;

	fpinfo = (tsurugiFdwRelationInfo *) palloc0(sizeof(tsurugiFdwRelationInfo));
	fpinfo->pushdown_safe = false;
	fpinfo->stage = stage;
	output_rel->fdw_private = fpinfo;

	switch (stage)
	{
		case UPPERREL_GROUP_AGG:
			add_foreign_grouping_paths(root, input_rel, output_rel,
									   (GroupPathExtraData *) extra);
			break;
		case UPPERREL_ORDERED:
			add_foreign_ordered_paths(root, input_rel, output_rel);
			break;
		case UPPERREL_FINAL:
			add_foreign_final_paths(root, input_rel, output_rel,
									(FinalPathExtraData *) extra);
			break;
		default:
			elog(ERROR, "unexpected upper relation: %d", (int) stage);
			break;
	}
}

/*
 * add_foreign_grouping_paths
 *		Add foreign path for grouping and/or aggregation.
 *
 * Given input_rel represents the underlying scan.  The paths are added to the
 * given grouped_rel.
 */
static void
add_foreign_grouping_paths(PlannerInfo *root, RelOptInfo *input_rel,
						   RelOptInfo *grouped_rel,
						   GroupPathExtraData *extra)
{
	Query	   *parse = root->parse;
	tsurugiFdwRelationInfo *ifpinfo = (tsurugiFdwRelationInfo *) input_rel->fdw_private;
	tsurugiFdwRelationInfo *fpinfo = (tsurugiFdwRelationInfo *) grouped_rel->fdw_private;
	ForeignPath *grouppath;
	double		rows;
	int			width;
	Cost		startup_cost;
	Cost		total_cost;

	/* Nothing to be done, if there is no grouping or aggregation required. */
	if (!parse->groupClause && !parse->groupingSets && !parse->hasAggs &&
		!root->hasHavingQual)
		return;

	Assert(extra->patype == PARTITIONWISE_AGGREGATE_NONE ||
		   extra->patype == PARTITIONWISE_AGGREGATE_FULL);

	/* save the input_rel as outerrel in fpinfo */
	fpinfo->outerrel = input_rel;

	/*
	 * Copy foreign table, foreign server, user mapping, FDW options etc.
	 * details from the input relation's fpinfo.
	 */
	fpinfo->table = ifpinfo->table;
	fpinfo->server = ifpinfo->server;
	fpinfo->user = ifpinfo->user;
	merge_fdw_options(fpinfo, ifpinfo, NULL);

	/*
	 * Assess if it is safe to push down aggregation and grouping.
	 *
	 * Use HAVING qual from extra. In case of child partition, it will have
	 * translated Vars.
	 */
	if (!foreign_grouping_ok(root, grouped_rel, extra->havingQual))
		return;

	/*
	 * Compute the selectivity and cost of the local_conds, so we don't have
	 * to do it over again for each path.  (Currently we create just a single
	 * path here, but in future it would be possible that we build more paths
	 * such as pre-sorted paths as in postgresGetForeignPaths and
	 * postgresGetForeignJoinPaths.)  The best we can do for these conditions
	 * is to estimate selectivity on the basis of local statistics.
	 */
	fpinfo->local_conds_sel = clauselist_selectivity(root,
													 fpinfo->local_conds,
													 0,
													 JOIN_INNER,
													 NULL);

	cost_qual_eval(&fpinfo->local_conds_cost, fpinfo->local_conds, root);
#if 0
	/* Estimate the cost of push down */
	estimate_path_cost_size(root, grouped_rel, NIL, NIL, NULL,
							&rows, &width, &startup_cost, &total_cost);
#endif
	/* Now update this information in the fpinfo */
	fpinfo->rows = rows;
	fpinfo->width = width;
	fpinfo->startup_cost = startup_cost;
	fpinfo->total_cost = total_cost;

	/* Create and add foreign path to the grouping relation. */
	grouppath = create_foreign_upper_path(root,
										  grouped_rel,
										  grouped_rel->reltarget,
										  rows,
										  startup_cost,
										  total_cost,
										  NIL,	/* no pathkeys */
										  NULL,
										  NIL); /* no fdw_private */

	/* Add generated path into grouped_rel by add_path(). */
	add_path(grouped_rel, (Path *) grouppath);
}

/*
 * add_foreign_ordered_paths
 *		Add foreign paths for performing the final sort remotely.
 *
 * Given input_rel contains the source-data Paths.  The paths are added to the
 * given ordered_rel.
 */
static void
add_foreign_ordered_paths(PlannerInfo *root, RelOptInfo *input_rel,
						  RelOptInfo *ordered_rel)
{
	Query	   *parse = root->parse;
	tsurugiFdwRelationInfo *ifpinfo = (tsurugiFdwRelationInfo *) input_rel->fdw_private;
	tsurugiFdwRelationInfo *fpinfo = (tsurugiFdwRelationInfo *) ordered_rel->fdw_private;
	PgFdwPathExtraData *fpextra;
	double		rows;
	int			width;
	Cost		startup_cost;
	Cost		total_cost;
	List	   *fdw_private;
	ForeignPath *ordered_path;
	ListCell   *lc;

	/* Shouldn't get here unless the query has ORDER BY */
	Assert(parse->sortClause);

	/* We don't support cases where there are any SRFs in the targetlist */
	if (parse->hasTargetSRFs)
		return;

	/* Save the input_rel as outerrel in fpinfo */
	fpinfo->outerrel = input_rel;

	/*
	 * Copy foreign table, foreign server, user mapping, FDW options etc.
	 * details from the input relation's fpinfo.
	 */
	fpinfo->table = ifpinfo->table;
	fpinfo->server = ifpinfo->server;
	fpinfo->user = ifpinfo->user;
	merge_fdw_options(fpinfo, ifpinfo, NULL);

	/*
	 * If the input_rel is a base or join relation, we would already have
	 * considered pushing down the final sort to the remote server when
	 * creating pre-sorted foreign paths for that relation, because the
	 * query_pathkeys is set to the root->sort_pathkeys in that case (see
	 * standard_qp_callback()).
	 */
	if (input_rel->reloptkind == RELOPT_BASEREL ||
		input_rel->reloptkind == RELOPT_JOINREL)
	{
		Assert(root->query_pathkeys == root->sort_pathkeys);

		/* Safe to push down if the query_pathkeys is safe to push down */
		fpinfo->pushdown_safe = ifpinfo->qp_is_pushdown_safe;

		return;
	}

	/* The input_rel should be a grouping relation */
	Assert(input_rel->reloptkind == RELOPT_UPPER_REL &&
		   ifpinfo->stage == UPPERREL_GROUP_AGG);

	/*
	 * We try to create a path below by extending a simple foreign path for
	 * the underlying grouping relation to perform the final sort remotely,
	 * which is stored into the fdw_private list of the resulting path.
	 */

	/* Assess if it is safe to push down the final sort */
	foreach(lc, root->sort_pathkeys)
	{
		PathKey    *pathkey = (PathKey *) lfirst(lc);
		EquivalenceClass *pathkey_ec = pathkey->pk_eclass;
		Expr	   *sort_expr;

		/*
		 * is_foreign_expr would detect volatile expressions as well, but
		 * checking ec_has_volatile here saves some cycles.
		 */
		if (pathkey_ec->ec_has_volatile)
			return;

		/* Get the sort expression for the pathkey_ec */
		sort_expr = find_em_expr_for_input_target(root,
												  pathkey_ec,
												  input_rel->reltarget);

		/* If it's unsafe to remote, we cannot push down the final sort */
		if (!is_foreign_expr(root, input_rel, sort_expr))
			return;
	}

	/* Safe to push down */
	fpinfo->pushdown_safe = true;

	/* Construct PgFdwPathExtraData */
	fpextra = (PgFdwPathExtraData *) palloc0(sizeof(PgFdwPathExtraData));
	fpextra->target = root->upper_targets[UPPERREL_ORDERED];
	fpextra->has_final_sort = true;

	/* Estimate the costs of performing the final sort remotely */
	estimate_path_cost_size(root, input_rel, NIL, root->sort_pathkeys, fpextra,
							&rows, &width, &startup_cost, &total_cost);

	/*
	 * Build the fdw_private list that will be used by postgresGetForeignPlan.
	 * Items in the list must match order in enum FdwPathPrivateIndex.
	 */
	fdw_private = list_make2(makeInteger(true), makeInteger(false));

	/* Create foreign ordering path */
	ordered_path = create_foreign_upper_path(root,
											 input_rel,
											 root->upper_targets[UPPERREL_ORDERED],
											 rows,
											 startup_cost,
											 total_cost,
											 root->sort_pathkeys,
											 NULL,	/* no extra plan */
											 fdw_private);

	/* and add it to the ordered_rel */
	add_path(ordered_rel, (Path *) ordered_path);
}

/*
 * add_foreign_final_paths
 *		Add foreign paths for performing the final processing remotely.
 *
 * Given input_rel contains the source-data Paths.  The paths are added to the
 * given final_rel.
 */
static void
add_foreign_final_paths(PlannerInfo *root, RelOptInfo *input_rel,
						RelOptInfo *final_rel,
						FinalPathExtraData *extra)
{
	Query	   *parse = root->parse;
	tsurugiFdwRelationInfo *ifpinfo = (tsurugiFdwRelationInfo *) input_rel->fdw_private;
	tsurugiFdwRelationInfo *fpinfo = (tsurugiFdwRelationInfo *) final_rel->fdw_private;
	bool		has_final_sort = false;
	List	   *pathkeys = NIL;
	PgFdwPathExtraData *fpextra;
	bool		save_use_remote_estimate = false;
	double		rows;
	int			width;
	Cost		startup_cost;
	Cost		total_cost;
	List	   *fdw_private;
	ForeignPath *final_path;

	/*
	 * Currently, we only support this for SELECT commands
	 */
	if (parse->commandType != CMD_SELECT)
		return;

	/*
	 * No work if there is no FOR UPDATE/SHARE clause and if there is no need
	 * to add a LIMIT node
	 */
	if (!parse->rowMarks && !extra->limit_needed)
		return;

	/* We don't support cases where there are any SRFs in the targetlist */
	if (parse->hasTargetSRFs)
		return;

	/* Save the input_rel as outerrel in fpinfo */
	fpinfo->outerrel = input_rel;

	/*
	 * Copy foreign table, foreign server, user mapping, FDW options etc.
	 * details from the input relation's fpinfo.
	 */
	fpinfo->table = ifpinfo->table;
	fpinfo->server = ifpinfo->server;
	fpinfo->user = ifpinfo->user;
	merge_fdw_options(fpinfo, ifpinfo, NULL);

	/*
	 * If there is no need to add a LIMIT node, there might be a ForeignPath
	 * in the input_rel's pathlist that implements all behavior of the query.
	 * Note: we would already have accounted for the query's FOR UPDATE/SHARE
	 * (if any) before we get here.
	 */
	if (!extra->limit_needed)
	{
		ListCell   *lc;

		Assert(parse->rowMarks);

		/*
		 * Grouping and aggregation are not supported with FOR UPDATE/SHARE,
		 * so the input_rel should be a base, join, or ordered relation; and
		 * if it's an ordered relation, its input relation should be a base or
		 * join relation.
		 */
		Assert(input_rel->reloptkind == RELOPT_BASEREL ||
			   input_rel->reloptkind == RELOPT_JOINREL ||
			   (input_rel->reloptkind == RELOPT_UPPER_REL &&
				ifpinfo->stage == UPPERREL_ORDERED &&
				(ifpinfo->outerrel->reloptkind == RELOPT_BASEREL ||
				 ifpinfo->outerrel->reloptkind == RELOPT_JOINREL)));

		foreach(lc, input_rel->pathlist)
		{
			Path	   *path = (Path *) lfirst(lc);

			/*
			 * apply_scanjoin_target_to_paths() uses create_projection_path()
			 * to adjust each of its input paths if needed, whereas
			 * create_ordered_paths() uses apply_projection_to_path() to do
			 * that.  So the former might have put a ProjectionPath on top of
			 * the ForeignPath; look through ProjectionPath and see if the
			 * path underneath it is ForeignPath.
			 */
			if (IsA(path, ForeignPath) ||
				(IsA(path, ProjectionPath) &&
				 IsA(((ProjectionPath *) path)->subpath, ForeignPath)))
			{
				/*
				 * Create foreign final path; this gets rid of a
				 * no-longer-needed outer plan (if any), which makes the
				 * EXPLAIN output look cleaner
				 */
				final_path = create_foreign_upper_path(root,
													   path->parent,
													   path->pathtarget,
													   path->rows,
													   path->startup_cost,
													   path->total_cost,
													   path->pathkeys,
													   NULL,	/* no extra plan */
													   NULL);	/* no fdw_private */

				/* and add it to the final_rel */
				add_path(final_rel, (Path *) final_path);

				/* Safe to push down */
				fpinfo->pushdown_safe = true;

				return;
			}
		}

		/*
		 * If we get here it means no ForeignPaths; since we would already
		 * have considered pushing down all operations for the query to the
		 * remote server, give up on it.
		 */
		return;
	}

	Assert(extra->limit_needed);

	/*
	 * If the input_rel is an ordered relation, replace the input_rel with its
	 * input relation
	 */
	if (input_rel->reloptkind == RELOPT_UPPER_REL &&
		ifpinfo->stage == UPPERREL_ORDERED)
	{
		input_rel = ifpinfo->outerrel;
		ifpinfo = (tsurugiFdwRelationInfo *) input_rel->fdw_private;
		has_final_sort = true;
		pathkeys = root->sort_pathkeys;
	}

	/* The input_rel should be a base, join, or grouping relation */
	Assert(input_rel->reloptkind == RELOPT_BASEREL ||
		   input_rel->reloptkind == RELOPT_JOINREL ||
		   (input_rel->reloptkind == RELOPT_UPPER_REL &&
			ifpinfo->stage == UPPERREL_GROUP_AGG));

	/*
	 * We try to create a path below by extending a simple foreign path for
	 * the underlying base, join, or grouping relation to perform the final
	 * sort (if has_final_sort) and the LIMIT restriction remotely, which is
	 * stored into the fdw_private list of the resulting path.  (We
	 * re-estimate the costs of sorting the underlying relation, if
	 * has_final_sort.)
	 */

	/*
	 * Assess if it is safe to push down the LIMIT and OFFSET to the remote
	 * server
	 */

	/*
	 * If the underlying relation has any local conditions, the LIMIT/OFFSET
	 * cannot be pushed down.
	 */
	if (ifpinfo->local_conds)
		return;

	/*
	 * Also, the LIMIT/OFFSET cannot be pushed down, if their expressions are
	 * not safe to remote.
	 */
	if (!is_foreign_expr(root, input_rel, (Expr *) parse->limitOffset) ||
		!is_foreign_expr(root, input_rel, (Expr *) parse->limitCount))
		return;

	/* Safe to push down */
	fpinfo->pushdown_safe = true;

	/* Construct PgFdwPathExtraData */
	fpextra = (PgFdwPathExtraData *) palloc0(sizeof(PgFdwPathExtraData));
	fpextra->target = root->upper_targets[UPPERREL_FINAL];
	fpextra->has_final_sort = has_final_sort;
	fpextra->has_limit = extra->limit_needed;
	fpextra->limit_tuples = extra->limit_tuples;
	fpextra->count_est = extra->count_est;
	fpextra->offset_est = extra->offset_est;

	/*
	 * Estimate the costs of performing the final sort and the LIMIT
	 * restriction remotely.  If has_final_sort is false, we wouldn't need to
	 * execute EXPLAIN anymore if use_remote_estimate, since the costs can be
	 * roughly estimated using the costs we already have for the underlying
	 * relation, in the same way as when use_remote_estimate is false.  Since
	 * it's pretty expensive to execute EXPLAIN, force use_remote_estimate to
	 * false in that case.
	 */
	if (!fpextra->has_final_sort)
	{
		save_use_remote_estimate = ifpinfo->use_remote_estimate;
		ifpinfo->use_remote_estimate = false;
	}
	estimate_path_cost_size(root, input_rel, NIL, pathkeys, fpextra,
							&rows, &width, &startup_cost, &total_cost);
	if (!fpextra->has_final_sort)
		ifpinfo->use_remote_estimate = save_use_remote_estimate;

	/*
	 * Build the fdw_private list that will be used by postgresGetForeignPlan.
	 * Items in the list must match order in enum FdwPathPrivateIndex.
	 */
	fdw_private = list_make2(makeInteger(has_final_sort),
							 makeInteger(extra->limit_needed));

	/*
	 * Create foreign final path; this gets rid of a no-longer-needed outer
	 * plan (if any), which makes the EXPLAIN output look cleaner
	 */
	final_path = create_foreign_upper_path(root,
										   input_rel,
										   root->upper_targets[UPPERREL_FINAL],
										   rows,
										   startup_cost,
										   total_cost,
										   pathkeys,
										   NULL,	/* no extra plan */
										   fdw_private);

	/* and add it to the final_rel */
	add_path(final_rel, (Path *) final_path);
}

/*
 * Find an equivalence class member expression, all of whose Vars, come from
 * the indicated relation.
 */
Expr *
find_em_expr_for_rel(EquivalenceClass *ec, RelOptInfo *rel)
{
	ListCell   *lc_em;

	foreach(lc_em, ec->ec_members)
	{
		EquivalenceMember *em = (EquivalenceMember *) lfirst(lc_em);

		if (bms_is_subset(em->em_relids, rel->relids) &&
			!bms_is_empty(em->em_relids))
		{
			/*
			 * If there is more than one equivalence member whose Vars are
			 * taken entirely from this relation, we'll be content to choose
			 * any one of those.
			 */
			return em->em_expr;
		}
	}

	/* We didn't find any suitable equivalence class expression */
	return NULL;
}

/*
 * Find an equivalence class member expression to be computed as a sort column
 * in the given target.
 */
Expr *
find_em_expr_for_input_target(PlannerInfo *root,
							  EquivalenceClass *ec,
							  PathTarget *target)
{
	ListCell   *lc1;
	int			i;

	i = 0;
	foreach(lc1, target->exprs)
	{
		Expr	   *expr = (Expr *) lfirst(lc1);
		Index		sgref = get_pathtarget_sortgroupref(target, i);
		ListCell   *lc2;

		/* Ignore non-sort expressions */
		if (sgref == 0 ||
			get_sortgroupref_clause_noerr(sgref,
										  root->parse->sortClause) == NULL)
		{
			i++;
			continue;
		}

		/* We ignore binary-compatible relabeling on both ends */
		while (expr && IsA(expr, RelabelType))
			expr = ((RelabelType *) expr)->arg;

		/* Locate an EquivalenceClass member matching this expr, if any */
		foreach(lc2, ec->ec_members)
		{
			EquivalenceMember *em = (EquivalenceMember *) lfirst(lc2);
			Expr	   *em_expr;

			/* Don't match constants */
			if (em->em_is_const)
				continue;

			/* Ignore child members */
			if (em->em_is_child)
				continue;

			/* Match if same expression (after stripping relabel) */
			em_expr = em->em_expr;
			while (em_expr && IsA(em_expr, RelabelType))
				em_expr = ((RelabelType *) em_expr)->arg;

			if (equal(em_expr, expr))
				return em->em_expr;
		}

		i++;
	}

	elog(ERROR, "could not find pathkey item to sort");
	return NULL;				/* keep compiler quiet */
}

static void 
estimate_path_cost_size(PlannerInfo *root,
						RelOptInfo *foreignrel,
						List *param_join_conds,
						List *pathkeys,
						PgFdwPathExtraData *fpextra,
						double *p_rows, int *p_width,
						Cost *p_startup_cost, Cost *p_total_cost)
{
	return;
}

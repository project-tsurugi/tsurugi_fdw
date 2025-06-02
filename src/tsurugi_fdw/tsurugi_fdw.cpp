/*
 * Copyright 2019-2025 Project Tsurugi.
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
 *	@file	tsurugi_fdw.cpp
 *	@brief 	Foreign Data Wrapper for Tsurugi.
 */
#include <boost/format.hpp>
//#include <boost/multiprecision/cpp_int.hpp>
//#include <memory>
//#include <regex>
//#include <string>
#include "ogawayama/stub/error_code.h"
#include "ogawayama/stub/api.h"

#include "tsurugi.h"
#include "tsurugi_utils.h"
#include "tsurugi_prepare.h"

#ifdef __cplusplus
extern "C" {
#endif
#include "postgres.h"
#include "tsurugi_fdw.h"

#include "access/xact.h"
#include "access/htup_details.h"
#include "access/sysattr.h"
#include "access/table.h"
#include "access/tupdesc.h"
#include "catalog/pg_class.h"
#include "commands/defrem.h"
#include "commands/explain.h"
#include "commands/vacuum.h"
#include "fmgr.h"
#include "foreign/fdwapi.h"
#include "miscadmin.h"
#include "nodes/makefuncs.h"
#include "nodes/nodeFuncs.h"
#if PG_VERSION_NUM >= 140000
#include "optimizer/appendinfo.h"	// get_translated_update_targetlist
#endif  // PG_VERSION_NUM >= 140000
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
#include "utils/numeric.h"
#include "utils/rel.h"
#include "utils/sampling.h"
#include "utils/selfuncs.h"
#include "utils/syscache.h"
#include "nodes/pg_list.h"

PG_MODULE_MAGIC;

#ifdef __cplusplus
}
#endif

int unused PG_USED_FOR_ASSERTS_ONLY;

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

/*
 * Similarly, this enum describes what's kept in the fdw_private list for
 * a ModifyTable node referencing a postgres_fdw foreign table.  We store:
 *
 * 1) INSERT/UPDATE/DELETE statement text to be sent to the remote server
 * 2) Integer list of target attribute numbers for INSERT/UPDATE
 *	  (NIL for a DELETE)
 * 3) Length till the end of VALUES clause for INSERT
 *	  (-1 for a DELETE/UPDATE)
 * 4) Boolean flag showing if the remote query has a RETURNING clause
 * 5) Integer list of attribute numbers retrieved by RETURNING, if any
 */
enum FdwModifyPrivateIndex
{
	/* SQL statement to execute remotely (as a String node) */
	FdwModifyPrivateUpdateSql,
	/* Integer list of target attribute numbers for INSERT/UPDATE */
	FdwModifyPrivateTargetAttnums,
	/* Length till the end of VALUES clause (as an integer Value node) */
	FdwModifyPrivateLen,
	/* has-returning flag (as an integer Value node) */
	FdwModifyPrivateHasReturning,
	/* Integer list of attribute numbers retrieved by RETURNING */
	FdwModifyPrivateRetrievedAttrs
};

#if 0
/*
 *	@brief 	FDW status per session
 */
typedef struct tsurugi_fdw_info_
{
	ResultSetPtr 		result_set = nullptr;
	MetadataPtr 		metadata = nullptr;
    bool                success = false;
} TsurugiFdwInfo;
#endif
#if 0
/*
 * Execution state of a foreign insert/update/delete operation.
 */
typedef struct TgFdwForeignModifyState
{
	Relation	rel;			/* relcache entry for the foreign table */
	AttInMetadata *attinmeta;	/* attribute datatype conversion metadata */

	/* for remote query execution */
	char	   *prep_name;		/* name of prepared statement, if created */

	/* extracted fdw_private data */
	char	   *query;			/* text of INSERT/UPDATE/DELETE command */
	char	   *orig_query;		/* original text of INSERT command */
	List	   *target_attrs;	/* list of target attribute numbers */
	int			values_end;		/* length up to the end of VALUES */
	int			batch_size;		/* value of FDW option "batch_size" */
	bool		has_returning;	/* is there a RETURNING clause? */
	List	   *retrieved_attrs;	/* attr numbers retrieved by RETURNING */

	/* info about parameters for prepared statement */
	AttrNumber	ctidAttno;		/* attnum of input resjunk ctid column */
	int			p_nums;			/* number of parameters to transmit */
	FmgrInfo   *p_flinfo;		/* output conversion functions for them */

	/* batch operation stuff */
	int			num_slots;		/* number of slots to insert */

	/* working memory context */
	MemoryContext temp_cxt;		/* context for per-tuple temporary data */

	/* for update row movement if subplan result rel */
	struct TgFdwForeignModifyState *aux_fmstate;	/* foreign-insert state, if
											 	 	 * created */
} TgFdwForeignModifyState;
#endif
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

/* ===========================================================================
 * 
 * Prototype declarations
 * 
 */
#ifdef __cplusplus
extern "C" {
#endif

PG_FUNCTION_INFO_V1(tsurugi_fdw_handler);

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
static void tsurugiGetForeignUpperPaths(PlannerInfo *root, UpperRelationKind stage,
							 			RelOptInfo *input_rel, RelOptInfo *output_rel,
							 			void *extra);
/*
 * FDW callback routines (Insert/Update/Delete)
 */
#if PG_VERSION_NUM >= 140000
static void tsurugiAddForeignUpdateTargets(PlannerInfo *root,
											Index rtindex,
											RangeTblEntry *target_rte,
											Relation target_relation);
#else
static void tsurugiAddForeignUpdateTargets(Query *parsetree,
											RangeTblEntry *target_rte,
											Relation target_relation);
#endif  // PG_VERSION_NUM >= 140000
static List *tsurugiPlanForeignModify(PlannerInfo *root,
									   ModifyTable *plan,
									   Index resultRelation,
									   int subplan_index);
static bool tsurugiPlanDirectModify(PlannerInfo *root,
									 ModifyTable *plan,
									 Index resultRelation,
									 int subplan_index);
static void tsurugiBeginDirectModify(ForeignScanState* node, int eflags);
static TupleTableSlot* tsurugiIterateDirectModify(ForeignScanState* node);
static void tsurugiEndDirectModify(ForeignScanState* node);
static void tsurugiBeginForeignModify(ModifyTableState *mtstate,
                                        ResultRelInfo *rinfo,
                                        List *fdw_private,
                                        int subplan_index,
                                        int eflags);
static TupleTableSlot* tsurugiExecForeignUpdate(EState *estate, 
                                                ResultRelInfo *rinfo, 
                                                TupleTableSlot *slot, 
                                                TupleTableSlot *planSlot);

static TupleTableSlot* tsurugiExecForeignDelete(EState *estate, 
                                                ResultRelInfo *rinfo, 
                                                TupleTableSlot *slot, 
                                                TupleTableSlot *planSlot);
static void tsurugiEndForeignModify(EState *estate,
                                    ResultRelInfo *rinfo);
static void tsurugiBeginForeignInsert(ModifyTableState *mtstate,
                                    ResultRelInfo *rinfo);
static TupleTableSlot* tsurugiExecForeignInsert(EState *estate, 
                                                ResultRelInfo *rinfo, 
                                                TupleTableSlot *slot, 
                                                TupleTableSlot *planSlot);
static void tsurugiEndForeignInsert(EState *estate,
                                    ResultRelInfo *rinfo);

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
#ifdef __cplusplus
}
#endif

/*
 * Helper functions
 */
extern PGDLLIMPORT PGPROC *MyProc;

extern void handle_remote_xact(ForeignServer *server);

static TgFdwForeignScanState* create_fdw_state();
#if PG_VERSION_NUM >= 140000
static ForeignScan *find_modifytable_subplan(PlannerInfo *root,
						 					ModifyTable *plan,
						 					Index rtindex,
						 					int subplan_index);
#endif	/* PG_VERSION_NUM >= 140000 */
static void store_pg_data_type(TgFdwForeignScanState* fsstate, List* tlist, List** );

/* ===========================================================================
 * 
 * FDW Handler
 *
 */
/*
 * Foreign-data wrapper handler function: return a struct with pointers
 * to my callback routines.
 */
Datum
tsurugi_fdw_handler(PG_FUNCTION_ARGS)
{
	FdwRoutine* routine = makeNode(FdwRoutine);

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	/*Functions for scanning foreign tables*/
	routine->GetForeignRelSize = tsurugiGetForeignRelSize;
	routine->GetForeignPaths = tsurugiGetForeignPaths;
	routine->GetForeignPlan = tsurugiGetForeignPlan;
	routine->BeginForeignScan = tsurugiBeginForeignScan;
	routine->IterateForeignScan = tsurugiIterateForeignScan;
	routine->ReScanForeignScan = tsurugiReScanForeignScan;
	routine->EndForeignScan = tsurugiEndForeignScan;
	routine->GetForeignUpperPaths = tsurugiGetForeignUpperPaths;

	/*Functions for updating foreign tables*/
	routine->AddForeignUpdateTargets = tsurugiAddForeignUpdateTargets;
	routine->PlanForeignModify = tsurugiPlanForeignModify;
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

   /*Functions for foreign modify*/
	routine->BeginForeignModify = tsurugiBeginForeignModify;
	routine->ExecForeignInsert = tsurugiExecForeignInsert;
	routine->ExecForeignUpdate = tsurugiExecForeignUpdate;
	routine->ExecForeignDelete = tsurugiExecForeignDelete;
	routine->EndForeignModify = tsurugiEndForeignModify;
	routine->BeginForeignInsert = tsurugiBeginForeignInsert;
	routine->EndForeignInsert = tsurugiEndForeignInsert;

	/* Support functions for join push-down */
	routine->GetForeignJoinPaths = tsurugiGetForeignJoinPaths;

	ERROR_CODE error = Tsurugi::init();
	if (error != ERROR_CODE::OK) 
	{
		elog(ERROR, "tsurugi_fdw : Tsurugi::init() failed. (%d)", (int) error);
	}
	elog(LOG, "tsurugi_fdw : tsurugi_fdw handler has been initialized.");

	PG_RETURN_POINTER(routine);
}

/* ===========================================================================
 *
 * FDW Scan functions. 
 * 
 */

/*
 * tsurugiGetForeignRelSize
 */
static void tsurugiGetForeignRelSize(
	PlannerInfo* root, RelOptInfo* baserel, Oid foreigntableid)
{
	TgFdwRelationInfo *fpinfo;
	ListCell   *lc;
	RangeTblEntry *rte = planner_rt_fetch(baserel->relid, root);
	const char *namespace_string;
	const char *relname;
	const char *refname;

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	/*
	 * We use TgFdwRelationInfo to pass various information to subsequent
	 * functions.
	 */
	fpinfo = (TgFdwRelationInfo *) palloc0(sizeof(TgFdwRelationInfo));
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

/*	apply_server_options(fpinfo);	*/
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
 * tsurugiGetForeignUpperPaths
 *		Add paths for post-join operations like aggregation, grouping etc. if
 *		corresponding operations are safe to push down.
 */
void
tsurugiGetForeignUpperPaths(PlannerInfo *root, UpperRelationKind stage,
							 RelOptInfo *input_rel, RelOptInfo *output_rel,
							 void *extra)
{
	TgFdwRelationInfo *fpinfo;

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	/*
	 * If input rel is not safe to pushdown, then simply return as we cannot
	 * perform any post-join operations on the foreign server.
	 */
	if (!input_rel->fdw_private ||
		!((TgFdwRelationInfo *) input_rel->fdw_private)->pushdown_safe)
		return;

	/* Ignore stages we don't support; and skip any duplicate calls. */
	if ((stage != UPPERREL_GROUP_AGG &&
		 stage != UPPERREL_ORDERED &&
		 stage != UPPERREL_FINAL) ||
		output_rel->fdw_private)
		return;

	fpinfo = (TgFdwRelationInfo *) palloc0(sizeof(TgFdwRelationInfo));
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
 * tsurugiGetForeignPaths
 */
static void 
tsurugiGetForeignPaths(PlannerInfo *root,
                        RelOptInfo *baserel,
                        Oid foreigntableid)
{
	TgFdwRelationInfo *fpinfo = (TgFdwRelationInfo *) baserel->fdw_private;
	ForeignPath *path;
	List	   *ppi_list;
	ListCell   *lc;

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

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
		double		rows = 0;
		int			width;
		Cost		startup_cost = 0;
		Cost		total_cost = 0;
		/* Get a cost estimate from the remote */
		estimate_path_cost_size(root, baserel,
								param_info->ppi_clauses, NIL, NULL,
								&rows, &width,
								&startup_cost, &total_cost);

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

/*	
 * tsurugiGetForeignPlan
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
	TgFdwRelationInfo *fpinfo = (TgFdwRelationInfo *) foreignrel->fdw_private;
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

	elog(LOG, "tsurugi_fdw : %s", __func__);

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
		 * recheck is handled elsewhere --- see tsurugiGetForeignJoinPaths().
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

	elog(LOG, "tsurugi_fdw - %s\ndeparsed sql:\n%s", __func__, sql.data);

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
 * tsurugiGetForeignJoinPaths
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
	TgFdwRelationInfo *fpinfo;
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
	 * Create unfinished TgFdwRelationInfo entry which is used to indicate
	 * that the join relation is already considered, so that we won't waste
	 * time in judging safety of join pushdown and adding the same paths again
	 * if found safe. Once we know that this join can be pushed down, we fill
	 * the entry.
	 */
	fpinfo = (TgFdwRelationInfo *) palloc0(sizeof(TgFdwRelationInfo));
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
	 * calling tsurugi_foreign_join_ok(), since that function updates fpinfo and marks
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

	if (!tsurugi_foreign_join_ok(root, joinrel, jointype, outerrel, innerrel, extra))
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
 *  tsurugiBeginForeignScan
 *	    Preparation for scanning foreign tables.
 */
static void 
tsurugiBeginForeignScan(ForeignScanState* node, int eflags)
{
	Assert(node != nullptr);

	ForeignScan* fsplan = (ForeignScan*) node->ss.ps.plan;
	TgFdwForeignScanState* fsstate = create_fdw_state();
	RangeTblEntry *rte;
	ForeignTable *table;
	ForeignServer *server;
	int			rtindex;

	/* Prepare processing when via ODBC */
	EState* estate = node->ss.ps.state;

	elog(DEBUG2, "tsurugi_fdw : %s", __func__);

	/*
	 * We'll save private state in node->fdw_state.
	 */
    node->fdw_state = (void*) fsstate;
    fsstate->rowidx = 0;

	if (fsplan->scan.scanrelid > 0)
		rtindex = fsplan->scan.scanrelid;
	else
		rtindex = bms_next_member(fsplan->fs_relids, -1);
	rte = exec_rt_fetch(rtindex, estate);

	/* Get info about foreign table. */
	table = GetForeignTable(rte->relid);
	server = GetForeignServer(table->serverid);

#ifdef __TSURUGI_PLANNER__
	fsstate->query_string = strVal(list_nth(fsplan->fdw_private,
								FdwScanPrivateSelectSql));
	fsstate->retrieved_attrs = (List*) list_nth(fsplan->fdw_private, 
								FdwScanPrivateRetrievedAttrs);
#else
	fsstate->query_string = strVal(list_nth(fsplan->fdw_private,
		FdwScanPrivateSelectSql));
	fsstate->retrieved_attrs = (List*) list_nth(fsplan->fdw_private, 
		FdwScanPrivateRetrievedAttrs);
#endif
  	fsstate->cursor_exists = false;

	/*
	 * Get info we'll need for converting data fetched from the foreign server
	 * into local representation and error reporting during that process.
	 */
	if (fsplan->scan.scanrelid > 0)
	{
		fsstate->rel = node->ss.ss_currentRelation;
		fsstate->tupdesc = RelationGetDescr(fsstate->rel);
	}
	else
	{
		fsstate->rel = NULL;
		fsstate->tupdesc = node->ss.ss_ScanTupleSlot->tts_tupleDescriptor;
	} 

	fsstate->attinmeta = TupleDescGetAttInMetadata(fsstate->tupdesc);

	begin_prepare_processing(estate);
	handle_remote_xact(server);
	fsstate->success = true;
}

/*
 * tsurugiIterateForeignScan
 *      Scanning row data from foreign tables.
 */
static TupleTableSlot* 
tsurugiIterateForeignScan(ForeignScanState* node)
{
	elog(DEBUG5, "tsurugi_fdw : %s", __func__);

	Assert(node != nullptr);

	TgFdwForeignScanState* fsstate = (TgFdwForeignScanState*) node->fdw_state;
	TupleTableSlot* tupleSlot = node->ss.ss_ScanTupleSlot;

	elog(DEBUG2, "tsurugi_fdw : %s", __func__);

	if (!fsstate->cursor_exists)
    {
        std::string query = make_tsurugi_query(fsstate->query_string);
        ERROR_CODE error = Tsurugi::execute_query(query);
        if (error != ERROR_CODE::OK)
        {
            fsstate->success = false;
            /* Prepare processing when via ODBC */
            EState* estate = node->ss.ps.state;
            end_prepare_processing(estate);
			elog(ERROR, "Failed to execute query to Tsurugi. (%d)\n%s", 
                (int) error, Tsurugi::get_error_message(error).c_str());
        }
        fsstate->cursor_exists = true;
        fsstate->eof_reached = false;
    }

	ExecClearTuple(tupleSlot);

    /* No point in another fetch if we already detected EOF, though. */
    if (!fsstate->eof_reached) 
    {
        ERROR_CODE error = Tsurugi::result_set_next_row();
        if (error == ERROR_CODE::OK)
        {
            make_tuple_from_result_row(Tsurugi::get_result_set(), 
                                        tupleSlot->tts_tupleDescriptor,
                                        fsstate->retrieved_attrs,
                                        tupleSlot->tts_values,
                                        tupleSlot->tts_isnull,
                                        fsstate);
            ExecStoreVirtualTuple(tupleSlot);
            fsstate->num_tuples++;
        }
        else if (error == ERROR_CODE::END_OF_ROW) 
        {
            elog(LOG, "End of rows. (rows: %d)", (int) fsstate->num_tuples);
            Tsurugi::init_result_set();
            fsstate->eof_reached = true;
        }
        else
        {
            fsstate->success = false;
            Tsurugi::init_result_set();
            /* Prepare processing when via ODBC */
            EState* estate = node->ss.ps.state;
            end_prepare_processing(estate);
			Tsurugi::report_error("Failed to retrieve result set from Tsurugi.", 
									error, fsstate->query_string);
        }
    }

	return tupleSlot;
}

/*
 *	@note	Not in used.
 */
static void 
tsurugiReScanForeignScan(ForeignScanState* node)
{
	elog(DEBUG2, "tsurugi_fdw : %s", __func__);
}

/*
 * tsurugiEndForeignScan
 *      Clean up for scanning foreign tables.
 */
static void 
tsurugiEndForeignScan(ForeignScanState* node)
{
	elog(DEBUG2, "tsurugi_fdw : %s", __func__);

	/* Prepare processing when via ODBC */
	EState* estate = node->ss.ps.state;
	end_prepare_processing(estate);
}

/* ===========================================================================
 *
 * FDW Modify functions.
 *
 */
 
/*
 * tsurugiAddForeignUpdateTargets
 *      
 */
#if PG_VERSION_NUM >= 140000
static void
tsurugiAddForeignUpdateTargets(PlannerInfo *root,
								Index rtindex,
								RangeTblEntry *target_rte,
								Relation target_relation)
#else
static void 
tsurugiAddForeignUpdateTargets(Query *parsetree,
								RangeTblEntry *target_rte,
								Relation target_relation)
#endif  // PG_VERSION_NUM >= 140000
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
#if PG_VERSION_NUM < 140000
	Plan	   *subplan;
#endif  // PG_VERSION_NUM < 140000
	RelOptInfo *foreignrel;
	RangeTblEntry *rte;
	TgFdwRelationInfo *fpinfo;
	Relation	rel;
	StringInfoData sql;
	ForeignScan *fscan;
#if PG_VERSION_NUM >= 140000
	List	   *processed_tlist = NIL;
#endif  // PG_VERSION_NUM >= 140000
	List	   *targetAttrs = NIL;
	List	   *remote_exprs;
	List	   *params_list = NIL;
	List	   *returningList = NIL;
	List	   *retrieved_attrs = NIL;

	/* operation - 1:SELECT, 2:UPDATE, 3:INSERT, 4:DELETE, 5:UTILITY */
	elog(LOG, "tsurugi_fdw : %s (operation= %d)", __func__, (int) operation);

	/*
	 * Decide whether it is safe to modify a foreign table directly.
	 */

	/*
	 * The table modification must be an UPDATE or DELETE.
	 */
	if (operation != CMD_UPDATE && operation != CMD_DELETE)
#ifdef __TSURUGI_PLANNER__
		return false;
#else
		return false;
#endif

#if PG_VERSION_NUM >= 140000
	/*
	 * Try to locate the ForeignScan subplan that's scanning resultRelation.
	 */
	fscan = find_modifytable_subplan(root, plan, resultRelation, subplan_index);
	if (!fscan)
		return false;
#else
	/*
	 * It's unsafe to modify a foreign table directly if there are any local
	 * joins needed.
	 */
	subplan = (Plan *) list_nth(plan->plans, subplan_index);
	if (!IsA(subplan, ForeignScan))
		return false;
	fscan = (ForeignScan *) subplan;
#endif  // PG_VERSION_NUM >= 140000

	/*
	 * It's unsafe to modify a foreign table directly if there are any quals
	 * that should be evaluated locally.
	 */
#if PG_VERSION_NUM >= 140000
	if (fscan->scan.plan.qual != NIL)
#else
	if (subplan->qual != NIL)
#endif  // PG_VERSION_NUM >= 140000
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
	fpinfo = (TgFdwRelationInfo *) foreignrel->fdw_private;

	/*
	 * It's unsafe to update a foreign table directly, if any expressions to
	 * assign to the target columns are unsafe to evaluate remotely.
	 */
	if (operation == CMD_UPDATE)
	{
#if PG_VERSION_NUM >= 140000
		ListCell   *lc,
				   *lc2;

		/*
		 * The expressions of concern are the first N columns of the processed
		 * targetlist, where N is the length of the rel's update_colnos.
		 */
		get_translated_update_targetlist(root, resultRelation,
										 &processed_tlist, &targetAttrs);
		forboth(lc, processed_tlist, lc2, targetAttrs)
		{
			TargetEntry *tle = lfirst_node(TargetEntry, lc);
			AttrNumber	attno = lfirst_int(lc2);

			/* update's new-value expressions shouldn't be resjunk */
			Assert(!tle->resjunk);

			if (attno <= InvalidAttrNumber) /* shouldn't happen */
				elog(ERROR, "system-column update is not supported");

			if (!is_foreign_expr(root, foreignrel, (Expr *) tle->expr))
				return false;
		}
#else
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
#endif  // PG_VERSION_NUM >= 140000
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
#if PG_VERSION_NUM >= 140000
								   processed_tlist,
#else
								   ((Plan *) fscan)->targetlist,
#endif  // PG_VERSION_NUM >= 140000
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

	elog(LOG, "tsurugi_fdw : %s : \ndeparsed sql:\n%s", __func__, sql.data);

	/*
	 * Update the operation info.
	 */
	fscan->operation = operation;
#if PG_VERSION_NUM >= 140000
	fscan->resultRelation = resultRelation;
#endif  // PG_VERSION_NUM >= 140000

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

#if PG_VERSION_NUM >= 140000
	/*
	 * Finally, unset the async-capable flag if it is set, as we currently
	 * don't support asynchronous execution of direct modifications.
	 */
	if (fscan->scan.plan.async_capable)
		fscan->scan.plan.async_capable = false;
#endif  // PG_VERSION_NUM >= 140000

	table_close(rel, NoLock);
	elog(LOG, "tsurugi_fdw : %s : Selected Direct Modify.", __func__);
	return true;
}

/*
 * tsurugiBeginDirectModify
 *      Preparation for modifying foreign tables.
 */
static void 
tsurugiBeginDirectModify(ForeignScanState* node, int eflags)
{
	RangeTblEntry *rte;
    ForeignTable *table;
    ForeignServer *server;
	ForeignScan* fsplan = (ForeignScan*) node->ss.ps.plan;
	int      rtindex;

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	Assert(node != nullptr);

	EState* estate = node->ss.ps.state;

	if (fsplan->scan.scanrelid > 0)
    	rtindex = fsplan->scan.scanrelid;
  	else
    	rtindex = bms_next_member(fsplan->fs_relids, -1);
  	rte = exec_rt_fetch(rtindex, estate);
  	/* Get info about foreign table. */
  	table = GetForeignTable(rte->relid);
  	server = GetForeignServer(table->serverid);

	TgFdwDirectModifyState* dmstate = 
		(TgFdwDirectModifyState *) palloc0(sizeof(TgFdwDirectModifyState));

 	dmstate->query_string = estate->es_sourceText; 
    node->fdw_state = dmstate;

	/* Prepare processing when via JDBC and ODBC */
	begin_prepare_processing(estate);

	handle_remote_xact(server);
}

/*
 * tsurugiIterateDirectModify
 *      Execute Insert/Upate/Delete command to foreign tables.
 */
static TupleTableSlot* 
tsurugiIterateDirectModify(ForeignScanState* node)
{
	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	Assert(node != nullptr);

	TgFdwDirectModifyState* dmstate = (TgFdwDirectModifyState*) node->fdw_state;
	TupleTableSlot* slot = nullptr;
	EState* estate = node->ss.ps.state;
	ERROR_CODE error;

    std::string statement = make_tsurugi_query(dmstate->query_string);
	std::size_t num_rows = 0;
	error = Tsurugi::execute_statement(statement, num_rows);
	if (error == ERROR_CODE::OK)
    {
		/* Increment the command es_processed count if necessary. */
		estate->es_processed += num_rows;
	} else {
        /* Prepare processing when via JDBC and ODBC */
        end_prepare_processing(estate);
		Tsurugi::report_error("Failed to execute the statement on Tsurugi.", 
								error, dmstate->query_string);
	}
	
	return slot;	
}

/*
 * tsurugiEndDirectModify
 *      Clean up for modifying foreign tables.
 */
static void 
tsurugiEndDirectModify(ForeignScanState* node)
{
	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	/* Prepare processing when via JDBC and ODBC */
	EState* estate = node->ss.ps.state;
	end_prepare_processing(estate);
}

/*
 * tsurugiPlanForeignModify
 */
static List 
*tsurugiPlanForeignModify(PlannerInfo *root,
						   ModifyTable *plan,
						   Index resultRelation,
						   int subplan_index)
{
	CmdType		operation = plan->operation;
	RangeTblEntry *rte = planner_rt_fetch(resultRelation, root);
	Relation	rel;
	StringInfoData sql;
	List	   *targetAttrs = NIL;
	List	   *withCheckOptionList = NIL;
	List	   *returningList = NIL;
	List	   *retrieved_attrs = NIL;
	bool		doNothing = false;
	int			values_end_len = -1;

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	initStringInfo(&sql);

	/*
	 * Core code already has some lock on each rel being planned, so we can
	 * use NoLock here.
	 */
	rel = table_open(rte->relid, NoLock);

	/*
	 * In an INSERT, we transmit all columns that are defined in the foreign
	 * table.  In an UPDATE, if there are BEFORE ROW UPDATE triggers on the
	 * foreign table, we transmit all columns like INSERT; else we transmit
	 * only columns that were explicitly targets of the UPDATE, so as to avoid
	 * unnecessary data transmission.  (We can't do that for INSERT since we
	 * would miss sending default values for columns not listed in the source
	 * statement, and for UPDATE if there are BEFORE ROW UPDATE triggers since
	 * those triggers might change values for non-target columns, in which
	 * case we would miss sending changed values for those columns.)
	 */
	if (operation == CMD_INSERT ||
		(operation == CMD_UPDATE &&
		 rel->trigdesc &&
		 rel->trigdesc->trig_update_before_row))
	{
		TupleDesc	tupdesc = RelationGetDescr(rel);
		int			attnum;

		for (attnum = 1; attnum <= tupdesc->natts; attnum++)
		{
			Form_pg_attribute attr = TupleDescAttr(tupdesc, attnum - 1);

			if (!attr->attisdropped)
				targetAttrs = lappend_int(targetAttrs, attnum);
		}
	}
	else if (operation == CMD_UPDATE)
	{
		int			col;
		Bitmapset  *allUpdatedCols = bms_union(rte->updatedCols, rte->extraUpdatedCols);

		col = -1;
		while ((col = bms_next_member(allUpdatedCols, col)) >= 0)
		{
			/* bit numbers are offset by FirstLowInvalidHeapAttributeNumber */
			AttrNumber	attno = col + FirstLowInvalidHeapAttributeNumber;

			if (attno <= InvalidAttrNumber) /* shouldn't happen */
				elog(ERROR, "system-column update is not supported");
			targetAttrs = lappend_int(targetAttrs, attno);
		}
	}

	/*
	 * Extract the relevant WITH CHECK OPTION list if any.
	 */
	if (plan->withCheckOptionLists)
		withCheckOptionList = (List *) list_nth(plan->withCheckOptionLists,
												subplan_index);

	if (plan->returningLists)
		ereport(ERROR,
				(errcode(ERRCODE_FDW_UNABLE_TO_CREATE_EXECUTION),
				 errmsg("RETURNING clause is not supported")));

	/*
	 * ON CONFLICT DO UPDATE and DO NOTHING case with inference specification
	 * should have already been rejected in the optimizer, as presently there
	 * is no way to recognize an arbiter index on a foreign table.  Only DO
	 * NOTHING is supported without an inference specification.
	 */
	if (plan->onConflictAction == ONCONFLICT_NOTHING)
		doNothing = true;
	else if (plan->onConflictAction != ONCONFLICT_NONE)
		elog(ERROR, "unexpected ON CONFLICT specification: %d",
			 (int) plan->onConflictAction);

	/*
	 * Construct the SQL command string.
	 */
	switch (operation)
	{
		case CMD_INSERT:
			deparseInsertSql(&sql, rte, resultRelation, rel,
							 targetAttrs, doNothing,
							 withCheckOptionList, returningList,
							 &retrieved_attrs, &values_end_len);
			break;
		case CMD_UPDATE:
			deparseUpdateSql(&sql, rte, resultRelation, rel,
							 targetAttrs,
							 withCheckOptionList, returningList,
							 &retrieved_attrs);
			break;
		case CMD_DELETE:
			deparseDeleteSql(&sql, rte, resultRelation, rel,
							 returningList,
							 &retrieved_attrs);
			break;
		default:
			elog(ERROR, "unexpected operation: %d", (int) operation);
			break;
	}

	elog(LOG, "tsurugi_fdw : %s : \ndeparsed sql:\n%s", __func__, sql.data);

	table_close(rel, NoLock);

	elog(LOG, "tsurugi_fdw : %s : Selected Foreign Modify.", __func__);

	/*
	 * Build the fdw_private list that will be available to the executor.
	 * Items in the list must match enum FdwModifyPrivateIndex, above.
	 */
#if PG_VERSION_NUM >= 140000
	return list_make5(makeString(sql.data),
					  targetAttrs,
					  makeInteger(values_end_len),
					  makeInteger((retrieved_attrs != NIL)),
					  retrieved_attrs);
#else
		return list_make3(makeString(sql.data), 
						targetAttrs, 
						makeInteger(values_end_len));
#endif
}

/*
 * tsurugiBeginForeignModify
 */
static void 
tsurugiBeginForeignModify(ModifyTableState *mtstate,
                        ResultRelInfo *resultRelInfo,
                        List *fdw_private,
                        int subplan_index,
                        int eflags)
{
	TgFdwForeignModifyState *fmstate;
	char	   *query;
	List	   *target_attrs;
	bool		has_returning;
	int			values_end_len;
	List	   *retrieved_attrs;
	RangeTblEntry *rte;
    ForeignTable *table;
   	ForeignServer *server;

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	/*
	 * Do nothing in EXPLAIN (no ANALYZE) case.  resultRelInfo->ri_FdwState
	 * stays NULL.
	 */
	if (eflags & EXEC_FLAG_EXPLAIN_ONLY)
		return;

	/* Deconstruct fdw_private data. */
	query = strVal(list_nth(fdw_private,
							FdwModifyPrivateUpdateSql));
	target_attrs = (List *) list_nth(fdw_private,
									 FdwModifyPrivateTargetAttnums);
	values_end_len = intVal(list_nth(fdw_private,
									 FdwModifyPrivateLen));
	has_returning = intVal(list_nth(fdw_private,
									FdwModifyPrivateHasReturning));
	retrieved_attrs = (List *) list_nth(fdw_private,
										FdwModifyPrivateRetrievedAttrs);

	/* Find RTE. */
	rte = exec_rt_fetch(resultRelInfo->ri_RangeTableIndex,
						mtstate->ps.state);

	/* Construct an execution state. */
	fmstate = create_foreign_modify(mtstate->ps.state,
									rte,
									resultRelInfo,
									mtstate->operation,
									outerPlanState(mtstate)->plan,
									query,
									target_attrs,
									values_end_len,
									has_returning,
									retrieved_attrs);

	resultRelInfo->ri_FdwState = fmstate;

	/* Get info about foreign table. */
  	table = GetForeignTable(rte->relid);
  	server = GetForeignServer(table->serverid);
	handle_remote_xact(server);
}

/*
 * tsurugiExecForeignInsert
 */
static TupleTableSlot*
tsurugiExecForeignInsert(
	EState *estate, 
	ResultRelInfo *resultRelInfo, 
	TupleTableSlot *slot, 
	TupleTableSlot *planSlot)
{
	TgFdwForeignModifyState *fmstate = 
		(TgFdwForeignModifyState *) resultRelInfo->ri_FdwState;
	TupleTableSlot **rslot;
	int			numSlots = 1;

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	if (fmstate->aux_fmstate)
		resultRelInfo->ri_FdwState = fmstate->aux_fmstate;
	rslot = execute_foreign_modify(estate, resultRelInfo, CMD_INSERT,
								   &slot, &planSlot, &numSlots);
	/* Revert that change */
	if (fmstate->aux_fmstate)
		resultRelInfo->ri_FdwState = fmstate;

	return rslot ? *rslot : NULL;
}

/*
 * tsurugiExecForeignUpdate
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
 * tsurugiExecForeignDelete
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
 */
static void 
tsurugiEndForeignModify(EState *estate,
                        ResultRelInfo *resultRelInfo)
{
	TgFdwForeignModifyState *fmstate = 
		(TgFdwForeignModifyState *) resultRelInfo->ri_FdwState;

	elog(DEBUG1, "tsurugi_fdw : %s : start_tx: %d", __func__, fmstate->start_tx);

	/* If fmstate is NULL, we are in EXPLAIN; nothing to do */
	if (fmstate == NULL)
		return;

	end_prepare_processing(estate);
}

/*
 * tsurugiBeginForeignInsert
 */
static void 
tsurugiBeginForeignInsert(ModifyTableState *mtstate,
                        ResultRelInfo *resultRelInfo)
{
	elog(DEBUG2, "tsurugi_fdw : %s", __func__);
}

/*
 * tsurugiEndForeignInsert
 */
static void 
tsurugiEndForeignInsert(EState *estate,
                        ResultRelInfo *resultRelInfo)
{
	elog(DEBUG2, "tsurugi_fdw : %s", __func__);
}

/* ===========================================================================
 *
 * FDW Explain functions.
 *
 */

/*
 * tsurugiExplainForeignScan
 *		Produce extra output for EXPLAIN of a ForeignScan on a foreign table
 */
static void 
tsurugiExplainForeignScan(ForeignScanState* node,
						   	ExplainState* es)
{
	List	   *fdw_private;
	char	   *sql;
	char	   *relations;

	elog(DEBUG2, "tsurugi_fdw : %s", __func__);

	fdw_private = ((ForeignScan *) node->ss.ps.plan)->fdw_private;

	/*
	 * Add names of relation handled by the foreign scan when the scan is a
	 * join
	 */
	if (list_length(fdw_private) > FdwScanPrivateRelations)
	{
		relations = strVal(list_nth(fdw_private, FdwScanPrivateRelations));
		ExplainPropertyText("Relations", relations, es);
	}

	/*
	 * Add remote query, when VERBOSE option is specified.
	 */
	if (es->verbose)
	{
		sql = strVal(list_nth(fdw_private, FdwScanPrivateSelectSql));
		ExplainPropertyText("Remote SQL", sql, es);
	}
}

/*
 * tsurugiExplainDirectModify
 *      Not in use.
 */
static void 
tsurugiExplainDirectModify(ForeignScanState* node,
							ExplainState* es)
{
	elog(DEBUG2, "tsurugi_fdw : %s", __func__);
}

/*
 * tsurugiAnalyzeForeignTable
 *      Not in use.
 */
static bool 
tsurugiAnalyzeForeignTable(Relation relation,
    AcquireSampleRowsFunc* func,
    BlockNumber* totalpages)
{
	elog(DEBUG2, "tsurugi_fdw : %s", __func__);

	return true;
}

/* ===========================================================================
 *
 * FDW Import Foreign Schema functions.
 *
 */

/*
 * tsurugiImportForeignSchema
 *      Import table metadata from a foreign server.
 */
static List* tsurugiImportForeignSchema(ImportForeignSchemaStmt* stmt, Oid serverOid)
{
	ERROR_CODE error = ERROR_CODE::UNKNOWN;

	elog(DEBUG2, "tsurugi_fdw : %s", __func__);

	/*
	 * Checking the options of the Import Foreign Schema statement.
	 * If the option is specified, an error is assumed.
	 */
	if ((stmt->options != nullptr) && (stmt->options->length > 0))
	{
#if PG_VERSION_NUM >= 130000
		auto def = static_cast<DefElem*>(lfirst(stmt->options->elements));
#else
		auto def = static_cast<DefElem*>(lfirst(stmt->options->head));
#endif
		ereport(ERROR,
				(errcode(ERRCODE_FDW_INVALID_OPTION_NAME),
				 errmsg(R"(unsupported import foreign schema option "%.64s")", def->defname)));
	}

	/* Get information about foreign server and user mapping. */
	ForeignServer* server = GetForeignServer(serverOid);
	//UserMapping* mapping = GetUserMapping(GetUserId(), server->serverid);

	elog(DEBUG2, "ForeignServer::fdwid: %u", server->fdwid);
	elog(DEBUG2, "ForeignServer::serverid: %u", server->serverid);
	elog(DEBUG2, R"(ForeignServer::servername: "%s")", server->servername);

	TableListPtr tg_table_list;
	/* Get a list of table names from Tsurugi. */
	error = Tsurugi::get_list_tables(tg_table_list);
	if (error != ERROR_CODE::OK)
	{
		ereport(ERROR,
			(errcode(ERRCODE_FDW_UNABLE_TO_CREATE_REPLY),
			 errmsg("Failed to retrieve table list from Tsurugi. (error: %d)",
				static_cast<int>(error)),
			 errdetail("%s", Tsurugi::get_error_message(error).c_str())));
	}

	auto tg_table_names = tg_table_list->get_table_names();

#ifdef ENABLE_IMPORT_TABLE_LIMITS
	/* The basic behavior regarding the restriction of tables to be imported is handled
	 * by PostgreSQL functions.
	 * FDW does not need to handle this and should be disabled.
	 */
	if ((stmt->list_type == FDW_IMPORT_SCHEMA_LIMIT_TO) || (stmt->list_type == FDW_IMPORT_SCHEMA_EXCEPT))
	{
		std::unordered_set<std::string> _table_list;
		ListCell* lc;
		foreach (lc, stmt->table_list)
		{
			_table_list.insert(((RangeVar*)lfirst(lc))->relname);
		}

		for (auto ite = tg_table_names.begin(); ite != tg_table_names.end();)
		{
			bool is_exclude_table = false;

			if (stmt->list_type == FDW_IMPORT_SCHEMA_LIMIT_TO)
			{
				/* include only listed tables in import */
				is_exclude_table = (_table_list.find(*ite) == _table_list.end());
			}
			else if (stmt->list_type == FDW_IMPORT_SCHEMA_EXCEPT)
			{
				/* exclude listed tables from import */
				is_exclude_table = (_table_list.find(*ite) != _table_list.end());
			}

			if (is_exclude_table)
			{
				elog(DEBUG2, R"(exclude table "%s" from import.)", (*ite).c_str());
				ite = tg_table_names.erase(ite);
			}
			else
			{
				++ite;
			}
		}
	}
#endif	// ENABLE_IMPORT_TABLE_LIMITS

	List* result_commands = NIL;
	/* CREATE FOREIGN TABLE statments */
	for (const auto& table_name : tg_table_names)
	{
		TableMetadataPtr tg_table_metadata;

		/* Get table metadata from Tsurugi. */
		error = Tsurugi::get_table_metadata(table_name, tg_table_metadata);
		if (error != ERROR_CODE::OK)
		{
			ereport(ERROR,
				(errcode(ERRCODE_FDW_UNABLE_TO_CREATE_REPLY),
				errmsg("Failed to retrieve table metadata from Tsurugi. (error: %d)",
					static_cast<int>(error)),
				errdetail("%s", Tsurugi::get_error_message(error).c_str())));
		}

		/* Get table metadata from Tsurugi. */
		const auto &tg_columns = tg_table_metadata->columns();

		elog(DEBUG2, R"(table: "%.64s")", table_name.c_str());

		std::ostringstream col_def;  /* columns definition */
		/* Create PostgreSQL column definitions based on Tsurugi column definitions. */
		for (const auto& column : tg_columns)
		{
			/* Convert from Tsurugi datatype to PostgreSQL datatype. */
			auto pg_type = Tsurugi::convert_type_to_pg(column.atom_type());
			if (!pg_type)
			{
				ereport(ERROR,
					(errcode(ERRCODE_FDW_INVALID_DATA_TYPE),
					 errmsg(R"(unsupported tsurugi data type "%d")",
					 	static_cast<int>(column.atom_type())),
					 errdetail(R"(table:"%s" column:"%s" type:%d)",
					 	table_name.c_str(),
					 	column.name().c_str(),
					 	static_cast<int>(column.atom_type()))));
			}
			std::string type_name(*pg_type);

			elog(DEBUG2,
				R"(column: {"name":"%.64s", "tsurugi_atom_type":%d, "postgres_type":"%s"})",
				column.name().c_str(), static_cast<int>(column.atom_type()), type_name.c_str());

			/* Create a column definition. */
			if (col_def.tellp() != 0)
			{
				col_def << ",";
			}
			col_def << "\"" << column.name() << "\" " << type_name;
		}

		/* Create a CREATE FOREIGN TABLE statement. */
		auto table_def =
			(boost::format(R"(CREATE FOREIGN TABLE "%s" (%s) SERVER %s)")
				% table_name.c_str() % col_def.str() % server->servername).str();

		elog(DEBUG1, "%.512s", table_def.c_str());

		result_commands = lappend(result_commands, pstrdup(table_def.c_str()));
	}

	return result_commands;
}

/* ===========================================================================
 *
 * Helper functions.
 * 
 */

/*
 *	create_fdw_state
 *      Create TgFdwForeignScanState structure.
 */
static TgFdwForeignScanState* 
create_fdw_state()
{
	TgFdwForeignScanState* fdw_state = 
		(TgFdwForeignScanState*) palloc0(sizeof(TgFdwForeignScanState));
	
	if (fdw_state == nullptr)
	{
		elog(ERROR, "tsurugi_fdw : %s : palloc0() failed.", __func__);
	}

	fdw_state->cursor_exists = false;
	fdw_state->number_of_columns = 0;
	fdw_state->column_types = nullptr;
	fdw_state->success = false;

	return fdw_state;
}

#if PG_VERSION_NUM >= 140000
/*
 * find_modifytable_subplan
 *		Helper routine for postgresPlanDirectModify to find the
 *		ModifyTable subplan node that scans the specified RTI.
 *
 * Returns NULL if the subplan couldn't be identified.  That's not a fatal
 * error condition, we just abandon trying to do the update directly.
 */
static ForeignScan *
find_modifytable_subplan(PlannerInfo *root,
						 ModifyTable *plan,
						 Index rtindex,
						 int subplan_index)
{
	Plan	   *subplan = outerPlan(plan);

	/*
	 * The cases we support are (1) the desired ForeignScan is the immediate
	 * child of ModifyTable, or (2) it is the subplan_index'th child of an
	 * Append node that is the immediate child of ModifyTable.  There is no
	 * point in looking further down, as that would mean that local joins are
	 * involved, so we can't do the update directly.
	 *
	 * There could be a Result atop the Append too, acting to compute the
	 * UPDATE targetlist values.  We ignore that here; the tlist will be
	 * checked by our caller.
	 *
	 * In principle we could examine all the children of the Append, but it's
	 * currently unlikely that the core planner would generate such a plan
	 * with the children out-of-order.  Moreover, such a search risks costing
	 * O(N^2) time when there are a lot of children.
	 */
	if (IsA(subplan, Append))
	{
		Append	   *appendplan = (Append *) subplan;

		if (subplan_index < list_length(appendplan->appendplans))
			subplan = (Plan *) list_nth(appendplan->appendplans, subplan_index);
	}
	else if (IsA(subplan, Result) &&
			 outerPlan(subplan) != NULL &&
			 IsA(outerPlan(subplan), Append))
	{
		Append	   *appendplan = (Append *) outerPlan(subplan);

		if (subplan_index < list_length(appendplan->appendplans))
			subplan = (Plan *) list_nth(appendplan->appendplans, subplan_index);
	}

	/* Now, have we got a ForeignScan on the desired rel? */
	if (IsA(subplan, ForeignScan))
	{
		ForeignScan *fscan = (ForeignScan *) subplan;

		if (bms_is_member(rtindex, fscan->fs_relids))
			return fscan;
	}

	return NULL;
}
#endif  // PG_VERSION_NUM >= 140000

/*
 * 	@biref	Scanning data type of target list from PG tables.
 * 	@param	[in/out] Store data type information.
 * 	@param	[in] target list. (Assuming that TargetEntry->Expr are all Vars)
 * 	@note	target list: Column to SELECT
 *
 * 	This function was prepared because we decided that it would be better to
 * 	understand PostgreSQL data types.
 */
[[maybe_unused]] static void 
store_pg_data_type(TgFdwForeignScanState* fsstate, List* tlist, List** retrieved_attrs)
{
	ListCell* lc = NULL;

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	*retrieved_attrs = NIL;

	if (tlist != NULL)
	{
		Oid *data_types = (Oid *) palloc(sizeof(Oid) * tlist->length + 1);

		int i = 0;
		int count = 0;
		foreach (lc, tlist)
		{
			TargetEntry* entry = (TargetEntry*) lfirst(lc);
			Node* node = (Node*) entry->expr;
			count++;

			if (nodeTag(node) == T_Var || nodeTag(node) == T_OpExpr)
			{
				Var* var = (Var*) node;
				data_types[i] = var->vartype;
				elog(DEBUG5, "tsurugi_fdw :  (att_number: %d, nodeTag: %u, vartype: %d)", 
					 i, (unsigned int) nodeTag(node), (int) var->vartype);
			}
			else if (nodeTag(node) == T_Const)
			{
				// When generating placeholders in a SELECT query expression.
				elog(DEBUG5, "Skip the data type placeholders. (index: %d, type: %u)",
					 i, (unsigned int) nodeTag(node));
			}
			else
			{
				elog(ERROR, "Unexpected data type in target list. (index: %d, type: %u)",
					i, (unsigned int) nodeTag(node));
			}
			elog(DEBUG1, "tsurugi_fdw : %s : attr_number: %d", __func__, i);
			*retrieved_attrs = lappend_int(*retrieved_attrs, i + 1);
			i++;
		}
		fsstate->column_types = data_types;
		fsstate->number_of_columns = count;
	}
}


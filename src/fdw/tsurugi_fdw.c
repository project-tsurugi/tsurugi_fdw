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
#include "postgres.h"
#include "tsurugi_fdw.h"

#include "access/table.h"
#include "catalog/pg_type_d.h"
#include "commands/defrem.h"
#include "commands/explain.h"
#include "foreign/fdwapi.h"
#include "miscadmin.h"
#include "nodes/makefuncs.h"
#include "nodes/pathnodes.h"
#include "nodes/pg_list.h"
#if PG_VERSION_NUM >= 120000
#include "optimizer/appendinfo.h"  // get_translated_update_targetlist
#endif							   // PG_VERSION_NUM >= 140000
#include "optimizer/cost.h"
#include "optimizer/inherit.h"
#include "optimizer/optimizer.h"
#include "optimizer/pathnode.h"
#include "optimizer/paths.h"
#include "optimizer/planmain.h"
#include "optimizer/restrictinfo.h"
#include "parser/parsetree.h"
#if PG_VERSION_NUM >= 160000
#include "utils/acl.h"
#endif	// PG_VERSION_NUM >= 160000
#include "connection.h"
#include "tsurugi_api.h"
#include "utils/guc.h"
#include "utils/lsyscache.h"
#include "utils/rel.h"

PG_MODULE_MAGIC;

/* Default CPU cost to start up a foreign query. */
#define DEFAULT_FDW_STARTUP_COST 100.0

/* Default CPU cost to process 1 row (above and beyond cpu_tuple_cost). */
#define DEFAULT_FDW_TUPLE_COST 0.01

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
enum FdwForeignModifyPrivateIndex
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

/*
 * Similarly, this enum describes what's kept in the fdw_private list for
 * a ForeignScan node that modifies a foreign table directly.  We store:
 *
 * 1) UPDATE/DELETE statement text to be sent to the remote server
 * 2) Boolean flag showing if the remote query has a RETURNING clause
 * 3) Integer list of attribute numbers retrieved by RETURNING, if any
 * 4) Boolean flag showing if we set the command es_processed
 */
enum FdwDirectModifyPrivateIndex
{
	/* SQL statement to execute remotely (as a String node) */
	FdwDirectModifyPrivateUpdateSql,
	/* has-returning flag (as an integer Value node) */
	FdwDirectModifyPrivateHasReturning,
	/* Integer list of attribute numbers retrieved by RETURNING */
	FdwDirectModifyPrivateRetrievedAttrs,
	/* set-processed flag (as an integer Value node) */
	FdwDirectModifyPrivateSetProcessed
};

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

/* -------------------------------------------------------------------------
 * Prototype declarations.
 * -------------------------------------------------------------------------
 */
#ifdef __cplusplus
extern "C"
{
#endif

	PG_FUNCTION_INFO_V1(tsurugi_fdw_handler);

/*
 * FDW callback routines (Scan)
 */
#ifndef __TSURUGI_PLANNER__
	static void tsurugiGetForeignRelSize(
			PlannerInfo *root, RelOptInfo *baserel, Oid foreigntableid);
	static void tsurugiGetForeignPaths(
			PlannerInfo *root, RelOptInfo *baserel, Oid foreigntableid);
	static ForeignScan *tsurugiGetForeignPlan(
			PlannerInfo *root,
			RelOptInfo	*foreignrel,
			Oid			 foreigntableid,
			ForeignPath *best_path,
			List		*tlist,
			List		*scan_clauses,
			Plan		*outer_plan);
#endif
	static void tsurugiBeginForeignScan(ForeignScanState *node, int eflags);
	static TupleTableSlot *tsurugiIterateForeignScan(ForeignScanState *node);
	static void			   tsurugiReScanForeignScan(ForeignScanState *node);
	static void			   tsurugiEndForeignScan(ForeignScanState *node);
#ifndef __TSURUGI_PLANNER__
	static void tsurugiGetForeignUpperPaths(
			PlannerInfo		 *root,
			UpperRelationKind stage,
			RelOptInfo		 *input_rel,
			RelOptInfo		 *output_rel,
			void			 *extra);
	static void tsurugiGetForeignJoinPaths(
			PlannerInfo		  *root,
			RelOptInfo		  *joinrel,
			RelOptInfo		  *outerrel,
			RelOptInfo		  *innerrel,
			JoinType		   jointype,
			JoinPathExtraData *extra);
#endif
/*
 * FDW callback routines (Insert/Update/Delete)
 */
#if PG_VERSION_NUM >= 140000
	static void tsurugiAddForeignUpdateTargets(
			PlannerInfo	  *root,
			Index		   rtindex,
			RangeTblEntry *target_rte,
			Relation	   target_relation);
#else
static void tsurugiAddForeignUpdateTargets(
		Query *parsetree, RangeTblEntry *target_rte, Relation target_relation);
#endif	// PG_VERSION_NUM >= 140000
	static List *tsurugiPlanForeignModify(
			PlannerInfo *root,
			ModifyTable *plan,
			Index		 resultRelation,
			int			 subplan_index);
	static bool tsurugiPlanDirectModify(
			PlannerInfo *root,
			ModifyTable *plan,
			Index		 resultRelation,
			int			 subplan_index);
	static void tsurugiBeginDirectModify(ForeignScanState *node, int eflags);
	static TupleTableSlot *tsurugiIterateDirectModify(ForeignScanState *node);
	static void			   tsurugiEndDirectModify(ForeignScanState *node);
	static void			   tsurugiBeginForeignModify(
					   ModifyTableState *mtstate,
					   ResultRelInfo	*rinfo,
					   List				*fdw_private,
					   int				 subplan_index,
					   int				 eflags);
	static TupleTableSlot *tsurugiExecForeignInsert(
			EState		   *estate,
			ResultRelInfo  *resultRelInfo,
			TupleTableSlot *slot,
			TupleTableSlot *planSlot);
	static TupleTableSlot *tsurugiExecForeignUpdate(
			EState		   *estate,
			ResultRelInfo  *resultRelInfo,
			TupleTableSlot *slot,
			TupleTableSlot *planSlot);

	static TupleTableSlot *tsurugiExecForeignDelete(
			EState		   *estate,
			ResultRelInfo  *resultRelInfo,
			TupleTableSlot *slot,
			TupleTableSlot *planSlot);
	static void tsurugiEndForeignModify(EState *estate, ResultRelInfo *rinfo);
#ifndef __TSURUGI_PLANNER__
	static void
	tsurugiBeginForeignInsert(ModifyTableState *mtstate, ResultRelInfo *rinfo);
	static void tsurugiEndForeignInsert(EState *estate, ResultRelInfo *rinfo);
#endif
	/*
	 * FDW callback routines (Others)
	 */
	static void
	tsurugiExplainForeignScan(ForeignScanState *node, ExplainState *es);
	static void
	tsurugiExplainDirectModify(ForeignScanState *node, ExplainState *es);
	static bool tsurugiAnalyzeForeignTable(
			Relation			   relation,
			AcquireSampleRowsFunc *func,
			BlockNumber			  *totalpages);
	static List *
	tsurugiImportForeignSchema(ImportForeignSchemaStmt *stmt, Oid serverOid);
#ifdef __cplusplus
}
#endif

/*
 * Helper functions
 */
extern PGDLLIMPORT PGPROC *MyProc;

#if PG_VERSION_NUM >= 140000
static ForeignScan *find_modifytable_subplan(
		PlannerInfo *root,
		ModifyTable *plan,
		Index		 rtindex,
		int			 subplan_index);
#endif /* PG_VERSION_NUM >= 140000 */

#if 0
static void make_retrieved_attrs(List* telist, List** retrieved_attrs);
#endif
static void
store_pg_data_type(TgFdwForeignScanState *fsstate, List *tlist, List **);
#ifndef __TSURUGI_PLANNER__
#endif

#if PG_VERSION_NUM >= 140000
static int get_batch_size_option(Relation rel);
#endif
static void				tg_execute_direct_modify(ForeignScanState *fsstate);
static TupleTableSlot **tg_execute_foreign_modify(
		EState			*estate,
		ResultRelInfo	*resultRelInfo,
		CmdType			 operation,
		TupleTableSlot **slots,
		TupleTableSlot **planSlots,
		int				*numSlots);

/* -------------------------------------------------------------------------
 * Foreign Data Wrapper handlers.
 * -------------------------------------------------------------------------
 */
/*
 * Foreign-data wrapper handler function: return a struct with pointers
 * to my callback routines.
 */
Datum
tsurugi_fdw_handler(PG_FUNCTION_ARGS)
{
	FdwRoutine *routine = makeNode(FdwRoutine);

	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	/*Functions for scanning foreign tables*/
	routine->GetForeignRelSize	  = tsurugiGetForeignRelSize;
	routine->GetForeignPaths	  = tsurugiGetForeignPaths;
	routine->GetForeignPlan		  = tsurugiGetForeignPlan;
	routine->BeginForeignScan	  = tsurugiBeginForeignScan;
	routine->IterateForeignScan	  = tsurugiIterateForeignScan;
	routine->ReScanForeignScan	  = tsurugiReScanForeignScan;
	routine->EndForeignScan		  = tsurugiEndForeignScan;
	routine->GetForeignUpperPaths = tsurugiGetForeignUpperPaths;
	/* Support functions for join push-down */
	routine->GetForeignJoinPaths = tsurugiGetForeignJoinPaths;

	/*Functions for updating foreign tables*/
	routine->AddForeignUpdateTargets = tsurugiAddForeignUpdateTargets;
	routine->PlanForeignModify		 = tsurugiPlanForeignModify;
	routine->PlanDirectModify		 = tsurugiPlanDirectModify;
	routine->BeginDirectModify		 = tsurugiBeginDirectModify;
	routine->IterateDirectModify	 = tsurugiIterateDirectModify;
	routine->EndDirectModify		 = tsurugiEndDirectModify;

	/*Support functions for EXPLAIN*/
	routine->ExplainForeignScan	 = tsurugiExplainForeignScan;
	routine->ExplainDirectModify = tsurugiExplainDirectModify;
	/*Support functions for ANALYZE*/
	routine->AnalyzeForeignTable = tsurugiAnalyzeForeignTable;

	/*Support functions for IMPORT FOREIGN SCHEMA*/
	routine->ImportForeignSchema = tsurugiImportForeignSchema;
	/*Functions for foreign modify*/
	routine->BeginForeignModify = tsurugiBeginForeignModify;
	routine->ExecForeignInsert	= tsurugiExecForeignInsert;
	routine->ExecForeignUpdate	= tsurugiExecForeignUpdate;
	routine->ExecForeignDelete	= tsurugiExecForeignDelete;
	routine->EndForeignModify	= tsurugiEndForeignModify;
	routine->BeginForeignInsert = tsurugiBeginForeignInsert;
	routine->EndForeignInsert	= tsurugiEndForeignInsert;

	PG_RETURN_POINTER(routine);
}

/* -------------------------------------------------------------------------
 * FDW Scan functions.
 * -------------------------------------------------------------------------
 */
/*
 * tsurugiGetForeignRelSize
 */
static void
tsurugiGetForeignRelSize(
		PlannerInfo *root, RelOptInfo *baserel, Oid foreigntableid)
{
	TgFdwRelationInfo *fpinfo;
	ListCell		  *lc;

	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	/*
	 * We use TgFdwRelationInfo to pass various information to subsequent
	 * functions.
	 */
	fpinfo = (TgFdwRelationInfo *) palloc0(sizeof(TgFdwRelationInfo));
	baserel->fdw_private = (void *) fpinfo;

	/* Base foreign tables need to be pushed down always. */
	fpinfo->pushdown_safe = true;

	/* Look up foreign-table catalog info. */
	fpinfo->table  = GetForeignTable(foreigntableid);
	fpinfo->server = GetForeignServer(fpinfo->table->serverid);

	/*
	 * Extract user-settable option values.  Note that per-table settings of
	 * use_remote_estimate, fetch_size and async_capable override per-server
	 * settings of them, respectively.
	 */
	fpinfo->use_remote_estimate	 = false;
	fpinfo->fdw_startup_cost	 = DEFAULT_FDW_STARTUP_COST;
	fpinfo->fdw_tuple_cost		 = DEFAULT_FDW_TUPLE_COST;
	fpinfo->shippable_extensions = NIL;
	fpinfo->fetch_size			 = 100;
	fpinfo->async_capable		 = false;

	/*
	 * If the table or the server is configured to use remote estimates,
	 * identify which user to do remote access as during planning.  This
	 * should match what ExecCheckPermissions() does.  If we fail due to lack
	 * of permissions, the query would have failed at runtime anyway.
	 */
	if (fpinfo->use_remote_estimate)
	{
#if PG_VERSION_NUM >= 160000
		Oid userid;

		userid = OidIsValid(baserel->userid) ? baserel->userid : GetUserId();
#else
		RangeTblEntry *rte = planner_rt_fetch(baserel->relid, root);
		Oid userid		   = rte->checkAsUser ? rte->checkAsUser : GetUserId();
#endif
		fpinfo->user = GetUserMapping(userid, fpinfo->server->serverid);
	}
	else
		fpinfo->user = NULL;

	/*
	 * Identify which baserestrictinfo clauses can be sent to the remote
	 * server and which can't.
	 */
	classifyConditions(
			root,
			baserel,
			baserel->baserestrictinfo,
			&fpinfo->remote_conds,
			&fpinfo->local_conds);

	/*
	 * Identify which attributes will need to be retrieved from the remote
	 * server.  These include all attrs needed for joins or final output, plus
	 * all attrs used in the local_conds.  (Note: if we end up using a
	 * parameterized scan, it's possible that some of the join clauses will be
	 * sent to the remote and thus we wouldn't really need to retrieve the
	 * columns used in them.  Doesn't seem worth detecting that case though.)
	 */
	fpinfo->attrs_used = NULL;
	pull_varattnos(
			(Node *) baserel->reltarget->exprs,
			baserel->relid,
			&fpinfo->attrs_used);
	foreach (lc, fpinfo->local_conds)
	{
		RestrictInfo *rinfo = lfirst_node(RestrictInfo, lc);

		pull_varattnos(
				(Node *) rinfo->clause, baserel->relid, &fpinfo->attrs_used);
	}

	/*
	 * Compute the selectivity and cost of the local_conds, so we don't have
	 * to do it over again for each path.  The best we can do for these
	 * conditions is to estimate selectivity on the basis of local statistics.
	 */
	fpinfo->local_conds_sel = clauselist_selectivity(
			root, fpinfo->local_conds, baserel->relid, JOIN_INNER, NULL);

	cost_qual_eval(&fpinfo->local_conds_cost, fpinfo->local_conds, root);

	/*
	 * Set # of retrieved rows and cached relation costs to some negative
	 * value, so that we can detect when they are set to some sensible values,
	 * during one (usually the first) of the calls to estimate_path_cost_size.
	 */
	fpinfo->retrieved_rows	 = -1;
	fpinfo->rel_startup_cost = -1;
	fpinfo->rel_total_cost	 = -1;

	/*
	 * If the table or the server is configured to use remote estimates,
	 * connect to the foreign server and execute EXPLAIN to estimate the
	 * number of rows selected by the restriction clauses, as well as the
	 * average row width.  Otherwise, estimate using whatever statistics we
	 * have locally, in a way similar to ordinary tables.
	 */
	if (fpinfo->use_remote_estimate)
	{
		/*
		 * Get cost/size estimates with help of remote server.  Save the
		 * values in fpinfo so we don't need to do it again to generate the
		 * basic foreign path.
		 */
		estimate_path_cost_size(
				root,
				baserel,
				NIL,
				NIL,
				NULL,
				&fpinfo->rows,
				&fpinfo->width,
				&fpinfo->startup_cost,
				&fpinfo->total_cost);

		/* Report estimated baserel size to planner. */
		baserel->rows			  = fpinfo->rows;
		baserel->reltarget->width = fpinfo->width;
	}
	else
	{
		/*
		 * If the foreign table has never been ANALYZEd, it will have
		 * reltuples < 0, meaning "unknown".  We can't do much if we're not
		 * allowed to consult the remote server, but we can use a hack similar
		 * to plancat.c's treatment of empty relations: use a minimum size
		 * estimate of 10 pages, and divide by the column-datatype-based width
		 * estimate to get the corresponding number of tuples.
		 */
#if (PG_VERSION_NUM >= 140000)
		if (baserel->tuples < 0)
#else
		if (baserel->pages == 0 && baserel->tuples == 0)
#endif
		{
			baserel->pages	= 10;
			baserel->tuples = (10 * BLCKSZ) /
							  (baserel->reltarget->width +
							   MAXALIGN(SizeofHeapTupleHeader));
		}

		/* Estimate baserel size as best we can with local statistics. */
		set_baserel_size_estimates(root, baserel);

		/* Fill in basically-bogus cost estimates for use later. */
		estimate_path_cost_size(
				root,
				baserel,
				NIL,
				NIL,
				NULL,
				&fpinfo->rows,
				&fpinfo->width,
				&fpinfo->startup_cost,
				&fpinfo->total_cost);
	}

	/*
	 * fpinfo->relation_name gets the numeric rangetable index of the foreign
	 * table RTE.  (If this query gets EXPLAIN'd, we'll convert that to a
	 * human-readable string at that time.)
	 */
	fpinfo->relation_name = psprintf("%u", baserel->relid);

	/* No outer and inner relations. */
	fpinfo->make_outerrel_subquery = false;
	fpinfo->make_innerrel_subquery = false;
	fpinfo->lower_subquery_rels	   = NULL;
	/* Set the relation index. */
	fpinfo->relation_index = baserel->relid;
}

/*
 * tsurugiGetForeignUpperPaths
 *		Add paths for post-join operations like aggregation, grouping etc. if
 *		corresponding operations are safe to push down.
 */
void
tsurugiGetForeignUpperPaths(
		PlannerInfo		 *root,
		UpperRelationKind stage,
		RelOptInfo		 *input_rel,
		RelOptInfo		 *output_rel,
		void			 *extra)
{
	TgFdwRelationInfo *fpinfo;

	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	/*
	 * If input rel is not safe to pushdown, then simply return as we cannot
	 * perform any post-join operations on the foreign server.
	 */
	if (!input_rel->fdw_private ||
		!((TgFdwRelationInfo *) input_rel->fdw_private)->pushdown_safe)
		return;

	/* Ignore stages we don't support; and skip any duplicate calls. */
	if ((stage != UPPERREL_GROUP_AGG && stage != UPPERREL_ORDERED &&
		 stage != UPPERREL_FINAL) ||
		output_rel->fdw_private)
		return;

	fpinfo = (TgFdwRelationInfo *) palloc0(sizeof(TgFdwRelationInfo));
	fpinfo->pushdown_safe	= false;
	fpinfo->stage			= stage;
	output_rel->fdw_private = fpinfo;

	switch (stage)
	{
	case UPPERREL_GROUP_AGG:
		add_foreign_grouping_paths(
				root, input_rel, output_rel, (GroupPathExtraData *) extra);
		break;
	case UPPERREL_ORDERED:
		add_foreign_ordered_paths(root, input_rel, output_rel);
		break;
	case UPPERREL_FINAL:
		add_foreign_final_paths(
				root, input_rel, output_rel, (FinalPathExtraData *) extra);
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
tsurugiGetForeignPaths(
		PlannerInfo *root, RelOptInfo *baserel, Oid foreigntableid)
{
	TgFdwRelationInfo *fpinfo = (TgFdwRelationInfo *) baserel->fdw_private;
	ForeignPath		  *path;
	List			  *ppi_list;
	ListCell		  *lc;

	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

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
	path = create_foreignscan_path(
			root,
			baserel,
			NULL, /* default pathtarget */
			fpinfo->rows,
			fpinfo->startup_cost,
			fpinfo->total_cost,
			NIL, /* no pathkeys */
			baserel->lateral_relids,
			NULL, /* no extra plan */
#if PG_VERSION_NUM >= 170000
			NIL, /* no fdw_restrictinfo list */
#endif
			NIL); /* no fdw_private list */
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
	foreach (lc, baserel->joininfo)
	{
		RestrictInfo  *rinfo = (RestrictInfo *) lfirst(lc);
		Relids		   required_outer;
		ParamPathInfo *param_info;

		/* Check if clause can be moved to this rel */
		if (!join_clause_is_movable_to(rinfo, baserel))
			continue;

		/* See if it is safe to send to remote */
		if (!is_foreign_expr(root, baserel, rinfo->clause))
			continue;

		/* Calculate required outer rels for the resulting path */
		required_outer =
				bms_union(rinfo->clause_relids, baserel->lateral_relids);
		/* We do not want the foreign rel itself listed in required_outer */
		required_outer = bms_del_member(required_outer, baserel->relid);

		/*
		 * required_outer probably can't be empty here, but if it were, we
		 * couldn't make a parameterized path.
		 */
		if (bms_is_empty(required_outer))
			continue;

		/* Get the ParamPathInfo */
		param_info = get_baserel_parampathinfo(root, baserel, required_outer);
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
			List *clauses;

			/* Make clauses, skipping any that join to lateral_referencers */
			arg.current = NULL;
			clauses		= generate_implied_equalities_for_column(
					root,
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
			foreach (lc, clauses)
			{
				RestrictInfo  *rinfo = (RestrictInfo *) lfirst(lc);
				Relids		   required_outer;
				ParamPathInfo *param_info;

				/* Check if clause can be moved to this rel */
				if (!join_clause_is_movable_to(rinfo, baserel))
					continue;

				/* See if it is safe to send to remote */
				if (!is_foreign_expr(root, baserel, rinfo->clause))
					continue;

				/* Calculate required outer rels for the resulting path */
				required_outer = bms_union(
						rinfo->clause_relids, baserel->lateral_relids);
				required_outer =
						bms_del_member(required_outer, baserel->relid);
				if (bms_is_empty(required_outer))
					continue;

				/* Get the ParamPathInfo */
				param_info = get_baserel_parampathinfo(
						root, baserel, required_outer);
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
	foreach (lc, ppi_list)
	{
		ParamPathInfo *param_info = (ParamPathInfo *) lfirst(lc);
		double		   rows		  = 0;
		int			   width;
		Cost		   startup_cost = 0;
		Cost		   total_cost	= 0;

		/* Get a cost estimate from the remote */
		estimate_path_cost_size(
				root,
				baserel,
				param_info->ppi_clauses,
				NIL,
				NULL,
				&rows,
				&width,
				&startup_cost,
				&total_cost);

		/*
		 * ppi_rows currently won't get looked at by anything, but still we
		 * may as well ensure that it matches our idea of the rowcount.
		 */
		param_info->ppi_rows = rows;

		/* Make the path */
		path = create_foreignscan_path(
				root,
				baserel,
				NULL, /* default pathtarget */
				rows,
				startup_cost,
				total_cost,
				NIL, /* no pathkeys */
				param_info->ppi_req_outer,
				NULL,
#if PG_VERSION_NUM >= 170000
				NIL, /* no fdw_restrictinfo list */
#endif
				NIL); /* no fdw_private list */
		add_path(baserel, (Path *) path);
	}
}

/*
 * tsurugiGetForeignPlan
 *		Create ForeignScan plan node which implements selected best path.
 */
static ForeignScan *
tsurugiGetForeignPlan(
		PlannerInfo *root,
		RelOptInfo	*foreignrel,
		Oid			 foreigntableid,
		ForeignPath *best_path,
		List		*tlist,
		List		*scan_clauses,
		Plan		*outer_plan)
{
	TgFdwRelationInfo *fpinfo = (TgFdwRelationInfo *) foreignrel->fdw_private;
	Index			   scan_relid;
	List			  *fdw_private;
	List			  *remote_exprs		 = NIL;
	List			  *local_exprs		 = NIL;
	List			  *params_list		 = NIL;
	List			  *fdw_scan_tlist	 = NIL;
	List			  *fdw_recheck_quals = NIL;
	List			  *retrieved_attrs;
	StringInfoData	   sql;
	bool			   has_final_sort = false;
	bool			   has_limit	  = false;
	ListCell		  *lc;

	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	/*
	 * Get FDW private data created by postgresGetForeignUpperPaths(), if any.
	 */
	if (best_path->fdw_private)
	{
		has_final_sort = intVal(
				list_nth(best_path->fdw_private, FdwPathPrivateHasFinalSort));
		has_limit = intVal(
				list_nth(best_path->fdw_private, FdwPathPrivateHasLimit));
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
		foreach (lc, scan_clauses)
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
		local_exprs	 = extract_actual_clauses(fpinfo->local_conds, false);

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
			foreach (lc, local_exprs)
			{
				Node *qual = (Node *) lfirst(lc);

				outer_plan->qual = list_delete(outer_plan->qual, qual);

				/*
				 * For an inner join the local conditions of foreign scan plan
				 * can be part of the joinquals as well.  (They might also be
				 * in the mergequals or hashquals, but we can't touch those
				 * without breaking the plan.)
				 */
				if (IsA(outer_plan, NestLoop) || IsA(outer_plan, MergeJoin) ||
					IsA(outer_plan, HashJoin))
				{
					Join *join_plan = (Join *) outer_plan;

					if (join_plan->jointype == JOIN_INNER)
						join_plan->joinqual =
								list_delete(join_plan->joinqual, qual);
				}
			}

			/*
			 * Now fix the subplan's tlist --- this might result in inserting
			 * a Result node atop the plan tree.
			 */
			outer_plan = change_plan_targetlist(
					outer_plan, fdw_scan_tlist, best_path->path.parallel_safe);
		}
	}

	/*
	 * Build the query string to be sent for execution, and identify
	 * expressions to be sent as parameters.
	 */
	initStringInfo(&sql);
	deparseSelectStmtForRel(
			&sql,
			root,
			foreignrel,
			fdw_scan_tlist,
			remote_exprs,
			best_path->path.pathkeys,
			has_final_sort,
			has_limit,
			false,
			&retrieved_attrs,
			&params_list);

	elog(DEBUG1, "tsurugi_fdw: \ndeparsed sql:\n%s", sql.data);

	/* Remember remote_exprs for possible use by tsurugiPlanDirectModify */
	fpinfo->final_remote_exprs = remote_exprs;

	/*
	 * Build the fdw_private list that will be available to the executor.
	 * Items in the list must match order in enum FdwScanPrivateIndex.
	 */
	fdw_private = list_make3(
			makeString(sql.data),
			retrieved_attrs,
			makeInteger(fpinfo->fetch_size));
	if (IS_JOIN_REL(foreignrel) || IS_UPPER_REL(foreignrel))
		fdw_private = lappend(fdw_private, makeString(fpinfo->relation_name));

	/*
	 * Create the ForeignScan node for the given relation.
	 *
	 * Note that the remote parameter expressions are stored in the fdw_exprs
	 * field of the finished plan node; we can't keep them in private state
	 * because then they wouldn't be subject to later planner processing.
	 */
	return make_foreignscan(
			tlist,
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
tsurugiGetForeignJoinPaths(
		PlannerInfo		  *root,
		RelOptInfo		  *joinrel,
		RelOptInfo		  *outerrel,
		RelOptInfo		  *innerrel,
		JoinType		   jointype,
		JoinPathExtraData *extra)
{
	TgFdwRelationInfo *fpinfo;
	ForeignPath		  *joinpath;
	double			   rows;
	int				   width;
	Cost			   startup_cost;
	Cost			   total_cost;
	Path			  *epq_path; /* Path to create plan to be executed when
								  * EvalPlanQual gets triggered. */

	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	/*
	 * Currently we don't push-down joins in query for UPDATE/DELETE.
	 * This would require a path for EvalPlanQual.
	 * This restriction might be relaxed in a later release.
	 */
	if (root->parse->commandType != CMD_SELECT)
	{
		elog(DEBUG2,
			 "tsurugi_fdw: don't push down join because it is no SELECT");
		return;
	}

	if (root->rowMarks)
	{
		elog(DEBUG2, "tsurugi_fdw: don't push down join with FOR UPDATE");
		return;
	}

	/*
	 * N-way join is not supported, due to the column definition
	 * infrastracture. If we can track relid mapping of join relations, we can
	 * support N-way join.
	 */
	if (!IS_SIMPLE_REL(outerrel) || !IS_SIMPLE_REL(innerrel))
		return;

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
	fpinfo->pushdown_safe = true;
	joinrel->fdw_private  = fpinfo;
	/* attrs_used is only for base relations. */
	fpinfo->attrs_used = NULL;

	/*
	 * If there is a possibility that EvalPlanQual will be executed, we need
	 * to be able to reconstruct the row using scans of the base relations.
	 * GetExistingLocalJoinPath will find a suitable path for this purpose in
	 * the path list of the joinrel, if one exists.  We must be careful to
	 * call it before adding any ForeignPath, since the ForeignPath might
	 * dominate the only suitable local path available.  We also do it before
	 * calling tsurugi_foreign_join_ok(), since that function updates fpinfo
	 * and marks it as pushable if the join is found to be pushable.
	 */
	if (root->parse->commandType == CMD_DELETE ||
		root->parse->commandType == CMD_UPDATE || root->rowMarks)
	{
		epq_path = GetExistingLocalJoinPath(joinrel);
		if (!epq_path)
		{
			elog(DEBUG3,
				 "could not push down foreign join because a local path "
				 "suitable for EPQ checks was not found");
			return;
		}
	}
	else
		epq_path = NULL;

	if (!tsurugi_foreign_join_ok(
				root, joinrel, jointype, outerrel, innerrel, extra))
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
	fpinfo->local_conds_sel = clauselist_selectivity(
			root, fpinfo->local_conds, 0, JOIN_INNER, NULL);
	cost_qual_eval(&fpinfo->local_conds_cost, fpinfo->local_conds, root);

	/*
	 * If we are going to estimate costs locally, estimate the join clause
	 * selectivity here while we have special join info.
	 */
	if (!fpinfo->use_remote_estimate)
		fpinfo->joinclause_sel = clauselist_selectivity(
				root, fpinfo->joinclauses, 0, fpinfo->jointype, extra->sjinfo);

	/* Estimate costs for bare join relation */
	estimate_path_cost_size(
			root,
			joinrel,
			NIL,
			NIL,
			NULL,
			&rows,
			&width,
			&startup_cost,
			&total_cost);
	/* Now update this information in the joinrel */
	joinrel->rows			  = rows;
	joinrel->reltarget->width = width;
	fpinfo->rows			  = rows;
	fpinfo->width			  = width;
	fpinfo->startup_cost	  = startup_cost;
	fpinfo->total_cost		  = total_cost;

	/*
	 * Create a new join path and add it to the joinrel which represents a
	 * join between foreign tables.
	 */
	joinpath = create_foreign_join_path(
			root,
			joinrel,
			NULL, /* default pathtarget */
			rows,
			startup_cost,
			total_cost,
			NIL, /* no pathkeys */
			joinrel->lateral_relids,
			epq_path,
#if PG_VERSION_NUM >= 170000
			extra->restrictlist,
#endif
			NIL); /* no fdw_private */

	/* Add generated path into joinrel by add_path(). */
	add_path(joinrel, (Path *) joinpath);

	/* Consider pathkeys for the join relation */
	add_paths_with_pathkeys_for_rel(root, joinrel, epq_path);

	/* XXX Consider parameterized paths for the join relation */
}

/**
 *  @brief  Preparation for scanning foreign table.
 */
static void
tsurugiBeginForeignScan(ForeignScanState *node, int eflags)
{
	ForeignScan			  *fsplan = (ForeignScan *) node->ss.ps.plan;
	TgFdwForeignScanState *fsstate;
	RangeTblEntry		  *rte;
	ForeignTable		  *table;
	ForeignServer		  *server;
	UserMapping			  *user;
	int					   rtindex;
	EState				  *estate = node->ss.ps.state;

	Assert(node != nullptr);

	elog(DEBUG1,
		 "tsurugi_fdw: %s\nquery:\n%s",
		 __func__,
		 estate->es_sourceText);

	/*
	 * Do nothing in EXPLAIN (no ANALYZE) case.  node->fdw_state stays NULL.
	 */
	if (eflags & EXEC_FLAG_EXPLAIN_ONLY)
		return;

	/*
	 * We'll save private state in node->fdw_state.
	 */
	fsstate = (TgFdwForeignScanState *) palloc0(sizeof(TgFdwForeignScanState));
	node->fdw_state			   = (void *) fsstate;
	fsstate->rowidx			   = 0;
	fsstate->number_of_columns = 0;
	fsstate->query_string	   = strVal(
			 list_nth(fsplan->fdw_private, FdwScanPrivateSelectSql));
	fsstate->retrieved_attrs = (List *)
			list_nth(fsplan->fdw_private, FdwScanPrivateRetrievedAttrs);
	fsstate->cursor_exists = false;
	fsstate->param_linfo   = estate->es_param_list_info;

	if (fsplan->scan.scanrelid > 0)
		rtindex = fsplan->scan.scanrelid;
	else
		rtindex = bms_next_member(fsplan->fs_relids, -1);

	/*
	 * Get info we'll need for converting data fetched from the foreign server
	 * into local representation and error reporting during that process.
	 */
	if (fsplan->scan.scanrelid > 0)
	{
		fsstate->rel	 = node->ss.ss_currentRelation;
		fsstate->tupdesc = RelationGetDescr(fsstate->rel);
	}
	else
	{
		fsstate->rel	 = ExecOpenScanRelation(estate, rtindex, eflags);
		fsstate->tupdesc = node->ss.ss_ScanTupleSlot->tts_tupleDescriptor;
	}
	fsstate->attinmeta = TupleDescGetAttInMetadata(fsstate->tupdesc);

	fsstate->numParams = list_length(fsplan->fdw_exprs);
	fsstate->param_exprs =
			ExecInitExprList(fsplan->fdw_exprs, (PlanState *) node);

	/* Get the server object from the ForeignTable associated with the
	 * relation. */
	rte				 = exec_rt_fetch(rtindex, estate);
	table			 = GetForeignTable(rte->relid);
	server			 = GetForeignServer(table->serverid);
	user			 = GetUserMapping(GetUserId(), table->serverid);
	fsstate->tg_conn = tg_get_connection(server, user);
}

/*
 * tsurugiIterateForeignScan
 *      Scanning row data from foreign tables.
 */
static TupleTableSlot *
tsurugiIterateForeignScan(ForeignScanState *node)
{
	TgFdwForeignScanState *fsstate = (TgFdwForeignScanState *) node->fdw_state;
	TupleTableSlot		  *tupleSlot = node->ss.ss_ScanTupleSlot;
	TG_STATUS			   tg_status;
	ExprContext			  *econtext = node->ss.ps.ps_ExprContext;
	ForeignScan			  *fsplan	= (ForeignScan *) node->ss.ps.plan;

	elog(DEBUG3,
		 "tsurugi_fdw: %s\nquery:\n%s",
		 __func__,
		 fsstate->query_string);

	if (!fsstate->cursor_exists)
	{
		fsstate->tg_stmt =
				tg_stmt_prepare(fsstate->tg_conn, fsstate->query_string);
		if (!fsstate->tg_stmt)
			elog(ERROR, "%s", tg_global_error_message());

		tg_status = tg_stmt_bind_params_for_query(
				fsstate->tg_stmt,
				fsplan->fdw_exprs,
				econtext,
				fsstate->param_exprs);
		if (tg_status != TG_STATUS_OK)
			elog(ERROR, "%s", tg_stmt_error_message(fsstate->tg_stmt));

		fsstate->tg_result = tg_stmt_execute_query(fsstate->tg_stmt);
		if (!fsstate->tg_result)
			elog(ERROR, "%s", tg_stmt_error_message(fsstate->tg_stmt));
		fsstate->num_tuples	   = 0;
		fsstate->cursor_exists = true;
	}
	ExecClearTuple(tupleSlot);

	tg_status = tg_result_next(fsstate->tg_result);
	if (tg_status == TG_STATUS_OK)
	{
		tg_status = tg_result_get_tuple(
				fsstate->tg_result, fsstate->retrieved_attrs, tupleSlot);
		if (tg_status != TG_STATUS_OK)
		{
			tg_result_destroy(fsstate->tg_result);
			elog(ERROR, "%s", tg_result_error_message(fsstate->tg_result));
		}
		fsstate->num_tuples++;
	}
	else if (tg_status == TG_STATUS_END_OF_ROW)
	{
		/* No more rows/data exists */
		tg_result_destroy(fsstate->tg_result);
		elog(DEBUG1,
			 "tsurugi_fdw: End of rows. (rows: %d)",
			 (int) fsstate->num_tuples);
	}
	else
	{
		tg_result_destroy(fsstate->tg_result);
		tg_stmt_destroy(fsstate->tg_stmt);
		elog(ERROR, "%s", tg_stmt_error_message(fsstate->tg_stmt));
	}

	elog(DEBUG5, "tsurugi_fdw: %s is done.", __func__);

	return tupleSlot;
}

/*
 *	tsurugiReScanForeignScan
 */
static void
tsurugiReScanForeignScan(ForeignScanState *node)
{
	TgFdwForeignScanState *fsstate = (TgFdwForeignScanState *) node->fdw_state;

	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	/* If we haven't created the cursor yet, nothing to do. */
	if (!fsstate->cursor_exists)
		return;

	fsstate->cursor_exists = false;
	fsstate->rowidx		   = 0;
	fsstate->num_tuples	   = 0;
}

/*
 *	tsurugiEndForeignScan
 *      Clean up for scanning foreign tables.
 */
static void
tsurugiEndForeignScan(ForeignScanState *node)
{
	TgFdwForeignScanState *fsstate = (TgFdwForeignScanState *) node->fdw_state;
	elog(DEBUG1, "tsurugi_fdw: %s", __func__);
	tg_stmt_destroy(fsstate->tg_stmt);
}

/* -------------------------------------------------------------------------
 * FDW Modify functions.
 * -------------------------------------------------------------------------
 */
/*
 * tsurugiAddForeignUpdateTargets
 *
 */
static void
tsurugiAddForeignUpdateTargets(
#if PG_VERSION_NUM >= 140000
		PlannerInfo *root,
		Index		 rtindex,
#else
		Query *parsetree,
#endif
		RangeTblEntry *target_rte,
		Relation	   target_relation)
{
	Oid		  relid	  = RelationGetRelid(target_relation);
	TupleDesc tupdesc = target_relation->rd_att;

	for (int i = 0; i < tupdesc->natts; i++)
	{
		Form_pg_attribute att	 = TupleDescAttr(tupdesc, i);
		AttrNumber		  attrno = att->attnum;
		List			 *options;
		ListCell		 *lc;

		if (att->attisdropped)
			continue;

		options = GetForeignColumnOptions(relid, attrno);

		foreach (lc, options)
		{
			DefElem *def = (DefElem *) lfirst(lc);

			if (strcmp(def->defname, "key") == 0 && defGetBoolean(def))
			{
				Var *var;

#if PG_VERSION_NUM < 140000
				Index		 rtindex = parsetree->resultRelation;
				TargetEntry *tle;
#endif
				var =
						makeVar(rtindex,
								attrno,
								att->atttypid,
								att->atttypmod,
								att->attcollation,
								0);

#if PG_VERSION_NUM >= 140000
				// PG14以降：行識別用として登録
				add_row_identity_var(
						root, var, rtindex, pstrdup(NameStr(att->attname)));
#else
				// PG13以前：targetList に “隠し列(resjunk)” として追加
				tle = makeTargetEntry(
						(Expr *) var,
						list_length(parsetree->targetList) + 1,
						pstrdup(NameStr(att->attname)),
						true /* resjunk */);
				parsetree->targetList = lappend(parsetree->targetList, tle);
#endif
			}
			else if (strcmp(def->defname, "key") == 0)
			{
				elog(ERROR, "impossible column option \"%s\"", def->defname);
			}
		}
	}
}

/* -------------------------------------------------------------------------
 * Direct Modify functions.
 * -------------------------------------------------------------------------
 */
/*
 * tsurugiPlanDirectModify
 *		Consider a direct foreign table modification
 *
 * Decide whether it is safe to modify a foreign table directly, and if so,
 * rewrite subplan accordingly.
 */
static bool
tsurugiPlanDirectModify(
		PlannerInfo *root,
		ModifyTable *plan,
		Index		 resultRelation,
		int			 subplan_index)
{
	CmdType operation = plan->operation;
#if PG_VERSION_NUM < 140000
	Plan *subplan;
#endif	// PG_VERSION_NUM < 140000
	RelOptInfo		  *foreignrel;
	RangeTblEntry	  *rte;
	TgFdwRelationInfo *fpinfo;
	Relation		   rel;
	StringInfoData	   sql;
	ForeignScan		  *fscan;
#if PG_VERSION_NUM >= 140000
	List *processed_tlist = NIL;
#endif	// PG_VERSION_NUM >= 140000
	List			  *targetAttrs	   = NIL;
	List			  *remote_exprs	   = NIL;
	List			  *params_list	   = NIL;
	List			  *returningList   = NIL;
	List			  *retrieved_attrs = NIL;
	static const char *operations[] =
			{"", "SELECT", "UPDATE", "INSERT", "DELETE", "UTILITY"};

	/* operation - 1:SELECT, 2:UPDATE, 3:INSERT, 4:DELETE, 5:UTILITY */
	elog(DEBUG3,
		 "tsurugi_fdw: %s (operation= %s(%d))",
		 __func__,
		 operations[operation],
		 (int) operation);

	/*
	 * Decide whether it is safe to modify a foreign table directly.
	 */

	/*
	 * The table modification must be an UPDATE or DELETE.
	 */
	if (operation != CMD_UPDATE && operation != CMD_DELETE)
		return false;

#if PG_VERSION_NUM >= 140000
	/*
	 * Try to locate the ForeignScan subplan that's scanning resultRelation.
	 */
	fscan = find_modifytable_subplan(
			root, plan, resultRelation, subplan_index);
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
#endif	// PG_VERSION_NUM >= 140000

	/*
	 * It's unsafe to modify a foreign table directly if there are any quals
	 * that should be evaluated locally.
	 */
#if PG_VERSION_NUM >= 140000
	if (fscan->scan.plan.qual != NIL)
#else
	if (subplan->qual != NIL)
#endif	// PG_VERSION_NUM >= 140000
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
	rte	   = root->simple_rte_array[resultRelation];
	fpinfo = (TgFdwRelationInfo *) foreignrel->fdw_private;

	/*
	 * It's unsafe to update a foreign table directly, if any expressions to
	 * assign to the target columns are unsafe to evaluate remotely.
	 */
	if (operation == CMD_UPDATE)
	{
#if PG_VERSION_NUM >= 140000
		ListCell *lc, *lc2;

		/*
		 * The expressions of concern are the first N columns of the processed
		 * targetlist, where N is the length of the rel's update_colnos.
		 */
		get_translated_update_targetlist(
				root, resultRelation, &processed_tlist, &targetAttrs);
		forboth (lc, processed_tlist, lc2, targetAttrs)
		{
			TargetEntry *tle   = lfirst_node(TargetEntry, lc);
			AttrNumber	 attno = lfirst_int(lc2);

			/* update's new-value expressions shouldn't be resjunk */
			Assert(!tle->resjunk);

			if (attno <= InvalidAttrNumber) /* shouldn't happen */
				elog(ERROR, "system-column update is not supported");

			if (!is_foreign_expr(root, foreignrel, (Expr *) tle->expr))
				return false;
		}
#else
		int col;

		/*
		 * We transmit only columns that were explicitly targets of the
		 * UPDATE, so as to avoid unnecessary data transmission.
		 */
		col = -1;
		while ((col = bms_next_member(rte->updatedCols, col)) >= 0)
		{
			/* bit numbers are offset by FirstLowInvalidHeapAttributeNumber */
			AttrNumber	 attno = col + FirstLowInvalidHeapAttributeNumber;
			TargetEntry *tle;

			if (attno <= InvalidAttrNumber) /* shouldn't happen */
				elog(ERROR, "system-column update is not supported");

			tle = get_tle_by_resno(subplan->targetlist, attno);

			if (!tle)
				elog(ERROR,
					 "attribute number %d not found in subplan targetlist",
					 attno);

			if (!is_foreign_expr(root, foreignrel, (Expr *) tle->expr))
				return false;

			targetAttrs = lappend_int(targetAttrs, attno);
		}
#endif	// PG_VERSION_NUM >= 140000
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
			returningList =
					build_remote_returning(resultRelation, rel, returningList);
	}

	/*
	 * Construct the SQL command string.
	 */
	switch (operation)
	{
	case CMD_UPDATE:
		deparseDirectUpdateSql(
				&sql,
				root,
				resultRelation,
				rel,
				foreignrel,
#if PG_VERSION_NUM >= 140000
				processed_tlist,
#else
				((Plan *) fscan)->targetlist,
#endif	// PG_VERSION_NUM >= 140000
				targetAttrs,
				remote_exprs,
				&params_list,
				returningList,
				&retrieved_attrs);
		break;
	case CMD_DELETE:
		deparseDirectDeleteSql(
				&sql,
				root,
				resultRelation,
				rel,
				foreignrel,
				remote_exprs,
				&params_list,
				returningList,
				&retrieved_attrs);
		break;
	default:
		elog(ERROR,
			 "Unexpected operation in %s: %d",
			 __func__,
			 (int) operation);
		break;
	}
	elog(DEBUG1, "tsurugi_fdw: \ndeparsed sql:\n%s", sql.data);

	/*
	 * Update the operation info.
	 */
	fscan->operation = operation;
#if PG_VERSION_NUM >= 140000
	fscan->resultRelation = resultRelation;
#endif	// PG_VERSION_NUM >= 140000

	/*
	 * Update the fdw_exprs list that will be available to the executor.
	 */
	fscan->fdw_exprs = params_list;

	/*
	 * Update the fdw_private list that will be available to the executor.
	 * Items in the list must match enum FdwDirectModifyPrivateIndex, above.
	 */
	fscan->fdw_private = list_make4(
			makeString(sql.data),
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
#endif	// PG_VERSION_NUM >= 140000

	table_close(rel, NoLock);
	elog(DEBUG1, "tsurugi_fdw: execute direct modify.");

	return true;
}

/*
 * tsurugiBeginDirectModify
 *      Preparation for modifying foreign tables.
 */
static void
tsurugiBeginDirectModify(ForeignScanState *node, int eflags)
{
	RangeTblEntry		   *rte;
	ForeignTable		   *table;
	ForeignServer		   *server;
	UserMapping			   *user;
	ForeignScan			   *fsplan = (ForeignScan *) node->ss.ps.plan;
	int						rtindex;
	EState				   *estate = node->ss.ps.state;
	TgFdwDirectModifyState *dmstate;

	Assert(node != NULL);
	Assert(fsplan != NULL);

	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	/* Initialize state variable */
	dmstate = (TgFdwDirectModifyState *) palloc0(
			sizeof(TgFdwDirectModifyState));
	dmstate->num_tuples = -1; /* -1 means not set yet */
	dmstate->orig_query = estate->es_sourceText;
	dmstate->query		= strVal(
			 list_nth(fsplan->fdw_private, FdwDirectModifyPrivateUpdateSql));
	dmstate->has_returning = intVal(
			list_nth(fsplan->fdw_private, FdwDirectModifyPrivateHasReturning));
	dmstate->retrieved_attrs = (List *) list_nth(
			fsplan->fdw_private, FdwDirectModifyPrivateRetrievedAttrs);
	dmstate->set_processed = intVal(
			list_nth(fsplan->fdw_private, FdwDirectModifyPrivateSetProcessed));
	dmstate->param_types = NULL;
	dmstate->prep_name	 = NULL;
	dmstate->param_linfo = estate->es_param_list_info;
	node->fdw_state		 = dmstate;

	if (fsplan->scan.scanrelid > 0)
		rtindex = fsplan->scan.scanrelid;
	else
		rtindex = bms_next_member(fsplan->fs_relids, -1);

	if (fsplan->scan.scanrelid == 0)
		dmstate->rel = ExecOpenScanRelation(estate, rtindex, eflags);
	else
		dmstate->rel = node->ss.ss_currentRelation;

	/* Get the server object from the ForeignTable associated with the
	 * relation. */
	rte				 = exec_rt_fetch(rtindex, estate);
	table			 = GetForeignTable(rte->relid);
	server			 = GetForeignServer(table->serverid);
	dmstate->server	 = server;
	user			 = GetUserMapping(GetUserId(), server->serverid);
	dmstate->tg_conn = tg_get_connection(server, user);
}

/*
 * tsurugiIterateDirectModify
 *      Execute Insert/Upate/Delete command to foreign tables.
 */
static TupleTableSlot *
tsurugiIterateDirectModify(ForeignScanState *node)
{
	TgFdwDirectModifyState *dmstate = (TgFdwDirectModifyState *)
											  node->fdw_state;
	EState		   *estate = node->ss.ps.state;
	TupleTableSlot *slot   = node->ss.ss_ScanTupleSlot;
	dmstate->set_processed = true;

	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	if (dmstate->num_tuples == (size_t) -1)
		tg_execute_direct_modify(node);

	/* Increment the command es_processed count if necessary. */
	if (dmstate->set_processed)
		estate->es_processed += dmstate->num_tuples;

	return ExecClearTuple(slot);
}

/*
 * tsurugiEndDirectModify
 *      Clean up for modifying foreign tables.
 */
static void
tsurugiEndDirectModify(ForeignScanState *node)
{
	TgFdwDirectModifyState *dmstate = (TgFdwDirectModifyState *)
											  node->fdw_state;
	elog(DEBUG1, "tsurugi_fdw: %s", __func__);
	tg_stmt_destroy(dmstate->tg_stmt);
}

/* -------------------------------------------------------------------------
 * Foreign Modify functions.
 * -------------------------------------------------------------------------
 */
/*
 * tsurugiPlanForeignModify
 */
static List *
tsurugiPlanForeignModify(
		PlannerInfo *root,
		ModifyTable *plan,
		Index		 resultRelation,
		int			 subplan_index)
{
	CmdType		   operation = plan->operation;
	RangeTblEntry *rte		 = planner_rt_fetch(resultRelation, root);
	Relation	   rel;
	StringInfoData sql;
	List		  *targetAttrs		   = NIL;
	List		  *withCheckOptionList = NIL;
	List		  *returningList	   = NIL;
	List		  *retrieved_attrs	   = NIL;
	bool		   doNothing		   = false;
	int			   values_end_len	   = -1;

	elog(DEBUG1, "tsurugi_fdw: %s : operation: %d", __func__, operation);

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
	if (operation == CMD_INSERT || (operation == CMD_UPDATE && rel->trigdesc &&
									rel->trigdesc->trig_update_before_row))
	{
		TupleDesc tupdesc = RelationGetDescr(rel);
		int		  attnum;

		for (attnum = 1; attnum <= tupdesc->natts; attnum++)
		{
			Form_pg_attribute attr = TupleDescAttr(tupdesc, attnum - 1);
			if (!attr->attisdropped)
				targetAttrs = lappend_int(targetAttrs, attnum);
		}
	}
	else if (operation == CMD_UPDATE)
	{
		int col;
#if PG_VERSION_NUM >= 160000
		RelOptInfo *rel			   = find_base_rel(root, resultRelation);
		Bitmapset  *allUpdatedCols = get_rel_all_updated_cols(root, rel);

		col = -1;
		while ((col = bms_next_member(allUpdatedCols, col)) >= 0)
		{
			/* bit numbers are offset by FirstLowInvalidHeapAttributeNumber */
			AttrNumber attno = col + FirstLowInvalidHeapAttributeNumber;

			if (attno <= InvalidAttrNumber) /* shouldn't happen */
				elog(ERROR, "system-column update is not supported");
			targetAttrs = lappend_int(targetAttrs, attno);
		}
#else
		Bitmapset *allUpdatedCols =
				bms_union(rte->updatedCols, rte->extraUpdatedCols);

		col = -1;
		while ((col = bms_next_member(allUpdatedCols, col)) >= 0)
		{
			/* bit numbers are offset by FirstLowInvalidHeapAttributeNumber */
			AttrNumber attno = col + FirstLowInvalidHeapAttributeNumber;

			if (attno <= InvalidAttrNumber) /* shouldn't happen */
				elog(ERROR, "system-column update is not supported");
			targetAttrs = lappend_int(targetAttrs, attno);
		}
#endif
	}

	/*
	 * Extract the relevant WITH CHECK OPTION list if any.
	 */
	if (plan->withCheckOptionLists)
		withCheckOptionList = (List *)
				list_nth(plan->withCheckOptionLists, subplan_index);

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
		elog(ERROR,
			 "unexpected ON CONFLICT specification: %d",
			 (int) plan->onConflictAction);

	/*
	 * Construct the SQL command string.
	 */
	switch (operation)
	{
	case CMD_INSERT:
		deparseInsertSql(
				&sql,
				rte,
				resultRelation,
				rel,
				targetAttrs,
				doNothing,
				withCheckOptionList,
				returningList,
				&retrieved_attrs,
				&values_end_len);
		break;
	case CMD_UPDATE:
		deparseUpdateSql(&sql, rte, resultRelation, rel, targetAttrs);
		break;
	case CMD_DELETE:
		deparseDeleteSql(
				&sql, rte, resultRelation, rel, NIL, &retrieved_attrs);
		break;
	default:
		elog(ERROR, "unexpected operation: %d", (int) operation);
		break;
	}

	elog(DEBUG1, "tsurugi_fdw: %s : \ndeparsed sql:\n%s", __func__, sql.data);

	table_close(rel, NoLock);

	/*
	 * Build the fdw_private list that will be available to the executor.
	 * Items in the list must match enum FdwForeignModifyPrivateIndex, above.
	 */
#if PG_VERSION_NUM >= 140000
	return list_make5(
			makeString(sql.data),
			targetAttrs,
			makeInteger(values_end_len),
			makeInteger((retrieved_attrs != NIL)),
			retrieved_attrs);
#elif PG_VERSION_NUM >= 130000
	return list_make4(
			makeString(sql.data),
			targetAttrs,
			makeInteger(values_end_len),
			makeInteger((retrieved_attrs != NIL)));
#else
	return list_make3(
			makeString(sql.data), targetAttrs, makeInteger(values_end_len));
#endif
}

/*
 * tsurugiBeginForeignModify
 */
static void
tsurugiBeginForeignModify(
		ModifyTableState *mtstate,
		ResultRelInfo	 *resultRelInfo,
		List			 *fdw_private,
		int				  subplan_index,
		int				  eflags)
{
	TgFdwForeignModifyState *fmstate;
	EState					*estate	   = mtstate->ps.state;
	Relation				 rel	   = resultRelInfo->ri_RelationDesc;
	AttrNumber				 n_params  = 0;
	Oid						 typefnoid = InvalidOid;
	bool					 isvarlena = false;
	ListCell				*lc		   = NULL;
	RangeTblEntry			*rte;
	ForeignTable			*table;
	ForeignServer			*server;
	UserMapping				*user;
	Oid						 foreignTableId;
	Plan					*subplan;

	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	foreignTableId = RelationGetRelid(rel);
#if (PG_VERSION_NUM >= 140000)
	subplan = outerPlanState(mtstate)->plan;
#else
	subplan = mtstate->mt_plans[subplan_index]->plan;
#endif

	/*
	 * Do nothing in EXPLAIN (no ANALYZE) case.  resultRelInfo->ri_FdwState
	 * stays NULL.
	 */
	if (eflags & EXEC_FLAG_EXPLAIN_ONLY)
		return;

	fmstate = (TgFdwForeignModifyState *) palloc0(
			sizeof(TgFdwForeignModifyState));

	/* Deconstruct fdw_private data. */
	fmstate->query = strVal(list_nth(fdw_private, FdwModifyPrivateUpdateSql));
	fmstate->target_attrs = (List *)
			list_nth(fdw_private, FdwModifyPrivateTargetAttnums);
	fmstate->values_end = intVal(list_nth(fdw_private, FdwModifyPrivateLen));
#if PG_VERSION_NUM >= 130000
	fmstate->has_returning = intVal(
			list_nth(fdw_private, FdwModifyPrivateHasReturning));
#endif
#if PG_VERSION_NUM >= 140000
	fmstate->retrieved_attrs = (List *)
			list_nth(fdw_private, FdwModifyPrivateRetrievedAttrs);
#endif
	/* Begin constructing TgFdwForeignModifyState. */
	fmstate->rel		 = rel;
	fmstate->orig_query	 = pstrdup(fmstate->query);
	fmstate->is_prepared = false;
	fmstate->p_nums		 = 0;
	/* Prepare for output conversion of parameters used in prepared stmt. */
	n_params		  = list_length(fmstate->target_attrs) + 1;
	fmstate->p_flinfo = (FmgrInfo *) palloc0(sizeof(FmgrInfo) * n_params);
	fmstate->p_nums	  = 0;
	/* Create context for per-tuple temp workspace. */
	fmstate->temp_cxt = AllocSetContextCreate(
			estate->es_query_cxt,
			"tsurugi_fdw temporary data",
			ALLOCSET_SMALL_SIZES);

	if (mtstate->operation == CMD_UPDATE || mtstate->operation == CMD_DELETE)
	{
		/* First transmittable parameter will be ctid */
		getTypeOutputInfo(TIDOID, &typefnoid, &isvarlena);
		fmgr_info(typefnoid, &fmstate->p_flinfo[fmstate->p_nums]);
		fmstate->p_nums++;
	}

	if (mtstate->operation == CMD_INSERT || mtstate->operation == CMD_UPDATE)
	{
		/* Set up for remaining transmittable parameters */
		foreach (lc, fmstate->target_attrs)
		{
			int				  attnum = lfirst_int(lc);
			Form_pg_attribute attr =
					TupleDescAttr(RelationGetDescr(rel), attnum - 1);

			Assert(!attr->attisdropped);
#if PG_VERSION_NUM >= 140000
			/* Ignore generated columns; they are set to DEFAULT */
			if (attr->attgenerated)
			{
				if (list_length(fmstate->retrieved_attrs) >= 1)
					fmstate->p_nums = 1;
				continue;
			}
#endif
			getTypeOutputInfo(attr->atttypid, &typefnoid, &isvarlena);
			fmgr_info(typefnoid, &fmstate->p_flinfo[fmstate->p_nums]);
			fmstate->p_nums++;
		}
	}
	Assert(fmstate->p_nums <= n_params);

#ifndef __TSURUGI_PLANNER__
#if PG_VERSION_NUM >= 140000
	/* Set batch_size from foreign server/table options. */
	if (mtstate->operation == CMD_INSERT)
		fmstate->batch_size = get_batch_size_option(fmstate->rel);
#endif
#endif

	n_params		   = list_length(fmstate->retrieved_attrs);
	fmstate->num_slots = 1;

	/* Initialize auxiliary state */
	fmstate->aux_fmstate = NULL;

	resultRelInfo->ri_FdwState = fmstate;

	/* Find RTE. */
	rte = exec_rt_fetch(resultRelInfo->ri_RangeTableIndex, mtstate->ps.state);

	/* Get info about foreign table. */
	table				 = GetForeignTable(rte->relid);
	server				 = GetForeignServer(table->serverid);
	user				 = GetUserMapping(GetUserId(), server->serverid);
	fmstate->tg_conn	 = tg_get_connection(server, user);
	fmstate->param_linfo = estate->es_param_list_info;

	fmstate->junk_idx = palloc0(
			RelationGetDescr(rel)->natts * sizeof(AttrNumber));
	/* loop through table columns */
	for (int i = 0; i < RelationGetDescr(rel)->natts; ++i)
	{
		/* for primary key columns, get the resjunk attribute number and store
		 * it */
		fmstate->junk_idx[i] = ExecFindJunkAttributeInTlist(
				subplan->targetlist,
				get_attname(foreignTableId, i + 1, false));
	}
}

/*
 * tsurugiExecForeignInsert
 */
static TupleTableSlot *
tsurugiExecForeignInsert(
		EState		   *estate,
		ResultRelInfo  *rinfo,
		TupleTableSlot *slot,
		TupleTableSlot *planSlot)
{
	TupleTableSlot **rslot;
	int				 numSlots = 1;

	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	rslot = tg_execute_foreign_modify(
			estate, rinfo, CMD_INSERT, &slot, &planSlot, &numSlots);

	return rslot ? *rslot : NULL;
}

/*
 * tsurugiExecForeignUpdate
 */
static TupleTableSlot *
tsurugiExecForeignUpdate(
		EState		   *estate,
		ResultRelInfo  *rinfo,
		TupleTableSlot *slot,
		TupleTableSlot *planSlot)
{
	TupleTableSlot **rslot;
	int				 numSlots = 1;

	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	rslot = tg_execute_foreign_modify(
			estate, rinfo, CMD_UPDATE, &slot, &planSlot, &numSlots);

	return rslot ? *rslot : NULL;
}

/*
 * tsurugiExecForeignDelete
 */
static TupleTableSlot *
tsurugiExecForeignDelete(
		EState		   *estate,
		ResultRelInfo  *rinfo,
		TupleTableSlot *slot,
		TupleTableSlot *planSlot)
{
	TupleTableSlot **rslot;
	int				 numSlots = 1;

	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	rslot = tg_execute_foreign_modify(
			estate, rinfo, CMD_DELETE, &slot, &planSlot, &numSlots);

	return rslot ? *rslot : NULL;
}

/*
 * tsurugiEndForeignModify
 */
static void
tsurugiEndForeignModify(EState *estate, ResultRelInfo *resultRelInfo)
{
	TgFdwForeignModifyState *fmstate = (TgFdwForeignModifyState *)
											   resultRelInfo->ri_FdwState;

	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	/* If fmstate is NULL, we are in EXPLAIN; nothing to do */
	if (fmstate == NULL)
		return;
}

/*
 * tsurugiBeginForeignInsert
 */
static void
tsurugiBeginForeignInsert(
		ModifyTableState *mtstate, ResultRelInfo *resultRelInfo)
{
	elog(DEBUG2, "tsurugi_fdw: %s", __func__);
}

/*
 * tsurugiEndForeignInsert
 */
static void
tsurugiEndForeignInsert(EState *estate, ResultRelInfo *resultRelInfo)
{
	elog(DEBUG2, "tsurugi_fdw: %s", __func__);
}

/* -------------------------------------------------------------------------
 * FDW Explain functions.
 * -------------------------------------------------------------------------
 */
/*
 * tsurugiExplainForeignScan
 *		Produce extra output for EXPLAIN of a ForeignScan on a foreign table
 */
static void
tsurugiExplainForeignScan(ForeignScanState *node, ExplainState *es)
{
	List *fdw_private;
	char *sql;
	char *relations;

	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

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
tsurugiExplainDirectModify(ForeignScanState *node, ExplainState *es)
{
	elog(DEBUG1, "tsurugi_fdw: %s", __func__);
}

/*
 * tsurugiAnalyzeForeignTable
 *      Not in use.
 */
static bool
tsurugiAnalyzeForeignTable(
		Relation			   relation,
		AcquireSampleRowsFunc *func,
		BlockNumber			  *totalpages)
{
	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	return true;
}

/* -------------------------------------------------------------------------
 * FDW Import Foreign Schema function.
 * -------------------------------------------------------------------------
 */
/*
 * tsurugiImportForeignSchema
 *      Import table metadata from a foreign server.
 */
static List *
tsurugiImportForeignSchema(ImportForeignSchemaStmt *stmt, Oid serverOid)
{
	List		  *commands;
	ForeignServer *server;
	UserMapping	  *user;
	TG_STATUS	   tg_status;
	TGconn		  *tg_conn;

	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	/*
	 * Checking the options of the Import Foreign Schema statement.
	 * If the option is specified, an error is assumed.
	 */
	if ((stmt->options != NULL) && (stmt->options->length > 0))
	{
#if PG_VERSION_NUM >= 130000
		DefElem *def = lfirst(stmt->options->elements);
#else
		DefElem *def = lfirst(stmt->options->head);
#endif
		ereport(ERROR,
				(errcode(ERRCODE_FDW_INVALID_OPTION_NAME),
				 errmsg("unsupported import foreign schema option \"%.64s\"",
						def->defname)));
	}
	commands = NULL;

	server	= GetForeignServer(serverOid);
	user	= GetUserMapping(GetUserId(), serverOid);
	tg_conn = tg_get_connection(server, user);

	tg_status =
			tg_exec_import_foreign_schema(tg_conn, stmt, serverOid, &commands);
	if (tg_status != TG_STATUS_OK)
		elog(ERROR, "%s", tg_global_error_message());

	return commands;
}

/* -------------------------------------------------------------------------
 * Helper functions.
 * -------------------------------------------------------------------------
 */
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
find_modifytable_subplan(
		PlannerInfo *root, ModifyTable *plan, Index rtindex, int subplan_index)
{
	Plan *subplan = outerPlan(plan);

	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

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
		Append *appendplan = (Append *) subplan;

		if (subplan_index < list_length(appendplan->appendplans))
			subplan = (Plan *)
					list_nth(appendplan->appendplans, subplan_index);
	}
	else if (
			IsA(subplan, Result) && outerPlan(subplan) != NULL &&
			IsA(outerPlan(subplan), Append))
	{
		Append *appendplan = (Append *) outerPlan(subplan);

		if (subplan_index < list_length(appendplan->appendplans))
			subplan = (Plan *)
					list_nth(appendplan->appendplans, subplan_index);
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
#endif	// PG_VERSION_NUM >= 140000
#if 0
static void make_retrieved_attrs(List *telist, List **retrieved_attrs)
{
	ListCell *lc;
	int i;

	elog(DEBUG3, "tsurugi_fdw: %s", __func__);

	*retrieved_attrs = NIL;

	i = 0;
	foreach (lc, telist)
	{
		TargetEntry *entry = (TargetEntry *) lfirst(lc);
		elog(
			DEBUG5,
			"tsurugi_fdw: %s : attr_number: %d, res_name: %s, resno: %d, resorigcol: %d",
			__func__, i, entry->resname, entry->resno, entry->resorigcol);
		*retrieved_attrs = lappend_int(*retrieved_attrs, i + 1);
		i++;
	}
}
#endif
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
store_pg_data_type(
		TgFdwForeignScanState *fsstate, List *tlist, List **retrieved_attrs)
{
	ListCell *lc = NULL;

	elog(DEBUG3, "tsurugi_fdw: %s", __func__);

	*retrieved_attrs = NIL;

	if (tlist != NULL)
	{
		Oid *data_types = (Oid *) palloc(sizeof(Oid) * tlist->length + 1);

		int i	  = 0;
		int count = 0;
		foreach (lc, tlist)
		{
			TargetEntry *entry = (TargetEntry *) lfirst(lc);
			Node		*node  = (Node *) entry->expr;
			count++;

			if (nodeTag(node) == T_Var || nodeTag(node) == T_OpExpr)
			{
				Var *var	  = (Var *) node;
				data_types[i] = var->vartype;
				elog(DEBUG5,
					 "tsurugi_fdw:  (att_number: %d, nodeTag: %u, vartype: "
					 "%d)",
					 i,
					 (unsigned int) nodeTag(node),
					 (int) var->vartype);
			}
			else if (nodeTag(node) == T_Const)
			{
				// When generating placeholders in a SELECT query expression.
				elog(DEBUG5,
					 "Skip the data type placeholders. (index: %d, type: %u)",
					 i,
					 (unsigned int) nodeTag(node));
			}
			else
			{
				elog(ERROR,
					 "Unexpected data type in target list. (index: %d, type: "
					 "%u)",
					 i,
					 (unsigned int) nodeTag(node));
			}
			elog(DEBUG1, "tsurugi_fdw: %s : attr_number: %d", __func__, i);
			*retrieved_attrs = lappend_int(*retrieved_attrs, i + 1);
			i++;
		}
		fsstate->column_types	   = data_types;
		fsstate->number_of_columns = count;
	}
}

#if PG_VERSION_NUM >= 140000
/*
 * Determine batch size for a given foreign table. The option specified for
 * a table has precedence.
 */
static int
get_batch_size_option(Relation rel)
{
	Oid			   foreigntableid = RelationGetRelid(rel);
	ForeignTable  *table;
	ForeignServer *server;
	List		  *options;
	ListCell	  *lc;

	/* we use 1 by default, which means "no batching" */
	int batch_size = 1;

	elog(DEBUG1, "tsurugi_fdw: %s", __func__);

	/*
	 * Load options for table and server. We append server options after table
	 * options, because table options take precedence.
	 */
	table  = GetForeignTable(foreigntableid);
	server = GetForeignServer(table->serverid);

	options = NIL;
	options = list_concat(options, table->options);
	options = list_concat(options, server->options);

	/* See if either table or server specifies batch_size. */
	foreach (lc, options)
	{
		DefElem *def = (DefElem *) lfirst(lc);

		if (strcmp(def->defname, "batch_size") == 0)
		{
			(void) parse_int(defGetString(def), &batch_size, 0, NULL);
			break;
		}
	}

	return batch_size;
}
#endif

/**
 * tg_execute_direct_modify
 */
static void
tg_execute_direct_modify(ForeignScanState *node)
{
	TG_STATUS				tg_status;
	TgFdwDirectModifyState *dmstate = (TgFdwDirectModifyState *)
											  node->fdw_state;
	ExprContext *econtext = node->ss.ps.ps_ExprContext;
	ForeignScan *fsplan	  = (ForeignScan *) node->ss.ps.plan;

	elog(DEBUG3, "tsurugi_fdw: %s", __func__);

	dmstate->tg_stmt = tg_stmt_prepare(dmstate->tg_conn, dmstate->query);
	if (!dmstate->tg_stmt)
		elog(ERROR, "%s", tg_stmt_error_message(dmstate->tg_stmt));

	tg_status = tg_stmt_bind_params_for_query(
			dmstate->tg_stmt,
			fsplan->fdw_exprs,
			econtext,
			dmstate->param_exprs);
	if (tg_status != TG_STATUS_OK)
		elog(ERROR, "%s", tg_stmt_error_message(dmstate->tg_stmt));

	tg_status =
			tg_stmt_execute_statement(dmstate->tg_stmt, &dmstate->num_tuples);
	if (tg_status != TG_STATUS_OK)
		elog(ERROR, "%s", tg_stmt_error_message(dmstate->tg_stmt));
}

/*
 * tsurugi_execute_insert
 *		Perform execute tsurugiExecForeignInsert, tsurugiExecForeignBatchInsert
 */
static TupleTableSlot **
tg_execute_foreign_modify(
		EState			*estate,
		ResultRelInfo	*resultRelInfo,
		CmdType			 operation,
		TupleTableSlot **slots,
		TupleTableSlot **planSlots,
		int				*numSlots)
{
	TgFdwForeignModifyState *fmstate = (TgFdwForeignModifyState *)
											   resultRelInfo->ri_FdwState;
	TG_STATUS tg_status;
	size_t	  n_rows = 0;
	/* silence unused warnings (depends on build flags) */
	(void) estate;
	(void) numSlots;

	/* The operation should be INSERT, UPDATE, or DELETE */
	Assert(operation == CMD_INSERT || operation == CMD_UPDATE ||
		   operation == CMD_DELETE);

	elog(DEBUG1, "tsurugi_fdw: %s (operation: %d)", __func__, operation);

	fmstate->tg_stmt = tg_stmt_prepare(fmstate->tg_conn, fmstate->query);
	tg_status		 = tg_stmt_bind_parameters2(
			   fmstate->tg_stmt,
			   fmstate->rel,
			   fmstate->target_attrs,
			   slots,
			   planSlots,
			   fmstate->junk_idx);
	if (tg_status != TG_STATUS_OK)
		elog(ERROR, "%s", tg_stmt_error_message(fmstate->tg_stmt));
	tg_status = tg_stmt_execute_statement(fmstate->tg_stmt, &n_rows);
	if (tg_status != TG_STATUS_OK)
		elog(ERROR, "%s", tg_stmt_error_message(fmstate->tg_stmt));

	/*
	 * Return NULL if nothing was inserted/updated/deleted on the remote end
	 */
	return (n_rows > 0) ? slots : NULL;
}

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
 * tsurugi_planner.c
 * Planning to push down DML for Tsurugi table to Tsurugi server
 */

#include "postgres.h"

#if PG_VERSION_NUM >= 120000
#include "access/table.h"
#endif
#include "catalog/pg_type.h"
#include "foreign/fdwapi.h"
#include "nodes/makefuncs.h"
#include "nodes/nodes.h"
#include "nodes/primnodes.h"
#include "optimizer/planner.h"
#include "parser/parsetree.h"
#include "parser/parse_coerce.h"
#include "utils/rel.h"

typedef struct tsurugi_planner_info_
{
	Query	*parse;
	bool	hasjoin;
	bool	hasaggref;
	Oid		serverid;
	List	*oidlist;
} TsurugiPlannerInfo;

/* "table_open" was "heap_open" before v12 */
#if PG_VERSION_NUM < 120000
#define table_open(x, y) heap_open(x, y)
#define table_close(x, y) heap_close(x, y)
#endif /* PG_VERSION_NUM */

#ifndef PG_MODULE_MAGIC
PG_MODULE_MAGIC;
#endif

/* planner_hook function */
#if PG_VERSION_NUM >= 130000
PlannedStmt *tsurugi_planner(Query *parse2, const char *query_string, int cursorOptions, ParamListInfo boundParams);
#else
PlannedStmt *tsurugi_planner(Query *parse2, int cursorOptions, ParamListInfo boundParams);
#endif
static bool is_only_foreign_table(TsurugiPlannerInfo *root, List *rtable);
static TsurugiPlannerInfo *init_TsurugiPlannerInfo(Query *parse);
static ForeignScan *create_foreign_scan(TsurugiPlannerInfo *root); 
static ModifyTable *create_modify_table(TsurugiPlannerInfo *root, ForeignScan *scan); 
static void set_target_entry(ForeignScan *scan, TsurugiPlannerInfo *root); 
static PlannedStmt *create_planned_stmt(TsurugiPlannerInfo *root, Plan *plan);
static void preprocess_targetlist2(Query *parse, ForeignScan *scan);
static List *expand_targetlist(List *tlist, int command_type, Index result_relation, Relation rel);
static bool contain_foreign_tables(TsurugiPlannerInfo *root, List *rtable);

/**
 *  @brief 	Alternative planner for tsurugidb.
 * 			This planner make a plan to push down a query to remote database.
 *  @param 	-
 *  @return	pointer to PlannedStmt.
 */
struct PlannedStmt *
#if PG_VERSION_NUM >= 130000
tsurugi_planner(Query *parse2, const char *query_string, int cursorOptions, ParamListInfo boundParams)
#else
tsurugi_planner(Query *parse2, int cursorOptions, ParamListInfo boundParams)
#endif
{
	Query *parse = copyObject(parse2);
	TsurugiPlannerInfo *root = init_TsurugiPlannerInfo(parse);
	ForeignScan *scan = NULL;
	Plan *plan = NULL;
	PlannedStmt *stmt = NULL;
	ModifyTable *modify = NULL;

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);
#if PG_VERSION_NUM >= 130000
	elog(LOG, "tsurugi_fdw : \nquery: \n%s", query_string);
#endif
	if ((root->parse != NULL && root->parse->rtable == NULL) || 
		!contain_foreign_tables(root, root->parse->rtable))
	{
#if PG_VERSION_NUM >= 130000
		return standard_planner(parse2, query_string, cursorOptions, boundParams);
#else
		return standard_planner(parse2, cursorOptions, boundParams);
#endif
	}

	if (parse->hasAggs)
	{
		root->hasaggref = true;
	}

	switch (parse->commandType)
	{
		case CMD_INSERT:
		case CMD_UPDATE:
		case CMD_DELETE:
		{
			/* Generates an error if there is a FROM clause in UPDATE or DELETE */
			if (root->oidlist != NULL && root->oidlist->length > 1 && 
				(parse->commandType == CMD_DELETE || parse->commandType == CMD_UPDATE))
			{
				elog(NOTICE, "PostgreSQL unique grammar.(there is a FROM clause in UPDATE or DELETE)");
			}
            
            if (root->parse != NULL && root->parse->rtable != NULL &&
                is_only_foreign_table(root, root->parse->rtable)) 
            {
                elog(LOG, "tsurugi_fdw : %s : Selected direct modify.", 
					__func__);
                scan = create_foreign_scan(root);
                modify = create_modify_table(root, scan);
                plan = (Plan *) modify;
				stmt = create_planned_stmt(root, plan);
            } 
            else 
            {
#if PG_VERSION_NUM >= 130000
				stmt = standard_planner(parse2, query_string, cursorOptions, boundParams);
#else
        		stmt = standard_planner(parse2, cursorOptions, boundParams);    
#endif
            }
			break;
		}
		case CMD_SELECT:
		default:
		{
#if PG_VERSION_NUM >= 130000
			stmt = standard_planner(parse2, query_string, cursorOptions, boundParams);
#else
			stmt = standard_planner(parse2, cursorOptions, boundParams);
#endif
			break;
		}
	}

	elog(LOG, "tsurugi_fdw : tsurugi_planner() is done.");

	return stmt;
}

/**
 *  @brief 	
 *  @param 	
 *  @return	
 */
/*
 * init_TsurugiPlannerInfo
 *
 * input
 * Query *parse         ... 
 *
 * output
 * TsurugiPlannerInfo *root ... 
 */
TsurugiPlannerInfo
*init_TsurugiPlannerInfo(Query *parse)
{
	TsurugiPlannerInfo *root = (TsurugiPlannerInfo *) palloc0(sizeof(TsurugiPlannerInfo));
	root->parse		=	parse;
	root->hasjoin	=	false;
	root->hasaggref	=	false;
	root->serverid	=	0;
	root->oidlist	=	NULL;

	return root;
}

/**
 *  @brief 	
 *  @param 	
 *  @return	
 */
/*
 * is_only_foreign_table
 *
 * input
 * TsurugiPlannerInfo *root ... 
 * List *rtable         ... 
 *
 * output
 * bool                 ... 
 */
bool
is_only_foreign_table(TsurugiPlannerInfo *root, List *rtable)
{
	ListCell	*rtable_list_cell;
	Oid			currentserverid;

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	foreach(rtable_list_cell, rtable)
	{
		RangeTblEntry	*range_table_entry;

		range_table_entry = lfirst_node(RangeTblEntry, rtable_list_cell);

		switch ((int) range_table_entry->rtekind)
		{
			case RTE_RELATION:
			{
				if (range_table_entry->relkind == 'f')
				{
					currentserverid = GetForeignServerIdByRelId(range_table_entry->relid);
					root->oidlist = lappend_oid(root->oidlist, range_table_entry->relid);
					if (root->serverid == 0)
					{
						root->serverid = currentserverid;
						break;
					}
					else if (root->serverid != currentserverid)
					{
						elog(NOTICE, "tsurugi_fdw : Mix of different types of servers.");
						return false;
					}
				}
				else
				{
					return false;
				}
				break;
			}

			case RTE_SUBQUERY:
			{
				if (range_table_entry->relkind != 0 || range_table_entry->subquery == 0)
				{
					return false;
				}
				else
				{
					Query	*subquery = range_table_entry->subquery;

					if (is_only_foreign_table(root, subquery->rtable))
					{
						break;
					}
					else
					{
						return false;
					}

				}
				break;
			}
			case RTE_JOIN:
			{
				if(!root->hasjoin)
				{
					root->hasjoin = true;
				}

				break;
			}
			case RTE_CTE:
			case RTE_FUNCTION:
			case RTE_TABLEFUNC:
			case RTE_VALUES:
			case RTE_NAMEDTUPLESTORE:
			default:
			{
                elog(LOG, "tsurugi_fdw : Whether or not support is provided will be " \
						"determined by Tsurugi. rtekind = %d", range_table_entry->rtekind);
				break;
			}
		}
	}

	return true;
}

/**
 *  @brief 	
 *  @param 	
 *  @return	
 */
bool 
contain_foreign_tables(TsurugiPlannerInfo *root, List *rtable)
{
	ListCell	*rtable_list_cell;
	Oid			currentserverid;
	bool contained = false;

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	foreach(rtable_list_cell, rtable)
	{
		RangeTblEntry	*range_table_entry;
		range_table_entry = lfirst_node(RangeTblEntry, rtable_list_cell);
		switch ((int) range_table_entry->rtekind)
		{
			case RTE_RELATION:
			{
				if (range_table_entry->relkind == 'f')
				{
					contained = true;
					currentserverid = GetForeignServerIdByRelId(range_table_entry->relid);
					root->oidlist = lappend_oid(root->oidlist, range_table_entry->relid);
					if (root->serverid == 0)
					{
						root->serverid = currentserverid;
						break;
					}
					else if (root->serverid != currentserverid)
					{
						elog(NOTICE, 
							"tsurugi_ fdw : Mix of different types of servers. (serverid: %d) (currentserverid: %d)",
							root->serverid, currentserverid);
						return false;
					}
				}
				break;
			}

			case RTE_SUBQUERY:
			{
				if (range_table_entry->relkind != 0 || range_table_entry->subquery == 0)
				{
					return false;
				}
				else
				{
					Query	*subquery = range_table_entry->subquery;

					if (contain_foreign_tables(root, subquery->rtable))
					{
						contained = true;
						break;
					}
				}
				break;
			}

			case RTE_JOIN:
			{
				if (!root->hasjoin)
				{
					root->hasjoin = true;
				}
				break;
			}

			case RTE_CTE:
			case RTE_TABLEFUNC:
			case RTE_NAMEDTUPLESTORE:
			{
				return false;
				break;
			}
			default:
                break;
		}
	}

	return contained;
}

/**
 *  @brief 	
 *  @param 	
 *  @return	
 */
ForeignScan *
create_foreign_scan(TsurugiPlannerInfo *root)
{
	Bitmapset  *fs_relids = NULL;
	ForeignScan *fnode;
	fnode = makeNode(ForeignScan);

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	fnode->scan.plan.targetlist = NIL;
	fnode->scan.plan.qual = NIL;
	fnode->scan.plan.lefttree = NULL;
	fnode->scan.plan.righttree = NULL;
	fnode->scan.scanrelid = 0;
	fnode->operation = root->parse->commandType;
	fnode->fs_server = root->serverid;
	fnode->fdw_exprs = NIL;
	fnode->fdw_private = NIL;
	fnode->fdw_scan_tlist = NIL;
	fnode->fdw_recheck_quals = NIL;
	fnode->fs_relids = NULL;
	fnode->fsSystemCol = false;

	fs_relids = bms_add_member(fs_relids, 1);
	fnode->fs_relids = fs_relids;

	set_target_entry(fnode, root);

	return fnode;
}

/**
 *  @brief 	
 *  @param 	
 *  @return	
 */
ModifyTable *
create_modify_table(TsurugiPlannerInfo *root, ForeignScan *scan)
{
	ModifyTable *modify = makeNode(ModifyTable);
	List *fdwPrivLists = NIL;
	Bitmapset  *direct_modify_plans = NULL;

	List *subplan = NIL;
	subplan = lappend(subplan, scan);

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

#if PG_VERSION_NUM >= 140000
	modify->plan.lefttree = (Plan *)scan;
#else
	modify->plan.lefttree = NULL;
#endif  // PG_VERSION_NUM >= 140000
	modify->plan.righttree = NULL;
	modify->plan.qual = NIL;
	modify->plan.targetlist = NIL;
	modify->operation = root->parse->commandType;
	modify->canSetTag = root->parse->canSetTag;
	modify->nominalRelation = 1;
#if PG_VERSION_NUM < 120000
	modify->partitioned_rels = 0;
#else
	modify->rootRelation = 0;
#endif
	modify->partColsUpdated = false;
#if PG_VERSION_NUM >= 140000
	modify->resultRelations = lappend_int(modify->resultRelations, root->parse->resultRelation);
#else
	modify->resultRelations = 0;
	modify->resultRelIndex = 0;
	modify->rootResultRelIndex = -1;
	modify->plans = subplan;
#endif  // PG_VERSION_NUM >= 140000
	modify->withCheckOptionLists = NIL;
	modify->returningLists = NIL;
	modify->fdwPrivLists = NIL;
	modify->fdwDirectModifyPlans = NULL;
	modify->rowMarks = NIL;
	modify->epqParam = 0;
	/* Areas requiring consideration. */
	modify->onConflictAction = ONCONFLICT_NONE;
	modify->onConflictSet = NIL;
	modify->onConflictWhere = NULL;
	modify->arbiterIndexes = NIL;
	modify->exclRelRTI = 0;
	modify->exclRelTlist = NIL;

	fdwPrivLists = lappend(fdwPrivLists, 0);
	modify->fdwPrivLists = fdwPrivLists;

	direct_modify_plans = bms_add_member(direct_modify_plans, 0);
	modify->fdwDirectModifyPlans = direct_modify_plans;

	return modify;
}

/**
 *  @brief 	
 *  @param 	
 *  @return	
 */
void
set_target_entry(ForeignScan *scan, TsurugiPlannerInfo *root)
{
	List *pte = root->parse->targetList;
	ListCell *lc = NULL;
	Var *var = NULL;
	Var *newvar = NULL;
	Aggref *aggref = NULL;
	TargetEntry *newte = NULL;
	TargetEntry *newfste = NULL;

	/* attribute number is 1 origin. */
	int attno = 1;

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	foreach(lc, pte)
	{
		TargetEntry *te = (TargetEntry *) lfirst(lc);
		Node *node = (Node *) te->expr;

		switch (nodeTag(node))
		{
			case T_Var:
			{
				/* for fdw_scan_tlist */
				var = (Var *) node;
				newfste = makeTargetEntry((Expr *) node,
											attno,
											NULL,
											te->resjunk);
				scan->fdw_scan_tlist = lappend(scan->fdw_scan_tlist, newfste);
				/* for targetlist */
				newvar = makeVar(var->varno,
						       attno,
						       var->vartype,
						       var->vartypmod,
						       var->varcollid,
						       0);
				newvar->varno = INDEX_VAR;
#if PG_VERSION_NUM >= 130000
				newvar->varattnosyn = var->varattnosyn;
#else
				newvar->varoattno = var->varoattno;
#endif
				newvar->location = var->location;
				newte = makeTargetEntry((Expr *) newvar,
										attno,
										te->resname,
										te->resjunk);
				newte->resorigtbl = te->resorigtbl;
				newte->resorigcol = te->resorigcol;
				newte->ressortgroupref = 0;
				scan->scan.plan.targetlist = lappend(scan->scan.plan.targetlist, newte);
				break;
			}
			case T_Aggref:
			{
				/* for fdw_scan_tlist */
				newfste = makeTargetEntry((Expr *) node,
										   attno,
										   NULL,
										   false);
				scan->fdw_scan_tlist = lappend(scan->fdw_scan_tlist, newfste);
				/* for targetlist */
				aggref = (Aggref *) node;
				newvar = makeVar(INDEX_VAR,
								  attno,
								  aggref->aggtype,
								  -1,
								  InvalidOid,
								  0);
				newte = makeTargetEntry((Expr *) newvar,
										 attno,
										 te->resname,
										 te->resjunk);
				newte->ressortgroupref = 0;
				scan->scan.plan.targetlist = lappend(scan->scan.plan.targetlist, newte);
				break;
			}
			case T_Const:
			case T_Param:
#if PG_VERSION_NUM < 120000
			case T_ArrayRef:
#else
			case T_SubscriptingRef:
#endif
			case T_FuncExpr:
			case T_OpExpr:
			case T_DistinctExpr:
			case T_ScalarArrayOpExpr:
			case T_RelabelType:
			case T_BoolExpr:
			case T_NullTest:
			case T_ArrayExpr:
			case T_List:
			default:
			{
				if (root->parse->commandType == CMD_SELECT)
				{
					elog(NOTICE, "Contains an unsupported TargetEntry.");
				}
				break;
			}
		}
		attno++;
	}

	if (root->parse->commandType == CMD_INSERT || root->parse->commandType == CMD_UPDATE)
	{
		preprocess_targetlist2(root->parse, scan);
	}
}

/**
 *  @brief 	
 *  @param 	
 *  @return	
 */
PlannedStmt *
create_planned_stmt(TsurugiPlannerInfo *root, Plan *plan)
{
	PlannedStmt *stmt = makeNode(PlannedStmt);
	Query *parse = root->parse;

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	stmt->commandType = parse->commandType;
	stmt->queryId = parse->queryId;
	stmt->hasReturning = false;
	stmt->hasModifyingCTE = false;
	stmt->canSetTag = true;
	stmt->transientPlan = false;
	stmt->dependsOnRole = false;
	stmt->parallelModeNeeded = false;
	stmt->jitFlags = 0;
	stmt->planTree = plan;
	stmt->rtable = parse->rtable;
	stmt->resultRelations = NIL;
#if PG_VERSION_NUM < 120000
	stmt->nonleafResultRelations = NIL;
#endif
#if PG_VERSION_NUM < 140000
	stmt->rootResultRelations = NIL;
#endif  // PG_VERSION_NUM >= 140000
	stmt->subplans = NIL;
	stmt->rewindPlanIDs = NULL;
	stmt->rowMarks = NIL;
	stmt->relationOids = root->oidlist;
	stmt->invalItems = NIL;
	stmt->paramExecTypes = NIL;
	stmt->utilityStmt = parse->utilityStmt;
	stmt->stmt_location = parse->stmt_location;
	stmt->stmt_len = parse->stmt_len;

	if (nodeTag(plan) == T_ModifyTable)
	{
		List *resultRelations = NIL;

		resultRelations = lappend_int(resultRelations, parse->resultRelation);
		stmt->resultRelations = resultRelations;
	}

	return stmt;
}

/**
 *  @brief 	
 *  @param 	
 *  @return	
 */
void
preprocess_targetlist2(Query *parse, ForeignScan *scan)
{
	RangeTblEntry	*target_rte = NULL;
	Relation		target_relation = NULL;
	List			*tlist;
#if PG_VERSION_NUM >= 140000
	Var		   *var;
	TargetEntry *tle;
#endif  // PG_VERSION_NUM >= 140000

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	target_rte = rt_fetch(parse->resultRelation, parse->rtable);

	target_relation = table_open(target_rte->relid, NoLock);

	tlist = parse->targetList;
	tlist = expand_targetlist(tlist, parse->commandType, 
							parse->resultRelation, target_relation);

#if PG_VERSION_NUM >= 140000
	var = makeWholeRowVar(target_rte, parse->resultRelation, 0, false);
	tle = makeTargetEntry((Expr *) var,
						  list_length(parse->targetList) + 1,
						  pstrdup("wholerow"),
						  true);
	tlist = lappend(tlist, tle);
#endif  // PG_VERSION_NUM >= 140000

	scan->scan.plan.targetlist = tlist;

	if (target_relation)
		table_close(target_relation, NoLock);

}

/**
 *  @brief 	
 *  @param 	
 *  @return	
 */
/*
 * expand_targetlist
 *	  Given a target list as generated by the parser and a result relation,
 *	  add targetlist entries for any missing attributes, and ensure the
 *	  non-junk attributes appear in proper field order.
 */
static List *
expand_targetlist(List *tlist, int command_type,
				  Index result_relation, Relation rel)
{
	List	   *new_tlist = NIL;
	ListCell   *tlist_item;
	int			attrno,
				numattrs;

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	tlist_item = list_head(tlist);

	/*
	 * The rewriter should have already ensured that the TLEs are in correct
	 * order; but we have to insert TLEs for any missing attributes.
	 *
	 * Scan the tuple description in the relation's relcache entry to make
	 * sure we have all the user attributes in the right order.
	 */
	numattrs = RelationGetNumberOfAttributes(rel);

	for (attrno = 1; attrno <= numattrs; attrno++)
	{
		Form_pg_attribute att_tup = TupleDescAttr(rel->rd_att, attrno - 1);
		TargetEntry *new_tle = NULL;

		if (tlist_item != NULL)
		{
			TargetEntry *old_tle = (TargetEntry *) lfirst(tlist_item);

			if (!old_tle->resjunk && old_tle->resno == attrno)
			{
				new_tle = old_tle;
#if PG_VERSION_NUM >= 130000
				tlist_item = lnext(tlist, tlist_item);
#else
				tlist_item = lnext(tlist_item);
#endif
			}
		}

		if (new_tle == NULL)
		{
			/*
			 * Didn't find a matching tlist entry, so make one.
			 *
			 * For INSERT, generate a NULL constant.  (We assume the rewriter
			 * would have inserted any available default value.) Also, if the
			 * column isn't dropped, apply any domain constraints that might
			 * exist --- this is to catch domain NOT NULL.
			 *
			 * For UPDATE, generate a Var reference to the existing value of
			 * the attribute, so that it gets copied to the new tuple. But
			 * generate a NULL for dropped columns (we want to drop any old
			 * values).
			 *
			 * When generating a NULL constant for a dropped column, we label
			 * it INT4 (any other guaranteed-to-exist datatype would do as
			 * well). We can't label it with the dropped column's datatype
			 * since that might not exist anymore.  It does not really matter
			 * what we claim the type is, since NULL is NULL --- its
			 * representation is datatype-independent.  This could perhaps
			 * confuse code comparing the finished plan to the target
			 * relation, however.
			 */
			Oid			atttype = att_tup->atttypid;
			int32		atttypmod = att_tup->atttypmod;
			Oid			attcollation = att_tup->attcollation;
			Node	   *new_expr;

			switch (command_type)
			{
				case CMD_INSERT:
					if (!att_tup->attisdropped)
					{
						new_expr = (Node *) makeConst(atttype,
													  -1,
													  attcollation,
													  att_tup->attlen,
													  (Datum) 0,
													  true, /* isnull */
													  att_tup->attbyval);
						new_expr = coerce_to_domain(new_expr,
													InvalidOid, -1,
													atttype,
													COERCION_IMPLICIT,
													COERCE_IMPLICIT_CAST,
													-1,
													false);
					}
					else
					{
						/* Insert NULL for dropped column */
						new_expr = (Node *) makeConst(INT4OID,
													  -1,
													  InvalidOid,
													  sizeof(int32),
													  (Datum) 0,
													  true, /* isnull */
													  true /* byval */ );
					}
					break;
				case CMD_UPDATE:
					if (!att_tup->attisdropped)
					{
						new_expr = (Node *) makeVar(result_relation,
													attrno,
													atttype,
													atttypmod,
													attcollation,
													0);
					}
					else
					{
						/* Insert NULL for dropped column */
						new_expr = (Node *) makeConst(INT4OID,
													  -1,
													  InvalidOid,
													  sizeof(int32),
													  (Datum) 0,
													  true, /* isnull */
													  true /* byval */ );
					}
					break;
				default:
					elog(ERROR, "tsurugi_fdw : unrecognized command_type: %d",
						 (int) command_type);
					new_expr = NULL;	/* keep compiler quiet */
					break;
			}

			new_tle = makeTargetEntry((Expr *) new_expr,
									  attrno,
									  pstrdup(NameStr(att_tup->attname)),
									  false);
		}

		new_tlist = lappend(new_tlist, new_tle);
	}

	/*
	 * The remaining tlist entries should be resjunk; append them all to the
	 * end of the new tlist, making sure they have resnos higher than the last
	 * real attribute.  (Note: although the rewriter already did such
	 * renumbering, we have to do it again here in case we are doing an UPDATE
	 * in a table with dropped columns, or an inheritance child table with
	 * extra columns.)
	 */
	while (tlist_item)
	{
		TargetEntry *old_tle = (TargetEntry *) lfirst(tlist_item);

		if (!old_tle->resjunk)
			elog(ERROR, "targetlist is not sorted correctly");
		/* Get the resno right, but don't copy unnecessarily */
		if (old_tle->resno != attrno)
		{
			old_tle = flatCopyTargetEntry(old_tle);
			old_tle->resno = attrno;
		}
		new_tlist = lappend(new_tlist, old_tle);
		attrno++;
#if PG_VERSION_NUM >= 130000
		tlist_item = lnext(tlist, tlist_item);
#else
		tlist_item = lnext(tlist_item);
#endif
	}

	return new_tlist;
}

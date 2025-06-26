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
 *	@file	tsurugi_fdw.h
 *	@brief 	Foreign Data Wrapper for Tsurugi.
 */
#ifndef TSURUGI_FDW_H
#define TSURUGI_FDW_H

#ifdef __cplusplus
extern "C" {
#endif
#include "foreign/foreign.h"
#include "funcapi.h"
#include "lib/stringinfo.h"
#include "nodes/execnodes.h"
#include "nodes/pathnodes.h"
#include "nodes/plannodes.h"
#include "utils/relcache.h"

/* Planning Flag */
#define __TSURUGI_PLANNER__

/*
 * Tsurugi-FDW Foreign Scan State
 */
typedef struct TgFdwForeignScanState
{
	const char* 	query_string;		/* SQL Query Text */
    Relation        rel;                /* relcache entry for the foreign table */
    TupleDesc       tupdesc;            /* tuple descriptor of scan */
    AttInMetadata*  attinmeta;          /* attribute datatype conversion */
    List*           retrieved_attrs;    /* list of target attribute numbers */

	bool 			cursor_exists;		/* have we created the cursor? */
    int             numParams;          /* number of parameters passed to query */
    FmgrInfo*       param_flinfo;       /* output conversion functions for them */
    List*           param_exprs;        /* executable expressions for param values */
	size_t 			number_of_columns;	/* Number of columns to SELECT */
	Oid* 			column_types; 		/* Pointer to the data type (Oid) of the column to be SELECT */

    /* batch operation stuff */
    size_t          rowidx;             /* current index of rows */
	size_t			num_tuples;         /* # of tuples in array */
	bool			eof_reached;        /* true if last fetch reached EOF */
} TgFdwForeignScanState;

/*
 * Tsurugi-FDW Foreign Modify State
 */
typedef struct TgFdwForeignModifyState
{
	Relation	rel;			/* relcache entry for the foreign table */
	AttInMetadata *attinmeta;	/* attribute datatype conversion metadata */

	/* for remote query execution */
//	char	   *prep_name;		/* name of prepared statement, if created */

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
	bool		is_prepared;
	bool		start_tx;
} TgFdwForeignModifyState;

 /*
 * Tsurugi-FDW Direct Modify State
 */
typedef struct TgFdwDirectModifyState
{
	ForeignServer *server;		/* Foreign server handle */
	ForeignTable  *table;		/* Foreign scan deal with this foreign table */

	Relation	rel;			/* relcache entry for the foreign table */
	AttInMetadata *attinmeta;	/* attribute datatype conversion metadata */

	/* extracted fdw_private data */
	const char *orig_query;
	char	   *query;			/* text of UPDATE/DELETE command */
	bool		has_returning;	/* is there a RETURNING clause? */
	List	   *retrieved_attrs;	/* attr numbers retrieved by RETURNING */
	bool		set_processed;	/* do we set the command es_processed? */

	/* for remote query execution */
	char	   *prep_name;		/* name of prepared statement, if created */
	char	   *prep_stmt;
	int			numParams;		/* number of parameters passed to query */
	FmgrInfo   *param_flinfo;	/* output conversion functions for them */
	List	   *param_exprs;	/* executable expressions for param values */
	const char **param_values;	/* textual values of query parameters */
	Oid		   *param_types;	/* type of query parameters */
	ParamListInfo param_linfo;
	TupleTableSlot* slot;

	/* for storing result tuples */
	size_t		num_tuples;		/* # of result tuples */
	int			next_tuple;		/* index of next one to return */
	Relation	resultRel;		/* relcache entry for the target relation */
	AttrNumber *attnoMap;		/* array of attnums of input user columns */
	AttrNumber	ctidAttno;		/* attnum of input ctid column */
	AttrNumber	oidAttno;		/* attnum of input oid column */
	bool		hasSystemCols;	/* are there system columns of resultRel? */

	/* working memory context */
	MemoryContext temp_cxt;		/* context for per-tuple temporary data */
} TgFdwDirectModifyState;

/*
 * 
 */
typedef struct TgFdwRelationInfo
{
	/*
	 * True means that the relation can be pushed down. Always true for simple
	 * foreign scan.
	 */
	bool		pushdown_safe;

	/*
	 * Restriction clauses, divided into safe and unsafe to pushdown subsets.
	 * All entries in these lists should have RestrictInfo wrappers; that
	 * improves efficiency of selectivity and cost estimation.
	 */
	List	   *remote_conds;
	List	   *local_conds;

	/* Actual remote restriction clauses for scan (sans RestrictInfos) */
	List	   *final_remote_exprs;

	/* Bitmap of attr numbers we need to fetch from the remote server. */
	Bitmapset  *attrs_used;

	/* True means that the query_pathkeys is safe to push down */
	bool		qp_is_pushdown_safe;

	/* Cost and selectivity of local_conds. */
	QualCost	local_conds_cost;
	Selectivity local_conds_sel;

	/* Selectivity of join conditions */
	Selectivity joinclause_sel;

	/* Estimated size and cost for a scan, join, or grouping/aggregation. */
	double		rows;
	int			width;
	Cost		startup_cost;
	Cost		total_cost;

	/*
	 * Estimated number of rows fetched from the foreign server, and costs
	 * excluding costs for transferring those rows from the foreign server.
	 * These are only used by estimate_path_cost_size().
	 */
	double		retrieved_rows;
	Cost		rel_startup_cost;
	Cost		rel_total_cost;

	/* Options extracted from catalogs. */
	bool		use_remote_estimate;
	Cost		fdw_startup_cost;
	Cost		fdw_tuple_cost;
	List	   *shippable_extensions;	/* OIDs of whitelisted extensions */
	bool		async_capable;

	/* Cached catalog information. */
	ForeignTable *table;
	ForeignServer *server;
	UserMapping *user;			/* only set in use_remote_estimate mode */

	int			fetch_size;		/* fetch size for this remote table */

	/*
	 * Name of the relation while EXPLAINing ForeignScan. It is used for join
	 * relations but is set for all relations. For join relation, the name
	 * indicates which foreign tables are being joined and the join type used.
	 */
	char	   *relation_name;

	/* Join information */
	RelOptInfo *outerrel;
	RelOptInfo *innerrel;
	JoinType	jointype;
	/* joinclauses contains only JOIN/ON conditions for an outer join */
	List	   *joinclauses;	/* List of RestrictInfo */

	/* Upper relation information */
	UpperRelationKind stage;

	/* Grouping information */
	List	   *grouped_tlist;

	/* Subquery information */
	bool		make_outerrel_subquery; /* do we deparse outerrel as a
										 * subquery? */
	bool		make_innerrel_subquery; /* do we deparse innerrel as a
										 * subquery? */
	Relids		lower_subquery_rels;	/* all relids appearing in lower
										 * subqueries */

	/*
	 * Index of the relation.  It is used to create an alias to a subquery
	 * representing the relation.
	 */
	int			relation_index;

	/* Function pushdown surppot in target list */
	bool		is_tlist_func_pushdown;
} TgFdwRelationInfo;

/* in postgres_fdw.c */
extern int	set_transmission_modes(void);
extern void reset_transmission_modes(int nestlevel);

/* in deparse.c */
extern void classifyConditions(PlannerInfo *root,
							   RelOptInfo *baserel,
							   List *input_conds,
							   List **remote_conds,
							   List **local_conds);
extern bool is_foreign_expr(PlannerInfo *root,
							RelOptInfo *baserel,
							Expr *expr);
extern bool is_foreign_param(PlannerInfo *root,
							 RelOptInfo *baserel,
							 Expr *expr);
extern void deparseInsertSql(StringInfo buf, RangeTblEntry *rte,
				 Index rtindex, Relation rel,
				 List *targetAttrs, bool doNothing,
				 List *withCheckOptionList, List *returningList,
				 List **retrieved_attrs, int *values_end_len);
extern void deparseUpdateSql(StringInfo buf, RangeTblEntry *rte,
							 Index rtindex, Relation rel,
							 List *targetAttrs);
extern void deparseDirectUpdateSql(StringInfo buf, PlannerInfo *root,
								   Index rtindex, Relation rel,
								   RelOptInfo *foreignrel,
								   List *targetlist,
								   List *targetAttrs,
								   List *remote_conds,
								   List **params_list,
								   List *returningList,
								   List **retrieved_attrs);
extern void deparseDeleteSql(StringInfo buf, RangeTblEntry *rte,
							 Index rtindex, Relation rel,
							 List *returningList,
							 List **retrieved_attrs);
extern void deparseDirectDeleteSql(StringInfo buf, PlannerInfo *root,
								   Index rtindex, Relation rel,
								   RelOptInfo *foreignrel,
								   List *remote_conds,
								   List **params_list,
								   List *returningList,
								   List **retrieved_attrs);
extern void deparseAnalyzeSizeSql(StringInfo buf, Relation rel);
extern void deparseAnalyzeSql(StringInfo buf, Relation rel,
							  List **retrieved_attrs);
extern void deparseStringLiteral(StringInfo buf, const char *val);
extern Expr *find_em_expr_for_rel(EquivalenceClass *ec, RelOptInfo *rel);
extern Expr *find_em_expr_for_input_target(PlannerInfo *root,
										   EquivalenceClass *ec,
										   PathTarget *target);
extern List *build_tlist_to_deparse(RelOptInfo *foreignrel);
extern void deparseSelectStmtForRel(StringInfo buf, PlannerInfo *root,
									RelOptInfo *foreignrel, List *tlist,
									List *remote_conds, List *pathkeys,
									bool has_final_sort, bool has_limit,
									bool is_subquery,
									List **retrieved_attrs, List **params_list);
extern const char *get_jointype_name(JoinType jointype);

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
} TgFdwPathExtraData;

/* 
 * Helper functions.
 */
extern void estimate_path_cost_size(PlannerInfo *root,
									RelOptInfo *foreignrel,
									List *param_join_conds,
									List *pathkeys,
									TgFdwPathExtraData *fpextra,
									double *p_rows, int *p_width,
									Cost *p_startup_cost, Cost *p_total_cost);
extern bool ec_member_matches_foreign(PlannerInfo *root, RelOptInfo *rel,
									  EquivalenceClass *ec, EquivalenceMember *em,
									  void *arg);
extern List *get_useful_pathkeys_for_relation(PlannerInfo *root,
											  RelOptInfo *rel);
extern void add_paths_with_pathkeys_for_rel(PlannerInfo *root, RelOptInfo *rel,
											Path *epq_path);
extern void add_foreign_grouping_paths(PlannerInfo *root,
									   RelOptInfo *input_rel,
									   RelOptInfo *grouped_rel,
									   GroupPathExtraData *extra);
extern void add_foreign_ordered_paths(PlannerInfo *root,
									  RelOptInfo *input_rel,
									  RelOptInfo *ordered_rel);
extern void add_foreign_final_paths(PlannerInfo *root,
									RelOptInfo *input_rel,
									RelOptInfo *final_rel,
									FinalPathExtraData *extra);
extern void apply_server_options(TgFdwRelationInfo *fpinfo);
extern void apply_table_options(TgFdwRelationInfo *fpinfo);
extern void merge_fdw_options(TgFdwRelationInfo *fpinfo,
							  const TgFdwRelationInfo *fpinfo_o,
							  const TgFdwRelationInfo *fpinfo_i);
extern List *build_remote_returning(Index rtindex, Relation rel,
									List *returningList);
extern void rebuild_fdw_scan_tlist(ForeignScan *fscan, List *tlist);
extern bool
tsurugi_foreign_join_ok(PlannerInfo *root, RelOptInfo *joinrel, JoinType jointype,
        				RelOptInfo *outerrel, RelOptInfo *innerrel,
		        		JoinPathExtraData *extra);

/* in shippable.c */
extern bool is_builtin(Oid objectId);
extern bool is_shippable(Oid objectId, Oid classId, TgFdwRelationInfo *fpinfo);

#ifdef __cplusplus
}
#endif

#endif // TSURUGI_FDW_H

/*-------------------------------------------------------------------------
 *
 * alt_planner.c
* 		V0版プランナフック(11.1)
 *
 *-------------------------------------------------------------------------
 */

#include "postgres.h"
#include "optimizer/planner.h"
#include "foreign/fdwapi.h"
#include "nodes/nodes.h"
#include "utils/rel.h"
#include "parser/parsetree.h"
#include "nodes/makefuncs.h"
#include "parser/parse_coerce.h"
#include "catalog/pg_type.h"
#include "nodes/primnodes.h"

/* 持ちまわししたい情報を一括管理できる構造体 */

typedef struct AltPlannerInfo
{
	Query	*parse;
	
	/* JOINがあるか */
	bool	hasjoin;

	/* 集積関数があるか */
	bool	hasaggref;
	
	/* 外部サーバオブジェクトのOID */
	Oid		serverid;
	
	/* 入力されたクエリに関係のあるOIDのリスト */
	List	*oidlist;
	
} AltPlannerInfo;


PG_MODULE_MAGIC;

extern void _PG_init(void);

extern PGDLLIMPORT planner_hook_type planner_hook;


bool is_only_foreign_table( AltPlannerInfo *root, List *rtable );
AltPlannerInfo *init_altplannerinfo( Query *parse );
ForeignScan *create_foreign_scan( AltPlannerInfo *root ); /* ForeignScanプランノードの初期化 */
ModifyTable *create_modify_table( AltPlannerInfo *root, ForeignScan *scan ); /* ModifyTableプランノードの初期化 */
void is_valid_targetentry( ForeignScan *scan, AltPlannerInfo *root ); /* fdw_scan_tlsitとtargetlistの貼り付け(JOIN, Aggrefのみ) */
PlannedStmt *create_planned_stmt( AltPlannerInfo *root, Plan *plan );
void preprocess_targetlist2( Query *parse, ForeignScan *scan );
static List *expand_targetlist( List *tlist, int command_type, Index result_relation, Relation rel );



/************************************************************
 * alt_planner
 * 今回追加するプランナ(V0)
 * 
 * ■input
 * Query *parse2             ... リライトまでを終えたパースツリー
 * int cursorOptions         ... 
 * ParamListInfo boundParams ... 
 * 
 * ■output
 * PlannedStmt stmt          ... プランツリーを含むPlannedStmt構造体
 ************************************************************/
struct PlannedStmt *
alt_planner( Query *parse2, int cursorOptions, ParamListInfo boundParams )
{
	/* 変数宣言 */
	Query *parse = copyObject(parse2);
	
	AltPlannerInfo *root = init_altplannerinfo(parse);
	ForeignScan *scan = 0;
	Plan *plan = 0;

	
	/*
	 * 操作対象のSQLコマンドかどうかに応じて処理を行う
	 * SQL文に含まれるオブジェクトがすべて同一サーバ上のRangeTblEntryであることを確認
	 */
	if ( !is_only_foreign_table( root, root->parse->rtable ) )
	{
		return standard_planner( parse2, cursorOptions, boundParams );
	}
	
	
	/*
	 * 集積関数の処理が存在するかを確認
	 */
	if ( parse->hasAggs )
	{
		root->hasaggref = true;
	}
	
	
	/*
	 * コマンドに応じた処理を実施
	 */
	
	switch ( parse->commandType )
	{
	case CMD_SELECT:

		/* v0版では暗黙のJOINはサポート対象外ですが一応*/
		if ( root->oidlist->length > 1 && !root->hasjoin )
		{
			root->hasjoin = true;
			elog( NOTICE, "暗黙のJOINは対象外です(今は通しますが。)" );
		}
		
		scan = create_foreign_scan( root );
		
		plan = (Plan *) scan;
		
		break;
		
	case CMD_INSERT:
	case CMD_UPDATE:
	case CMD_DELETE:

		/* PostgreSQL独自文法として、UPDATE文とDELETE文にFROM句が付く場合があります。 */
		/* この場合、root->oidlistに2以上の数値が計上されることになるため、このような文法は多分将来的にエラーとします。 */
		if(root->oidlist->length > 1 && (parse->commandType == CMD_DELETE || parse->commandType == CMD_UPDATE))
		{
			elog(NOTICE, "PostgreSQL独自文法です。(UPDATEもしくはDELETEでのFROM句の使用)");
		}
		
		scan = create_foreign_scan( root );
		ModifyTable *modify = create_modify_table( root, scan );
		
		plan = (Plan *) modify;
		
		break;
		
	default:
		return standard_planner( parse2, cursorOptions, boundParams );
	}
	
	/* PlannedStmtの生成 */
	
	PlannedStmt *stmt = create_planned_stmt( root, plan );
	
	/* 最終的に生成したPlannedStmtを返却する */
	return stmt;

}



/************************************************************
 * init_altplannerinfo
 * alt_plannerの実行中に保持しておきたい情報を初期化する
 * 
 * ■input
 * Query *parse         ... alt_plannerの入力にあたるパースツリー
 *                          事前にcopyObject関数でコピーしたものを引数として使用する。
 * 
 * ■output
 * AltPlannerInfo *root ... パースツリー(のコピー)や、外部サーバのOID等、
 *                          alt_planner実行中に使いまわしたい情報を収めた構造体を
 *                          初期化したもの。
 ************************************************************/

AltPlannerInfo 
*init_altplannerinfo( Query *parse )
{
	AltPlannerInfo *root = (AltPlannerInfo *) palloc0( sizeof( AltPlannerInfo ) );
	root->parse		=	parse;
	root->hasjoin	=	false;
	root->hasaggref	=	false;
	root->serverid	=	0;
	root->oidlist	=	NULL;
	
	return root;
}



/************************************************************
 * is_only_foreign_table
 * 同じ外部サーバ上に存在するリレーション同士のクエリであるか、
 * また、後々PlannedStmt->relationOidsに追加するため、oidlistを
 * 生成する。
 * 
 * ■input
 * AltPlannerInfo *root ... alt_planner内で使いまわしたい情報。
 *                          本関数内で、root->serverid(外部サーバのOID)の取得と
 *                          root->oidlist(外部表オブジェクトのOIDのリスト)の生成を行う。
 * List *rtable         ... チェックするRangeTblEntryのリスト
 *                          rootにも含まれる要素ではあるが、再帰呼出しをしたいため個別で
 *                          RangeTblEntryのリストも入力する。
 *
 * ■output
 * bool                 ... alt_plannerでの処理対象であればtrueを、
 *                          対象外であればfalseを返却する。
 *                          現時点では、SQLに含まれる表がすべて外部表であればtrueとなる。
 ************************************************************/

bool 
is_only_foreign_table( AltPlannerInfo *root, List *rtable )
{
	ListCell	*rtable_list_cell;
	Oid			currentserverid;

	foreach( rtable_list_cell, rtable )
	{
		/* 取り出し用にRangeTblEntryを宣言 */
		RangeTblEntry	*range_table_entry;
		
		/* RangeTblEntryを取り出し */
		range_table_entry = lfirst_node( RangeTblEntry, rtable_list_cell );
		
		/* チェック */
		
		switch ( range_table_entry->rtekind )
		{
		case RTE_RELATION:
			/* 外部表の場合は、外部サーバのOidを取得する。全てのリレーションで同一外部サーバをアクセスしているかを判定する */
			if ( range_table_entry->relkind == 'f' )
			{
				/* 現在チェックしているRTEの外部サーバのOIDを獲得 */
				currentserverid = GetForeignServerIdByRelId( range_table_entry->relid );
				
				/* OIDをoidlistに追加 */
				root->oidlist = lappend_oid( root->oidlist, range_table_entry->relid );
				

				/* 異なるサーバ上のオブジェクトが混在していないかをチェック */
				if ( root->serverid == 0 )
				{
					root->serverid = currentserverid;
					break;
				}
				else if ( root->serverid != currentserverid )
				{
					elog( NOTICE, "異なる種類のサーバが混在しています" );
					return false;
				}
			}
			
			/* リレーションが外部表以外の場合は処理対象外とする */
			else
			{
				return false;
			}
			
			break;
		
		case RTE_SUBQUERY:
		
			/* 純粋なSUBQUERY以外除外する(VIEWなどは除外する) */
			if ( range_table_entry->relkind != 0 || range_table_entry->subquery==0 )
			{
				return false;
			}
			else
			{
				/* サブクエリ内のRTEをis_only_foreign_tableにかける(再帰) */
				Query	*subquery = range_table_entry->subquery;
				
				if ( is_only_foreign_table( root, subquery->rtable ) )
				{
					break;
				}
				else
				{
					return false;
				}
				
			}
			break;
	
		case RTE_JOIN:
			
			/* JOIN句を明示的に使用した場合、JOINであることを示すRTEが作られる。
			   ただし、実質的にほぼ空なハズなので、特にこれと言った処理はしない。
			*/
			
			if( !root->hasjoin )
			{
				root->hasjoin = true;
			}
			
			break;
			
		/* 以下、処理対象外とします。 */
		case RTE_CTE:
		case RTE_FUNCTION:
		case RTE_TABLEFUNC:
		case RTE_VALUES:
		case RTE_NAMEDTUPLESTORE:
			return false;
			break;
		}
		
	} /* foreach終了 */
	
	/* 最後まで抜けることができればOK */
	return true;
}



/************************************************************
 * create_foreign_scan
 * ForeignScan構造体を生成する
 * SQLコマンドによって異なるtargetlist, fdw_scan_tlistについては、
 * この関数から呼び出されるis_valid_targetentry関数を通して設定する。
 * 
 * ■input
 * AltPlannerInfo *root ... alt_planner内で使いまわしたい情報。
 *                          この関数では、root->parse内の情報と、root->serveridを使用する。
 *
 * ■output
 * ForeignScan *fnode   ... 作成したForeignScanプランノード。
 *                          単純なSELECT文を実行した場合と同等の内容となるよう各値を設定している。
 ************************************************************/

ForeignScan *
create_foreign_scan( AltPlannerInfo *root )
{
	
	/* 初期化 */
	ForeignScan *fnode;
	fnode = makeNode( ForeignScan );
	
	fnode->scan.plan.targetlist = 0;
	fnode->scan.plan.qual = 0;
	fnode->scan.plan.lefttree = NULL;
	fnode->scan.plan.righttree = NULL;
	fnode->scan.scanrelid = 1;
	fnode->operation = root->parse->commandType;
	fnode->fs_server = root->serverid;
	fnode->fdw_exprs = 0;
	fnode->fdw_private = 0;
	fnode->fdw_scan_tlist = 0;
	fnode->fdw_recheck_quals = 0;
	fnode->fs_relids = NULL;
	fnode->fsSystemCol = false;

	/* fs_relidsの設定 */
	/* 単一表のSCANと見なすため、fs_relidsは1が入っているBitmapsetとします */
	Bitmapset  *fs_relids = NULL;
	fs_relids = bms_add_member( fs_relids, 1 );
	fnode->fs_relids = fs_relids;
	
	/* scan.plan.targetlistおよびfdw_scan_tlistの設定 */
	is_valid_targetentry( fnode, root );
	
	/* scanrelidの設定 */
	/* JOIN等が存在する場合は0に変更 */
	if(root->hasjoin || root->hasaggref)
	{
		fnode->scan.scanrelid = 0;
	}
	
	return fnode;
}



/************************************************************
 * create_modify_table
 * ModifyTable構造体を生成する
 * 
 * ■input
 * AltPlannerInfo *root ... alt_planner内で使いまわしたい情報。
 *                          root->parse内の情報を使用する。
 * ForeignScan *scan    ... ModifyTableに紐づけるForeignScanプランノード。
 *                          この関数に入る前に作成済みである前提。
 * 
 * ■output
 * ModifyTable *modify  ... INSERT, DELETE, UPDATE文で必要となるModifyTableプランノード。
 *                          ExecutorでDirectModifyに入るように各項目を設定している。
 ************************************************************/
 
ModifyTable *
create_modify_table( AltPlannerInfo *root, ForeignScan *scan )
{
	ModifyTable *modify = makeNode( ModifyTable );

	/* ForeignScanプランノードのList化 */
	List *subplan = NIL;
	
	subplan = lappend( subplan, scan );
	
	
	/* 初期化 */
	modify->plan.lefttree = NULL;
	modify->plan.righttree = NULL;
	modify->plan.qual = NIL;
	modify->plan.targetlist = NIL;
	modify->operation = root->parse->commandType;
	modify->canSetTag = root->parse->canSetTag;
	modify->nominalRelation = 1;
	modify->partitioned_rels = 0;
	modify->partColsUpdated = false;
	modify->resultRelations = 0;
	modify->resultRelIndex = 0;
	modify->rootResultRelIndex = -1;
	modify->plans = subplan;
	modify->withCheckOptionLists = NIL;
	modify->returningLists = NIL;
	modify->fdwPrivLists = NIL;
	modify->fdwDirectModifyPlans = NULL; 
	modify->rowMarks = NIL;
	modify->epqParam = 0;
	/* ON CONFLICT句の指定がある場合は考慮が必要な項目(V0での考慮は無し) */
	modify->onConflictAction = ONCONFLICT_NONE;
	modify->onConflictSet = NIL;
	modify->onConflictWhere = NULL;
	modify->arbiterIndexes = NIL;
	modify->exclRelRTI = 0;
	modify->exclRelTlist = NIL;

	
	
	/* modify->fdwPrivListsの指定。実質内容のないT_List */
	List *fdwPrivLists = NIL;
	fdwPrivLists = lappend( fdwPrivLists, 0 );
	
	modify->fdwPrivLists = fdwPrivLists;
	
	
	/* modify->fdwDirectModifyPlansの指定。Bitmapsetを追加。 */
	Bitmapset  *direct_modify_plans = NULL;
	direct_modify_plans = bms_add_member( direct_modify_plans, 0 );
	
	modify->fdwDirectModifyPlans = direct_modify_plans;
	
	
	return modify;
}



/************************************************************
 * is_valid_targetentry
 * SELECT, DELETE用 (今のところ問題が起きないのはVarとAggrefのみ)
 * INSERT, UPDATE用 (他の関数に処理を移す)
 * 
 * ■input
 * ForeignScan *scan    ... この関数で作成したTargetEntryのリストを
 *                          紐づけるForeignScanプランノード
 * AltPlannerInfo *root ... 
 * 
 * ■output
 * --
 * 
 ************************************************************/

void
is_valid_targetentry( ForeignScan *scan, AltPlannerInfo *root )
{
	List *pte = root->parse->targetList;
	ListCell *l;
	Var *var;
	Var *newvar;
	Aggref *aggref;
	
	/* ForeignScan->targetlist用 */
	TargetEntry *newte = NULL;
	
	/* fdw_scan_tlist用 */
	TargetEntry *newfste = NULL;
	
	/* 入力されたTargetEntryをチェック */
	
	int attno = 1;
	foreach( l, pte )
	{
		TargetEntry *te = (TargetEntry *) lfirst( l );
		Node *node = (Node *) te->expr;
		
		switch ( nodeTag( node ) )
			{
			case T_Var:
				var = (Var *) node;
				
				if ( root->hasjoin || root->hasaggref )
				{
					/* ForeignScan->fdw_scan_tlist用 */
					newfste = makeTargetEntry( (Expr *) node,
											   attno,
											   NULL,
											   te->resjunk );
					
					scan->fdw_scan_tlist = lappend( scan->fdw_scan_tlist, newfste );
					
					
					/* ForeignScan->targetlist用 */
					newvar = makeVar( var->varno,
									  attno,
									  var->vartype,
									  var->vartypmod,
									  var->varcollid,
									  0 );
					
					newvar->varno = INDEX_VAR;
					newvar->varoattno = var->varoattno;
					newvar->location = var->location;
					
					newte = makeTargetEntry( (Expr *) newvar,
											 attno,
											 te->resname,
											 te->resjunk );
					
					newte->resorigtbl = te->resorigtbl;
					newte->resorigcol = te->resorigcol;
					newte->ressortgroupref = 0;
					
					scan->scan.plan.targetlist = lappend( scan->scan.plan.targetlist, newte );
				}
				else /* 単純に列を指定した場合 */
				{
					scan->scan.plan.targetlist = lappend( scan->scan.plan.targetlist, te );
				}
				break;
				
			case T_Aggref:
				aggref = (Aggref *) node;
				
				
				/* ForeignScan->targetlist用 */
				newvar = makeVar( INDEX_VAR,
								  attno,
								  aggref->aggtype,
								  -1,
								  InvalidOid,
								  0 );
				
				newte = makeTargetEntry( (Expr *) newvar,
										 attno,
										 te->resname,
										 te->resjunk );
				
				newte->ressortgroupref = 0;
				
				scan->scan.plan.targetlist = lappend( scan->scan.plan.targetlist, newte );
				
				
				/* ForeignScan->fdw_scan_tlist用 */
				newfste = makeTargetEntry( (Expr *) node,
										   attno,
										   NULL,
										   false );
			
				scan->fdw_scan_tlist = lappend( scan->fdw_scan_tlist, newfste );
			
				break;
				
			/* 以下、処理しません */
			case T_Const:
			case T_Param:
			case T_ArrayRef:
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
				if ( root->parse->commandType == CMD_SELECT )
				{
					elog( NOTICE, "サポート対象外のTargetEntryが含まれているようです。" );
				}
				break;
			}
		attno++;
	}
	
	/* INSERTとUPDATEの場合 */
	if ( root->parse->commandType == CMD_INSERT || root->parse->commandType == CMD_UPDATE )
	{
		preprocess_targetlist2( root->parse, scan );
	}
	
}



/************************************************************
 * create_planned_stmt
 * 入力された情報からPlannedStmtを作成する
 *
 * ■input
 * AltPlannerInfo *root ... alt_plannerで使いまわしたい情報。
 *                          これまでの処理で設定した値などを反映するために使用。
 * Plan *plan           ... ForeignScanプランノードもしくはModifyTableプランノードを
 *                          Planにキャストしたもの。
 *                          stmt->planTreeに設定する。
 * 
 * ■output
 * PlannedStmt *stmt    ... alt_plannerから返却する構造体。
 ************************************************************/

PlannedStmt *
create_planned_stmt( AltPlannerInfo *root, Plan *plan )
{
	PlannedStmt *stmt = makeNode( PlannedStmt );
	Query *parse = root->parse;
	
	/* 初期化 */
	stmt->commandType = parse->commandType;
	stmt->queryId = parse->queryId;
	stmt->hasReturning = false;
	stmt->hasModifyingCTE = false;
	stmt->canSetTag = false;
	stmt->transientPlan = false;
	stmt->dependsOnRole = false;
	stmt->parallelModeNeeded = false;
	stmt->jitFlags = 0;
	stmt->planTree = plan;
	stmt->rtable = parse->rtable;
	stmt->resultRelations = NIL;
	stmt->nonleafResultRelations = NIL;
	stmt->rootResultRelations = NIL;
	stmt->subplans = NIL;
	stmt->rewindPlanIDs = NULL;
	stmt->rowMarks = NIL;
	stmt->relationOids = root->oidlist; 
	stmt->invalItems = NIL;
	stmt->paramExecTypes = NIL; 
	stmt->utilityStmt = parse->utilityStmt;
	stmt->stmt_location = parse->stmt_location;
	stmt->stmt_len = parse->stmt_len;

	
	/* ModifyTableに特有の処理 */
	if ( nodeTag( plan ) == T_ModifyTable )
	{
		/* resultRelationsを作成 */
		List *resultRelations = NIL;
		
		resultRelations = lappend_int( resultRelations, parse->resultRelation );
		stmt->resultRelations = resultRelations;
	}
	
	return stmt;
	
}



/************************************************************
 * preprocess_targetlist
 * INSERTとUPDATEのための処理(preptlist.cと同名の別関数)
 * 
 * ■input
 * Query *parse      ... クエリツリー。
 *                       クエリツリー内部のtargetList, resultRelationなどを使用する。
 * ForeignScan *scan ... この関数を実行した結果、生成されるTargetEntryのリストを
 *                       紐づける関数。
 ************************************************************/
void
preprocess_targetlist2( Query *parse, ForeignScan *scan )
{
	RangeTblEntry	*target_rte = NULL;
	Relation		target_relation = NULL;
	List			*tlist;
	
	/* RangeTblEntryのリストから、Update対象のRangeTblEntryを取得 */
	target_rte = rt_fetch( parse->resultRelation, parse->rtable );
	
	/* 更新対象のリレーションのヒープを開く */
	target_relation = heap_open( target_rte->relid, NoLock );
	
	/* targetListを追加する。 */
	tlist = parse->targetList;
	tlist = expand_targetlist( tlist, parse->commandType, parse->resultRelation, target_relation );
	
	scan->scan.plan.targetlist = tlist;
	
	if ( target_relation )
		heap_close( target_relation, NoLock );

}



/*****************************************************************************
 *
 *		TARGETLIST EXPANSION (preptlist.cから移植しました。)
 *
 *****************************************************************************/

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
				tlist_item = lnext(tlist_item);
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
					elog(ERROR, "unrecognized command_type: %d",
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
		tlist_item = lnext(tlist_item);
	}

	return new_tlist;
}



/************************************************************
 * Module initialization function
 ************************************************************/

void
_PG_init(void)
{
  planner_hook = alt_planner;
}
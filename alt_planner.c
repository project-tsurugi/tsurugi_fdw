/*-------------------------------------------------------------------------
 *
 * alt_planner.c
* 		V0�Ńv�����i�t�b�N(11.1)
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

/* �����܂킵�����������ꊇ�Ǘ��ł���\���� */

typedef struct AltPlannerInfo
{
	Query	*parse;
	
	/* JOIN�����邩 */
	bool	hasjoin;

	/* �W�ϊ֐������邩 */
	bool	hasaggref;
	
	/* �O���T�[�o�I�u�W�F�N�g��OID */
	Oid		serverid;
	
	/* ���͂��ꂽ�N�G���Ɋ֌W�̂���OID�̃��X�g */
	List	*oidlist;
	
} AltPlannerInfo;


PG_MODULE_MAGIC;

extern void _PG_init(void);

extern PGDLLIMPORT planner_hook_type planner_hook;


bool is_only_foreign_table( AltPlannerInfo *root, List *rtable );
AltPlannerInfo *init_altplannerinfo( Query *parse );
ForeignScan *create_foreign_scan( AltPlannerInfo *root ); /* ForeignScan�v�����m�[�h�̏����� */
ModifyTable *create_modify_table( AltPlannerInfo *root, ForeignScan *scan ); /* ModifyTable�v�����m�[�h�̏����� */
void is_valid_targetentry( ForeignScan *scan, AltPlannerInfo *root ); /* fdw_scan_tlsit��targetlist�̓\��t��(JOIN, Aggref�̂�) */
PlannedStmt *create_planned_stmt( AltPlannerInfo *root, Plan *plan );
void preprocess_targetlist2( Query *parse, ForeignScan *scan );
static List *expand_targetlist( List *tlist, int command_type, Index result_relation, Relation rel );



/************************************************************
 * alt_planner
 * ����ǉ�����v�����i(V0)
 * 
 * ��input
 * Query *parse2             ... �����C�g�܂ł��I�����p�[�X�c���[
 * int cursorOptions         ... 
 * ParamListInfo boundParams ... 
 * 
 * ��output
 * PlannedStmt stmt          ... �v�����c���[���܂�PlannedStmt�\����
 ************************************************************/
struct PlannedStmt *
alt_planner( Query *parse2, int cursorOptions, ParamListInfo boundParams )
{
	/* �ϐ��錾 */
	Query *parse = copyObject(parse2);
	
	AltPlannerInfo *root = init_altplannerinfo(parse);
	ForeignScan *scan = 0;
	Plan *plan = 0;

	
	/*
	 * ����Ώۂ�SQL�R�}���h���ǂ����ɉ����ď������s��
	 * SQL���Ɋ܂܂��I�u�W�F�N�g�����ׂē���T�[�o���RangeTblEntry�ł��邱�Ƃ��m�F
	 */
	if ( !is_only_foreign_table( root, root->parse->rtable ) )
	{
		return standard_planner( parse2, cursorOptions, boundParams );
	}
	
	
	/*
	 * �W�ϊ֐��̏��������݂��邩���m�F
	 */
	if ( parse->hasAggs )
	{
		root->hasaggref = true;
	}
	
	
	/*
	 * �R�}���h�ɉ��������������{
	 */
	
	switch ( parse->commandType )
	{
	case CMD_SELECT:

		/* v0�łł͈Öق�JOIN�̓T�|�[�g�ΏۊO�ł����ꉞ*/
		if ( root->oidlist->length > 1 && !root->hasjoin )
		{
			root->hasjoin = true;
			elog( NOTICE, "�Öق�JOIN�͑ΏۊO�ł�(���͒ʂ��܂����B)" );
		}
		
		scan = create_foreign_scan( root );
		
		plan = (Plan *) scan;
		
		break;
		
	case CMD_INSERT:
	case CMD_UPDATE:
	case CMD_DELETE:

		/* PostgreSQL�Ǝ����@�Ƃ��āAUPDATE����DELETE����FROM�傪�t���ꍇ������܂��B */
		/* ���̏ꍇ�Aroot->oidlist��2�ȏ�̐��l���v�コ��邱�ƂɂȂ邽�߁A���̂悤�ȕ��@�͑��������I�ɃG���[�Ƃ��܂��B */
		if(root->oidlist->length > 1 && (parse->commandType == CMD_DELETE || parse->commandType == CMD_UPDATE))
		{
			elog(NOTICE, "PostgreSQL�Ǝ����@�ł��B(UPDATE��������DELETE�ł�FROM��̎g�p)");
		}
		
		scan = create_foreign_scan( root );
		ModifyTable *modify = create_modify_table( root, scan );
		
		plan = (Plan *) modify;
		
		break;
		
	default:
		return standard_planner( parse2, cursorOptions, boundParams );
	}
	
	/* PlannedStmt�̐��� */
	
	PlannedStmt *stmt = create_planned_stmt( root, plan );
	
	/* �ŏI�I�ɐ�������PlannedStmt��ԋp���� */
	return stmt;

}



/************************************************************
 * init_altplannerinfo
 * alt_planner�̎��s���ɕێ����Ă���������������������
 * 
 * ��input
 * Query *parse         ... alt_planner�̓��͂ɂ�����p�[�X�c���[
 *                          ���O��copyObject�֐��ŃR�s�[�������̂������Ƃ��Ďg�p����B
 * 
 * ��output
 * AltPlannerInfo *root ... �p�[�X�c���[(�̃R�s�[)��A�O���T�[�o��OID���A
 *                          alt_planner���s���Ɏg���܂킵�����������߂��\���̂�
 *                          �������������́B
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
 * �����O���T�[�o��ɑ��݂��郊���[�V�������m�̃N�G���ł��邩�A
 * �܂��A��XPlannedStmt->relationOids�ɒǉ����邽�߁Aoidlist��
 * ��������B
 * 
 * ��input
 * AltPlannerInfo *root ... alt_planner���Ŏg���܂킵�������B
 *                          �{�֐����ŁAroot->serverid(�O���T�[�o��OID)�̎擾��
 *                          root->oidlist(�O���\�I�u�W�F�N�g��OID�̃��X�g)�̐������s���B
 * List *rtable         ... �`�F�b�N����RangeTblEntry�̃��X�g
 *                          root�ɂ��܂܂��v�f�ł͂��邪�A�ċA�ďo�������������ߌʂ�
 *                          RangeTblEntry�̃��X�g�����͂���B
 *
 * ��output
 * bool                 ... alt_planner�ł̏����Ώۂł����true���A
 *                          �ΏۊO�ł����false��ԋp����B
 *                          �����_�ł́ASQL�Ɋ܂܂��\�����ׂĊO���\�ł����true�ƂȂ�B
 ************************************************************/

bool 
is_only_foreign_table( AltPlannerInfo *root, List *rtable )
{
	ListCell	*rtable_list_cell;
	Oid			currentserverid;

	foreach( rtable_list_cell, rtable )
	{
		/* ���o���p��RangeTblEntry��錾 */
		RangeTblEntry	*range_table_entry;
		
		/* RangeTblEntry�����o�� */
		range_table_entry = lfirst_node( RangeTblEntry, rtable_list_cell );
		
		/* �`�F�b�N */
		
		switch ( range_table_entry->rtekind )
		{
		case RTE_RELATION:
			/* �O���\�̏ꍇ�́A�O���T�[�o��Oid���擾����B�S�Ẵ����[�V�����œ���O���T�[�o���A�N�Z�X���Ă��邩�𔻒肷�� */
			if ( range_table_entry->relkind == 'f' )
			{
				/* ���݃`�F�b�N���Ă���RTE�̊O���T�[�o��OID���l�� */
				currentserverid = GetForeignServerIdByRelId( range_table_entry->relid );
				
				/* OID��oidlist�ɒǉ� */
				root->oidlist = lappend_oid( root->oidlist, range_table_entry->relid );
				

				/* �قȂ�T�[�o��̃I�u�W�F�N�g�����݂��Ă��Ȃ������`�F�b�N */
				if ( root->serverid == 0 )
				{
					root->serverid = currentserverid;
					break;
				}
				else if ( root->serverid != currentserverid )
				{
					elog( NOTICE, "�قȂ��ނ̃T�[�o�����݂��Ă��܂�" );
					return false;
				}
			}
			
			/* �����[�V�������O���\�ȊO�̏ꍇ�͏����ΏۊO�Ƃ��� */
			else
			{
				return false;
			}
			
			break;
		
		case RTE_SUBQUERY:
		
			/* ������SUBQUERY�ȊO���O����(VIEW�Ȃǂ͏��O����) */
			if ( range_table_entry->relkind != 0 || range_table_entry->subquery==0 )
			{
				return false;
			}
			else
			{
				/* �T�u�N�G������RTE��is_only_foreign_table�ɂ�����(�ċA) */
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
			
			/* JOIN��𖾎��I�Ɏg�p�����ꍇ�AJOIN�ł��邱�Ƃ�����RTE�������B
			   �������A�����I�ɂقڋ�ȃn�Y�Ȃ̂ŁA���ɂ���ƌ����������͂��Ȃ��B
			*/
			
			if( !root->hasjoin )
			{
				root->hasjoin = true;
			}
			
			break;
			
		/* �ȉ��A�����ΏۊO�Ƃ��܂��B */
		case RTE_CTE:
		case RTE_FUNCTION:
		case RTE_TABLEFUNC:
		case RTE_VALUES:
		case RTE_NAMEDTUPLESTORE:
			return false;
			break;
		}
		
	} /* foreach�I�� */
	
	/* �Ō�܂Ŕ����邱�Ƃ��ł����OK */
	return true;
}



/************************************************************
 * create_foreign_scan
 * ForeignScan�\���̂𐶐�����
 * SQL�R�}���h�ɂ���ĈقȂ�targetlist, fdw_scan_tlist�ɂ��ẮA
 * ���̊֐�����Ăяo�����is_valid_targetentry�֐���ʂ��Đݒ肷��B
 * 
 * ��input
 * AltPlannerInfo *root ... alt_planner���Ŏg���܂킵�������B
 *                          ���̊֐��ł́Aroot->parse���̏��ƁAroot->serverid���g�p����B
 *
 * ��output
 * ForeignScan *fnode   ... �쐬����ForeignScan�v�����m�[�h�B
 *                          �P����SELECT�������s�����ꍇ�Ɠ����̓��e�ƂȂ�悤�e�l��ݒ肵�Ă���B
 ************************************************************/

ForeignScan *
create_foreign_scan( AltPlannerInfo *root )
{
	
	/* ������ */
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

	/* fs_relids�̐ݒ� */
	/* �P��\��SCAN�ƌ��Ȃ����߁Afs_relids��1�������Ă���Bitmapset�Ƃ��܂� */
	Bitmapset  *fs_relids = NULL;
	fs_relids = bms_add_member( fs_relids, 1 );
	fnode->fs_relids = fs_relids;
	
	/* scan.plan.targetlist�����fdw_scan_tlist�̐ݒ� */
	is_valid_targetentry( fnode, root );
	
	/* scanrelid�̐ݒ� */
	/* JOIN�������݂���ꍇ��0�ɕύX */
	if(root->hasjoin || root->hasaggref)
	{
		fnode->scan.scanrelid = 0;
	}
	
	return fnode;
}



/************************************************************
 * create_modify_table
 * ModifyTable�\���̂𐶐�����
 * 
 * ��input
 * AltPlannerInfo *root ... alt_planner���Ŏg���܂킵�������B
 *                          root->parse���̏����g�p����B
 * ForeignScan *scan    ... ModifyTable�ɕR�Â���ForeignScan�v�����m�[�h�B
 *                          ���̊֐��ɓ���O�ɍ쐬�ς݂ł���O��B
 * 
 * ��output
 * ModifyTable *modify  ... INSERT, DELETE, UPDATE���ŕK�v�ƂȂ�ModifyTable�v�����m�[�h�B
 *                          Executor��DirectModify�ɓ���悤�Ɋe���ڂ�ݒ肵�Ă���B
 ************************************************************/
 
ModifyTable *
create_modify_table( AltPlannerInfo *root, ForeignScan *scan )
{
	ModifyTable *modify = makeNode( ModifyTable );

	/* ForeignScan�v�����m�[�h��List�� */
	List *subplan = NIL;
	
	subplan = lappend( subplan, scan );
	
	
	/* ������ */
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
	/* ON CONFLICT��̎w�肪����ꍇ�͍l�����K�v�ȍ���(V0�ł̍l���͖���) */
	modify->onConflictAction = ONCONFLICT_NONE;
	modify->onConflictSet = NIL;
	modify->onConflictWhere = NULL;
	modify->arbiterIndexes = NIL;
	modify->exclRelRTI = 0;
	modify->exclRelTlist = NIL;

	
	
	/* modify->fdwPrivLists�̎w��B�������e�̂Ȃ�T_List */
	List *fdwPrivLists = NIL;
	fdwPrivLists = lappend( fdwPrivLists, 0 );
	
	modify->fdwPrivLists = fdwPrivLists;
	
	
	/* modify->fdwDirectModifyPlans�̎w��BBitmapset��ǉ��B */
	Bitmapset  *direct_modify_plans = NULL;
	direct_modify_plans = bms_add_member( direct_modify_plans, 0 );
	
	modify->fdwDirectModifyPlans = direct_modify_plans;
	
	
	return modify;
}



/************************************************************
 * is_valid_targetentry
 * SELECT, DELETE�p (���̂Ƃ����肪�N���Ȃ��̂�Var��Aggref�̂�)
 * INSERT, UPDATE�p (���̊֐��ɏ������ڂ�)
 * 
 * ��input
 * ForeignScan *scan    ... ���̊֐��ō쐬����TargetEntry�̃��X�g��
 *                          �R�Â���ForeignScan�v�����m�[�h
 * AltPlannerInfo *root ... 
 * 
 * ��output
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
	
	/* ForeignScan->targetlist�p */
	TargetEntry *newte = NULL;
	
	/* fdw_scan_tlist�p */
	TargetEntry *newfste = NULL;
	
	/* ���͂��ꂽTargetEntry���`�F�b�N */
	
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
					/* ForeignScan->fdw_scan_tlist�p */
					newfste = makeTargetEntry( (Expr *) node,
											   attno,
											   NULL,
											   te->resjunk );
					
					scan->fdw_scan_tlist = lappend( scan->fdw_scan_tlist, newfste );
					
					
					/* ForeignScan->targetlist�p */
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
				else /* �P���ɗ���w�肵���ꍇ */
				{
					scan->scan.plan.targetlist = lappend( scan->scan.plan.targetlist, te );
				}
				break;
				
			case T_Aggref:
				aggref = (Aggref *) node;
				
				
				/* ForeignScan->targetlist�p */
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
				
				
				/* ForeignScan->fdw_scan_tlist�p */
				newfste = makeTargetEntry( (Expr *) node,
										   attno,
										   NULL,
										   false );
			
				scan->fdw_scan_tlist = lappend( scan->fdw_scan_tlist, newfste );
			
				break;
				
			/* �ȉ��A�������܂��� */
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
					elog( NOTICE, "�T�|�[�g�ΏۊO��TargetEntry���܂܂�Ă���悤�ł��B" );
				}
				break;
			}
		attno++;
	}
	
	/* INSERT��UPDATE�̏ꍇ */
	if ( root->parse->commandType == CMD_INSERT || root->parse->commandType == CMD_UPDATE )
	{
		preprocess_targetlist2( root->parse, scan );
	}
	
}



/************************************************************
 * create_planned_stmt
 * ���͂��ꂽ��񂩂�PlannedStmt���쐬����
 *
 * ��input
 * AltPlannerInfo *root ... alt_planner�Ŏg���܂킵�������B
 *                          ����܂ł̏����Őݒ肵���l�Ȃǂ𔽉f���邽�߂Ɏg�p�B
 * Plan *plan           ... ForeignScan�v�����m�[�h��������ModifyTable�v�����m�[�h��
 *                          Plan�ɃL���X�g�������́B
 *                          stmt->planTree�ɐݒ肷��B
 * 
 * ��output
 * PlannedStmt *stmt    ... alt_planner����ԋp����\���́B
 ************************************************************/

PlannedStmt *
create_planned_stmt( AltPlannerInfo *root, Plan *plan )
{
	PlannedStmt *stmt = makeNode( PlannedStmt );
	Query *parse = root->parse;
	
	/* ������ */
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

	
	/* ModifyTable�ɓ��L�̏��� */
	if ( nodeTag( plan ) == T_ModifyTable )
	{
		/* resultRelations���쐬 */
		List *resultRelations = NIL;
		
		resultRelations = lappend_int( resultRelations, parse->resultRelation );
		stmt->resultRelations = resultRelations;
	}
	
	return stmt;
	
}



/************************************************************
 * preprocess_targetlist
 * INSERT��UPDATE�̂��߂̏���(preptlist.c�Ɠ����̕ʊ֐�)
 * 
 * ��input
 * Query *parse      ... �N�G���c���[�B
 *                       �N�G���c���[������targetList, resultRelation�Ȃǂ��g�p����B
 * ForeignScan *scan ... ���̊֐������s�������ʁA���������TargetEntry�̃��X�g��
 *                       �R�Â���֐��B
 ************************************************************/
void
preprocess_targetlist2( Query *parse, ForeignScan *scan )
{
	RangeTblEntry	*target_rte = NULL;
	Relation		target_relation = NULL;
	List			*tlist;
	
	/* RangeTblEntry�̃��X�g����AUpdate�Ώۂ�RangeTblEntry���擾 */
	target_rte = rt_fetch( parse->resultRelation, parse->rtable );
	
	/* �X�V�Ώۂ̃����[�V�����̃q�[�v���J�� */
	target_relation = heap_open( target_rte->relid, NoLock );
	
	/* targetList��ǉ�����B */
	tlist = parse->targetList;
	tlist = expand_targetlist( tlist, parse->commandType, parse->resultRelation, target_relation );
	
	scan->scan.plan.targetlist = tlist;
	
	if ( target_relation )
		heap_close( target_relation, NoLock );

}



/*****************************************************************************
 *
 *		TARGETLIST EXPANSION (preptlist.c����ڐA���܂����B)
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
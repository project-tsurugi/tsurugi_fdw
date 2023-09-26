/*
 * Copyright 2023 tsurugi project.
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
 *	@file	prepare_execute.cpp
 *	@brief  Dispatch the prepare command to ogawayama.
 */

#include <iostream>
#include <map>
#include <string>
#include <vector>

#include "manager/metadata/metadata_factory.h"
#include "ogawayama/stub/api.h"
#include "tsurugi.h"

#ifdef __cplusplus
extern "C" {
#endif

#include "postgres.h"
#include "catalog/pg_type.h"
#include "commands/prepare.h"
#include "lib/stringinfo.h"
#include "nodes/parsenodes.h"
#include "parser/parse_type.h"

#ifdef __cplusplus
}
#endif

#include "prepare_execute.h"

using namespace ogawayama;

PreparedStatementPtr prepared_statement;
stub::parameters_type parameters{};

std::map<std::string, PreparedStatementPtr> stored_prepare_statment;
std::map<std::string, std::vector<Oid>> stored_argtypes;

bool deparse_where_clause(Node* expr, const Oid* argtypes, stub::placeholders_type& placeholders, StringInfo buf);
bool deparse_expr_recurse(Node* expr, const Oid* argtypes, stub::placeholders_type& placeholders, std::string& col_name, StringInfo buf);
void deparse_execute_where_clause(const Node* expr, const ExecuteStmt* stmts);
bool deparse_execute_expr_recurse(Node* expr, std::string& col_name, const ExecuteStmt* stmts);
void deparse_select_query(const SelectStmt* stmt, const Oid* argtypes, stub::placeholders_type& placeholders, StringInfo buf);

void
get_tsurugi_table_join_expr(JoinExpr* join,
							std::vector<std::string>& target_tables)
{
	switch (nodeTag(join->larg))
	{
		case T_RangeVar:
			{
				RangeVar* relation = (RangeVar *) join->larg;
				target_tables.emplace_back(relation->relname);
			}
			break;
		case T_JoinExpr:
			{
				get_tsurugi_table_join_expr((JoinExpr *)join->larg, target_tables);
			}
			break;
		default:
			/* should not reach here */
			elog(ERROR, "unsupported join larg %d", (int) nodeTag(join->larg));
			break;
	}

	if (IsA(join->rarg, RangeVar)) {
		RangeVar* relation = (RangeVar *) join->rarg;
		target_tables.emplace_back(relation->relname);
	}
}

/**
 *  @brief Tsurugi OLTP table exist in the target relation.
 *  @param [in] query
 *  @return true if Tsurugi OLTP table exists.
 */
bool
is_tsurugi_table(Node* query,
				 bool show_warning)
{
	bool result = false;
	bool is_tsurugi = false;
	bool is_not_tsurugi = false;
	std::vector<std::string> target_tables;

	switch (nodeTag(query))
	{
		case T_InsertStmt:
			{
				InsertStmt* stmt = (InsertStmt *) query;
				target_tables.emplace_back(stmt->relation->relname);
			}
			break;
		case T_UpdateStmt:
			{
				UpdateStmt* stmt = (UpdateStmt *) query;
				target_tables.emplace_back(stmt->relation->relname);
			}
			break;
		case T_DeleteStmt:
			{
				DeleteStmt* stmt = (DeleteStmt *) query;
				target_tables.emplace_back(stmt->relation->relname);
			}
			break;
		case T_SelectStmt:
			{
				SelectStmt* stmt = (SelectStmt *) query;
				ListCell* l;
				foreach(l, stmt->fromClause)
				{
					Node* from = (Node *) lfirst(l);
					if (IsA(from, RangeVar)) {
						RangeVar* relation = (RangeVar *) from;
						target_tables.emplace_back(relation->relname);
					}
					if (IsA(from, JoinExpr)) {
						get_tsurugi_table_join_expr((JoinExpr *) from, target_tables);
					}
				}
			}
			break;
		default:
			/* should not reach here */
			elog(ERROR, "is_tsurugi_table: unrecognized node type: %d",
				 (int) nodeTag(query));
			return result;
	}

	auto tables = manager::metadata::get_tables_ptr("Tsurugi");
	for(std::size_t i = 0; i < target_tables.size(); i++) {
		if (tables->exists(target_tables[i])) {
			is_tsurugi = true;
		} else {
			is_not_tsurugi = true;
		}
	}

	if (is_tsurugi) {
		if (is_not_tsurugi) {
			if (show_warning) {
				elog(WARNING,
					"If Tsurugi and non-Tsurugi tables are mixed, do not PREPARE to Tsurugi");
			}
		} else {
			result = true;
		}
	}

	return result;
}

/**
 *  @brief Transform list of TypeNames to array of type OIDs.
 *  @param [in] list of TypeNames
 *  @param [in] query String
 *  @return pointer to array of type OIDs.
 */
Oid*
transform_typenames_to_oids(const List* argtypes,
							std::vector<Oid>& argtypes_v,
							const char* queryString)
{
	Oid* argoids = nullptr;
	int nargs;
	int i;

	nargs = list_length(argtypes);
	if (nargs)
	{
		ParseState* pstate;
		ListCell* l;

		/*
		 * typenameTypeId wants a ParseState to carry the source query string.
		 * Is it worth refactoring its API to avoid this?
		 */
		pstate = make_parsestate(nullptr);
		pstate->p_sourcetext = queryString;

		argoids = (Oid *) palloc(nargs * sizeof(Oid));
		i = 0;

		foreach(l, argtypes)
		{
			TypeName* tn = (TypeName *)lfirst(l);
			Oid toid = typenameTypeId(pstate, tn);

			argoids[i++] = toid;
			argtypes_v.push_back(toid);
		}
	}

	return argoids;
}

void
deparse_query_columns(const List* cols,
					   std::vector<std::string>& col_names,
					   StringInfo buf)
{
	bool first = true;
	ListCell* lc;

	appendStringInfoChar(buf, '(');
	foreach(lc, cols)
	{
		ResTarget* col = lfirst_node(ResTarget, lc);
		if (!first)
			appendStringInfoString(buf, ", ");
		first = false;
		appendStringInfo(buf, "%s", col->name);
		col_names.push_back(col->name);
	}
	appendStringInfoChar(buf, ')');
}

bool
deparse_value_paramref(const ParamRef* param,
					   const Oid* argtypes,
					   std::string col_name,
					   stub::placeholders_type& placeholders,
					   StringInfo buf)
{
	bool result{true};
	int num = param->number;
	col_name += "_" + std::to_string(num);
	appendStringInfo(buf, ":%s", col_name.c_str());

	switch (argtypes[num-1])
	{
		case INT2OID:
			placeholders.emplace_back(col_name,
							stub::Metadata::ColumnType::Type::INT16);
			break;
		case INT4OID:
			placeholders.emplace_back(col_name,
							stub::Metadata::ColumnType::Type::INT32);
			break;
		case INT8OID:
			placeholders.emplace_back(col_name,
							stub::Metadata::ColumnType::Type::INT64);
			break;
		case FLOAT4OID:
			placeholders.emplace_back(col_name,
							stub::Metadata::ColumnType::Type::FLOAT32);
			break;
		case FLOAT8OID:
			placeholders.emplace_back(col_name,
							stub::Metadata::ColumnType::Type::FLOAT64);
			break;
		case BPCHAROID:
		case VARCHAROID:
		case TEXTOID:
			placeholders.emplace_back(col_name,
							stub::Metadata::ColumnType::Type::TEXT);
			break;
		case DATEOID:
			placeholders.emplace_back(col_name,
							stub::Metadata::ColumnType::Type::DATE);
			break;
		case TIMEOID:
			placeholders.emplace_back(col_name,
							stub::Metadata::ColumnType::Type::TIME);
			break;
		case TIMESTAMPOID:
			placeholders.emplace_back(col_name,
							stub::Metadata::ColumnType::Type::TIMESTAMP);
			break;
		case TIMETZOID:
			placeholders.emplace_back(col_name,
							stub::Metadata::ColumnType::Type::TIMETZ);
			break;
		case TIMESTAMPTZOID:
			placeholders.emplace_back(col_name,
							stub::Metadata::ColumnType::Type::TIMESTAMPTZ);
			break;
		case NUMERICOID:
			placeholders.emplace_back(col_name,
							stub::Metadata::ColumnType::Type::DECIMAL);
			break;
		default:
			/* should not reach here */
			elog(ERROR, "unrecognized type oid: %d",
				 (int) argtypes[num-1]);
			result = false;
			break;
	}

	return result;
}

bool
deparse_value_ref(const Node* value,
				  const Oid* argtypes,
				  const std::vector<std::string>& col_names,
				  stub::placeholders_type& placeholders,
				  StringInfo buf)
{
	bool result{true};

	switch (nodeTag(value))
	{
		case T_ParamRef:
			{
				ParamRef* param_ref = (ParamRef *)value;
				int param_num = param_ref->number;
				std::string col_name = col_names[param_num-1];
				deparse_value_paramref((ParamRef *)value, argtypes, col_name, placeholders, buf);
			}
			break;
		case T_A_Const:
			{
				A_Const* con = (A_Const *)value;
				Value* val = &con->val;
				switch (nodeTag(val))
				{
					case T_Integer:
						appendStringInfo(buf, "%d", intVal(val));
						break;
					case T_Float:
						appendStringInfo(buf, "%f", floatVal(val));
						break;
					case T_String:
						appendStringInfo(buf, "\'%s\'", strVal(val));
						break;
					default:
						/* should not reach here */
						elog(ERROR, "value_ref: unrecognized a_const value node type: %d",
							 (int) nodeTag(value));
						result = false;
						return result;
				}
			}
			break;
		default:
			/* should not reach here */
			elog(ERROR, "unrecognized value node type: %d",
				 (int) nodeTag(value));
			result = false;
			return result;
	}

	return result;
}

bool
deparse_values_lists(const List* valuesLists,
					 const Oid* argtypes,
					 std::vector<std::string>& col_names,
					 stub::placeholders_type& placeholders,
					 StringInfo buf)
{
	bool result{true};
	bool first_list = true;
	ListCell* vtl;
	foreach(vtl, valuesLists)
	{
		List* values = (List *) lfirst(vtl);
		bool first_col = true;
		int col_names_pos = 0;
		ListCell* lc;

		if (first_list)
			first_list = false;
		else
			appendStringInfoString(buf, ", ");

		appendStringInfoChar(buf, '(');
		foreach(lc, values)
		{
			Node* value = (Node *) lfirst(lc);

			if (!first_col)
				appendStringInfoString(buf, ", ");
			first_col = false;

			result = deparse_value_ref(value, argtypes, col_names, placeholders, buf);
			if (result == false) {
				return result;
			}
			if (IsA(value, A_Const)) {
				col_names.erase(col_names.begin() + col_names_pos);
			}
			col_names_pos++;
		}
		appendStringInfoChar(buf, ')');
	}

	return result;
}

char *
deparse_column_ref(ColumnRef* cref,
				   char* alias,
				   StringInfo buf)
{
	char* result;

	/*----------
	 * The allowed syntaxes are:
	 *
	 * A		First try to resolve as unqualified column name;
	 *			if no luck, try to resolve as unqualified table name (A.*).
	 * A.B		A is an unqualified table name; B is either a
	 *			column or function name (trying column name first).
	 * A.B.C	schema A, table B, col or func name C.
	 * A.B.C.D	catalog A, schema B, table C, col or func D.
	 * A.*		A is an unqualified table name; means whole-row value.
	 * A.B.*	whole-row value of table B in schema A.
	 * A.B.C.*	whole-row value of table C in schema B in catalog A.
	 *
	 * We do not need to cope with bare "*"; that will only be accepted by
	 * the grammar at the top level of a SELECT list, and transformTargetList
	 * will take care of it before it ever gets here.  Also, "A.*" etc will
	 * be expanded by transformTargetList if they appear at SELECT top level,
	 * so here we are only going to see them as function or operator inputs.
	 *
	 * Currently, if a catalog name is given then it must equal the current
	 * database name; we check it here and then discard it.
	 *----------
	 */
	switch (list_length(cref->fields))
	{
		case 1:
			{
				Node* field1 = (Node*) linitial(cref->fields);
				if (IsA(field1, A_Star)) {
					if (buf != NULL) {
						appendStringInfoString(buf, "*");
					}
				} else if (IsA(field1, String)) {
					if (buf != NULL) {
						appendStringInfo(buf, "%s", strVal(field1));
					}
					result = strVal(field1);
					if (alias != NULL) {
						if (buf != NULL) {
							appendStringInfo(buf, " AS %s", alias);
						}
					}
				}
			}
			break;
		case 2:
			{
				Node* field1 = (Node*) linitial(cref->fields);
				Node* field2 = (Node*) lsecond(cref->fields);
				if (IsA(field2, A_Star)) {
					if (buf != NULL) {
						appendStringInfo(buf, "%s.*", strVal(field1));
					}
				} else if (IsA(field2, String)) {
					if (buf != NULL) {
						appendStringInfo(buf, "%s.%s", strVal(field1),
														strVal(field2));
					}
					result = strVal(field2);
					if (alias != NULL) {
						if (buf != NULL) {
							appendStringInfo(buf, " AS %s", alias);
						}
					}
				}
			}
			break;
		case 3:
			{
				Node* field3 = (Node*) lthird(cref->fields);
				Assert(IsA(field3, String));
				result = strVal(field3);
				break;
			}
		case 4:
			{
				Node* field4 = (Node*) lfourth(cref->fields);
				Assert(IsA(field4, String));
				result = strVal(field4);
				break;
			}
		default:
			/* should not reach here */
			elog(ERROR, "improper qualified name (too many dotted names)");
			break;
	}

	return result;
}

bool
deparse_a_const(Value* value,
				StringInfo buf)
{
	bool result{true};

	switch (nodeTag(value))
	{
		case T_Integer:
			if (buf != NULL) {
				appendStringInfo(buf, "%d ", intVal(value));
			}
			break;
		case T_Float:
			if (buf != NULL) {
				appendStringInfo(buf, "%f ", floatVal(value));
			}
			break;
		case T_String:
			if (buf != NULL) {
				appendStringInfo(buf, "\'%s\' ", strVal(value));
			}
			break;
		default:
			/* should not reach here */
			elog(ERROR, "unrecognized a_const node type: %d", (int) nodeTag(value));
			result = false;
			break;
	}

	return result;
}

bool
deparse_aexpr_op(A_Expr* a,
			     const Oid* argtypes,
			     stub::placeholders_type& placeholders,
				 StringInfo buf)
{
	Node* lexpr = a->lexpr;
	Node* rexpr = a->rexpr;
	std::string col_name;
	bool result{true};

	result = deparse_expr_recurse(lexpr, argtypes, placeholders, col_name, buf);
	if (result != true) {
		return result;
	}

	switch (list_length(a->name))
	{
		case 1:
			appendStringInfo(buf, " %s ", strVal(linitial(a->name)));
			break;
		default:
			/* should not reach here */
			elog(ERROR, "deparse_aexpr_op: list_length = %d", list_length(a->name));
			result = false;
			break;
	}

	result = deparse_expr_recurse(rexpr, argtypes, placeholders, col_name, buf);

	return result;
}

bool
deparse_aexpr_between(A_Expr* a,
			     const Oid* argtypes,
			     stub::placeholders_type& placeholders,
				 StringInfo buf)
{
	Node* lexpr = a->lexpr;
	List* rexpr = (List *) a->rexpr;
	std::string col_name;
	bool result{true};

	result = deparse_expr_recurse(lexpr, argtypes, placeholders, col_name, buf);
	if (result != true) {
		return result;
	}

	switch (list_length(a->name))
	{
		case 1:
			appendStringInfo(buf, " %s ", strVal(linitial(a->name)));
			break;
		default:
			/* should not reach here */
			elog(ERROR, "deparse_aexpr_between: list_length = %d", list_length(a->name));
			result = false;
			break;
	}

	ListCell   *lc;
	int name_num = 0;
	const char* sep = "";
	foreach(lc, rexpr)
	{
		Node* expr = (Node *) lfirst(lc);
		std::string name = col_name + std::to_string(name_num);
		appendStringInfoString(buf, sep);
		result = deparse_expr_recurse(expr, argtypes, placeholders, name, buf);
		if (result != true) {
			return result;
		}
		sep = "AND ";
	}

	return result;
}

bool
deparse_aexpr_like(A_Expr* a,
			     const Oid* argtypes,
			     stub::placeholders_type& placeholders,
				 StringInfo buf)
{
	Node* lexpr = a->lexpr;
	Node* rexpr = a->rexpr;
	std::string col_name;
	bool result{true};

	result = deparse_expr_recurse(lexpr, argtypes, placeholders, col_name, buf);
	if (result != true) {
		return result;
	}

	switch (list_length(a->name))
	{
		case 1:
//			appendStringInfo(buf, "%s ", strVal(linitial(a->name)));
			appendStringInfoString(buf, " LIKE ");
			break;
		default:
			/* should not reach here */
			elog(ERROR, "deparse_aexpr_op: list_length = %d", list_length(a->name));
			result = false;
			break;
	}

	result = deparse_expr_recurse(rexpr, argtypes, placeholders, col_name, buf);
	if (result != true) {
		return result;
	}

	return result;
}

bool
deparse_aexpr_in(A_Expr* a,
			     const Oid* argtypes,
			     stub::placeholders_type& placeholders,
				 StringInfo buf)
{
	Node* lexpr = a->lexpr;
	List* rexpr = (List *) a->rexpr;
	std::string col_name;
	bool result{true};

	result = deparse_expr_recurse(lexpr, argtypes, placeholders, col_name, buf);
	if (result != true) {
		return result;
	}

	switch (list_length(a->name))
	{
		case 1:
//			appendStringInfo(buf, "%s ", strVal(linitial(a->name)));
			appendStringInfoString(buf, " IN ");
			break;
		default:
			/* should not reach here */
			elog(ERROR, "deparse_aexpr_between: list_length = %d", list_length(a->name));
			result = false;
			break;
	}

	ListCell   *lc;
	int name_num = 0;
	const char* sep = "";
	appendStringInfoString(buf, "(");
	foreach(lc, rexpr)
	{
		Node* expr = (Node *) lfirst(lc);
		std::string name = col_name + std::to_string(name_num);
		appendStringInfoString(buf, sep);
		result = deparse_expr_recurse(expr, argtypes, placeholders, name, buf);
		if (result != true) {
			return result;
		}
		sep = ", ";
	}
	appendStringInfoString(buf, ")");

	return result;
}

bool
deparse_bool_expr(BoolExpr* a,
				  const Oid* argtypes,
				  stub::placeholders_type& placeholders,
				  StringInfo buf)
{
	const char* opname;
	ListCell   *lc;
	bool result{true};

	switch (a->boolop)
	{
		case AND_EXPR:
			opname = "AND";
			break;
		case OR_EXPR:
			opname = "OR";
			break;
		case NOT_EXPR:
			opname = "NOT";
			break;
		default:
			/* should not reach here */
			elog(ERROR, "deparse_bool_expr: unrecognized boolop: %d", (int) a->boolop);
			result = false;
			return result;
	}

	bool set_opname{false};
	foreach(lc, a->args)
	{
		Node* arg = (Node *) lfirst(lc);
		result = deparse_where_clause(arg, argtypes, placeholders, buf);
		if (result != true) {
			return result;
		}
		if (set_opname != true) {
			appendStringInfo(buf, " %s ", opname);
			set_opname = true;
		}
	}

	return result;
}

bool
deparse_expr_recurse(Node* expr,
					 const Oid* argtypes,
					 stub::placeholders_type& placeholders,
					 std::string& col_name,
					 StringInfo buf)
{
	bool result{true};

	switch (nodeTag(expr))
	{
		case T_ColumnRef:
			col_name = deparse_column_ref((ColumnRef*) expr, NULL, buf);
			break;

		case T_A_Const:
			{
				A_Const* con = (A_Const *) expr;
				Value* val = &con->val;
				result = deparse_a_const(val, buf);
				break;
			}

		case T_ParamRef:
			{
				deparse_value_paramref((ParamRef *)expr, argtypes, col_name, placeholders, buf);
				break;
			}

		case T_A_Expr:
			{
				A_Expr* a = (A_Expr *) expr;
				switch (a->kind)
				{
					case AEXPR_OP:
						result = deparse_aexpr_op(a, argtypes, placeholders, buf);
						break;
					case AEXPR_BETWEEN:
						result = deparse_aexpr_between(a, argtypes, placeholders, buf);
						break;
					case AEXPR_LIKE:
						result = deparse_aexpr_like(a, argtypes, placeholders, buf);
						break;
					case AEXPR_IN:
						result = deparse_aexpr_in(a, argtypes, placeholders, buf);
						break;
					default:
						/* should not reach here */
						elog(ERROR, "unrecognized A_Expr kind: %d", a->kind);
						result = false;
						break;
				}
				break;
			}

		case T_BoolExpr:
			result = deparse_bool_expr((BoolExpr*) expr, argtypes, placeholders, buf);
			break;

		case T_SubLink:
			{
				SubLink* sub_link = (SubLink *) expr;
				appendStringInfoString(buf, "EXISTS (");
				deparse_select_query((SelectStmt*) sub_link->subselect, argtypes, placeholders, buf);
				appendStringInfoString(buf, ")");
			}
			break;

		case T_FuncCall:
			{
				FuncCall* func = (FuncCall *) expr;
				ListCell* l;
				foreach(l, func->funcname){
					Node* name = (Node *) lfirst(l);
					if (IsA(name, String)) {
						appendStringInfo(buf, "%s", strVal(name));
					}
				}
				appendStringInfoChar(buf, '(');
				foreach(l, func->args){
					Node* args = (Node *) lfirst(l);
					if (IsA(args, ColumnRef)) {
						deparse_column_ref((ColumnRef*) args, NULL, buf);
					}
				}
				appendStringInfoChar(buf, ')');
			}
			break;

		default:
			/* should not reach here */
			elog(ERROR, "unrecognized expr node type: %d", (int) nodeTag(expr));
			result = false;
			break;
	}

	return result;
}

bool
deparse_where_clause(Node* expr,
					 const Oid* argtypes,
					 stub::placeholders_type& placeholders,
					 StringInfo buf)
{
	bool result{true};

	switch (nodeTag(expr))
	{
		case T_A_Expr:
			{
				A_Expr* a = (A_Expr *) expr;
				switch (a->kind)
				{
					case AEXPR_OP:
						result = deparse_aexpr_op(a, argtypes, placeholders, buf);
						break;
					case AEXPR_BETWEEN:
						result = deparse_aexpr_between(a, argtypes, placeholders, buf);
						break;
					case AEXPR_LIKE:
						result = deparse_aexpr_like(a, argtypes, placeholders, buf);
						break;
					case AEXPR_IN:
						result = deparse_aexpr_in(a, argtypes, placeholders, buf);
						break;
					default:
						/* should not reach here */
						elog(ERROR, "unrecognized where clause A_Expr kind: %d", a->kind);
						result = false;
						break;
				}
				break;
			}

		case T_BoolExpr:
			result = deparse_bool_expr((BoolExpr*) expr, argtypes, placeholders, buf);
			break;

		case T_SubLink:
			{
				SubLink* sub_link = (SubLink *) expr;
				appendStringInfoString(buf, "EXISTS (");
				deparse_select_query((SelectStmt*) sub_link->subselect, argtypes, placeholders, buf);
				appendStringInfoString(buf, ")");
			}
			break;

		default:
			/* should not reach here */
			elog(ERROR, "unrecognized where clause expr node type: %d", (int) nodeTag(expr));
			result = false;
			break;
	}

	return result;
}

void
deparse_sort_clause(List* sortClause,
					 StringInfo buf)
{
	const char* sep = "";
	ListCell* l;
	foreach(l, sortClause)
	{
		Node* sort = (Node *) lfirst(l);
		if (IsA(sort, SortBy)) {
			SortBy* sortby = (SortBy *) sort;
			appendStringInfoString(buf, sep);
			if (IsA(sortby->node, ColumnRef)) {
				deparse_column_ref((ColumnRef*) sortby->node, NULL, buf);
			}
			if (IsA(sortby->node, A_Const)) {
				A_Const* con = (A_Const *) sortby->node;
				Value* val = &con->val;
				deparse_a_const(val, buf);
			}
			switch (sortby->sortby_dir)
			{
				case SORTBY_DEFAULT:
					break;
				case SORTBY_ASC:
					{
						appendStringInfoString(buf, " ASC");
					}
					break;
				case SORTBY_DESC:
					{
						appendStringInfoString(buf, " DESC");
					}
					break;
				default:
					/* should not reach here */
					elog(ERROR, "unrecognized sortby dir: %d",
						 sortby->sortby_dir);
					return;
			}
			switch (sortby->sortby_nulls)
			{
				case SORTBY_NULLS_DEFAULT:
					break;
				case SORTBY_NULLS_FIRST:
					{
						appendStringInfoString(buf, " NULLS FIRST");
					}
					break;
				case SORTBY_NULLS_LAST:
					{
						appendStringInfoString(buf, " NULLS LAST");
					}
					break;
				default:
					/* should not reach here */
					elog(ERROR, "unrecognized sortby dir: %d",
						 sortby->sortby_dir);
					return;
			}
			sep = ", ";
		}
	}
}

void
deparse_join_expr(JoinExpr* join,
				  const Oid* argtypes,
				  stub::placeholders_type& placeholders,
				  StringInfo buf)
{
	switch (nodeTag(join->larg))
	{
		case T_RangeVar:
			{
				RangeVar* relation = (RangeVar *) join->larg;
				appendStringInfo(buf, "%s", relation->relname);
				if (relation->alias != NULL) {
					appendStringInfo(buf, " %s", relation->alias->aliasname);
				}
			}
			break;
		case T_JoinExpr:
			{
				deparse_join_expr((JoinExpr *)join->larg, argtypes, placeholders, buf);
			}
			break;
		default:
			/* should not reach here */
			elog(ERROR, "unsupported join larg %d", (int) nodeTag(join->larg));
			break;
	}

	switch (join->jointype)
	{
		case JOIN_INNER:
			if (join->quals != NULL) {
				appendStringInfoString(buf, " INNER JOIN ");
			} else {
				appendStringInfoString(buf, " CROSS JOIN ");
			}
			break;
		case JOIN_LEFT:
			appendStringInfoString(buf, " LEFT JOIN ");
			break;
		case JOIN_RIGHT:
			appendStringInfoString(buf, " RIGHT JOIN ");
			break;
		case JOIN_FULL:
			appendStringInfoString(buf, " FULL JOIN ");
			break;
		default:
			/* should not reach here */
			elog(ERROR, "unsupported join type %d", join->jointype);
			break;
	}

	if (IsA(join->rarg, RangeVar)) {
		RangeVar* relation = (RangeVar *) join->rarg;
		appendStringInfo(buf, "%s", relation->relname);
		if (relation->alias != NULL) {
			appendStringInfo(buf, " %s", relation->alias->aliasname);
		}
	}

	if (join->usingClause != NULL) {
		bool first = true;
		ListCell* lc;

		appendStringInfoString(buf, " USING (");
		foreach(lc, join->usingClause)
		{
			Node* using_clause = (Node *) lfirst(lc);
			if (IsA(using_clause, String)) {
				if (!first)
					appendStringInfoString(buf, ", ");
				first = false;
				appendStringInfo(buf, "%s", strVal(using_clause));
			}
		}
		appendStringInfoChar(buf, ')');
	}

	if (join->quals != NULL) {
		appendStringInfoString(buf, " ON ");
		deparse_where_clause(join->quals, argtypes, placeholders, buf);
	}
}

void
deparse_insert_query(const InsertStmt* stmt,
					 const Oid* argtypes,
					 stub::placeholders_type& placeholders,
					 StringInfo buf)
{
	std::vector<std::string> col_names;

	appendStringInfo(buf, "INSERT INTO %s ", stmt->relation->relname);

	deparse_query_columns(stmt->cols, col_names, buf);

	appendStringInfoString(buf, " VALUES ");

	SelectStmt* selectStmt = (SelectStmt *)stmt->selectStmt;
	deparse_values_lists(selectStmt->valuesLists, argtypes, col_names, placeholders, buf);
}

void
deparse_update_query(const UpdateStmt* stmt,
					 const Oid* argtypes,
					 stub::placeholders_type& placeholders,
					 StringInfo buf)
{
	appendStringInfo(buf, "UPDATE %s ", stmt->relation->relname);

	appendStringInfoString(buf, "SET ");

	bool first = true;
	ListCell* lc;
	foreach(lc, stmt->targetList)
	{
		ResTarget* col = lfirst_node(ResTarget, lc);
		if (!first)
			appendStringInfoString(buf, ", ");
		first = false;
		appendStringInfo(buf, "%s = ", col->name);
		if (IsA(col->val, ParamRef)) {
			deparse_value_paramref((ParamRef *)col->val, argtypes, col->name, placeholders, buf);
		}
		if (IsA(col->val, A_Const)) {
			A_Const* con = (A_Const *) col->val;
			Value* val = &con->val;
			deparse_a_const(val, buf);
		}
	}

	if (stmt->whereClause != NULL) {
		appendStringInfoString(buf, " WHERE ");
		deparse_where_clause(stmt->whereClause, argtypes, placeholders, buf);
	}
}

void
deparse_delete_query(const DeleteStmt* stmt,
					 const Oid* argtypes,
					 stub::placeholders_type& placeholders,
					 StringInfo buf)
{
	appendStringInfo(buf, "DELETE FROM %s ", stmt->relation->relname);

	if (stmt->whereClause != NULL) {
		appendStringInfoString(buf, " WHERE ");
		deparse_where_clause(stmt->whereClause, argtypes, placeholders, buf);
	}
}

void
deparse_select_query(const SelectStmt* stmt,
					 const Oid* argtypes,
					 stub::placeholders_type& placeholders,
					 StringInfo buf)
{
	appendStringInfoString(buf, "SELECT ");

	bool first = true;
	ListCell* lc;
	foreach(lc, stmt->targetList)
	{
		ResTarget* res = lfirst_node(ResTarget, lc);

		if (!first)
			appendStringInfoString(buf, ", ");
		first = false;

		if (IsA(res->val, ColumnRef)) {
			deparse_column_ref((ColumnRef*) res->val, res->name, buf);
		}

		if (IsA(res->val, FuncCall)) {
			FuncCall* func = (FuncCall *) res->val;
			ListCell* l;
			foreach(l, func->funcname){
				Node* name = (Node *) lfirst(l);
				if (IsA(name, String)) {
					appendStringInfo(buf, "%s", strVal(name));
				}
			}
			appendStringInfoChar(buf, '(');
			foreach(l, func->args){
				Node* args = (Node *) lfirst(l);
				if (IsA(args, ColumnRef)) {
					deparse_column_ref((ColumnRef*) args, NULL, buf);
				}
			}
			appendStringInfoChar(buf, ')');
			if (res->name != NULL) {
				appendStringInfo(buf, " AS \'%s\'", res->name);
			}
		}
	}

	if (stmt->fromClause != NULL) {
		appendStringInfoString(buf, " FROM ");

		ListCell* l;
		foreach(l, stmt->fromClause)
		{
			Node* from = (Node *) lfirst(l);

			if (IsA(from, RangeVar)) {
				RangeVar* relation = (RangeVar *) from;
				appendStringInfo(buf, "%s", relation->relname);
				if (relation->alias != NULL) {
					appendStringInfo(buf, " %s", relation->alias->aliasname);
				}
			}

			if (IsA(from, JoinExpr)) {
				deparse_join_expr((JoinExpr *)from, argtypes, placeholders, buf);
			}
		}
	}

	if (stmt->whereClause != NULL) {
		appendStringInfoString(buf, " WHERE ");
		deparse_where_clause(stmt->whereClause, argtypes, placeholders, buf);
	}

	if (stmt->sortClause != NULL) {
		appendStringInfoString(buf, " ORDER BY ");
		deparse_sort_clause(stmt->sortClause, buf);
	}

	if (stmt->groupClause != NULL) {
		appendStringInfoString(buf, " GROUP BY ");
		ListCell* l;
		foreach(l, stmt->groupClause)
		{
			Node* group = (Node *) lfirst(l);
			if (IsA(group, ColumnRef)) {
				deparse_column_ref((ColumnRef*) group, NULL, buf);
			}
		}
	}

	if (stmt->havingClause != NULL) {
		appendStringInfoString(buf, " HAVING ");
		deparse_where_clause(stmt->havingClause, argtypes, placeholders, buf);
	}
}

/**
 *  @brief Calls the function to get ID and send created role ID to ogawayama.
 *  @param [in] stmts of statements.
 *  @return true if operation was successful, false otherwize.
 */
bool
after_prepare_stmt(const PrepareStmt* stmts,
				   const char* queryString)
{
	Assert(stmts != nullptr);

	Node* query = stmts->query;
	if (!is_tsurugi_table(query, true)) {
		return true;
	}

	stub::placeholders_type placeholders{};
	StringInfoData sql;
	initStringInfo(&sql);

	/* Transform list of TypeNames to array of type OIDs */
	Oid* argtypes = nullptr;
	std::vector<Oid> argtypes_v;
	argtypes = transform_typenames_to_oids(stmts->argtypes, argtypes_v, queryString);

	switch (nodeTag(query))
	{
		case T_InsertStmt:
			{
				deparse_insert_query((InsertStmt *)query, argtypes, placeholders, &sql);
			}
			break;
		case T_UpdateStmt:
			{
				deparse_update_query((UpdateStmt *)query, argtypes, placeholders, &sql);
			}
			break;
		case T_DeleteStmt:
			{
				deparse_delete_query((DeleteStmt *)query, argtypes, placeholders, &sql);
			}
			break;
		case T_SelectStmt:
			{
				deparse_select_query((SelectStmt *)query, argtypes, placeholders, &sql);
			}
			break;
		default:
			/* should not reach here */
			elog(ERROR, "unrecognized node type: %d",
				 (int) nodeTag(query));
			break;
	}

#if 0
	stub::Connection* connection;
	ERROR_CODE error = Tsurugi::get_connection(&connection);
	if (error != ERROR_CODE::OK)
	{
		elog(ERROR, "Tsurugi::get_connection() failed. (code: %d)", (int) error);
		return false;
	}
	error = connection->prepare(sql.data, placeholders, prepared_statement);
	if (error != ERROR_CODE::OK)
	{
		elog(ERROR, "connection->prepare() failed. (%d)\n\tsql:%s", (int) error, sql.data);
		return false;
	}
#else
	PreparedStatementPtr prepared_statement;
	ERROR_CODE error = Tsurugi::prepare(sql.data, placeholders, prepared_statement);
	if (error != ERROR_CODE::OK)
	{
		elog(ERROR, "Tsurugi::prepare() failed. (%d)\n\tsql:%s", (int) error, sql.data);
		return false;
	}
#endif

	char* name = stmts->name;
	stored_prepare_statment[std::string(name)] = std::move(prepared_statement);
	stored_argtypes[std::string(name)] = argtypes_v;

	return true;
}

void
deparse_execute_param(const ExecuteStmt* stmts,
					  const Param* target_param,
					  const char* resname)
{
	List* stmt_params = stmts->params;
	ListCell* lcp;
	int param_count = 0;
	foreach(lcp, stmt_params)
	{
		param_count++;
		if (target_param->paramid == param_count) {
			Node* stmt_param = (Node *) lfirst(lcp);
			if (IsA(stmt_param, A_Const)) {
				A_Const* con = (A_Const *)stmt_param;
				Value* val = &con->val;
				std::string col_name = resname;
				col_name += "_" + std::to_string(target_param->paramid);
				switch (nodeTag(val))
				{
					case T_Integer:
					case T_Float:
						{
							switch (target_param->paramtype)
							{
								case INT2OID:
									parameters.emplace_back(col_name,
													static_cast<std::int16_t>(intVal(val)));
									break;
								case INT4OID:
									parameters.emplace_back(col_name,
													static_cast<std::int32_t>(intVal(val)));
									break;
								case INT8OID:
									parameters.emplace_back(col_name,
													static_cast<std::int64_t>(intVal(val)));
									break;
								case FLOAT4OID:
									parameters.emplace_back(col_name,
													static_cast<float>(floatVal(val)));
									break;
								case FLOAT8OID:
									parameters.emplace_back(col_name,
													static_cast<double>(floatVal(val)));
									break;
								default:
									/* should not reach here */
									elog(ERROR, "execute_param: unrecognized T_Integer paramtype oid: %d",
										 (int) target_param->paramtype);
									break;
							}
						}
						break;
					case T_String:
#if 1
						parameters.emplace_back(col_name, strVal(val));
#else
						switch (target_param->paramtype)
						{
							case BPCHAROID:
							case VARCHAROID:
							case TEXTOID:
								parameters.emplace_back(col_name, strVal(val));
								break;
							case DATEOID:
								stub::date_type value;
								// ToDo: Transform strVal to takatori::datetime::date
								break;
							case TIMEOID:
								stub::time_type value;
								// ToDo: Transform strVal to takatori::datetime::time_of_day
								break;
							case TIMESTAMPOID:
								stub::timestamp_type value;
								// ToDo: Transform strVal to takatori::datetime::time_point
								break;
							default:
								/* should not reach here */
								elog(ERROR, "execute_param: unrecognized T_String paramtype oid: %d",
									 (int) target_param->paramtype);
								break;
						}
#endif
						break;
					case T_Null:
						{
							std::monostate monostate;
							parameters.emplace_back(col_name, monostate);
						}
						break;
					default:
						/* should not reach here */
						elog(ERROR, "execute_param: unrecognized a_const value node type: %d",
							 (int) nodeTag(val));
						break;
				}
			}
		}
	}
}

void
deparse_execute_target_entry(const TargetEntry* target_entry,
							 const ExecuteStmt* stmts)
{
	Expr* expr = target_entry->expr;

	if (IsA(expr, Param)) {
		Param* target_param = (Param *) expr;
		deparse_execute_param(stmts, target_param, target_entry->resname);
	} else if (IsA(expr, FuncExpr)) {
		FuncExpr* func_expr = (FuncExpr *) expr;
		List* args = func_expr->args;
		ListCell* lca;
		foreach(lca, args)
		{
			Node* arg = (Node *) lfirst(lca);
			if (IsA(arg, Param)) {
				Param* target_param = (Param *) arg;
				deparse_execute_param(stmts, target_param, target_entry->resname);
			}
		}
	}
}

void
deparse_execute_paramref(const ParamRef* param_ref,
						 std::string col_name,
						 const ExecuteStmt* stmts)
{
	List* stmt_params = stmts->params;
	ListCell* lcp;
	int param_count = 0;
	foreach(lcp, stmt_params)
	{
		param_count++;
		if (param_ref->number == param_count) {
			Node* stmt_param = (Node *) lfirst(lcp);
			if (IsA(stmt_param, A_Const)) {
				A_Const* con = (A_Const *)stmt_param;
				Value* val = &con->val;
				col_name += "_" + std::to_string(param_ref->number);
				switch (nodeTag(val))
				{
					case T_Integer:
					case T_Float:
						{
							std::vector<Oid> argtypes_v;
							argtypes_v = stored_argtypes[stmts->name];
							switch (argtypes_v[param_ref->number-1])
							{
								case INT2OID:
									parameters.emplace_back(col_name,
													static_cast<std::int16_t>(intVal(val)));
									break;
								case INT4OID:
									parameters.emplace_back(col_name,
													static_cast<std::int32_t>(intVal(val)));
									break;
								case INT8OID:
									parameters.emplace_back(col_name,
													static_cast<std::int64_t>(intVal(val)));
									break;
								case FLOAT4OID:
									parameters.emplace_back(col_name,
													static_cast<float>(floatVal(val)));
									break;
								case FLOAT8OID:
									parameters.emplace_back(col_name,
													static_cast<double>(floatVal(val)));
									break;
								default:
									/* should not reach here */
									elog(ERROR, "execute_paramref: unrecognized paramtype oid: %d",
										 (int) argtypes_v[param_ref->number-1]);
									break;
							}
						}
						break;
					case T_String:
						parameters.emplace_back(col_name, strVal(val));
						break;
					default:
						/* should not reach here */
						elog(ERROR, "execute_paramref: unrecognized a_const value node type: %d",
							 (int) nodeTag(val));
						break;
				}
			}
		}
	}
}

bool
deparse_execute_aexpr_op(A_Expr* a,
						 const ExecuteStmt* stmts)
{
	Node* lexpr = a->lexpr;
	Node* rexpr = a->rexpr;
	std::string col_name;
	bool result{true};

	result = deparse_execute_expr_recurse(lexpr, col_name, stmts);
	if (result != true) {
		return result;
	}

	switch (list_length(a->name))
	{
		case 1:
			break;
		default:
			/* should not reach here */
			elog(ERROR, "deparse_execute_aexpr_op: list_length = %d", list_length(a->name));
			result = false;
			break;
	}

	result = deparse_execute_expr_recurse(rexpr, col_name, stmts);

	return result;
}

bool
deparse_execute_aexpr_between(A_Expr* a,
							  const ExecuteStmt* stmts)
{
	Node* lexpr = a->lexpr;
	List* rexpr = (List *) a->rexpr;
	std::string col_name;
	bool result{true};

	result = deparse_execute_expr_recurse(lexpr, col_name, stmts);
	if (result != true) {
		return result;
	}

	switch (list_length(a->name))
	{
		case 1:
			break;
		default:
			/* should not reach here */
			elog(ERROR, "deparse_execute_aexpr_between: list_length = %d", list_length(a->name));
			result = false;
			return result;
	}

	ListCell   *lc;
	int name_num = 0;
	foreach(lc, rexpr)
	{
		Node* expr = (Node *) lfirst(lc);
		std::string name = col_name + std::to_string(name_num);
		result = deparse_execute_expr_recurse(expr, name, stmts);
		if (result != true) {
			return result;
		}
	}

	return result;
}

bool
deparse_execute_aexpr_like(A_Expr* a,
						 const ExecuteStmt* stmts)
{
	Node* lexpr = a->lexpr;
	Node* rexpr = a->rexpr;
	std::string col_name;
	bool result{true};

	result = deparse_execute_expr_recurse(lexpr, col_name, stmts);
	if (result != true) {
		return result;
	}

	switch (list_length(a->name))
	{
		case 1:
			break;
		default:
			/* should not reach here */
			elog(ERROR, "deparse_execute_aexpr_like: list_length = %d", list_length(a->name));
			result = false;
			break;
	}

	result = deparse_execute_expr_recurse(rexpr, col_name, stmts);

	return result;
}

bool
deparse_execute_aexpr_in(A_Expr* a,
						 const ExecuteStmt* stmts)
{
	Node* lexpr = a->lexpr;
	List* rexpr = (List *) a->rexpr;
	std::string col_name;
	bool result{true};

	result = deparse_execute_expr_recurse(lexpr, col_name, stmts);
	if (result != true) {
		return result;
	}

	switch (list_length(a->name))
	{
		case 1:
			break;
		default:
			/* should not reach here */
			elog(ERROR, "deparse_execute_aexpr_between: list_length = %d", list_length(a->name));
			result = false;
			return result;
	}

	ListCell   *lc;
	int name_num = 0;
	foreach(lc, rexpr)
	{
		Node* expr = (Node *) lfirst(lc);
		std::string name = col_name + std::to_string(name_num);
		result = deparse_execute_expr_recurse(expr, name, stmts);
		if (result != true) {
			return result;
		}
	}

	return result;
}

bool
deparse_execute_bool_expr(BoolExpr* a,
						  const ExecuteStmt* stmts)
{
	ListCell   *lc;
	bool result{true};

	switch (a->boolop)
	{
		case AND_EXPR:
		case OR_EXPR:
		case NOT_EXPR:
			break;
		default:
			/* should not reach here */
			elog(ERROR, "deparse_execute_bool_expr: unrecognized boolop: %d", (int) a->boolop);
			result = false;
			return result;
	}

	foreach(lc, a->args)
	{
		Node* arg = (Node *) lfirst(lc);
		deparse_execute_where_clause(arg, stmts);
	}

	return result;
}

bool
deparse_execute_expr_recurse(Node* expr,
							 std::string& col_name,
							 const ExecuteStmt* stmts)
{
	bool result{true};

	switch (nodeTag(expr))
	{
		case T_ColumnRef:
			col_name = deparse_column_ref((ColumnRef*) expr, NULL, NULL);
			break;

		case T_ParamRef:
			{
				deparse_execute_paramref((ParamRef *)expr, col_name, stmts);
				break;
			}

		case T_A_Expr:
			{
				A_Expr* a = (A_Expr *) expr;
				switch (a->kind)
				{
					case AEXPR_OP:
						result = deparse_execute_aexpr_op(a, stmts);
						break;
					case AEXPR_BETWEEN:
						result = deparse_execute_aexpr_between(a, stmts);
						break;
					case AEXPR_LIKE:
						result = deparse_execute_aexpr_like(a, stmts);
						break;
					case AEXPR_IN:
						result = deparse_execute_aexpr_in(a, stmts);
						break;
					default:
						/* should not reach here */
						elog(ERROR, "unrecognized A_Expr kind: %d", a->kind);
						result = false;
						break;
				}
				break;
			}

		case T_BoolExpr:
			result = deparse_execute_bool_expr((BoolExpr*) expr, stmts);
			break;

		case T_SubLink:
			{
				SubLink* sub_link = (SubLink *) expr;
				SelectStmt* stmt = (SelectStmt *) sub_link->subselect;
				deparse_execute_where_clause(stmt->whereClause, stmts);
			}
			break;

		case T_A_Const:
		case T_FuncCall:
			/* EXECUTE does not require deparsing */
			break;

		default:
			/* should not reach here */
			elog(ERROR, "unrecognized expr node type: %d", (int) nodeTag(expr));
			result = false;
			break;
	}

	return result;
}

void
deparse_execute_where_clause(const Node* expr,
							 const ExecuteStmt* stmts)
{
	if (expr == NULL) {
		return;
	}

	switch (nodeTag(expr))
	{
		case T_A_Expr:
			{
				A_Expr* a = (A_Expr *) expr;
				switch (a->kind)
				{
					case AEXPR_OP:
						deparse_execute_aexpr_op(a, stmts);
						break;
					case AEXPR_BETWEEN:
						deparse_execute_aexpr_between(a, stmts);
						break;
					case AEXPR_LIKE:
						deparse_execute_aexpr_like(a, stmts);
						break;
					case AEXPR_IN:
						deparse_execute_aexpr_in(a, stmts);
						break;
					default:
						/* should not reach here */
						elog(ERROR, "unrecognized where clause A_Expr kind: %d", a->kind);
						break;
				}
				break;
			}

		case T_BoolExpr:
			deparse_execute_bool_expr((BoolExpr*) expr, stmts);
			break;

		case T_SubLink:
			{
				SubLink* sub_link = (SubLink *) expr;
				SelectStmt* stmt = (SelectStmt *) sub_link->subselect;
				deparse_execute_where_clause(stmt->whereClause, stmts);
			}
			break;

		default:
			/* should not reach here */
			elog(ERROR, "unrecognized where clause expr node type: %d", (int) nodeTag(expr));
			break;
	}
}

bool
befor_execute_stmt(const ExecuteStmt* stmts)
{
	PreparedStatement* entry;
	List* query_list;
	ListCell* l;

	entry = FetchPreparedStatement(stmts->name, true);

	RawStmt* raw_stmt = entry->plansource->raw_parse_tree;
	Node* query = raw_stmt->stmt;
	if (!is_tsurugi_table(query, false)) {
		return true;
	}

	query_list = entry->plansource->query_list;
	foreach(l, query_list)
	{
		Query* query = (Query *) lfirst(l);
		List* target_list = query->targetList;
		ListCell* lc;
		foreach(lc, target_list)
		{
			TargetEntry* target_entry = (TargetEntry *) lfirst(lc);
			deparse_execute_target_entry(target_entry, stmts);
		}
	}

	switch (nodeTag(raw_stmt->stmt))
	{
		case T_InsertStmt:
			break;
		case T_UpdateStmt:
			{
				UpdateStmt* stmt = (UpdateStmt *) raw_stmt->stmt;
				deparse_execute_where_clause(stmt->whereClause, stmts);
			}
			break;
		case T_DeleteStmt:
			{
				DeleteStmt* stmt = (DeleteStmt *) raw_stmt->stmt;
				deparse_execute_where_clause(stmt->whereClause, stmts);
			}
			break;
		case T_SelectStmt:
			{
				SelectStmt* stmt = (SelectStmt *) raw_stmt->stmt;

				if (stmt->fromClause != NULL) {
					ListCell* l;
					foreach(l, stmt->fromClause)
					{
						Node* from = (Node *) lfirst(l);
						if (IsA(from, JoinExpr)) {
							JoinExpr* join = (JoinExpr *) from;
							deparse_execute_where_clause(join->quals, stmts);
						}
					}
				}
				deparse_execute_where_clause(stmt->whereClause, stmts);
				deparse_execute_where_clause(stmt->havingClause, stmts);
			}
			break;
		default:
			/* should not reach here */
			elog(ERROR, "unrecognized where clause node type: %d",
				 (int) nodeTag(raw_stmt->stmt));
			break;
	}

	prepared_statement = std::move(stored_prepare_statment.at(stmts->name));

	return true;
}

bool
after_execute_stmt(const ExecuteStmt* stmts)
{
	PreparedStatement* entry = FetchPreparedStatement(stmts->name, true);
	RawStmt* raw_stmt = entry->plansource->raw_parse_tree;
	Node* query = raw_stmt->stmt;
	if (!is_tsurugi_table(query, false)) {
		return true;
	}

	stored_prepare_statment[stmts->name] = std::move(prepared_statement);
	parameters = {};
	return true;
}

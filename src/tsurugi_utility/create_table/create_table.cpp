/*
 * Copyright 2019-2023 Project Tsurugi.
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
 *	@file	  create_table.cpp
 */
#include <unordered_set>
#include <boost/property_tree/ptree.hpp>
#include <boost/optional.hpp>
#include "manager/metadata/metadata.h"
#include "manager/metadata/datatypes.h"
#include "manager/metadata/tables.h"
#include "manager/metadata/error_code.h"

#ifdef __cplusplus
extern "C" {
#endif
#include "postgres.h"
#include "catalog/heap.h"
#include "catalog/pg_class.h"
#include "nodes/nodes.h"
#include "nodes/parsenodes.h"
#include "nodes/value.h"
#include "utils/ruleutils.h"
#ifdef __cplusplus
}
#endif

#include "create_table.h"

using boost::property_tree::ptree;
using namespace manager;

/**
 * @brief seek ordinal positions of primary keys in table or column constraints.
 * 
 * 
 * 
 */
std::vector<int64_t> get_primary_key(
    	const CreateStmt* create_stmt, 
		std::vector<metadata::Column>& columns)
{
	std::vector<int64_t> primary_keys;

	List* table_elts = create_stmt->tableElts;
	ListCell* listptr;
	foreach(listptr, table_elts) {
		// Seek primary-key in column constraints.
		Assert(IsA(lfirst(listptr), ColumnDef));
		ColumnDef* column_def = (ColumnDef *) lfirst(listptr);
		List* column_def_constraints = column_def->constraints;
		if (column_def_constraints != NIL) {
			ListCell* lc;
			foreach(lc, column_def_constraints) {
				Constraint* constr = (Constraint*) lfirst(lc);
				/* Get oridinal positions of column constraints' primary key columns */
				if (constr->contype == CONSTR_PRIMARY) {
					for (metadata::Column column : columns) {
						if (column.name == column_def->colname) {
							primary_keys.emplace_back(column.column_number);
							break;
						}
					}
				}
			}
		}
	}

	return primary_keys;
}

/**
 *  @brief  Check if given syntax supported or not by Tsurugi
 *  @return true if supported
 *  @return false otherwise.
 */
bool CreateTable::validate_syntax() const
{
  assert(create_stmt() != nullptr);

  const CreateStmt* create_stmt = this->create_stmt();
  bool result{false};
  List* table_elts = create_stmt->tableElts;

  /* Check members of CreateStmt structure. */
  if (create_stmt->inhRelations != NIL) {
      ereport(ERROR,
              (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                errmsg("Tsurugi does not support INHERITS clause")));
      return result;
  }

  if (create_stmt->partbound != nullptr) {
      ereport(ERROR,
              (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                errmsg("Tsurugi does not support FOR VALUES clause")));
      return result;
  }

  if (create_stmt->partspec != nullptr) {
      ereport(ERROR,
              (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                errmsg("Tsurugi does not support PARTITION BY clause")));
      return result;
  }

  if (create_stmt->ofTypename != nullptr) {
      ereport(ERROR,
              (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                errmsg("Tsurugi does not support OF typename clause")));
      return result;
  }

  if (create_stmt->options != NIL) {
      ereport(ERROR,
              (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                errmsg("Tsurugi does not support WITH clause")));
      return result;
  }

  if (create_stmt->oncommit != ONCOMMIT_NOOP) {
      ereport(ERROR,
              (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                errmsg("Tsurugi does not support ON COMMIT clause")));
      return result;
  }

#if PG_VERSION_NUM >= 120000
  if (create_stmt->accessMethod != nullptr) {
      ereport(ERROR,
              (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                errmsg("Tsurugi does not support USING clause")));
      return result;
  }
#endif

  /* for duplicate column name check */
  std::unordered_set<std::string> column_names;

  /* Check members of each column */
  ListCell* l;
  foreach(l, table_elts) {
    ColumnDef *column_def = (ColumnDef *)lfirst(l);
    List *column_def_constraints = column_def->constraints;

    /* Check column constraints */
    if (column_def_constraints != NIL) {
      ListCell   *l;
      foreach(l, column_def_constraints) {
        Constraint *constr = (Constraint *) lfirst(l);
        switch (constr->contype)
        {
            case CONSTR_IDENTITY:
                ereport(ERROR,
                    (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                     errmsg("Tsurugi does not support IDENTITY in column constraint")));
                return result;
            case CONSTR_GENERATED:
                ereport(ERROR,
                    (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                     errmsg("Tsurugi does not support GENERATED in column constraint")));
                return result;
            case CONSTR_ATTR_DEFERRABLE:
                ereport(ERROR,
                    (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                     errmsg("Tsurugi does not support DEFERRABLE in column constraint")));
                return result;
            case CONSTR_ATTR_NOT_DEFERRABLE:
                ereport(ERROR,
                    (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                     errmsg("Tsurugi does not support NOT DEFERRABLE in column constraint")));
                return result;
            case CONSTR_ATTR_DEFERRED:
                ereport(ERROR,
                    (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                     errmsg("Tsurugi does not support INITIALLY DEFERRED in column constraint")));
                return result;
            case CONSTR_ATTR_IMMEDIATE:
                ereport(ERROR,
                    (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                     errmsg("Tsurugi does not support INITIALLY IMMEDIATE in column constraint")));
                return result;
            default:
                break;
        }
      }
    }

    /* If COLLATE clause, LIKE clause, DEFAULT constrint, or other syntax, collOid is valid. */
    if ((column_def->collClause != nullptr) | OidIsValid(column_def->collOid)) {
      ereport(ERROR,
              (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                errmsg("Tsurugi does not support COLLATE clause")));
      return result;
    }

    /* Check for duplicates */
    std::string colname = std::string(column_def->colname);
    if (column_names.find(colname) != column_names.end()) {
      ereport(ERROR,
              (errcode(ERRCODE_DUPLICATE_COLUMN),
                errmsg("column \"%s\" specified more than once",
                      colname.c_str()),
                errdetail("Tsurugi does not support this syntax")));
      return result;
    }
    column_names.insert(colname);
  }

  /**
    * If statements to create temprary or unlogged table are given,
    * report error messages.
    */
  RangeVar* relation = (RangeVar*) create_stmt->relation;
  if (relation != nullptr && relation->relpersistence != RELPERSISTENCE_PERMANENT) {
    ereport(ERROR,
        (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
          errmsg("Tsurugi supports only regular table")));
    return result;
  }

  result = true;

  return result;
}

/**
 *  @brief  Check if given syntax supported or not by Tsurugi
 *  @return true if supported
 *  @return false otherwise.
 */
bool CreateTable::validate_data_type() const
{
  assert(create_stmt() != nullptr);

  bool result{true};
  CreateStmt* create_stmt = this->create_stmt();
  List *table_elts = create_stmt->tableElts;
  ListCell *l;
  auto datatypes = std::make_unique<metadata::DataTypes>(TSURUGI_DB_NAME);

  /*
    * List of TypeName structure's member "names" not supported by Tsurugi.
    * If type_oid_not_supported is not empty, type_names_not_supported is NIL.
    */
  List *type_names_not_supported = NIL;
  /*
    * List of TypeName structure's member "typeOid" not supported by Tsurugi.
    * If type_oid_not_supported is not NIL, type_oid_not_supported is empty.
    */
  std::vector<int> type_oid_not_supported;

  /* Check type of each column */
  foreach(l, table_elts) {
    ColumnDef *column_def = (ColumnDef *)lfirst(l);
    TypeName *column_type = column_def->typeName;

    if (column_type != nullptr) {
      List *type_names = column_type->names;

      /**
        * If "names" is NIL then the actual type OID is given by typeOid,
        * otherwise typeOid is unused.
        */
      if (type_names != NIL) {
        bool is_supported{false};

        ListCell   *l;
        foreach(l, type_names) {
          Value *type_name_value = (Value *)lfirst(l);
          std::string type_name{std::string(strVal(type_name_value))};

          ptree datatype;
          /*
            * ErrorCode::OK if the given type name is suppoted by Tsurugi,
            * otherwize error code is returned.
            */
          metadata::ErrorCode err = datatypes->get(
              metadata::DataTypes::PG_DATA_TYPE_QUALIFIED_NAME, type_name, datatype);
          if (err == metadata::ErrorCode::OK) {
              is_supported = true;
          }
        }

        /* If the given type name is not suppoted, append the list of type names not supported*/
        if (!is_supported) {
            type_names_not_supported = lappend(type_names_not_supported,type_names);
            result = false;
        }
      }

      if (OidIsValid(column_type->typeOid)) {
        ptree datatype;
        std::string type_oid_str = std::to_string(column_type->typeOid);

        /*
          * ErrorCode::OK if the given type is suppoted by Tsurugi,
          * otherwize error code is returned.
          */
        metadata::ErrorCode err = datatypes->get(
              metadata::DataTypes::PG_DATA_TYPE, type_oid_str, datatype);
        /* If the given type is not suppoted, append the list of type oids not supported*/
        if (err != metadata::ErrorCode::OK) {
            type_oid_not_supported.push_back(column_type->typeOid);
            result = false;
        }
      }
    } else {
      /* If invalid syntax is given, report error messages. */
      show_syntax_error_msg("type name of column is not specified");
      result = false;
      return result;
    }
  }

  /* If given type is not supported, report error messages. */
  if (result != true) {
    if (type_names_not_supported != NIL) {
        show_type_error_msg(type_names_not_supported);
    }
    if (!type_oid_not_supported.empty()) {
        show_type_error_msg(type_oid_not_supported);
    }
  }

  return result;
}

/**
 * @brief 	Generate metadata from query tree.
 * @param	table_tree	
 * @return	true if success.
 */
bool CreateTable::generate_metadata(manager::metadata::Object& object) const
{
	const CreateStmt* create_stmt = this->create_stmt();
	assert(create_stmt != NULL);
	auto& table = static_cast<metadata::Table&>(object);

	bool result{false};
//	ptree table_tree;

	//
	// table metadata
	//
	// table name
	RangeVar* relation = (RangeVar*) create_stmt->relation;
	if (relation != nullptr && relation->relname != nullptr) {
		table.name = relation->relname;
	} else {
		show_syntax_error_msg("table name is not specified");
		return result;
	}
	// tuples
	table.number_of_tuples = 0;

	//
	// columns metadata
	//
	ptree columns_node;

	/* for each columns */
	List* table_elts = create_stmt->tableElts;
	ListCell* listptr;
	int64_t ordinal_position = metadata::Column::ORDINAL_POSITION_BASE_INDEX;
	TupleDesc descriptor = BuildDescForRelation(table_elts);
	foreach(listptr, table_elts) {
		Node* node = (Node *) lfirst(listptr);
		if (IsA(node, ColumnDef)) {
			ColumnDef* column_def = (ColumnDef*) node;
			metadata::Column column;

			bool success = generate_column_metadata(column_def, 
													ordinal_position, 
													descriptor,
													column);
			if (!success) {
				return result;
			}
			table.columns.emplace_back(column);
			ordinal_position++;
		}
	}
	result = true;

	return result;
}

/**
 * @brief	Generate column metadata from ColumnDef.
 * @param 	column_def [in] column query tree.
 * @param 	ordinal_position [in] column ordinal position
 * @param 	descriptor [in] tuple descriptor
 * @param 	column [out] column metadata
 */
bool CreateTable::generate_column_metadata(ColumnDef* column_def, 
							int64_t ordinal_position, 
							TupleDesc descriptor,
							metadata::Column& column) const
{
	assert(column_def != NULL);

	bool result = false;
	auto datatypes = std::make_unique<metadata::DataTypes>(TSURUGI_DB_NAME);

	/* ordinalPosition  */
	column.column_number = ordinal_position;

	/* column name */
	column.name = column_def->colname;

	// nullable
	column.is_not_null = column_def->is_not_null;

	// default_expr
	if (column_def->raw_default != NULL) {
		char* adsrc;
		ParseState* pstate = make_parsestate(NULL);
		Form_pg_attribute atp = TupleDescAttr(descriptor, ordinal_position - 1);
		Node *expr_cooked = cookDefault(pstate, column_def->raw_default,
										atp->atttypid, atp->atttypmod,
										NameStr(atp->attname), 0);
		adsrc = deparse_expression(expr_cooked, NIL, false, false);
		if (adsrc) {
			column.default_expression = adsrc;
			if (IsA(column_def->raw_default, SQLValueFunction)) {
				column.is_funcexpr = true;
			}
		}
	}

	//
	// column data type
	//
	TypeName* column_type = column_def->typeName;
	if (column_type == NULL) {
		this->show_syntax_error_msg("type name of the column is not specified");
		return result;
	}
	List *type_names = column_type->names;
	boost::optional<metadata::ObjectIdType> data_type_id;

	/*
	* If "names" is NIL then the actual type OID is given by typeOid,
	* otherwise typeOid is unused.
	*/
	ListCell* listptr;
	foreach(listptr, type_names) {
		Value* type_name_value = (Value*) lfirst(listptr);
		std::string type_name{std::string(strVal(type_name_value))};

		// PG data type qualified name
		ptree datatype;
		metadata::ErrorCode error = datatypes->get(
				metadata::DataTypes::PG_DATA_TYPE_QUALIFIED_NAME, type_name, datatype);
		if (error == metadata::ErrorCode::OK) {
			data_type_id = 
					datatype.get_optional<metadata::ObjectIdType>(metadata::DataTypes::ID);
			break;
		}
	}

	// Get data type ID
	if (OidIsValid(column_type->typeOid)) {
		ptree datatype;
		std::string type_oid_str = std::to_string(column_type->typeOid);
		metadata::ErrorCode error = datatypes->get(
			metadata::DataTypes::PG_DATA_TYPE, type_oid_str, datatype);
		if (error != metadata::ErrorCode::OK) {
			data_type_id = datatype.get_optional<metadata::ObjectIdType>(metadata::DataTypes::ID);
		}
	}
	if (!data_type_id) {
		ereport(ERROR,
				(errcode(ERRCODE_INTERNAL_ERROR),
				errmsg("Tsurugi could not found data type ids")));
		return result;
	} 
	metadata::ObjectId id = data_type_id.get();
	column.data_type_id = id;

	/* put varying metadata if given type is varchar or char */
	switch (static_cast<metadata::DataTypes::DataTypesId>(id)) {
		case metadata:: DataTypes::DataTypesId::VARCHAR: {
			/* put true if given type is varchar */
			column.varying = true;
			break;
		}
		case metadata::DataTypes::DataTypesId::CHAR: {
			/* put false if given type is char */
			column.varying = false;
			break;
		}
		default: {
			/* other data type */
			column.varying = false;
			break;
		}
	}

	/* put data type lengths metadata */
	switch (static_cast<metadata::DataTypes::DataTypesId>(id)) {
		case metadata::DataTypes::DataTypesId::INTERVAL:
		case metadata::DataTypes::DataTypesId::TIMESTAMPTZ:
		case metadata::DataTypes::DataTypesId::TIMESTAMP:
		case metadata::DataTypes::DataTypesId::TIMETZ:
		case metadata::DataTypes::DataTypesId::TIME:
		case metadata::DataTypes::DataTypesId::NUMERIC:
		case metadata::DataTypes::DataTypesId::VARCHAR:
		case metadata::DataTypes::DataTypesId::CHAR: {
			/*
			 * if "typmods" is NIL then the actual typmod is expected to
			 * be prespecified in typemod, otherwise typemod is unused.
			 */
			List* typmods = column_type->typmods;
			/* typemod includes varlena header */
			int64_t typemod = (int64_t) column_type->typemod - VARHDRSZ;
			if (typmods != NIL) {
				/* for data type lengths metadata */
				bool success = get_data_lengths(typmods, column.data_length);
				if (!success) {
					return result;
				}
			} else if (typemod >= 0) {
				/* if typmod is -1, typmod is NULL VALUE*/
				/* put a data type length metadata */
				column.data_length.emplace_back(typemod);
			}
			break;
		}
		default: {
			/* other data type */
			break;
		}
	}  
	result = true;

	return result;
}

/**
 * @brief	Get column data lengths.
 */
bool CreateTable::get_data_lengths(List* typmods, std::vector<int64_t>& datalengths) const
{
	bool result{false};

	ListCell *listptr;
	foreach(listptr, typmods) {
		Node* node = (Node*) lfirst(listptr);
		if (IsA(node, A_Const)) {
			A_Const* a_const = (A_Const*) node;
			if (IsA(&a_const->val, Integer)) {
				/*
				* get data type lengths from typmods of TypeName structure.
				* The given data type length must be constant integer value.
				*/
				datalengths.emplace_back(a_const->val.val.ival);
			} else {
				this->show_syntax_error_msg("can use only integer value in data length");
				return result;
			}
		} else {
			this->show_syntax_error_msg("can use only constant value in data length");
			return result;
		}
	}
	result = true;

	return result;
}

/**
 * @brief	Get check constraint information.
 * @param 	constr [in] column query tree.
 * @param 	table [in] table metadata.
 * @param 	column_def [in] column query tree.
 * @param 	constraint [out] constraint metadata.
 * @return 	true if success, otherwise fault.
 */
bool CreateTable::get_constraint_metadata(Constraint* constr, 
							metadata::Table& table, 
							ColumnDef* column_def,
							metadata::Constraint& constraint) const
{
	bool result{false};

	if (constr->contype == CONSTR_CHECK) {

		/* put constraint name metadata */
		if (constr->conname != NULL) {
			constraint.name = constr->conname;
		}

		/* put constraint columns metadata and columns_id metadata */
		if (column_def != NULL) {
			for (const auto& column : table.columns) {
				if (column.name == column_def->colname) {
					constraint.columns.emplace_back(column.column_number);
					constraint.columns_id.emplace_back(column.id);
				}
			}
		}

		/* put constraint type metadata */
		constraint.type = metadata::Constraint::ConstraintType::CHECK;

		/* put constraint expression metadata */
		char* adsrc;
		adsrc = get_check_expression(constr->raw_expr);
		if (!adsrc) {
			return result;
		}
		constraint.expression = adsrc;

		result = true;
	}

	return result;
}

/**
 * @brief  	Create constraint metadata from query tree.
 * @param 	table [in] table metadata.
 * @return 	OK if success, otherwise fault.
 * @note	Add metadata of CONSTR_CHECK.
 */
metadata::ErrorCode 
CreateTable::generate_constraint_metadata(metadata::Table& table) const
{
	const CreateStmt* create_stmt = this->create_stmt();
	assert(create_stmt != NULL);
	metadata::ErrorCode result = metadata::ErrorCode::NOT_FOUND;

	/* for table columns */
	ListCell* listptr;
	foreach(listptr, create_stmt->constraints) {
		Constraint* constr = (Constraint*) lfirst(listptr);
		metadata::Constraint constraint;
		bool success = get_constraint_metadata(constr, table, NULL, constraint);
		if (success) {
			table.constraints.emplace_back(constraint);
			result = metadata::ErrorCode::OK;
		}
	}

	return result;
}

/**
 * @brief	Analyze and get the check constraint expression.
 * @param	expr [in] expression.
 * @return	The parsed expression string.
 */
char* CreateTable::get_check_expression(Node* expr) const
{
	StringInfoData buf;
	initStringInfo(&buf);

	bool success = get_expr_recurse(expr, &buf);
	if (!success) {
		return NULL;
	}

	/* Remove trailing spaces */
	buf.data[buf.len - 1] = '\0';

	return buf.data;
}

/**
 * @brief	Recursively get the check constraint expressions.
 * @param	expr [in] expression.
 * @param	buf [in] StringInfoData.
 * @return	true if success, otherwise fault.
 */
bool CreateTable::get_expr_recurse(Node* expr, StringInfoData* buf) const
{
	bool result{true};

	switch (nodeTag(expr))
	{
		case T_ColumnRef:
			result = get_column_ref((ColumnRef*) expr, buf);
			break;

		case T_A_Const:
			{
				A_Const* con = (A_Const *) expr;
				Value* val = &con->val;
				result = get_a_const(val, buf);
				break;
			}

		case T_A_Expr:
			{
				A_Expr* a = (A_Expr *) expr;
				switch (a->kind)
				{
					case AEXPR_OP:
						result = get_aexpr_op(a, buf);
						break;
					default:
						ereport(INFO, errmsg("unrecognized A_Expr kind: %d", a->kind));
						result = false;
						break;
				}
				break;
			}

		case T_BoolExpr:
			result = get_bool_expr((BoolExpr*) expr, buf);
			break;

		default:
			/* should not reach here */
			ereport(INFO, errmsg("unrecognized expr node type: %d", (int) nodeTag(expr)));
			result = false;
			break;
	}

	return result;
}

/**
 * @brief	Get column name from ColumnRef.
 * @param	expr [in] expression.
 * @param	buf [in] StringInfoData.
 * @return	true if success, otherwise fault.
 */
bool CreateTable::get_column_ref(ColumnRef* cref, StringInfoData* buf) const
{
	bool result{true};

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
				Assert(IsA(field1, String));
				appendStringInfo(buf, "%s ", strVal(field1));
				break;
			}
		case 2:
			{
				Node* field2 = (Node*) lsecond(cref->fields);
				Assert(IsA(field2, String));
				appendStringInfo(buf, "%s ", strVal(field2));
				break;
			}
		case 3:
			{
				Node* field3 = (Node*) lthird(cref->fields);
				Assert(IsA(field3, String));
				appendStringInfo(buf, "%s ", strVal(field3));
				break;
			}
		case 4:
			{
				Node* field4 = (Node*) lfourth(cref->fields);
				Assert(IsA(field4, String));
				appendStringInfo(buf, "%s ", strVal(field4));
				break;
			}
		default:
			ereport(INFO, errmsg("improper qualified name (too many dotted names)"));
			result = false;
			break;
	}

	return result;
}

/**
 * @brief	Get constant value from Value(A_Const).
 * @param	expr [in] expression.
 * @param	buf [in] StringInfoData.
 * @return	true if success, otherwise fault.
 */
bool CreateTable::get_a_const(Value* value, StringInfoData* buf) const
{
	bool result{true};

	switch (nodeTag(value))
	{
		case T_Integer:
			appendStringInfo(buf, "%d ", intVal(value));
			break;
		case T_String:
			appendStringInfo(buf, "\'%s\' ", strVal(value));
			break;
		default:
			ereport(INFO, errmsg("unrecognized a_const node type: %d", (int) nodeTag(value)));
			result = false;
			break;
	}

	return result;
}

/**
 * @brief	Recursively get the check constraint expressions(A_Expr).
 * @param	a [in] expression(A_Expr).
 * @param	buf [in] StringInfoData.
 * @return	true if success, otherwise fault.
 */
bool CreateTable::get_aexpr_op(A_Expr* a, StringInfoData* buf) const
{
	Node* lexpr = a->lexpr;
	Node* rexpr = a->rexpr;
	bool result{true};

	result = get_expr_recurse(lexpr, buf);
	if (result != true) {
		return result;
	}

	switch (list_length(a->name))
	{
		case 1:
			appendStringInfo(buf, "%s ", strVal(linitial(a->name)));
			break;
		default:
			ereport(INFO, errmsg("get_aexpr_op: list_length = %d", list_length(a->name)));
			result = false;
			break;
	}

	result = get_expr_recurse(rexpr, buf);

	return result;
}

/**
 * @brief	Recursively get the check constraint expressions(BoolExpr).
 * @param	a [in] expression(BoolExpr).
 * @param	buf [in] StringInfoData.
 * @return	true if success, otherwise fault.
 */
bool CreateTable::get_bool_expr(BoolExpr* a, StringInfoData* buf) const
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
			ereport(INFO, errmsg("get_bool_expr: unrecognized boolop: %d", (int) a->boolop));
			result = false;
			return result;
	}

	bool set_opname{false};
	foreach(lc, a->args)
	{
		Node* arg = (Node *) lfirst(lc);
		result = get_expr_recurse(arg, buf);
		if (result != true) {
			return result;
		}
		if (set_opname != true) {
			appendStringInfo(buf, "%s ", opname);
			set_opname = true;
		}
	}

	return result;
}

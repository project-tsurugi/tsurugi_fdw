/*
 * Copyright 2019-2020 tsurugi project.
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
 *	@file	  table_metadata.h
 *	@brief  TABLE metadata operations.
 */
#include "create_table.h"

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
#include "catalog/pg_class.h"
#include "nodes/nodes.h"
#include "nodes/parsenodes.h"
#include "nodes/value.h"
#ifdef __cplusplus
}
#endif

using boost::property_tree::ptree;
using namespace manager;

/* base index of ordinal position metadata-manager manages */
const metadata::ObjectIdType ORDINAL_POSITION_BASE_INDEX = 1;

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
							primary_keys.emplace_back(column.ordinal_position);
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
        if (constr->contype != CONSTR_NOTNULL && constr->contype != CONSTR_PRIMARY) {
          ereport(ERROR,
              (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                errmsg("Tsurugi supports only NOT NULL and PRIMARY KEY in column constraint")));
          return result;
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

  List *table_constraints = create_stmt->constraints;

  /* Check table constraints */
  foreach(l, table_constraints) {
    Constraint* constr = (Constraint*) lfirst(l);
    if (constr->contype != CONSTR_PRIMARY) {
        ereport(ERROR,
            (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
              errmsg("Tsurugi supports only PRIMARY KEY in table constraint")));
        return result;
    }
  }
#if 0
  /* Check members of IndexStmt structure */
  if (index_stmt != nullptr) {
    if (index_stmt->unique && !(index_stmt->primary)) {
        show_table_constraint_syntax_error_msg("Tsurugi does not support UNIQUE table constraint");
        return result;
    }

    if (index_stmt->tableSpace != nullptr) {
        ereport(ERROR,
                (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                  errmsg("Tsurugi does not support USING INDEX TABLESPACE clause")));
        return result;
    }

    if (index_stmt->indexIncludingParams != NIL) {
        ereport(ERROR,
                (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                  errmsg("Tsurugi does not support INCLUDE clause")));
        return result;
    }

    if (index_stmt->options != NIL) {
        ereport(ERROR,
                (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                  errmsg("Tsurugi does not support WITH clause")));
        return result;
    }

    if (index_stmt->excludeOpNames != nullptr) {
        show_table_constraint_syntax_error_msg("Tsurugi does not support EXCLUDE table constraint");
        return result;
    }

    if (index_stmt->deferrable) {
        ereport(ERROR,
                (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                  errmsg("Tsurugi does not support DEFERRABLE")));
        return result;
    }

    if (index_stmt->initdeferred) {
        ereport(ERROR,
                (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                  errmsg("Tsurugi does not support INITIALLY DEFERRED")));
        return result;
    }
  }
#endif
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
  auto datatypes = std::make_unique<metadata::DataTypes>("tsurugi");

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
    TypeName *column_def_type_name = column_def->typeName;

    if (column_def_type_name != nullptr) {
      List *type_names = column_def_type_name->names;

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

      if (OidIsValid(column_def_type_name->typeOid)) {
        ptree datatype;
        std::string type_oid_str = std::to_string(column_def_type_name->typeOid);

        /*
          * ErrorCode::OK if the given type is suppoted by Tsurugi,
          * otherwize error code is returned.
          */
        metadata::ErrorCode err = datatypes->get(
              metadata::DataTypes::PG_DATA_TYPE, type_oid_str, datatype);
        /* If the given type is not suppoted, append the list of type oids not supported*/
        if (err != metadata::ErrorCode::OK) {
            type_oid_not_supported.push_back(column_def_type_name->typeOid);
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
bool CreateTable::generate_metadata2(manager::metadata::Table& table)
{
	const CreateStmt* create_stmt = this->create_stmt();
	assert(create_stmt != nullptr);

	bool result{false};
	ptree table_tree;

	//
	// table metadata
	//
	// table name
	RangeVar* relation = (RangeVar*) create_stmt->relation;
	if (relation != nullptr && relation->relname != nullptr) {
		table_tree.put(metadata::Tables::NAME, relation->relname);
		table.name = relation->relname;
	} else {
		show_syntax_error_msg("table name is not specified");
		return result;
	}
	// tuples
	table_tree.put(metadata::Tables::TUPLES, 0);
	table.tuples = 0;

	//
	// columns metadata
	//
	ptree columns_node;

	/* for each columns */
	List* table_elts = create_stmt->tableElts;
	ListCell* listptr;
	int64_t ordinal_position = ORDINAL_POSITION_BASE_INDEX;
	foreach(listptr, table_elts) {
		Node* node = (Node *) lfirst(listptr);
		if (IsA(node, ColumnDef)) {
			ColumnDef* column_def = (ColumnDef*) node;
			ptree column_tree;
			metadata::Column column;

			bool success = create_column_metadata(column_def, 
													ordinal_position, 
													column_tree, 
													column);
			if (!success) {
				return result;
			}
			columns_node.push_back(std::make_pair("", column_tree));
			table.columns.emplace_back(column);
			ordinal_position++;
		}
	}
	table_tree.add_child(metadata::Tables::COLUMNS_NODE, columns_node);

	//
	// primary keys
	//
	table.primary_keys = get_primary_key(create_stmt, table.columns);
	if (table.primary_keys.size() > 0) {
		ptree primary_key;
		for (auto ordinal_position : table.primary_keys) {
			primary_key.put<int64_t>("", ordinal_position);
			primary_key.push_back(std::make_pair("", primary_key));
		}
		table_tree.add_child(metadata::Tables::PRIMARY_KEY_NODE, primary_key);
	}

	result = true;

	return result;
}

/**
 * @brief
 * @param column_def [in] column query tree.
 * @param ordinal_position [in] column ordinal position
 * @param column [out] column metadata
 */
bool CreateTable::create_column_metadata(ColumnDef* column_def, 
                                          int64_t ordinal_position, 
                                          ptree& column_tree,
                                          metadata::Column& column)
{
	assert(column_def != nullptr);

	bool result = false;
	auto datatypes = std::make_unique<metadata::DataTypes>("tsurugi");

	/* ordinalPosition  */
	column_tree.put<int64_t>(metadata::Tables::Column::ORDINAL_POSITION, ordinal_position);
	column.ordinal_position = ordinal_position;

	/* column name */
	column_tree.put(metadata::Tables::Column::NAME, column_def->colname);
	column.name = column_def->colname;

	// nullable
	column_tree.put<bool>(metadata::Tables::Column::NULLABLE, !column_def->is_not_null);
	column.nullable = !(column_def->is_not_null);

	//
	// column data type
	//
	TypeName *column_def_type_name = column_def->typeName;
	if (column_def_type_name == nullptr) {
		show_syntax_error_msg("type name of the column is not specified");
		return result;
	}
	List *type_names = column_def_type_name->names;
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

	// data type ID
	if (OidIsValid(column_def_type_name->typeOid)) {
		ptree datatype;
		std::string type_oid_str = std::to_string(column_def_type_name->typeOid);
		metadata::ErrorCode err = datatypes->get(
			metadata::DataTypes::PG_DATA_TYPE, type_oid_str, datatype);
		if (err == metadata::ErrorCode::OK) {
			data_type_id = datatype.get_optional<metadata::ObjectIdType>(metadata::DataTypes::ID);
		}
	}
	if (!data_type_id) {
		ereport(ERROR,
				(errcode(ERRCODE_INTERNAL_ERROR),
				errmsg("Tsurugi could not found data type ids")));
		return result;
	} 
	metadata::ObjectIdType id = data_type_id.get();
	column_tree.put<metadata::ObjectIdType>(metadata::Tables::Column::DATA_TYPE_ID, id);
	column.data_type_id = id;

	/* put varying metadata if given type is varchar or char */
	switch (static_cast<metadata::DataTypes::DataTypesId>(id)) {
		case metadata:: DataTypes::DataTypesId::VARCHAR: {
			/* put true if given type is varchar */
			column_tree.put<bool>(metadata::Tables::Column::VARYING, true);
			column.varying = true;
			break;
		}
		case metadata::DataTypes::DataTypesId::CHAR: {
			/* put false if given type is char */
			column_tree.put<bool>(metadata::Tables::Column::VARYING, false);
			column.varying = false;
			break;
		}
		default:
			/* other data type */
			column.varying = false;
			break;
	}

	/* put data type lengths metadata if given type is varchar or char */
	switch (static_cast<metadata::DataTypes::DataTypesId>(id)) {
		case metadata::DataTypes::DataTypesId::VARCHAR:
		case metadata::DataTypes::DataTypesId::CHAR: {
			/*
				* if "typmods" is NIL then the actual typmod is expected to
				* be prespecified in typemod, otherwise typemod is unused.
				*/
			List *typmods = column_def_type_name->typmods;
			/* typemod includes varlena header */
			int64_t typemod = (int64_t) column_def_type_name->typemod - VARHDRSZ;
			if (typmods != NIL) {
				/* for data type lengths metadata */
				ptree data_lengths;
				bool success = put_data_lengths(typmods, data_lengths);
				if (!success) {
				return result;
				}
				/* put data type lengths metadata */
				if (!data_lengths.data().empty()) {
					column_tree.add_child(metadata::Tables::Column::DATA_LENGTH, data_lengths);
					column.data_length = 99;
				}
			} else if (typemod >= 0) {
				/* if typmod is -1, typmod is NULL VALUE*/
				/* put a data type length metadata */
				column_tree.put<metadata::ObjectIdType>(metadata::Tables::Column::DATA_LENGTH, typemod);
				column.data_length = typemod;
			}
			break;
		}
		default: {
			/* other data type */
			column.data_length = 0;
			break;
		}
	}  
	result = true;

	return result;
}

bool CreateTable::put_data_lengths(List* typmods, ptree& datalengths)
{
	bool result = false;

	ListCell *l;
	foreach(l, typmods) {
	Node* tm = (Node*) lfirst(l);
	if (IsA(tm, A_Const)) {
		A_Const* ac = (A_Const*) tm;
		if (IsA(&ac->val, Integer)) {
			/*
			* get data type lengths from typmods of TypeName structure.
			* The given data type length must be constant integer value.
			*/
			datalengths.put<metadata::ObjectIdType>("", ac->val.val.ival);
		} else {
			show_syntax_error_msg("can use only integer value in data length");
			return result;
		}
	} else {
		show_syntax_error_msg("can use only constant value in data length");
		return result;
	}
	}
	result = true;

	return result;
}

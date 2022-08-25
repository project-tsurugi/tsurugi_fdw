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
#include <unordered_set>
#include <boost/property_tree/ptree.hpp>
#include <boost/optional.hpp>
#include "manager/metadata/metadata.h"
#include "manager/metadata/datatypes.h"
#include "manager/metadata/tables.h"
#include "manager/metadata/error_code.h"
#include "create_table.h"

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

using namespace boost;
using namespace manager;

/* base index of ordinal position metadata-manager manages */
const metadata::ObjectIdType ORDINAL_POSITION_BASE_INDEX = 1;

/**
 *  @brief  Check if given syntax supported or not by Tsurugi
 *  @return true if supported
 *  @return false otherwise.
 */
bool CreateTable::validate_syntax()
{
  assert(create_stmt() != nullptr);

  CreateStmt* create_stmt = this->create_stmt();
  bool ret_value{false};
  List* table_elts = create_stmt->tableElts;

  /* Check members of CreateStmt structure. */
  if (create_stmt->inhRelations != NIL) {
      ereport(ERROR,
              (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                errmsg("Tsurugi does not support INHERITS clause")));
      return ret_value;
  }

  if (create_stmt->partbound != nullptr) {
      ereport(ERROR,
              (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                errmsg("Tsurugi does not support FOR VALUES clause")));
      return ret_value;
  }

  if (create_stmt->partspec != nullptr) {
      ereport(ERROR,
              (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                errmsg("Tsurugi does not support PARTITION BY clause")));
      return ret_value;
  }

  if (create_stmt->ofTypename != nullptr) {
      ereport(ERROR,
              (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                errmsg("Tsurugi does not support OF typename clause")));
      return ret_value;
  }

  if (create_stmt->options != NIL) {
      ereport(ERROR,
              (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                errmsg("Tsurugi does not support WITH clause")));
      return ret_value;
  }

  if (create_stmt->oncommit != ONCOMMIT_NOOP) {
      ereport(ERROR,
              (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                errmsg("Tsurugi does not support ON COMMIT clause")));
      return ret_value;
  }

#if PG_VERSION_NUM >= 120000
  if (create_stmt->accessMethod != nullptr) {
      ereport(ERROR,
              (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                errmsg("Tsurugi does not support USING clause")));
      return ret_value;
  }
#endif

  /* for duplicate column name check */
  std::unordered_set<std::string> column_names;

  /* Check members of each column */
  ListCell* l;
  foreach(l, table_elts) {
    ColumnDef *colDef = (ColumnDef *)lfirst(l);
    List *colDef_constraints = colDef->constraints;

    /* Check column constraints */
    if (colDef_constraints != NIL) {
      ListCell   *l;
      foreach(l, colDef_constraints) {
        Constraint *constr = (Constraint *) lfirst(l);
        if (constr->contype != CONSTR_NOTNULL && constr->contype != CONSTR_PRIMARY) {
          ereport(ERROR,
              (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                errmsg("Tsurugi supports only NOT NULL and PRIMARY KEY in column constraint")));
          return ret_value;
        }
      }
    }

    /* If COLLATE clause, LIKE clause, DEFAULT constrint, or other syntax, collOid is valid. */
    if ((colDef->collClause != nullptr) | OidIsValid(colDef->collOid)) {
      ereport(ERROR,
              (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                errmsg("Tsurugi does not support COLLATE clause")));
      return ret_value;
    }

    /* Check for duplicates */
    std::string colname = std::string(colDef->colname);
    if (column_names.find(colname) != column_names.end()) {
      ereport(ERROR,
              (errcode(ERRCODE_DUPLICATE_COLUMN),
                errmsg("column \"%s\" specified more than once",
                      colname.c_str()),
                errdetail("Tsurugi does not support this syntax")));
      return ret_value;
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
        return ret_value;
    }
  }
#if 0
  /* Check members of IndexStmt structure */
  if (index_stmt != nullptr) {
    if (index_stmt->unique && !(index_stmt->primary)) {
        show_table_constraint_syntax_error_msg("Tsurugi does not support UNIQUE table constraint");
        return ret_value;
    }

    if (index_stmt->tableSpace != nullptr) {
        ereport(ERROR,
                (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                  errmsg("Tsurugi does not support USING INDEX TABLESPACE clause")));
        return ret_value;
    }

    if (index_stmt->indexIncludingParams != NIL) {
        ereport(ERROR,
                (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                  errmsg("Tsurugi does not support INCLUDE clause")));
        return ret_value;
    }

    if (index_stmt->options != NIL) {
        ereport(ERROR,
                (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                  errmsg("Tsurugi does not support WITH clause")));
        return ret_value;
    }

    if (index_stmt->excludeOpNames != nullptr) {
        show_table_constraint_syntax_error_msg("Tsurugi does not support EXCLUDE table constraint");
        return ret_value;
    }

    if (index_stmt->deferrable) {
        ereport(ERROR,
                (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                  errmsg("Tsurugi does not support DEFERRABLE")));
        return ret_value;
    }

    if (index_stmt->initdeferred) {
        ereport(ERROR,
                (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                  errmsg("Tsurugi does not support INITIALLY DEFERRED")));
        return ret_value;
    }
  }
#endif

#if 0
  /* If statememts except CreateStmt and IndexStmt are given, report error messages. */
  foreach(l, stmts) {
    Node *stmt = (Node *) lfirst(l);

    if (!IsA(stmt, CreateStmt) && !IsA(stmt, IndexStmt)) {
      ereport(ERROR,
          (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
            errmsg("Tsurugi supports only PRIMARY KEY in table constraint"),
            errdetail("Tsurugi does not support FOREIGN KEY table constraint")));
      return ret_value;
    }
  }
#endif
  /*
    * If statements to create temprary or unlogged table are given,
    * report error messages.
    */
  RangeVar* relation = (RangeVar*) create_stmt->relation;
  if (relation != nullptr && relation->relpersistence != RELPERSISTENCE_PERMANENT) {
    ereport(ERROR,
        (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
          errmsg("Tsurugi supports only regular table")));
    return ret_value;
  }

  ret_value = true;

  return ret_value;
}

  /**
   *  @brief  Check if given syntax supported or not by Tsurugi
   *  @return true if supported
   *  @return false otherwise.
   */
bool CreateTable::validate_data_type()
{
  assert(create_stmt() != nullptr);

  bool ret_value{true};
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
    ColumnDef *colDef = (ColumnDef *)lfirst(l);
    TypeName *colDef_type_name = colDef->typeName;

    if (colDef_type_name != nullptr) {
      List *type_names = colDef_type_name->names;

      /*
        * If "names" is NIL then the actual type OID is given by typeOid,
        * otherwise typeOid is unused.
        */
      if (type_names != NIL) {
        bool is_supported{false};

        ListCell   *l;
        foreach(l, type_names) {
          Value *type_name_value = (Value *)lfirst(l);
          std::string type_name{std::string(strVal(type_name_value))};

          property_tree::ptree datatype;
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
            ret_value = false;
        }
      }

      if (OidIsValid(colDef_type_name->typeOid)) {
        property_tree::ptree datatype;
        std::string type_oid_str = std::to_string(colDef_type_name->typeOid);

        /*
          * ErrorCode::OK if the given type is suppoted by Tsurugi,
          * otherwize error code is returned.
          */
        metadata::ErrorCode err = datatypes->get(
              metadata::DataTypes::PG_DATA_TYPE, type_oid_str, datatype);
        /* If the given type is not suppoted, append the list of type oids not supported*/
        if (err != metadata::ErrorCode::OK) {
            type_oid_not_supported.push_back(colDef_type_name->typeOid);
            ret_value = false;
        }
      }
    } else {
      /* If invalid syntax is given, report error messages. */
      show_syntax_error_msg("type name of column is not specified");
      ret_value = false;
      return ret_value;
    }
  }

  /* If given type is not supported, report error messages. */
  if (!ret_value) {
    if (type_names_not_supported != NIL) {
        show_type_error_msg(type_names_not_supported);
    }
    if (!type_oid_not_supported.empty()) {
        show_type_error_msg(type_oid_not_supported);
    }
  }

  return ret_value;
}

/**
 * @brief Generate metadata from query tree.
 * 
 */
bool CreateTable::generate_metadata(property_tree::ptree& table)
{
  assert(create_stmt() != nullptr);

  bool ret_value{false};
  CreateStmt* create_stmt = this->create_stmt();
  RangeVar* relation = (RangeVar*) create_stmt->relation;

  //
  // table metadata
  //
  if (relation != nullptr && relation->relname != nullptr) {
      table.put(metadata::Tables::NAME, relation->relname);
  } else {
      show_syntax_error_msg("table name is not specified");
      return ret_value;
  }

  //
  // primary keys metadata
  //
  property_tree::ptree primary_keys;

  /* get ordinal positions of primary keys in table or column constraints */
  #if 0
  std::unordered_set<metadata::ObjectIdType> op_pkeys = 
      get_ordinal_positions_of_primary_keys(create_stmt, index_stmt);
  #endif

  /* put primary key metadata */
  table.add_child(metadata::Tables::PRIMARY_KEY_NODE, primary_keys);

  //
  // columns metadata
  //
  property_tree::ptree columns;
  int64_t ordinal_position = ORDINAL_POSITION_BASE_INDEX;

  /* for each columns */
  List* table_elts = create_stmt->tableElts;
  ListCell* l;
  foreach(l, table_elts) {
    ColumnDef* colDef = (ColumnDef *) lfirst(l);
    property_tree::ptree column;
    bool success = create_column_metadata(colDef, ordinal_position, column);
    if (!success) {
      return ret_value;
    }
    columns.push_back(std::make_pair("", column));
    ordinal_position++;
  }
  table.add_child(metadata::Tables::COLUMNS_NODE, columns);

  ret_value = true;

  return ret_value;
}

/**
 * @brief
 * @param colDef [in] column query tree.
 * @param ordinal_position [in] column ordinal position
 * @param column [out] column metadata
 */
bool CreateTable::create_column_metadata(ColumnDef* colDef, 
                                          int64_t ordinal_position, 
                                          property_tree::ptree& column)
{
  assert(colDef != nullptr);

  bool ret_value = false;
  auto datatypes = std::make_unique<metadata::DataTypes>("tsurugi");

  /* ordinalPosition  */
  column.put<int64_t>(metadata::Tables::Column::ORDINAL_POSITION, ordinal_position);

  /* column name */
  column.put(metadata::Tables::Column::NAME, colDef->colname);

#if 0
  /*
    * If this column is primary key, put primary key and ascending direction.
    * Otherwise, put default direction.
    */
  if (op_pkeys.find(ordinal_position) == op_pkeys.end()) {
    column.put<int>(metadata::Tables::Column::DIRECTION, static_cast<int>(metadata::Tables::Column::Direction::DEFAULT));
  } else {
    ptree primary_key;
    primary_key.put<metadata::ObjectIdType>("", ordinal_position);
    primary_keys.push_back(std::make_pair("", primary_key));
    column.put<int>(metadata::Tables::Column::DIRECTION, static_cast<int>(metadata::Tables::Column::Direction::ASCENDANT));
  }
#endif

  // nullable
  column.put<bool>(metadata::Tables::Column::NULLABLE, !colDef->is_not_null);

  TypeName *colDef_type_name = colDef->typeName;

  //
  // column data type
  //
  if (colDef_type_name == nullptr) {
    show_syntax_error_msg("type name of the column is not specified");
    return ret_value;
  }

  List *type_names = colDef_type_name->names;
  boost::optional<metadata::ObjectIdType> data_type_id;

  /*
    * If "names" is NIL then the actual type OID is given by typeOid,
    * otherwise typeOid is unused.
    */
  ListCell* l;
  foreach(l, type_names) {
    Value* type_name_value = (Value*) lfirst(l);

    std::string type_name{std::string(strVal(type_name_value))};

    // PG data type qualified name
    property_tree::ptree datatype;
    metadata::ErrorCode error = datatypes->get(
        metadata::DataTypes::PG_DATA_TYPE_QUALIFIED_NAME, type_name, datatype);
    if (error == metadata::ErrorCode::OK) {
        data_type_id = datatype.get_optional<metadata::ObjectIdType>(metadata::DataTypes::ID);
        break;
    }
  }

  // data type ID
  if (OidIsValid(colDef_type_name->typeOid)) {
      property_tree::ptree datatype;
      std::string type_oid_str = std::to_string(colDef_type_name->typeOid);

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
    return ret_value;
  } 
  metadata::ObjectIdType id = data_type_id.get();
  column.put<metadata::ObjectIdType>(metadata::Tables::Column::DATA_TYPE_ID, id);

  /* put varying metadata if given type is varchar or char */
  switch (static_cast<metadata::DataTypes::DataTypesId>(id)) {
      case metadata:: DataTypes::DataTypesId::VARCHAR:
          /* put true if given type is varchar */
          column.put<bool>(metadata::Tables::Column::VARYING, true);
          break;
      case metadata::DataTypes::DataTypesId::CHAR:
          /* put false if given type is char */
          column.put<bool>(metadata::Tables::Column::VARYING, false);
          break;
      default:
          /* other data type */
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
        List *typmods = colDef_type_name->typmods;

        /* typemod includes varlena header */
        int typemod = (int)colDef_type_name->typemod - VARHDRSZ;
        if (typmods != NIL) {
          /* for data type lengths metadata */
          property_tree::ptree datalengths;
          bool success = put_data_lengths(typmods, datalengths);
          if (!success) {
            return ret_value;
          }
          /* put data type lengths metadata */
          if (!datalengths.data().empty()) {
              column.add_child(metadata::Tables::Column::DATA_LENGTH, datalengths);
          }
        } else if (typemod >= 0) {
          /* if typmod is -1, typmod is NULL VALUE*/
            /* put a data type length metadata */
            column.put<metadata::ObjectIdType>(metadata::Tables::Column::DATA_LENGTH, typemod);
        }
        break;
    }
    default:
        /* other data type */
        break;
  }
  ret_value = true;

  return ret_value;
}

bool CreateTable::put_data_lengths(List* typmods, property_tree::ptree& datalengths)
{
  bool ret_value = false;

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
          return ret_value;
      }
    } else {
      show_syntax_error_msg("can use only constant value in data length");
      return ret_value;
    }
  }
  ret_value = true;

  return ret_value;
}

/**
 *  @brief  Get ordinal positions of table's primary key columns in table or column constraints.
 *  @return ordinal positions of table's primary key columns.
 */
std::unordered_set<metadata::ObjectIdType>
get_ordinal_positions_of_primary_keys(CreateStmt* create_stmt, IndexStmt* index_stmt)
{
    std::unordered_set<metadata::ObjectIdType> op_pkeys;

    /* true if table constraints include primary key constraint */
    bool has_table_pkey = false;

    /* Check if table constraints include primary key constraint */
    if (index_stmt != nullptr && index_stmt->primary)
    {
        has_table_pkey = true;

        metadata::ObjectIdType ordinal_position = ORDINAL_POSITION_BASE_INDEX;

        List *table_elts = create_stmt->tableElts;
        ListCell *lte;

        List *index_params = index_stmt->indexParams;
        ListCell *lip;

        foreach(lte, table_elts)
        {
            foreach(lip, index_params)
            {
                IndexElem *index_elem = (IndexElem *) lfirst(lip);
                ColumnDef *colDef = (ColumnDef *) lfirst(lte);

                /* Get oridinal positions of table constraints' primary key columns */
                if (strcmp(index_elem->name, colDef->colname) == 0)
                {
                    op_pkeys.insert(ordinal_position);
                }
            }
            ordinal_position++;
        }
    }

    /*
     * If table constraints does not include primary key constraint,
     * check if column constraints include primary key constraint.
     */
    if (!has_table_pkey) {
        metadata::ObjectIdType ordinal_position = ORDINAL_POSITION_BASE_INDEX;

        List* table_elts = create_stmt->tableElts;
        ListCell* l;

        foreach(l, table_elts)
        {
            ColumnDef *colDef = (ColumnDef *) lfirst(l);

            List *colDef_constraints = colDef->constraints;

            if (colDef_constraints != NIL)
            {
                ListCell   *l;
                foreach(l, colDef_constraints)
                {
                    Constraint *constr = (Constraint *)lfirst(l);

                    /* Get oridinal positions of column constraints' primary key columns */
                    if (constr->contype == CONSTR_PRIMARY)
                    {
                        op_pkeys.insert(ordinal_position);
                    }
                }
            }
            ordinal_position++;
        }
    }

    return op_pkeys;
}

/**
 *  @brief  Reports error message that given table constraint is not supported by Tsurugi.
 *  @param  [in] The primary message.
 */
void
show_table_constraint_syntax_error_msg(const char *error_message)
{
    ereport(ERROR,
        (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
         errmsg("%s",error_message),
         errdetail("Tsurugi supports only PRIMARY KEY in table constraint")));
}

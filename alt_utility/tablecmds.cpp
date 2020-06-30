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
 *	@file	tablecmds.cpp
 *	@brief  Sends metadata to metadata-manager.
 */

#include <boost/optional.hpp>
#include <iostream>
#include <string>

#include "manager/metadata/datatypes.h"
#include "manager/metadata/metadata.h"
#include "manager/metadata/tables.h"

using namespace manager::metadata;
using namespace boost::property_tree;

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

#include "tablecmds.h"

/**
 * @brief C'tors. Initialize member variables.
 * @param [in] List of statements.
 */
CreateTable::CreateTable(List *stmts) : stmts(stmts)
{
    create_stmt = nullptr;
    index_stmt = nullptr;

    ListCell *l;

    foreach(l, stmts)
    {
        Node *stmt = (Node *) lfirst(l);

        if (IsA(stmt, CreateStmt))
        {
            create_stmt = (CreateStmt *)stmt;
        }
        else if (IsA(stmt, IndexStmt))
        {
            index_stmt = (IndexStmt *)stmt;
        }
    }
}

/**
 *  @brief  Defines relation include loading metadata, syntax check, type check, storing metadata.
 *  @param  [out] The object id stored if new table was successfully created.
 *  @return true if metadata was successfully stored
 *  @return false otherwize
 */
bool
CreateTable::define_relation( uint64_t* object_id )
{
    Assert(create_stmt != nullptr);

    /* return value */
    bool ret_value{false};

    /* load metadata */
    if (!load_metadata())
    {
        return ret_value;
    }

    /* check if given syntax supported or not by Tsurugi */
    if (!is_syntax_supported())
    {
        return ret_value;
    }

    /* check if given type supported or not by Tsurugi */
    if (!is_type_supported())
    {
        return ret_value;
    }

    /* send metadata to metadata manager */
    if (!store_metadata( object_id ))
    {
        return ret_value;
    }

    ret_value = true;
    return ret_value;
}

/**
 *  @brief  Loads metadata from metadata-manager.
 *  @return true if metadata was successfully loaded
 *  @return false otherwize.
 */
bool
CreateTable::load_metadata()
{
    /* return value */
    bool ret_value{false};

    /* Loads data type metadata */
    datatypes = std::make_unique<DataTypes>(dbname);

    if (datatypes->load() != ErrorCode::OK)
    {
        ereport(ERROR,
            (errcode(ERRCODE_INTERNAL_ERROR),
             errmsg("Tsurugi could not load data type metadata")));
        return ret_value;
    }

    /* Loads table metadata */
    tables = std::make_unique<Tables>(dbname);

    if (tables->load() != ErrorCode::OK)
    {
        ereport(ERROR,
            (errcode(ERRCODE_INTERNAL_ERROR),
             errmsg("Tsurugi could not load table metadata")));
        return ret_value;
    }

    ret_value = true;
    return ret_value;
}

/**
 *  @brief  Check if given type supported or not by Tsurugi
 *  @return true if supported
 *  @return false otherwise.
 */
bool
CreateTable::is_type_supported()
{
    /* return value */
    bool ret_value{true};

    List *table_elts = create_stmt->tableElts;
    ListCell *l;

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
    foreach(l, table_elts)
    {
        ColumnDef *colDef = (ColumnDef *)lfirst(l);
        TypeName *colDef_type_name = colDef->typeName;

        if (colDef_type_name != nullptr)
        {
            List *type_names = colDef_type_name->names;

            /*
             * If "names" is NIL then the actual type OID is given by typeOid,
             * otherwise typeOid is unused.
             */
            if (type_names != NIL)
            {
                bool is_supported{false};

                ListCell   *l;
                foreach(l, type_names)
                {
                    Value *type_name_value = (Value *)lfirst(l);
                    std::string type_name{std::string(strVal(type_name_value))};

                    ptree datatype;
                    /*
                     * ErrorCode::OK if the given type name is suppoted by Tsurugi,
                     * otherwize error code is returned.
                     */
                    ErrorCode err = datatypes->get(DataTypes::PG_DATA_TYPE_QUALIFIED_NAME, type_name, datatype);
                    if (err == ErrorCode::OK)
                    {
                        is_supported = true;
                    }
                }

                /* If the given type name is not suppoted, append the list of type names not supported*/
                if (!is_supported)
                {
                    type_names_not_supported = lappend(type_names_not_supported,type_names);
                    ret_value = false;
                }
            }

            if (OidIsValid(colDef_type_name->typeOid))
            {
                ptree datatype;
                std::string type_oid_str = std::to_string(colDef_type_name->typeOid);

                /*
                 * ErrorCode::OK if the given type is suppoted by Tsurugi,
                 * otherwize error code is returned.
                 */
                ErrorCode err = datatypes->get(DataTypes::PG_DATA_TYPE, type_oid_str, datatype);
                /* If the given type is not suppoted, append the list of type oids not supported*/
                if (err != ErrorCode::OK)
                {
                    type_oid_not_supported.push_back(colDef_type_name->typeOid);
                    ret_value = false;
                }
            }

        }
        else
        {
            /* If invalid syntax is given, report error messages. */
            show_syntax_error_msg("type name of column is not specified");
            ret_value = false;
            return ret_value;
        }
    }

    /* If given type is not supported, report error messages. */
    if (!ret_value)
    {
        if (type_names_not_supported != NIL)
        {
            show_type_error_msg(type_names_not_supported);
        }

        if (!type_oid_not_supported.empty())
        {
            show_type_error_msg(type_oid_not_supported);
        }
    }

    return ret_value;
}

/**
 *  @brief  Check if given syntax supported or not by Tsurugi
 *  @return true if supported
 *  @return false otherwise.
 */
bool
CreateTable::is_syntax_supported()
{
    /* return value */
    bool ret_value{false};
    ListCell *l;

    List *table_elts = create_stmt->tableElts;

    /* Check members of CreateStmt structure. */
    if (create_stmt->inhRelations != NIL)
    {
        ereport(ERROR,
                (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                 errmsg("Tsurugi does not support INHERITS clause")));
        return ret_value;
    }

    if (create_stmt->partbound != nullptr)
    {
        ereport(ERROR,
                (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                 errmsg("Tsurugi does not support FOR VALUES clause")));
        return ret_value;
    }

    if (create_stmt->partspec != nullptr)
    {
        ereport(ERROR,
                (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                 errmsg("Tsurugi does not support PARTITION BY clause")));
        return ret_value;
    }

    if (create_stmt->ofTypename != nullptr)
    {
        ereport(ERROR,
                (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                 errmsg("Tsurugi does not support OF typename clause")));
        return ret_value;
    }

    if (create_stmt->options != NIL)
    {
        ereport(ERROR,
                (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                 errmsg("Tsurugi does not support WITH clause")));
        return ret_value;
    }

    if (create_stmt->oncommit != ONCOMMIT_NOOP)
    {
        ereport(ERROR,
                (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                 errmsg("Tsurugi does not support ON COMMIT clause")));
        return ret_value;
    }

#if PG_VERSION_NUM >= 120000
    if (create_stmt->accessMethod != nullptr)
    {
        ereport(ERROR,
                (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                 errmsg("Tsurugi does not support USING clause")));
        return ret_value;
    }
#endif

    /* Check members of each column */
    foreach(l, table_elts)
    {
        ColumnDef *colDef = (ColumnDef *)lfirst(l);
        List *colDef_constraints = colDef->constraints;

        /* Check column constraints */
        if (colDef_constraints != NIL)
        {
            ListCell   *l;
            foreach(l, colDef_constraints)
            {
                Constraint *constr = (Constraint *)lfirst(l);

                if (constr->contype != CONSTR_NOTNULL && constr->contype != CONSTR_PRIMARY)
                {
                    ereport(ERROR,
                        (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                         errmsg("Tsurugi supports only NOT NULL and PRIMARY KEY in column constraint")));
                    return ret_value;
                }
            }
        }

        /* If COLLATE clause, LIKE clause, DEFAULT constrint, or other syntax, collOid is valid. */
        if ((colDef->collClause != nullptr) | OidIsValid(colDef->collOid))
        {
            ereport(ERROR,
                    (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                     errmsg("Tsurugi does not support COLLATE clause")));
            return ret_value;
        }
    }

    List *table_constraints = create_stmt->constraints;

    /* Check table constraints */
    foreach(l, table_constraints)
    {
        Constraint *constr = (Constraint *)lfirst(l);

        if (constr->contype != CONSTR_PRIMARY)
        {
            ereport(ERROR,
                (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                 errmsg("Tsurugi supports only PRIMARY KEY in table constraint")));
            return ret_value;
        }
    }

    /* Check members of IndexStmt structure */
    if (index_stmt != nullptr)
    {
        if (index_stmt->unique && !(index_stmt->primary))
        {
            show_table_constraint_syntax_error_msg("Tsurugi does not support UNIQUE table constraint");
            return ret_value;
        }

        if (index_stmt->tableSpace != nullptr)
        {
            ereport(ERROR,
                    (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                     errmsg("Tsurugi does not support USING INDEX TABLESPACE clause")));
            return ret_value;
        }

        if (index_stmt->indexIncludingParams != NIL)
        {
            ereport(ERROR,
                    (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                     errmsg("Tsurugi does not support INCLUDE clause")));
            return ret_value;
        }

        if (index_stmt->options != NIL)
        {
            ereport(ERROR,
                    (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                     errmsg("Tsurugi does not support WITH clause")));
            return ret_value;
        }

        if (index_stmt->excludeOpNames != nullptr)
        {
            show_table_constraint_syntax_error_msg("Tsurugi does not support EXCLUDE table constraint");
            return ret_value;
        }

        if (index_stmt->deferrable)
        {
            ereport(ERROR,
                    (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                     errmsg("Tsurugi does not support DEFERRABLE")));
            return ret_value;
        }

        if (index_stmt->initdeferred)
        {
            ereport(ERROR,
                    (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                     errmsg("Tsurugi does not support INITIALLY DEFERRED")));
            return ret_value;
        }

    }

    /* If statememts except CreateStmt and IndexStmt are given, report error messages. */
    foreach(l, stmts)
    {
        Node *stmt = (Node *) lfirst(l);

        if (!IsA(stmt, CreateStmt) && !IsA(stmt, IndexStmt))
        {
            ereport(ERROR,
                (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                 errmsg("Tsurugi supports only PRIMARY KEY in table constraint"),
                 errdetail("Tsurugi does not support FOREIGN KEY table constraint")));
            return ret_value;
        }
    }

    /*
     * If statements to create temprary or unlogged table are given,
     * report error messages.
     */
    RangeVar *relation = (RangeVar *)create_stmt->relation;
    if (relation != nullptr && relation->relpersistence != RELPERSISTENCE_PERMANENT)
    {
        ereport(ERROR,
            (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
             errmsg("Tsurugi supports only regular table")));
        return ret_value;
    }

    ret_value = true;
    return ret_value;
}

/**
 *  @brief  Sends metadata to metadata-manager.
 *  @param  [out] The object id stored if new table was successfully created.
 *  @return true if metadata was successfully sended
 *  @return false otherwize.
 */
bool
CreateTable::store_metadata( uint64_t* object_id )
{

    bool ret_value{false};

    /* table metadata of newly created table */
    ptree new_table;

    RangeVar *relation = (RangeVar *)create_stmt->relation;

    char *relname = nullptr;

    /* put table name metadata */
    if (relation != nullptr && relation->relname != nullptr)
    {
        relname = relation->relname;
        new_table.put(Tables::NAME, relname);
    }
    else
    {
        show_syntax_error_msg("table name is not specified");
        return ret_value;
    }

    /* for primary keys metadata */
    ptree primary_keys;

    /* get ordinal positions of primary keys in table or column constraints */
    std::unordered_set<uint64_t> op_pkeys = get_ordinal_positions_of_primary_keys();

    /* for columns metadata */
    ptree columns;
    uint64_t ordinal_position = ORDINAL_POSITION_BASE_INDEX;

    List *table_elts = create_stmt->tableElts;
    ListCell *l;

    /* for each columns */
    foreach(l, table_elts)
    {
        ColumnDef *colDef = (ColumnDef *)lfirst(l);

        /* for each column metadata */
        ptree column;

        /* put ordinalPosition metadata */
        column.put<uint64_t>(Tables::Column::ORDINAL_POSITION, ordinal_position);

        /* put column name metadata */
        column.put(Tables::Column::NAME, colDef->colname);

        /*
         * If this column is primary key, put primary key and ascending direction.
         * Otherwise, put default direction.
         */
        if (op_pkeys.find(ordinal_position) == op_pkeys.end())
        {
            column.put<uint64_t>(Tables::Column::DIRECTION,TSURUGI_DIRECTION_DEFAULT);
        }
        else
        {
            ptree primary_key;
            primary_key.put<uint64_t>("", ordinal_position);
            primary_keys.push_back(std::make_pair("", primary_key));

            column.put<uint64_t>(Tables::Column::DIRECTION,TSURUGI_DIRECTION_ASC);
        }

        /* put nullable metadata */
        column.put<bool>(Tables::Column::NULLABLE, !colDef->is_not_null);

        TypeName *colDef_type_name = colDef->typeName;

        /* put type metadata */
        if (colDef_type_name != nullptr)
        {
            List *type_names = colDef_type_name->names;
            boost::optional<ObjectIdType> data_type_id;

            ListCell   *l;
            /*
             * If "names" is NIL then the actual type OID is given by typeOid,
             * otherwise typeOid is unused.
             */
            foreach(l, type_names)
            {
                Value *type_name_value = (Value *)lfirst(l);
                std::string type_name{std::string(strVal(type_name_value))};

                ErrorCode err;
                ptree datatype;

                /* get dataTypeId from metadata-manager */
                err = datatypes->get(DataTypes::PG_DATA_TYPE_QUALIFIED_NAME, type_name, datatype);
                if (err == ErrorCode::OK)
                {
                    data_type_id = datatype.get_optional<ObjectIdType>(DataTypes::ID);
                    break;
                }
            }

            if (OidIsValid(colDef_type_name->typeOid))
            {
                ptree datatype;
                std::string type_oid_str = std::to_string(colDef_type_name->typeOid);

                /* get dataTypeId from metadata-manager */
                ErrorCode err = datatypes->get(DataTypes::PG_DATA_TYPE, type_oid_str, datatype);
                if (err == ErrorCode::OK)
                {
                    data_type_id = datatype.get_optional<ObjectIdType>(DataTypes::ID);
                }
            }

            if (!data_type_id)
            {
                ereport(ERROR,
                    (errcode(ERRCODE_INTERNAL_ERROR),
                     errmsg("Tsurugi could not get data type ids")));
                return ret_value;
            }
            else
            {
                /* put dataTypeId metadata */
                ObjectIdType id = data_type_id.get();
                column.put<ObjectIdType>(Tables::Column::DATA_TYPE_ID, id);

                /* put varying metadata if given type is varchar or char */
                if (id == TSURUGI_TYPE_VARCHAR_ID)
                {
                    /* put true if given type is varchar */
                    column.put<bool>(Tables::Column::VARYING, true);
                }
                else if (id == TSURUGI_TYPE_CHAR_ID)
                {
                    /* put false if given type is char */
                    column.put<bool>(Tables::Column::VARYING, false);
                }

                /* put data type lengths metadata if given type is varchar or char */
                switch (id)
                {
                    case TSURUGI_TYPE_VARCHAR_ID:
                    case TSURUGI_TYPE_CHAR_ID:
                        /*
                         * if "typmods" is NIL then the actual typmod is expected to
                         * be prespecified in typemod, otherwise typemod is unused.
                         */
                        List *typmods = colDef_type_name->typmods;

                        /* typemod includes varlena header */
                        int typemod = (int)colDef_type_name->typemod - VARHDRSZ;

                        if (typmods != NIL)
                        {
                            /* for data type lengths metadata */
                            ptree datalengths;

                            ListCell *l;
                            foreach(l, typmods)
                            {
                                Node *tm = (Node *) lfirst(l);

                                if (IsA(tm, A_Const))
                                {
                                    A_Const    *ac = (A_Const *) tm;

                                    if (IsA(&ac->val, Integer))
                                    {
                                        /*
                                         * get data type lengths from typmods of TypeName structure.
                                         * The given data type length must be constant integer value.
                                         */
                                        datalengths.put<uint64_t>("", ac->val.val.ival);
                                    }
                                    else
                                    {
                                        show_syntax_error_msg("can use only integer value in data length");
                                        return ret_value;
                                    }
                                }
                                else
                                {
                                    show_syntax_error_msg("can use only constant value in data length");
                                    return ret_value;
                                }
                            }

                            /* put data type lengths metadata */
                            if (!datalengths.data().empty())
                            {
                                column.add_child(Tables::Column::DATA_LENGTH, datalengths);
                            }
                        }
                        /* if typmod is -1, typmod is NULL VALUE*/
                        else if (typemod >= 0)
                        {
                            /* put a data type length metadata */
                            column.put<uint64_t>(Tables::Column::DATA_LENGTH, typemod);
                        }

                }

            }

        }
        else
        {
            show_syntax_error_msg("type name of the column is not specified");
            return ret_value;
        }

        columns.push_back(std::make_pair("", column));
        ordinal_position++;
    }

    /* put primary key metadata */
    new_table.add_child(Tables::PRIMARY_KEY_NODE, primary_keys);

    /* put column metadata */
    new_table.add_child(Tables::COLUMNS_NODE, columns);

    ErrorCode error = ErrorCode::UNKNOWN;

    error = tables->add(new_table, object_id);

    switch (error)
    {
        case ErrorCode::OK:
            ret_value = true;
            return ret_value;
            break;
        case ErrorCode::TABLE_NAME_ALREADY_EXISTS:
            if (create_stmt->if_not_exists)
            {
                ereport(NOTICE,
                    (errcode(ERRCODE_DUPLICATE_TABLE),
                     errmsg("table name \"%s\" already exsists, skipping", relname)));
            }
            else{
                ereport(ERROR,
                    (errcode(ERRCODE_DUPLICATE_TABLE),
                     errmsg("table name \"%s\" already exsists", relname)));
            }
            return ret_value;
            break;
        default:
            ereport(ERROR,
                (errcode(ERRCODE_INTERNAL_ERROR),
                 errmsg("Tsurugi could not store table metadata")));
            return ret_value;
    }

}

/**
 *  @brief  Get ordinal positions of table's primary key columns in table or column constraints.
 *  @return ordinal positions of table's primary key columns.
 */
std::unordered_set<uint64_t>
CreateTable::get_ordinal_positions_of_primary_keys()
{
    std::unordered_set<uint64_t> op_pkeys;

    /* true if table constraints include primary key constraint */
    bool has_table_pkey = false;

    /* Check if table constraints include primary key constraint */
    if (index_stmt != nullptr && index_stmt->primary)
    {
        has_table_pkey = true;

        uint64_t ordinal_position = ORDINAL_POSITION_BASE_INDEX;

        List *table_elts = create_stmt->tableElts;
        ListCell *lte;

        List *index_params = index_stmt->indexParams;
        ListCell *lip;

        foreach(lte, table_elts)
        {
            foreach(lip, index_params)
            {
                IndexElem *index_elem = (IndexElem *)lfirst(lip);
                ColumnDef *colDef = (ColumnDef *)lfirst(lte);

                char *index_elem_name = index_elem->name;
                char *coldef_colname = colDef->colname;

                /* Get oridinal positions of table constraints' primary key columns */
                if (strcmp(index_elem_name,coldef_colname) == 0)
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
    if (!has_table_pkey)
    {
        uint64_t ordinal_position = ORDINAL_POSITION_BASE_INDEX;

        List *table_elts = create_stmt->tableElts;
        ListCell *l;

        foreach(l, table_elts)
        {
            ColumnDef *colDef = (ColumnDef *)lfirst(l);

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
 *  @brief  Reports error message that given types are not supported by Tsurugi.
 *  @param  [in] List of TypeName structure's member "names".
 */
void
CreateTable::show_type_error_msg(List *type_names)
{
    ereport(ERROR,
        (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
         errmsg("Tsurugi does not support type %s", nodeToString(type_names))));
}

/**
 *  @brief  Reports error message that given types are not supported by Tsurugi.
 *  @param  [in] List of TypeName structure's member "typeOid".
 */
void
CreateTable::show_type_error_msg(std::vector<int> type_oids)
{
    std::stringstream type_oid_str;
    std::copy(type_oids.begin(), type_oids.end(), std::ostream_iterator<int>(type_oid_str, ", "));

    ereport(ERROR,
        (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
         errmsg("Tsurugi does not support type oid %s", type_oid_str.str().c_str())));
}

/**
 *  @brief  Reports error message that given syntax is not supported by Tsurugi.
 *  @param  [in] The primary message.
 */
void
CreateTable::show_syntax_error_msg(const char *error_message)
{
    ereport(ERROR,
        (errcode(ERRCODE_SYNTAX_ERROR),
         errmsg("%s",error_message),
         errdetail("Tsurugi does not support this syntax")));
}

/**
 *  @brief  Reports error message that given table constraint is not supported by Tsurugi.
 *  @param  [in] The primary message.
 */
void
CreateTable::show_table_constraint_syntax_error_msg(const char *error_message)
{
    ereport(ERROR,
        (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
         errmsg("%s",error_message),
         errdetail("Tsurugi supports only PRIMARY KEY in table constraint")));
}

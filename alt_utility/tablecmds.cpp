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
 *	@brief
 */

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
#include "nodes/nodes.h"
#include "nodes/parsenodes.h"
#include "nodes/value.h"
#ifdef __cplusplus
}
#endif

#include "tablecmds.h"

/*
 * @brief C'tors
 */

CreateTable::CreateTable(List *stmts)
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

/*
 *  @brief:
 */
bool
CreateTable::define_relation()
{
    Assert(create_stmt != nullptr);

    bool ret_value{false};

    std::cout << nodeToString(create_stmt) << std::endl;
    std::cout << nodeToString(index_stmt) << std::endl;

    // load metadata
    if (!load_metadata())
    {
        elog(ERROR, "define_relation() failed.");
        return ret_value;
    }

    // check syntax supported or not by Tsurugi
    if (!is_syntax_supported())
    {
        elog(ERROR, "define_relation() failed.");
        return ret_value;
    }

    // check type supported or not by Tsurugi
    if (!is_type_supported())
    {
        elog(ERROR, "define_relation() failed.");
        return ret_value;
    }

    // send metadata to metadata manager
    if (!store_metadata())
    {
        elog(ERROR, "define_relation() failed.");
        return ret_value;
    }

    ret_value = true;
    return ret_value;
}

bool
CreateTable::load_metadata()
{
    bool ret_value{false};

    datatypes = std::make_unique<DataTypes>(dbname);

    if (datatypes->load() != ErrorCode::OK)
    {
        std::cout << "DataTypes::load() error." << std::endl;
        return ret_value;
    }

    tables = std::make_unique<Tables>(dbname);

    if (tables->load() != ErrorCode::OK)
    {
        std::cout << "Tables::load() error." << std::endl;
        return ret_value;
    }

    ret_value = true;
    return ret_value;
}

bool
CreateTable::is_type_supported()
{
    bool ret_value{true};

    List *table_elts = create_stmt->tableElts;
    ListCell *l;

    List *type_names_not_supported = NIL;

    foreach(l, table_elts)
    {
        ColumnDef *colDef = (ColumnDef *)lfirst(l);
        TypeName *colDef_type_name = colDef->typeName;

        if (colDef_type_name != nullptr)
        {
            List *type_names = colDef_type_name->names;

            bool is_supported{false};

            ListCell   *l;
            foreach(l, type_names)
            {
                Value *type_name_value = (Value *)lfirst(l);
                std::string type_name{std::string(strVal(type_name_value))};
                ErrorCode err;
                ptree datatype;
                err = datatypes->get(DataTypes::PG_DATA_TYPE_QUALIFIED_NAME, type_name, datatype);
                if (err == ErrorCode::OK)
                {
                    is_supported = true;
                }
            }

            if (!is_supported)
            {
                type_names_not_supported = lappend(type_names_not_supported,type_names);
                ret_value = false;
            }
        }
        else
        {
            show_syntax_error_msg();
            ret_value = false;
            return ret_value;
        }
    }

    if (!ret_value)
    {
        show_type_error_msg(type_names_not_supported);
    }

    return ret_value;
}

bool
CreateTable::is_syntax_supported()
{
    bool ret_value{true};
    return ret_value;
}

bool
CreateTable::store_metadata()
{

    bool ret_value{false};

    // table
    ptree new_table;

    // tbale name
    RangeVar *relation = (RangeVar *)create_stmt->relation;

    if (relation != nullptr && relation->relname != nullptr)
    {
        char *relname = relation->relname;
        new_table.put(Tables::NAME, relname);
    }
    else
    {
        show_syntax_error_msg();
        return ret_value;
    }

    // primaryKey
    ptree primary_keys;
    std::unordered_set<uint64_t> op_pkeys = get_ordinal_positions_of_primary_keys();

    // columns
    ptree columns;
    uint64_t ordinal_position = ORDINAL_POSITION_BASE_INDEX;

    List *table_elts = create_stmt->tableElts;
    ListCell *l;

    foreach(l, table_elts)
    {
        ColumnDef *colDef = (ColumnDef *)lfirst(l);

        // column
        ptree column;

        // ordinalPosition
        column.put<uint64_t>(Tables::Column::ORDINAL_POSITION, ordinal_position);

        // column name
        column.put(Tables::Column::NAME, colDef->colname);

        List *colDef_constraints = colDef->constraints;
        bool nullable = true;

        if (colDef_constraints != nullptr)
        {
            ListCell   *l;
            foreach(l, colDef_constraints)
            {
                Constraint *constr = (Constraint *)lfirst(l);

                if (constr->contype == CONSTR_NOTNULL)
                {
                    // nullable
                    nullable = false;
                }
            }
        }

        // nullable
        column.put<bool>(Tables::Column::NULLABLE, nullable);

        // primary key and direction
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

        TypeName *colDef_type_name = colDef->typeName;

        if (colDef_type_name != nullptr)
        {
            List *type_names = colDef_type_name->names;
            ObjectIdType data_type_id;

            ListCell   *l;
            foreach(l, type_names)
            {
                Value *type_name_value = (Value *)lfirst(l);
                std::string type_name{std::string(strVal(type_name_value))};
                // get dataTypeId
                ErrorCode err;
                ptree datatype;
                err = datatypes->get(DataTypes::PG_DATA_TYPE_QUALIFIED_NAME, type_name, datatype);
                if (err == ErrorCode::OK)
                {
                    data_type_id = datatype.get<ObjectIdType>(DataTypes::ID);
                    if (!data_type_id)
                    {
                        return ret_value;
                    }
                    else
                    {
                        // put dataTypeId
                        column.put<ObjectIdType>(Tables::Column::DATA_TYPE_ID, data_type_id);
                    }
                    break;
                }
            }

            List *typmods = colDef_type_name->typmods;
            int32 typemod = colDef_type_name->typemod;

            if (typmods != NIL)
            {
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
                            datalengths.put<uint64_t>("", ac->val.val.ival);
                        }
                        else
                        {
                            show_syntax_error_msg();
                            return ret_value;
                        }
                    }
                    else
                    {
                        show_syntax_error_msg();
                        return ret_value;
                    }
                }

                if (!datalengths.empty())
                {
                    column.add_child(Tables::Column::DATA_LENGTH, datalengths);
                }
            }
            else if (typemod != TYPEMOD_NULL_VALUE )
            {
                column.put<uint64_t>(Tables::Column::DATA_LENGTH, typemod);
            }

            if (!data_type_id)
            {
                if (data_type_id == TSURUGI_TYPE_VARCHAR_ID)
                {
                    // varying
                    column.put<bool>(Tables::Column::VARYING, true);
                }
                else if (data_type_id == TSURUGI_TYPE_CHAR_ID)
                {
                    // varying
                    column.put<bool>(Tables::Column::VARYING, false);
                }
            }

        }
        else
        {
            show_syntax_error_msg();
        }

        columns.push_back(std::make_pair("", column));
        ordinal_position++;
    }

    // primary key
    if (!primary_keys.empty())
    {
        new_table.add_child(Tables::PRIMARY_KEY_NODE, primary_keys);
    }

    if (!columns.empty())
    {
        new_table.add_child(Tables::COLUMNS_NODE, columns);
    }
    else
    {
        show_syntax_error_msg();
        return ret_value;
    }

    if (tables->add(new_table) != ErrorCode::OK)
    {
        elog(ERROR, "define_relation() failed.");
        return ret_value;
    }

    ret_value = true;
    return ret_value;
}

std::unordered_set<uint64_t>
CreateTable::get_ordinal_positions_of_primary_keys()
{
    std::unordered_set<uint64_t> op_pkeys;
    bool has_table_pkey = false;

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
                if (strcmp(index_elem_name,coldef_colname) == 0)
                {
                    op_pkeys.insert(ordinal_position);
                }
            }
            ordinal_position++;
        }
    }

    if (!has_table_pkey)
    {
        uint64_t ordinal_position = ORDINAL_POSITION_BASE_INDEX;

        List *table_elts = create_stmt->tableElts;
        ListCell *l;

        foreach(l, table_elts)
        {
            ColumnDef *colDef = (ColumnDef *)lfirst(l);

            List *colDef_constraints = colDef->constraints;

            if (colDef_constraints != nullptr)
            {
                ListCell   *l;
                foreach(l, colDef_constraints)
                {
                    Constraint *constr = (Constraint *)lfirst(l);

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

void
CreateTable::show_type_error_msg(List *type_names)
{
    elog(ERROR, "Tsurugi does not support type \"%s\".", nodeToString(type_names));
}

void
CreateTable::show_syntax_error_msg()
{
    elog(ERROR, "Tsurugi does not support this syntax.");
}

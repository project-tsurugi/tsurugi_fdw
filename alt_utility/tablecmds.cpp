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

const std::string dbname{"Tsurugi"};

const int TSURUGI_TYPE_CHAR_ID = 13;
const int TSURUGI_TYPE_VARCHAR_ID = 14;

const int TSURUGI_DIRECTION_DEFAULT = 0;
const int TSURUGI_DIRECTION_ASC = 1;
const int TSURUGI_DIRECTION_DESC = 2;

const int TYPEMOD_NULL_VALUE = -1;

/*
 *  @brief:
 */
bool define_relation(CreateStmt *stmt)
{
    Assert(stmt != nullptr);

    bool ret_value{false};

    std::cout << nodeToString(stmt) << std::endl;

    // check syntax supported or not by Tsurugi
    if(!is_syntax_supported(stmt)){
        elog(ERROR, "define_relation() failed.");
        return ret_value;
    }

    // check type supported or not by Tsurugi
    if(!is_type_supported(stmt)){
        elog(ERROR, "define_relation() failed.");
        return ret_value;
    }

    // send metadata to metadata manager
    if(!store_metadata(stmt)){
        elog(ERROR, "define_relation() failed.");
        return ret_value;
    }

    ret_value = true;
    return ret_value;
}

bool is_type_supported(CreateStmt *stmt){
    bool supported{false};

    supported = true;
    return supported;
}

bool is_syntax_supported(CreateStmt *stmt){
    bool supported{false};
    supported = true;
    return supported;
}

bool store_metadata(CreateStmt *stmt){

    bool ret_value{false};
    std::unique_ptr<Metadata> datatypes{new DataTypes(dbname)};

    if (datatypes->load() != ErrorCode::OK) {
        std::cout << "DataTypes::load() error." << std::endl;
        return ret_value;
    }

    std::unique_ptr<Metadata> tables{new Tables(dbname)};

    if (tables->load() != ErrorCode::OK) {
        std::cout << "Tables::load() error." << std::endl;
        return ret_value;
    }

    // root
    ptree root;

    // table
    ptree new_table;

    // tbale name
    RangeVar *relation = (RangeVar *)stmt->relation;
    if (relation != NULL){
        char *relname = relation->relname;
        if (relation->relname != NULL){
            new_table.put(Tables::NAME, relname);
        }
    }else{
        return ret_value;
    }

    List *table_elts = stmt->tableElts;
    ListCell *table_elt;

    // primaryKey
    ptree primary_keys;

    // columns
    ptree columns;
    uint64_t ordinal_position = 1;

    foreach (table_elt, table_elts)
    {
        ColumnDef *colDef = (ColumnDef *)lfirst(table_elt);

        // column
        ptree column;

        // ordinalPosition
        column.put<uint64_t>(Tables::Column::ORDINAL_POSITION, ordinal_position);

        // column name
        column.put(Tables::Column::NAME, colDef->colname);

        List *colDef_constraints = colDef->constraints;
        bool nullable = true;
        bool pkey = false;

        if(colDef_constraints != NULL){

            ListCell   *l;
            foreach (l, colDef_constraints){
                Constraint *constraint = (Constraint *)lfirst(l);

                if(constraint->contype == CONSTR_NOTNULL){
                    // nullable
                    nullable = false;
                }else if(constraint->contype == CONSTR_PRIMARY){
                    // primary key
                    pkey = true;
                }
            }
        }

        // nullable
        column.put<bool>(Tables::Column::NULLABLE, nullable);

        // primary key and direction
        if (pkey){
            ptree primary_key;
            primary_key.put<uint64_t>("", ordinal_position);
            primary_keys.push_back(std::make_pair("", primary_key));

            column.put<uint64_t>(Tables::Column::DIRECTION,TSURUGI_DIRECTION_ASC);
        }else{
            column.put<uint64_t>(Tables::Column::DIRECTION,TSURUGI_DIRECTION_DEFAULT);
        }

        TypeName *colDef_type_name = colDef->typeName;

        if(colDef_type_name != NULL){
            List *type_names = colDef_type_name->names;
            ObjectIdType data_type_id;

            ListCell   *l;
            foreach (l, type_names){
                Value *type_name_value = (Value *)lfirst(l);
                std::string type_name{std::string(type_name_value->val.str)};
                // get dataTypeId
                ErrorCode err;
                ptree datatype;
                err = datatypes->get(DataTypes::PG_DATA_TYPE_QUALIFIED_NAME, type_name, datatype);
                if (err == ErrorCode::OK) {
                    data_type_id = datatype.get<ObjectIdType>(DataTypes::ID);
                    if (!data_type_id) {
                        return ret_value;
                    }else{
                        // put dataTypeId
                        column.put<ObjectIdType>(Tables::Column::DATA_TYPE_ID, data_type_id);
                    }
                    break;
                }
            }

            List *typmods = colDef_type_name->typmods;
            int32 typemod = colDef_type_name->typemod;

            if (typmods != NIL){
                ptree datalengths;

                ListCell *l;
                foreach (l, typmods){
                    Node *tm = (Node *) lfirst(l);

                    if (IsA(tm, A_Const))
		            {
			            A_Const    *ac = (A_Const *) tm;

		                if (IsA(&ac->val, Integer))
		                {
                            datalengths.put<uint64_t>("", ac->val.val.ival);
		                }else{
                            return ret_value;
                        }
                    }else{
                        return ret_value;
                    }
                }
                column.add_child(Tables::Column::DATA_LENGTH, datalengths);
            }else if (typemod != TYPEMOD_NULL_VALUE ){
                column.put<uint64_t>(Tables::Column::DATA_LENGTH, typemod);
            }

            if (!data_type_id){
                if(data_type_id == TSURUGI_TYPE_VARCHAR_ID){
                    // varying
                    column.put<bool>(Tables::Column::VARYING, true);
                }else if(data_type_id == TSURUGI_TYPE_CHAR_ID){
                    // varying
                    column.put<bool>(Tables::Column::VARYING, false);
                }
            }

        }

        columns.push_back(std::make_pair("", column));
        ordinal_position++;
    }

    new_table.add_child(Tables::PRIMARY_KEY_NODE, primary_keys);

    new_table.add_child(Tables::COLUMNS_NODE, columns);

    root.add_child(Tables::TABLES_NODE, new_table);

    if (Tables::save(dbname, root) != ErrorCode::OK) {
        elog(ERROR, "define_relation() failed.");
        return ret_value;
    }

    ret_value = true;
    return ret_value;
}

/*
 * Copyright 2020-2020 tsurugi project.
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

#ifdef __cplusplus
extern "C" {
#endif

#include <postgres.h>

#include "nodes/nodes.h"
#include "nodes/parsenodes.h"
#include "utils/palloc.h"

#ifdef __cplusplus
}
#endif

#include <iostream>
#include <string>

#include "manager/metadata/datatypes.h"
#include "manager/metadata/metadata.h"
#include "tablecmds.h"

using namespace manager::metadata;
using namespace boost::property_tree;

std::unique_ptr<Metadata> datatypes{new DataTypes("Tsurugi")};

const int TSURUGI_TYPE_CHAR_ID = 13;
const int TSURUGI_TYPE_VARCHAR_ID = 14;

const int TSURUGI_DIRECTION_DEFAULT = 0
const int TSURUGI_DIRECTION_ASC = 1;
const int TSURUGI_DIRECTION_DESC = 2;

/*
 *  @brief:
 */
bool define_relation(CreateStmt *stmt)
{
    Assert(stmt != nullptr);

    char *create_stmt_cstr;
    bool ret_val{false};

    create_stmt_cstr = nodeToString(stmt);

    std::cout << "nodeToString: " << create_stmt_cstr << "\n" << std::endl;
    pfree(create_stmt_cstr);

    if (datatypes->load() != ErrorCode::OK) {
        std::cout << "DataTypes::load() error." << std::endl;
        return ret_val;
    }

    // check syntax supported or not by Tsurugi
    if(ret_val = check_syntax_supported(stmt)){
        elog(ERROR, "define_relation() failed.");
        return ret_val;
    }

    // check type supported or not by Tsurugi
    if(ret_val = check_type_supported(stmt)){
        elog(ERROR, "define_relation() failed.");
        return ret_val;
    }

    // send metadata to metadata manager
    if(ret_val = store_metadata(stmt)){
        elog(ERROR, "define_relation() failed.");
        return ret_val;
    }

    ret_val = true;
    return ret_val;
}

bool check_type_supported(CreateStmt *stmt){
    bool supported{false};

    supported = true;
    return supported;
}

bool check_syntax_supported(CreateStmt *stmt){
    bool supported{false};
    supported = true;
    return supported;
}

bool store_metadata(CreateStmt *stmt){

    bool ret_val{false};

    // default constraint expression
    const std::string default_constraint_expr{"(undefined)"}

    // root
    boost::property_tree::ptree root;

    // table
    boost::property_tree::ptree new_table;

    // tbale name
    if (stmt.relation != NIL){
        RangeVar *relation = (RangeVar *)stmt.relation)
        char *relname = relation.relname;
        if (relation.relname != NULL){
            new_table.put(Tables::NAME, relname);
        }
    }else{
        return ret_val;
    }

    List *table_elts = stmt->tableElts;
    ListCell *table_elt;

    // primaryKey
    boost::property_tree::ptree primary_keys;

    // columns
    boost::property_tree::ptree columns;
    uint64_t ordinal_position = 1;

    foreach (table_elt, table_elts)
    {

        // column
        boost::property_tree::ptree column;

        // ordinalPosition
        column.put<uint64_t>(Tables::Column::ORDINAL_POSITION, ordinal_position);

        // column name
        column.put(Tables::Column::NAME, colDef.colname);

        ColumnDef *colDef = (ColumnDef *)lfirst(table_elt);
        List *colDef_constraints = colDef.constrains;

        bool nullable = true;
        bool pkey = false;

        if(colDef_constraints != NIL){

            foreach (l, colDef_constraints){
                Constraint *constraint = (Constraint *)lfirst(l);

                if(constraint.contype == CONSTR_NOTNULL){
                    // nullable
                    nullable = false;
                }else if(constraint.contype == CONSTR_PRIMARY){
                    // primary key
                    pkey = true;
                }
            }
        }

        // nullable
        column.put<bool>(Tables::Column::NULLABLE, nullable);

        // primary key and direction
        if (pkey){
            boost::property_tree::ptree primary_key;
            primary_key.put<uint64_t>("", ordinal_position);
            primary_keys.push_back(std::make_pair("", primary_key));

            column.put<uint64_t>(Tables::Column::DIRECTION,TSURUGI_DIRECTION_ASC);
        }else{
            column.put<uint64_t>(Tables::Column::DIRECTION,TSURUGI_DEFAULT);
        }

        // get dataTypeId
        ErrorCode err;
        boost::property_tree::ptree datatype;

        TypeName *colDef_type_name = colDef.typeName;

        if(colDef_type_name != NIL){
            List type_names = colDef_type_name.names;
            ObjectIdType data_type_id = NULL;

            foreach (l, type_names){
                Value *type_name_value = (Value *)lfirst(l);
                err = datatypes_->get(DataTypes::PG_DATA_TYPE_QUALIFIED_NAME, type_name_value, datatype);
                if (err != ErrorCode::OK) {
                    data_type_id = datatype.get<ObjectIdType>(DataTypes::ID);
                    if (!data_type_id) {
                        return ret_val;
                    }else{
                        // put dataTypeId
                        column.put<ObjectIdType>(Tables::Column::DATA_TYPE_ID, data_type_id);
                    }
                    break;
                }
            }

            List typmods = colDef_type_name.typmods;
            int32 typmod = colDef_type_name.typmod;

            if (type_mods != NIL){
                foreach (l, typmods){
                    if (IsA(tm, A_Const))
		            {
			            A_Const    *ac = (A_Const *) tm;

		                if (IsA(&ac->val, Integer))
		                {
                            column.put<uint64_t>(Tables::Column::DATA_LENGTH, ac->val.val.ival);
		                }else{
                            return ret_val;
                        }
                    }else{
                        return ret_val;
                    }
                }
            else if (typmod != 0 ){
                column.put<uint64_t>(Tables::Column::DATA_LENGTH, typmod);
            }
            if (data_type_id != NULL){
                if(data_type_id == TSURUGI_TYPE_VARCHAR_ID){
                    // varying
                    column.put<bool>(Tables::Column::VARYING, true);
                }else if(data_type_id == TSURUGI_TYPE_CHAR_ID){
                    // varying
                    column.put<bool>(Tables::Column::VARYING, false);
                }
            }

        }

        // default constraint expression
        column.put(Tables::Column::DEFAULT, default_constraint_expr);

        columns.push_back(std::make_pair("", column));
        ordinal_position++;
    }

    new_table.add_child(Tables::PRIMARY_KEY_NODE, primary_keys);

    new_table.add_child(Tables::COLUMNS_NODE, columns);

    root.add_child(Tables::TABLES_NODE, new_table);

    if (Tables::save(dbname, root) != ErrorCode::OK) {
        elog(ERROR, "define_relation() failed.");
        return ret_val;
    }

    ret_val = true;
    return ret_val;
}

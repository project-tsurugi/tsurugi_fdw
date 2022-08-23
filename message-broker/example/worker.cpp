/*
 * Copyright 2020 tsurugi project.
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
 *	@file	worker.cpp
 */

#include <iostream>
#include <string>
#include <string_view>

#include <boost/property_tree/exceptions.hpp>
#include <boost/foreach.hpp>
#include <boost/optional.hpp>

#include "manager/metadata/metadata.h"
#include "manager/metadata/metadata.h"
#include "manager/metadata/datatypes.h"
#include "manager/metadata/tables.h"

#include "worker.h"

using namespace manager::metadata;
using namespace boost::property_tree;

const char * const TEST_DB = "Tsurugi";

/*
 *  @brief  print error code and line number.
 */
void Worker::print_error(ErrorCode error, uint64_t line)
{
    std::cout << std::endl << "error occurred at line " << line << ", errorno: " << (uint64_t) error << std::endl;
}

/*
 *  @biref  display talbe-metadata-object.
 */
ErrorCode Worker::display_table_metadata_object(const ptree& table)
{
    ErrorCode error = ErrorCode::OK;

    std::unique_ptr<Metadata> datatypes(new DataTypes(TEST_DB));
    error = datatypes->load();
    if (error != ErrorCode::OK) {
        print_error(error, __LINE__);
        return error;
    }

    ptree datatype;

    // table metadata
    std::cout << "--- table ---" << std::endl;
    boost::optional<ObjectIdType> id =
        table.get_optional<ObjectIdType>(Tables::ID);
    if (id) {
        std::cout << "id : " << id.get() << std::endl;
    }

    boost::optional<std::string> name =
        table.get_optional<std::string>(Tables::NAME);
    if (name) {
        std::cout << "name : " << name << std::endl;
    }

    ptree primary_keys = table.get_child(Tables::PRIMARY_KEY_NODE);
    BOOST_FOREACH (const ptree::value_type& node, primary_keys) {
        std::cout << "primary_key : " << node.second.data() << std::endl;
    }

    // column metadata
    std::cout << "--- columns ---" << std::endl;
    BOOST_FOREACH (const ptree::value_type& node, table.get_child(Tables::COLUMNS_NODE)) {
        const ptree& column = node.second;

        boost::optional<ObjectIdType> id =
            column.get_optional<ObjectIdType>(Tables::Column::ID);
        if (id) {
            std::cout << "id : " << id << std::endl;
        }

        boost::optional<ObjectIdType> table_id =
            column.get_optional<ObjectIdType>(Tables::Column::TABLE_ID);
        if (table_id) {
            std::cout << "table id : " << table_id << std::endl;
        }

        boost::optional<std::string> name =
            column.get_optional<std::string>(Tables::Column::NAME);
        if (name) {
            std::cout << "name : " << name << std::endl;
        }

        boost::optional<uint64_t> ordinal_position =
            column.get_optional<uint64_t>(Tables::Column::ORDINAL_POSITION);
        if (ordinal_position) {
            std::cout << "ordinal position : " << ordinal_position << std::endl;
        }

        boost::optional<ObjectIdType> data_type_id =
            column.get_optional<ObjectIdType>(Tables::Column::DATA_TYPE_ID);
        if (data_type_id) {
            std::cout << "datatype id : " << data_type_id << std::endl;
            datatypes->get(data_type_id.get(), datatype);
            std::cout << "datatype name : "
            << datatype.get<std::string>(DataTypes::NAME) << std::endl;
        }

        boost::optional<uint64_t> data_length =
            column.get_optional<uint64_t>(Tables::Column::DATA_LENGTH);
        if (data_length) {
            std::cout << "data length : " << data_length << std::endl;
        }

        boost::optional<bool> varying =
            column.get_optional<bool>(Tables::Column::VARYING);
        if (varying) {
            std::cout << "varying : " << varying << std::endl;
        }

        boost::optional<bool> nullable =
            column.get_optional<bool>(Tables::Column::NULLABLE);
        if (nullable) {
            std::cout << "nullable : " << nullable << std::endl;
        }

        boost::optional<uint64_t> direction =
            column.get_optional<uint64_t>(Tables::Column::DIRECTION);
        if (direction) {
            std::cout << "direction : " << direction << std::endl;
            switch (static_cast<Tables::Column::Direction>(direction.get())) {
                case Tables::Column::Direction::DEFAULT:
                    std::cout << "direction : DEFAULT" << std::endl;
                    break;
                case Tables::Column::Direction::DESCENDANT:
                    std::cout << "direction : DESCENDANT" << std::endl;
                    break;
                case Tables::Column::Direction::ASCENDANT:
                    std::cout << "direction : ASCENDANT" << std::endl;
                    break;
                default:
                    break;
            }
        }

        std::cout << "---------------" << std::endl;
    }

    return ErrorCode::OK;;
}


/*
 *  @biref  read table-metadata from metadata-table.
 */
ErrorCode Worker::read_table_metadata(int64_t object_id)
{
    ErrorCode error = ErrorCode::UNKNOWN;

    std::unique_ptr<Metadata> tables(new Tables(TEST_DB));   // use Template-Method.
    error = tables->load();
    if (error != ErrorCode::OK) {
        print_error(error, __LINE__);
        return error;
    }

    std::cout << "--- table-metadata to read. ---" << std::endl;

    ptree table;
    error = tables->get(object_id, table);
    if (error == ErrorCode::OK)
    {
        error = display_table_metadata_object(table);
        if (error != ErrorCode::OK) {
            return error;
        }
        std::cout << std::endl;
    }
    else
    {
        return error;
    }

    error = ErrorCode::OK;

    return error;
}

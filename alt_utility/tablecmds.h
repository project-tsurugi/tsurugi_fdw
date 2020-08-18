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
 *	@file	tablecmds.h
 *	@brief  Sends metadata to metadata-manager.
 */

#ifndef TABLECMDS_H
#define TABLECMDS_H

#include <unordered_set>

/* char type id value obtained from metadata-manager  */
const manager::metadata::ObjectIdType TSURUGI_TYPE_CHAR_ID = 13;
/* varchar type id value obtained from metadata-manager  */
const manager::metadata::ObjectIdType TSURUGI_TYPE_VARCHAR_ID = 14;

/* default direction value metadata-manager manages */
const int TSURUGI_DIRECTION_DEFAULT = 0;
/* ascending direction value metadata-manager manages */
const int TSURUGI_DIRECTION_ASC = 1;
/* descending direction value metadata-manager manages */
const int TSURUGI_DIRECTION_DESC = 2;

/* DB name metadata-manager manages */
const std::string DBNAME = "Tsurugi";

/* base index of ordinal position metadata-manager manages */
const uint64_t ORDINAL_POSITION_BASE_INDEX = 1;

class CreateTable {
    public:
        /**
         * @brief C'tors. Initialize member variables.
         * @param [in] List of statements.
         */
        CreateTable(List *stmts);

        /**
         *  @brief  Defines relation include loading metadata, syntax check, type check, storing metadata.
         *  @param  [out] The object id stored if new table was successfully created.
         *  @return true if metadata was successfully stored
         *  @return false otherwize
         */
        bool define_relation( uint64_t* object_id );

    private:
        /* DB name metadata-manager manages */
        const std::string dbname{DBNAME};
        /* List of statements */
        List *stmts;
        /* Create Table Statement */
        CreateStmt *create_stmt;
        /* Create Index Statement */
        IndexStmt *index_stmt;

        /* data types metadata obtained from metadata-manager */
        std::unique_ptr<manager::metadata::Metadata> datatypes;
        /* table metadata obtained from metadata-manager */
        std::unique_ptr<manager::metadata::Metadata> tables;

        /**
         *  @brief  Loads metadata from metadata-manager.
         *  @return true if metadata was successfully loaded
         *  @return false otherwize.
         */
        bool load_metadata();

        /**
         *  @brief  Check if given type supported or not by Tsurugi
         *  @return true if supported
         *  @return false otherwise.
         */
        bool is_type_supported();

        /**
         *  @brief  Check if given syntax supported or not by Tsurugi
         *  @return true if supported
         *  @return false otherwise.
         */
        bool is_syntax_supported();

        /**
         *  @brief  Sends metadata to metadata-manager.
         *  @param  [out] The object id stored if new table was successfully created.
         *  @return true if metadata was successfully sended
         *  @return false otherwize.
         */
        bool store_metadata( uint64_t* object_id );

        /**
         *  @brief  Get ordinal positions of table's primary key columns in table or column constraints.
         *  @return ordinal positions of table's primary key columns.
         */
        std::unordered_set<uint64_t> get_ordinal_positions_of_primary_keys();

        /**
         *  @brief  Reports error message that given types are not supported by Tsurugi.
         *  @param  [in] List of TypeName structure's member "names".
         */
        void show_type_error_msg(List *type_names);

        /**
         *  @brief  Reports error message that given types are not supported by Tsurugi.
         *  @param  [in] List of TypeName structure's member "typeOid".
         */
        void show_type_error_msg(std::vector<int> type_oids);

        /**
         *  @brief  Reports error message that given syntax is not supported by Tsurugi.
         *  @param  [in] The primary message.
         */
        void show_syntax_error_msg(const char *error_message);

        /**
         *  @brief  Reports error message that given table constraint is not supported by Tsurugi.
         *  @param  [in] The primary message.
         */
        void show_table_constraint_syntax_error_msg(const char *error_message);
};

#endif // TABLECMDS_H

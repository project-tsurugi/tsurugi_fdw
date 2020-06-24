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
 *	@brief  send metadata to metadata-manager
 */

#ifndef TABLECMDS_
#define TABLECMDS_

#include <unordered_set>

const manager::metadata::ObjectIdType TSURUGI_TYPE_CHAR_ID = 13;
const manager::metadata::ObjectIdType TSURUGI_TYPE_VARCHAR_ID = 14;

const int TSURUGI_DIRECTION_DEFAULT = 0;
const int TSURUGI_DIRECTION_ASC = 1;
const int TSURUGI_DIRECTION_DESC = 2;

const std::string DBNAME = "Tsurugi";

const uint64_t ORDINAL_POSITION_BASE_INDEX = 1;

class CreateTable {
    public:
        CreateTable(List *stmts);
        bool define_relation();

    private:
        const std::string dbname{DBNAME};
        List *stmts;
        CreateStmt *create_stmt;
        IndexStmt *index_stmt;

        std::unique_ptr<manager::metadata::Metadata> datatypes;
        std::unique_ptr<manager::metadata::Metadata> tables;

        bool load_metadata();
        bool is_type_supported();
        bool is_syntax_supported();
        bool store_metadata();
        std::unordered_set<uint64_t> get_ordinal_positions_of_primary_keys();
        void show_type_error_msg(List *type_names);
        void show_type_error_msg(std::vector<int> type_oids);
        void show_syntax_error_msg(const char *error_message);
        void show_table_constraint_syntax_error_msg(const char *error_message);
};

#endif // TABLECMDS_

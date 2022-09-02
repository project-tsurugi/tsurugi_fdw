/*
 * Copyright 2019-2022 tsurugi project.
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
 *	@file	create_table.h
 *	@brief  Dispatch the create-table command to ogawayama.
 */
#include <memory>
#include <vector>
#include "create_index.h"
#include "manager/metadata/tables.h"

using namespace manager;

/* base index of ordinal position metadata-manager manages */
const metadata::ObjectIdType ORDINAL_POSITION_BASE_INDEX = 1;

/**
 * 
 * 
 */
std::vector<int64_t> get_primary_keys(IndexStmt* index_stmt)
{
	std::vector<int64_t> primary_keys;
	auto tables = std::make_unique<metadata::Tables>("tsurugi");

	ListCell* listptr;
	if (index_stmt->primary) {
		foreach(listptr, index_stmt->indexParams) {
			Node* stmt = (Node*) lfirst(listptr);
			if (IsA(stmt, IndexElem)) {
				IndexElem* elem = (IndexElem*) stmt;
				metadata::Table table;
				metadata::ErrorCode error = tables->get(index_stmt->relation->relname, table);
				if (error != metadata::ErrorCode::OK) {
					elog(NOTICE, "Table not found. (error:%d) (name:%s)", 
						(int) error, index_stmt->relation->relname);
					return primary_keys;
				}
				for (const metadata::Column& column : table.columns) {
					if (column.name == elem->name) {
						primary_keys.emplace_back(column.ordinal_position);
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
bool CreateIndex::validate_syntax()
{
  bool result = false;
  IndexStmt* index_stmt = this->index_stmt();

  /* Check members of IndexStmt structure */
  if (index_stmt != nullptr) {
    if (index_stmt->unique && !(index_stmt->primary)) {
        this->show_table_constraint_syntax_error_msg(
            "Tsurugi does not support UNIQUE table constraint");
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
        this->show_table_constraint_syntax_error_msg("Tsurugi does not support EXCLUDE table constraint");
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

  return result;
}

/**
 *  @brief  Check if given syntax supported or not by Tsurugi
 *  @return true if supported
 *  @return false otherwise.
 */
bool CreateIndex::validate_data_type()
{
  return true;
}

#if 0
/**
 *  @brief  Create metadata from query tree.
 *  @return true if supported
 *  @return false otherwise.
 */
bool CreateIndex::generate_metadata(boost::property_tree::ptree& table)
{
	IndexStmt* index_stmt = this->index_stmt();
	property_tree::ptree columns = table.get_child(metadata::Tables::COLUMNS_NODE);
    property_tree::ptree primary_key;
    property_tree::ptree primary_keys;

	std::vector<int64_t> primary_key_set = get_primary_keys(index_stmt);
	for (int64_t ordinal_position : primary_key_set) {
		primary_key.put<int64_t>("", ordinal_position);
		primary_keys.push_back(std::make_pair("", primary_key));
		table.put(metadata::Tables::NAME, primary_keys);

		property_tree::ptree column;

	    column.put<int>(metadata::Tables::Column::DIRECTION, 
						static_cast<int>(metadata::Tables::Column::Direction::DEFAULT));
	}

  	return true;
}
#endif
/**
 *  @brief  Create table metadata from query tree.
 *  @return true if supported
 *  @return false otherwise.
 */
bool CreateIndex::generate_table_metadata(manager::metadata::Table& table)
{
	IndexStmt* index_stmt = this->index_stmt();

	table.primary_keys = get_primary_keys(index_stmt);
	for (int64_t ordinal_position : table.primary_keys) {
		for (metadata::Column& column : table.columns) {
			if (column.ordinal_position == ordinal_position) {
				column.direction = 
					static_cast<int64_t>(metadata::Tables::Column::Direction::DEFAULT);
			}
		}
	}

  	return true;
}

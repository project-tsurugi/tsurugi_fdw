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

metadata::Tables::Column::Direction get_sort_by_dir(SortByDir direction)
{
	metadata::Tables::Column::Direction result = metadata::Tables::Column::Direction::DEFAULT;
	switch (direction)
	{
		case SortByDir::SORTBY_DEFAULT: {
			result = metadata::Tables::Column::Direction::DEFAULT;
			break;
		}
		case SortByDir::SORTBY_ASC: {
			result = metadata::Tables::Column::Direction::ASCENDANT;
			break;
		}
		case SortByDir::SORTBY_DESC: {
			result = metadata::Tables::Column::Direction::DESCENDANT;
			break;
		}
		default: {
			// case SortByDir::SORTBY_USING:
//			result = metadata::Table::Column::Direction::UNSUPPORTED;
			break;
		}
	}

	return result;
}

/**
 * 
 * 
 */
bool get_primary_keys_and_direction(IndexStmt* index_stmt, metadata::Table& table)
{
	bool result = false;
	auto tables = std::make_unique<metadata::Tables>("tsurugi");

	ListCell* listptr;
	if (index_stmt->primary) {
		foreach(listptr, index_stmt->indexParams) {
			Node* stmt = (Node*) lfirst(listptr);
			if (IsA(stmt, IndexElem)) {
				IndexElem* elem = (IndexElem*) stmt;
				metadata::Table table;
				auto error = tables->get(index_stmt->relation->relname, table);
				if (error != metadata::ErrorCode::OK) {
					elog(NOTICE, "Table not found. (error:%d) (name:%s)", 
						(int) error, index_stmt->relation->relname);
					return result;
				}
				for (metadata::Column& column : table.columns) {
					if (column.name == elem->name) {
						table.primary_keys.emplace_back(column.ordinal_position);
						metadata::Tables::Column::Direction direction = get_sort_by_dir(elem->ordering);
						if (direction == metadata::Tables::Column::Direction::DEFAULT ) {
							return result;
						} 
						column.direction = static_cast<int64_t>(direction);
					}
				}
			}
		}
	}
	result = true;
	
	return result;
}

/**
 * @brief  	Create table metadata from query tree.
 * @return 	true if success, otherwise fault.
 * @note	Add metadata of Primary-keys and Direction.
 */
manager::metadata::ErrorCode 
CreateIndex::generate_table_metadata(manager::metadata::Table table) const
{
	auto result = metadata::ErrorCode::UNKNOWN;
	IndexStmt* index_stmt = this->index_stmt();
	std::vector<int64_t> primary_keys;

	bool success = get_primary_keys_and_direction(index_stmt, table);
	if (!success) {
		result = metadata::ErrorCode::NOT_FOUND;
		return result;
	}
	result = metadata::ErrorCode::OK;;

  	return result;
}

/**
 *  @brief  Check if given syntax supported or not by Tsurugi
 *  @return true if supported
 *  @return false otherwise.
 */
bool CreateIndex::validate_syntax() const
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
bool CreateIndex::validate_data_type() const
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

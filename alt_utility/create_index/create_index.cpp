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
 *	@file	create_index.h
 *	@brief  Generate index metadata from index statement.
 */
#include <memory>
#include <vector>
#include "create_index.h"
#include "manager/metadata/tables.h"

#ifdef __cplusplus
extern "C" {
#endif
#include "nodes/parsenodes.h"
#ifdef __cplusplus
}
#endif

using namespace manager;

/**
 * @brief
 */
void show_table_constraint_syntax_error_msg(const char* error_message)
{
	ereport(ERROR,
		(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
		errmsg("%s",error_message),
		errdetail("Tsurugi supports only PRIMARY KEY in table constraint")));
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
  Assert(index_stmt != NULL);

  /* Check members of IndexStmt structure */
  if (index_stmt != nullptr) {
    if (index_stmt->unique && !(index_stmt->primary)) {
        show_table_constraint_syntax_error_msg(
            "Tsurugi does not support UNIQUE table constraint");
        return result;
    }
#if 0
    if (index_stmt->tableSpace != nullptr) {
        ereport(ERROR,
                (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                  errmsg("Tsurugi does not support USING INDEX TABLESPACE clause")));
        return result;
    }
#endif
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
        show_table_constraint_syntax_error_msg(
			"Tsurugi does not support EXCLUDE table constraint");
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

/**
 * @brief	Trasform from ordering ot direction.
 * @param	elem	Pointer to IndexElem.
 * @return	Direction status mixed direction and nulls order if success.
 * @return 	metadata::INVALID_VALUE if failure.
 */
int64_t get_direction(IndexElem* elem)
{
	auto direction = 
			static_cast<metadata::Index::Direction>(metadata::INVALID_VALUE);

	switch (static_cast<int64_t>(elem->ordering)) {
		case SortByDir::SORTBY_ASC:
		case SortByDir::SORTBY_DEFAULT: {
			if (elem->nulls_ordering == SortByNulls::SORTBY_NULLS_LAST ||
					elem->nulls_ordering == SortByNulls::SORTBY_NULLS_DEFAULT) {
				direction = metadata::Index::Direction::ASC_NULLS_LAST;
			} else if (elem->nulls_ordering == SortByNulls::SORTBY_NULLS_FIRST) {
				direction = metadata::Index::Direction::ASC_NULLS_FIRST;
			}
			break;
		}
		case SortByDir::SORTBY_DESC: {
			if (elem->nulls_ordering == SortByNulls::SORTBY_NULLS_LAST ||
					elem->nulls_ordering == SortByNulls::SORTBY_NULLS_DEFAULT) {
				direction = metadata::Index::Direction::DESC_NULLS_LAST;
			} else if (elem->nulls_ordering == SortByNulls::SORTBY_NULLS_FIRST) {
				direction = metadata::Index::Direction::DESC_NULLS_FIRST;
			}
			break;
		}
		default: {
			// SortByDir::SORTBY_USING
			elog(NOTICE, "Tsurugi does no support SortByDir::SORTBY_USING.");
			break;
		}
	}
	return static_cast<int64_t>(direction);
}

/**
 *  @brief  Generate index metadata from query tree.
 *  @return true if success.
 *  @return false otherwise.
 */
bool CreateIndex::generate_metadata(manager::metadata::Object& object) const
{
	bool result{false};
	IndexStmt* index_stmt{this->index_stmt()};
	Assert(index_stmt != NULL);
	auto& index = static_cast<metadata::Index&>(object);
	auto tables = std::make_unique<metadata::Tables>("tsurugi");
	
	index.access_method = 
			std::underlying_type_t<metadata::Index::AccessMethod>
			(metadata::Index::AccessMethod::TSURGI_DEFAULT_METHOD);
	index.name 			= index_stmt->idxname;
	index.is_primary 	= index_stmt->primary;
	index.is_unique 	= index_stmt->unique;

	// Generate key indexes.
	ListCell* listptr;
	foreach(listptr, index_stmt->indexParams) {
		Node* node = (Node*) lfirst(listptr);
		if (IsA(node, IndexElem)) {
			IndexElem* elem = (IndexElem*) node;
			metadata::Table table;
			tables->get(index_stmt->relation->relname, table);
			for (const auto& column : table.columns) {
				if (column.name == elem->name) {
					index.keys.emplace_back(column.ordinal_position);
					index.keys_id.emplace_back(column.id);
					int64_t direction = get_direction(elem);
					if (direction == metadata::INVALID_VALUE) {
						return result;
					}
					index.options.emplace_back(direction);
				}
			}
		}
	}
	index.number_of_key_indexes = index.keys.size();

	// Generaete included keys.
	foreach(listptr, index_stmt->indexIncludingParams) {
		Node* node = (Node*) lfirst(listptr);
		if (IsA(node, IndexElem)) {
			IndexElem* elem = (IndexElem*) node;
			metadata::Table table;
			tables->get(index_stmt->relation->relname, table);
			for (const auto& column : table.columns) {
				if (column.name == elem->name) {
					index.keys.emplace_back(column.ordinal_position);
					index.keys_id.emplace_back(column.id);
					// Included keys does NOT have direction.
				}
			}
		}
	}
	result = true;

  	return result;
}

/**
 * @brief	Get ordinal position of primary keys.
 * @param 	index_stmt		Pointer of index statement.
 * @param	primary_keys	Reference of vector for storing key position.
 * @return	true if success.
 */
bool get_primary_keys(IndexStmt* index_stmt, std::vector<int64_t>& primary_keys)
{
	bool result = false;
	auto tables = std::make_unique<metadata::Tables>("tsurugi");

	if (index_stmt->primary) {
		ListCell* listptr;
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
				for (const auto& column : table.columns) {
					if (column.name == elem->name) {
						primary_keys.emplace_back(column.ordinal_position);
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
 * @note	Add metadata of Primary-keys.
 */
manager::metadata::ErrorCode 
CreateIndex::generate_table_metadata(manager::metadata::Table& table) const
{
	IndexStmt* index_stmt = this->index_stmt();

	bool success = get_primary_keys(index_stmt, table.primary_keys);
	if (!success) {
		return metadata::ErrorCode::NOT_FOUND;
	}

	return metadata::ErrorCode::OK;
}

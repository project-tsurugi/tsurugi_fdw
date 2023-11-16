/*
 * Copyright 2019-2023 Project Tsurugi.
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
 * Portions Copyright (c) 1996-2023, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, The Regents of the University of California
 *
 *	@file	create_index.cpp
 *	@brief  Generate index metadata from index statement.
 */
#include <memory>
#include <vector>
#include "create_index.h"
#include "manager/metadata/tables.h"
#include "manager/metadata/index.h"
#include "manager/metadata/indexes.h"
#include "manager/metadata/metadata_factory.h"

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
 * @brief	If index name is not specified, generate index name
 *          from table name and column name.
 * @param	index_stmt_idxname	Name of new index in the Create Index Statement.
 * @param	table_name			Table name that has this index.
 * @param	column_name			Column name that has this index.
 * @param	is_primary			Primary Key is true, otherwise false.
 * @return 	Index name to be registered in metadata.
 */
std::string generate_index_name(char* index_stmt_idxname,
								std::string table_name,
								std::string column_name,
								bool is_primary)
{
	std::string index_name;
	if (index_stmt_idxname != nullptr) {
		index_name = index_stmt_idxname;
	} else {
		// default index names.
		if (is_primary) {
			index_name = table_name + std::string("_pkey");
		} else {
			index_name = std::string(table_name + column_name + "_key");
		}
	}
	return index_name;
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
    auto tables = metadata::get_tables_ptr(TSURUGI_DB_NAME);

    metadata::Table table;
    tables->get(this->get_table_name(), table);

    index.table_id = table.id;
    index.access_method 
			= std::underlying_type_t<metadata::Index::AccessMethod>(
    				metadata::Index::AccessMethod::MASS_TREE_METHOD);
    index.is_primary = index_stmt->primary;
    index.is_unique = index_stmt->unique;

    // Create key indexes.
	std::string column_name;
    ListCell* listptr;
    foreach (listptr, index_stmt->indexParams) {
    	Node* node = (Node*)lfirst(listptr);
      	if (IsA(node, IndexElem)) {
        	IndexElem* elem = (IndexElem*) node;
        	metadata::Table table;
        	tables->get(index_stmt->relation->relname, table);
        	for (const auto& column : table.columns) {
          		if (column.name == elem->name) {
            		index.keys.emplace_back(column.column_number);
            		index.keys_id.emplace_back(column.id);
					column_name += '_' + column.name;
            		int64_t direction = get_direction(elem);
            		if (direction == metadata::INVALID_VALUE) {
              			return result;
            		}
            		index.options.emplace_back(direction);
          		}
        	}
      	}
	}
	index.number_of_key_columns = index.keys.size();

	// Create included keys.
	foreach(listptr, index_stmt->indexIncludingParams) {
		Node* node = (Node*) lfirst(listptr);
		if (IsA(node, IndexElem)) {
			IndexElem* elem = (IndexElem*) node;
			metadata::Table table;
			tables->get(index_stmt->relation->relname, table);
			for (const auto& column : table.columns) {
				if (column.name == elem->name) {
					index.keys.emplace_back(column.column_number);
					index.keys_id.emplace_back(column.id);
					column_name += '_' + column.name;
					// Included keys does NOT have direction.
				}
			}
		}
	}
    index.number_of_columns = index.keys.size();

	index.name = generate_index_name(index_stmt->idxname,
								table.name, column_name, index.is_primary);

    result = true;

  	return result;
}

/**
 *  @brief  Generate constraint metadata from query tree.
 *  @return true if success.
 *  @return false otherwise.
 */
metadata::ErrorCode 
CreateIndex::generate_constraint_metadata(metadata::Table& table) const
{
	IndexStmt* index_stmt{this->index_stmt()};
	Assert(index_stmt != NULL);
	metadata::ErrorCode result = metadata::ErrorCode::NOT_FOUND;

	if (index_stmt->primary || index_stmt->unique) {
		metadata::Constraint constraint;
		std::string column_name;

		/* put constraint type metadata */
		if (index_stmt->primary) {
			constraint.type = metadata::Constraint::ConstraintType::PRIMARY_KEY;
		} else if (index_stmt->unique) {
			constraint.type = metadata::Constraint::ConstraintType::UNIQUE;
		}

		/* put constraint columns and columns_id metadata */
		ListCell* listptr;
		foreach(listptr, index_stmt->indexParams) {
			Node* node = (Node*) lfirst(listptr);
			if (IsA(node, IndexElem)) {
				IndexElem* elem = (IndexElem*) node;
				for (const auto& column : table.columns) {
					if (column.name == elem->name) {
						constraint.columns.emplace_back(column.column_number);
						constraint.columns_id.emplace_back(column.id);
						column_name += '_' + column.name;
					}
				}
			}
		}

		/* Generate column_name based on index include parameter */
		foreach(listptr, index_stmt->indexIncludingParams) {
			Node* node = (Node*) lfirst(listptr);
			if (IsA(node, IndexElem)) {
				IndexElem* elem = (IndexElem*) node;
				for (const auto& column : table.columns) {
					if (column.name == elem->name) {
						column_name += '_' + column.name;
					}
				}
			}
		}

		/* put constraint index_id metadata */
		std::string index_name;
		index_name = generate_index_name(index_stmt->idxname,
									table.name, column_name, index_stmt->primary);

		auto indexes = metadata::get_indexes_ptr(TSURUGI_DB_NAME);
		metadata::Index index;
		auto error = indexes->get(index_name, index);
		if (error != metadata::ErrorCode::OK) {
			elog(NOTICE, "Index not found. (error:%d) (name:%s)", 
				(int) error, index_stmt->relation->relname);
			return result;
		}
		if (index_name == index.name) {
			constraint.index_id = index.id;
		} else {
			elog(NOTICE, "Index not found. (index name:%s)", index_name.data());
			return result;
		}

		/* put constraint name metadata */
		constraint.name = index_name;

		table.constraints.emplace_back(constraint);
		result = metadata::ErrorCode::OK;
	}

	return result;
}

/**
 * @brief  	Create constraint metadata from query tree.
 * @param 	table [in] table metadata.
 * @return 	true if success, otherwise fault.
 * @note	Add metadata of CONSTR_CHECK and CONSTR_FOREIGN.
 */
bool get_primary_keys(IndexStmt* index_stmt, std::vector<int64_t>& primary_keys)
{
	bool result = false;
    auto tables = metadata::get_tables_ptr(TSURUGI_DB_NAME);

        if (index_stmt->primary) {
		ListCell* listptr;
		foreach(listptr, index_stmt->indexParams) {
			Node* stmt = (Node*) lfirst(listptr);
			if (IsA(stmt, IndexElem)) {
				IndexElem* elem = (IndexElem*) stmt;
				metadata::Table table;
				auto error = tables->get((const char*) index_stmt->relation->relname, table);
				if (error != metadata::ErrorCode::OK) {
					elog(NOTICE, "Table not found. (error:%d) (name:%s)", 
						(int) error, index_stmt->relation->relname);
					return result;
				}
				for (const auto& column : table.columns) {
					if (column.name == elem->name) {
						primary_keys.emplace_back(column.column_number);
					}
				}
			}
		}
	}
	result = true;
	
	return result;
}

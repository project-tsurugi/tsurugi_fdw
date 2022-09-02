#include "create_index.h"
#include <vector>
#include <unordered_set>
#include <boost/operators.hpp>
#include <boost/foreach.hpp>
#include "manager/metadata/tables.h"

using namespace manager;
using namespace boost;

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
				property_tree::ptree table;
				metadata::ErrorCode error = tables->get(index_stmt->relation->relname, table);
				if (error != metadata::ErrorCode::OK) {
					elog(NOTICE, "Table not found. (error:%d) (name:%s)", 
						(int) error, index_stmt->relation->relname);
					return primary_keys;
				}
				property_tree::ptree columns;
				table.get_child(metadata::Tables::COLUMNS_NODE, columns);
				BOOST_FOREACH(const property_tree::ptree::value_type& child, columns) {
					const property_tree::ptree& column = child.second;
					auto column_name = 
						column.get_optional<std::string>(metadata::Tables::Column::NAME);
					if (column_name.get() == elem->name) {
						auto ordinal_position = 
							column.get_optional<int64_t>(metadata::Tables::Column::ORDINAL_POSITION);
						primary_keys.emplace_back(ordinal_position.get());
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

/**
 *  @brief  Create table metadata from query tree.
 *  @return true if supported
 *  @return false otherwise.
 */
bool CreateIndex::generate_table_metadata(Table& table)
{
	IndexStmt* index_stmt = this->index_stmt();

	table.primary_keys = get_primary_keys(index_stmt);
	for (int64_t ordinal_position : table.primary_keys) {
		for (Column& column : table.columns) {
			if (column.ordinal_position == ordinal_position) {
				column.direction = 
					static_cast<int64_t>(metadata::Tables::Column::Direction::DEFAULT);
			}
		}
	}

  	return true;
}

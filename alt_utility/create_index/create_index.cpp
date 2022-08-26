#include "create_index.h"
#include "manager/metadata/tables.h"
#include <boost/property_tree/ptree.hpp>
#include <boost/operators.hpp>
#include <boost/foreach.hpp>

using namespace manager;
using namespace boost;

/* base index of ordinal position metadata-manager manages */
const metadata::ObjectIdType ORDINAL_POSITION_BASE_INDEX = 1;

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
bool CreateIndex::generate_metadata(boost::property_tree::ptree& metadata)
{
  metadata::ObjectIdType ordinal_position = ORDINAL_POSITION_BASE_INDEX;
  std::unordered_set<metadata::ObjectIdType> op_pkeys = 
    get_ordinal_positions_of_primary_keys();

   /*
    * If this column is primary key, put primary key and ascending direction.
    * Otherwise, put default direction.
    */
   property_tree::ptree column;

  if (op_pkeys.find(ordinal_position) == op_pkeys.end()) {
    column.put<int>(metadata::Tables::Column::DIRECTION, static_cast<int>(metadata::Tables::Column::Direction::DEFAULT));
  } else {
    property_tree::ptree primary_key;
    property_tree::ptree primary_keys;
    primary_key.put<metadata::ObjectIdType>("", ordinal_position);
    primary_keys.push_back(std::make_pair("", primary_key));
    column.put<int>(metadata::Tables::Column::DIRECTION, static_cast<int>(metadata::Tables::Column::Direction::ASCENDANT));
  } 

  return true;
}


/**
 *  @brief  Get ordinal positions of table's primary key columns in table or column constraints.
 *  @return ordinal positions of table's primary key columns.
 */
std::unordered_set<metadata::ObjectIdType>
CreateIndex::get_ordinal_positions_of_primary_keys()
{
    std::unordered_set<metadata::ObjectIdType> op_pkeys;
    const char* DBNAME = "tsurugi";
    auto tables = std::make_unique<metadata::Tables>(DBNAME);
    IndexStmt* index_stmt = this->index_stmt();

    RangeVar* relation = index_stmt->relation;

    /* Check if table constraints include primary key constraint */
    if (index_stmt != nullptr && index_stmt->primary)
    {
        List* index_params = index_stmt->indexParams;
        ListCell* lip;
        boost::property_tree::ptree table;
        metadata::ErrorCode error = tables->get(std::string_view{relation->relname}, table);
        if (error != metadata::ErrorCode::OK) {
          return op_pkeys;
        }

        /* Find positions with matching column names. */
        boost::property_tree::ptree columns = table.get_child(metadata::Tables::COLUMNS_NODE);
        BOOST_FOREACH(const property_tree::ptree::value_type& child, columns) {
            const boost::property_tree::ptree& column = child.second;
            boost::optional<std::string> column_name = 
                column.get_optional<std::string>(metadata::Tables::Column::NAME);
            foreach(lip, index_params)
            {
                IndexElem *index_elem = (IndexElem *) lfirst(lip);
                if (column_name.get().compare(index_elem->name) == 0)
                {
                    /* Get oridinal positions of table constraints' primary key columns */
                    boost::optional<uint64_t> position = 
                        column.get_optional<uint64_t>(metadata::Tables::Column::ORDINAL_POSITION);
                    op_pkeys.insert(position.get());
                }
            }
        }
    }

    return op_pkeys;
}

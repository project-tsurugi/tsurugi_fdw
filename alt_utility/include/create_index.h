#include <unordered_set>
#include <boost/property_tree/ptree.hpp>
#include "command/index_command.h"
#include "manager/metadata/metadata.h"
#include "create_table.h"

class CreateIndex : public IndexCommand {
 public:
	CreateIndex(IndexStmt* index_stmt) : IndexCommand(index_stmt) {}
	/**
	 *  @brief  Check if given syntax supported or not by Tsurugi
	 *  @return true if supported
	 *  @return false otherwise.
	 */
	virtual bool validate_syntax();

	/**
	 *  @brief  Check if given syntax supported or not by Tsurugi
	 *  @return true if supported
	 *  @return false otherwise.
	 */
	virtual bool validate_data_type();

	/**
	 *  @brief  Create metadata from query tree.
	 *  @return true if supported
	 *  @return false otherwise.
	 */
	virtual bool generate_metadata(boost::property_tree::ptree& metadata);
	bool generate_table_metadata(Table& table);

	private:
	/**
	 *  @brief  Reports error message that given table constraint is not supported by Tsurugi.
	 *  @param  [in] The primary message.
	 */
	void
	show_table_constraint_syntax_error_msg(const char *error_message)
	{
		ereport(ERROR,
			(errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
			errmsg("%s",error_message),
			errdetail("Tsurugi supports only PRIMARY KEY in table constraint")));
	}

	/**
	 *  @brief  Get ordinal positions of table's primary key columns in table or column constraints.
	 *  @return ordinal positions of table's primary key columns.
	 */
	std::vector<manager::metadata::ObjectIdType> get_ordinal_positions_of_primary_keys();
	};

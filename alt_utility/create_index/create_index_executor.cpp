#include <boost/property_tree/ptree.hpp>
#include "create_index.h"
#include "create_table.h"
#include "create_index_executor.h"

using namespace boost;

void execute_create_index(IndexStmt* index_stmt)
{
	Table table;

	CreateIndex create_index(index_stmt);

	create_index.generate_table_metadata(table);

	property_tree::ptree metadata;
	create_index.generate_metadata(metadata);
}

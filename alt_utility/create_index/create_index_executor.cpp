#include <boost/property_tree/ptree.hpp>
#include "create_index.h"

#include "create_index_executor.h"

using namespace boost;

void execute_create_index(IndexStmt* index_stmt)
{
  CreateIndex create_index(index_stmt);

  property_tree::ptree metadata;
  bool success = create_index.generate_metadata(metadata);
  if (!success) {
    ereport(NOTICE,
      (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
          errmsg("Tsurugi does not support USING INDEX TABLESPACE clause")));
  }
}

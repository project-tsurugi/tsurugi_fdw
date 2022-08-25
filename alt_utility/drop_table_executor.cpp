/*
 * Copyright 2022 tsurugi project.
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
 *	@file	  drop_table.cpp
 *	@brief  Dispatch drop-message to ogawayama.
 */
#include "ogawayama/stub/api.h"
#include "stub_manager.h"

#if 0
#include "frontend/message/ddl_message.h"
#include "frontend/message/message_broker.h"
#include "frontend/message/status.h"
#else
#include "manager/message/ddl_message.h"
#include "manager/message/message_broker.h"
#include "manager/message/status.h"
#endif
#include "manager/metadata/datatypes.h"
#include "manager/metadata/metadata.h"
#include "manager/metadata/tables.h"

#ifdef __cplusplus
extern "C"
{
#endif
#include "postgres.h"
#include "nodes/parsenodes.h"
#ifdef __cplusplus
}
#endif

#include "tablecmds.h"
#include "send_message.h"
#include "drop_table_executor.h"

/* DB name metadata-manager manages */
const std::string DBNAME = "Tsurugi";

using namespace boost;
using namespace manager;
using namespace manager::metadata;
using namespace ogawayama;

/**
 *  @brief Calls the function sending metadata to metadata-manager and drops parameters sended to ogawayama.
 *  @param [in] Table name to remove.
 */
bool drop_table(DropStmt *drop, char *relname)
{
    Assert(drop != nullptr);
    bool success = false;

    if (drop->behavior == DROP_CASCADE) {
        ereport(ERROR,
                (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                 errmsg("Tsurugi does not support CASCADE clause")));
        return success;
    }

    /* Get the object ID of the table to be deleted */
    property_tree::ptree remove_table;
    std::unique_ptr<metadata::Metadata> tables = std::make_unique<Tables>(DBNAME);
    metadata::ErrorCode error = tables->get(relname, remove_table);
    if (error != ErrorCode::OK) {
        if (error == ErrorCode::NAME_NOT_FOUND && drop->missing_ok) {
            success = true;
        } else {
            ereport(ERROR,
                    (errcode(ERRCODE_INTERNAL_ERROR),
                     errmsg("drop_table() get metadata failed.")));
        }
        return success;
    }
    boost::optional<ObjectIdType> remove_table_id = 
        remove_table.get_optional<ObjectIdType>(Tables::ID);
    ObjectIdType object_id = remove_table_id.get();

    /* DROP_TABLE message to ogawayama */
    message::DropTable drop_table_message{object_id};
    success = send_message(drop_table_message);
    if (!success) {
      ereport(ERROR,
              (errcode(ERRCODE_INTERNAL_ERROR), 
              errmsg("send_message() failed. (DROP_TABLE)")));
      return success;
    }

    /* remobe metadata */
    // ToDo: Fix process order.
    error = tables->remove(object_id);
    if (error != ErrorCode::OK) {
        ereport(ERROR,
                (errcode(ERRCODE_INTERNAL_ERROR),
                 errmsg("drop_table() remove metadata failed.")));
        success = false;
        return success;
    }

    return success;
}

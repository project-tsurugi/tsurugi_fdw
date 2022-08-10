/*
 * Copyright 2020 tsurugi project.
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
 *	@file	oltp_receiver.cpp
 *	@brief  the oltp receiver class that handle message
 */

#include "manager/message/status.h"
#include "worker.h"
#include "oltp_receiver.h"

using namespace manager;

message::Status OltpReceiver::receive_create_table(ObjectIdType object_id) 
{
  message::Status ret_val{message::ErrorCode::SUCCESS, (int) metadata::ErrorCode::OK};

  Worker worker;
  manager::metadata::ErrorCode ret_val_read = worker.read_table_metadata(object_id);
  if (ret_val_read != manager::metadata::ErrorCode::OK) {
      message::Status failure{message::ErrorCode::FAILURE, (int) ret_val_read};
      return failure;
  }
  return ret_val;
}

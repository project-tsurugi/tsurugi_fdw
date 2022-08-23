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
 *	@file	oltp_receiver.h
 *	@brief  the oltp receiver class that handle message
 */

#pragma once

#include "manager/message/receiver.h"
#include "manager/message/message.h"
#include "manager/message/status.h"
#include "manager/metadata/metadata.h"

using namespace manager;

class OltpReceiver : public message::Receiver {
 public:
  OltpReceiver() {}
  message::Status receive_begin_ddl(int64_t mode) const { 
    return message::Status(message::ErrorCode::SUCCESS, 0); 
  }
  message::Status receive_end_ddl() const { 
    return message::Status(message::ErrorCode::SUCCESS, 0); 
  }

  message::Status receive_create_table(metadata::ObjectIdType object_id) const ;
};

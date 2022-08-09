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
 *	@file	receiver.h
 *	@brief  the receiver class that handle message
 */

#pragma once

#include "manager/metadata/metadata.h"
#include "frontend/message/status.h"
#include "frontend/message/message.h"

namespace frontend::message {
class Message;

class Receiver {
  public:
  /**
   * @brief Derived class of this Receiver class will receive
   * an instance of Message class
   * @param [in] message an instance of Message class that Receiver will receive.
   * @return an instance of Status class.
   * A primary error code and a secondary error code must be set.
   */
  virtual Status receive_message(Message* message) = 0; // will be depricated.
  virtual Status receive_begin_ddl(uint64_t mode) = 0;
  virtual Status receive_end_ddl() = 0;

  virtual Status receive_create_table(ObjectIdType object_id) { return Status(ErrorCode::SUCCESS, 0); }
  virtual Status receive_alter_table(ObjectIdType object_id) { return Status(ErrorCode::SUCCESS, 0); }
  virtual Status receive_drop_table(ObjectIdType object_id) { return Status(ErrorCode::SUCCESS, 0); }

  virtual Status receive_create_role(ObjectIdType object_id) { return Status(ErrorCode::SUCCESS, 0); }
  virtual Status receive_alter_role(ObjectIdType object_id) { return Status(ErrorCode::SUCCESS, 0); }
  virtual Status receive_drop_role(ObjectIdType object_id) { return Status(ErrorCode::SUCCESS, 0); }

  virtual Status receive_grant_role(ObjectIdType object_id) { return Status(ErrorCode::SUCCESS, 0); }
  virtual Status receive_revoke_role(ObjectIdType object_id) { return Status(ErrorCode::SUCCESS, 0); }
  virtual Status receive_grant_table(ObjectIdType object_id) { return Status(ErrorCode::SUCCESS, 0); }
  virtual Status receive_revoke_table(ObjectIdType object_id) { return Status(ErrorCode::SUCCESS, 0); }
};

}; // namespace frontend::message

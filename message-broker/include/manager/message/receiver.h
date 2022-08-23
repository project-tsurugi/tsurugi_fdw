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

#include "manager/message/status.h"
#include "manager/metadata/metadata.h"

using namespace manager;

namespace manager::message {
class Receiver {
 public:
  /**
   * @brief Derived class of this Receiver class will receive
   * an instance of Message class
   * @return an instance of Status class.
   * A primary error code and a secondary error code must be set.
   */
  virtual Status receive_begin_ddl(const int64_t mode) const = 0;
  virtual Status receive_end_ddl() const = 0;

  // Table object DDL
  virtual Status receive_create_table(const metadata::ObjectIdType object_id) const { 
    return Status(ErrorCode::SUCCESS, 0); 
  }
  virtual Status receive_alter_table(const metadata::ObjectIdType object_id) const { 
    return Status(ErrorCode::SUCCESS, 0); 
  }
  virtual Status receive_drop_table(const metadata::ObjectIdType object_id) const { 
    return Status(ErrorCode::SUCCESS, 0); 
  }

  // Role object DDL
  virtual Status receive_create_role(const metadata::ObjectIdType object_id) const { 
    return Status(ErrorCode::SUCCESS, 0); 
  }
  virtual Status receive_alter_role(const metadata::ObjectIdType object_id) const { 
    return Status(ErrorCode::SUCCESS, 0); 
  }
  virtual Status receive_drop_role(const metadata::ObjectIdType object_id) const { 
    return Status(ErrorCode::SUCCESS, 0); 
  }

  // Grant/Revoke
  virtual Status receive_grant_role(const metadata::ObjectIdType object_id) const { 
    return Status(ErrorCode::SUCCESS, 0); 
  }
  virtual Status receive_revoke_role(const metadata::ObjectIdType object_id) const { 
    return Status(ErrorCode::SUCCESS, 0); 
  }
  virtual Status receive_grant_table(const metadata::ObjectIdType object_id) const { 
    return Status(ErrorCode::SUCCESS, 0); 
  }
  virtual Status receive_revoke_table(const metadata::ObjectIdType object_id) const { 
    return Status(ErrorCode::SUCCESS, 0); 
  }
};

}; // namespace manager::message

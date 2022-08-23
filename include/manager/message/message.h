/*
 * Copyright 2020-2022 tsurugi project.
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
 *	@file	message.h
 *	@brief  the message class for metadata-manager.
 */

#pragma once

#include <string>
#include <vector>
#include <typeinfo>
#include <iostream>

#include "manager/metadata/metadata.h"
#include "manager/message/receiver.h"

using namespace manager;

namespace manager::message {
class Message {
 public:
  static constexpr int64_t NONE = -1;
  /**
   * @brief C'tor. Initialize member variables.
   * @param [in] id message type ID that is an uniquely determined statement ID inputted by user.
   * @note  the meaning of each parameter(param1/param2) is described in the derived class.
   */
  Message(int64_t param1 = NONE, int64_t param2 = NONE)
      : param1_(param1), param2_(param2) {}

  /**
   * @brief Set a receiver that will receive messages.
   * @param [in] receiver_ a receiver
   */
  void set_receiver(Receiver* receiver) { receivers_.push_back(receiver); };
  /**
   * @brief Get all receivers_ that will receive messages.
   * @return all receivers_.
   */
  std::vector<Receiver*> receivers() { return receivers_; };

  int64_t param1() const { return param1_; }
  int64_t param2() const { return param2_; }
  const char* string() { return typeid(*this).name(); }

  /**
   * @brief
   * @return
   */
  Status send(void) {
    Status ret_value{ErrorCode::SUCCESS, (int) ErrorCode::SUCCESS};

    for (auto receiver : this->receivers()) {
      Status status = send_message(*receiver, this->param1(), this->param2());
      if (status.get_error_code() == ErrorCode::FAILURE) {
        return status;
      }
    }
    return ret_value;    
  }

 protected:
  int64_t param1_;
  int64_t param2_;
  std::vector<Receiver*> receivers_;  //!< @brief receivers that will receive message ex) OLTP_Receiver, OLAP_Receiver.

  /**
   * @brief 
   * @param [in] receiver ref of Receiver class.
   * @param [in] param1 1st parameter of message.
   * @param [in] param2 2nd parameter of message.
   * @return  
   */
  virtual Status send_message(
    const Receiver& receiver, int64_t param1, int64_t param2) const = 0;

};

/**
 * @brief BEGIN DDL message.
 */
class BeginDDL : public Message {
 public:
  enum class EXECUTION_MODE : int64_t {
    DEFAULT = 0,
    EXCLUDE,
  };
  /**
   * @brief C'tor. Initialize member variables.
   * @param [in] param1 DDL execution mode.
   */
  BeginDDL(EXECUTION_MODE mode = EXECUTION_MODE::DEFAULT) 
    : Message{static_cast<int64_t> (mode)} {}

  /**
   * @brief
   * @param [in] ref of Receiver class.
   * @param [in] DDL execution mode.
   * @return
   */
  Status send_message(const Receiver& receiver, uint64_t mode, uint64_t) const {
    return receiver.receive_begin_ddl(mode);
  }
};

/**
 * @brief END DDL message.
 */
class EndDDL : public Message {
 public:
  /**
   * @brief C'tor. Initialize member variables.
   */
  EndDDL() : Message{} {}

  /**
   * @brief
   * @param [in] receiver ref of Receiver class.
   * @return
   */
  Status send_message(Receiver& receiver, uint64_t, uint64_t) const {
    return receiver.receive_end_ddl();
  }
};

/**
 * @brief CREATE TABLE message.
 */
class CreateTable : public Message {
 public:
  /**
   * @brief C'tor. Initialize member variables.
   * @param [in] object_id object ID that will be added, updated, or deleted.
   */
  CreateTable(metadata::ObjectIdType object_id) : Message{object_id} {}
  /**
   * @brief
   * @param [in] receiver ref of Receiver class.
   * @return
   */
  Status send_message(Receiver& receiver, uint64_t object_id, uint64_t) const {
    return receiver.receive_create_table(object_id);
  }
};

/**
 * @brief DROP TABLE message.
 */
class DropTable : public Message {
 public:
  /**
   * @brief C'tor. Initialize member variables.
   * @param [in] object_id object ID that will be added, updated, or deleted.
   */
  DropTable(metadata::ObjectIdType object_id) : Message{object_id} {}
  /**
   * @brief
   * @param [in] receiver ref of Receiver class.
   * @return
   */
  Status send_message(Receiver& receiver, uint64_t object_id, uint64_t) const {
    return receiver.receive_drop_table(object_id);
  }
};

/**
 * @brief CREATE ROLE message.
 */
class CreateRole : public Message {
 public:
  /**
   * @brief C'tor. Initialize member variables.
   * @param [in] object_id object ID that will be added, updated, or deleted.
   */
  CreateRole(metadata::ObjectIdType object_id) : Message{object_id} {}
  /**
   * @brief
   * @param [in] receiver ref of Receiver class.
   * @return
   */
  Status send_message(Receiver& receiver, uint64_t object_id, uint64_t) const {
    return receiver.receive_create_role(object_id);
  }
};

/**
 * @brief ALTER ROLE message.
 */
class AlterRole : public Message {
  AlterRole(metadata::ObjectIdType object_id) : Message{object_id} {}
  /**
   * @brief
   * @param [in] receiver ref of Receiver class.
   * @return
   */
  Status send_message(Receiver& receiver, uint64_t object_id, uint64_t) const {
    return receiver.receive_alter_role(object_id);
  }
};

/**
 * @brief DROP ROLE message.
 */
class DropRole : public Message {
  DropRole(metadata::ObjectIdType object_id) : Message{object_id} {}
  /**
   * @brief
   * @param [in] receiver ref of Receiver class.
   * @return
   */
  Status send_message(Receiver& receiver, uint64_t object_id, uint64_t) const {
    return receiver.receive_drop_role(object_id);
  }
};

/**
 * @brief GRANT ROLE message.
 */
class GrantRole : public Message {
 public:
  /**
   * @brief C'tor. Initialize member variables.
   * @param [in] object_id object ID that will be added, updated, or deleted.
   */
  GrantRole(metadata::ObjectIdType object_id) : Message{object_id} {}
  /**
   * @brief
   * @param [in] receiver ref of Receiver class.
   * @return
   */
  Status send_message(Receiver& receiver, uint64_t object_id, uint64_t) const {
    return receiver.receive_grant_role(object_id);
  }
};

/**
 * @brief REVOKE ROLE message.
 */
class RevokeRole : public Message {
 public:
  /**
   * @brief C'tor. Initialize member variables.
   * @param [in] object_id object ID that will be added, updated, or deleted.
   */
  RevokeRole(metadata::ObjectIdType object_id) : Message{object_id} {}
  /**
   * @brief
   * @param [in] receiver ref of Receiver class.
   * @return
   */
  Status send_message(Receiver& receiver, uint64_t object_id, uint64_t) const {
    return receiver.receive_revoke_role(object_id);
  }
};

/**
 * @brief GRANT TABLE message.
 */
class GrantTable :  public Message {
 public:
  /**
   * @brief C'tor. Initialize member variables.
   * @param [in] object_id object ID that will be added, updated, or deleted.
   */
  GrantTable(metadata::ObjectIdType object_id) : Message{object_id} {}
  /**
   * @brief
   * @param [in] receiver ref of Receiver class.
   * @return
   */
  Status send_message(Receiver& receiver, uint64_t object_id, uint64_t) const {
    return receiver.receive_grant_table(object_id);
  }
};

/**
 * @brief REVOKE TABLE message.
 */
class RevokeTable : public Message {
 public:
  /**
   * @brief C'tor. Initialize member variables.
   * @param [in] object_id object ID that will be added, updated, or deleted.
   */
  RevokeTable(metadata::ObjectIdType object_id) : Message{object_id} {}
  /**
   * @brief
   * @param [in] receiver ref of Receiver class.
   * @return
   */
  Status send_message(Receiver& receiver, uint64_t object_id, uint64_t) const {
    return receiver.receive_revoke_table(object_id);
  }
};

};  // namespace manager::message

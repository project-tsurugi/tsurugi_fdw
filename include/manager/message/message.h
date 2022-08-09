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

#include "manager/metadata/metadata.h"
#include "manager/message/receiver.h"

namespace manager::message {

class Message {
 public:
  static constexpr uint64_t NONE = 0;
  /**
   * @brief C'tor. Initialize member variables.
   * @param [in] id message type ID that is an uniquely determined statement ID inputted by user.
   * @note  the meaning of each parameter(param1/param2) is described in the derived class.
   */
  Message(uint64_t param1 = NONE, uint64_t param2 = NONE)
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
  std::vector<Receiver*> get_receivers() { return receivers_; };

  uint64_t param1() { return param1_; }
  uint64_t param2() { return param2_; }
  const char* string() { return typeid(*this).name(); }
  virtual Status execute() = 0;

 protected:
  uint64_t param1_;
  uint64_t param2_;
  std::vector<Receiver*> receivers_;  //!< @brief receivers that will receive message ex) OLTP_Receiver, OLAP_Receiver.
};

/**
 * @brief BEGIN DDL message.
 */
class BeginDDL : public Message {
 public:
  static constexpr uint64_t DEFAULT_MODE = 0;
  /**
   * @brief C'tor. Initialize member variables.
   * @param [in] param1 DDL execution mode.
   */
  BeginDDL(uint64_t mode = DEFAULT_MODE) : Message{mode} {}

  Status execute() {
    Status ret_value{ErrorCode::SUCCESS, (int) ErrorCode::SUCCESS};

    for (Receiver* receiver : this->get_receivers()) {
      Status status = receiver->receive_begin_ddl(this->param1());
      if (status.get_error_code() == ErrorCode::FAILURE) {
        return status;
      }
    }
    return ret_value;
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

  Status execute() {
    Status ret_value{ErrorCode::SUCCESS, (int) ErrorCode::SUCCESS};

    for (Receiver* receiver : this->get_receivers()) {
      Status status = receiver->receive_end_ddl();
      if (status.get_error_code() == ErrorCode::FAILURE) {
        return status;
      }
    }
    return ret_value;
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

  Status execute() {
    Status ret_value{ErrorCode::SUCCESS, (int) ErrorCode::SUCCESS};

    for (Receiver* receiver : this->get_receivers()) {
      Status status = receiver->receive_create_table(this->param1());
      if (status.get_error_code() == ErrorCode::FAILURE) {
        return status;
      }
    }
    return ret_value;
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

  Status execute() {
    Status ret_value{ErrorCode::SUCCESS, (int) ErrorCode::SUCCESS};

    for (Receiver* receiver : this->get_receivers()) {
      Status status = receiver->receive_create_role(this->param1());
      if (status.get_error_code() == ErrorCode::FAILURE) {
        return status;
      }
    }
    return ret_value;
  }
};

/**
 * @brief ALTER ROLE message.
 */
class AlterRole : public Message {
  AlterRole(metadata::ObjectIdType object_id) : Message{object_id} {}

  Status execute() {
    Status ret_value{ErrorCode::SUCCESS, (int) ErrorCode::SUCCESS};

    for (Receiver* receiver : this->get_receivers()) {
      Status status = receiver->receive_alter_role(this->param1());
      if (status.get_error_code() == ErrorCode::FAILURE) {
        return status;
      }
    }
    return ret_value;
  }
};

/**
 * @brief DROP ROLE message.
 */
class DropRole : public Message {
  DropRole(metadata::ObjectIdType object_id) : Message{object_id} {}

  Status execute() {
    Status ret_value{ErrorCode::SUCCESS, (int) ErrorCode::SUCCESS};

    for (Receiver* receiver : this->get_receivers()) {
      Status status = receiver->receive_drop_role(this->param1());
      if (status.get_error_code() == ErrorCode::FAILURE) {
        return status;
      }
    }
    return ret_value;
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

  Status execute() {
    Status ret_value{ErrorCode::SUCCESS, (int) ErrorCode::SUCCESS};

    for (Receiver* receiver : this->get_receivers()) {
      Status status = receiver->receive_grant_role(this->param1());
      if (status.get_error_code() == ErrorCode::FAILURE) {
        return status;
      }
    }
    return ret_value;
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

  Status execute() {
    Status ret_value{ErrorCode::SUCCESS, (int) ErrorCode::SUCCESS};

    for (Receiver* receiver : this->get_receivers()) {
      Status status = receiver->receive_revoke_role(this->param1());
      if (status.get_error_code() == ErrorCode::FAILURE) {
        return status;
      }
    }
    return ret_value;
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

  Status execute() {
    Status ret_value{ErrorCode::SUCCESS, (int) ErrorCode::SUCCESS};

    for (Receiver* receiver : this->get_receivers()) {
      Status status = receiver->receive_grant_table(this->param1());
      if (status.get_error_code() == ErrorCode::FAILURE) {
        return status;
      }
    }
    return ret_value;
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

  Status execute() {
    Status ret_value{ErrorCode::SUCCESS, (int) ErrorCode::SUCCESS};

    for (Receiver* receiver : this->get_receivers()) {
      Status status = receiver->receive_revoke_table(this->param1());
      if (status.get_error_code() == ErrorCode::FAILURE) {
        return status;
      }
    }
    return ret_value;
  }
};

};  // namespace manager::message

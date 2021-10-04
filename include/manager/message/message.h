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
 *	@brief  the message class dipatched to ogawayama
 */

#ifndef MESSAGE_H
#define MESSAGE_H

#include <string>
#include <vector>

#include "manager/message/receiver.h"

namespace manager::message {
class Receiver;

const std::string MESSAGE_TYPE_NANE_CREATE_TABLE = "CREATE TABLE";
const std::string MESSAGE_TYPE_NANE_BEGIN_DDL = "BEGIN DDL";
const std::string MESSAGE_TYPE_NANE_END_DDL = "END DDL";
const std::string MESSAGE_TYPE_NANE_CREATE_ROLE = "CREATE ROLE";
const std::string MESSAGE_TYPE_NANE_DROP_ROLE = "DROP ROLE";
const std::string MESSAGE_TYPE_NANE_ALTER_ROLE = "ALTER ROLE";
const std::string MESSAGE_TYPE_NANE_GRANT_ROLE = "GRANT ROLE";
const std::string MESSAGE_TYPE_NANE_REVOKE_ROLE = "REVOKE ROLE";
const std::string MESSAGE_TYPE_NANE_GRANT_TABLE = "GRANT TABLE";
const std::string MESSAGE_TYPE_NANE_REVOKE_TABLE = "REVOKE TABLE";

/**
 * @enum MessageId
 * @brief message type ID that is an uniquely determined statement ID inputted by user.
 */
enum class MessageId : int {
  CREATE_TABLE = 0,  //!< @brief CREATE TABLE statement.
  BEGIN_DDL,         //!< @brief BEGIN DDL statement.
  END_DDL,           //!< @brief END DDL statement.
  CREATE_ROLE,       //!< @brief CREATE ROLE statement.
  DROP_ROLE,         //!< @brief DROP ROLE statement.
  ALTER_ROLE,        //!< @brief ALTER ROLE statement.
  GRANT_ROLE,        //!< @brief GRANT ROLE statement.
  REVOKE_ROLE,       //!< @brief REVOKE ROLE statement.
  GRANT_TABLE,       //!< @brief GRANT TABLE statement.
  REVOKE_TABLE       //!< @brief REVOKE TABLE statement.

};

class Message {
 public:
  /**
   * @brief C'tor. Initialize member variables.
   * @param [in] id message type ID that is an uniquely determined statement ID inputted by user.
   * @param [in] object_id object ID that will be added, updated, or deleted.
   * @param [in] message_type_name string in order to report error messages.
   */
  Message(MessageId id, uint64_t object_id, std::string message_type_name)
      : id(id), object_id(object_id), message_type_name(message_type_name){};

  /**
   * @brief Set a receiver that will receive messages.
   * @param [in] receiver_ a receiver
   */
  void set_receiver(Receiver* receiver_) { receivers.push_back(receiver_); };

  /**
   * @brief Get message type ID that is an uniquely determined statement ID inputted by user.
   * @return message type ID.
   */
  MessageId get_id() { return id; };

  /**
   * @brief Get object ID that will be added, updated, or deleted.
   * @return object ID.
   */
  uint64_t get_object_id() { return object_id; };

  /**
   * @brief Get all receivers that will receive messages.
   * @return all receivers.
   */
  std::vector<Receiver*> get_receivers() { return receivers; };

  /**
   * @brief Get message type name to report error messages.
   * @return message type name.
   */
  std::string get_message_type_name() { return message_type_name; };

 private:
  MessageId id;                     //!< @brief message type ID that is an uniquely determined statement ID inputted by user.
  uint64_t object_id;               //!< @brief object ID that will be added, updated, or deleted.
  std::vector<Receiver*> receivers; //!< @brief receivers that will receive message ex) OLTP_Receiver, OLAP_Receiver.
  std::string message_type_name;    //!< @brief string in order to report error messages ex)"CREATE TABLE"
};

class CreateTableMessage : public Message {
 public:
  /**
   * @brief C'tor. Initialize member variables.
   * @param [in] object_id object ID that will be added, updated, or deleted.
   */
  CreateTableMessage(uint64_t object_id)
      : Message{MessageId::CREATE_TABLE, object_id,
                MESSAGE_TYPE_NANE_CREATE_TABLE} {}
};

class BeginDDLMessage : public Message {
 public:
  /**
   * @brief C'tor. Initialize member variables.
   * @param [in] object_id object ID that will be added, updated, or deleted.
   */
  BeginDDLMessage(uint64_t object_id)
      : Message{MessageId::BEGIN_DDL, object_id,
                MESSAGE_TYPE_NANE_BEGIN_DDL} {}
};

class EndDDLMessage : public Message {
 public:
  /**
   * @brief C'tor. Initialize member variables.
   * @param [in] object_id object ID that will be added, updated, or deleted.
   */
  EndDDLMessage(uint64_t object_id)
      : Message{MessageId::END_DDL, object_id,
                MESSAGE_TYPE_NANE_END_DDL} {}
};

class CreateRoleMessage : public Message {
 public:
  /**
   * @brief C'tor. Initialize member variables.
   * @param [in] object_id object ID that will be added, updated, or deleted.
   */
  CreateRoleMessage(uint64_t object_id)
      : Message{MessageId::CREATE_ROLE, object_id,
                MESSAGE_TYPE_NANE_CREATE_ROLE} {}
};

class DropRoleMessage : public Message {
  DropRoleMessage(uint64_t object_id)
      : Message{MessageId::DROP_ROLE, object_id,
                MESSAGE_TYPE_NANE_DROP_ROLE} {}
};

class AlterRoleMessage : public Message {
  AlterRoleMessage(uint64_t object_id)
      : Message{MessageId::ALTER_ROLE, object_id,
                MESSAGE_TYPE_NANE_ALTER_ROLE} {}
};

class GrantRoleMessage : public Message {
 public:
  /**
   * @brief C'tor. Initialize member variables.
   * @param [in] object_id object ID that will be added, updated, or deleted.
   */
  GrantRoleMessage(uint64_t object_id)
      : Message{MessageId::GRANT_ROLE, object_id,
                MESSAGE_TYPE_NANE_GRANT_ROLE} {}
};

class RevokeRoleMessage : public Message {
 public:
  /**
   * @brief C'tor. Initialize member variables.
   * @param [in] object_id object ID that will be added, updated, or deleted.
   */
  RevokeRoleMessage(uint64_t object_id)
      : Message{MessageId::REVOKE_ROLE, object_id,
                MESSAGE_TYPE_NANE_REVOKE_ROLE} {}
};

class GrantTableMessage : public Message {
 public:
  /**
   * @brief C'tor. Initialize member variables.
   * @param [in] object_id object ID that will be added, updated, or deleted.
   */
  GrantTableMessage(uint64_t object_id)
      : Message{MessageId::GRANT_TABLE, object_id,
                MESSAGE_TYPE_NANE_GRANT_TABLE} {}
};

class RevokeTableMessage : public Message {
 public:
  /**
   * @brief C'tor. Initialize member variables.
   * @param [in] object_id object ID that will be added, updated, or deleted.
   */
  RevokeTableMessage(uint64_t object_id)
      : Message{MessageId::REVOKE_TABLE, object_id,
                MESSAGE_TYPE_NANE_REVOKE_TABLE} {}
};

};  // namespace manager::message

#endif  // MESSAGE_H

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
 *	@file	message.h
 *	@brief  the message class dipatched to ogawayama
 */

#ifndef MOCK_MESSAGE_H
#define MOCK_MESSAGE_H

#include <string>
#include <vector>

#include "manager/message/message.h"

namespace manager::message {
const std::string MESSAGE_TYPE_NAME_CREATE_ROLE = "CREATE_ROLE";
const std::string MESSAGE_TYPE_NANE_DROP_ROLE = "DROP ROLE";
const std::string MESSAGE_TYPE_NANE_ALTER_ROLE = "ALTER ROLE";
const std::string MESSAGE_TYPE_NANE_GRANT_ROLE = "GRANT ROLE";
const std::string MESSAGE_TYPE_NANE_REVOKE_ROLE = "REVOKE ROLE";
const std::string MESSAGE_TYPE_NANE_GRANT_TABLE = "GRANT TABLE ";
const std::string MESSAGE_TYPE_NANE_REVOKE_TABLE = "REVOKE TABLE ";

class CreateRoleMessage : public Message {
 public:
  CreateRoleMessage(uint64_t object_id)
      : Message{MessageId::CREATE_TABLE, object_id,
                MESSAGE_TYPE_NAME_CREATE_ROLE} {}
};

class DropRoleMessage : public Message {
 public:
  /**
   * @brief C'tor. Initialize member variables.
   * @param [in] object_id object ID that will be added, updated, or deleted.
   */
  DropRoleMessage(uint64_t object_id)
      : Message{MessageId::CREATE_TABLE, object_id, MESSAGE_TYPE_NANE_DROP_ROLE} {}
};

class AlterRoleMessage : public Message {
 public:
  /**
   * @brief C'tor. Initialize member variables.
   * @param [in] object_id object ID that will be added, updated, or deleted.
   */
  AlterRoleMessage(uint64_t object_id)
      : Message{MessageId::CREATE_TABLE, object_id,
                MESSAGE_TYPE_NANE_ALTER_ROLE} {}
};

class GrantRoleMessage : public Message {
 public:
  /**
   * @brief C'tor. Initialize member variables.
   * @param [in] object_id object ID that will be added, updated, or deleted.
   */
  GrantRoleMessage(uint64_t object_id)
      : Message{MessageId::CREATE_TABLE, object_id,
                MESSAGE_TYPE_NANE_GRANT_ROLE} {}
};

class RevokeRoleMessage : public Message {
 public:
  /**
   * @brief C'tor. Initialize member variables.
   * @param [in] object_id object ID that will be added, updated, or deleted.
   */
  RevokeRoleMessage(uint64_t object_id)
      : Message{MessageId::CREATE_TABLE, object_id,
                MESSAGE_TYPE_NANE_REVOKE_ROLE} {}
};

class GrantTableMessage : public Message {
 public:
  /**
   * @brief C'tor. Initialize member variables.
   * @param [in] object_id object ID that will be added, updated, or deleted.
   */
  GrantTableMessage(uint64_t object_id)
      : Message{MessageId::CREATE_TABLE, object_id,
                MESSAGE_TYPE_NANE_GRANT_TABLE} {}
};

class RevokeTableMessage : public Message {
 public:
  /**
   * @brief C'tor. Initialize member variables.
   * @param [in] object_id object ID that will be added, updated, or deleted.
   */
  RevokeTableMessage(uint64_t object_id)
      : Message{MessageId::CREATE_TABLE, object_id,
                MESSAGE_TYPE_NANE_REVOKE_TABLE} {}
};

};  // namespace manager::message

#endif  // MESSAGE_H

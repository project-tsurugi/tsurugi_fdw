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

namespace manager::message
{
    const std::string MESSAGE_TYPE_NAME_CREATE_ROLE = "CREATE_ROLE";

    class CreateRoleMessage : public Message
    {
      public:
        CreateRoleMessage(uint64_t object_id)
          :Message{MessageId::CREATE_TABLE, object_id, MESSAGE_TYPE_NAME_CREATE_ROLE} {}
    };

}; // namespace manager::message

#endif // MESSAGE_H

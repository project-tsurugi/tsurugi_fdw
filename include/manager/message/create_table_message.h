/*
 * Copyright 2019-2020 tsurugi project.
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
 *	@file	create_table_message.h
 *	@brief  the create-table message class dipatched to ogawayama
 */

#ifndef CREATE_TABLE_MESSAGE_H
#define CREATE_TABLE_MESSAGE_H

#include <string>

#include "manager/message/message.h"

namespace manager::message
{
    const std::string MESSAGE_TYPE_NANE_CREATE_TABLE = "CREATE TABLE";

    class CreateTableMessage : public Message
    {
        public:
            // C'tors
            CreateTableMessage(uint64_t object_id)
                : Message(MESSAGE_TYPE_NANE_CREATE_TABLE, object_id) {}
    };

}; // namespace manager::message

#endif // CREATE_TABLE_MESSAGE_H

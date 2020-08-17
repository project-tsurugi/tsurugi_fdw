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
 *	@file	message.h
 *	@brief  the message class dipatched to ogawayama
 */

#ifndef MESSAGE_H
#define MESSAGE_H

#include <string>

#include "manager/message/receiver.h"

namespace manager::message
{
    class Receiver;

    const std::string MESSAGE_TYPE_NANE_CREATE_TABLE = "CREATE TABLE";

    enum class MessageId : int
    {
        /**
        *  @brief CREATE_TABLE.
        */
        CREATE_TABLE = 0
    };

    class Message {
        public:
            // C'tors
            Message(MessageId id, uint64_t object_id, std::string message_type_name)
                : id(id), object_id(object_id), message_type_name(message_type_name){};

            void set_receiver(Receiver *receiver_) {
                receivers.push_back(receiver_);
            };

            MessageId get_id(){
                return id;
            };
            uint64_t get_object_id(){
                return object_id;
            };
            std::vector<Receiver *> get_receivers()
            {
                return receivers;
            };
            std::string get_message_type_name()
            {
                return message_type_name;
            };

        private:
            MessageId id;                      // message type ID
            uint64_t object_id;                // object ID that will be added, updated, or deleted
            std::vector<Receiver *> receivers; // receiver ex) OLTP_Receiver, OLAP_Receiver
            std::string message_type_name;      // for error message ex)"CREATE TABLE"
    };

    class CreateTableMessage : public Message
    {
        public:
            // C'tors
            CreateTableMessage(uint64_t object_id)
                : Message{MessageId::CREATE_TABLE, object_id, MESSAGE_TYPE_NANE_CREATE_TABLE} {}
    };

}; // namespace manager::message

#endif // MESSAGE_H

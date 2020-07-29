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
 *	@file	Message.h
 *	@brief  the message class dipatched to ogawayama
 */

#ifndef MESSAGE_
#define MESSAGE_

#include "Receiver.h"

namespace manager::message-broker
{

    enum class MESSAGE_ID
    {
        /**
        *  @brief CREATE_TABLE.
        */
        CREATE_TABLE = 0,

        /**
        *  @brief DROP_TABLE.
        */
        DROP_TABLE
    };

    class Message {
        public:
            // C'tors
            Message(std::string message_type_name, uint64_t object_id)
                : message_type_name(message_type_name), object_id(object_id) {};
            void set_receiver(Receiver *receiver_) {
                receivers.push_back(receiver_);
            };

            MESSAGE_ID get_id(){
                return id;
            };
            std::string get_message_type_name(){
                return message_type_name;
            };
            uint64_t get_object_id(){
                return object_id;
            };

        private:
            MESSAGE_ID id;                  // message type ID
            uint64_t object_id;             // object ID that will be added, updated, or deleted
            vector<Receiver *> receivers;   // receiver ex) OLTP_Receiver, OLAP_Receiver
            std::string message_type_name;  // for error message ex)"CREATE TABLE"
    };

}; // namespace manager::message-broker

#endif // MESSAGE_

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

#ifndef MESSAGE_H
#define MESSAGE_H

#include <string>
#include <vector>

#include "manager/message/receiver.h"

namespace manager::message
{
    class Receiver;

    const std::string MESSAGE_TYPE_NANE_CREATE_TABLE = "CREATE TABLE";

    /**
     * @enum MessageId
     * @brief message type ID that is an uniquely determined statement ID inputted by user.
     */
    enum class MessageId : int
    {
        /**
         *  @brief CREATE TABLE statement.
         */
        CREATE_TABLE = 0
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
            void set_receiver(Receiver *receiver_) {
                receivers.push_back(receiver_);
            };

            /**
             * @brief Get message type ID that is an uniquely determined statement ID inputted by user.
             * @return message type ID.
             */
            MessageId get_id(){
                return id;
            };

            /**
             * @brief Get object ID that will be added, updated, or deleted.
             * @return object ID.
             */
            uint64_t get_object_id(){
                return object_id;
            };

            /**
             * @brief Get all receivers that will receive messages.
             * @return all receivers.
             */
            std::vector<Receiver *> get_receivers()
            {
                return receivers;
            };

            /**
             * @brief Get message type name to report error messages.
             * @return message type name.
             */
            std::string get_message_type_name()
            {
                return message_type_name;
            };

        private:
            MessageId id; //!< @brief message type ID that is an uniquely determined statement ID inputted by user.
            uint64_t object_id; //!< @brief object ID that will be added, updated, or deleted.
            std::vector<Receiver *> receivers; //!< @brief receivers that will receive message ex) OLTP_Receiver, OLAP_Receiver.
            std::string message_type_name; //!< @brief string in order to report error messages ex)"CREATE TABLE"
    };

    class CreateTableMessage : public Message
    {
        public:
            /**
             * @brief C'tor. Initialize member variables.
             * @param [in] object_id object ID that will be added, updated, or deleted.
             */
            CreateTableMessage(uint64_t object_id)
                : Message{MessageId::CREATE_TABLE, object_id, MESSAGE_TYPE_NANE_CREATE_TABLE} {}
    };

}; // namespace manager::message

#endif // MESSAGE_H

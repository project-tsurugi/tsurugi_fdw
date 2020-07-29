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
 *	@file	MessageBroker.h
 *	@brief  the message broker class sends message from frontend to Receiver
 */

#ifndef MESSAGEBROKER_
#define MESSAGEBROKER_

#include "Message.h"
#include "Receiver.h"

namespace manager::message-broker
{

    class MessageBroker {
        public:
            void send_message(Message *message)
            {
                for (Receiver &receiver : message->receivers)
                {
                    receiver.receive_message(message);
                }
            }
    };

}; // namespace manager::message-broker

#endif // MESSAGEBROKER_

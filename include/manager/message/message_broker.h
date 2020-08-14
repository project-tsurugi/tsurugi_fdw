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
 *	@file	message_broker.h
 *	@brief  the message broker class sends message from frontend to Receiver
 */

#ifndef MESSAGE_BROKER_H
#define MESSAGE_BROKER_H

#include "manager/message/status.h"
#include "manager/message/message.h"
#include "manager/message/receiver.h"

namespace manager::message
{

    class MessageBroker {
        public:
            Status send_message(Message *message)
            {
                Status ret_val{ErrorCode::SUCCESS, (int)ErrorCode::SUCCESS, ReceiverId::ALL_RECEIVERS};

                for (Receiver *receiver : message->get_receivers())
                {
                    auto status = receiver->receive_message(message);
                    if(status.get_error_code() == ErrorCode::FAILURE){
                        return status;
                    }
                }
                return ret_val;
            }
    };

}; // namespace manager::message

#endif // MESSAGE_BROKER_H

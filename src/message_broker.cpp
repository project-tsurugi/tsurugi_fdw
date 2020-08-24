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
 *	@file	message_broker.cpp
 *	@brief  the message broker class sends message
 *          to all receivers of message
 */

#include "manager/message/message_broker.h"

namespace manager::message
{


    /**
     * @brief MessageBroker sends a message to all receivers.
     * @param [in] message an instance of Message class that Receiver will receive.
     * @return both primary error code and secondary error code
     * are ErrorCode::SUCCESS
     * if all receivers' process is successfully completed.
     * @return an instance of Status class otherwize.
     * A primary error code and a secondary error code must be set.
     */
    Status MessageBroker::send_message(Message *message)
    {
        Status ret_val{ErrorCode::SUCCESS, (int)ErrorCode::SUCCESS};
        for (Receiver *receiver : message->get_receivers())
        {
            Status status = receiver->receive_message(message);
            if (status.get_error_code() == ErrorCode::FAILURE)
            {
                return status;
            }
        }
        return ret_val;
    }

}; // namespace manager::message

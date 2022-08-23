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

#include "frontend/message/message.h"
#include "frontend/message/message_broker.h"
#include "frontend/message/status.h"

namespace frontend::message {
  /**
   * @brief MessageBroker sends a message to all receivers.
   * @param [in] message an instance of Message class that Receiver will receive.
   * @return both primary error code and secondary error code
   * are ErrorCode::SUCCESS
   * if all receivers' process is successfully completed.
   * @return an instance of Status class otherwize.
   * A primary error code and a secondary error code must be set.
   */
  Status MessageBroker::send_message(message::Message* msg) {
    Status status{ErrorCode::SUCCESS, 0};
    status = msg->send_to_receivers();
    return status;
  }

}; // namespace frontend::message

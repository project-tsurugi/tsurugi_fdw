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
 *	@file	Receiver.h
 *	@brief  the receiver class that handle message
 */

#ifndef RECEIVER_
#define RECEIVER_

namespace manager::message-broker
{
    class Receiver
    {
        public:
            virtual ErrorCode receive_message(Message* message) = 0;
    };

}; // namespace manager::message-broker

#endif // RECEIVER_

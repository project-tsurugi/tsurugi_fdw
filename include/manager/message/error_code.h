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
 *	@file	error_code.h
 *	@brief  error code of message-broker
 */

#ifndef MESSAGE_ERROR_CODE_H
#define MESSAGE_ERROR_CODE_H

namespace manager::message {

    enum class ErrorCode
    {
        /**
         *  @brief Success.
         */
        OK = 0,

        /**
         * @brief Unsupported function.
         */
        UNSUPPORTED,

        /**
         * @brief Unknown error.
         */
        UNKNOWN,

        /**
         * @brief Server failure.
         */
        SERVER_FAILURE
    };

} // namespace manager::message

#endif // MESSAGE_ERROR_CODE_H

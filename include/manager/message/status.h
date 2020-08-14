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
 *	@file	status.h
 *	@brief  error code of message-broker
 */

#ifndef STATUS_H
#define STATUS_H

namespace manager::message
{

    enum class ErrorCode : int
    {
        SUCCESS = 0,
        FAILURE
    };

    class Status
    {
        public:
            Status(ErrorCode error_code, int sub_error_code)
                : error_code(error_code), sub_error_code(sub_error_code) {}
            ErrorCode get_error_code()
            {
                return error_code;
            }
            int get_sub_error_code()
            {
                return sub_error_code;
            }

        private:
            ErrorCode error_code;
            int sub_error_code;
    };
} // namespace manager::message

#endif // STATUS_H

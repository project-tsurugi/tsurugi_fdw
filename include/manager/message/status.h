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

    /**
     *  @brief a primary error code.
     */
    enum class ErrorCode : int
    {
        /**
         *  @brief Success.
         */
        SUCCESS = 0,

        /**
         *  @brief Failure.
         */
        FAILURE
    };

    class Status
    {
        public:
            /**
             * @brief C'tor. Initialize member variables.
             * @param [in] ErrorCode primary error code.
             * @param [in] int secondary error code.
             */
            Status(ErrorCode error_code, int sub_error_code)
                : error_code(error_code), sub_error_code(sub_error_code) {}
            /**
             *  @brief Get a primary error code.
             *  @return ErrorCode::SUCCESS if metadata was successfully stored
             *  @return ErrorCode::FAILURE otherwize
             */
            ErrorCode get_error_code()
            {
                return error_code;
            }
            /**
             *  @brief Get a secondary error code.
             *  @return an integer value of error code managed by other component.
             */
            int get_sub_error_code()
            {
                return sub_error_code;
            }

        private:
            /**
             * @brief a primary error code.
             */
            ErrorCode error_code;

            /**
             * @brief a secondary error code that is an integer value of error code managed by other component.
             */
            int sub_error_code;
    };
} // namespace manager::message

#endif // STATUS_H

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
#pragma once

namespace frontend::message {
/**
 *  @enum ErrorCode
 *  @brief a primary error code.
 */
enum class ErrorCode : int {
  SUCCESS = 0,
  FAILURE
};

class Status {
  public:
  /**
   * @brief C'tor. Initialize member variables.
   * @param [in] error_code a primary error code managed by message-broker.
   * @param [in] sub_error_code a secondary error code
   * that is an integer value of error code managed by receiver.
   */
  Status(ErrorCode error_code, int sub_error_code) :
    error_code_(error_code), sub_error_code_(sub_error_code) {}

  /**
   *  @brief Get a primary error code.
   *  @return ErrorCode::SUCCESS if Receiver's process succeeded.
   *  @return ErrorCode::FAILURE otherwise
   */
  ErrorCode get_error_code() {
    return error_code_;
  }

  /**
   *  @brief Get a secondary error code.
   *  @return an integer value of error code managed by other component.
   */
  int get_sub_error_code() {
    return sub_error_code_;
  }

  ErrorCode error_code() {
    return error_code_;
  }

  int sub_error_code() {
    return sub_error_code_;
  }

  private:
  /**
   * @brief a primary error code managed by message-broker.
   */
  ErrorCode error_code_;

  /**
   * @brief a secondary error code
   * that is an integer value of error code managed by receiver.
   */
  int sub_error_code_;
};
} // namespace frontend::message

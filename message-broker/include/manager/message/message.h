/*
 * Copyright 2020-2022 tsurugi project.
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
 *	@brief  the message class for metadata-manager.
 */
#pragma once

#include <string>
#include <vector>
#include <typeinfo>
#include <iostream>

#include "manager/metadata/metadata.h"
#include "manager/message/receiver.h"
#include "manager/message/status.h"

using namespace manager;

namespace manager::message {
class Message {
 public:
  static constexpr int64_t NONE = -1;
  /**
   * @brief C'tor. Initialize member variables.
   * @param [in] id message type ID that is an uniquely determined statement ID inputted by user.
   * @note  the meaning of each parameter(param1/param2) is described in the derived class.
   */
  Message(int64_t param1 = NONE, int64_t param2 = NONE)
      : param1_(param1), param2_(param2) {}

  /**
   * @brief Set a receiver that will receive messages.
   * @param [in] receiver_ a receiver
   */
  void set_receiver(Receiver* receiver) { receivers_.push_back(receiver); };
  /**
   * @brief Get all receivers_ that will receive messages.
   * @return all receivers_.
   */
  std::vector<Receiver*> receivers() { return receivers_; };

  int64_t param1() const { return param1_; }
  int64_t param2() const { return param2_; }
  const char* string() { return typeid(*this).name(); }

  /**
   * @brief
   * @return
   */
  Status send_to_receivers(void) {
    Status ret_value{ErrorCode::SUCCESS, (int) ErrorCode::SUCCESS};

    for (auto receiver : this->receivers()) {
      Status status = send_message(*receiver, this->param1(), this->param2());
      if (status.get_error_code() == ErrorCode::FAILURE) {
        return status;
      }
    }
    return ret_value;    
  }

 protected:
  int64_t param1_;
  int64_t param2_;
  std::vector<Receiver*> receivers_;  //!< @brief receivers that will receive message ex) OLTP_Receiver, OLAP_Receiver.

  /**
   * @brief 
   * @param [in] receiver ref of Receiver class.
   * @param [in] param1 1st parameter of message.
   * @param [in] param2 2nd parameter of message.
   * @return  
   */
  virtual Status send_message(
    const Receiver& receiver, const int64_t param1, const int64_t param2) const = 0;

};

};  // namespace manager::message

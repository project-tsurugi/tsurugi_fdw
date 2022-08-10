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
 *	@file	main.cpp
 *  @brief  sample code main
 */

#include <iostream>
#include "manager/message/message.h"
#include "manager/message/message_broker.h"
#include "oltp_receiver.h"

using namespace manager;

int main()
{
  message::BeginDDL begin_ddl;
  message::EndDDL end_ddl;
  message::CreateTable ct_msg_0{1};
  message::CreateTable ct_msg_1{1};
  message::CreateTable ct_msg_2{2};
  message::CreateTable ct_msg_3{3};

  OltpReceiver oltp_receiver;
  begin_ddl.set_receiver(&oltp_receiver);
  ct_msg_0.set_receiver(&oltp_receiver);
  ct_msg_1.set_receiver(&oltp_receiver);
  ct_msg_2.set_receiver(&oltp_receiver);
  ct_msg_3.set_receiver(&oltp_receiver);

  message::Status status = message::MessageBroker::send_message(&begin_ddl);
  std::cout << "message: " << begin_ddl.string() << ", "
            << "primary error code:" << (int)status.get_error_code()
            << ",secondary error code:" << status.get_sub_error_code() << std::endl << std::endl;

  status = message::MessageBroker::send_message(&ct_msg_0);
  std::cout << "message: " << ct_msg_0.string() << ", "
            << "primary error code:" << (int)status.get_error_code()
            << ",secondary error code:" << status.get_sub_error_code() << std::endl << std::endl;;

  status = message::MessageBroker::send_message(&ct_msg_1);
  std::cout << "message: " << ct_msg_1.string() << ", "
            << "primary error code:" << (int)status.get_error_code()
            << ",secondary error code:" << status.get_sub_error_code() << std::endl << std::endl;;

  status = message::MessageBroker::send_message(&ct_msg_2);
  std::cout << "message: " << ct_msg_2.string() << ", "
            << "primary error code:" << (int)status.get_error_code()
            << ",secondary error code:" << status.get_sub_error_code() << std::endl << std::endl;;

  status = message::MessageBroker::send_message(&ct_msg_3);
  std::cout << "message: " << ct_msg_3.string() << ", "
            << "primary error code:" << (int)status.get_error_code()
            << ",secondary error code:" << status.get_sub_error_code() << std::endl << std::endl;;
  
  status = message::MessageBroker::send_message(&end_ddl);
  std::cout << "message: " << end_ddl.string() << ", "
            << "primary error code:" << (int)status.get_error_code()
            << ",secondary error code:" << status.get_sub_error_code() << std::endl << std::endl;;
}

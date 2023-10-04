/*
 * Copyright 2019-2023 Project Tsurugi.
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
 *	@file	  send_message.h
 *	@brief  Dispatch messages to ogawayama.
 */
#include "send_message.h"
#include "tsurugi.h"
#include "manager/message/ddl_message.h"
#include "manager/message/status.h"
#include "manager/message/broker.h"

#ifdef __cplusplus
extern "C"
{
#endif
#include "postgres.h"
#ifdef __cplusplus
}
#endif

using namespace ogawayama;
using namespace manager;

/**
 * @brief Send messages to ogawayama.
 * @param messages [in] message list without BeginDDL and EndDDL.
 * @return true if success.
 * @return false otherwise.
 */
bool send_message(message::Message& message) 
{
  bool ret_value = false;

  stub::Connection* connection;
  ERROR_CODE error = Tsurugi::get_connection(&connection);
  if (error != ERROR_CODE::OK) {
    ereport(NOTICE,
            (errcode(ERRCODE_INTERNAL_ERROR),
            errmsg("Tsurugi::get_connection() failed. (error: %d)",
            (int) error)));
    return ret_value;
  }

  message::BeginDDL begin_ddl{};
  message::EndDDL end_ddl{};
  
  begin_ddl.set_receiver(connection);
  end_ddl.set_receiver(connection);
  message.set_receiver(connection);

  message::Status status = message::Broker::send_message(&begin_ddl);
  if (status.get_error_code() == message::ErrorCode::FAILURE) {
    ereport(NOTICE,
            (errcode(ERRCODE_INTERNAL_ERROR),
            errmsg("Broker::send_message() failed. (msg: %s, code: %d)", 
            begin_ddl.string(), status.get_sub_error_code())));
    return ret_value;
  }

  status = message::Broker::send_message(&message);
  if (status.get_error_code() == message::ErrorCode::FAILURE) {
    ereport(NOTICE,
            (errcode(ERRCODE_INTERNAL_ERROR),
            errmsg("Broker::send_message() failed. (msg: %s, code: %d)", 
            message.string(), status.get_sub_error_code())));
    // ToDo: Add rollback process.
    message::Broker::send_message(&end_ddl);
    return ret_value;
  }

  status = message::Broker::send_message(&end_ddl);
  if (status.get_error_code() == message::ErrorCode::FAILURE) {
    ereport(NOTICE,
            (errcode(ERRCODE_INTERNAL_ERROR),
            errmsg("Broker::send_message() failed. (msg: %s, code: %d)", 
            end_ddl.string(), status.get_sub_error_code())));
    return ret_value;
  }

  ret_value = true;

  return ret_value;
}

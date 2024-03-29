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
 *	@brief  Dispatch DDL message to ogawayama.
 */
#pragma once

#include "manager/message/message.h"

/**
 * @brief Send messages to ogawayama.
 * @param messages [in] message list without BeginDDL and EndDDL.
 * @return true if success.
 * @return false otherwise.
 */
bool send_message(manager::message::Message& message);


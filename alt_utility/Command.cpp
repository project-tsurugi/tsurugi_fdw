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
 *	@file	Command.cpp
 *	@brief  the command class dipatched to ogawayama
 */

#include <string>

#ifdef __cplusplus
extern "C" {
#endif
#include "postgres.h"
#ifdef __cplusplus
}
#endif

#include "Command.h"

std::string Command::get_command_type_name()
{
    return command_type_name;
}

uint64_t Command::get_table_id()
{
    return table_id;
}

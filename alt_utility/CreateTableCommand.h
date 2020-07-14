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
 *	@file	CreateTableCommand.h
 *	@brief  the create-table command class dipatched to ogawayama
 */

#ifndef CREATETABLECOMMAND_
#define CREATETABLECOMMAND_

#include <string>

#include "Command.h"

const std::string COMMAND_TYPE_NANE_CREATE_TABLE = "CREATE TABLE";

class CreateTableCommand : public Command{
    public:
        // C'tors
        CreateTableCommand(uint64_t object_id)
            : Command(COMMAND_TYPE_NANE_CREATE_TABLE, object_id) {}
};

#endif // CREATETABLECOMMAND_

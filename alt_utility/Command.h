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
 *	@file	Command.h
 *	@brief  the command class dipatched to ogawayama
 */

#ifndef COMMAND_
#define COMMAND_

class Command {
    private:
        std::string name; //command type name ex)"CREATE TABLE"
        int table_id; // id of table meta data object
        virtual int execute() = 0; // frontend does not use. ogawayama use?

    public:
        // C'tors
        explicit Command(std::string name, int table_id) : name(name),table_id(table_id) {}
        // D'tor.
        virtual ~Command();
};

#endif // COMMAND_

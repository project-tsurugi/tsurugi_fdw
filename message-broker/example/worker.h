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
 *	@file	worker.h
 */

#ifndef WORKER_H
#define WORKER_H

#include <boost/property_tree/ptree.hpp>
#include "manager/metadata/error_code.h"

using namespace manager::metadata;
using namespace boost::property_tree;

class Worker {
public:
  ErrorCode read_table_metadata(int64_t object_id);

private:
  void print_error(ErrorCode error, uint64_t line);
  ErrorCode display_table_metadata_object(const ptree& table);
};

#endif // WORKER_H

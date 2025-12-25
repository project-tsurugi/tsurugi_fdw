/*
 * Copyright 2025 Project Tsurugi.
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
 */
#include <string>
#include <memory>
#include <boost/format.hpp>
#include "ogawayama/stub/api.h"
#include "ogawayama/stub/error_code.h"
#include "tg_common/tsurugi.h"

#ifdef __cplusplus
extern "C" {
#endif
#include "postgres.h"

using namespace ogawayama;

/** ===========================================================================
 *  
 *  
 * 
 */
const char* tg_get_error_message() {
    return Tsurugi::tsurugi().get_error_message();
}

bool tg_do_connect(Oid server_oid) {
    auto error = Tsurugi::tsurugi().init(server_oid);
    return (error == ERROR_CODE::OK) ? true : false;
}

bool tg_do_begin(Oid server_oid) {
    auto error = Tsurugi::tsurugi().start_transaction(server_oid);
    return (error == ERROR_CODE::OK) ? true : false;
}

bool tg_do_commit() {
    auto error = Tsurugi::tsurugi().commit();
    return (error == ERROR_CODE::OK) ? true : false;
}

bool tg_do_rollback() {
    auto error = Tsurugi::tsurugi().rollback();
    return (error == ERROR_CODE::OK) ? true : false;
}

#ifdef __cplusplus
}   /* extern "C" */
#endif

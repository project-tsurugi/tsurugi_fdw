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
 *	@file	tsurugi_api.h
 */
#ifndef TSURUGI_API_H
#define TSURUGI_API_H

#ifdef __cplusplus
extern "C" {
#endif
#include "postgres.h"

const char* tg_get_error_message();
bool tg_do_connect(Oid server_oid);
bool tg_do_begin(Oid server_oid);
bool tg_do_commit();
bool tg_do_rollback();

#ifdef __cplusplus
} /* extern "C" */
#endif

#endif /* TSURUGI_API_H */

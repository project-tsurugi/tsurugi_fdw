/*
 * Copyright 2023-2025 Project Tsurugi.
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
 *	@file	tsurugi.hpp
 */
#pragma once

#include <ogawayama/stub/api.h>
#include <optional>

#ifdef __cplusplus
extern "C" {
#endif
#include "postgres.h"

#include "nodes/pg_list.h"
#ifdef __cplusplus
}
#endif

using TgColumnType = ogawayama::stub::Metadata::ColumnType::Type;
using TgValue = ogawayama::stub::value_type;

std::optional<std::string_view> tg_convert_type_tg_to_pg(
		jogasaki::proto::sql::common::AtomType tg_type);

std::optional<TgColumnType> tg_convert_type_pg_to_tg(const Oid pg_type);

std::optional<std::pair<bool, Datum>> tg_convert_value_tg_to_pg(
		ResultSetPtr result_set, const Oid pgtype);

std::optional<TgValue> tg_convert_value_pg_to_tg(
		const Oid pg_type, Datum pg_value);

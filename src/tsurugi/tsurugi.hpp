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

namespace tsurugi {
// datatype converter
std::optional<std::string_view> convert_type_to_pg(
	jogasaki::proto::sql::common::AtomType tg_type);

ogawayama::stub::value_type convert_type_to_tg(const Oid pg_type, Datum value);

std::pair<bool, Datum> convert_type_to_pg(ResultSetPtr result_set, const Oid pgtype);

ogawayama::stub::Metadata::ColumnType::Type get_tg_column_type(const Oid pg_type);

bool get_tg_column_type(const Oid pg_type,
						ogawayama::stub::Metadata::ColumnType::Type& tg_type);

ogawayama::stub::timestamptz_type convert_timestamptz_to_tg(Datum value);

takatori::decimal::triple convert_decimal_to_tg(Datum value);
}  // namespace tsurugi
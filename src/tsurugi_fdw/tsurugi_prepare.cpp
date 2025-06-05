/*
 * Copyright 2023 Project Tsurugi.
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
 * Portions Copyright (c) 1996-2023, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, The Regents of the University of California
 *
 *	@file	tsurugi_prepare.cpp
 *	@brief 	Dispatch the prepare statement to ogawayama.
 */

#include <boost/multiprecision/cpp_int.hpp>
#include <map>

#include "ogawayama/stub/api.h"
#include "takatori/value/time_point.h"
#include "tsurugi.h"
#include "tsurugi_utils.h"

#ifdef __cplusplus
extern "C" {
#endif
#include "postgres.h"

#include "catalog/pg_type.h"
#include "nodes/params.h"
#include "nodes/execnodes.h"
#include "utils/builtins.h"
#include "utils/date.h"
#include "utils/datetime.h"
#include "utils/numeric.h"
#include "utils/timestamp.h"

extern void getTypeOutputInfo(Oid type, Oid *typOutput, bool *typIsVarlena);
#ifdef __cplusplus
}
#endif

#include "tg_numeric.h"
#include "tsurugi_prepare.h"

using namespace ogawayama;

static constexpr const char* const PREPARE_NAME = "tsurugi_prep_";
static constexpr const char* const PREPARE_PARAM_NAME = "param_";
static constexpr const char* const PREPARE_PARAM_NAME_SQL = ":param_";
static constexpr const char* const COMMA_CHAR = ",";
static constexpr const char* const SPACE_CHAR = " ";
static constexpr const char* const RIGHT_PARENTHESIS_CHAR = ")";

// Name of the stored Prepared Statement.
std::map<std::string, std::string> stored_prepare_name;
int tsurugi_prep_number = 0;

// Data Required for Prepared SQL Execution.
extern PreparedStatementPtr prepared_statement;
// Parameter Settings Required for Prepared SQL Execution.
extern stub::parameters_type parameters;

// Data Required for stored Prepared SQL Execution.
extern std::map<std::string, PreparedStatementPtr> stored_prepare_statment;

/**
 *  @brief Begin processing of PreparedStatement via JDBC.
 *  @param [in] working state for an Executor invocation
 */
void
begin_prepare_processing(const EState* estate)
{
	ParamListInfo params = estate->es_param_list_info;

	elog(DEBUG2, "tsurugi_fdw : %s", __func__);

	return;

	if (params == NULL) {
		// If there is no parameter information, do nothing.
		return;
	}

	if (parameters.size() != 0) {
		// If there is an EXECUTE command, do nothing.
		return;
	}

	std::string sql = estate->es_sourceText;
	// Determine Tsurugi::prepare execution from stored prepared statement name.
	std::map<std::string, std::string>::iterator itr = stored_prepare_name.find(sql);
	if (itr == stored_prepare_name.end()) {
		// Generating Prepared Statement Name.
		std::string prepare_name = PREPARE_NAME + std::to_string(tsurugi_prep_number++);
		stored_prepare_name[sql] = prepare_name;

		// Generating (converting parameters) SQL text for Tsurugi Prepared Statements.
		for (int i = 0; i < params->numParams; i++) {
			std::string serch_param = "$" + std::to_string(i+1);
			std::size_t serch_param_len = serch_param.length();
			std::size_t param_pos = sql.find(serch_param);
			if (param_pos == std::string::npos) {
				elog(ERROR, "Unrecognized parameter position in SQL text.");
				return;
			}
			// Search for PostgreSQL-specific a type casts(expression::type).
			std::size_t cast_exists = sql.find(serch_param + "::", param_pos);
			if (cast_exists != std::string::npos) {
				std::size_t sql_length = sql.length();
				// Calculate length including type cast(expression::type+comma).
				std::size_t cast_param_len = sql_length;
				std::size_t comma_char_pos = sql.find(COMMA_CHAR, param_pos);
				if (comma_char_pos != std::string::npos) {
					cast_param_len = std::min(comma_char_pos, cast_param_len);
				}
				// Calculate length including type cast(expression::type+space).
				std::size_t space_char_pos = sql.find(SPACE_CHAR, param_pos);
				if (space_char_pos != std::string::npos) {
					cast_param_len = std::min(space_char_pos, cast_param_len);
				}
				// Calculate length including type cast(expression::type+right parenthesis).
				std::size_t right_parenthesis_char_pos = sql.find(RIGHT_PARENTHESIS_CHAR, param_pos);
				if (right_parenthesis_char_pos != std::string::npos) {
					cast_param_len = std::min(right_parenthesis_char_pos, cast_param_len);
				}
				serch_param_len = cast_param_len - param_pos;
			}

			// replace prepare string.
			// ex) "$1" -> ":param_0", "$2::int4" -> ":param_1"
			std::string param_name = PREPARE_PARAM_NAME_SQL + std::to_string(i);
			sql = sql.replace(param_pos, serch_param_len, param_name);
		}

		// Generating placeholders for Tsurugi Prepared Statements.
		stub::placeholders_type placeholders{};
		for (int i = 0; i < params->numParams; i++) {
			std::string param_name = PREPARE_PARAM_NAME + std::to_string(i);
			ParamExternData param = params->params[i];
			elog(LOG, "tsurugi_fdw : preapre statement parameter: %s, pgtype_oid: %d", 
				param_name.data(), param.ptype);
			switch (param.ptype)
			{
				case INT2OID:
					placeholders.emplace_back(param_name,
									stub::Metadata::ColumnType::Type::INT16);
					break;
				case INT4OID:
					placeholders.emplace_back(param_name,
									stub::Metadata::ColumnType::Type::INT32);
					break;
				case INT8OID:
					placeholders.emplace_back(param_name,
									stub::Metadata::ColumnType::Type::INT64);
					break;
				case FLOAT4OID:
					placeholders.emplace_back(param_name,
									stub::Metadata::ColumnType::Type::FLOAT32);
					break;
				case FLOAT8OID:
					placeholders.emplace_back(param_name,
									stub::Metadata::ColumnType::Type::FLOAT64);
					break;
				case BPCHAROID:
				case VARCHAROID:
				case TEXTOID:
					placeholders.emplace_back(param_name,
									stub::Metadata::ColumnType::Type::TEXT);
					break;
				case DATEOID:
					placeholders.emplace_back(param_name,
									stub::Metadata::ColumnType::Type::DATE);
					break;
				case TIMEOID:
					placeholders.emplace_back(param_name,
									stub::Metadata::ColumnType::Type::TIME);
					break;
				case TIMESTAMPOID:
					placeholders.emplace_back(param_name,
									stub::Metadata::ColumnType::Type::TIMESTAMP);
					break;
				case TIMETZOID:
					placeholders.emplace_back(param_name,
									stub::Metadata::ColumnType::Type::TIMETZ);
					break;
				case TIMESTAMPTZOID:
					placeholders.emplace_back(param_name,
									stub::Metadata::ColumnType::Type::TIMESTAMPTZ);
					break;
				case NUMERICOID:
					placeholders.emplace_back(param_name,
									stub::Metadata::ColumnType::Type::DECIMAL);
					break;
				default:
					elog(ERROR, "unrecognized type oid: %d", (int) param.ptype);
					return;
			}
		}

		sql = make_tsurugi_query(sql);
		ERROR_CODE error = Tsurugi::prepare(sql, placeholders, prepared_statement);
		if (error != ERROR_CODE::OK)
		{
			elog(ERROR, "Failed to prepare SQL statement to Tsurugi. (%d)\n\tsql:%s\n%s", 
                (int) error, sql.c_str(), Tsurugi::get_error_message(error).c_str());
			return;
		}
	} else {
		// Restore the Data Required for Prepared SQL Execution.
		std::string prepare_name = stored_prepare_name[sql];
		prepared_statement = std::move(stored_prepare_statment.at(prepare_name));
	}

	// Generating parameters for Tsurugi Prepared Statements.
	for (int i = 0; i < params->numParams; i++) {
		std::string param_name = PREPARE_PARAM_NAME + std::to_string(i);
		ParamExternData param = params->params[i];
		switch (param.ptype)
		{
			case INT2OID:
				parameters.emplace_back(param_name,
								static_cast<std::int16_t>(DatumGetInt16(param.value)));
				break;
			case INT4OID:
				parameters.emplace_back(param_name,
								static_cast<std::int32_t>(DatumGetInt32(param.value)));
				break;
			case INT8OID:
				parameters.emplace_back(param_name,
								static_cast<std::int64_t>(DatumGetInt64(param.value)));
				break;
			case FLOAT4OID:
				parameters.emplace_back(param_name,
								static_cast<float>(DatumGetFloat4(param.value)));
				break;
			case FLOAT8OID:
				parameters.emplace_back(param_name,
								static_cast<double>(DatumGetFloat8(param.value)));
				break;
			case BPCHAROID:
			case VARCHAROID:
			case TEXTOID:
				Oid typoutput;
				bool typisvarlena;
				char* pstring;
				getTypeOutputInfo(param.ptype, &typoutput, &typisvarlena);
				pstring = OidOutputFunctionCall(typoutput, param.value);
				parameters.emplace_back(param_name, pstring);
				pfree(pstring);
				break;
			case DATEOID:
				{
					DateADT date = DatumGetDateADT(param.value);
					struct pg_tm tm;
					j2date(date + POSTGRES_EPOCH_JDATE,
							&(tm.tm_year), &(tm.tm_mon), &(tm.tm_mday));
					auto tg_date = takatori::datetime::date(
											static_cast<std::int32_t>(tm.tm_year),
											static_cast<std::int32_t>(tm.tm_mon),
											static_cast<std::int32_t>(tm.tm_mday));
					parameters.emplace_back(param_name, tg_date);
				}
				break;
			case TIMEOID:
				{
					TimeADT time = DatumGetTimeADT(param.value);
					struct pg_tm tt, *tm = &tt;
					fsec_t fsec;
					time2tm(time, tm, &fsec);
					auto tg_time_of_day = takatori::datetime::time_of_day(
											static_cast<std::int64_t>(tm->tm_hour),
											static_cast<std::int64_t>(tm->tm_min),
											static_cast<std::int64_t>(tm->tm_sec),
											std::chrono::nanoseconds(fsec*1000));
					parameters.emplace_back(param_name, tg_time_of_day);
				}
				break;
			case TIMETZOID:
				{
					TimeTzADT* timetz = DatumGetTimeTzADTP(param.value);
					struct pg_tm tt, *tm = &tt;
					fsec_t fsec;
					time2tm(timetz->time, tm, &fsec);
					auto tg_time_of_day = takatori::datetime::time_of_day(
											static_cast<std::int64_t>(tm->tm_hour),
											static_cast<std::int64_t>(tm->tm_min),
											static_cast<std::int64_t>(tm->tm_sec),
											std::chrono::nanoseconds(fsec*1000));
					std::int32_t tg_time_zone = 0;
					if (timetz->zone != 0) {
						tg_time_zone = -timetz->zone / SECS_PER_MINUTE;
					}
					auto tg_time_of_day_with_time_zone =
						std::pair<takatori::datetime::time_of_day, std::int32_t>{tg_time_of_day, tg_time_zone};

					elog(DEBUG5, "time_of_day = %d:%d:%d.%d, time_zone = %d",
									tm->tm_hour, tm->tm_min, tm->tm_sec, fsec, tg_time_zone);

					parameters.emplace_back(param_name, tg_time_of_day_with_time_zone);
				}
				break;
			case TIMESTAMPTZOID:
				{
					TimestampTz timestamptz = DatumGetTimestampTz(param.value);
					struct pg_tm tt, *tm = &tt;
					fsec_t fsec;
					int tz;
					if (timestamp2tm(timestamptz, &tz, tm, &fsec, NULL, NULL) != 0)
						ereport(ERROR,
								(errcode(ERRCODE_DATETIME_VALUE_OUT_OF_RANGE),
								 errmsg("timestamp out of range")));
					auto tg_date = takatori::datetime::date(
											static_cast<std::int32_t>(tm->tm_year),
											static_cast<std::int32_t>(tm->tm_mon),
											static_cast<std::int32_t>(tm->tm_mday));
					auto tg_time_of_day = takatori::datetime::time_of_day(
											static_cast<std::int64_t>(tm->tm_hour),
											static_cast<std::int64_t>(tm->tm_min),
											static_cast<std::int64_t>(tm->tm_sec),
											std::chrono::nanoseconds(fsec*1000));
					auto tg_time_point = takatori::datetime::time_point(
											tg_date,
											tg_time_of_day);
					std::int32_t tg_time_zone = 0;
					if (tz != 0) {
						tg_time_zone = -tz / SECS_PER_MINUTE;
					}
					auto tg_time_point_with_time_zone =
						std::pair<takatori::datetime::time_point, std::int32_t>{tg_time_point, tg_time_zone};

					elog(DEBUG5, "date = %d/%d/%d, time_of_day = %d:%d:%d.%d, time_zone = %d",
									tm->tm_year, tm->tm_mon, tm->tm_mday,
									tm->tm_hour, tm->tm_min, tm->tm_sec, fsec, tg_time_zone);

					parameters.emplace_back(param_name, tg_time_point_with_time_zone);
				}
				break;
			case TIMESTAMPOID:
				{
					Timestamp timestamp = DatumGetTimestamp(param.value);
					struct pg_tm tt, *tm = &tt;
					fsec_t fsec;
					if (timestamp2tm(timestamp, NULL, tm, &fsec, NULL, NULL) != 0) {
						elog(ERROR, "timestamp out of range");
					}
					auto tg_date = takatori::datetime::date(
											static_cast<std::int32_t>(tm->tm_year),
											static_cast<std::int32_t>(tm->tm_mon),
											static_cast<std::int32_t>(tm->tm_mday));
					auto tg_time_of_day = takatori::datetime::time_of_day(
											static_cast<std::int64_t>(tm->tm_hour),
											static_cast<std::int64_t>(tm->tm_min),
											static_cast<std::int64_t>(tm->tm_sec),
											std::chrono::nanoseconds(fsec*1000));
					auto tg_time_point = takatori::datetime::time_point(
											tg_date,
											tg_time_of_day);
					parameters.emplace_back(param_name, tg_time_point);
				}
				break;
			case NUMERICOID:
				{
					// Convert PostgreSQL NUMERIC type to string.
					std::string pg_numeric = DatumGetCString(DirectFunctionCall1(numeric_out, param.value));
					elog(DEBUG5, "orignal: pg_numeric = %s", pg_numeric.c_str());
					auto pos_period = pg_numeric.find(".");
					if (pos_period != std::string::npos) {
						pg_numeric.erase(pos_period, 1);
					}
					auto pos_negative = pg_numeric.find("-");
					if (pos_negative != std::string::npos) {
						pg_numeric.erase(pos_negative, 1);
					}
					while (pg_numeric.at(0) == '0' && pg_numeric.size() > 1) {
						// The first zero is deleted. Because identified as an octal number.
						pg_numeric.erase(0, 1);
					}
					elog(DEBUG5, "after: pg_numeric = %s", pg_numeric.c_str());

					// Get display scale and sign from NumericData.
					Numeric numeric_data = DatumGetNumeric(param.value);
					bool numeric_is_short = numeric_data->choice.n_header & 0x8000;
					int numeric_dscale;
					int numeric_sign;
					if (numeric_is_short) {
						numeric_dscale = (numeric_data->choice.n_short.n_header & NUMERIC_SHORT_DSCALE_MASK) >>
										NUMERIC_SHORT_DSCALE_SHIFT;
						if (numeric_data->choice.n_short.n_header & NUMERIC_SHORT_SIGN_MASK)
							numeric_sign = NUMERIC_NEG;
						else
							numeric_sign = NUMERIC_POS;
					} else {
						numeric_dscale = numeric_data->choice.n_long.n_sign_dscale & NUMERIC_DSCALE_MASK;
						numeric_sign = numeric_data->choice.n_header & NUMERIC_SIGN_MASK;
					}

					// Generate parameters for takatori::decimal::triple.
					std::int64_t sign = 0;
					switch (numeric_sign)
					{
						case NUMERIC_POS:
							sign = 1;
							break;
						case NUMERIC_NEG:
							sign = -1;
							break;
						case NUMERIC_NAN:
							sign = 0;
							break;
						default:
							elog(ERROR, "unrecognized numeric sign = 0x%x", numeric_sign);
							break;
					}

					boost::multiprecision::cpp_int mp_coefficient(pg_numeric);
					if (mp_coefficient > std::numeric_limits<boost::multiprecision::uint128_t>::max()) {
						elog(ERROR, "numeric coefficient field overflow");
					}
					std::uint64_t coefficient_high = static_cast<std::uint64_t>(mp_coefficient >> 64);
					std::uint64_t coefficient_low  = static_cast<std::uint64_t>(mp_coefficient);

					std::int32_t exponent = -numeric_dscale;

					elog(DEBUG5, "triple(%ld, %lu(0x%lX), %lu(0x%lX), %d)",
											sign, coefficient_high, coefficient_high, 
											coefficient_low, coefficient_low, exponent);

					auto tg_decimal = takatori::decimal::triple{sign, coefficient_high, coefficient_low, exponent};
					parameters.emplace_back(param_name, tg_decimal);
				}
				break;
			default:
				elog(ERROR, "unrecognized type oid: %d", (int) param.ptype);
				return;
		}
	}
}

/**
 *  @brief End processing of PreparedStatement via JDBC.
 *  @param [in] working state for an Executor invocation
 */
void
end_prepare_processing(const EState* estate)
{
	ParamListInfo params = estate->es_param_list_info;

	elog(DEBUG2, "tsurugi_fdw : %s", __func__);

	return;

	if (params == NULL) {
		// If there is no parameter information, do nothing.
		return;
	}

	std::string sql = estate->es_sourceText;

	std::map<std::string, std::string>::iterator itr = stored_prepare_name.find(sql);
	if (itr != stored_prepare_name.end()) {
		// Store the Data Required for Prepared SQL Execution.
		std::string prepare_name = stored_prepare_name[sql];
		stored_prepare_statment[prepare_name] = std::move(prepared_statement);
		parameters = {};
	} 
}

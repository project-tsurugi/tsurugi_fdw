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
 *	@file	tsurugi.cpp
 */
#include <string>
#include <string_view>

#include <ogawayama/stub/api.h>
#include <ogawayama/stub/error_code.h>
#include <boost/multiprecision/cpp_int.hpp>

#include "tsurugi.hpp"
#include "tg_numeric.hpp"

#ifdef __cplusplus
extern "C" {
#endif
#include "postgres.h"

#include "access/htup_details.h"
#include "catalog/pg_type.h"
#include "commands/defrem.h"
#include "foreign/foreign.h"
#include "miscadmin.h"
#include "utils/builtins.h"
#include "utils/date.h"
#include "utils/datetime.h"
#include "utils/lsyscache.h"
#include "utils/numeric.h"
#include "utils/syscache.h"
#include "utils/timestamp.h"
#ifdef __cplusplus
}
#endif

using namespace ogawayama;
namespace tg_metadata = jogasaki::proto::sql::common;

extern bool GetTransactionOption(boost::property_tree::ptree&);

/* -------------------------------------------------------------------------
 * Tsurugi functions.
 * ------------------------------------------------------------------------- 
 */
namespace {
#if 0
/**
 *  @brief 	Convert structure of timestamptz value from PostgreSQL to
 * tsurugidb.
 *  @param 	(value) PostgreSQL datum.
 *  @return	timestamptz type of tsurugidb.
 */
std::optional<ogawayama::stub::timestamptz_type> convert_timestamptz_to_tg(Datum value) {
	TimestampTz timestamptz = DatumGetTimestampTz(value);
	struct pg_tm tt, *tm = &tt;
	fsec_t fsec;
	int tz;
	if (timestamp2tm(timestamptz, &tz, tm, &fsec, NULL, NULL) != 0) {
		elog(LOG, "tsurugi_fdw: timestamp out of range");
		return std::nullopt;
	}
	auto tg_date =
			takatori::datetime::date(static_cast<std::int32_t>(tm->tm_year),
					static_cast<std::int32_t>(tm->tm_mon),
					static_cast<std::int32_t>(tm->tm_mday));
	auto tg_time_of_day = takatori::datetime::time_of_day(
			static_cast<std::int64_t>(tm->tm_hour),
			static_cast<std::int64_t>(tm->tm_min),
			static_cast<std::int64_t>(tm->tm_sec),
			std::chrono::nanoseconds(fsec * 1000));
	auto tg_time_point =
			takatori::datetime::time_point(tg_date, tg_time_of_day);
	std::int32_t tg_time_zone = 0;
	if (tz != 0) {
		tg_time_zone = -tz / SECS_PER_MINUTE;
	}
	auto tg_time_point_with_time_zone =
			std::pair<takatori::datetime::time_point, std::int32_t>{
					tg_time_point, tg_time_zone};
	elog(DEBUG5, "date = %d/%d/%d, time_of_day = %d:%d:%d.%d, time_zone = %d",
			tm->tm_year, tm->tm_mon, tm->tm_mday, tm->tm_hour, tm->tm_min,
			tm->tm_sec, fsec, tg_time_zone);

	return tg_time_point_with_time_zone;
}
#endif
#if 0
/**
 *  @brief 	Convert structure of decimal value from PostgreSQL to tsurugidb.
 *  @param 	(value) PostgreSQL datum.
 *  @return	decimal value of tsurugidb.
 */
std::optional<takatori::decimal::triple> convert_decimal_to_tg(Datum value) {
	// Convert PostgreSQL NUMERIC type to string.
	std::string pg_numeric =
			DatumGetCString(DirectFunctionCall1(numeric_out, value));
	elog(DEBUG5, "original: pg_numeric = %s", pg_numeric.c_str());
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
	Numeric numeric_data = DatumGetNumeric(value);
	bool numeric_is_short = numeric_data->choice.n_header & 0x8000;
	int numeric_dscale;
	int numeric_sign;
	if (numeric_is_short) {
		numeric_dscale = (numeric_data->choice.n_short.n_header &
								 NUMERIC_SHORT_DSCALE_MASK) >>
						 NUMERIC_SHORT_DSCALE_SHIFT;
		if (numeric_data->choice.n_short.n_header & NUMERIC_SHORT_SIGN_MASK)
			numeric_sign = NUMERIC_NEG;
		else
			numeric_sign = NUMERIC_POS;
	} else {
		numeric_dscale =
				numeric_data->choice.n_long.n_sign_dscale & NUMERIC_DSCALE_MASK;
		numeric_sign = numeric_data->choice.n_header & NUMERIC_SIGN_MASK;
	}

	// Generate parameters for takatori::decimal::triple.
	std::int64_t sign = 0;
	switch (numeric_sign) {
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
			elog(LOG, "unrecognized numeric sign = 0x%x", numeric_sign);
			return std::nullopt;
	}

	boost::multiprecision::cpp_int mp_coefficient(pg_numeric);
	if (mp_coefficient >
			std::numeric_limits<boost::multiprecision::uint128_t>::max()) {
		elog(LOG, "numeric coefficient field overflow");
		return std::nullopt;
	}
	std::uint64_t coefficient_high =
			static_cast<std::uint64_t>(mp_coefficient >> 64);
	std::uint64_t coefficient_low = static_cast<std::uint64_t>(mp_coefficient);

	std::int32_t exponent = -numeric_dscale;

	elog(DEBUG5, "triple(%ld, %lu(0x%lX), %lu(0x%lX), %d)", sign,
			coefficient_high, coefficient_high, coefficient_low,
			coefficient_low, exponent);

	return takatori::decimal::triple{
			sign, coefficient_high, coefficient_low, exponent};
}
#endif
}  // namespace tsurugi::detail

/**
 * @brief convert Tsurugi data types to PostgreSQL data types.
 * @param tg_type tsurugi data type (AtomType)
 * @return (std::nullopt) failure.
 * 		   (others) postgreSQL data type.
 */
std::optional<std::string_view> tg_convert_type_tg_to_pg(
		jogasaki::proto::sql::common::AtomType tg_type) {
	elog(DEBUG5, "tsurugi_fdw: %s", __func__);

	static const std::unordered_map<tg_metadata::AtomType, std::string>
			type_mapping = {
					{tg_metadata::AtomType::INT4, "integer"},
					{tg_metadata::AtomType::INT8, "bigint"},
					{tg_metadata::AtomType::FLOAT4, "real"},
					{tg_metadata::AtomType::FLOAT8, "double precision"},
					{tg_metadata::AtomType::DECIMAL, "numeric"},
					{tg_metadata::AtomType::CHARACTER, "text"},
					{tg_metadata::AtomType::DATE, "date"},
					{tg_metadata::AtomType::OCTET, "bytea"},
					{tg_metadata::AtomType::TIME_OF_DAY, "time"},
					{tg_metadata::AtomType::TIME_POINT, "timestamp"},
					{tg_metadata::AtomType::TIME_OF_DAY_WITH_TIME_ZONE,
							"time with time zone"},
					{tg_metadata::AtomType::TIME_POINT_WITH_TIME_ZONE,
							"timestamp with time zone"},
			};

	auto pg_type = type_mapping.find(tg_type);
	if (pg_type == type_mapping.end()) {
		// pg type not found.
		return std::nullopt;
	}

	return pg_type->second;
}

/**
 *  @brief 	Convert PostgreSQL data type to Tsurugi data type.
 *  @param 	(pg_type) oid of PostgreSQL data type.
 * 			(tg_type) data type ID of Tsurugi.
 *  @return	(true) success.
 * 			(false) failure.
 */
std::optional<TgColumnType> tg_convert_type_pg_to_tg(const Oid pg_type) {
	elog(DEBUG5, "tsurugi_fdw: %s (pg_type: %d)", __func__, (int) pg_type);

	TgColumnType tg_type;
	tg_type = stub::Metadata::ColumnType::Type::NULL_VALUE;
	switch (pg_type) {
		case INT2OID:
			tg_type = stub::Metadata::ColumnType::Type::INT16;
			break;
		case INT4OID:
			tg_type = stub::Metadata::ColumnType::Type::INT32;
			break;
		case INT8OID:
			tg_type = stub::Metadata::ColumnType::Type::INT64;
			break;
		case FLOAT4OID:
			tg_type = stub::Metadata::ColumnType::Type::FLOAT32;
			break;
		case FLOAT8OID:
			tg_type = stub::Metadata::ColumnType::Type::FLOAT64;
			break;
		case BPCHAROID:
		case VARCHAROID:
		case TEXTOID:
			tg_type = stub::Metadata::ColumnType::Type::TEXT;
			break;
		case DATEOID:
			tg_type = stub::Metadata::ColumnType::Type::DATE;
			break;
		case TIMEOID:
			tg_type = stub::Metadata::ColumnType::Type::TIME;
			break;
		case TIMESTAMPOID:
			tg_type = stub::Metadata::ColumnType::Type::TIMESTAMP;
			break;
		case TIMETZOID:
			tg_type = stub::Metadata::ColumnType::Type::TIMETZ;
			break;
		case TIMESTAMPTZOID:
			tg_type = stub::Metadata::ColumnType::Type::TIMESTAMPTZ;
			break;
		case NUMERICOID:
			tg_type = stub::Metadata::ColumnType::Type::DECIMAL;
			break;
		case BYTEAOID:
			tg_type = stub::Metadata::ColumnType::Type::OCTET;
			break;
		default:
			elog(LOG, "tsurugi_fdw: Unrecognized type oid: %d", (int) pg_type);
			return std::nullopt;
	}

	return tg_type;
}

/**
 *  @brief 	Convert Tsurugi value to PostgreSQL value.
 *  @param 	(resultset)	Pointer to ResultSet object of Tsurugi.
 * 			(pgtype) OID of PostgreSQL data type.
 * 			(is_null) NULL value falg.
 * 			(pg_value) PostgreSQL value.
 *  @return	(true) success.
 * 			(false) failure.
 */
std::optional<std::pair<bool, Datum>> tg_convert_value_tg_to_pg(
		ResultSetPtr result_set, const Oid pgtype) {
	bool is_null = true;
	Datum pg_value = (Datum) 0;

	elog(DEBUG3, "tsurugi_fdw: %s", __func__);

	switch (pgtype) {
		case INT2OID: {
			std::int16_t value;
			elog(DEBUG5, "tsurugi_fdw: %s : pgtype is INT2OID.", __func__);
			if (result_set->next_column(value) == ERROR_CODE::OK) {
				elog(DEBUG5, "tsurugi_fdw: %s : value = %d", __func__, value);
				is_null = false;
				pg_value = Int16GetDatum(value);
			}
		} break;

		case INT4OID: {
			std::int32_t value = 0;
			elog(DEBUG5, "tsurugi_fdw: %s : pgtype is INT4OID.", __func__);
			if (result_set->next_column(value) == ERROR_CODE::OK) {
				elog(DEBUG5, "tsurugi_fdw: %s : value = %d", __func__, value);
				is_null = false;
				pg_value = Int32GetDatum(value);
			}
		} break;

		case INT8OID: {
			std::int64_t value;
			elog(DEBUG5, "tsurugi_fdw: %s : pgtype is INT8OID.", __func__);
			if (result_set->next_column(value) == ERROR_CODE::OK) {
				elog(DEBUG5, "tsurugi_fdw: %s : value = %ld", __func__, value);
				is_null = false;
				pg_value = Int64GetDatum(value);
			}
		} break;

		case FLOAT4OID: {
			float4 value;
			elog(DEBUG5, "tsurugi_fdw: %s : pgtype is FLOAT4OID.", __func__);
			if (result_set->next_column(value) == ERROR_CODE::OK) {
				is_null = false;
				pg_value = Float4GetDatum(value);
			}
		} break;

		case FLOAT8OID: {
			float8 value;
			elog(DEBUG5, "tsurugi_fdw: %s : pgtype is FLOAT8OID.", __func__);
			if (result_set->next_column(value) == ERROR_CODE::OK) {
				is_null = false;
				pg_value = Float8GetDatum(value);
			}
		} break;

		case BPCHAROID:
		case VARCHAROID:
		case TEXTOID: {
			elog(DEBUG5,
					"tsurugi_fdw: %s : pgtype is "
					"BPCHAROID/VARCHAROID/TEXTOID.",
					__func__);
			std::string value;
			Datum value_datum;
			HeapTuple heap_tuple;
			regproc typinput;
			int typemod;

			heap_tuple = SearchSysCache1(TYPEOID, ObjectIdGetDatum(pgtype));
			if (!HeapTupleIsValid(heap_tuple)) {
				elog(LOG, "tsurugi_fdw: cache lookup failed for type %u",
						pgtype);
				return std::nullopt;
			}
			typinput = ((Form_pg_type) GETSTRUCT(heap_tuple))->typinput;
			typemod = ((Form_pg_type) GETSTRUCT(heap_tuple))->typtypmod;
			ReleaseSysCache(heap_tuple);

			ERROR_CODE result = result_set->next_column(value);
			if (result == ERROR_CODE::OK) {
				value_datum = CStringGetDatum(value.c_str());
				if (value_datum == (Datum) nullptr) {
					break;
				}
				is_null = false;
				pg_value = (Datum) OidFunctionCall3(typinput, value_datum,
						ObjectIdGetDatum(InvalidOid), Int32GetDatum(typemod));
			}
		} break;

		case DATEOID: {
			stub::date_type value;
			elog(DEBUG5, "tsurugi_fdw: %s : pgtype is DATEOID.", __func__);
			if (result_set->next_column(value) == ERROR_CODE::OK) {
				DateADT date;
				date = value.days_since_epoch();
				date = date - (POSTGRES_EPOCH_JDATE - UNIX_EPOCH_JDATE);
				pg_value = DateADTGetDatum(date);
				is_null = false;
			}
			break;
		}

		case TIMEOID: {
			stub::time_type value;
			elog(DEBUG5, "tsurugi_fdw: %s : pgtype is TIMEOID.", __func__);
			if (result_set->next_column(value) == ERROR_CODE::OK) {
				TimeADT time;
				auto subsecond = value.subsecond().count();
				time = (value.hour() * MINS_PER_HOUR) + value.minute();
				time = (time * SECS_PER_MINUTE) + value.second();
				time = time * USECS_PER_SEC;
				if (subsecond != 0) {
					subsecond = round(subsecond / 1000.0);
					time = time + subsecond;
				}
				pg_value = TimeADTGetDatum(time);
				is_null = false;
			}
			break;
		}

		case TIMETZOID: {
			stub::timetz_type value;
			elog(DEBUG5, "tsurugi_fdw: %s : pgtype is TIMETZOID.", __func__);
			if (result_set->next_column(value) == ERROR_CODE::OK) {
				TimeTzADT timetz;
				auto subsecond = value.first.subsecond().count();
				timetz.time = (value.first.hour() * MINS_PER_HOUR) +
							  value.first.minute();
				timetz.time =
						(timetz.time * SECS_PER_MINUTE) + value.first.second();
				timetz.time = timetz.time * USECS_PER_SEC;
				if (subsecond != 0) {
					subsecond = round(subsecond / 1000.0);
					timetz.time = timetz.time + subsecond;
				}
				timetz.zone = -value.second * SECS_PER_MINUTE;

				elog(DEBUG5, "time_of_day = %d:%d:%d.%d, time_zone = %d",
						value.first.hour(), value.first.minute(),
						value.first.second(), subsecond, value.second);

				pg_value = TimeTzADTPGetDatum(&timetz);
				is_null = false;
			}
			break;
		}

		case TIMESTAMPTZOID: {
			stub::timestamptz_type value;
			elog(DEBUG5, "tsurugi_fdw: %s : pgtype is TIMESTAMPTZOID.",
					__func__);
			if (result_set->next_column(value) == ERROR_CODE::OK) {
				Timestamp timestamp;
				auto subsecond = value.first.subsecond().count();
				timestamp = value.first.seconds_since_epoch().count() -
							((POSTGRES_EPOCH_JDATE - UNIX_EPOCH_JDATE) *
									SECS_PER_DAY);
				timestamp = timestamp * USECS_PER_SEC;
				if (subsecond != 0) {
					subsecond = round(subsecond / 1000.0);
					timestamp = timestamp + subsecond;
				}
				auto time_zone = value.second * SECS_PER_MINUTE;
				timestamp = timestamp - (time_zone * USECS_PER_SEC);

				elog(DEBUG5,
						"seconds_since_epoch = %ld, subsecond = %d, "
						"time_zone "
						"= %d",
						value.first.seconds_since_epoch().count(),
						value.first.subsecond().count(), value.second);

				pg_value = TimestampTzGetDatum(timestamp);
				is_null = false;
			}
			break;
		}

		case TIMESTAMPOID: {
			stub::timestamp_type value;
			elog(DEBUG5, "tsurugi_fdw: %s : pgtype is TIMESTAMPOID.", __func__);
			if (result_set->next_column(value) == ERROR_CODE::OK) {
				Timestamp timestamp;
				auto subsecond = value.subsecond().count();
				timestamp = value.seconds_since_epoch().count() -
							((POSTGRES_EPOCH_JDATE - UNIX_EPOCH_JDATE) *
									SECS_PER_DAY);
				timestamp = timestamp * USECS_PER_SEC;
				if (subsecond != 0) {
					subsecond = round(subsecond / 1000.0);
					timestamp = timestamp + subsecond;
				}
				pg_value = TimestampGetDatum(timestamp);
				is_null = false;
			}
			break;
		}

		case NUMERICOID: {
			stub::decimal_type value;
			elog(DEBUG5, "tsurugi_fdw: %s : pgtype is NUMERICOID.", __func__);
			auto error_code = result_set->next_column(value);
			if (error_code == ERROR_CODE::OK) {
				const auto sign = value.sign();
				const auto coefficient_high = value.coefficient_high();
				const auto coefficient_low = value.coefficient_low();
				const auto exponent = value.exponent();
				elog(DEBUG5, "triple(%d, %lu(0x%lX), %lu(0x%lX), %d)", sign,
						coefficient_high, coefficient_high, coefficient_low,
						coefficient_low, exponent);

				int scale = 0;
				if (exponent < 0) {
					scale = -exponent;
				}

				boost::multiprecision::uint128_t mp_coefficient;
				boost::multiprecision::uint128_t mp_high = coefficient_high;
				mp_coefficient = mp_high << 64;
				mp_coefficient |= coefficient_low;

				std::string coefficient;
				coefficient = mp_coefficient.str();
				if (exponent != 0) {
					if (scale >= (int) coefficient.size()) {
						// padding decimal point with zero
						std::stringstream ss;
						ss << std::setw(scale + 1) << std::setfill('0')
						   << coefficient;
						coefficient = ss.str();
					}
					coefficient.insert(coefficient.end() + exponent, '.');
				}
				if (sign < 0) {
					coefficient = "-" + coefficient;
				}
				elog(DEBUG5, "numeric_in(%s)", coefficient.c_str());

				pg_value = DirectFunctionCall3(numeric_in,
						CStringGetDatum(coefficient.c_str()),
						ObjectIdGetDatum(InvalidOid),
						Int32GetDatum(((NUMERIC_MAX_PRECISION << 16) | scale) +
									  VARHDRSZ));
				is_null = false;
			}
			break;
		}

		case BYTEAOID: {
			elog(DEBUG5, "tsurugi_fdw: %s : pgtype is BYTEAOID.", __func__);

			std::string_view value;
			ERROR_CODE result = result_set->next_column(value);
			if (result == ERROR_CODE::OK) {
				bytea* pg_bytea = (bytea*) palloc(value.size() + VARHDRSZ);
				SET_VARSIZE(pg_bytea, value.size() + VARHDRSZ);
				memcpy(VARDATA(pg_bytea), value.data(), value.size());

				is_null = false;
				pg_value = PointerGetDatum(pg_bytea);
			}
			break;
		}

		default: {
			/* unsuported data type */
			elog(LOG, "Invalid data type of PG. (%u)", pgtype);
			return std::nullopt;
		}
	}

	return std::make_pair(is_null, pg_value);
}

static inline void
reject_infinite_timestamp(Oid pg_type, Datum pg_value)
{
    if (pg_type == TIMESTAMPOID)
    {
        Timestamp ts = DatumGetTimestamp(pg_value);
        if (TIMESTAMP_NOT_FINITE(ts))
            ereport(ERROR,
                    (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                     errmsg("'infinity' is not supported in tsurugi_fdw.")));
    }
    else if (pg_type == TIMESTAMPTZOID)
    {
        TimestampTz ts = DatumGetTimestampTz(pg_value);
        if (TIMESTAMP_NOT_FINITE(ts))
            ereport(ERROR,
                    (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                     errmsg("'infinity' is not supported in tsurugi_fdw.")));
    }
}

/**
 *  @brief 	Convert PostgreSQL value to Tsurugi value.
 *  @param 	(pg_type) OID of PostgreSQL data type.
 * 			(pg_value) PostgreSQL value.
 * 			(tg_value) Tsurugi value.
 *  @return	(true) success.
 * 			(false) failure.
 */
std::optional<TgValue> tg_convert_value_pg_to_tg(
		const Oid pg_type, Datum pg_value) {
	elog(DEBUG3, "tsurugi_fdw: %s : pg_type: %d", __func__, (int) pg_type);

	reject_infinite_timestamp(pg_type, pg_value);

	TgValue tg_value;
	switch (pg_type) {
		case INT2OID:
			tg_value = static_cast<std::int16_t>(DatumGetInt16(pg_value));
			break;
		case INT4OID:
			tg_value = static_cast<std::int32_t>(DatumGetInt32(pg_value));
			break;
		case INT8OID:
			tg_value = static_cast<std::int64_t>(DatumGetInt64(pg_value));
			break;
		case FLOAT4OID:
			tg_value = static_cast<float>(DatumGetFloat4(pg_value));
			break;
		case FLOAT8OID:
			tg_value = static_cast<double>(DatumGetFloat8(pg_value));
			break;
		case BPCHAROID:
		case VARCHAROID:
		case TEXTOID: {
			Oid typoutput;
			bool typisvarlena;
			getTypeOutputInfo(pg_type, &typoutput, &typisvarlena);
			tg_value = OidOutputFunctionCall(typoutput, pg_value);
			break;
		}
		case DATEOID: {
			DateADT date = DatumGetDateADT(pg_value);
			struct pg_tm tm;
			j2date(date + POSTGRES_EPOCH_JDATE, &(tm.tm_year), &(tm.tm_mon),
					&(tm.tm_mday));
			auto tg_date = takatori::datetime::date(
					static_cast<std::int32_t>(tm.tm_year),
					static_cast<std::int32_t>(tm.tm_mon),
					static_cast<std::int32_t>(tm.tm_mday));
			tg_value = tg_date;
			break;
		}
		case TIMEOID: {
			TimeADT time = DatumGetTimeADT(pg_value);
			struct pg_tm tt, *tm = &tt;
			fsec_t fsec;
			time2tm(time, tm, &fsec);
			auto tg_time_of_day = takatori::datetime::time_of_day(
					static_cast<std::int64_t>(tm->tm_hour),
					static_cast<std::int64_t>(tm->tm_min),
					static_cast<std::int64_t>(tm->tm_sec),
					std::chrono::nanoseconds(fsec * 1000));
			tg_value = tg_time_of_day;
			break;
		}
		case TIMETZOID: {
			TimeTzADT* timetz = DatumGetTimeTzADTP(pg_value);
			struct pg_tm tt, *tm = &tt;
			fsec_t fsec;
			time2tm(timetz->time, tm, &fsec);
			auto tg_time_of_day = takatori::datetime::time_of_day(
					static_cast<std::int64_t>(tm->tm_hour),
					static_cast<std::int64_t>(tm->tm_min),
					static_cast<std::int64_t>(tm->tm_sec),
					std::chrono::nanoseconds(fsec * 1000));
			std::int32_t tg_time_zone = 0;
			if (timetz->zone != 0) {
				tg_time_zone = -timetz->zone / SECS_PER_MINUTE;
			}
			auto tg_time_of_day_with_time_zone =
					std::pair<takatori::datetime::time_of_day, std::int32_t>{
							tg_time_of_day, tg_time_zone};
			elog(DEBUG5, "time_of_day = %d:%d:%d.%d, time_zone = %d",
					tm->tm_hour, tm->tm_min, tm->tm_sec, fsec, tg_time_zone);
			tg_value = tg_time_of_day_with_time_zone;
			break;
		}
		case TIMESTAMPTZOID: {
			TimestampTz timestamptz = DatumGetTimestampTz(pg_value);
			struct pg_tm tt, *tm = &tt;
			fsec_t fsec;
			int tz;
			if (timestamp2tm(timestamptz, &tz, tm, &fsec, NULL, NULL) != 0) {
				elog(LOG, "tsurugi_fdw: timestamp out of range");
				return false;
			}
			auto tg_date = takatori::datetime::date(
					static_cast<std::int32_t>(tm->tm_year),
					static_cast<std::int32_t>(tm->tm_mon),
					static_cast<std::int32_t>(tm->tm_mday));
			auto tg_time_of_day = takatori::datetime::time_of_day(
					static_cast<std::int64_t>(tm->tm_hour),
					static_cast<std::int64_t>(tm->tm_min),
					static_cast<std::int64_t>(tm->tm_sec),
					std::chrono::nanoseconds(fsec * 1000));
			auto tg_time_point =
					takatori::datetime::time_point(tg_date, tg_time_of_day);
			std::int32_t tg_time_zone = 0;
			if (tz != 0) {
				tg_time_zone = -tz / SECS_PER_MINUTE;
			}
			auto tg_time_point_with_time_zone =
					std::pair<takatori::datetime::time_point, std::int32_t>{
							tg_time_point, tg_time_zone};
			elog(DEBUG5,
					"date = %d/%d/%d, time_of_day = %d:%d:%d.%d, time_zone "
					"= "
					"%d",
					tm->tm_year, tm->tm_mon, tm->tm_mday, tm->tm_hour,
					tm->tm_min, tm->tm_sec, fsec, tg_time_zone);
			tg_value = tg_time_point_with_time_zone;
			// tg_value = convert_timestamptz_to_tg(pg_value);
			break;
		}
		case TIMESTAMPOID: {
			Timestamp timestamp = DatumGetTimestamp(pg_value);
			struct pg_tm tt, *tm = &tt;
			fsec_t fsec;
			if (timestamp2tm(timestamp, NULL, tm, &fsec, NULL, NULL) != 0) {
				elog(LOG, "tsurugi_fdw: timestamp out of range");
				return false;
			}
			auto tg_date = takatori::datetime::date(
					static_cast<std::int32_t>(tm->tm_year),
					static_cast<std::int32_t>(tm->tm_mon),
					static_cast<std::int32_t>(tm->tm_mday));
			auto tg_time_of_day = takatori::datetime::time_of_day(
					static_cast<std::int64_t>(tm->tm_hour),
					static_cast<std::int64_t>(tm->tm_min),
					static_cast<std::int64_t>(tm->tm_sec),
					std::chrono::nanoseconds(fsec * 1000));
			auto tg_time_point =
					takatori::datetime::time_point(tg_date, tg_time_of_day);
			tg_value = tg_time_point;
			break;
		}
		case NUMERICOID: {
			// Convert PostgreSQL NUMERIC type to string.
			std::string pg_numeric =
					DatumGetCString(DirectFunctionCall1(numeric_out, pg_value));
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
				// The first zero is deleted. Because identified as an octal
				// number.
				pg_numeric.erase(0, 1);
			}
			elog(DEBUG5, "after: pg_numeric = %s", pg_numeric.c_str());

			// Get display scale and sign from NumericData.
			Numeric numeric_data = DatumGetNumeric(pg_value);
			bool numeric_is_short = numeric_data->choice.n_header & 0x8000;
			int numeric_dscale;
			int numeric_sign;
			if (numeric_is_short) {
				numeric_dscale = (numeric_data->choice.n_short.n_header &
										 NUMERIC_SHORT_DSCALE_MASK) >>
								 NUMERIC_SHORT_DSCALE_SHIFT;
				if (numeric_data->choice.n_short.n_header &
						NUMERIC_SHORT_SIGN_MASK)
					numeric_sign = NUMERIC_NEG;
				else
					numeric_sign = NUMERIC_POS;
			} else {
				numeric_dscale = numeric_data->choice.n_long.n_sign_dscale &
								 NUMERIC_DSCALE_MASK;
				numeric_sign =
						numeric_data->choice.n_header & NUMERIC_SIGN_MASK;
			}

			// Generate parameters for takatori::decimal::triple.
			std::int64_t sign = 0;
			switch (numeric_sign) {
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
					elog(LOG, "tsurugi_fdw: Unrecognized numeric sign = 0x%x", numeric_sign);
					return false;
			}

			boost::multiprecision::cpp_int mp_coefficient(pg_numeric);
			if (mp_coefficient >
					std::numeric_limits<
							boost::multiprecision::uint128_t>::max()) {
				elog(LOG, "tsurugi_fdw: Numeric coefficient field overflow");
				return false;
			}
			std::uint64_t coefficient_high =
					static_cast<std::uint64_t>(mp_coefficient >> 64);
			std::uint64_t coefficient_low =
					static_cast<std::uint64_t>(mp_coefficient);

			std::int32_t exponent = -numeric_dscale;

			elog(DEBUG5, "triple(%ld, %lu(0x%lX), %lu(0x%lX), %d)", sign,
					coefficient_high, coefficient_high, coefficient_low,
					coefficient_low, exponent);

			auto tg_decimal = takatori::decimal::triple{
					sign, coefficient_high, coefficient_low, exponent};
			tg_value = tg_decimal;
			//	tg_value = convert_decimal_to_tg(pg_value);
			break;
		}

		case BYTEAOID: {
			auto datum_value = DatumGetByteaPP(pg_value);
			auto pg_value = VARDATA_ANY(datum_value);
			auto pg_value_len = VARSIZE_ANY_EXHDR(datum_value);

			stub::binary_type bin_value(pg_value_len);
			if (pg_value_len > 0) {
				memcpy(bin_value.data(), pg_value, pg_value_len);
			}

			tg_value = bin_value;
			break;
		}
		default: {
			elog(LOG, "Unrecognized type oid: %d", (int) pg_type);
			return std::nullopt;
		}
	}

	return tg_value;
}

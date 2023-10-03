/*
 * Copyright 2023 tsurugi project.
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
 *	@file	tsurugi_prepare.cpp
 *	@brief 	Dispatch the prepare statement to ogawayama.
 */

#include <map>

#include "ogawayama/stub/api.h"
#include "tsurugi.h"

#ifdef __cplusplus
extern "C" {
#endif
#include "postgres.h"

#include "catalog/pg_type.h"
#include "nodes/params.h"
#include "nodes/execnodes.h"

extern void getTypeOutputInfo(Oid type, Oid *typOutput, bool *typIsVarlena);
#ifdef __cplusplus
}
#endif

#include "tsurugi_prepare.h"

using namespace ogawayama;

static constexpr const char* const PREPARE_NAME = "tsurugi_prep_";
static constexpr const char* const PREPARE_PARAM_NAME = "param_";
static constexpr const char* const PREPARE_PARAM_NAME_SQL = ":param_";

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
			std::string param_name = PREPARE_PARAM_NAME_SQL + std::to_string(i);
			sql = sql.replace(param_pos, serch_param_len, param_name);
		}

		// Generating placeholders for Tsurugi Prepared Statements.
		stub::placeholders_type placeholders{};
		for (int i = 0; i < params->numParams; i++) {
			std::string param_name = PREPARE_PARAM_NAME + std::to_string(i);
			ParamExternData param = params->params[i];
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

		ERROR_CODE error = Tsurugi::prepare(sql, placeholders, prepared_statement);
		if (error != ERROR_CODE::OK)
		{
			elog(ERROR, "Tsurugi::prepare() failed. (%d)\n\tsql:%s", (int) error, sql.c_str());
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

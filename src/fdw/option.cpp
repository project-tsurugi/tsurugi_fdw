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
 * Portions Copyright (c) 1996-2023, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, The Regents of the University of California
 *
 *	@file option.cpp
 *	@brief tsurugi_fdw options.
 */

#include <algorithm>
#include <charconv>
#include <string>
#include <unordered_map>

#ifdef __cplusplus
extern "C" {
#endif

#include "postgres.h"

#include "access/reloptions.h"
#include "catalog/pg_foreign_server.h"
#include "foreign/fdwapi.h"

PG_FUNCTION_INFO_V1(tsurugi_fdw_validator);

#ifdef __cplusplus
}
#endif

/* Defines for valid option names */
static constexpr const char* const kOptNameEndpoint = "endpoint";
static constexpr const char* const kOptNameDbname = "dbname";
static constexpr const char* const kOptNameAddress = "address";
static constexpr const char* const kOptNamePort = "port";
static constexpr const char* const kOptNameKey = "key";

/* Defines for endpoint values. */
static constexpr const char* const kValEndpointIpc = "ipc";
static constexpr const char* const kValEndpointTcp = "stream";
static constexpr const char* const kValTrue = "true";

/**
 * Describes the valid options for objects that use this wrapper.
 */
struct TsurugiFdwOption
{
	std::string name; // Option name
	Oid context; // Oid of catalog in which option may appear
};

/**
 * Valid options for tsurugi_fdw.
 */
static const std::unordered_multimap<std::string_view, Oid> VALID_OPTIONS =
{
	/* Foreign server options */
	{kOptNameEndpoint, ForeignServerRelationId},
	{kOptNameDbname, ForeignServerRelationId},
	{kOptNameAddress, ForeignServerRelationId},
	{kOptNamePort, ForeignServerRelationId},
	/* CREATE FOREIGN TABLE options */
	{kOptNameKey, AttributeRelationId},
};

static bool is_valid_option(std::string_view option, Oid context);

/**
 * Validate the generic options given to a FOREIGN DATA WRAPPER, SERVER,
 * USER MAPPING or FOREIGN TABLE that uses tsurugi_fdw.
 *
 * Raise an ERROR if the option or its value is considered invalid.
 */
Datum
tsurugi_fdw_validator(PG_FUNCTION_ARGS)
{
	List* options_list = untransformRelOptions(PG_GETARG_DATUM(0));
	Oid catalog = PG_GETARG_OID(1);

	elog(DEBUG2, "tsurugi_fdw : %s(%d)", __func__, catalog);

	std::string opt_val_endpoint;
	std::string opt_val_dbname;
	std::string opt_val_address;
	std::string opt_val_port;
	std::string opt_val_key;

	ListCell* cell;
	foreach (cell, options_list) {
		DefElem* def = (DefElem*)lfirst(cell);

		auto opt_key = std::string(def->defname);
		auto opt_val = std::string(strVal(def->arg));

		/* Convert the option name to lowercase. */
		std::transform(opt_key.begin(), opt_key.end(), opt_key.begin(),
					   [](unsigned char c) { return std::tolower(c); });

		/* Check whether the option name is valid. */
		if (!is_valid_option(opt_key, catalog)) {
			ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_OPTION_NAME),
							errmsg(R"_(invalid option "%s")_", def->defname)));
		}

		/* Trim spaces from both ends of the option value. */
		auto it_s =
			std::find_if_not(opt_val.begin(), opt_val.end(), [](unsigned char ch) {
				return std::isspace(ch);
			});
		auto it_e =
			std::find_if_not(opt_val.rbegin(), opt_val.rend(), [](unsigned char ch) {
						 return std::isspace(ch);
			}).base();

		/* If it consists only of spaces, it is treated as an empty string. */
		if (it_s >= it_e) {
			opt_val.clear();
		} 

		/* Validate option values. */
		if (opt_val.empty()) {
			ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_ATTRIBUTE_VALUE),
							errmsg(R"(option "%s" requires a non-empty value)", opt_key.c_str())));
		}

		/* Option value validation and storage. */
		if (opt_key == kOptNameEndpoint) {
			/* The value of the "endpoint" option must be either "ipc" or "stream". */
			if ((opt_val != kValEndpointIpc) && (opt_val != kValEndpointTcp)) {
				ereport(ERROR,
						(errcode(ERRCODE_FDW_INVALID_ATTRIBUTE_VALUE),
						 errmsg(R"(invalid value ("%s") for option "%s")", opt_val.c_str(),
								kOptNameEndpoint),
						 errdetail("expected '%s' or '%s'", kValEndpointIpc, kValEndpointTcp)));
			}
			opt_val_endpoint = opt_val;

		} else if (opt_key == kOptNameDbname) {
			opt_val_dbname = opt_val;

		} else if (opt_key == kOptNameAddress) {
			opt_val_address = opt_val;

		} else if (opt_key == kOptNamePort) {
			/* The value of the "port" option must be an integer greater than zero. */
			int port_num;
			auto begin = opt_val.data();
			auto end = begin + opt_val.size();
			auto [pos, ec] = std::from_chars(begin, end, port_num);

			if ((ec != std::errc{}) || (pos != end) || (port_num <= 0)) {
				ereport(ERROR, (errcode(ERRCODE_FDW_INVALID_ATTRIBUTE_VALUE),
								errmsg(R"("%s" must be an integer value greater than zero: %s)",
									   def->defname, opt_val.c_str())));
			}
			opt_val_port = opt_val;
		} else if (opt_key == kOptNameKey) {
			opt_val_key = opt_val;
		}
	}

	/* Validate required options. */
	if (catalog == ForeignServerRelationId) {
		/* For foreign server options. */
		if (opt_val_endpoint == kValEndpointIpc) {
			if (opt_val_dbname.empty()) {
				elog(LOG, R"(The default value is used for "%s".)", kOptNameDbname);
			}
		} else if (opt_val_endpoint == kValEndpointTcp) {
			/* The "address" and "port" options are required for TCP connection. */
			if (opt_val_address.empty()) {
				ereport(ERROR, (errcode(ERRCODE_FDW_OPTION_NAME_NOT_FOUND),
								errmsg(R"(missing required option "%s")", kOptNameAddress)));
			} else if (opt_val_port.empty()) {
				ereport(ERROR, (errcode(ERRCODE_FDW_OPTION_NAME_NOT_FOUND),
								errmsg(R"(missing required option "%s")", kOptNamePort)));
			}
		}

		elog(DEBUG2, "Foreign server options: %s:=[%s], %s:=[%s], %s:=[%s], %s:=[%s]",
				kOptNameEndpoint, opt_val_endpoint.c_str(),
				kOptNameDbname, opt_val_dbname.c_str(),
				kOptNameAddress, opt_val_address.c_str(),
				kOptNamePort, opt_val_port.c_str());
	}

	PG_RETURN_VOID();
}

/**
 * @brief Check if the provided option is one of the valid options.
 * @param option The option name to check.
 * @param context The Oid of the catalog holding the object the option is for.
 * @retval true if the option is valid.
 * @retval false if the option is not valid.
 */
static bool is_valid_option(std::string_view option, Oid context)
{
	auto range = VALID_OPTIONS.equal_range(option);
	for (auto it = range.first; it != range.second; ++it) {
		if (it->second == context) {
			return true;
		}
	}
	return false;
}

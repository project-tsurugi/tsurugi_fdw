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
 */
#include "tsurugi_utils.h"

#include <regex>
#include "tsurugi_fdw.h"
#include "ogawayama/stub/error_code.h"

#ifdef __cplusplus
extern "C" {
#endif
#include "fmgr.h"
#include "access/htup_details.h"
#include "catalog/pg_type.h"
#include "utils/syscache.h"
#ifdef __cplusplus
}
#endif

using namespace ogawayama;

static const std::string PUBLIC_SCHEMA_NAME = "public\\.";
static const std::string PUBLIC_DOUBLE_QUOTATION = "\"public\"\\.";

/*
 *  
 */
std::string make_tsurugi_query(std::string_view query_string)
{
    std::string tsurugi_query(query_string);

	elog(DEBUG1, "tsurugi_fdw : raw query string : \"%s\"", query_string.data());

	// erase public schema.
	std::smatch regex_match;
	std::regex regex_public(PUBLIC_SCHEMA_NAME, std::regex_constants::icase);
	while(std::regex_search(tsurugi_query, regex_match, regex_public)) {
		std::string::size_type erase_pos = tsurugi_query.find(regex_match.str(0));
		std::size_t erase_size = regex_match.str(0).size();
		tsurugi_query.erase(erase_pos, erase_size);
	}
	std::regex regex_double_quotation(PUBLIC_DOUBLE_QUOTATION);
	while(std::regex_search(tsurugi_query, regex_match, regex_double_quotation)) {
		std::string::size_type erase_pos = tsurugi_query.find(regex_match.str(0));
		std::size_t erase_size = regex_match.str(0).size();
		tsurugi_query.erase(erase_pos, erase_size);
	}

    // trim terminal semi-column.
    if (tsurugi_query.back() == ';') 
    {
        tsurugi_query.pop_back();
    }

    elog(DEBUG1, "tsurugi_fdw : tsurugi query string : \"%s\"", tsurugi_query.c_str());

    return tsurugi_query;
}

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
 *	@file	tsurugi_query.c
 *	@brief 	Foreign Data Wrapper for tsurugi
 */
#include "tsurugi_utils.h"

#include <regex>
#include "ogawayama_fdw.h"
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

/*
 *  
 */
std::string make_tsurugi_query(std::string_view query_string)
{
    std::string tsurugi_query(query_string);

	elog(DEBUG1, "tsurugi_fdw : raw query string : \"%s\"", query_string.data());

    // trim terminal semi-column.
    if (tsurugi_query.back() == ';') 
    {
        tsurugi_query.pop_back();
    }

    elog(DEBUG1, "tsurugi_fdw : tsurugi query string : \"%s\"", tsurugi_query.c_str());

    return tsurugi_query;
}

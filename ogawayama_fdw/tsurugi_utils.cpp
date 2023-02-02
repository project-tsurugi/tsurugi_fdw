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

    // for deleting cast string
    tsurugi_query = std::regex_replace(tsurugi_query, std::regex("(::[a-zA-Z]+)"), "");

    // for ORDER BY
    tsurugi_query = std::regex_replace(tsurugi_query, std::regex("(ASC|NULLS|LAST|FIRST)"), "");

    elog(DEBUG1, "tsurugi_fdw : tsurugi query string : \"%s\"", tsurugi_query.c_str());

    return tsurugi_query;
}

/*
 *  Convert tsurugi data into PostgreSQL's compatible data types.
 */
Datum
tsurugi_convert_to_pg(Oid pgtype, ResultSetPtr result_set)
{
    Datum       dat = 0;
    HeapTuple 	heap_tuple;
    regproc 	typinput;
    int 		typemod;

    heap_tuple = SearchSysCache1(TYPEOID, 
                                ObjectIdGetDatum(pgtype));
    if (!HeapTupleIsValid(heap_tuple))
    {
        elog(ERROR, "cache lookup failed for type %u", pgtype);
    }
    typinput = ((Form_pg_type) GETSTRUCT(heap_tuple))->typinput;
    typemod = ((Form_pg_type) GETSTRUCT(heap_tuple))->typtypmod;
    ReleaseSysCache(heap_tuple);

    switch (pgtype)
    {
        case INT2OID:
            {
                std::int16_t value;
                if (result_set->next_column(value) == ERROR_CODE::OK)
                {
                    dat = Int16GetDatum(value);
                }
                break;
            }

        case INT4OID:
            {
                std::int32_t value;
                if (result_set->next_column(value) == ERROR_CODE::OK)
                {
                    dat =  Int32GetDatum(value);
                }
                break;
            }

        case INT8OID:
            {
                std::int64_t value;
                if (result_set->next_column(value) == ERROR_CODE::OK) 
                {
                    dat = Int64GetDatum(value);
                }
                break;
            }

        case FLOAT4OID:
            {
                float4 value;
                if (result_set->next_column(value) == ERROR_CODE::OK)
                {
                    dat = Float4GetDatum(value);
                }
                break;
            }

        case FLOAT8OID:
            {
                float8 value;
                if (result_set->next_column(value) == ERROR_CODE::OK)
                {
                    dat = Float8GetDatum(value);
                }
                break;
            }
        
        case BPCHAROID:
        case VARCHAROID:
        case TEXTOID:
            {
                std::string_view value;
                Datum value_datum;
                ERROR_CODE result = result_set->next_column(value);
                if (result == ERROR_CODE::OK)
                {
                    value_datum = CStringGetDatum(value.data());				
                    if (value_datum == (Datum) nullptr)
                    {
                        break;
                    }
                    dat = (Datum) OidFunctionCall3(typinput, 
                                                value_datum, 
                                                ObjectIdGetDatum(InvalidOid), 
                                                Int32GetDatum(typemod));
                }
                else if (result == ERROR_CODE::COLUMN_WAS_NULL)
                {
                    value_datum = CStringGetDatum("");
                    dat = (Datum) OidFunctionCall3(typinput, 
                                                value_datum, 
                                                ObjectIdGetDatum(InvalidOid), 
                                                Int32GetDatum(typemod));
                }
                else
                {
                    elog(ERROR, 
                        "stub::ResultSet::next_column() failed. (error: %d)", 
                        (int) result);
                }
            }
            break;
            
        default:
            elog(ERROR, "Invalid data type. (%d)", pgtype);
            break;
    }

    return dat;
}

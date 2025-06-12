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

#include <memory>
#include <regex>
#include <string>
#include <boost/multiprecision/cpp_int.hpp>
#include "ogawayama/stub/error_code.h"
#include "tsurugi_fdw.h"
#include "tsurugi.h"
#include "tsurugi_prepare.h"

#ifdef __cplusplus
extern "C" {
#endif
#include "access/htup_details.h"
#include "catalog/pg_type.h"
#include "commands/defrem.h"
#include "fmgr.h"
#include "funcapi.h"
#include "utils/date.h"
#include "utils/fmgrprotos.h"
#include "utils/guc.h"
#include "utils/lsyscache.h"
#include "utils/memutils.h"
#include "utils/numeric.h"
#include "utils/rel.h"
#include "utils/syscache.h"
#include "utils/timestamp.h"
#ifdef __cplusplus
}
#endif

using namespace ogawayama;

static const std::string PUBLIC_SCHEMA_NAME = "public\\.";
static const std::string PUBLIC_DOUBLE_QUOTATION = "\"public\"\\.";

std::string make_tsurugi_query(std::string_view query_string);
static ogawayama::stub::parameters_type bind_parameters(Relation rel,
                                                        List* target_attrs,
                                                        FmgrInfo* flinfo,
                                                        TupleTableSlot **slots,
                                                        int numSlots);
/*
 *  make_tsurugi_query
 *      
 */
std::string make_tsurugi_query(std::string_view query_string)
{
    std::string tsurugi_query(query_string);

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

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

    return tsurugi_query;
}

/*
 * make_tuple_from_result_row
 *      Obtain tuple data from Ogawayama and convert data type.
 */
void 
make_tuple_from_result_row(ResultSetPtr result_set, 
                            TupleDesc tupleDescriptor,
                            List* retrieved_attrs,
                            Datum* row,
                            bool* is_null,
                            TgFdwForeignScanState* fsstate)
{
	elog(DEBUG5, "tsurugi_fdw : %s", __func__);

	ListCell   *lc = NULL;
	foreach(lc, retrieved_attrs)
	{
		int     attnum = lfirst_int(lc) - 1;
		Oid     	pgtype = TupleDescAttr(tupleDescriptor, attnum)->atttypid;
        HeapTuple 	heap_tuple;
        regproc 	typinput;
        int 		typemod;

		elog(DEBUG5, "tsurugi_fdw : %s : attnum: %d", __func__, attnum + 1);

		heap_tuple = SearchSysCache1(TYPEOID, 
                                    ObjectIdGetDatum(pgtype));
        if (!HeapTupleIsValid(heap_tuple))
        {
            elog(ERROR, "tsurugi_fdw : cache lookup failed for type %u", pgtype);
        }
        typinput = ((Form_pg_type) GETSTRUCT(heap_tuple))->typinput;
        typemod = ((Form_pg_type) GETSTRUCT(heap_tuple))->typtypmod;
        ReleaseSysCache(heap_tuple);

        is_null[attnum] = true;
        switch (pgtype)
        {
            case INT2OID:
                {
                    std::int16_t value;
					elog(DEBUG5, "tsurugi_fdw : %s : pgtype is INT2OID.", __func__);
                    if (result_set->next_column(value) == ERROR_CODE::OK)
                    {
                        is_null[attnum] = false;
                        row[attnum] = Int16GetDatum(value);
                    }
                }
                break;

            case INT4OID:
                {
                    std::int32_t value;
					elog(DEBUG5, "tsurugi_fdw : %s : pgtype is INT4OID.", __func__);
                    if (result_set->next_column(value) == ERROR_CODE::OK)
                    {
                        is_null[attnum] = false;
                        row[attnum] =  Int32GetDatum(value);
                    }
                }
                break;

            case INT8OID:
                {
                    std::int64_t value;
					elog(DEBUG5, "tsurugi_fdw : %s : pgtype is INT8OID.", __func__);
                    if (result_set->next_column(value) == ERROR_CODE::OK)
                    {
                        is_null[attnum] = false;
                        row[attnum] = Int64GetDatum(value);
                    }
                }
                break;

            case FLOAT4OID:
                {
                    float4 value;
					elog(DEBUG5, "tsurugi_fdw : %s : pgtype is FLOAT4OID.", __func__);
                    if (result_set->next_column(value) == ERROR_CODE::OK)
                    {
                        is_null[attnum] = false;
                        row[attnum] = Float4GetDatum(value);
                    }
                }
                break;

            case FLOAT8OID:
                {
                    float8 value;
					elog(DEBUG5, "tsurugi_fdw : %s : pgtype is FLOAT8OID.", __func__);
                    if (result_set->next_column(value) == ERROR_CODE::OK)
                    {
                        is_null[attnum] = false;
                        row[attnum] = Float8GetDatum(value);
                    }
                }
                break;

            case BPCHAROID:
            case VARCHAROID:
            case TEXTOID:
                {
					elog(DEBUG5, "tsurugi_fdw : %s : pgtype is BPCHAROID/VARCHAROID/TEXTOID.", __func__);
					std::string value;
                    Datum value_datum;
                    ERROR_CODE result = result_set->next_column(value);
					if (result == ERROR_CODE::OK)
                    {
                        value_datum = CStringGetDatum(value.c_str());
                        if (value_datum == (Datum) nullptr)
                        {
                            break;
                        }
                        is_null[attnum] = false;
                        row[attnum] = (Datum) OidFunctionCall3(typinput,
                                                    value_datum, 
                                                    ObjectIdGetDatum(InvalidOid),
                                                    Int32GetDatum(typemod));
                    }
                }
                break;

            case DATEOID:
                {
                    stub::date_type value;
					elog(DEBUG5, "tsurugi_fdw : %s : pgtype is DATEOID.", __func__);
                    if (result_set->next_column(value) == ERROR_CODE::OK)
                    {
                        DateADT date;
                        date = value.days_since_epoch();
                        date = date - (POSTGRES_EPOCH_JDATE - UNIX_EPOCH_JDATE);
                        row[attnum] = DateADTGetDatum(date);
                        is_null[attnum] = false;
                    }
                }
                break;

            case TIMEOID:
                {
                    stub::time_type value;
					elog(DEBUG5, "tsurugi_fdw : %s : pgtype is TIMEOID.", __func__);
                    if (result_set->next_column(value) == ERROR_CODE::OK)
                    {
                        TimeADT time;
                        auto subsecond = value.subsecond().count();
                        time = (value.hour() * MINS_PER_HOUR) + value.minute();
                        time = (time * SECS_PER_MINUTE) + value.second();
                        time = time * USECS_PER_SEC;
                        if (subsecond != 0) {
                            subsecond = round(subsecond / 1000.0);
                            time = time + subsecond;
                        }
                        row[attnum] = TimeADTGetDatum(time);
                        is_null[attnum] = false;
                    }
                }
                break;

            case TIMETZOID:
                {
                    stub::timetz_type value;
					elog(DEBUG5, "tsurugi_fdw : %s : pgtype is TIMETZOID.", __func__);
					if (result_set->next_column(value) == ERROR_CODE::OK)
                    {
                        TimeTzADT timetz;
                        auto subsecond = value.first.subsecond().count();
                        timetz.time = (value.first.hour() * MINS_PER_HOUR) + value.first.minute();
                        timetz.time = (timetz.time * SECS_PER_MINUTE) + value.first.second();
                        timetz.time = timetz.time * USECS_PER_SEC;
                        if (subsecond != 0) {
                            subsecond = round(subsecond / 1000.0);
                            timetz.time = timetz.time + subsecond;
                        }
                        timetz.zone = -value.second * SECS_PER_MINUTE;

                        elog(DEBUG5, "time_of_day = %d:%d:%d.%d, time_zone = %d",
                                        value.first.hour(), value.first.minute(), value.first.second(),
                                        subsecond, value.second);

                        row[attnum] = TimeTzADTPGetDatum(&timetz);
                        is_null[attnum] = false;
                    }
                }
                break;

            case TIMESTAMPTZOID:
                {
                    stub::timestamptz_type value;
					elog(DEBUG5, "tsurugi_fdw : %s : pgtype is TIMESTAMPTZOID.", __func__);
                    if (result_set->next_column(value) == ERROR_CODE::OK)
                    {
                        Timestamp timestamp;
                        auto subsecond = value.first.subsecond().count();
                        timestamp = value.first.seconds_since_epoch().count() -
                            ((POSTGRES_EPOCH_JDATE - UNIX_EPOCH_JDATE) * SECS_PER_DAY);
                        timestamp = timestamp * USECS_PER_SEC;
                        if (subsecond != 0) {
                            subsecond = round(subsecond / 1000.0);
                            timestamp = timestamp + subsecond;
                        }
                        auto time_zone = value.second * SECS_PER_MINUTE;
                        timestamp = timestamp - (time_zone * USECS_PER_SEC);

                        elog(DEBUG5, "seconds_since_epoch = %ld, subsecond = %d, time_zone = %d",
                                        value.first.seconds_since_epoch().count(),
                                        value.first.subsecond().count(),
                                        value.second);

                        row[attnum] = TimestampTzGetDatum(timestamp);
                        is_null[attnum] = false;
                    }
                }
                break;

            case TIMESTAMPOID:
                {
                    stub::timestamp_type value;
					elog(DEBUG5, "tsurugi_fdw : %s : pgtype is TIMESTAMPOID.", __func__);
                    if (result_set->next_column(value) == ERROR_CODE::OK)
                    {
                        Timestamp timestamp;
                        auto subsecond = value.subsecond().count();
                        timestamp = value.seconds_since_epoch().count() -
                            ((POSTGRES_EPOCH_JDATE - UNIX_EPOCH_JDATE) * SECS_PER_DAY);
                        timestamp = timestamp * USECS_PER_SEC;
                        if (subsecond != 0) {
                            subsecond = round(subsecond / 1000.0);
                            timestamp = timestamp + subsecond;
                        }
                        row[attnum] = TimestampGetDatum(timestamp);
                        is_null[attnum] = false;
                    }
                }
                break;

            case NUMERICOID:
                {
                    stub::decimal_type value;
					elog(DEBUG5, "tsurugi_fdw : %s : pgtype is NUMERICOID.", __func__);
                    auto error_code = result_set->next_column(value);
                    if (error_code == ERROR_CODE::OK)
                    {
                        const auto sign = value.sign();
                        const auto coefficient_high = value.coefficient_high();
                        const auto coefficient_low = value.coefficient_low();
                        const auto exponent = value.exponent();
                        elog(DEBUG5, "triple(%d, %lu(0x%lX), %lu(0x%lX), %d)",
                                                sign, coefficient_high, coefficient_high,
                                                coefficient_low, coefficient_low, exponent);

                        int scale = 0;
                        if (exponent < 0) {
                            scale =- exponent;
                        }

                        boost::multiprecision::uint128_t mp_coefficient;
                        boost::multiprecision::uint128_t mp_high = coefficient_high;
                        mp_coefficient = mp_high << 64;
                        mp_coefficient |= coefficient_low;

                        std::string coefficient;
                        coefficient = mp_coefficient.str();
                        if (exponent != 0) {
                            if (scale >= (int)coefficient.size()) {
                                // padding decimal point with zero
                                std::stringstream ss;
                                ss << std::setw(scale+1) << std::setfill('0') << coefficient;
                                coefficient = ss.str();
                            }
                            coefficient.insert(coefficient.end() + exponent, '.');
                        }
                        if (sign < 0) {
                            coefficient = "-" + coefficient;
                        }
                        elog(DEBUG5, "numeric_in(%s)", coefficient.c_str());

                        row[attnum] = DirectFunctionCall3(numeric_in,
                                                     CStringGetDatum(coefficient.c_str()),
                                                     ObjectIdGetDatum(InvalidOid),
                                                     Int32GetDatum(((NUMERIC_MAX_PRECISION << 16) |
                                                                             scale) + VARHDRSZ));
                        is_null[attnum] = false;

                    }
                }
                break;

            default:
                elog(ERROR, "Invalid data type of PG. (%u)", pgtype);
                break;
        }
    }
}

/*
 *	bind_parameters
 *		Bind parameters of prepared statement.
 */
static ogawayama::stub::parameters_type
bind_parameters(Relation rel,
                List* target_attrs,
                FmgrInfo* flinfo,
			 	TupleTableSlot **slots,
			 	int numSlots)
{
	TupleDesc	tupdesc = RelationGetDescr(rel);
	stub::parameters_type params{};

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	if (slots != NULL && target_attrs != NIL)
	{
		int param_num = 0;
		ListCell   *lc;
		foreach(lc, target_attrs)
		{	
			int			attnum = lfirst_int(lc);
			Form_pg_attribute attr = TupleDescAttr(tupdesc, attnum - 1);
			Datum		value;
			bool		isnull;	
			std::string param_name = "param" + std::to_string(++param_num);

			/* Ignore generated columns; they are set to DEFAULT */
			if (attr->attgenerated)
				continue;
			value = slot_getattr(slots[0], attnum, &isnull);
			if (isnull)
			{
				std::monostate mono{};
				params.emplace_back(param_name, mono);
			}
			else
			{
				stub::value_type tg_type = Tsurugi::convert_type_to_tg(attr->atttypid, 
                                                                        value);
				params.emplace_back(param_name, tg_type);
				elog(LOG, "tsurugi_fdw : parameter name: %s, value: %s", 
					param_name.c_str(), 
					OutputFunctionCall(&flinfo[param_num-1], value));
			}
		}
        elog(LOG, "tsurugi_fdw : parameter count: %d", param_num);
	}

	return params;
}

/*
 *	bind_parameters
 *		Bind parameters of prepared statement.
 */
static ogawayama::stub::parameters_type
bind_parameters2(ExprContext* econtext,
                FmgrInfo* param_flinfo,
                List* param_exprs,
                Relation rel)
{
	TupleDesc	tupdesc = RelationGetDescr(rel);
    stub::parameters_type params{};

	elog(DEBUG1, "tsurugi_fdw : %s", __func__);

    int param_num = 0;
    ListCell   *lc;
    foreach(lc, param_exprs)
    {	
        ExprState*  expr_state = (ExprState*) lfirst(lc);
        Datum       expr_value;
        bool		isNull;	
        Form_pg_attribute attr = TupleDescAttr(tupdesc, param_num - 1);
        /* parameter number is 1 origin. */
        std::string param_name = "param" + std::to_string(++param_num);

        expr_value = ExecEvalExpr(expr_state, econtext, &isNull);

        if (isNull)
        {
            std::monostate mono{};
            params.emplace_back(param_name, mono);
        }
        else
        {
            stub::value_type tg_type = Tsurugi::convert_type_to_tg(attr->atttypid, 
                                                                    expr_value);
            params.emplace_back(param_name, tg_type);
            elog(LOG, "tsurugi_fdw : parameter name: %s, value: %s", 
                param_name.c_str(), 
                OutputFunctionCall(&param_flinfo[param_num-1], expr_value));
        }
        param_num++;
    }

    elog(LOG, "tsurugi_fdw : parameter count: %d", param_num);

	return params;
}

/*
 *	prepare_direct_modify
 *		Prepare a statement for direct modify.
 */
void
prepare_direct_modify(TgFdwDirectModifyState* dmstate)
{
	TupleDesc	tupdesc = RelationGetDescr(dmstate->rel);
	stub::placeholders_type placeholders{};

	assert(tupdesc != nullptr);

	elog(DEBUG3, "tsurugi_fdw : %s", __func__);

	for (int i = 0; i < tupdesc->natts; i++)
	{
		/* parameter name is 1 origin. */
		std::string param_name = "param" + std::to_string(i+1);
		placeholders.emplace_back(std::make_pair(param_name, 
			Tsurugi::get_tg_column_type(tupdesc->attrs[i].atttypid)));
	}

	ERROR_CODE error = Tsurugi::prepare(dmstate->query, placeholders);
	if (error != ERROR_CODE::OK)
	{
		Tsurugi::report_error("Failed to prepare the statement on Tsurugi.", 
								error, dmstate->query);
	}
}

/*
 *  execute_direct_modify
 *      Execute a direct UPDATE/DELETE statement.
 */
void
execute_direct_modify(ForeignScanState* node)
{
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);

	TgFdwDirectModifyState *dmstate = (TgFdwDirectModifyState *) node->fdw_state;
    EState* estate = node->ss.ps.state;
    dmstate->set_processed = false;

    std::string stmt = make_tsurugi_query(dmstate->orig_query);
	ERROR_CODE error = Tsurugi::execute_statement(stmt, dmstate->num_tuples);
	if (error != ERROR_CODE::OK)
    {
        /* Prepare processing when via JDBC and ODBC */
        end_prepare_processing(estate);
		Tsurugi::report_error("Failed to execute the statement on Tsurugi.", 
								error, stmt.data());
	}
    dmstate->set_processed = true;
}

/*
 *  execute_direct_modify_with_deparse_sql
 *      Execute a direct UPDATE/DELETE statement using depared sql.
 */
void 
execute_direct_modify_with_deparse_sql(ForeignScanState* node)
{
    elog(DEBUG1, "tsurugi_fdw : %s", __func__);

    TgFdwDirectModifyState *dmstate = (TgFdwDirectModifyState *) node->fdw_state;
    EState* estate = node->ss.ps.state;
    ExprContext *econtext = node->ss.ps.ps_ExprContext;
    dmstate->set_processed = false;

	stub::parameters_type params = bind_parameters2(econtext, 
                                                    dmstate->param_flinfo,
                                                    dmstate->param_exprs,
                                                    dmstate->rel);

	ERROR_CODE error = Tsurugi::execute_statement(params, dmstate->num_tuples);
	if (error != ERROR_CODE::OK)
    {
        /* Prepare processing when via JDBC and ODBC */
        end_prepare_processing(estate);
		Tsurugi::report_error("Failed to execute the statement on Tsurugi.", 
								error, dmstate->query);
	}
    dmstate->set_processed = true;
}

/*
 *	prepare_foreign_modify
 *		Prepare a statement for foreign modify.
 */
void
prepare_foreign_modify(TgFdwForeignModifyState *fmstate)
{
	TupleDesc	tupdesc = RelationGetDescr(fmstate->rel);
	stub::placeholders_type placeholders{};

	assert(tupdesc != nullptr);

	elog(DEBUG3, "tsurugi_fdw : %s", __func__);

	for (int i = 0; i < tupdesc->natts; i++)
	{
		/* parameter name is 1 origin. */
		std::string param_name = "param" + std::to_string(i+1);
		placeholders.emplace_back(std::make_pair(param_name, 
			Tsurugi::get_tg_column_type(tupdesc->attrs[i].atttypid)));
	}

	ERROR_CODE error = Tsurugi::prepare(fmstate->query, placeholders);
	if (error != ERROR_CODE::OK)
	{
		Tsurugi::report_error("Failed to prepare the statement on Tsurugi.", 
								error, fmstate->query);
	}
	fmstate->is_prepared = true;
}

/*
 * 	execute_foreign_modify
 *		Execute a INSERT statement.
 */
TupleTableSlot **
execute_foreign_modify(EState *estate,
					   ResultRelInfo *resultRelInfo,
					   CmdType operation,
					   TupleTableSlot **slots,
					   TupleTableSlot **planSlots,
					   int *numSlots)
{
	TgFdwForeignModifyState *fmstate = 
		(TgFdwForeignModifyState *) resultRelInfo->ri_FdwState;

	/* The operation should be INSERT, UPDATE, or DELETE */
	Assert(operation == CMD_INSERT ||
		   operation == CMD_UPDATE ||
		   operation == CMD_DELETE);

	elog(DEBUG3, "tsurugi_fdw : %s", __func__);

	/* Convert parameters needed by prepared statement to text form */
	//
	stub::parameters_type params = bind_parameters(fmstate->rel,
                                                    fmstate->target_attrs,
                                                    fmstate->p_flinfo, 
                                                    slots, *numSlots);

	/*
	 * Execute the prepared statement.
	 */
	std::size_t	n_rows = 0;
	ERROR_CODE error = Tsurugi::execute_statement(params, n_rows);
	if (error != ERROR_CODE::OK)
	{
		Tsurugi::report_error("Failed to execute the statement on Tsurugi.", 
								error, fmstate->query);
	}

	MemoryContextReset(fmstate->temp_cxt);

	*numSlots = n_rows;

	/*
	 * Return NULL if nothing was inserted/updated/deleted on the remote end
	 */
	return (n_rows > 0) ? slots : NULL;
}

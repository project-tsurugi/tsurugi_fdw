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
 *	@file	alt_function.c
 *	@brief	Tsurugi User-Defined Functions.
 */
#include "postgres.h"
#include "fmgr.h"

bool EnableLTx = false;

PG_FUNCTION_INFO_V1(tsurugi_ltx);

Datum
tsurugi_ltx(PG_FUNCTION_ARGS)
{
	char	   *res = (char *) palloc(32);

	if (PG_NARGS() == 1) {
	    EnableLTx = PG_GETARG_BOOL(0);
	}

	if (EnableLTx) {
		res = "Tsurugi LTx : Enable";
	} else {
		res = "Tsurugi LTx : Disable";
	}

	PG_RETURN_CSTRING(res);
}

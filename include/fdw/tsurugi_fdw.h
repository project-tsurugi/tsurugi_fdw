/*
 * Copyright 2019-2025 Project Tsurugi.
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
 *	@file	tsurugi_fdw.h
 *	@brief 	Foreign Data Wrapper for Tsurugi.
 */
#ifndef TSURUGI_FDW_H
#define TSURUGI_FDW_H

#ifdef __cplusplus
extern "C" {
#endif
#include "foreign/foreign.h"
#include "funcapi.h"
#include "lib/stringinfo.h"
#include "nodes/execnodes.h"
#include "nodes/pathnodes.h"
#include "nodes/plannodes.h"
#include "utils/relcache.h"

/*
 * Tsurugi-FDW Foreign Scan State
 */
typedef struct TgFdwForeignScanState
{
	const char* 	query_string;		/* SQL Query Text */
    Relation        rel;                /* relcache entry for the foreign table */
    TupleDesc       tupdesc;            /* tuple descriptor of scan */
    AttInMetadata*  attinmeta;          /* attribute datatype conversion */
    List*           retrieved_attrs;    /* list of target attribute numbers */

	bool 			cursor_exists;		/* have we created the cursor? */
    int             numParams;          /* number of parameters passed to query */
    FmgrInfo*       param_flinfo;       /* output conversion functions for them */
	ParamListInfo 	param_linfo;
	List*           param_exprs;        /* executable expressions for param values */
	size_t 			number_of_columns;	/* Number of columns to SELECT */
	Oid* 			column_types; 		/* Pointer to the data type (Oid) of the column to be SELECT */

    /* batch operation stuff */
    size_t          rowidx;             /* current index of rows */
	size_t			num_tuples;         /* # of tuples in array */
} TgFdwForeignScanState;

 /*
 * Tsurugi-FDW Direct Modify State
 */
typedef struct TgFdwDirectModifyState
{
	ForeignServer *server;		/* Foreign server handle */
	ForeignTable  *table;		/* Foreign scan deal with this foreign table */

	Relation	rel;			/* relcache entry for the foreign table */
	AttInMetadata *attinmeta;	/* attribute datatype conversion metadata */

	/* extracted fdw_private data */
	const char *orig_query;
	char	   *query;			/* text of UPDATE/DELETE command */
	bool		has_returning;	/* is there a RETURNING clause? */
	List	   *retrieved_attrs;	/* attr numbers retrieved by RETURNING */
	bool		set_processed;	/* do we set the command es_processed? */

	/* for remote query execution */
	char	   *prep_name;		/* name of prepared statement, if created */
	char	   *prep_stmt;
	int			numParams;		/* number of parameters passed to query */
	FmgrInfo   *param_flinfo;	/* output conversion functions for them */
	List	   *param_exprs;	/* executable expressions for param values */
	const char **param_values;	/* textual values of query parameters */
	Oid		   *param_types;	/* type of query parameters */
	ParamListInfo param_linfo;
	TupleTableSlot* slot;

	/* for storing result tuples */
	size_t		num_tuples;		/* # of result tuples */
	int			next_tuple;		/* index of next one to return */
	Relation	resultRel;		/* relcache entry for the target relation */
	AttrNumber *attnoMap;		/* array of attnums of input user columns */
	AttrNumber	ctidAttno;		/* attnum of input ctid column */
	AttrNumber	oidAttno;		/* attnum of input oid column */
	bool		hasSystemCols;	/* are there system columns of resultRel? */

	/* working memory context */
	MemoryContext temp_cxt;		/* context for per-tuple temporary data */
	
} TgFdwDirectModifyState;

#ifdef __cplusplus
}
#endif

#endif // TSURUGI_FDW_H

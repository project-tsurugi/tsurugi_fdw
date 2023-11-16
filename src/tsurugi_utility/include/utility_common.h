/*
 * Copyright 2021-2023 Project Tsurugi.
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
 *	@file	utility_common.h
 *	@brief  Utility command to operate Table through metadata-manager.
 */
#ifndef UTILITY_COMMON_H
#define UTILITY_COMMON_H

#include "postgres.h"
#include "nodes/pg_list.h"

typedef struct _object_name {
    char *database_name;
    char *schema_name;
    char *object_name;
} ObjectName;

void get_object_name(
	List *names, ObjectName *obj);
 
#endif /* UTILITY_COMMON_H */

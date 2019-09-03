/*
 * Copyright 2019-2019 tsurugi project.
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
 */
#ifndef DATATYPE_H
#define DATATYPE_H

/* See metadata.h of ogawayama-stub for original data type definition. */

typedef enum {

    /**
     * @brief Pseudotype representing that the column is NULL.
     */
    PGTYPE_NULL_VALUE = 0,

    /**
     * @brief 16bit integral number type.
     */
    PGTYPE_INT16 = 1,

    /**
     * @brief 32bit integral number type.
     */
    PGTYPE_INT32 = 2,

    /**
     * @brief 64bit integral number type.
     */
    PGTYPE_INT64 = 3,

    /**
     * @brief 32bit floating point number type.
     */
    PGTYPE_FLOAT32 = 4,

    /**
     * @brief 64bit floating point number type.
     */
    PGTYPE_FLOAT64 = 5,

    /**
     * @brief text type.
     */
    PGTYPE_TEXT = 6,
} PG_TYPE;

#endif // DATATYPE_H


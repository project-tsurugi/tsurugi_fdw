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

/* See error_code.h of ogawayama-stub for original data type definition. */

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
#ifndef ERROR_CODE_H
#define ERROR_CODE_H

/* See metadata.h of ogawayama-stub for original data type definition. */

typedef enum {
    /**
     * @brief Success
     */
    ERRORCODE_OK = 0,

    /**
     * @brief NULL has been observed as the column value (a result of successful prodessing).
     */
    ERRORCODE_COLUMN_WAS_NULL,

    /**
     * @brief Current in the ResultSet stepped over the last row (a result of successful prodessing).
     */
    ERRORCODE_END_OF_ROW,

    /**
     * @brief Current Column in the Row stepped over the last column (a result of successful prodessing).
     */
    ERRORCODE_END_OF_COLUMN,

    /**
     * @brief the column value has been requested for a different type than the actual type.
     */
    ERRORCODE_COLUMN_TYPE_MISMATCH,

    /**
     * @brief Encountered server failure.
     */
    ERRORCODE_SERVER_FAILURE,

} ERROR_CODE;

#endif // ERROR_CODE_H


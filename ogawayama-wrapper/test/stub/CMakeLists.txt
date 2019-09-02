# Copyright 2019-2019 tsurugi fin project.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

add_library( ogawayama-stub 
    SHARED
        connection.cpp
        result_set.cpp
        stub.cpp
        transaction.cpp
)

target_include_directories( ogawayama-stub
    PRIVATE ${PROJECT_SOURCE_DIR}/../../ogawayama/stub/include
    PRIVATE ${PROJECT_SOURCE_DIR}/../../ogawayama/stub/include/ogawayama/stub
    PRIVATE ${PROJECT_SOURCE_DIR}/test/stub/include
)

set_target_properties( ogawayama-stub
    PROPERTIES
        LIBRARY_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}/libs"
        ARCHIVE_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}/build"
)

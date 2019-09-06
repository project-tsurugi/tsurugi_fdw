# Copyright 2019-2019 tsurugi project.
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

add_library( ogawayama-wrapper 
    SHARED
        dispatcher.cpp
)

target_include_directories( ogawayama-wrapper
    PRIVATE ${PROJECT_SOURCE_DIR}/include
    PRIVATE ${PROJECT_SOURCE_DIR}/../../ogawayama/stub/include
    PRIVATE ${PROJECT_SOURCE_DIR}/../../ogawayama/stub/include/ogawayama/stub
    PRIVATE ${PROJECT_SOURCE_DIR}/../../../postgresql-11.1/src/include
)

#find_library( DEPEND_LIBRALIES ogawayama-stub HINTS ${PROJECT_SOURCE_DIR}/libs )

target_link_libraries( ogawayama-wrapper 
#    PRIVATE ${DEPEND_LIBRALIES} 
    PRIVATE ogawayama-stub
)

set_target_properties( ogawayama-wrapper
    PROPERTIES
        LIBRARY_OUTPUT_NAME "ogawayama-wrapper"
        LIBRARY_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}/build"
        ARCHIVE_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}/build"
)

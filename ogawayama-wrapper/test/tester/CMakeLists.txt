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

add_executable( tester tester.c )

enable_language(C)
set(CMAKE_C_STANDARD 99)

target_include_directories( tester
    PRIVATE ${PROJECT_SOURCE_DIR}/include
    PRIVATE ${PROJECT_SOURCE_DIR}/../../postgresql-11.1/src/include
)

add_dependencies( tester ogawayama-wrapper )

#find_library( OGAWAYAMA_WRAPPER ogawayama-wrapper HINTS ${PROJECT_SOURCE_DIR}/build )

target_link_libraries( tester
#    PRIVATE ${OGAWAYAMA_WRAPPER} 
    PRIVATE "ogawayama-wrapper"
)

set_target_properties( tester
    PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}/build"
        ARCHIVE_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}/build"
)

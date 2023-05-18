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

set(CMAKE_CXX_COMPILER /usr/bin/g++)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -fno-omit-frame-pointer")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} -fno-omit-frame-pointer")

set( CMAKE_CPP_FLAGS "-pthread" )

add_executable( tester tester.cpp )

target_include_directories( tester
    PRIVATE ${PROJECT_SOURCE_DIR}/../../../../src/include
    PRIVATE ${PROJECT_SOURCE_DIR}/../third_party/ogawayama/stub/include
)

find_library( DEPEND_LIBRALIES ogawayama-stub
    HINTS /home/k-okada/local/lib
)

target_link_libraries( tester
        ${DEPEND_LIBRALIES}
        pthread
        rt
)

set_target_properties( tester
    PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}/build/output"
        ARCHIVE_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}/build"
)

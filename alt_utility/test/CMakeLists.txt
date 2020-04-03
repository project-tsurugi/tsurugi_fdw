cmake_minimum_required(VERSION 3.5)
project(test
    VERSION 0.0.1
    LANGUAGES CXX
)
set(CMAKE_CXX_COMPILER /usr/bin/g++)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -fno-omit-frame-pointer")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} -fno-omit-frame-pointer")

#set(CMAKE_CPP_FLAGS "-pthread")

set(POSTGRESQL_INCLUDE_PATH ${PROJECT_SOURCE_DIR}/../../../../src/include)

set(THIRD_PARTY_DIR ${PROJECT_SOURCE_DIR}/../../third_party)

set(OGAWAYAMA_DIR ${THIRD_PARTY_DIR}/ogawayama)
set(OGAWAYAMA_INCLUDE_PATH ${OGAWAYAMA_DIR}/stub/include)
set(OGAWAYAMA_LIBRARY_PATH ${OGAWAYAMA_DIR}/build/stub/src)

set(MANAGER_DIR ${THIRD_PARTY_DIR}/manager)
set(MANAGER_INCLUDE_PATH ${MANAGER_DIR}/metadata-manager/include)
set(MANAGER_LIBRARY_PATH ${MANAGER_DIR}/metadata-manager/build/output)

set(COMMON_DIR ${PROJECT_SOURCE_DIR}/../../common)
set(COMMON_INCLUDE_PATH ${PROJECT_SOURCE_DIR}/../../include)
set(COMMON_LIBRARY_PATH ${PROJECT_BINARY_DIR}/common)

set(ALT_UTILITY_DIR ${PROJECT_SOURCE_DIR}/..)
set(ALT_UTILITY_INCLUDE_PATH ${ALT_UTILITY_DIR})
set(ALT_UTILITY_LIBRARY_PATH ${PROJECT_BINARY_DIR}/alt_utility)

#set(CMAKE_MODULE_PATH ${manager_DIR})
set(CMAKE_PREFIX_PATH 
    ${OGAWAYAMA_DIR}/build
    ${OGAWAYAMA_DIR}/build/CMakeFiles/Export/lib/cmake/ogawayama
    ${MANAGER_DIR}/metadata-manager/build
    ${MANAGER_DIR}/build/CMakeFiles/Export/lib/cmake/ogawayama
)

message(STATUS manager_FOUND)
message(STATUS ogawayama_FOUND)

link_directories(
    PUBLIC ${OGAWAYAMA_LIBRARY_PATH}
    PUBLIC ${MANAGER_LIBRARY_PATH}
)
message(${OGAWAYAMA_LIBRARY_PATH})
message(${MANAGER_LIBRARY_PATH})

add_subdirectory(${COMMON_DIR} ${COMMON_LIBRARY_PATH})
add_subdirectory(${ALT_UTILITY_DIR} ${ALT_UTILITY_LIBRARY_PATH})

add_executable(test_util test_util.cpp)
target_include_directories(test_util
    PRIVATE ${ALT_UTILITY_DIR} # aly_utility
)

target_link_libraries(test_util 
    PUBLIC alt_utility
)

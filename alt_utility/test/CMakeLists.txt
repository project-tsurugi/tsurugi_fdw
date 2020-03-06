cmake_minimum_required(VERSION 3.0)
project(alt_utility CXX)

set(CMAKE_CXX_COMPILER /usr/bin/g++)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -fno-omit-frame-pointer")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} -fno-omit-frame-pointer")
set( CMAKE_CPP_FLAGS "-pthread" )

add_subdirectory(../src ${PROJECT_BINARY_DIR}/output)
#add_subdirectory(test)

add_executable(test_util test_util.cpp)

target_include_directories(test_util
    PRIVATE ${PROJECT_SOURCE_DIR}/../include/
)

link_directories({${PROJECT_SOURCE_DIR}/build/src/)

target_link_libraries(test_util
        create_table
        pthread
        rt
)

set_target_properties(test_util
    PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/output"
        ARCHIVE_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/"
)





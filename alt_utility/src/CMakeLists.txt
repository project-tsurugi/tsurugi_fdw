add_library(create_table SHARED create_table.cpp)

target_include_directories(create_table
    PRIVATE ${PROJECT_SOURCE_DIR}/../include/
    PRIVATE ${PROJECT_SOURCE_DIR}/../../../../src/include/
    PRIVATE ${PROJECT_SOURCE_DIR}/../../third_party/ogawayama/stub/include/
)

find_library(DEPEND_LIBRALIES ogawayama-stub
    HINTS /home/k-okada/local/lib
)

target_link_libraries(create_table
        ${DEPEND_LIBRALIES}
        pthread
        rt
)

set_target_properties(create_table
    PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/output"
    ARCHIVE_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/"
)
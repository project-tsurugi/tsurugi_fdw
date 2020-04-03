# This file for testing.

add_library(common SHARED stub_connector.cpp)

find_library(ogawayama_stub_lib ogawayama-stub HINTS ${OGAWAYAMA_LIBRARY_PATH})
message(${ogawayama_stub_lib})

target_include_directories(common
    PRIVATE ${POSTGRESQL_INCLUDE_PATH}  # PostgreSQL
    PRIVATE ${COMMON_INCLUDE_PATH}      # common
    PRIVATE ${OGAWAYAMA_INCLUDE_PATH}   # ogawayama
)

target_link_libraries(common
    ${ogawayama_stub_lib}
)

# This file for testing.

add_library(alt_utility SHARED create_table.cpp tablecmds.cpp)

find_library(manager_lib metadata HINTS ${MANAGER_LIBRARY_PATH})
message(${manager_lib})
find_library(ogawayama_stub_lib ogawayama-stub HINTS ${OGAWAYAMA_LIBRARY_PATH})
message(${ogawayama_stub_lib})

target_include_directories(alt_utility
    PRIVATE ${POSTGRESQL_INCLUDE_PATH}  # PostgreSQL
    PRIVATE ${COMMON_INCLUDE_PATH}      # common
    PRIVATE ${ALT_UTILITY_INCLUDE_PATH} # aly_utility
    PRIVATE ${OGAWAYAMA_INCLUDE_PATH}   # ogawayama
    PRIVATE ${MANAGER_INCLUDE_PATH}     # manager
)

target_link_libraries(alt_utility
    common
    ${manager_lib}
    ${ogawayama_stub_lib}
)

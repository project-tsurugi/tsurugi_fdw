add_library(alt_utility SHARED create_table.cpp)

#find_package(ogawayama REQUIRED)
#find_package(manager REQUIRED)

find_library(manager_lib metadata HINTS ${MANAGER_LIBRARY_PATH})
message(${manager_lib})
find_library(ogawayama_stub_lib ogawayama-stub HINTS ${OGAWAYAMA_LIBRARY_PATH})
message(${ogawayama_stub_lib})

target_include_directories(alt_utility
    PRIVATE ${PROJECT_SOURCE_DIR}/../../../../src/include # PostgreSQL
    PRIVATE ${ALT_UTILITY_DIR} # aly_utility
    PRIVATE ${OGAWAYAMA_INCLUDE_PATH} #ogawayama
    PRIVATE ${MANAGER_INCLUDE_PATH} # manager
)

target_link_libraries(alt_utility
    ${manager_lib}
    ${ogawayama_stub_lib}
)

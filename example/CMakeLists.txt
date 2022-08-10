
set(package_name "manager_example")
set(export_name "manager_example")

# Add an executable
add_executable(manager_example main.cpp oltp_receiver.cpp worker.cpp)
find_package(manager REQUIRED)
target_link_libraries(manager_example
    PRIVATE manager-metadata
    PRIVATE manager-message
)

target_include_directories(manager_example
    PRIVATE 
        ${CMAKE_CURRENT_SOURCE_DIR}/../include
)

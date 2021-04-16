cmake_minimum_required(VERSION 3.10)

# set the project name
project(zetasql-sample)

include_directories(
    include
)

link_directories(
    lib
    )


add_executable(resolved_ast_test resolved_ast_test.cc)
target_link_libraries(resolved_ast_test zetasql)

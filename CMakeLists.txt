cmake_minimum_required(VERSION 3.10)
SET(CMAKE_CXX_FLAGS "-g -Wall -std=c++17")
set(CMAKE_CXX_STANDARD 17)

# set the project name
project(zetasql-sample)

include_directories(
    /usr/local/include
    include/
    zetasql/bazel-bin/bazel/copy_m4/m4/include
    zetasql/bazel-bin/bazel/copy_flex/flex/include
    zetasql/bazel-bin/bazel/
    zetasql/bazel-bin/external/icu/copy_icu/icu/include
)

link_directories(
    lib
    /usr/local/lib
    lib-external
    zetasql/bazel-bin/bazel/copy_flex/flex/lib
)


add_executable(resolved_ast_test resolved_ast_test.cc)
target_link_libraries(resolved_ast_test zetasql protobuf)

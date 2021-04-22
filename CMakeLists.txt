cmake_minimum_required(VERSION 3.10)
set(CMAKE_CXX_FLAGS
    "-g -Wall -std=c++1z -Wno-char-subscripts -Wno-return-type -Wno-sign-compare -Wno-switch -Wno-unused-but-set-parameter -Wno-unused-function -Wnonnull-compare"
)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# set the project name
project(zetasql-sample)

find_package(absl REQUIRED)
find_package(GTest CONFIG REQUIRED)
list(
  APPEND
  ABSL_LIBS
  absl::algorithm
  absl::base
  absl::debugging
  absl::flat_hash_map
  absl::flags
  absl::flags_parse
  absl::memory
  absl::meta
  absl::numeric
  absl::random_random
  absl::strings
  absl::synchronization
  absl::time
  absl::status
  absl::utility)

list(APPEND ICU_LIBS icui18n icuio icuuc icudata)

include_directories(
  ${CMAKE_SOURCE_DIR}/include
  ${CMAKE_SOURCE_DIR}zetasql/bazel-bin/bazel/copy_m4/m4/include
  ${CMAKE_SOURCE_DIR}zetasql/bazel-bin/bazel/copy_flex/flex/include
  /usr/local/include)
link_directories(
  ${CMAKE_SOURCE_DIR}/lib /usr/local/lib ${CMAKE_SOURCE_DIR}/lib-external
  ${CMAKE_SOURCE_DIR}/zetasql/bazel-bin/bazel/copy_flex/flex/lib)


link_libraries(
  zetasql
  zetasql_public_templated_sql_tvf
  zetasql
  re2
  ${ICU_LIBS}
  protobuf
  ${ABSL_LIBS}
  GTest::gtest
  GTest::gmock
  timeofday_proto
  date_proto)

add_executable(resolved_ast_test resolved_ast_test.cc)

add_executable(resolver_test resolver_test.cc)

add_executable(analyzer_test analyzer_test.cc)

add_executable(parse_tree_test parse_tree_test.cc)

cmake_minimum_required(VERSION 3.10)

# set the project name
project(zetasql-sample VERSION 0.1.0)

set(CMAKE_CXX_FLAGS
    "-g -Wall -Wno-char-subscripts -Wno-return-type -Wno-sign-compare -Wno-switch -Wno-unused-but-set-parameter -Wno-unused-function -Wnonnull-compare"
)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(CMAKE_BUILD_TYPE Release)


# Prefer our bundled versions of dependencies.
if(DEFINED ENV{DEPS_BUILD_DIR})
  set(DEPS_PREFIX "$ENV{DEPS_BUILD_DIR}" CACHE PATH "Path prefix for finding dependencies")
else()
  set(DEPS_PREFIX "${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/usr" CACHE PATH "Path prefix for finding dependencies")
  # When running from within CLion or Visual Studio,
  # build bundled dependencies automatically.
  if(NOT EXISTS ${DEPS_PREFIX})
    message(STATUS "Building dependencies...")
    set(DEPS_BUILD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/build)
    file(MAKE_DIRECTORY ${DEPS_BUILD_DIR})
    execute_process(
      COMMAND ${CMAKE_COMMAND} -G ${CMAKE_GENERATOR}
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
        -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
        -DCMAKE_C_FLAGS_DEBUG=${CMAKE_C_FLAGS_DEBUG}
        -DCMAKE_C_FLAGS_MINSIZEREL=${CMAKE_C_FLAGS_MINSIZEREL}
        -DCMAKE_C_FLAGS_RELWITHDEBINFO=${CMAKE_C_FLAGS_RELWITHDEBINFO}
        -DCMAKE_C_FLAGS_RELEASE=${CMAKE_C_FLAGS_RELEASE}
        -DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}
        ${PROJECT_SOURCE_DIR}/thirdparty
      WORKING_DIRECTORY ${DEPS_BUILD_DIR})
    execute_process(
      COMMAND ${CMAKE_COMMAND} --build ${DEPS_BUILD_DIR} --config ${CMAKE_BUILD_TYPE})
  endif()
endif()

set(CMAKE_PREFIX_PATH ${DEPS_PREFIX})

find_package(absl REQUIRED)
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
  ${DEPS_PREFIX}/include
  ${CMAKE_SOURCE_DIR}zetasql/bazel-bin/bazel/copy_m4/m4/include
  ${CMAKE_SOURCE_DIR}zetasql/bazel-bin/bazel/copy_flex/flex/include
  )
link_directories(
  ${DEPS_PREFIX}/lib
  ${CMAKE_SOURCE_DIR}/zetasql/bazel-bin/bazel/copy_flex/flex/lib)


find_package(GTest REQUIRED)
set(Protobuf_USE_STATIC_LIBS ON)
find_package(Protobuf 3.6 EXACT REQUIRED)

link_libraries(
  zetasql
  zetasql_public_templated_sql_tvf
  zetasql
  re2
  ${ICU_LIBS}
  ${Protobuf_LIBRARIES}
  ${ABSL_LIBS}
  ${GTEST_LIBRARIES}
  gmock
  timeofday_proto
  date_proto)

add_executable(resolved_ast_test resolved_ast_test.cc)

add_executable(resolver_test resolver_test.cc)

add_executable(analyzer_test analyzer_test.cc)

add_executable(parse_tree_test parse_tree_test.cc)

add_executable(like_test like_test.cc)

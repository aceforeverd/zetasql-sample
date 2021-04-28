cmake_minimum_required(VERSION 3.10)

# set the project name
project(zetasql-sample VERSION 0.1.0)
set(CMAKE_CXX_FLAGS
    "-g -Wall -Wno-char-subscripts -Wno-return-type -Wno-sign-compare -Wno-switch -Wno-unused-but-set-parameter -Wno-unused-function -Wnonnull-compare"
)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(CMAKE_PREFIX_PATH "${CMAKE_SOURCE_DIR}/thirdparty")
set(DEPS_PREFIX "${CMAKE_SOURCE_DIR}/thirdparty")
set(DEPS_BUILD_DIR
    "${CMAKE_SOURCE_DIR}/.deps/build"
    CACHE PATH "Dependencies build directory.")
set(DEPS_DOWNLOAD_DIR
    "${DEPS_BUILD_DIR}/downloads"
    CACHE PATH "Dependencies download directory.")

list(APPEND CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH}
     ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
message(STATUS "PROJECT_SOURCE_DIR ${PROJECT_SOURCE_DIR}")
include(ExternalProject)

find_program(MAKE_EXE NAMES gmake nmake make)
ExternalProject_Add(
  protobuf
  URL https://github.com/protocolbuffers/protobuf/archive/v3.6.1.3.tar.gz
  URL_HASH
    SHA256=73fdad358857e120fd0fa19e071a96e15c0f23bb25f85d3f7009abfd4f264a2a
  PREFIX ${DEPS_BUILD_DIR}
  DOWNLOAD_DIR ${DEPS_DOWNLOAD_DIR}/protobuf
  INSTALL_DIR ${CMAKE_SOURCE_DIR}/thirdparty
  BUILD_IN_SOURCE True
  CONFIGURE_COMMAND ./autogen.sh && ./configure --prefix ${DEPS_PREFIX}
                    --enable-shared=false CXXFLAGS=-std=c++11
  BUILD_COMMAND ${MAKE_EXE} -j$(nproc)
  INSTALL_COMMAND ${MAKE_EXE} install)

include_directories(${DEPS_PREFIX}/include)
link_directories(${DEPS_PREFIX}/lib)
set(absl_DIR ${DEPS_PREFIX})
find_package(absl REQUIRED)
list(
  APPEND
  ABSL_LIBS
  absl::algorithm
  absl::base
        absl::cord
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
list(APPEND file_based_test_driver_LIBS
    alternations
    test_case_options
    test_case_outputs
    file_based_test_driver
    test_case_mode
    logging
    path
    status
    unified_diff_oss
    ret_check
    )

set(GTest_DIR ${DEPS_PREFIX}/gtest)
find_package(GTest 1.10 EXACT REQUIRED)
set(Protobuf_USE_STATIC_LIBS ON)
find_package(Protobuf 3.6 EXACT REQUIRED)
link_libraries(
  zetasql
  re2
  ${ICU_LIBS}
  ${Protobuf_LIBRARIES}
  ${ABSL_LIBS}
  ${GTEST_LIBRARIES}
  gmock
  date_proto)

add_executable(parse_tree_test parse_tree_test.cc)
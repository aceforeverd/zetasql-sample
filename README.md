# zetasql-sample

cmake sampel project integrated zetasql

## zetasql external dependency management

### protobuf

- source locate: `$HOME/.cache/bazel/$bazel_user/$digest/external/com_google_protobuf`
- header: /usr/local/include/google/protobuf
- libs: ./lib-external
- command:
  ```bash
  ./autogen.sh
  ./configure --prefix /usr/local --with-pic CXXFLAGS=-std=c++17
  make && make install
  ```

### absl

- source locate: `$HOME/.cache/bazel/$bazel_user/$digest/external/com_google_absl`
- header: `/usr/local/include/absl`
- command:
  ```bash
  cmake -H. -Bbuild \
      -DCMAKE_C_FLAGS:STRING="-std=c++17" \
      -DCMAKE_CXX_FLAGS:STRING="${CXXFLAGS}" \
      -DCMAKE_EXE_LINKER_FLAGS:STRING="${LDFLAGS}" \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_INSTALL_PREFIX=/usr/local \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_STANDARD=17 \
      -DABSL_USE_GOOGLETEST_HEAD=OFF \
      -DABSL_RUN_TESTS=OFF \
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON
  pushd build
  make -j$(nproc)
  sudo make install
  popd
  ```

### icu

+ we need things like icudt65_dat except includes and libs
+ need use `ar_wrapper` instead of `ar` to compile
+ icudata should placed after icuuc

### google test

- source locate: `$HOME/.cache/bazel/$bazel_user/$digest/external/com_google_googletest`
- compile: refer (arch googletest)[https://github.com/archlinux/svntogit-community/blob/packages/gtest/trunk/PKGBUILD]
  ```bash
  rm -rf build
  cmake -H. -Bbuild \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DBUILD_SHARED_LIBS=ON \
    -Dgtest_build_tests=ON \
    -DCMAKE_CXX_FLAGS=-std=c++17
  ```

   pushd build
   make -j$(nproc)
   sudo make install
   popd
   ```

### googleapi
+ need: timeofday_proto date_proto

### re2
+ commit: d1394506654e0a19a92f3d8921e26f7c3f4de969
+ command: `find re2 -iname "*.h" -exec install -D {} /usr/local/include/{} \;`

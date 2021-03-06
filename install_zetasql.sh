#!/bin/bash

# install zetasql compiled header files and libs

set -eE

cd "$(dirname "$0")"
export ROOT=$(realpath .)
export PREFIX="$ROOT/thirdparty/usr"

rm -rf tmp-lib libzetasql.mri
mkdir -p tmp-lib

install_lib() {
    local file
    file=$1
    local libname
    libname=lib$(echo "$file" | tr '/' '_' | sed -e 's/lib//')
    install -D "$file" "$ROOT/tmp-lib/$libname"
}

install_gen_include_file() {
    local file
    file=$1
    local outfile
    outfile=$(echo "$file" | sed -e 's/^.*proto\///')
    install -D "$file" "$ROOT/thirdparty/usr/include/$outfile"
}

install_external_lib() {
    local file
    file=$1
    local libname
    libname=$(basename "$file")
    install -D "$file" "$PREFIX/lib/$libname"
}

export -f install_gen_include_file
export -f install_lib
export -f install_external_lib

pushd zetasql/bazel-bin/
# exlucde test so
find zetasql -maxdepth 4 -type f -iname '*.so' -exec bash -c 'install_lib $0' {} \;
find zetasql -type f -iname '*.a' -exec bash -c 'install_lib $0' {} \;

# external lib headers
pushd "$(realpath .)/../../../../../external/com_googlesource_code_re2"
find re2 -iname "*.h" -exec install -D {} "$PREFIX"/include/{} \;
popd

# external lib
pushd external
find icu -type f -iregex ".*/.*\.\(so\|a\)\$" -exec bash -c 'install_external_lib $0' {} \;
find com_googlesource_code_re2 -type f -iregex ".*/.*\.\(so\|a\)\$" -exec bash -c 'install_external_lib $0' {} \;
find com_googleapis_googleapis -type f -iname '*.so' -exec bash -c 'install_external_lib $0' {} \;
popd

# zetasql header files: protobuf generated files
find zetasql -type f -iname "*.h" -exec install -D {} "$ROOT"/thirdparty/usr/include/{} \;
find zetasql -iregex ".*/_virtual_includes/.*\.h\$" -exec bash -c 'install_gen_include_file $0' {} \;
popd

pushd zetasql/
find zetasql -type f -iname "*.h" -exec install -D {} "$ROOT"/thirdparty/usr/include/{} \;
popd

echo 'create libzetasql.a' >> libzetasql.mri
find tmp-lib/ -iname "*.a" -type f -exec bash -c 'echo "addlib $0" >> libzetasql.mri' {} \;
echo "save" >> libzetasql.mri
echo "end" >> libzetasql.mri

ar -M <libzetasql.mri
ranlib libzetasql.a
mv libzetasql.a "$ROOT/thirdparty/usr/lib"

mv tmp-lib/libzetasql_public_templated_sql_tvf.so "$ROOT/thirdparty/usr/lib"


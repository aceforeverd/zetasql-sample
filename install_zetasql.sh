#!/bin/bash

set -eE

cd "$(dirname "$0")"
export ROOT=$(realpath .)

rm -rf lib include libzetasql.mri
mkdir -p lib include

install_lib() {
    local file
    file=$1
    local libname
    libname=$(echo "$file" | cut -c 3- | tr '/' '_')
    install -D "$file" "$ROOT/lib/$libname"
}

export -f install_lib

pushd zetasql/bazel-bin/zetasql/
find . -type f -iregex ".*/.*\.\(so\|a\)\$" -exec bash -c 'install_lib $0' {} \;
popd
pushd zetasql
find zetasql -type f -iname "*.h" -exec install -D {} $ROOT/include/{} \;
popd

echo 'create libzetasql.a' >> libzetasql.mri
find lib/ -iname "*.a" -type f -exec bash -c 'echo "addlib $0" >> libzetasql.mri' {} \;
echo -e "save\nend\n" >> libzetasql.mri

ar -M <libzetasql.mri
ranlib libzetasql.a

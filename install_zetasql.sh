#!/bin/bash

set -eE

cd "$(dirname "$0")"
export ROOT=$(realpath .)

rm -rf tmp-lib include lib libzetasql.mri lib-external libexternal.mri
mkdir -p tmp-lib include lib lib-external

install_lib() {
    local file
    file=$1
    local libname
    libname=$(echo "$file" | tr '/' '_')
    install -D "$file" "$ROOT/tmp-lib/$libname"
}

install_gen_include_file() {
    local file
    file=$1
    local outfile
    outfile=$(echo "$file" | sed -e 's/^.*proto\///')
    install -D "$file" "$ROOT/include/$outfile"
}
export -f install_gen_include_file

export -f install_lib

pushd zetasql/bazel-bin/
find zetasql -type f -iregex ".*/.*\.\(so\|a\)\$" -exec bash -c 'install_lib $0' {} \;

pushd external
find . -type f -iregex ".*/.*\.\(so\|a\)\$" -exec install -D {} "$ROOT/lib-external" \;
popd

find zetasql -type f -iname "*.h" -exec install -D {} $ROOT/include/{} \;
find zetasql -iregex ".*/_virtual_includes/.*\.h\$" -exec bash -c 'install_gen_include_file $0' {} \;
popd

pushd zetasql/
find zetasql -type f -iname "*.h" -exec install -D {} $ROOT/include/{} \;
popd

echo 'create libzetasql.a' >> libzetasql.mri
find tmp-lib/ -iname "*.a" -type f -exec bash -c 'echo "addlib $0" >> libzetasql.mri' {} \;
echo -e "save\nend\n" >> libzetasql.mri

ar -M <libzetasql.mri
ranlib libzetasql.a
mv libzetasql.a lib/


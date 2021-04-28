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
    libname=lib$(echo "$file" | tr '/' '_' | sed -e 's/lib//')
    install -cv "$file" "$ROOT/tmp-lib/$libname"
}

install_gen_include_file() {
    local file
    file=$1
    local file_dir
    file_dir=$(dirname $file)
    local outfile
    outfile=$(echo "$file" | sed -e 's/^.*proto\///')
    install -vd  "$ROOT/include/$file_dir"
    install -vc  "$file" "$ROOT/include/$outfile"
}

install_include() {
    local file
    file=$1
    local file_dir
    file_dir=$(dirname $file)
    install -vd  "$ROOT/include/$file_dir"
    install -vc  "$file" "$ROOT/include/$file"
}
export -f install_gen_include_file

export -f install_lib
export -f install_include
pushd zetasql/bazel-bin/
# exlucde test so

find zetasql -type f -iname '*.a' -exec bash -c 'install_lib $0' {} \;

pushd external
find . -type f -iname '*.a' -exec install -c {} "$ROOT/lib-external" \;
popd
find zetasql -type f -iname '*.h' -exec bash -c 'install_include $0' {} \;
# find zetasql -type d -exec install -vd $ROOT/include/{} \;
# find zetasql -type f -iname '*.h' -exec install -vc {} $ROOT/include/{} \;
find zetasql -type f -iname '*.h' -exec bash -c 'install_include $0' {} \;
find zetasql -iregex ".*/_virtual_includes/.*\.h\$" -exec bash -c 'install_gen_include_file $0' {} \;
popd

pushd zetasql/
find zetasql -type f -iname "*.h" -exec bash -c 'install_include $0' {} \;
popd

echo 'create libzetasql.a' >> libzetasql.mri
find tmp-lib/ -iname "*.a" -type f -exec bash -c 'echo "addlib $0" >> libzetasql.mri' {} \;
echo "save\nend\n" >> libzetasql.mri

ar -m <libzetasql.mri
# ranlib libzetasql.a
# mv libzetasql.a lib/

# mv tmp-lib/*.so lib/


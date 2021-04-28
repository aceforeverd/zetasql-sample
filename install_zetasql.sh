#!/bin/bash

set -eE

cd "$(dirname "$0")"
export ROOT=$(realpath .)

rm -rf tmp-lib include lib libzetasql.mri lib-external libexternal.mri
mkdir -p tmp-lib include lib lib-external

install_lib() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]
    then
        INSTALL_BIN="install"
    else
        INSTALL_BIN="/usr/local/opt/coreutils/bin/ginstall"
    fi
    local file
    file=$1
    local libname
    libname=lib$(echo "$file" | tr '/' '_' | sed -e 's/lib//')
    ${INSTALL_BIN} -D "$file" "$ROOT/tmp-lib/$libname"
}

install_gen_include_file() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]
    then
        INSTALL_BIN="install"
    else
        INSTALL_BIN="/usr/local/opt/coreutils/bin/ginstall"
    fi
    local file
    file=$1
    local outfile
    outfile=$(echo "$file" | sed -e 's/^.*proto\///')
    ${INSTALL_BIN} -D "$file" "$ROOT/include/$outfile"
}
export -f install_gen_include_file

export -f install_lib

if [[ "$OSTYPE" == "linux-gnu"* ]]
then
    INSTALL_BIN="install"
else
    INSTALL_BIN="/usr/local/opt/coreutils/bin/ginstall"
fi


pushd zetasql/bazel-bin/
# exlucde test so in linux
if [[ "$OSTYPE" == "linux-gnu"* ]]
then
find zetasql -maxdepth 4 -type f -iname '*.so' -exec bash -c 'install_lib $0' {} \;
fi

find zetasql -type f -iname '*.a' -exec bash -c 'install_lib $0' {} \;

pushd external
if [[ "$OSTYPE" == "linux-gnu"* ]]
then
    find . -type f -iregex ".*/.*\.\(so\|a\)\$" -exec ${INSTALL_BIN} -D {} "$ROOT/lib-external" \;
else
    find . -type f -iregex ".*/.*\.\(a\)\$" -exec ${INSTALL_BIN} -D {} "$ROOT/lib-external" \;
fi
popd
find zetasql -type f -iname "*.h" -exec ${INSTALL_BIN} -D {} $ROOT/include/{} \;
find zetasql -iregex ".*/_virtual_includes/.*\.h\$" -exec bash -c 'install_gen_include_file $0' {} \;
popd

pushd zetasql/
find zetasql -type f -iname "*.h" -exec ${INSTALL_BIN} -D {} $ROOT/include/{} \;
popd

pushd zetasql/bazel-zetasql/external

pushd com_googlesource_code_re2
find re2 -type f -iname "*.h" -exec ${INSTALL_BIN} -D {} $ROOT/include/{} \;
popd

pushd com_googleapis_googleapis
find google -type f -iname "*.h" -exec ${INSTALL_BIN} -D {} $ROOT/include/{} \;
popd

pushd com_google_file_based_test_driver
find file_based_test_driver -type f -iname "*.h" -exec ${INSTALL_BIN} -D {} $ROOT/include/{} \;
popd

popd


if [[ "$OSTYPE" == "linux-gnu"* ]]
then
    echo 'create libzetasql.a' >> libzetasql.mri
    find tmp-lib/ -iname "*.a" -type f -exec bash -c 'echo "addlib $0" >> libzetasql.mri' {} \;
    echo "save" >> libzetasql.mri
    echo "end" >> libzetasql.mri
    ar -M <libzetasql.mri
    RANLIB_BIN libzetasql.a  
else
    libtool -static -o libzetasql.a tmp-lib/*.a
fi
mv libzetasql.a lib/


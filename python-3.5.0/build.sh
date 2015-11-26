#!/bin/bash

#rm -rf Lib/test Lib/*/test

if [ `uname` = Darwin ]; then
    export CFLAGS="-I$PREFIX/include $CFLAGS"
    export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
    $REPLACE "@OSX_ARCH@" "'$OSX_ARCH'" Lib/distutils/unixccompiler.py
    export CC=gcc-4.2
    export CXX=gcc-4.2
fi

PYTHON_BAK=$PYTHON
unset PYTHON

# XXX pip can fail installing because of https://bugs.python.org/issue24418

./configure --enable-shared --enable-ipv6 --with-ensurepip=upgrade \
    --prefix=$PREFIX
make -j4
make install

export PYTHON=$PYTHON_BAK

if [ `uname` == Darwin ]; then
    DYNLOAD_DIR=$STDLIB_DIR/lib-dynload
    rm $DYNLOAD_DIR/_hashlib_failed.so
    rm $DYNLOAD_DIR/_ssl_failed.so
    rm $DYNLOAD_DIR/_sqlite3_failed.so
    rm $DYNLOAD_DIR/_tkinter_failed.so
    pushd Modules
    rm -rf build
    cp $RECIPE_DIR/setup_misc.py .
    $PYTHON setup_misc.py build
    cp build/lib.macosx-*/_hashlib.so \
       build/lib.macosx-*/_ssl.so \
       build/lib.macosx-*/_sqlite3.so \
       build/lib.macosx-*/_tkinter.so \
           $DYNLOAD_DIR
    popd
    pushd $DYNLOAD_DIR
    mv readline_failed.so readline.so
    popd
    $REPLACE gcc-4.2 gcc \
        $STDLIB_DIR/_sysconfigdata.py \
        $STDLIB_DIR/config-3.4m/Makefile
fi

cd $PREFIX/bin
ln -s python3 python

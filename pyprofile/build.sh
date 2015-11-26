#!/bin/bash

#rm -rf Lib/test Lib/*/test

if [ `uname` == Darwin ]; then
    export CFLAGS="-I$PREFIX/include $CFLAGS"
    export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
    $REPLACE "@OSX_ARCH@" "'$OSX_ARCH'" Lib/distutils/unixccompiler.py
fi

PYTHON_BAK=$PYTHON
unset PYTHON


if [ `uname` == Darwin ]; then
    ./configure --enable-shared --enable-ipv6 --with-ensurepip=no \
        --prefix=$PREFIX
fi
if [ `uname` == Linux ]; then
    FLTO="-flto -O3 -fuse-linker-plugin"
    ./configure --enable-shared --enable-ipv6 --with-ensurepip=no \
        --prefix=$PREFIX \
        --with-tcltk-includes="-I$PREFIX/include" \
        --with-tcltk-libs="-L$PREFIX/lib -ltcl8.5 -ltk8.5" \
        CFLAGS="$FLTO" \
        CPPFLAGS="-I$PREFIX/include" \
        LDFLAGS="-L$PREFIX/lib -Wl,-rpath=$PREFIX/lib,--no-as-needed $FLTO"
fi


# The following is basically "make profile-opt", but with additional
# flexibility if you want to add e.g. "-j4" when building

# Tests to exclude from the profiling run (too slow, or crashy)
EXCLUDE_TESTS="test_gdb test_subprocess test_faulthandler \
    test_multiprocessing test_multiprocessing_fork \
    test_multiprocessing_forkserver test_multiprocessing_spawn \
    test_multiprocessing_main_handling test_signal \
    test_concurrent_futures"

PROFILE_TASK="-m test.regrtest -w -uall,-audio -x $EXCLUDE_TESTS"

# Build with support for profile generation
make -j4 build_all_generate_profile
# Run workload to generate profile data
# Errors in the test suite are ignored
make run_profile_task PROFILE_TASK="$PROFILE_TASK" || true
# Rebuild with profile guided optimizations
make clean
make -j4 build_all_use_profile

# End "make profile-opt"

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
    mv _lzma_failed.so _lzma.so
    popd
fi
# if [ $CC != "gcc" ]; then
#     $REPLACE $CC gcc $STDLIB_DIR/_sysconfigdata.py \
#         $STDLIB_DIR/config-3.5m/Makefile
#     $REPLACE $CXX g++ $STDLIB_DIR/_sysconfigdata.py \
#         $STDLIB_DIR/config-3.5m/Makefile
# fi
#
# $REPLACE '-Werror=declaration-after-statement' '' \
#     $PREFIX/lib/python3.5/_sysconfigdata.py \
#     $PREFIX/lib/python3.5/config-3.5m/Makefile

cd $PREFIX/bin
ln -s python3.5 python
ln -s pydoc3.5 pydoc

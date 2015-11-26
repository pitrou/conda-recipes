#!/bin/bash

cp $RECIPE_DIR/test_fft.py numpy/fft/tests

if [ $PRO == 1 ]
then # MKL
    LLC=numpy/linalg/lapack_litemodule.c
    $REPLACE "/*MARK1*/" "@INIT_ANACONDA@"  $LLC || exit 1
    $REPLACE "/*MARK2*/" "init_anaconda();" $LLC || exit 1
    $SYS_PREFIX/bin/insert_license --insert=$LLC -pm || exit 1

    $REPLACE '$MKL_VERSION' "'$MKL_VERSION'" numpy/__init__.py

    if [ `uname` == Darwin ]; then
        export ATLAS=1
    fi
    SITE_CFG="site-mkl-$SUBDIR.cfg"

else # Non-MKL
#     if [[ (`uname` == Linux) && (`uname -m` != armv6l) ]]; then
#         SITE_CFG="site-atlas-linux.cfg"
#     else
        SITE_CFG="site-empty.cfg"
#     fi
fi

# sed -e "s,@PREFIX@,$PREFIX," <$FILES_DIR/numpy/$SITE_CFG >site.cfg
# sed -e "s,@PREFIX@,$PREFIX," <$RECIPE_DIR/$SITE_CFG >site.cfg

# if [ ! -f site.cfg ]; then
#     echo "ERROR: *** site.cfg missing ***"
#     exit 1
# fi

$PYTHON setup.py install || exit 1

if [ $PY3K == 1 ]; then
    rm -f $PREFIX/bin/f2py
fi

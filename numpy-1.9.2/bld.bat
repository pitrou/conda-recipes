set LLC=numpy\linalg\lapack_litemodule.c

if "%PRO%"=="1" (
    if "%PY_VER%"=="3.4" (
       %REPLACE% "mfinfo = self.manifest_g" "mfinfo = None #" %PREFIX%\Lib\distutils\msvc9compiler.py
       if errorlevel 1 exit 1
    )

    %REPLACE% /*MARK1*/ "@INIT_ANACONDA@" %LLC%
    if errorlevel 1 exit 1
    %REPLACE% /*MARK2*/ "init_anaconda();" %LLC%
    if errorlevel 1 exit 1
    %SYS_PREFIX%\Scripts\insert_license --insert %LLC% -pm
    if errorlevel 1 exit 1

    echo __mkl_version__ = '%MKL_VERSION%' >> numpy\__init__.py
    if errorlevel 1 exit 1

    copy %FILES_DIR%\numpy\site-mkl-%SUBDIR%.cfg site.cfg
    if errorlevel 1 exit 1

    %REPLACE% @PREFIX@ %PREFIX% site.cfg
    if errorlevel 1 exit 1

    python setup.py install
    if errorlevel 1 exit 1

) else (
    rd /s /q %SP_DIR%
    move %SRC_DIR%\Lib\site-packages %STDLIB_DIR%

    patch -d %SP_DIR% -p0 -i %RECIPE_DIR%\mklfft.patch

    mkdir %SCRIPTS%
    move %SRC_DIR%\Scripts\f2py.py %SCRIPTS%\f2py
)

copy %RECIPE_DIR%\test_fft.py %SP_DIR%\numpy\fft\tests\
if errorlevel 1 exit 1

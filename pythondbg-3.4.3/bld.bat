REM ========== prepare source

if "%ARCH%"=="64" (
    set DMSW=-DMS_WIN64
    set PCB=%SRC_DIR%\PCbuild\amd64
) else (
    set DMSW=
    set PCB=%SRC_DIR%\PCbuild
)

%REPLACE% "@DMSW@" "%DMSW%" Lib\distutils\cygwinccompiler.py
if errorlevel 1 exit 1

REM ========== actual compile step

msbuild PCbuild\pcbuild.sln /t:build /p:Configuration=Debug

REM ========== add stuff from official python.org msi

set MSI_DIR=\Pythons\3.4.1-%ARCH%
for %%x in (DLLs Doc libs tcl Tools) do (
    xcopy /s %MSI_DIR%\%%x %PREFIX%\%%x\
    if errorlevel 1 exit 1
)
copy %MSI_DIR%\LICENSE.txt %PREFIX%\LICENSE_PYTHON.txt
if errorlevel 1 exit 1

REM ========== add stuff from our own build

xcopy /s %SRC_DIR%\Include %PREFIX%\include\
if errorlevel 1 exit 1
copy %SRC_DIR%\PC\pyconfig.h %PREFIX%\include\
if errorlevel 1 exit 1

REM XXX python34.dll only seems to exist in release builds?
for %%x in (python34.dll python_d.exe pythonw_d.exe) do (
    copy %PCB%\%%x %PREFIX%
    if errorlevel 1 exit 1
)
copy %PCB%\python34.lib %PREFIX%\libs\
if errorlevel 1 exit 1
del %PREFIX%\libs\libpython*.a

xcopy /s %SRC_DIR%\Lib %PREFIX%\Lib\
if errorlevel 1 exit 1

REM ========== bytecode compile standard library

rd /s /q %STDLIB_DIR%\lib2to3\tests\
if errorlevel 1 exit 1

%PYTHON% -Wi %STDLIB_DIR%\compileall.py -f -q -x "bad_coding|badsyntax|py2_" %STDLIB_DIR%
if errorlevel 1 exit 1

REM ========== add idle script

mkdir %SCRIPTS%
if errorlevel 1 exit 1
copy %SRC_DIR%\Tools\scripts\idle3 %SCRIPTS%\idle
if errorlevel 1 exit 1

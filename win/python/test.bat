@echo off
setlocal enabledelayedexpansion

rem Set variables
set ARG=%*
set SHELL_DIR=%~dp0
set SHELL_DIR=%SHELL_DIR:"=%
set RESULT_DIR=%SHELL_DIR%result
set SOURCE_DIR=%SHELL_DIR%cubrid-python
set GIT_PATH=C:\Program Files\Git\bin\git.exe
set FIRST_VERSION_FILE=%SOURCE_DIR%\VERSION
set SECOND_VERSION_FILE=%SOURCE_DIR%\VERSION
set MAJOR_START_DATE=2017-06-27

REM set PYTHON_EXECUTE_END=6
REM set PYTHON_EXECUTE[0]=C:\python\python26\python.exe
REM set PYTHON_EXECUTE[1]=C:\python\python27\python.exe
REM set PYTHON_EXECUTE[2]=C:\python\python30\python.exe
REM set PYTHON_EXECUTE[3]=C:\python\python31\python.exe
REM set PYTHON_EXECUTE[4]=C:\python\python32\python.exe
REM set PYTHON_EXECUTE[5]=C:\python\python36\python.exe
REM set /a PYTHON_COUNT=0

set PYTHON_EXECUTE_END=2
set PYTHON_EXECUTE[0]=C:\python\python27\python.exe
set PYTHON_EXECUTE[1]=C:\python\python36\python.exe
set /a PYTHON_COUNT=0

set BUILD_FOLDERS=lib.win-amd64-2.6 lib.win-amd64-2.7 lib.win-amd64-3.0 lib.win-amd64-3.1 lib.win-amd64-3.2 lib.win-amd64-3.6

:main
echo "SOURCE DIR %SOURCE_DIR%"

if not "%ARG%"=="" (
    if "%ARG%"=="-h" (
        call :show_usage
        exit /b 0
    )
    if "%ARG%"=="-test" (
        echo "only test the software"
        goto test
    )
)

if not exist "%GIT_PATH%" (
    echo [ERROR] Git not found
    exit /b 1
)

rem Initialize temp directory
if exist "%SOURCE_DIR%" (
    rmdir /s /q "%SOURCE_DIR%"
)

echo "source download"
"%GIT_PATH%" clone git@github.com:hwany7seo/cubrid-python.git -b new_windows_release_test --recursive

echo "Handle commit ID if provided"
if not "%ARG%"=="" (
    echo [CHECK] input commit id: %ARG%
    cd /D "%SOURCE_DIR%"
    "%GIT_PATH%" reset --HARD %ARG%
    "%GIT_PATH%" submodule update
)

if exist "%FIRST_VERSION_FILE%" (
    echo [CHECK] 1st version file: %FIRST_VERSION_FILE%
    for /f "usebackq tokens=*" %%a in ("%FIRST_VERSION_FILE%") do set VERSION=%%a
) else if exist "%SECOND_VERSION_FILE%" (
    echo [CHECK] 2nd version file: %SECOND_VERSION_FILE%
    for /f "usebackq tokens=*" %%a in (%SECOND_VERSION_FILE%) do set VERSION=%%a
) else (
    echo [ERROR] Version file not found
    exit /b 1
)

:build_env
echo "Execute ENV Batch For Windows"
call "%SOURCE_DIR%\env_windows.bat"

:build_install
rem Driver Build
cd /d "%SOURCE_DIR%"
if %PYTHON_COUNT% lss %PYTHON_EXECUTE_END% (
    echo "Driver Build"
    set "PYTHON_EXE=!PYTHON_EXECUTE[%PYTHON_COUNT%]!"
    echo "BUILD !PYTHON_EXE!"
    call "!PYTHON_EXE!" setup.py build
    call "!PYTHON_EXE!" setup.py install
    set /a PYTHON_COUNT+=1
    goto build_install
)
set /a PYTHON_COUNT=0

:test
rem Driver Test
cd /d "%SOURCE_DIR%\tests"
if %PYTHON_COUNT% lss %PYTHON_EXECUTE_END% (
    echo "Driver Test"
    set "PYTHON_EXE=!PYTHON_EXECUTE[%PYTHON_COUNT%]!"
    echo "BUILD !PYTHON_EXE!"
    call "!PYTHON_EXE!" test_cubrid.py
    call "!PYTHON_EXE!" test_CUBRIDdb.py
    if exist %RESULT_DIR%\%PYTHON_COUNT% (
        rmdir /s /q "%RESULT_DIR%\%PYTHON_COUNT%"
        mkdir "%RESULT_DIR%\%PYTHON_COUNT%"
    ) else (
        mkdir "%RESULT_DIR%\%PYTHON_COUNT%"
    )
    cp -f test_cubrid.result test_CUBRIDdb.result "%RESULT_DIR%\%PYTHON_COUNT%"
    set /a PYTHON_COUNT+=1
    goto test
)


exit /b 0

:show_usage
echo Usage: %0 [OPTIONS or Commit-ID]
echo Note. For Python Driver Release
echo.
echo OPTIONS
echo   -? ^| -h Show this help message and exit
echo.
echo Commit-ID
echo Command) git reset --hard [Commit-ID]
echo           git submodule update
echo.
echo EXAMPLES
echo   %0                                           # Compress
echo   %0 a6ae44b76dc283bd74c555fef1585ed0ec7dc470  # Git Reset, Submodule Update and Compress
exit /b 1


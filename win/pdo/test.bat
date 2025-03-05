@echo off

set SHELL_PATH=%~dp0
set arg1=%1
set arg2=%2

echo "Test Env File Copy (%SHELL_PATH%connect.inc) To (%arg2%)"
copy /y "%SHELL_PATH%pdo_test.inc" "%arg2%"

cd %arg2%
echo "arg2 : %arg2%"
echo "SHELL_PATH : %SHELL_PATH%"

set TEST_PHP_EXECUTABLE=%arg1%

echo "TEST_PHP_EXECUTABLE : %TEST_PHP_EXECUTABLE%"

%TEST_PHP_EXECUTABLE% %arg2%run-tests.php %arg2%*.phpt

cd %SHELL_PATH%

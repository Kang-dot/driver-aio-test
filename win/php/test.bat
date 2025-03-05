@echo off

set SHELL_PATH=%~dp0
set arg1=%1
set arg2=%2
set arg3=%3

cd %arg2%
echo "arg2 : %arg2%"
echo "arg3 : %arg3%"
echo "SHELL_PATH : %SHELL_PATH%"

set TEST_PHP_EXECUTABLE=%arg1%

echo "TEST_PHP_EXECUTABLE : %TEST_PHP_EXECUTABLE%"

if "%arg3%"=="test2" (
  echo "Test2 Env File Copy (%SHELL_PATH%connect.inc) To (%arg2%)"
  copy /y "%SHELL_PATH%connect_test2.inc" "%arg2%connect.inc"
  copy /y "%SHELL_PATH%connectLarge.inc" "%arg2%"
  echo "Execute Tests2"
  %arg2%choseRunCases.bat -R %TEST_PHP_EXECUTABLE%
) ELSE (
  echo "Test1 Env File Copy (%SHELL_PATH%connect.inc) To (%arg2%)"
  copy /y "%SHELL_PATH%connect.inc" "%arg2%connect.inc"
  echo "Execute Tests1"
  %TEST_PHP_EXECUTABLE% %arg2%run-tests.php %arg2%*.phpt
)

cd %SHELL_PATH%

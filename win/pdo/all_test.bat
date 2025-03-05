@echo off

set SHELL_PATH=%~dp0
set LIB_PATH=%PDO_LIB%
set DEVEL_PACK_PATH=%PDO_LIB%\devel-pack
set SOURCE_DIR_PHP_56=%SHELL_PATH%cubrid-pdo-5-6\tests\
set SOURCE_DIR_PHP_71=%SHELL_PATH%cubrid-pdo-7-1\tests_7\
set SOURCE_DIR_PHP_74=%SHELL_PATH%cubrid-pdo-7-4\tests_74\

set RESULT_FILE_56=%SHELL_PATH%result\result_php56
set RESULT_FILE_71=%SHELL_PATH%result\result_php71
set RESULT_FILE_74=%SHELL_PATH%result\result_php74

IF "%1"=="" (
        echo "usage: %0 PHP_VERSION <e.g.: php-5.6| php-7.1| php-7.4>"
        GOTO exit
)

echo SHELL_PATH %SHELL_PATH%

for /F "tokens=2 delims=0-" %%f in ("%1") do for /F "tokens=1 delims=1." %%g in ("%%f") do set PHP_MAJOR_VERSION=%%g
for /F "tokens=2 delims=0-" %%f in ("%1") do for /F "tokens=2 delims=2." %%g in ("%%f") do set PHP_MINOR_VERSION=%%g

IF NOT EXIST "%SHELL_PATH%result" (
  mkdir %SHELL_PATH%result
)

IF "%PHP_MAJOR_VERSION%"=="5" (
  echo "Testing php-5.6-ts-x64"
  call "%SHELL_PATH%test.bat" %LIB_PATH%\php-5.6.31-Win32-vc11-x64\php.exe %SOURCE_DIR_PHP_56% | tee %RESULT_FILE_56%
  echo "Testing php-5.6-nts-x64"
  call "%SHELL_PATH%test.bat" %LIB_PATH%\php-5.6.31-nts-Win32-vc11-x64\php.exe %SOURCE_DIR_PHP_56% | tee %RESULT_FILE_56%
  echo "End Test Result is : %RESULT_FILE_56%"
) ELSE (
  IF "%PHP_MINOR_VERSION%"=="1" (
    echo "Testing php-7.1-ts-x64"
    call %SHELL_PATH%test.bat %LIB_PATH%\php-7.1.8-Win32-vc14-x64\php.exe %SOURCE_DIR_PHP_71% > %RESULT_FILE_71%
    echo "Testing php-7.1-nts-x64"
    call %SHELL_PATH%test.bat %LIB_PATH%\php-7.1.8-nts-Win32-vc14-x64\php.exe %SOURCE_DIR_PHP_71% >> %RESULT_FILE_71%
    echo "End Test Result is : %RESULT_FILE_71%"
  ) ELSE IF "%PHP_MINOR_VERSION%"=="4" (
    echo "Testing php-7.4-ts-x64"
    call %SHELL_PATH%test.bat %LIB_PATH%\php-7.4.2-Win32-vc15-x64\php.exe %SOURCE_DIR_PHP_74% | tee %RESULT_FILE_74%
    echo "Testing php-7.4-nts-x64"
    call %SHELL_PATH%test.bat %LIB_PATH%\php-7.4.2-nts-Win32-vc15-x64\php.exe %SOURCE_DIR_PHP_74% | tee %RESULT_FILE_74%
    echo "End Test Result is : %RESULT_FILE_74%"
  )
)

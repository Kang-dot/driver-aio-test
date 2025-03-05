@echo off

set SHELL_PATH=%~dp0
set ARG=

IF "%1"=="" (
  echo "usage: %0 PHP_VERSION <e.g.: php-5.6| php-7.1| php-7.4>"
  GOTO exit
) ELSE IF "%1"=="all" (
  set ARG=php-5.6
  goto run_test
) ELSE (
  set ARG=%1
)

:run_test
for /F "tokens=2 delims=0-" %%f in ("%ARG%") do for /F "tokens=1 delims=1." %%g in ("%%f") do set PHP_MAJOR_VERSION=%%g
for /F "tokens=2 delims=0-" %%f in ("%ARG%") do for /F "tokens=2 delims=2." %%g in ("%%f") do set PHP_MINOR_VERSION=%%g

IF "%PHP_MAJOR_VERSION%"=="5" (
  echo "PHP 5.6 START"
  call %SHELL_PATH%envsetup.bat php-5.6
  call %SHELL_PATH%all_test.bat php-5.6
) ELSE (
  IF "%PHP_MINOR_VERSION%"=="1" (
    echo "PHP 7.1 START"
    call %SHELL_PATH%envsetup.bat php-7.1
    call %SHELL_PATH%all_test.bat php-7.1
  ) ELSE IF "%PHP_MINOR_VERSION%"=="4" (
    echo "PHP 7.4 START"
    call %SHELL_PATH%envsetup.bat php-7.4
    call %SHELL_PATH%all_test.bat php-7.4
  ) ELSE (
    echo "Please Check the first argument. e.g.) php-5.6, php-7.1, php-7.4"
  )
)

IF "%1"=="all" (
  IF "%PHP_MAJOR_VERSION%"=="5" (
    set ARG=php-7.1
    goto run_test
  ) ELSE (
    IF "%PHP_MINOR_VERSION%"=="1" (
      set ARG=php-7.4
      goto run_test
    )
  )
)


set SHELL_PATH=%~dp0
set DRIVER_NAME=cubrid-odbc

setlocal

git clone git@github.com:CUBRID/%DRIVER_NAME%.git

cd .\%DRIVER_NAME%\script

call get_cci_driver.bat

cd ..

call build_2017.bat
call build_unicode_2017.bat

call test.bat

cd %SHELL_PATH%
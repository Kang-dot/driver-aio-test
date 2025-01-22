set SHELL_PATH=%~dp0
set DRIVER_NAME=cubrid-adonet

setlocal

git clone git@github.com:CUBRID/%DRIVER_NAME%.git

cd .\%DRIVER_NAME%\script

call get_cci_driver.bat

cd ..

call test.bat
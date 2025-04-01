@echo off

set ISDOWNLOAD=%3

set SHELL_PATH=%~dp0
set LIB_PATH=%SHELL_PATH%lib
set DEVEL_PACK_PATH=%SHELL_PATH%lib\devel-pack
set SOURCE_DIR=%SHELL_PATH%
set GIT_PATH=C:\Program Files\Git\bin\git.exe

@REM set GIT_CLONE=git@github.com:hwany7seo/cubrid-php.git -b 11_4_test --recursive
set GIT_CLONE=git@github.com:CUBRID/cubrid-php.git --recursive
set SOURCE_DIR_PHP_56=%SOURCE_DIR%cubrid-php-5-6
set SOURCE_DIR_PHP_71=%SOURCE_DIR%cubrid-php-7-1
set SOURCE_DIR_PHP_74=%SOURCE_DIR%cubrid-php-7-4

set RESULT=true

echo "ISDOWNLOAD : %ISDOWNLOAD%"

IF "%1"=="" (
	echo "usage: %0 PHP_VERSION <ex: php-5.6.31 | php-7.1.8 | php-7.4.2> Driver <ex: pdo>"
	GOTO exit
)

for /F "tokens=2 delims=0-" %%f in ("%1") do for /F "tokens=1 delims=1." %%g in ("%%f") do set PHP_MAJOR_VERSIN=%%g
for /F "tokens=2 delims=0-" %%f in ("%1") do for /F "tokens=2 delims=2." %%g in ("%%f") do set PHP_MINOR_VERSIN=%%g

call :FINDEXEC git.exe GIT_PATH "%GIT_PATH%"

echo Checking test source directory [%SOURCE_DIR%cubrid-php]...

echo "Start PHP %PHP_MAJOR_VERSIN%.%PHP_MINOR_VERSIN% Build"

IF "%PHP_MAJOR_VERSIN%"=="5" (
  set TARGETDIR=%SOURCE_DIR_PHP_56%
  set PHP_VERSION=CUBRID-PHP-5.6.31
  set VC_VERSION=VC11
  IF NOT "%ISDOWNLOAD%"=="ND" (
    if EXIST "%SOURCE_DIR_PHP_56%" (
      rmdir /s /q "%SOURCE_DIR_PHP_56%"
    )
    "%GIT_PATH%" clone %GIT_CLONE% cubrid-php-5-6
  )
) ELSE IF "%PHP_MAJOR_VERSIN%"=="7" (
  IF "%PHP_MINOR_VERSIN%"=="1" (
    set TARGETDIR=%SOURCE_DIR_PHP_71%
    set PHP_VERSION=CUBRID-PHP-7.1.8
    set VC_VERSION=VC14
    IF NOT "%ISDOWNLOAD%"=="ND" (
      if EXIST "%SOURCE_DIR_PHP_71%" (
        rmdir /s /q "%SOURCE_DIR_PHP_71%"
      )
      "%GIT_PATH%" clone %GIT_CLONE% cubrid-php-7-1
    )
  ) ELSE IF "%PHP_MINOR_VERSIN%"=="4" (
    set TARGETDIR=%SOURCE_DIR_PHP_74%
    set PHP_VERSION=CUBRID-PHP-7.4.2
    set VC_VERSION=VC15
    IF NOT "%ISDOWNLOAD%"=="ND" (
      if EXIST "%SOURCE_DIR_PHP_74%" (
        rmdir /s /q "%SOURCE_DIR_PHP_74%"
      )
      "%GIT_PATH%" clone %GIT_CLONE% cubrid-php-7-4
    )
  )
)

IF "%2"=="pdo" (
	set slnPREFIX=pdo_cubrid
) ELSE (
	set slnPREFIX=php_cubrid
)

REM ===================
REM PHP 64bit env
REM ===================
set PHP5_TS_SRC_X64=%DEVEL_PACK_PATH%\php-devel-pack-5.6.31-Win32-VC11-x64\php-5.6.31-devel-VC11-x64\include
set PHP5_NTS_SRC_X64=%DEVEL_PACK_PATH%\php-devel-pack-5.6.31-nts-Win32-VC11-x64\php-5.6.31-devel-VC11-x64\include

set PHP7_TS_SRC_X64=%DEVEL_PACK_PATH%\php-devel-pack-7.1.8-Win32-VC14-x64\php-7.1.8-devel-VC14-x64\include
set PHP7_NTS_SRC_X64=%DEVEL_PACK_PATH%\php-devel-pack-7.1.8-nts-Win32-VC14-x64\php-7.1.8-devel-VC14-x64\include

set PHP74_TS_SRC_X64=%DEVEL_PACK_PATH%\php-devel-pack-7.4.2-Win32-vc15-x64\php-7.4.2-devel-vc15-x64\include
set PHP74_NTS_SRC_X64=%DEVEL_PACK_PATH%\php-devel-pack-7.4.2-nts-Win32-vc15-x64\php-7.4.2-devel-vc15-x64\include


set PHP5_NTS_X64=%LIB_PATH%\php-5.6.31-nts-Win32-VC11-x64
set PHP5_TS_X64=%LIB_PATH%\php-5.6.31-Win32-VC11-x64

set PHP7_NTS_X64=%LIB_PATH%\php-7.1.8-nts-Win32-VC14-x64
set PHP7_TS_X64=%LIB_PATH%\php-7.1.8-Win32-VC14-x64

set PHP74_NTS_X64=%LIB_PATH%\php-7.4.2-nts-Win32-vc15-x64
set PHP74_TS_X64=%LIB_PATH%\php-7.4.2-Win32-vc15-x64
REM ===================


echo %PHP74_TS_SRC_X64%
echo %PHP74_NTS_SRC_X64%

set PHP5_SRC=""
set PHP7_SRC=""
set PHPRC_TS_X64=""
set PHPRC_NTS_X64=""

IF NOT EXIST %TARGETDIR% (
	echo "%TARGETDIR% is missing or the other name"
	GOTO exit
)

if EXIST "%TARGETDIR%\php_cubrid_version.h" set VERSION_FILE=php_cubrid_version.h
echo Checking build number with [%TARGETDIR%\%VERSION_FILE%]...
for /f "tokens=1,2,3 delims= " %%a IN (%TARGETDIR%\%VERSION_FILE%) DO set CUBRID_VERSION=%%~c
echo "CUBRID_VERSION %CUBRID_VERSION%"

IF "%PHP_MAJOR_VERSIN%"=="5" (
REM	cd "C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC"
  echo "RUN VS2012 %VS110COMNTOOLS%vsvars32.bat"
	call "%VS110COMNTOOLS%vsvars32.bat"
) ELSE IF "%PHP_MAJOR_VERSIN%"=="7" (
REM	cd "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools"
  echo "RUN VS2017 %VS2017COMNTOOLS%VsDevCmd.bat"
	call "%VS2017COMNTOOLS%VsDevCmd.bat"
) ELSE (
	echo "1st parameter is undefined"
	GOTO exit
)

echo "Start build %TARGETDIR%..."
cd %TARGETDIR%
IF "%ISDOWNLOAD%"=="ND" (
  rmdir /s /q %slnPREFIX%__x64_Release_NTS %slnPREFIX%__x64_Release_TS
)
IF "%PHP_MAJOR_VERSIN%"=="5" (
	set PHP7_SRC=""

	REM ===================
	REM PHP 64bit build
	REM ===================
	set PHP5_SRC=%PHP5_NTS_SRC_X64%
  set PHPRC=%PHP5_NTS_X64%
	set PHPRC_NTS_X64=%PHP5_NTS_X64%
    MSBuild.exe %slnPREFIX%.sln /t:Rebuild /p:Configuration=Release_NTS /p:Platform=x64
	
	set PHP5_SRC=%PHP5_TS_SRC_X64%
  set PHPRC=%PHP5_TS_X64%
	set PHPRC_TS_X64=%PHP5_TS_X64%
    MSBuild.exe %slnPREFIX%.sln /t:Rebuild /p:Configuration=Release_TS /p:Platform=x64

) ELSE IF "%PHP_MAJOR_VERSIN%"=="7" (
	set PHP5_SRC=""
	
	IF "%PHP_MINOR_VERSIN%"=="1" (
		REM ===================
		REM PHP 64bit build
		REM ===================
		set PHP7_SRC=%PHP7_NTS_SRC_X64%
    set PHPRC=%PHP7_NTS_X64%
		set PHPRC_NTS_X64=%PHP7_NTS_X64%
		devenv %slnPREFIX%_7.sln /rebuild "Release_NTS|x64"
		
		set PHP7_SRC=%PHP7_TS_SRC_X64%
    set PHPRC=%PHP7_TS_X64%
		set PHPRC_TS_X64=%PHP7_TS_X64%
		devenv %slnPREFIX%_7.sln /rebuild "Release_TS|x64"

	) ELSE IF "%PHP_MINOR_VERSIN%"=="4" (
    REM ===================
		REM PHP 64bit build
		REM ===================	
		set PHP7_SRC=%PHP74_NTS_SRC_X64%
    set PHPRC=%PHP74_NTS_X64%
		set PHPRC_NTS_X64=%PHP74_NTS_X64%
    devenv %slnPREFIX%_7.sln /Upgrade
		devenv %slnPREFIX%_7.sln /rebuild "Release_NTS|x64"

		set PHP7_SRC=%PHP74_TS_SRC_X64%
    set PHPRC=%PHP74_TS_X64%
		set PHPRC_TS_X64=%PHP74_TS_X64%
    devenv %slnPREFIX%_7.sln /Upgrade
		devenv %slnPREFIX%_7.sln /rebuild "Release_TS|x64"
	
	) ELSE (
		echo "check minor version"
		@exit
	)
)


echo "PHP env....."
echo "PHP5_SRC : %PHP5_SRC%"
echo "PHP7_SRC: %PHP7_SRC%"
echo "================================================================="
echo "=====================Build Result================================"
IF NOT EXIST "%SHELL_PATH%result" (
  mkdir %SHELL_PATH%result
)

IF EXIST "%TARGETDIR%\%slnPREFIX%___x64_Release_NTS\%slnPREFIX%.dll" ( 
  copy /y "%TARGETDIR%\%slnPREFIX%___x64_Release_NTS\%slnPREFIX%.dll" "%PHPRC_NTS_X64%\ext"
  echo "X64 NTS BUILD OK %PHPRC_NTS_X64%\ext"
  zip -j %SHELL_PATH%result\%PHP_VERSION%-WIN64-%VC_VERSION%-NTS-%CUBRID_VERSION%.zip "%TARGETDIR%\%slnPREFIX%___x64_Release_NTS\%slnPREFIX%.dll"
) ELSE (
  set RESULT=false
  echo "PLEASE CHECK X64 NTS BUILD"
)

IF EXIST "%TARGETDIR%\%slnPREFIX%___x64_Release_TS\%slnPREFIX%.dll" ( 
  copy /y "%TARGETDIR%\%slnPREFIX%___x64_Release_TS\%slnPREFIX%.dll" "%PHPRC_TS_X64%\ext"
  echo "X64 TS BUILD OK %PHPRC_TS_X64%\ext"
  zip -j %SHELL_PATH%result\%PHP_VERSION%-WIN64-%VC_VERSION%-TS-%CUBRID_VERSION%.zip "%TARGETDIR%\%slnPREFIX%___x64_Release_TS\%slnPREFIX%.dll"
) ELSE (
  set RESULT=false
  echo "PLEASE CHECK X64 TS BUILD"
)
echo "===================RESULT : %RESULT%=============================================="

IF %RESULT%==true ( 
GOTO exit
) ELSE (
GOTO error
)

:error
echo "ERROR BUILD %TARGETDIR%....."
cd %SOURCE_DIR%
GOTO :EOF

:exit
echo "END BUILD %TARGETDIR%....."
cd %SOURCE_DIR%
GOTO :EOF

:FINDEXEC
if EXIST %3 set %2=%~3
if NOT EXIST %3 for %%X in (%1) do set FOUNDINPATH=%%~$PATH:X
if defined FOUNDINPATH set %2=%FOUNDINPATH:"=%
if NOT defined FOUNDINPATH if NOT EXIST %3 echo Executable [%1] is not found & GOTO :EOF
call echo Executable [%1] is found at [%%%2%%]
GOTO :EOF

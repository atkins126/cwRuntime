@echo off
SET WORKSPACE=%1

REM ------------------------------------------------------------------------------
REM - This file exists for the sake of the projects continuous integration server.
REM - Do not use unless you know what you are doing.
REM ------------------------------------------------------------------------------

REM ------------------------------ Build sample projects ------------------------

REM ------------------------------ Build log library (debug) --------------------
lazbuild %WORKSPACE%\src\projects\lib_cwLog.lpi  || exit /b

REM ------------------------------ Build test projects --------------------------

lazbuild %WORKSPACE%\src\tests\test_dynamic_cwLog.lpi      || exit /b
lazbuild %WORKSPACE%\src\tests\test_cwTest.lpi             || exit /b
lazbuild %WORKSPACE%\src\tests\test_cwRuntime.lpi          || exit /b

REM ------------------------------ Execute test projects --------------------------

%WORKSPACE%\out\bin\x86_64-win64\test_dynamic_cwLog.exe  || exit /b
%WORKSPACE%\out\bin\x86_64-win64\test_cwTest.exe         || exit /b
%WORKSPACE%\out\bin\x86_64-win64\test_cwRuntime.exe      || exit /b

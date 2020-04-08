@echo off
REM ------------------------------------------------------------------------------
REM - This file exists for the sake of the projects continuous integration server.
REM - Do not use unless you know what you are doing.
REM ------------------------------------------------------------------------------

SET ENV=%1
SET WORKSPACE=%2
SET VARIANT=%3
call %ENV% || exit /b

REM ------------------------------ Build sample projects ------------------------

REM ------------------------------ Build log library (debug) --------------------
msbuild %WORKSPACE%\src\projects\lib_cwLog_Rio.dproj                      || exit /b

REM ------------------------------ Build test projects --------------------------

msbuild %WORKSPACE%\src\tests\test_dynamic_cwLog_%VARIANT%.dproj          || exit /b
msbuild %WORKSPACE%\src\tests\test_cwTest_%VARIANT%.dproj                || exit /b
msbuild %WORKSPACE%\src\tests\test_cwRuntime_%VARIANT%.dproj          || exit /b

REM ------------------------------ Execute test projects --------------------------

%WORKSPACE%\out\bin\Win64\Debug\test_dynamic_cwLog.exe                    || exit /b
%WORKSPACE%\out\bin\Win64\Debug\test_cwTest.exe                           || exit /b
%WORKSPACE%\out\bin\Win64\Debug\test_cwRuntime.exe                        || exit /b

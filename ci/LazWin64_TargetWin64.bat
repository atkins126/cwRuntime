@echo off
WORKSPACE=%1

REM ------------------------------------------------------------------------------
REM - This file exists for the sake of the projects continuous integration server.
REM - Do not use unless you know what you are doing.
REM ------------------------------------------------------------------------------

REM ------------------------------ Build sample projects ------------------------

REM ------------------------------ Build log library (debug) --------------------
lazbuild %WORKSPACE%\src\projects\lib_cwLog.lpi  || exit /b

REM ------------------------------ Build test projects --------------------------

lazbuild %WORKSPACE%\src\tests\cwCollections\test_cwCollections.lpi  || exit /b
lazbuild %WORKSPACE%\src\tests\cwIO\test_cwIO.lpi                    || exit /b
lazbuild %WORKSPACE%\src\tests\cwLog\test_dynamic_cwLog.lpi          || exit /b
lazbuild %WORKSPACE%\src\tests\cwLog\test_static_cwLog.lpi           || exit /b
lazbuild %WORKSPACE%\src\tests\cwTest\test_cwTest.lpi                || exit /b
lazbuild %WORKSPACE%\src\tests\cwTypes\test_cwTypes.lpi              || exit /b
lazbuild %WORKSPACE%\src\tests\cwUnicode\test_cwUnicode.lpi          || exit /b

REM ------------------------------ Execute test projects --------------------------

%WORKSPACE%\out\bin\x86_64-win64\test_cwCollections.exe  || exit /b
REM - %WORKSPACE%\out\bin\x86_64-win64\test_cwIO.exe           || exit /b 
%WORKSPACE%\out\bin\x86_64-win64\test_dynamic_cwLog.exe  || exit /b
%WORKSPACE%\out\bin\x86_64-win64\test_static_cwLog.exe   || exit /b
%WORKSPACE%\out\bin\x86_64-win64\test_cwTest.exe         || exit /b
%WORKSPACE%\out\bin\x86_64-win64\test_cwTypes.exe        || exit /b
%WORKSPACE%\out\bin\x86_64-win64\test_cwUnicode.exe      || exit /b
%WORKSPACE%\out\bin\x86_64-win64\test_cwVectors.exe      || exit /b

@echo off
SETLOCAL

IF NOT "%3"=="-postbuildevent" GOTO RUN_MSG

SET PXFROMDIR=%1
SET PXTODIR=%2

CALL :UPDATE_PX_TARGET PhysXCooking_64.dll
CALL :UPDATE_PX_TARGET PhysX_64.dll
CALL :UPDATE_PX_TARGET PhysXGpu_64.dll
CALL :UPDATE_PX_TARGET PhysXDevice64.dll
CALL :UPDATE_PX_TARGET PhysXCommon_64.dll
CALL :UPDATE_PX_TARGET PhysXFoundation_64.dll
CALL :UPDATE_PX_TARGET glut32.dll

ENDLOCAL
GOTO END


REM ********************************************
REM NO CALLS TO :UPDATE*_TARGET below this line!!
REM ********************************************

:UPDATE_PX_TARGET
IF NOT EXIST %PXFROMDIR%\%1 (
	echo File doesn't exist %PXFROMDIR\%1
) ELSE (
    XCOPY "%PXFROMDIR%\%1" "%PXTODIR%" /R /C /Y > nul
)
GOTO END

:RUN_MSG
echo This script doesn't need to be run manually.
pause

:END

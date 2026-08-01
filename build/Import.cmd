:: YTM Import Script
:: Created by Tech How - https://github.com/Tech-How
:: Version 1.4

@echo off
title YTM Import
cd /d "%~dp0"

:: Retrieve import mode from disk, and goto first time setup if needed
:initialize
set importMode=unspecified
set /p importMode=<Settings\importMode.txt
if %importMode%==unspecified (
    cls
    call "Redistributables\Setup.cmd" /run_wizard_import
    goto initialize
)
set importMode=%importMode: =%

:: If a folder was passed to this script by calling or drag and drop, use that as the import folder
if "%~1" neq "" (
    set "locator=%1"
    goto import_files
)

:: First run tips
if exist Settings goto tips

:: Prompt for import folder
:prompt1
    set /p "locator=Enter folder: "
    if not exist "%locator%" (
    echo.
    echo Folder "%locator%" not found.
    echo Press any key to quit...
    timeout -1 >nul
    exit
)

:: Import by opening
:import_files
set locator=%locator:"=%
echo.
echo Importing...
if %importMode%==move goto movefiles
for /f "tokens=* usebackq" %%i in (`dir /b /od "%locator%\*.*"`) do start "" "%locator%\%%i" && cscript Redistributables\Sleep.vbs 500 >nul
exit

:: Import by moving
:movefiles
set /p importDestination=<Settings\importDestination.txt
set "importDestination=%importDestination: =%"
set "importDestination=%importDestination:/= %"
set errorCount=0
move /-y "%locator%\*" "%importDestination%"
if errorlevel 1 set errorCount=1
for /d %%a in ("%locator%\*") do move /-y "%%~fa" "%importDestination%"
if errorlevel 1 set errorCount=1
rd /s /q "%locator%" >nul 2>&1
if %errorCount%==1 (
    echo.
    echo CAUTION: Some errors may have occured during the import operation.
    echo Press any key to quit...
    timeout -1 >nul
    exit
)
echo.
echo Import complete.
echo Press any key to quit...
timeout -1 >nul
exit

:: Determine whether or not to show first run tips
:tips
set tipsCheck=0
if exist Settings\dragDropShown.txt set /p tipsCheck=<Settings\dragDropShown.txt
if exist Settings\dragDropShown.txt set tipsCheck=%tipsCheck: =%
if %tipsCheck%==2 goto prompt1
set /a tipsCheck=%tipsCheck%+1
echo %tipsCheck% > Settings\dragDropShown.txt
echo Tip: You can also drag a folder onto this script in the File Explorer to import it.
echo.
goto prompt1
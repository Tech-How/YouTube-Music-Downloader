:: YTM Duplicate Finder
:: Created by Tech How - https://github.com/Tech-How
:: Version 1.4

@echo off
title YTM Duplicate Finder
cd /d "%~dp0"

:: If a folder was passed to this script by calling or drag and drop, use that as folder 1
if "%~1" neq "" goto get_selected_folder

:: First run tips
if exist Settings goto tips

:: Prompt for first folder
:prompt1
set /p "locator1=Enter folder #1: "
if not exist "%locator1%" (
    echo.
    echo Folder "%locator1%" not found.
    echo Press any key to quit...
    timeout -1 >nul
    exit
)

:: Prompt for second folder
:prompt2
set /p "locator2=Enter folder #2: "
if not exist "%locator2%" (
    echo.
    echo Folder "%locator2%" not found.
    echo Press any key to quit...
    timeout -1 >nul
    exit
)
echo.

:: Scan for and output duplicates
echo Checking...
for %%F in ("%locator1%\*") do if exist "%locator2%\%%~nxF" echo Found duplicate: %%~nxF
echo.
echo Done searching.
echo Press any key to quit...
timeout -1 >nul
exit

:: Set folder 1 from script input if applicable
:get_selected_folder
set locator1=%1
set locator1=%locator1:"=%
echo Folder #1 selected.
if exist Settings echo 2 > Settings\dragDropShown.txt
goto prompt2

:: Determine whether or not to show first run tips
:tips
set tipsCheck=0
if exist Settings\dragDropShown.txt set /p tipsCheck=<Settings\dragDropShown.txt
if exist Settings\dragDropShown.txt set tipsCheck=%tipsCheck: =%
if %tipsCheck%==2 goto prompt1
set /a tipsCheck=%tipsCheck%+1
echo %tipsCheck% > Settings\dragDropShown.txt
echo Tip: You can also drag a folder onto this script in the File Explorer to select it.
echo.
goto prompt1
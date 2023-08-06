:YTM Duplicate Finder
:Created by Tech How - https://github.com/Tech-How
:Version 1.2

@echo off
title YTM Duplicate Finder
if "%~1" neq "" goto getSelectedFolder
if exist Settings goto tips
:prompt1
set /p "locator1=Enter folder #1: "
if not exist "%locator1%" (
echo.
echo Folder "%locator1%" not found.
echo Press any key to quit...
timeout -1 >nul
exit
)
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
echo Checking...
for %%F in ("%locator1%\*") do if exist "%locator2%\%%~nxF" echo Found duplicate: %%~nxF
echo.
echo Done searching.
echo Press any key to quit...
timeout -1 >nul
exit

:getSelectedFolder
set locator1=%1
set locator1=%locator1:"=%
echo Folder #1 selected.
if exist Settings echo 2 > Settings\dragDropShown.txt
goto prompt2

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
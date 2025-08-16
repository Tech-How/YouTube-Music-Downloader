:YTM Import Script
:Created by Tristian Dedinas - https://github.com/Tech-How
:Version 1.3

@echo off
title YTM Import
:initialize
set importMode=unspecified
set /p importMode=<Settings\importMode.txt
if %importMode%==unspecified cls && goto setup
set importMode=%importMode: =%
if "%~1" neq "" (
set "locator=%1"
goto skipprompt
)
if exist Settings goto tips
:prompt1
set /p "locator=Enter folder: "
if not exist "%locator%" (
echo.
echo Folder "%locator%" not found.
echo Press any key to quit...
timeout -1 >nul
exit
)
:skipprompt
set locator=%locator:"=%
echo.
echo Importing...
if %importMode%==move goto movefiles
for /f "tokens=* usebackq" %%i in (`dir /b /od "%locator%\*.*"`) do start "" "%locator%\%%i" && cscript Redistributables\Sleep.vbs 500 >nul
exit

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

:setup
set "setting=importMode" && set "returnto=setup_end"
md Settings >nul 2>&1
echo This script has been run for the first time. Please configure it below.
echo.
echo There are 2 modes that can be used for music import. Please select the correct mode based
echo on your specific media player.
echo.
echo Mode 1: Just open files with default media player (Eg. iTunes)
echo Mode 2: Move files to a media folder (Eg. VLC, Plex, Kodi, MusicBee)
echo.
echo Press numbers 1 or 2, or press Q to quit.
choice /c 12q /n /m "> "
if errorlevel 3 exit
if errorlevel 2 cls && goto 2
if errorlevel 1 set value=open && goto setup_write
:2
echo To continue, you'll need to specify a folder for the audio files to be moved to.
echo NOTE: Importing files in playlist/download order is only available with the "Open" mode.
echo.
echo Press any key to select a destination folder...
pause >nul
set folder=notSelected
set "folderprompt=Select folder"
set "defaultfolderlocation=%userprofile%\Music"
set PScommand=powershell "Add-Type -AssemblyName System.Windows.Forms; $FolderBrowse = New-Object System.Windows.Forms.OpenFileDialog -Property @{ValidateNames = $false;CheckFileExists = $false;RestoreDirectory = $true;initialDirectory = '%defaultfolderlocation%';Filter = 'Folders|*.';FileName = '%folderprompt%';};$null = $FolderBrowse.ShowDialog();$FolderName = Split-Path -Path $FolderBrowse.FileName;Write-Output $FolderName"
for /f "usebackq tokens=*" %%q in (`%PScommand%`) do set "folder=%%q"
if "%folder%"=="notSelected" cls && echo ERROR: No folder selected. && echo. && goto 2
cls
echo The path "%folder%" will be used for all downloaded music.
set "folder=%folder: =/%"
pause
:3
cls
set "setting=importDestination" && set "returnto=4"
set "value=%folder%" && goto setup_write
:4
set "setting=importMode" && set "returnto=setup_end"
set value=move && goto setup_write

:setup_write
echo %value% > "Settings\%setting%.txt"
goto %returnto%
exit

:setup_end
cls
echo Setup complete. You can edit these options anytime in the Settings folder.
pause
cls
goto initialize
exit

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
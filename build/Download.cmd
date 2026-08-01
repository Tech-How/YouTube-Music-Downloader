:: YTM Download Launcher
:: Created by Tech How - https://github.com/Tech-How
:: Version 1.4

:: Uses third-party licenses
:: yt-dlp - https://github.com/yt-dlp/yt-dlp
:: ffmpeg - https://ffmpeg.org/
:: Album Art Downloader - https://sourceforge.net/projects/album-art/

@echo off
title YTM Downloader
cd /d "%~dp0"

:: Reset app state if requested
echo %*|find "/reset" >nul 2>&1 && goto reset_app

:: Skip currently failing download if requested
echo %*|find "/skip" >nul 2>&1 && goto skip_item

:: Check if all files are intact and run initial setup if required
call "Redistributables\Setup.cmd" /validate_prepare
if errorlevel 1 (
    echo.
    echo One or more of the required redistributables is missing or not found. Please visit this project on GitHub.
    echo The program cannot continue.
    timeout -1 /nobreak >nul
    exit
)
cls

:: Check if music is already being downloaded
set checkBusy=0
if exist Cache set /a checkBusy=%checkBusy%+1
if exist YTMusic set /a checkBusy=%checkBusy%+1
if %checkBusy%==2 echo Not so fast^! It appears music is already being downloaded. && echo Please wait for the current download to finish. && echo. && echo If this isn't the case, another download may have been interrupted. && echo Deleting the Cache and YTMusic folders will resolve this issue. && pause && exit

:: Check if videos are being downloaded
if exist Cache01 echo Not so fast^! It appears videos are already being downloaded. && echo Please wait for the current download to finish. && echo. && echo If this isn't the case, another download may have been interrupted. && echo Deleting the Cache folder will resolve this issue. && pause && exit

:: Recycle URL files, clear the cache, and prepare for a new launch
if exist "%~dp0Redistributables\LastRun.txt" goto cleanup

:: Main script start
:start
if exist "%~dp0Redistributables\Track.txt" del /q "%~dp0Redistributables\Track.txt"
if exist "%~dp0Redistributables\TotalTracks.txt" del /q "%~dp0Redistributables\TotalTracks.txt"
if not exist "%~dp0URLs.txt" echo You haven't queued anything to download! Paste your links in the Add scripts first. && echo Press any key to exit... && pause >nul && exit

:: Run first time setup if necessary
if not exist Settings\autoImport.txt call "Redistributables\Setup.cmd" /run_wizard

:initialize

:: Check for yt-dlp updates if necessary and permitted
:yt-dl-update
set engineUpdatesAllowed=0
set lastUpdateCheck=0

if exist Settings\engineUpdatesAllowed.txt set/p engineUpdatesAllowed=<Settings\engineUpdatesAllowed.txt
set engineUpdatesAllowed=%engineUpdatesAllowed: =%

:: Skip updates if specified by the user
if "%engineUpdatesAllowed%"=="false" goto yt-dl-update-skip

if exist Settings\lastUpdateCheck.txt set/p lastUpdateCheck=<Settings\lastUpdateCheck.txt
set lastUpdateCheck=%lastUpdateCheck: =%

:: Skip updates if we've already checked once today
for /F "tokens=2 delims=. " %%a in ("%date%") do set "currentDate=%%a"
if "%currentDate%" equ "%lastUpdateCheck%" goto yt-dl-update-skip

:: Tell the engine to update itself
echo Checking for engine updates...
Redistributables\yt-dlp\yt-dlp.exe --update >nul 2>&1

:: Write the current date to the disk
echo %currentDate% > Settings\lastUpdateCheck.txt

:: Save the preference in case it hasn't been created yet
echo true > Settings\engineUpdatesAllowed.txt
cls

:yt-dl-update-skip
set autoImport=false
set/p autoImport=<Settings\autoImport.txt
set autoImport=%autoImport: =%

if exist "%~dp0Redistributables\VideoMode.txt" goto download_videos

:: Determine number of tracks to download
set trackcount=0
for /f "tokens=* usebackq" %%a in (`find /v /c "" "%~dp0URLs.txt"`) do set trackcount=%%a
for /f "tokens=3 delims=:" %%f in ("%trackcount%") do set trackcount=%%f
set trackcount=%trackcount: =%
set pl=songs
if %trackcount%== 1 set pl=song
echo %trackcount% %pl% will be downloaded.
if %trackcount%== 1 goto download_files
echo.
echo Is this an Album? Press [N] if you are downloading singles, or [Y] if this is an album.
choice /c yn /n /m "> "
if errorlevel 2 goto download_files
if errorlevel 1 goto album_warning

:: Alert for albums/singles
:: Added to save time fetching the same album cover if they are all identical
:album_warning
cls
echo NOTE: This will treat all %trackcount% %pl% as one album, inheriting the same track numbers and album art.
echo When downloading albums, please download them separately.
echo.
echo [Close window to cancel]
echo [Press any key to continue...]
pause >nul
echo 0 > "%~dp0Redistributables\Track.txt"
echo %trackcount% > "%~dp0Redistributables\TotalTracks.txt"
goto download_files

:: Recycle URL files, clear the cache, and prepare for a new launch, called at the beginning of the script
:cleanup
if exist "%~dp0Cache" rd /s /q "%~dp0Cache"
del /q "%~dp0Redistributables\LastRun.txt"
del /q "%~dp0URLs.txt.bak3" >nul 2>&1
ren "%~dp0URLs.txt.bak2" URLs.txt.bak3 >nul 2>&1
ren "%~dp0URLs.txt.bak" URLs.txt.bak2 >nul 2>&1
ren "%~dp0URLs.txt" URLs.txt.bak >nul 2>&1
goto start

:: Begin the downloading of songs
:download_files
echo 0 > "%~dp0Redistributables\dlProgress"
for /f "usebackq tokens=*" %%a in ("%~dp0URLs.txt") do call "%~dp0Redistributables\Downloader.cmd" %%a %trackcount% 0
timeout 1 /nobreak >nul
del /q "%~dp0Redistributables\dlProgress"
del /q "%~dp0Redistributables\skipItem"
del /q Cache\Album.jpg >nul 2>&1
rd Cache >nul 2>&1
set "saveFolder=%date:/=_%"
if exist "%saveFolder%" (
set "saveFolder=%date:/=_% %time::=-%"
)
md "%saveFolder%"
move "YTMusic\*" "%saveFolder%"
for /d %%a in ("YTMusic\*") do move /y "%%~fa" "%saveFolder%" >nul 2>&1
rd YTMusic >nul 2>&1
if "%autoImport%"=="true" Import.cmd "%saveFolder%"
exit

:download_videos
if not exist Settings\videoFormat.txt call "Redistributables\Setup.cmd" /run_wizard_video
set itemcount=0
for /f "tokens=* usebackq" %%a in (`find /v /c "" "%~dp0URLs.txt"`) do set itemcount=%%a
for /f "tokens=3 delims=:" %%f in ("%itemcount%") do set itemcount=%%f
set itemcount=%itemcount: =%
set plv=videos
if %itemcount%== 1 set plv=video
echo %itemcount% %plv% will be downloaded.
set/p content_type=<Redistributables\VideoConvertType.txt
set content_type=%content_type: =%
set content_format=0
findstr "mp4" Settings\videoFormat.txt >nul && set content_format=1
echo 0 > "%~dp0Redistributables\dlProgress"
for /f "usebackq tokens=*" %%a in ("%~dp0URLs.txt") do call "%~dp0Redistributables\Downloader.cmd" %%a %itemcount% 1 %content_type% %content_format%
rd Cache01 >nul 2>&1
if %content_type%==0 set "saveFolder=Video Downloads"
if %content_type%==1 set "saveFolder=Audio Downloads"
del /q "%~dp0Redistributables\dlProgress"
del /q "%~dp0Redistributables\skipItem"
del /q "%~dp0Redistributables\VideoMode.txt"
del /q "%~dp0Redistributables\VideoConvertType.txt"
if %content_type%==1 (
    if "%autoImport%"=="true" (
        Import.cmd "%saveFolder%"
    )
)
exit

:skip_item
echo true > "%~dp0Redistributables\skipItem"
echo The currently failing download will now be skipped.
echo You may close this window and press any key on the currently open downloader window to jump to the next item.
exit /b

:reset_app
title YTM Downloader - RESET CONFIG
echo You have requested to reset this app's data.
echo This can help resolve any errors. The following changes will be made:
echo - Clear all pending downloads and download history
echo - Clear all user settings
echo - Clear cache and download progress state data
echo.
echo Any completed downloads will NOT be removed.
echo Would you like to proceed?
echo [Y] Yes [N] No
choice /c yn /n /m "> "
if errorlevel 2 echo Canceled && exit /b
if errorlevel 1 goto reset_app_data
exit /b

:reset_app_data
echo.
echo.
echo Clearing download lists...
del /q "%~dp0URLs.txt" >nul 2>&1
del /q "%~dp0URLs.txt.bak" >nul 2>&1
del /q "%~dp0URLs.txt.bak2" >nul 2>&1
del /q "%~dp0URLs.txt.bak3" >nul 2>&1
if exist "%~dp0YTMusic" md "%~dp0Interrupted Downloads" >nul 2>&1
if exist "%~dp0YTMusic" xcopy /e /i "%~dp0YTMusic" "%~dp0Interrupted Downloads" >nul 2>&1
if exist "%~dp0YTMusic" echo This folder contains data of an in progress download that was not finished properly. These files were preserved the last time the app's data was cleared. You may delete this folder if you no longer need its contents. > "%~dp0Interrupted Downloads\~Info.txt"
rd /s /q "%~dp0YTMusic" >nul 2>&1
echo Done
echo Clearing user settings...
rd /s /q "%~dp0Settings" >nul 2>&1
echo Done
echo Clearing app state...
rd /s /q "%~dp0Cache" >nul 2>&1
rd /s /q "%~dp0Cache01" >nul 2>&1
del /q "%~dp0Redistributables\LastRun.txt" >nul 2>&1
del /q "%~dp0Redistributables\dlProgress" >nul 2>&1
del /q "%~dp0Redistributables\skipItem" >nul 2>&1
del /q "%~dp0Redistributables\Track.txt" >nul 2>&1
del /q "%~dp0Redistributables\TotalTracks.txt" >nul 2>&1
del /q "%~dp0Redistributables\VideoMode.txt" >nul 2>&1
del /q "%~dp0Redistributables\VideoConvertType.txt" >nul 2>&1
echo Done
echo.
echo The app's state has been reset.
echo You may close this window now.
pause
exit /b
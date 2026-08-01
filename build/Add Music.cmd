:: YTM Music Scraper
:: Created by Tech How - https://github.com/Tech-How
:: Version 1.4

:: Uses third-party licenses
:: yt-dlp - https://github.com/yt-dlp/yt-dlp

@echo off
title YTM Downloader
cd /d "%~dp0"

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
:: Don't modify this, please use the dedicated video script to queue and download videos.
:: Forcing this to 1 in music mode will result in failed downloads.
set "content_display=music"
set "content_display_info=track"
set "allow_videos=0"
if "%1" == "allow_videos" set "allow_videos=1" && set "content_type=%2" && set "content_display=content" && set "content_display_info=available"
if exist "%~dp0Redistributables\VideoMode.txt" (
    if %allow_videos%==0 (
        echo You have videos pending for download.
        echo Please use the Download script to finish all video downloads before using this script.
        echo To reset the state of this application, run Download.cmd /reset
        echo.
        pause
        exit /b
    )
)
if %allow_videos%==0 goto help

:: Beginning of prompt for music album/playlist/song URLs
:: Supports Beatbump.io parsing as well
:prompt
if not exist "%~dp0URLs.txt" goto skip_count
set trackcount=0
for /f "tokens=* usebackq" %%a in (`find /v /c "" "%~dp0URLs.txt"`) do set trackcount=%%a
for /f "tokens=3 delims=:" %%f in ("%trackcount%") do set trackcount=%%f
set trackcount=%trackcount: =%
set pl=items
if %trackcount%== 1 set pl=item
echo %trackcount% %pl% queued
echo ----------------

:skip_count
set/p "URL=Paste your link here: "
echo "%URL%"|find "beatbump.io/listen?id" >nul
if %errorlevel% neq 1 set URL=%URL:beatbump.io/listen?id=youtube.com/watch?v% && goto parseNow
echo "%URL%"|find "music.youtube.com" >nul
if errorlevel 1 goto error
set URL=%URL:music=www%

:: Fetch all IDs using yt-dlp and write them to the disk
:parseNow
cls
title Loading...
echo Please wait while your %content_display% is being prepared. This may take a few minutes.
echo ...
echo Fetching %content_display_info% information for URL:
echo %URL%
Redistributables\yt-dlp\yt-dlp.exe --no-warnings --ffmpeg-location "%~dp0Redistributables\FFMPEG\bin\ffmpeg.exe" -i --get-id %URL% >> "%~dp0URLs.txt"
cls
title YTM Downloader
if %allow_videos%==1 echo true > "%~dp0Redistributables\VideoMode.txt"
if %allow_videos%==1 echo %content_type% > "%~dp0Redistributables\VideoConvertType.txt"
echo Success^!
echo.
echo To download this %content_display% now, close this script and run the downloader.
echo You can also add more %content_display% to download below.
echo.
echo.
goto prompt

:: Notify the user if the provided link is invalid
:error
if %allow_videos%==1 goto parse_video_url
cls
echo ERROR: The link you provided is not a valid YouTube Music link.
echo.
goto prompt

:: Video support for when using the dedicated video script
:parse_video_url
set parse_video_check=0
echo "%URL%"|find "youtube.com" >nul || set /a parse_video_check=%parse_video_check%+1
echo "%URL%"|find "youtu.be" >nul || set /a parse_video_check=%parse_video_check%+1
if %parse_video_check%==2 goto parse_video_cancel
goto parseNow
:parse_video_cancel
cls
echo ERROR: The link you provided is not a valid YouTube link.
echo.
goto prompt


:: Recycle URL files, clear the cache, and prepare for a new launch, called at the beginning of the script
:cleanup
if exist "%~dp0Cache" rd /s /q "%~dp0Cache"
del /q "%~dp0Redistributables\LastRun.txt"
del /q "%~dp0URLs.txt.bak3" >nul 2>&1
ren "%~dp0URLs.txt.bak2" URLs.txt.bak3 >nul 2>&1
ren "%~dp0URLs.txt.bak" URLs.txt.bak2 >nul 2>&1
ren "%~dp0URLs.txt" URLs.txt.bak >nul 2>&1
goto start

:: Show tips the first time the program is used
:help
if exist Settings\helpShown.txt goto help_cancel
if exist Settings echo true > Settings\helpShown.txt
echo --------------------------------------------------------------------------------------
echo Here you can queue music to be saved by the downloader.
echo.
echo - To begin, visit https://music.youtube.com in your browser.
echo - Search for songs, playlists, or albums.
echo - Right-click on the item, and select share to grab the link.
echo.
echo NOTE: If there are ANY videos in your playlists, DO NOT USE this script.
echo Use the dedicated video script instead. This script does not support video
echo content and will produce unexpected results.
echo.
echo For best results, ensure all of your content is in the official YouTube song format.
echo --------------------------------------------------------------------------------------
echo.
goto prompt
:help_cancel
echo Reminder: If there are any videos in your playlist, use the other script.
echo.
goto prompt
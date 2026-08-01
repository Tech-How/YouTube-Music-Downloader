:: YTM Video Support Launcher
:: Created by Tech How - https://github.com/Tech-How
:: Version 1.4

:: Uses third-party licenses
:: yt-dlp - https://github.com/yt-dlp/yt-dlp
:: ffmpeg - https://ffmpeg.org/

:: Messages for the existing queue
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

if exist "%~dp0Redistributables\VideoMode.txt" goto start

if exist "%~dp0URLs.txt" (
    if not exist "%~dp0Redistributables\LastRun.txt" (
        echo You have music pending for download.
        echo Please use the Download script to finish all music downloads before using this script.
        echo To reset the state of this application, run Download.cmd /reset
        echo.
        pause
        exit /b
    )
    
)

:: Welcome message
:start
goto help

:: Prompt the user to download the video or audio
:content_type_select
if exist "%~dp0Redistributables\VideoConvertType.txt" goto content_type_read
echo You can choose to download the videos, or just extract the audio from them.
echo Use your keyboard to select:
echo [V] Video [A] Audio
choice /c va /n /m "> "
if errorlevel 2 set content_type=1
if errorlevel 1 set content_type=0

:: Start queueing
:begin_queue
"%~dp0Add Music.cmd" allow_videos %content_type%
exit

:: Remember the user's content type choice from the previous session
:content_type_read
set/p content_type=<Redistributables\VideoConvertType.txt
set content_type=%content_type: =%
goto begin_queue

:help
if exist Settings\helpShownVideo.txt goto help_cancel
if exist Settings echo true > Settings\helpShownVideo.txt
echo This script can be used for:
echo - Downloading YouTube Music playlists that include videos or other non official song format content
echo - Downloading music videos
echo - Downloading regular videos from YouTube in their original quality
echo.
echo If every item in your playlist is an official song file, use the Add Music script instead.
echo To begin, press any key...
pause >nul
cls
goto content_type_select
:help_cancel
echo Use this script if your playlist has any videos in it, or just to download video content.
echo.
goto content_type_select
:: Use the following script to download videos. Not officially supported or polished.
:: Feel free to modify this script to fit your needs, like removing the update code for instance

@echo off
echo Updating...
"%~dp0Redistributables\YouTube-DL\youtube-dl.exe" --update >nul 2>&1
cls
set/p "URL=URL: "
set/p "OUT=Output File Name: "
echo.
echo Below, specify whether you wish to download the video, or just extract the audio from it.
echo Use a keyboard letter to select
choice /c va /n /m "Download Type [V]ideo [A]udio:"
if errorlevel 2 goto dl_audio
if errorlevel 1 goto dl_video


:dl_video
"%~dp0Redistributables\YouTube-DL\youtube-dl.exe" -o "%~dp0%OUT%" --no-warnings --embed-metadata --no-check-certificate --audio-quality 0 --restrict-filenames --ffmpeg-location "%~dp0Redistributables\FFMPEG\bin\ffmpeg.exe" %URL%
exit /b

:dl_audio
"%~dp0Redistributables\YouTube-DL\youtube-dl.exe" -o "%~dp0%OUT%" -x --audio-format mp3 --no-warnings --embed-metadata --no-check-certificate --audio-quality 0 --restrict-filenames --ffmpeg-location "%~dp0Redistributables\FFMPEG\bin\ffmpeg.exe" %URL%
exit /b
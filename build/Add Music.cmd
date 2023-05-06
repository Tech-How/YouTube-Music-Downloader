:YTM Music Scraper
:Created by Tech How - https://github.com/Tech-How
:Version 1.0

:Uses third-party licenses
:yt-dlp - https://github.com/yt-dlp/yt-dlp

@echo off
title YTM Downloader
goto integritycheck
:integritypass
if exist "%~dp0Redistributables\LastRun.txt" goto cleanup
:start
echo -----------------------------------------------------------------------------------
echo Please read the Help file before using this program^!
echo.
echo Here you can queue music to be saved by the downloader.
echo.
echo - To begin, visit https://music.youtube.com in your browser.
echo - Search for songs, playlists, or albums.
echo - Right-click on the item, and select share to grab the link.
echo.
echo NOTE: Please ensure you are NOT selecting a video, as they are not yet compatible.
echo -----------------------------------------------------------------------------------
echo.
:prompt
set/p "URL=Paste your link here: "
echo "%URL%"|find "music.youtube.com" >nul
if errorlevel 1 goto error
set URL=%URL:music=www%
cls
echo Please wait while your music is being prepared. This may take a few minutes.
echo ...
timeout 2 /nobreak >nul
echo Downloading track information for URL:
echo %URL%
Redistributables\YouTube-DL\youtube-dl.exe -i --get-id %URL% >> "%~dp0URLs.txt"
cls
echo Success^! To download this music now, close this script and run the downloader.
echo You can also add more music to download below.
echo.
goto prompt

:error
cls
echo ERROR: The link you provided is not a valid YouTube Music link.
echo.
goto prompt

:cleanup
if exist "%~dp0Cache" rd /s /q "%~dp0Cache"
del /q "%~dp0Redistributables\LastRun.txt"
del /q "%~dp0URLs.txt.bak3" >nul 2>&1
ren "%~dp0URLs.txt.bak2" URLs.txt.bak3 >nul 2>&1
ren "%~dp0URLs.txt.bak" URLs.txt.bak2 >nul 2>&1
ren "%~dp0URLs.txt" URLs.txt.bak >nul 2>&1
goto start

:integritycheck
set integrityverification=2
if not exist "Redistributables\AlbumArtDownloader\aad.exe" set integrityverification=1 && echo Missing "Redistributables\AlbumArtDownloader\aad.exe"
if not exist "Redistributables\FFMPEG\bin\ffmpeg.exe" set integrityverification=1 && echo Missing "Redistributables\FFMPEG\bin\ffmpeg.exe"
if not exist "Redistributables\YouTube-DL\youtube-dl.exe" set integrityverification=1 && echo Missing "Redistributables\YouTube-DL\youtube-dl.exe"
if not exist "Redistributables\Downloader.cmd" set integrityverification=1 && echo Missing "Redistributables\Downloader.cmd"
if not exist "Redistributables\Get Info.cmd" set integrityverification=1 && echo Missing "Redistributables\Get Info.cmd"
if %integrityverification%== 2 goto integritypass
echo.
echo One or more of the required redistributables is missing or not found. Please visit this project on GitHub.
echo The program cannot continue.
timeout -1 /nobreak >nul
exit
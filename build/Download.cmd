:YTM Download Launcher
:Created by Tech How - https://github.com/Tech-How
:Version 1.0

:Uses third-party licenses
:yt-dlp - https://github.com/yt-dlp/yt-dlp
:ffmpeg - https://ffmpeg.org/
:Album Art Downloader - https://sourceforge.net/projects/album-art/

@echo off
title YTM Downloader
goto integritycheck
:integritypass
if exist "%~dp0Redistributables\LastRun.txt" goto cleanup

:start
if exist "%~dp0Redistributables\Track.txt" del /q "%~dp0Redistributables\Track.txt"
if exist "%~dp0Redistributables\TotalTracks.txt" del /q "%~dp0Redistributables\TotalTracks.txt"
if not exist "%~dp0URLs.txt" echo You haven't added any music to download! Paste your links in the Add Music script first. && echo Press any key to exit... && pause >nul && exit
set trackcount=0
for /f "tokens=* usebackq" %%a in (`find /v /c "" "%~dp0URLs.txt"`) do set trackcount=%%a
for /f "tokens=3 delims=:" %%f in ("%trackcount%") do set trackcount=%%f
set trackcount=%trackcount: =%
set pl=songs
if %trackcount%== 1 set pl=song
echo %trackcount% %pl% will be downloaded.
if %trackcount%== 1 goto singles
echo.
echo Is this an Album? Press [N] if you are downloading singles, or [Y] if this is an album.
choice /c yn /n /m "> "
if errorlevel 2 goto singles
if errorlevel 1 goto album

:album
cls
echo NOTE: This will treat all %trackcount% %pl% as one album, inheriting the same track numbers and album art.
echo When downloading albums, please download them seperately.
echo.
echo [Close window to cancel]
echo [Press any key to continue...]
pause >nul
echo 0 > "%~dp0Redistributables\Track.txt"
echo %trackcount% > "%~dp0Redistributables\TotalTracks.txt"
goto singles

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

:singles
for /f "usebackq tokens=*" %%a in ("%~dp0URLs.txt") do "%~dp0Redistributables\Downloader.cmd" %%a
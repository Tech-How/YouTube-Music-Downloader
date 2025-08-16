:YTM Music Scraper
:Created by Tristian Dedinas - https://github.com/Tech-How
:Version 1.3

:Uses third-party licenses
:yt-dlp - https://github.com/yt-dlp/yt-dlp

@echo off
title YTM Downloader
goto integritycheck
:integritypass
cls
set checkBusy=0
if exist Cache set /a checkBusy=%checkBusy%+1
if exist YTMusic set /a checkBusy=%checkBusy%+1
if %checkBusy%==2 echo Not so fast^! It appears music is already being downloaded. && echo Please wait for the current download to finish. && echo. && echo If this isn't the case, another download may have been interrupted. && echo Deleting the Cache and YTMusic folders will resolve this issue. && pause && exit
if exist "%~dp0Redistributables\LastRun.txt" goto cleanup

:start
:yt-dl-update
set engineUpdatesAllowed=0
set lastUpdateCheck=0
if exist Settings\engineUpdatesAllowed.txt set/p engineUpdatesAllowed=<Settings\engineUpdatesAllowed.txt
set engineUpdatesAllowed=%engineUpdatesAllowed: =%
if %engineUpdatesAllowed%==false goto yt-dl-update-skip
if exist Settings\lastUpdateCheck.txt set/p lastUpdateCheck=<Settings\lastUpdateCheck.txt
set lastUpdateCheck=%lastUpdateCheck: =%
for /F "tokens=2 delims=. " %%a in ("%date%") do set "currentDate=%%a"
if "%currentDate%" equ "%lastUpdateCheck%" goto yt-dl-update-skip
echo Checking for engine updates...
Redistributables\YouTube-DL\youtube-dl.exe --update >nul 2>&1
echo %currentDate% > Settings\lastUpdateCheck.txt
echo true > Settings\engineUpdatesAllowed.txt
cls

:yt-dl-update-skip
goto help

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

:parseNow
cls
title Loading...
echo Please wait while your music is being prepared. This may take a few minutes.
echo ...
timeout 1 /nobreak >nul
echo Fetching track information for URL:
echo %URL%
Redistributables\YouTube-DL\youtube-dl.exe --ffmpeg-location "%~dp0Redistributables\FFMPEG\bin\ffmpeg.exe" -i --get-id %URL% >> "%~dp0URLs.txt"
cls
title YTM Downloader
echo Success^!
echo.
echo To download this music now, close this script and run the downloader.
echo You can also add more music to download below.
echo.
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
if not exist Redistributables\FFMPEG\bin goto prepare_redistributables
if not exist Redistributables\YouTube-DL\youtube-dl.exe goto prepare_redistributables
if not exist Redistributables\AlbumArtDownloader\aad.exe goto prepare_redistributables
:integritycheck_resume
set integrityverification=2
if not exist "Add Music.cmd" set integrityverification=1 && echo Missing "Add Music.cmd"
if not exist "Download.cmd" set integrityverification=1 && echo Missing "Download.cmd"
if not exist "Import.cmd" set integrityverification=1 && echo Missing "Import.cmd"
if not exist "Find Duplicates.cmd" set integrityverification=1 && echo Missing "Find Duplicates.cmd"
if not exist "Redistributables\AlbumArtDownloader\aad.exe" set integrityverification=1 && echo Missing "Redistributables\AlbumArtDownloader\aad.exe"
if not exist "Redistributables\FFMPEG\bin\ffmpeg.exe" set integrityverification=1 && echo Missing "Redistributables\FFMPEG\bin\ffmpeg.exe"
if not exist "Redistributables\YouTube-DL\youtube-dl.exe" set integrityverification=1 && echo Missing "Redistributables\YouTube-DL\youtube-dl.exe"
if not exist "Redistributables\Downloader.cmd" set integrityverification=1 && echo Missing "Redistributables\Downloader.cmd"
if not exist "Redistributables\Get Info.cmd" set integrityverification=1 && echo Missing "Redistributables\Get Info.cmd"
if not exist "Redistributables\Sleep.vbs" set integrityverification=1 && echo Missing "Redistributables\Sleep.vbs"
if not exist "Redistributables\msg.exe" set integrityverification=1 && echo Missing "Redistributables\msg.exe"
if %integrityverification%== 2 goto integritypass
echo.
echo One or more of the required redistributables is missing or not found. Please visit this project on GitHub.
echo The program cannot continue.
timeout -1 /nobreak >nul
exit

:prepare_redistributables
echo Setting up...
echo.
if exist Redistributables\YouTube-DL\yt-dlp.exe ren Redistributables\YouTube-DL\yt-dlp.exe youtube-dl.exe
if exist Redistributables\FFMPEG\ffmpeg-2021-02-07-git-a52b9464e4-full_build.zip (
tar.exe -x -v -f "Redistributables\FFMPEG\ffmpeg-2021-02-07-git-a52b9464e4-full_build.zip" -C "Redistributables\FFMPEG" >nul 2>&1
move Redistributables\FFMPEG\ffmpeg-2021-02-07-git-a52b9464e4-full_build\bin Redistributables\FFMPEG\ >nul 2>&1
move Redistributables\FFMPEG\ffmpeg-2021-02-07-git-a52b9464e4-full_build\doc Redistributables\FFMPEG\ >nul 2>&1
move Redistributables\FFMPEG\ffmpeg-2021-02-07-git-a52b9464e4-full_build\presets Redistributables\FFMPEG\ >nul 2>&1
move Redistributables\FFMPEG\ffmpeg-2021-02-07-git-a52b9464e4-full_build\LICENSE Redistributables\FFMPEG\ >nul 2>&1
move Redistributables\FFMPEG\ffmpeg-2021-02-07-git-a52b9464e4-full_build\README.txt Redistributables\FFMPEG\ >nul 2>&1
rd Redistributables\FFMPEG\ffmpeg-2021-02-07-git-a52b9464e4-full_build >nul 2>&1
del /q Redistributables\FFMPEG\ffmpeg-2021-02-07-git-a52b9464e4-full_build.zip
)
if exist "C:\Program Files\AlbumArtDownloader" (
copy /y "C:\Program Files\AlbumArtDownloader" "Redistributables\AlbumArtDownloader" >nul 2>&1
del /q "Redistributables\AlbumArtDownloader\AlbumArt.exe"
Redistributables\msg.exe %username% All required files from AlbumArtDownloader have been copied to this project folder. You're free to uninstall the program now if you'd like.
)
goto integritycheck_resume

:help
if exist Settings\helpShown.txt goto prompt
if exist Settings echo shown > Settings\helpShown.txt
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
goto prompt
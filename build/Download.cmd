:YTM Download Launcher
:Created by Tech How - https://github.com/Tech-How
:Version 1.2

:Uses third-party licenses
:yt-dlp - https://github.com/yt-dlp/yt-dlp
:ffmpeg - https://ffmpeg.org/
:Album Art Downloader - https://sourceforge.net/projects/album-art/

@echo off
title YTM Downloader
goto integritycheck
:integritypass
cls
if exist "%~dp0Redistributables\LastRun.txt" goto cleanup

:start
if exist "%~dp0Redistributables\Track.txt" del /q "%~dp0Redistributables\Track.txt"
if exist "%~dp0Redistributables\TotalTracks.txt" del /q "%~dp0Redistributables\TotalTracks.txt"
if not exist "%~dp0URLs.txt" echo You haven't added any music to download! Paste your links in the Add Music script first. && echo Press any key to exit... && pause >nul && exit

if not exist Settings goto setup
rd Settings >nul 2>&1
timeout 1 /nobreak >nul
if not exist Settings goto setup
if not exist Settings\autoImport.txt goto setup

:initialize
set autoImport=false
set/p autoImport=<Settings\autoImport.txt
set autoImport=%autoImport: =%

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
msg %username% All required files from AlbumArtDownloader have been copied to this project folder. You're free to uninstall the program now if you'd like.
)
goto integritycheck_resume

:setup
md Settings >nul 2>&1
echo This script has been run for the first time. Please configure it below.
echo ^(Respond to the prompts by pressing the letters "Y" or "N" on your keyboard.^)
echo.
echo After the songs have been downloaded, should they be automatically imported into your
echo default media player? [Y/N]
choice /c yn /n /m "> "
if errorlevel 2 goto 7
if errorlevel 1 goto 2
:2
cls
if exist Settings\importMode.txt echo true > Settings\autoImport.txt && goto setup_end
set "setting=importMode" && set "returnto=6"
echo There are 2 modes that can be used for auto import. Please select the correct mode based
echo on your specific media player.
echo.
echo Mode 1: Just open files with default media player (Eg. iTunes)
echo Mode 2: Move files to a media folder (Eg. VLC, Plex, Kodi, MusicBee)
echo.
echo Press numbers 1 or 2, or press Q to quit.
choice /c 12q /n /m "> "
if errorlevel 3 goto setup_abort
if errorlevel 2 cls && goto 3
if errorlevel 1 set value=open && goto setup_write
:3
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
if "%folder%"=="notSelected" cls && echo ERROR: No folder selected. && echo. && goto 3
cls
echo The path "%folder%" will be used for all downloaded music.
set "folder=%folder: =/%"
pause
:4
cls
set "setting=importDestination" && set "returnto=5"
set "value=%folder%" && goto setup_write
:5
set "setting=importMode" && set "returnto=6"
set value=move && goto setup_write
:6
set "setting=autoImport" && set "returnto=setup_end"
set value=true && goto setup_write
:7
set "setting=autoImport" && set "returnto=setup_end"
set value=false && goto setup_write
:setup_end
cls
echo Setup complete. You can edit these options anytime in the Settings folder.
pause
cls
goto initialize
exit

:setup_write
echo %value% > "Settings\%setting%.txt"
goto %returnto%
exit

:setup_abort
rd /s /q Settings >nul 2>&1
exit

:singles
for /f "usebackq tokens=*" %%a in ("%~dp0URLs.txt") do call "%~dp0Redistributables\Downloader.cmd" %%a
timeout 1 /nobreak >nul
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
if %autoImport%==true Import.cmd "%saveFolder%"
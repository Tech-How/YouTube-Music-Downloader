:: YTM Downloader Setup Tool
:: Created by Tech How - https://github.com/Tech-How
:: Version 1.4

@echo off
cd /d "%~dp0.."
md Settings >nul 2>&1
if not exist "Settings\Reset App.cmd" echo "..\Download.cmd" /reset > "Settings\Reset App.cmd"
if not exist "Settings\Skip Download.cmd" echo "..\Download.cmd" /skip > "Settings\Skip Download.cmd"
echo %*|find "/validate_prepare" >nul 2>&1 && goto validate
echo %*|find "/run_wizard_import" >nul 2>&1 && goto wizard_import
echo %*|find "/run_wizard_video" >nul 2>&1 && goto wizard_video
echo %*|find "/run_wizard" >nul 2>&1 && goto wizard_start
echo No argument passed.
exit /b 1

:: Check if all files are intact
:validate
if not exist Redistributables\FFMPEG\bin goto prepare
if not exist Redistributables\yt-dlp\yt-dlp.exe goto prepare
if not exist Redistributables\AlbumArtDownloader\aad.exe goto prepare
:validate_resume
set validation_result=2
if not exist "Add Music.cmd" set validation_result=1 && echo Missing "Add Music.cmd"
if not exist "Add Videos.cmd" set validation_result=1 && echo Missing "Add Videos.cmd"
if not exist "Download.cmd" set validation_result=1 && echo Missing "Download.cmd"
if not exist "Import.cmd" set validation_result=1 && echo Missing "Import.cmd"
if not exist "Find Duplicates.cmd" set validation_result=1 && echo Missing "Find Duplicates.cmd"
if not exist "Redistributables\AlbumArtDownloader\aad.exe" set validation_result=1 && echo Missing "Redistributables\AlbumArtDownloader\aad.exe"
if not exist "Redistributables\FFMPEG\bin\ffmpeg.exe" set validation_result=1 && echo Missing "Redistributables\FFMPEG\bin\ffmpeg.exe"
if not exist "Redistributables\yt-dlp\yt-dlp.exe" set validation_result=1 && echo Missing "Redistributables\yt-dlp\yt-dlp.exe"
if not exist "Redistributables\Downloader.cmd" set validation_result=1 && echo Missing "Redistributables\Downloader.cmd"
if not exist "Redistributables\Get Info.cmd" set validation_result=1 && echo Missing "Redistributables\Get Info.cmd"
if not exist "Redistributables\Sleep.vbs" set validation_result=1 && echo Missing "Redistributables\Sleep.vbs"
if not exist "Redistributables\msg.exe" set validation_result=1 && echo Missing "Redistributables\msg.exe"
if %validation_result%==2 (
    exit /b 0
) else (
    exit /b 1
)

:: Configure redistributables on first program run
:prepare
echo Setting up...
echo.
if exist Redistributables\FFMPEG\ffmpeg-master-latest-win64-gpl-shared.zip (
    tar.exe -x -v -f "Redistributables\FFMPEG\ffmpeg-master-latest-win64-gpl-shared.zip" -C "Redistributables\FFMPEG" >nul 2>&1
    move Redistributables\FFMPEG\ffmpeg-master-latest-win64-gpl-shared\bin Redistributables\FFMPEG\ >nul 2>&1
    move Redistributables\FFMPEG\ffmpeg-master-latest-win64-gpl-shared\doc Redistributables\FFMPEG\ >nul 2>&1
    move Redistributables\FFMPEG\ffmpeg-master-latest-win64-gpl-shared\include Redistributables\FFMPEG\ >nul 2>&1
    move Redistributables\FFMPEG\ffmpeg-master-latest-win64-gpl-shared\lib Redistributables\FFMPEG\ >nul 2>&1
    move Redistributables\FFMPEG\ffmpeg-master-latest-win64-gpl-shared\presets Redistributables\FFMPEG\ >nul 2>&1
    move Redistributables\FFMPEG\ffmpeg-master-latest-win64-gpl-shared\LICENSE.txt Redistributables\FFMPEG\ >nul 2>&1
    rd Redistributables\FFMPEG\ffmpeg-master-latest-win64-gpl-shared >nul 2>&1
    del /q Redistributables\FFMPEG\ffmpeg-master-latest-win64-gpl-shared.zip
)
if not exist "Redistributables\AlbumArtDownloader\aad.exe" (
    if exist "C:\Program Files\AlbumArtDownloader" (
        copy /y "C:\Program Files\AlbumArtDownloader" "Redistributables\AlbumArtDownloader" >nul 2>&1
        del /q "Redistributables\AlbumArtDownloader\AlbumArt.exe"
        del /q "Redistributables\AlbumArtDownloader\uninst.exe"
        Redistributables\msg.exe %username% All required files from AlbumArtDownloader have been copied to this project folder. You're free to uninstall the program now if you'd like.
    )
)
goto validate_resume

:: Initial program setup/configurator
:wizard_start
if exist Settings\autoImport.txt goto wizard_import
cls
md Settings >nul 2>&1
echo This script has been run for the first time. Please configure it below.
echo ^(Respond to the prompts by pressing the letters "Y" or "N" on your keyboard.^)
echo.
echo After the songs have been downloaded, should they be automatically imported into your
echo default media player? [Y/N]
choice /c yn /n /m "> "
if errorlevel 2 (
    set "setting=autoImport"
    set "value=false"
    set "returnto=setup_end"
    goto setup_write
)
if errorlevel 1 (
    set "setting=autoImport"
    set "value=true"
    set "returnto=wizard_import"
    goto setup_write
)
:wizard_import
if exist Settings\importMode.txt goto setup_end
cls
set "setting=importMode"
set "returnto=setup_end"
echo There are 2 modes that can be used for importing. Please select the correct mode based
echo on your specific media player's configuration.
echo NOTE: Importing files in playlist/download order is only available with Mode 1.
echo.
echo Mode 1: Just open files with default media player, and allow the player to handle the import.
echo Mode 2: Move files to a media folder that your player reads from.
echo.
echo Press numbers 1 or 2:
choice /c 12 /n /m "> "
if errorlevel 2 cls && goto wizard_import_select
if errorlevel 1 set value=open && goto setup_write
:wizard_import_select
echo To continue, you'll need to specify a folder for the audio files to be moved to.
echo Press any key to select a destination folder...
pause >nul
set "folderprompt=Select folder"
set "defaultfolderlocation=%userprofile%\Music"
set PScommand=powershell "Add-Type -AssemblyName System.Windows.Forms; $FolderBrowse = New-Object System.Windows.Forms.OpenFileDialog -Property @{ValidateNames = $false;CheckFileExists = $false;RestoreDirectory = $true;initialDirectory = '%defaultfolderlocation%';Filter = 'Folders|*.';FileName = '%folderprompt%';};$null = $FolderBrowse.ShowDialog();$FolderName = Split-Path -Path $FolderBrowse.FileName;Write-Output $FolderName"
for /f "usebackq tokens=*" %%q in (`%PScommand%`) do set "folder=%%q"
if "%folder%"=="" (
    cls
    echo ERROR: No folder selected.
    echo.
    goto wizard_import_select
)
cls
echo The path "%folder%" will be used for all downloaded music.
set "folder=%folder: =/%"
pause
cls
set "setting=importDestination"
set "value=%folder%"
set "returnto=wizard_import_2"
goto setup_write
:wizard_import_2
set "setting=importMode"
set value=move
set "returnto=setup_end"
goto setup_write
:wizard_video
if exist Settings\videoFormat.txt exit /b 0
cls
echo By default, videos are downloaded in .mkv format to support the highest available resolution.
echo .mp4 files may not always be available in the video's native resolution, and may be restricted to 1080p or below.
echo.
echo For archiving and preserving YouTube content, .mkv is always recommended.
echo For general purpose use where quality is not of utmost importance, .mp4 can be used instead for broader compatibility.
echo Learn more on this project's README.
echo.
echo Please select your preferred download mode. This only applies when you're downloading video content.
echo You can change this anytime in the Settings folder.
echo 1. mkv (Will always download highest available resoluton)
echo 2. mp4 (May max out at 1080p)
choice /c 12 /n /m "> "
if errorlevel 2 (
    set "setting=videoFormat"
    set value=mp4
    set "returnto=setup_end"
    goto setup_write
)
if errorlevel 1 (
    set "setting=videoFormat"
    set value=mkv
    set "returnto=setup_end"
    goto setup_write
)
:setup_end
cls
echo Setup complete. You can edit these options anytime in the Settings folder.
pause
cls
exit /b 0

:: Write specified config to disk
:setup_write
echo %value% > "Settings\%setting%.txt"
goto %returnto%
exit
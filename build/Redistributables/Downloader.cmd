:: YTM Download Script
:: Created by Tech How - https://github.com/Tech-How
:: Version 1.4

:: Uses third-party licenses
:: yt-dlp - https://github.com/yt-dlp/yt-dlp
:: ffmpeg - https://ffmpeg.org/
:: Album Art Downloader - https://sourceforge.net/projects/album-art/

:: This script is called one time for each item that needs to be downloaded.
:: The expected input is: Downloader.cmd VIDEO_ID TRACK_COUNT CONTENT_TYPE DOWNLOAD_TYPE DOWNLOAD_FORMAT
:: The TRACK_COUNT parameter is used for display purposes only within the script. The actual track reading and writing is done via files created by the caller script.
:: CONTENT_TYPE accepts 0 for an official audio track, and 1 for a video.
:: DOWNLOAD_TYPE is only required if the CONTENT_TYPE is 1. It accepts 0 or 1. 0 downloads the raw video, 1 converts it to audio.
:: DOWNLOAD_FORMAT accepts 0 for mkv and 1 for mp4, again, only required if CONTENT_TYPE is a video.
:: Video downloading does NOT support any of the advanced metadata features of audio tracks, and is not recommended unless there is NO audio version available.
:: This script is not intended to be used standalone, and may misbehave if run out of context. I added these comments in case people would try to run this instead.

@echo off
:: Validate content type
if "%1"=="" echo ERROR && echo This script does not function standalone. Use the other launcher scripts in the parent directory. && pause && exit /b 1
set "ID=%1"
set video_mode=0
if "%3"=="1" goto video_mode

:: Set up temporary downloading environment
set "workingDir=%~dp0.."
if not exist "%workingDir%\YTMusic" md "%workingDir%\YTMusic"
cd /d "%workingDir%"
:tempdir
set tempsave=%random%
md "%workingDir%\Cache\%tempsave%"
if errorlevel 1 goto tempdir

:: Progress logic
:progress
set /p dlProgress=<Redistributables\dlProgress
set dlProgress=%dlProgress: =%
set /a dlProgress=%dlProgress%+1
echo.
echo.
echo Fetching track %dlProgress%/%2...
title Download - %dlProgress%/%2
echo.
echo.
echo %dlProgress% > Redistributables\dlProgress

:: Track number counting
cd Redistributables
echo %date% %time% > LastRun.txt
if not exist TotalTracks.txt set currenttrack=1 && set totaltracks=1 && goto download
set /p totaltracks=<TotalTracks.txt
set /p currenttrack=<Track.txt
set /a currenttrack=%currenttrack%+1
echo %currenttrack% > Track.txt

:: Download YouTube audio to cache and store file name in variable
:download
cd..
set MAXIMUM_RETRIES=9999
set currenttrack=%currenttrack: =%
set totaltracks=%totaltracks: =%
set dlTryCount=0
set dlTrySeconds=0
set dlRetryDest=dlRetry
set dlFailDest=dlFail
set content_display=track
cd .
:dlRetry
Redistributables\yt-dlp\yt-dlp.exe "https://www.youtube.com/watch?v=%ID%" -o "%workingDir%\Cache\%tempsave%\%%(track)s;%%(artist)s;%%(album)s;" -x --audio-format mp3 --no-warnings --embed-metadata --no-check-certificate --audio-quality 0 --restrict-filenames --ffmpeg-location "%~dp0FFMPEG\bin\ffmpeg.exe" --postprocessor-args "-metadata track="%currenttrack%/%totaltracks%" -metadata disc="1/1""
if errorlevel 1 (
	:dlErrCatch
	if %dlTryCount%==%MAXIMUM_RETRIES% (
		echo.
		echo.
		echo -------------------------------------------
		echo FATAL: Download of %content_display% ID %ID% failed^!
		echo Request rejected by Google. Not retrying.
		echo -------------------------------------------
		echo.
		echo.
		goto %dlFailDest%
	)
	if exist Redistributables\skipItem (
		echo.
		echo.
		echo Skipping %content_display% ID %ID% as requested by user.
		echo.
		echo.
		del /q Redistributables\skipItem
		goto %dlFailDest%
	)
	set /a dlTryCount=%dlTryCount%+1
	set /a dlTrySeconds=%dlTrySeconds%+15
	echo.
	echo.
	echo -----------------------------------------------------------
	echo ERROR: Download of %content_display% ID %ID% failed^!
	echo Request rejected by Google. Retrying in %dlTrySeconds%...
	echo ^(Run Download.cmd /skip to abort.^)
	echo -----------------------------------------------------------
	echo.
	echo.
	timeout %dlTrySeconds%
	goto %dlRetryDest%
)
:dlFail
for /f "tokens=* usebackq" %%f in (`dir /b /a-d "%workingDir%\Cache\%tempsave%"`) do set filename1=%%f

:: Replace underscores with spaces and rename file
:format_name_compliant
set filename=%filename1:_= %
ren "%workingDir%\Cache\%tempsave%\%filename1%" "%filename%"

::Parse variable to retreive original track metadata
:retrieve_metadata_compliant
for /f "tokens=1 delims=;" %%f in ("%filename%") do set track=%%f
for /f "tokens=2 delims=;" %%f in ("%filename%") do set artist=%%f
for /f "tokens=3 delims=;" %%f in ("%filename%") do set album=%%f

:: Retrieve non-ASCII metadata
:retrieve_metadata_full
for /f "tokens=* usebackq" %%f in (`call "%~dp0Get Info.cmd" "%workingDir%\Cache\%tempsave%\%filename%" 13`) do set artistfull=%%f
for /f "tokens=* usebackq" %%f in (`call "%~dp0Get Info.cmd" "%workingDir%\Cache\%tempsave%\%filename%" 14`) do set albumfull=%%f
set d[artistfull]="%artistfull:,=" "%"
for %%g in (%d[artistfull]%) do set "d[artistfull]=%%~g"
setlocal enabledelayedexpansion
set "artistdisplay=!artistfull:,%d[artistfull]%= &%d[artistfull]%!"
(endlocal
set "artistdisplay=%artistdisplay%"
)

:: Get first artist in non-ASCII metadata
:retrieve_artist_first
for /f "tokens=1 delims=," %%f in ("%artistfull%") do set artistfull=%%f

:: Move song to Artist folder if already exists
:duplicate_title_handler
set "trackLocator=%track%"
if exist "%workingDir%\YTMusic\%track%.mp3" set "trackLocator=%artist%\%track%" && md "%workingDir%\YTMusic\%artist%"

:: Search iTunes store for album artwork using the first artist credited in the file
:: iTunes is used as their search formatting has been standardized for decades and has a higher chance of returning valid results
:: YouTube is not used because they serve a rectangular thumbnail, not a square album cover
:retrieve_artwork
ren "%workingDir%\Cache\%tempsave%\%filename%" "%track%.tmp.mp3"
set keepAlbumCover=0
if exist "%workingDir%\Cache\Album.jpg" copy "%workingDir%\Cache\Album.jpg" "%workingDir%\Cache\%tempsave%\%track%.jpg" && goto format_file_full
cd Redistributables
if exist TotalTracks.txt set keepAlbumCover=1
cd..
echo.
echo Searching for artwork...
Redistributables\AlbumArtDownloader\aad.exe /ar "%artistfull%" /al "%albumfull%" /p "%workingDir%\Cache\%tempsave%\%track%.jpg" /s "iTunes"
if not exist "%workingDir%\Cache\%tempsave%\%track%.jpg" goto format_file_min
echo Success
echo.

:: Use FFMPEG to embed album artwork, re-format contributing artists, and strip unnecessary data
:format_file_full
if %keepAlbumCover%== 1 copy "%workingDir%\Cache\%tempsave%\%track%.jpg" "%workingDir%\Cache\Album.jpg"
Redistributables\FFMPEG\bin\ffmpeg.exe -i "%workingDir%\Cache\%tempsave%\%track%.tmp.mp3" -i "%workingDir%\Cache\%tempsave%\%track%.jpg" -map 0:0 -map 1:0 -c copy -id3v2_version 3 -metadata artist="%artistdisplay%" -metadata album_artist="%artistdisplay%" -metadata synopsis=\"\" -metadata description=\"\" -metadata purl=\"\" -metadata comment=\"\" "%workingDir%\YTMusic\%trackLocator%.mp3"
goto end

:: Re-format contributing artists without embedding album artwork, if none is available
:format_file_min
echo No artwork found
echo.
Redistributables\FFMPEG\bin\ffmpeg.exe -i "%workingDir%\Cache\%tempsave%\%track%.tmp.mp3" -map 0:0 -c copy -id3v2_version 3 -metadata artist="%artistdisplay%" -metadata album_artist="%artistdisplay%" -metadata synopsis=\"\" -metadata description=\"\" -metadata purl=\"\" -metadata comment=\"\" "%workingDir%\YTMusic\%trackLocator%.mp3"
goto end

:: Video support via separate caller script
:video_mode
set video_mode=1
if "%4"=="0" ( set "audio_only=0" ) else ( set "audio_only=1" )
if "%5"=="0" ( set "video_format=mkv" ) else ( set "video_format=mp4" )
echo %date% %time% > Redistributables\LastRun.txt

:: Video support for progress logic
:progress_video
set /p dlProgress=<Redistributables\dlProgress
set dlProgress=%dlProgress: =%
set /a dlProgress=%dlProgress%+1
echo.
echo.
echo Fetching video %dlProgress%/%2...
if %audio_only%==1 echo ^(Only the audio will be saved.^)
title Download - %dlProgress%/%2
echo.
echo.
echo %dlProgress% > Redistributables\dlProgress

:: Video support for downloading environment
md "%~dp0..\Cache01" >nul 2>&1
if %audio_only%==0 md "%~dp0..\Video Downloads" >nul 2>&1
if %audio_only%==1 md "%~dp0..\Audio Downloads" >nul 2>&1
set cache_path=%~dp0..\Cache01
if %audio_only%==0 set video_path=%~dp0..\Video Downloads
if %audio_only%==1 set video_path=%~dp0..\Audio Downloads

:: Video support for downloader code
:download_video
set MAXIMUM_RETRIES=9999
set dlTryCount=0
set dlTrySeconds=0
set dlRetryDest=dlRetry_video
set dlFailDest=dlFail_video
set content_display=video
cd .
:dlRetry_video
if "%audio_only%"=="0" (
	if "%video_format%"=="mkv" (
		Redistributables\yt-dlp\yt-dlp.exe "https://www.youtube.com/watch?v=%ID%" -o "%cache_path%\%%(channel)s - %%(title)s" --no-warnings --embed-metadata --no-check-certificate --audio-quality 0 --merge-output-format mkv --ffmpeg-location "%~dp0FFMPEG\bin\ffmpeg.exe"
	) else if "%video_format%"=="mp4" (
		REM Allow mp4 native streams only and don't re-encode, will limit resolution but works on most media players
		Redistributables\yt-dlp\yt-dlp.exe "https://www.youtube.com/watch?v=%ID%" -o "%cache_path%\%%(channel)s - %%(title)s" --no-warnings --embed-metadata --no-check-certificate -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" --merge-output-format mp4 --ffmpeg-location "%~dp0FFMPEG\bin\ffmpeg.exe"

		REM Force a re-encode from nonstandard formats to mp4, allows higher resolutions but may not work on all media players
		REM Redistributables\yt-dlp\yt-dlp.exe "https://www.youtube.com/watch?v=%ID%" -o "%cache_path%\%%(channel)s - %%(title)s" --no-warnings --embed-metadata --no-check-certificate --audio-quality 0 --merge-output-format mp4 --ffmpeg-location "%~dp0FFMPEG\bin\ffmpeg.exe"
	)
)
if errorlevel 1 goto dlErrCatch
if "%audio_only%"=="1" Redistributables\yt-dlp\yt-dlp.exe "https://www.youtube.com/watch?v=%ID%" -o "%cache_path%\%%(channel)s - %%(title)s_Audio" -x --audio-format mp3 --no-warnings --embed-metadata --no-check-certificate --audio-quality 0 --ffmpeg-location "%~dp0FFMPEG\bin\ffmpeg.exe"
if errorlevel 1 goto dlErrCatch

move /y "%cache_path%\*" "%video_path%"
for /d %%a in ("%cache_path%\*") do move /y "%%~fa" "%video_path%" >nul 2>&1

:dlFail_video

:: Clean cache and return to parent script
:end
if %video_mode%==0 rd /s /q "%workingDir%\Cache\%tempsave%"
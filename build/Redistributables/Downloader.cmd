:YTM Download Script
:Created by Tech How - https://github.com/Tech-How
:Version 1.0

:Uses third-party licenses
:yt-dlp - https://github.com/yt-dlp/yt-dlp
:ffmpeg - https://ffmpeg.org/
:Album Art Downloader - https://sourceforge.net/projects/album-art/

@echo off
set "URL=%1"
set "workingDir=%~dp0.."
if not exist "%workingDir%\YTMusic" md "%workingDir%\YTMusic"
cd /d %workingDir%
:tempdir
set temp=%random%
md "%workingDir%\Cache\%temp%"
if errorlevel 1 goto tempdir

:Check whether or not to count track numbers
cd Redistributables
echo %date% %time% > LastRun.txt
if not exist TotalTracks.txt set currenttrack=1 && set totaltracks=1 && goto Download
set /p totaltracks=<TotalTracks.txt
set /p currenttrack=<Track.txt
set /a currenttrack=%currenttrack%+1
echo %currenttrack% > Track.txt

:Download YouTube audio to cache and store file name in variable
cd..
set currenttrack=%currenttrack: =%
set totaltracks=%totaltracks: =%
Redistributables\YouTube-DL\youtube-dl.exe "https://www.youtube.com/watch?v=%URL%" -o "%workingDir%\Cache\%temp%\%%(track)s;%%(artist)s;%%(album)s;" -x --audio-format mp3 --no-warnings --embed-metadata --no-check-certificate --audio-quality 0 --restrict-filenames --ffmpeg-location "%~dp0FFMPEG\bin\ffmpeg.exe" --postprocessor-args "-metadata track="%currenttrack%/%totaltracks%""
for /f "tokens=* usebackq" %%f in (`dir /b /a-d "%workingDir%\Cache\%temp%"`) do set filename1=%%f

:Replace underscores with spaces and rename file
set filename=%filename1:_= %
ren "%workingDir%\Cache\%temp%\%filename1%" "%filename%"

:Parse variable to retreive original track metadata
for /f "tokens=1 delims=;" %%f in ("%filename%") do set track=%%f
for /f "tokens=2 delims=;" %%f in ("%filename%") do set artist=%%f
for /f "tokens=3 delims=;" %%f in ("%filename%") do set album=%%f

:Retrieve non-ASCII metadata
for /f "tokens=* usebackq" %%f in (`call "%~dp0Get Info.cmd" "%workingDir%\Cache\%temp%\%filename%" 13`) do set artistfull=%%f
for /f "tokens=* usebackq" %%f in (`call "%~dp0Get Info.cmd" "%workingDir%\Cache\%temp%\%filename%" 14`) do set albumfull=%%f
set d[artistfull]="%artistfull:,=" "%"
for %%g in (%d[artistfull]%) do set "d[artistfull]=%%~g"
setlocal enabledelayedexpansion
set "artistdisplay=!artistfull:,%d[artistfull]%= &%d[artistfull]%!"
(endlocal
set "artistdisplay=%artistdisplay%"
)

:Get first artist in non-ASCII metadata
for /f "tokens=1 delims=," %%f in ("%artistfull%") do set artistfull=%%f

:Move song to Artist folder if already exists
set "tracklocator=%track%"
if exist "%workingDir%\YTMusic\%track%.mp3" set "tracklocator=%artist%\%track%" && md "%workingDir%\YTMusic\%artist%"

:Search iTunes store for album artwork
ren "%workingDir%\Cache\%temp%\%filename%" "%track%.tmp.mp3"
set keepalbumcover=0
if exist "%workingDir%\Cache\Album.jpg" copy "%workingDir%\Cache\Album.jpg" "%workingDir%\Cache\%temp%\%track%.jpg" && goto Use
cd Redistributables
if exist TotalTracks.txt set keepalbumcover=1
cd..
Redistributables\AlbumArtDownloader\aad.exe /ar "%artistfull%" /al "%albumfull%" /p "%workingDir%\Cache\%temp%\%track%.jpg" /s "iTunes"
if errorlevel 1 goto Re-format

:Use FFMPEG to embed album artwork, re-format contributing artists, and strip unnecessary data
if %keepalbumcover%== 1 copy "%workingDir%\Cache\%temp%\%track%.jpg" "%workingDir%\Cache\Album.jpg"
Redistributables\FFMPEG\bin\ffmpeg.exe -i "%workingDir%\Cache\%temp%\%track%.tmp.mp3" -i "%workingDir%\Cache\%temp%\%track%.jpg" -map 0:0 -map 1:0 -c copy -id3v2_version 3 -metadata artist="%artistdisplay%" -metadata album_artist="%artistdisplay%" -metadata synopsis=\"\" -metadata description=\"\" -metadata purl=\"\" -metadata comment=\"\" "%workingDir%\YTMusic\%tracklocator%.mp3"
goto End

:Re-format contributing artists without embedding album artwork, if none is available
Redistributables\FFMPEG\bin\ffmpeg.exe -i "%workingDir%\Cache\%temp%\%track%.tmp.mp3" -map 0:0 -c copy -id3v2_version 3 -metadata artist="%artistdisplay%" -metadata album_artist="%artistdisplay%" -metadata synopsis=\"\" -metadata description=\"\" -metadata purl=\"\" -metadata comment=\"\" "%workingDir%\YTMusic\%tracklocator%.mp3"

:End
rd /s /q "%workingDir%\Cache\%temp%"
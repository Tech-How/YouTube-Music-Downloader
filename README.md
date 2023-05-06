# YouTube Music Downloader
A frontend for youtube-dlp, adding metadata to downloaded tracks.

<img src="https://raw.githubusercontent.com/Tech-How/YouTube-Music-Downloader/main/images/repo/readme/1.png"/>

This project will allow you to use [youtube-dlp](https://github.com/yt-dlp/yt-dlp) to download music from YouTube Music, and automatically add album artwork, artist name, album name, and track info to the files. They can then be added to a media player, such as iTunes or VLC, transferred to devices, or whatever you'd like. This project is still very early in development, and as such there will be issues. Some metadata pulled from YouTube is formatted in a way that confuses the downloader and will cause incorrect data to be applied. This document includes a detailed explanation of how the downloader works. If you find an issue that is reproducable under specific conditions, or have general feedback, feel free to open an issue report.

## v1.0 Release Notes
- First release!

## Setup Instructions
This project is written in batch, and requires additional programs that I do not own the license to in order to function correctly. Below are links to those programs, as well as where they need to be placed to be read by the downloader.
- If you haven't already, [download](https://github.com/Tech-How/YouTube-Music-Downloader/releases) the latest version of this project. **Unzip the contents** to a new directory.
- Download [yt-dlp](https://github.com/yt-dlp/yt-dlp/releases). (You are looking for yt-dlp.exe.) Once downloaded, save the file as **[Project Folder]\Redistributables\YouTube-DL\youtube-dl.exe**. _(You will need to **rename** the file.)_
- Download [FFMPEG](https://github.com/GyanD/codexffmpeg/releases/download/2021-02-07-git-a52b9464e4/ffmpeg-2021-02-07-git-a52b9464e4-full_build.zip). Once downloaded, **unzip** the contents to **[Project Folder]\Redistributables\FFMPEG**. _(There should be a bin, doc, and presets folder here.)_
- Download and install [Album Art Downloader](https://sourceforge.net/projects/album-art/). Once installed, **copy** the contents from (C:\Program Files\AlbumArtDownloader) to **[Project Folder]\Redistributables\AlbumArtDownloader, EXCEPT** for the Scripts folder, **do not** overwrite it.

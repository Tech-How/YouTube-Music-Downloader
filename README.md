# YouTube Music Downloader
A frontend for youtube-dlp, adding metadata to downloaded tracks.

<img src="https://raw.githubusercontent.com/Tech-How/YouTube-Music-Downloader/main/images/repo/readme/1.png"/>

This project will allow you to use [youtube-dlp](https://github.com/yt-dlp/yt-dlp) to download music from YouTube Music, and automatically add album artwork, artist name, album name, and track info to the files. They can then be added to a media player, such as iTunes or VLC, transferred to devices, or whatever you'd like. Unlike the `--embed-metadata` switch in youtube-dlp, this embeds the actual album cover, and not the video thumbnail. This project is still very early in development, and as such there will be issues. Some metadata pulled from YouTube is formatted in a way that confuses the downloader and will cause incorrect data to be applied. This document includes a detailed explanation of how the downloader works. If you find an issue that is reproducible under specific conditions, or have general feedback, feel free to open an issue report.

## v1.2 Release Notes
- Added script to import songs to a media player by playlist order or date downloaded
- Added script to check for duplicates in two folders
- Music is now organized into folders by the date they were downloaded
- Added support for disc numbers
- Cache folder is now automatically removed at the end of download
- The Add Music script will now alert you if a download is already in progress
- The Add Music script will now hide the instructions after being used for some time
- Added link to check for updates in project directory
- Made improvements to simplify initial setup process

## Setup Instructions
This project is written in batch, and requires additional programs that I do not own the license to in order to function correctly. Below are links to those programs, as well as where they need to be placed to be read by the downloader.
- If you haven't already, [download](https://github.com/Tech-How/YouTube-Music-Downloader/releases) and run the latest version of this project. A project folder will be generated; feel free to move this wherever you like.
- Download [yt-dlp](https://github.com/yt-dlp/yt-dlp/releases). (You are looking for yt-dlp.exe.) Once downloaded, save the file into **Redistributables\YouTube-DL**.
- Download [FFMPEG](https://github.com/GyanD/codexffmpeg/releases/download/2021-02-07-git-a52b9464e4/ffmpeg-2021-02-07-git-a52b9464e4-full_build.zip). Once downloaded, save the file into **Redistributables\FFMPEG**.
- Download and install [Album Art Downloader](https://sourceforge.net/projects/album-art/).
- You should be all set. The program will notify you if there are any missing components. Refer to the included Help file for more information.

## Other Information
(This information may be helpful when debugging the script. There are also detailed comments in [Project Folder]\Redistributables\Downloader.cmd.)
- To my knowledge, it is not currently possible to pull track numbers when the songs are called individually, which is how this script works. As such, unless the provided URL is specified as an album when being added, all songs will have track numbers of 1/1. If the user specifies that the URL is an album, the script will count up from 1 until it reaches the end. For this reason, it's best to only download one album at a time. For entire playlists of singles, this isn't important. Genre information will also be left blank for the time being.
- Artist information is formatted as `[Artist1 & Artist2 & Artist 3]` by default. When searching for album artwork, the script will pull the first item in the array. It will also re-format the artist data as `[Artist1, Artist2 & Artist3]`, where the last item in the data set will have an & symbol. If there are only 2 artists, the & symbol will be kept.
- When tracks are initially downloaded, all spaces are replaced with underscores, and any non-ASCII characters are stripped out to comply with the limits of Windows filenames. These are later replaced with spaces. The format for the initial download filename is `%(track)s;%(artist)s;%(album)s;`. These 3 items are separated by semicolons and are parsed out later. The final MP3 will be saved as the track name.
- If 2 of the same songs are found, the conflicting one is moved into a subfolder with the Artist name.

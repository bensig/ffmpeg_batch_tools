Bash scripts to batch video file conversions. Change variables of the script to suit your needs or create new ones using my code.

I built this because transcoding video with subtitles is a pain when I have to use After Effects or AVID.

This is tested and working on a Ubuntu 16.04 clean install. 

USAGE:
sudo FFmpeg_installer.sh - The installer script will download, compile, and install a version of ffmpeg for running these scripts as well as Google fonts for writing timecode onto your video.

TimeCodeBurn.sh - This will prompt you for a file input, then it will resize the video, extract and stripe timecode on the bottom of the video. This outputs a .mov of the same name.
BatchTimeCodeBurn.sh - Batch of above! This will recursively find all *.MP4 files in the directory where it is run and create .mov files with timecode burned-in.
ConvertDNXHD1080p.sh - This will prompt you for a file input, then it will resize the video to 1080p using DNXHD codec for AVID.
BatchConvertDNXHD1080p.sh - Batch of above! This will recursively find all *.MP4 files in the directory where it is run and create basename_dnxhd.mov files.

FUTURE: Possibly looking to make this more portable than Ubuntu 16.04 using Docker or Python or both! 

- bensig@gmail.com

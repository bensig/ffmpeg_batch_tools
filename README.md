Bash script to run ffmpeg on a single h264 mp4 file and output an mjpeg mov file at 1/4 resolution with nice timecode on it.

Change variables of the script to suit your needs.

I tested this on Ubuntu 16.04

Install these packages:
	sudo apt-get install libass-dev libtheora-dev libfreetype6-dev autoconf autogen

Then follow this guide:
	https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu

Download and install droid sans mono from google fonts
	DroidSansMono.ttf

You may need to change the location of the font on your system. On my system it is at:
	font=/usr/local/share/fonts/d/DroidSansMono_Regular.ttf

- bensig@gmail.com

#!/bin/bash
#This script will burn timecode from what is embedded in a video file
#in=/path/to/input_file
in=11000001.MP4
echo -e "$in"
#out=/path/to/ouput_file.mov
out="${in%.*}.mov"
echo -e "$out"
#TC rate should be identical to FPS
tcrate=24
#font size and position
font=/usr/local/share/fonts/d/DroidSansMono_Regular.ttf
fontsize=22
# time code position bottom center:
position="x=(w-tw)/2: y=h-(2*lh)"
# get the timecode, and escape the ":" to be able to use it in the burn-in filter
tcode=$( ffmpeg -i "$in" 2>&1 | awk '$1 ~ /^timecode/ {print $NF}' )
tc_escaped=${tcode//:/\\:}
#make this slower to increase quality over speed
preset=ultrafast
#remove audio
noaudio=-an
# And finally
ffmpeg -threads 0 -i "$in" $test_secs -pix_fmt yuvj422p -map 0:0 -map 0:1 $noaudio -c:v mjpeg -q:v 3 -huffman optimal -preset $preset -deinterlace -vf "scale=w=iw/4:h=ih/4,drawtext=fontfile=$font: timecode='$tc_escaped': r=$tcrate: $position: fontcolor=white: fontsize=$fontsize: box=1: boxcolor=black@0.2" "$out"

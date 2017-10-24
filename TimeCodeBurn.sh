#!/bin/bash
#This script will burn timecode from what is embedded in a video file
#in_file=/path/to/input_file
read -e -p "Enter path to input file:" in_file
echo -e "$in_file"
#out=/path/to/ouput_file.mov
out_file="${in_file%.*}.mov"
echo -e "$out_file"
#TC rate should be identical to FPS
timecode_rate=24
#font size and position
timecode_font="/usr/local/share/fonts/d/DroidSansMono_Regular.ttf"
timecode_font_size=22
timecode_font_color=white
timecode_box_color='black@0.5'
# time code position bottom center:
timecode_position="x=(w-tw)/2: y=h-(2*lh)"
# get the timecode of the first frame, and escape the ":" to be able to use it in the burn-in filter
timecode_subprocess=$( ffmpeg -i "$in_file" 2>&1 | awk '$1 ~ /^timecode/ {print $NF}' )
timecode_subprocess_timecode_formatted=${timecode_subprocess//:/\\:}
#scaling
video_resolution_scaling="scale=w=iw/4:h=ih/4"
video_endcoder='-pix_fmt yuvj422p -c:v mjpeg -huffman optimal'
video_variable_bitrate='-q:v 3'
#make this slower to increase quality over speed
video_encoder_preset='ultrafast'
#remove audio
audio_encoder_option='-an'
# And finally run the ffmpeg script
$path_to_ffmpeg/ffmpeg -threads 0 -i $in_file $audio_encoder_option $video_endcoder $video_variable_bitrate -preset $video_encoder_preset -deinterlace -vf "$video_resolution_scaling,drawtext=fontfile=$timecode_font: timecode='$timecode_subprocess_timecode_formatted': r=$timecode_rate: $timecode_position: fontcolor=$timecode_font_color: fontsize=$timecode_font_size: box=1: boxcolor=$timecode_box_color" "$out_file"

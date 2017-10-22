#!/bin/bash
#This script will burn timecode from what is embedded in a video file
#in_file_path=/path/to/input_file
for in_file_path in **/*.MP4; do
#out=/path/to/ouput_file.mov
out_file_path="${in_file_path%.*}.mov"
echo -e "$out_file_pah"
#TC rate should be identical to FPS
timecode_rate=24
#font size and position
timecode_font="/usr/local/share/fonts/d/DroidSansMono_Regular.ttf"
timecode_font_size=22
timecode_font_color=white
timecode_box_color='black@0.5'
# time code position bottom center:
timecode_position="x=(w-tw)/2: y=h-(2*lh)"
# get the timecode, and escape the ":" to be able to use it in the burn-in filter
timecode_subprocess=$( ffmpeg -i "$in_file_path" 2>&1 | awk '$1 ~ /^timecode/ {print $NF}' )
echo -e "This is the unformatted timecode $timecode_subprocess"
timecode_subprocess__timecode_formatted=${timecode_subprocess//:/\\:}
echo -e "This is the formatted timecode $timecode_subprocess__timecode_formatted"
#scaling
video_resolution_scaling="scale=w=iw/4:h=ih/4"
video_endcoder='-pix_fmt yuvj422p -c:v mjpeg -huffman optimal'
video_variable_bitrate='-q:v 3'
#make this slower to increase quality over speed
video_encoder_preset=ultrafast
#remove audio
audio_encoder_option='-an'
# And finally run the ffmpeg script
ffmpeg -threads 0 -i $in_file_path $audio_encoder_option $video_endcoder $video_variable_bitrate -preset $video_encoder_preset -deinterlace -vf "$video_resolution_scaling,drawtext=fontfile=$timecode_font: timecode='$timecode_subprocess__timecode_formatted': r=$timecode_rate: $timecode_position: fontcolor=$timecode_font_color: fontsize=$timecode_font_size: box=1: boxcolor=$timecode_box_color" "$out_file_path"
done

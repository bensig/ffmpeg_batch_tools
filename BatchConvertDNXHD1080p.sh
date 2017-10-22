#!/bin/bash
#This script will burn timecode from what is embedded in a video file
#in_file_path=/path/to/input_file
for in_file_path in **/*.MP4; do
#out=/path/to/ouput_file.mov
out_file_path="${in_file_path%.*}_dnxhd.mov"
echo -e "$out_file_pah"
#TC rate should be identical to FPS
timecode_rate=24
#scaling
video_resolution_scaling="scale=1920x1080,fps=30000/1001"
video_endcoder='-c:v dnxhd'
#remove audio
audio_encoder_option='-an'
# And finally run the ffmpeg script
#ffmpeg -threads 0 -i $in_file_path $audio_encoder_option $video_endcoder $video_variable_bitrate -preset $video_encoder_preset -deinterlace -vf "$video_resolution_scaling" $out_file_path
ffmpeg -threads 0 -i $in_file_path $audio_encoder_option -vf format=yuv422p10,scale=1920x1080 -r 24000/1001 -c:v dnxhd -b:v 175M $out_file_path
done

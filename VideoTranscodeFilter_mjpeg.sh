#!/bin/bash
#This script will convert video based on the video filters settings

#this is the function to run ffmpeg - variables can be changed to suit your needs
function ffmpeg_filters() {
  read -e -p "Enter path to input file:" in_file
  echo -e "$in_file"
  #this takes the basename of the file and adds _dnxhd - specifies output format as .mov
  out_file="${in_file%.*}_mjpeg.mov"
  echo -e "$out_file"
  #video encoder filters - can be changed, this is meant to maintain aspect ratio and convert to mjpeg
  video_endcoder="-c:v mjpeg -q:v 3 -huffman optimal"
  #remove audio
  audio_encoder_option="-an"
  # And finally run the ffmpeg script
  "$path_to_ffmpeg" -y -nostdin -threads 8 -i $in_file $audio_encoder_option $video_endcoder "$out_file"
}

#this runs the script
if [ -f source.cfg ]; then
    echo "Reading user config...." >&2
    source source.cfg
    ffmpeg_filters
  elif [ -f $HOME/ffmpeg/bin/ffmpeg ]; then
    echo "Located ffmpeg even without source.cfg"
    path_to_ffmpeg="$HOME/ffmpeg/bin/ffmpeg"
    ffmpeg_filters
  else
    echo "There is no configuration file called source.cfg - please create it and set the path_to_ffmpeg variable"
    echo "#example of source.cfg - remove the # comment on the 2nd line and paste these into a new file called source.cfg
       #variables to paths - do not include trailing slash on paths
       path_to_ffmpeg=$HOME/ffmpeg/bin/ffmpeg"
    exit
fi

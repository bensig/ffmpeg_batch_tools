#!/bin/bash
#This script will convert video based on the video filters settings

#this is the function to run ffmpeg - variables can be changed to suit your needs
function ffmpeg_filters() {
  read -e -p "Enter path to input file:" in_file
  echo -e "$in_file"
  #this takes the basename of the file and adds _dnxhd - specifies output format as .mov
  out_file="${in_file%.*}_dnxhd.mov"
  echo -e "$out_file"
  #video encoder filters - can be changed, this is meant to convert 4k to 1080p with padding
  video_filters=(format=yuv422p,scale="iw*min(1920/iw\,1080/ih):ih*min(1920/iw\,1080/ih)"\,pad="1920:1080:(1920-iw*min(1920/iw\,1080/ih))/2:(1080-ih*min(1920/iw\,1080/ih))/2",setsar=1:1)
  video_endcoder="-c:v dnxhd -b:v 36M"
  #remove audio
  audio_encoder_option="-an"
  # And finally run the ffmpeg script
  "$path_to_ffmpeg"/ffmpeg -y -nostdin -threads 8 -i $in_file $audio_encoder_option -vf $video_filters $video_endcoder "$out_file"
}

#this runs the script
if [ -f source.cfg ]; then
    echo "Reading user config...." >&2
    source source.cfg
    ffmpeg_filters
  elif [ -f $HOME/ffmpeg/bin/ffmpeg ]
    echo "Located ffmpeg even without source.cfg"
    $path_to_ffmpeg="$HOME/ffmpeg/bin"
    ffmpeg_filters
  else
    echo "There is no configuration file called source.cfg - please create it and set the path_to_ffmpeg variable"
    echo "#example of source.cfg - remove the # comment on the 2nd line and paste these into a new file called source.cfg
       #variables to paths - do not include trailing slash on paths
       path_to_ffmpeg=$HOME/ffmpeg/bin"
    exit
fi

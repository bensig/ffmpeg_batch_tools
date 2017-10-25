#!/bin/bash
#This script will recursively create video based on filters
function batch_ffmpeg_filters () {
  in_file=( )
  out_file=( )
  read -e -p "Please choose the folder that contains subfolders or videos you want to convert:" in_file_path
  find "$in_file_path" -iname "*MP4" | \
  while read -r in_file || [[ -n "${in_file}" ]]; do
      in_filename=$(basename "$in_file")
      out_file="${in_file%.MP4}_DNXHD.mov"
      #TC rate should be identical to FPS
      video_filters_array=(format=yuv422p,scale="iw*min(1920/iw\,1080/ih):ih*min(1920/iw\,1080/ih)"\,pad="1920:1080:(1920-iw*min(1920/iw\,1080/ih))/2:(1080-ih*min(1920/iw\,1080/ih))/2",setsar=1:1)
      video_endcoder="-c:v dnxhd -b:v 36M"
      #remove audio
      audio_encoder_option="-an"
      # And finally run the ffmpeg script
      "$path_to_ffmpeg"/ffmpeg -y -nostdin -threads 8 -i $in_file $audio_encoder_option -vf $video_filters_array $video_endcoder "$out_file"
      if [ "$?" -eq "0" ]; then
          printf -- 'ffmpeg succeeded - created movies!' "${in_file}" "${in_file}" "/n"
      else
          printf -- 'ffmpeg failed - was unable to create movies :()' "${i}" "${in_file}" "/n"
      fi
    done
}

if [ -f source.cfg ]; then
    echo "Reading user config...." >&2
    source source.cfg
    batch_ffmpeg_filters
  elif [ -f $HOME/ffmpeg/bin/ffmpeg ]; then
    echo "Located ffmpeg even without source.cfg"
    $path_to_ffmpeg="$HOME/ffmpeg/bin"
    batch_ffmpeg_filters
  else
    echo "There is no configuration file called source.cfg - please create it and set the path_to_ffmpeg variable"
    echo "#example of source.cfg - remove the # comment on the 2nd line and paste these into a new file called source.cfg
       #variables to paths - do not include trailing slash on paths
       path_to_ffmpeg=$HOME/ffmpeg/bin"
    exit

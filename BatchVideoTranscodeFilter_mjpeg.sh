#!/bin/bash
#This script will recursively create video based on video_filters_array and video_encoder filters set here
#this variable  sets the codec to mjpeg
video_endcoder="-c:v mjpeg -q:v 3 -huffman optimal"
#this variable removes audio to keep you can use -a copy
audio_encoder_option="-an"
function batch_ffmpeg_filters () {
  read -e -p "Please enter the folder that contains subfolders or videos you want to convert:" in_file_path
  read -e -p "Please enter the destination folder for transcoded videos - must end with slash:" out_file_path
  [[ -d $out_file_path ]] || mkdir -p $out_file_path
  find "$in_file_path" -iname "*mov" | \
  while read -r in_file || [[ -n "${in_file}" ]]; do
      in_filename=$(basename "$in_file")
      out_file="${in_filename%.mov}_MJPEG.mov"
      # And finally run the ffmpeg script
      "$path_to_ffmpeg" -y -nostdin -threads 8 -i $in_file $audio_encoder_option $video_endcoder "$out_file_path""$out_file"
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
    path_to_ffmpeg="$HOME/ffmpeg/bin/ffmpeg"
    batch_ffmpeg_filters
  else
    echo "There is no configuration file called source.cfg - please create it and set the path_to_ffmpeg variable"
    echo "#example of source.cfg - remove the # comment on the 2nd line and paste these into a new file called source.cfg
       #variables to paths - do not include trailing slash on paths
       path_to_ffmpeg=$HOME/ffmpeg/bin/ffmpeg"
    exit
fi

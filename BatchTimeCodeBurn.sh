#!/bin/bash
#This script will batch recursivly and burn timecode from what is embedded in a video file and resize the video to 1/4 resolution

function batch_ffmpeg_timecode_burn () {
  read -e -p "Please choose the folder that contains subfolders or videos you want to convert:" in_file_path
  read -e -p "Please enter the destination folder for transcoded videos - must end with slash:" out_file_path
  mkdir -p $out_file_path
  find "$in_file_path" -iname "*MP4" | \
  while read -r in_file || [[ -n "${in_file}" ]]; do
      in_filename=$(basename "$in_file")
      out_file="$out_file_path""${in_filename%.MP4}.mov"
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
      timecode_subprocess__timecode_formatted=${timecode_subprocess//:/\\:}
      #scaling for video resizer
      video_resolution_scaling="scale=w=iw/4:h=ih/4"
      video_endcoder='-pix_fmt yuvj422p -c:v mjpeg -huffman optimal'
      video_variable_bitrate='-q:v 3'
      #make this slower to increase quality over speed
      video_encoder_preset=ultrafast
      #remove audio
      audio_encoder_option='-an'
      # And finally run the ffmpeg script
      "$path_to_ffmpeg"/ffmpeg -y -nostdin -threads 0 -i $in_file $audio_encoder_option $video_endcoder $video_variable_bitrate -preset $video_encoder_preset -deinterlace -vf "$video_resolution_scaling,drawtext=fontfile=$timecode_font: timecode='$timecode_subprocess__timecode_formatted': r=$timecode_rate: $timecode_position: fontcolor=$timecode_font_color: fontsize=$timecode_font_size: box=1: boxcolor=$timecode_box_color" "$out_file"
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
    batch_ffmpeg_timecode_burn
  elif [ -f $HOME/ffmpeg/bin/ffmpeg ]; then
    echo "Located ffmpeg even without source.cfg"
    $path_to_ffmpeg="$HOME/ffmpeg/bin"
    batch_ffmpeg_timecode_burn
  else
    echo "There is no configuration file called source.cfg - please create it and set the path_to_ffmpeg variable"
    echo "#example of source.cfg - remove the # comment on the 2nd line and paste these into a new file called source.cfg
       #variables to paths - do not include trailing slash on paths
       path_to_ffmpeg=$HOME/ffmpeg/bin"
    exit
fi

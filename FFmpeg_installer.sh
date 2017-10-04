#Based on from https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu
# created by bensig on 10/4/2017
#Prep steps: 
mkdir ~/ffmpeg_sources
sudo apt-get remove ffmpeg 
sudo apt-get update && sudo apt-get install --no-upgrade libtheora-dev libass-dev libfreetype6-dev autoconf autogen automake build-essential libsdl2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev pkg-config texinfo wget zlib1g-dev yasm libx264-dev libx265-dev libfdk-aac-dev libmp3lame-dev libopus-dev libvpx-dev

#install x265 manually - this seems to fail in ubuntu apt/ffmpeg installer
sudo apt-get install cmake mercurial
cd ~/ffmpeg_sources
hg clone https://bitbucket.org/multicoreware/x265
cd ~/ffmpeg_sources/x265/build/linux
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED:bool=off ../../source
make
make install

#download and install ffmpeg
cd ~/ffmpeg_sources
wget http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
tar xjvf ffmpeg-snapshot.tar.bz2
cd ffmpeg
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
  --prefix="$HOME/ffmpeg_build" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I$HOME/ffmpeg_build/include" \
  --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
  --bindir="$HOME/bin" \
  --enable-gpl \
  --enable-libass \
  --enable-libfdk-aac \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libtheora \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libx264 \
  --enable-libx265 \
  --enable-nonfree
PATH="$HOME/bin:$PATH" make
make install
hash -r

echo "MANPATH_MAP $HOME/bin $HOME/ffmpeg_build/share/man" >> ~/.manpath
  
#Download and install droid sans mono from google fonts - DroidSansMono-Regular.ttf - there might be a cleaner way to do this if this breaks, email me.
cd ~/ffmpeg_sources
wget https://github.com/google/fonts/raw/master/apache/droidsansmono/DroidSansMono-Regular.ttf
sudo mv DroidSansMono-Regular.ttf /usr/local/share/fonts/d/DroidSansMono_Regular.ttf
sudo apt-get install fontconfig
sudo fc-cache -fv

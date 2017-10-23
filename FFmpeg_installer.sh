# Downloads and installs ffmpeg with codecs and tools for running scripts to convert and add timecode to videos
# Based on from https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu
# created by bensig on 10/4/2017

ffmpeg_build_dir = "$HOME/ffmpeg/ffmpeg_build"
ffmpeg_sources_dir = "$HOME/ffmpeg/ffmpeg_sources"

#Prep steps: 
	mkdir $ffmpeg_sources_dir
	sudo apt-get remove ffmpeg x265 x264 libx264-dev libx265-dev

	sudo apt-get update && sudo apt-get install -y --no-upgrade autoconf automake build-essential mercurial git libarchive-dev \
	fontconfig checkinstall libass-dev libfreetype6-dev libsdl2-dev libtheora-dev libgnutls-dev libvorbis-dev \
	libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev pkg-config texinfo libtool libva-dev \
	libbs2b-dev libcaca-dev libopenjp2-7-dev librtmp-dev libvpx-dev libvdpau-dev wget \
	libwavpack-dev libxvidcore-dev lzma-dev liblzma-dev zlib1g-dev cmake-curses-gui \
	libx11-dev libxfixes-dev libmp3lame-dev libfdk-aac-dev libopus-dev

#install NASM assembler
	cd $ffmpeg_sources_dir
	wget http://www.nasm.us/pub/nasm/releasebuilds/2.13.01/nasm-2.13.01.tar.bz2
	tar xjvf nasm-2.13.01.tar.bz2
	cd nasm-2.13.01
	./autogen.sh
	PATH="$HOME/bin:$PATH" ./configure --prefix=$ffmpeg_build_dir --bindir="$HOME/bin"
	PATH="$HOME/bin:$PATH" make
	make install

#install libnuma
   	SOURCE_PREFIX="$ffmpeg_sources_dir"
   	NUMA_LIB="numactl-2.0.11.tar.gz"
   	NUMA_PATH=$(basename ${NUMA_LIB} .tar.gz)
   	cd ${SOURCE_PREFIX}
   	if [ ! -d "${NUMA_PATH}" ];then
        	wget -O ${NUMA_LIB} "ftp://oss.sgi.com/www/projects/libnuma/download/${NUMA_LIB}"
   	fi
   	tar xfzv ${NUMA_LIB}
   	cd ${NUMA_PATH}
   	./configure PATH="$HOME/bin:$PATH" --prefix=$ffmpeg_build_dir --bindir="$HOME/bin"
	PATH="$HOME/bin:$PATH" make
	make install
	sleep 5

#compile x264... 
	cd $ffmpeg_sources_dir
	wget http://download.videolan.org/pub/x264/snapshots/last_x264.tar.bz2
	tar xjvf last_x264.tar.bz2
	cd x264-snapshot*
	PATH="$HOME/bin:$PATH" ./configure --prefix=$ffmpeg_build_dir --bindir="$HOME/bin" --enable-static --disable-opencl
	PATH="$HOME/bin:$PATH" make
	make install
	sleep 5

#install x265 manually - ffmpeg seems to fail in finding the ubuntu apt install of x265
#	sudo apt-get install cmake mercurial
#	cd $ffmpeg_sources_dir
#	hg clone https://bitbucket.org/multicoreware/x265
#	cd $ffmpeg_sources_dir/x265/build/linux
#	PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=$ffmpeg_build_dir -DENABLE_SHARED:bool=off ../../source
#	make
#	make install
#	sleep 5

#download and install ffmpeg
	cd $ffmpeg_sources_dir
	wget http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
	tar xjvf ffmpeg-snapshot.tar.bz2
	cd ffmpeg
	PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$ffmpeg_build_dir/lib/pkgconfig" ./configure \
	  --prefix=$ffmpeg_build_dir \
	  --pkg-config-flags="--static" \
	  --extra-cflags="-I$ffmpeg_build_dir/include" \
	  --extra-ldflags="-L$ffmpeg_build_dir/lib" \
	  --bindir="$HOME/bin" \
	  --enable-gpl \
	  --enable-libass \
	  --enable-fontconfig \
	  --enable-gnutls \
	  --enable-libfreetype \
	  --enable-libmp3lame \
	  --enable-libopus \
	  --enable-libtheora \
	  --enable-libvorbis \
	  --enable-libvpx \
	  --enable-libx264 \
	  --enable-pthreads \
	  --enable-nonfree
	PATH="$HOME/bin:$PATH" make
	make install
	sleep 5
	hash -r
	echo "MANPATH_MAP $HOME/bin $/ffmpeg_build_dir/share/man" >> ~/.manpath

#Download and install droid sans mono from google fonts - DroidSansMono-Regular.ttf - there might be a cleaner way to do this if this breaks, email me.
	cd $ffmpeg_sources_dir
	wget https://github.com/google/fonts/raw/master/apache/droidsansmono/DroidSansMono-Regular.ttf
	sudo mkdir /usr/local/share/fonts/d/
	sudo mv $ffmpeg_sources_dir/DroidSansMono-Regular.ttf /usr/local/share/fonts/d/DroidSansMono_Regular.ttf
	sudo apt-get install fontconfig
	sudo fc-cache -fv

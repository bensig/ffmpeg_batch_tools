# Downloads and installs ffmpeg with codecs and tools for running scripts to convert and add timecode to videos
# Based on from https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu
# created by bensig on 10/4/2017

# Detect and exit if 'sudo' wasn't used
if [[ $EUID -ne 0 ]]; then
   echo "Add sudo and try again"
   exit 1
fi

SCRIPT=`realpath -s $0`
SCRIPTPATH=`dirname $SCRIPT`

#set variables for directories
ffmpeg_home_dir="$HOME/ffmpeg"
ffmpeg_bin_dir="$HOME/ffmpeg/bin"
ffmpeg_build_dir="$HOME/src/ffmpeg_bash/ffmpeg_build"
ffmpeg_sources_dir="$HOME/src/ffmpeg_bash/ffmpeg_sources"

function install_ffmpeg_scripts() {
  echo -e "#variables to paths - do not include trailing slash on paths" > $SCRIPTPATH/source.cfg
  echo -e "path_to_ffmpeg=$ffmpeg_bin_dir" >> $SCRIPTPATH/source.cfg
  echo -e "path_to_scripts=$SCRIPTPATH" >> $SCRIPTPATH/source.cfg
  cp $SCRIPTPATH/* $ffmpeg_bin_dir/
}

function setup_ffmpeg_directories() {
        mkdir -p "$ffmpeg_bin_dir"
	mkdir -p "$ffmpeg_home_dir"
	mkdir -p "$ffmpeg_build_dir"
	mkdir -p "$ffmpeg_sources_dir"
}

function install_apt_packages() {
        sudo apt-get remove ffmpeg x265 x264 libx264-dev libx265-dev

	sudo apt-get update && sudo apt-get install -y --no-upgrade autoconf automake build-essential mercurial git libarchive-dev \
	fontconfig checkinstall libass-dev libfreetype6-dev libsdl2-dev libtheora-dev libgnutls-dev libvorbis-dev \
	libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev pkg-config texinfo libtool libva-dev \
	libbs2b-dev libcaca-dev libopenjp2-7-dev librtmp-dev libvpx-dev libvdpau-dev wget \
	libwavpack-dev libxvidcore-dev lzma-dev liblzma-dev zlib1g-dev cmake-curses-gui \
	libx11-dev libxfixes-dev libmp3lame-dev libfdk-aac-dev libopus-dev
}

function install_nasm() {
#Install NASM assembler
	cd $ffmpeg_sources_dir
	wget http://www.nasm.us/pub/nasm/releasebuilds/2.13.01/nasm-2.13.01.tar.bz2
	tar xjvf nasm-2.13.01.tar.bz2
	cd nasm-2.13.01
	./autogen.sh
	PATH="$ffmpeg_bin_dir:$PATH" ./configure --prefix=$ffmpeg_build_dir --bindir="$ffmpeg_bin_dir"
	PATH="$ffmpeg_bin_dir:$PATH" make
	make install
}

function install_libnuma() {
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
   	./configure PATH="$ffmpeg_bin_dir:$PATH" --prefix=$ffmpeg_build_dir --bindir="$ffmpeg_bin_dir"
	PATH="$ffmpeg_bin_dir:$PATH" make
	make install
	sleep 5
}

function install_x264() {
#compile x264...
	cd $ffmpeg_sources_dir
	wget http://download.videolan.org/pub/x264/snapshots/last_x264.tar.bz2
	tar xjvf last_x264.tar.bz2
	cd x264-snapshot*
	PATH="$ffmpeg_bin_dir:$PATH" ./configure --prefix=$ffmpeg_build_dir --bindir="$ffmpeg_bin_dir" --enable-static --disable-opencl
	PATH="$ffmpeg_bin_dir:$PATH" make
	make install
	sleep 5
}

function install_x265() {
  #compile x265...
  install x265 manually - ffmpeg seems to fail in finding the ubuntu apt install of x265
	sudo apt-get install cmake mercurial
	cd $ffmpeg_sources_dir
	hg clone https://bitbucket.org/multicoreware/x265
	cd $ffmpeg_sources_dir/x265/build/linux
	PATH="$ffmpeg_bin_dir:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=$ffmpeg_build_dir -DENABLE_SHARED:bool=off ../../source
	make
	make install
	sleep 5
}

function install_droidsansmono_font() {
#Download and install droid sans mono from google fonts - DroidSansMono-Regular.ttf - there might be a cleaner way to do this if this breaks, email me.
	cd $ffmpeg_sources_dir
	wget https://github.com/google/fonts/raw/master/apache/droidsansmono/DroidSansMono-Regular.ttf
	sudo mkdir /usr/local/share/fonts/d/
	sudo mv $ffmpeg_sources_dir/DroidSansMono-Regular.ttf /usr/local/share/fonts/d/DroidSansMono_Regular.ttf
	sudo apt-get install fontconfig
	sudo fc-cache -fv
}

function install_ffmpeg() {
#download and install ffmpeg
	cd $ffmpeg_sources_dir
	wget http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
	tar xjvf ffmpeg-snapshot.tar.bz2
	cd ffmpeg
	PATH="$ffmpeg_bin_dir:$PATH" PKG_CONFIG_PATH="$ffmpeg_build_dir/lib/pkgconfig" ./configure \
	  --prefix=$ffmpeg_build_dir \
	  --pkg-config-flags="--static" \
	  --extra-cflags="-I$ffmpeg_build_dir/include" \
	  --extra-ldflags="-L$ffmpeg_build_dir/lib" \
	  --bindir="$ffmpeg_bin_dir" \
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
	PATH="$ffmpeg_bin_dir:$PATH" make
	make install
	sleep 5
	hash -r
	echo "MANPATH_MAP $ffmpeg_bin_dir $/ffmpeg_build_dir/share/man" >> ~/.manpath
}

function cleanup() {
  rm -f "${tempfiles[@]}"
}


function error() {
  local parent_lineno="$1"
  local message="$2"
  local code="${3:-1}"
  if [[ -n "$message" ]] ; then
    echo "Error on or near line ${parent_lineno}: ${message}; exiting with status ${code}"
  else
    echo "Error on or near line ${parent_lineno}; exiting with status ${code}"
  fi
  exit "${code}"
}

function show_menu() {
PS3='Please enter your choice: '
options=("Install everything" "Install ffmpeg prerequisites" "Install ffmpeg scripts" "Install ffmpeg" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Install everything - packages, scripts, and custom ffmpeg in $ffmpeg_bin_dir")
            echo "You chose to run the full installer"
            setup_ffmpeg_directories
            install_apt_packages
            install_nasm
            install_libnuma
            install_x264
            install_droidsansmono_font
            install_ffmpeg
            install_ffmpeg_scripts
  	    echo -e "Check $ffmpeg_bin_dir for scripts and custom-built ffmpeg version for the scripts. Make sure you set this path in source.cfg when you run scripts."
            ;;
        "Install ffmpeg prerequisites")
            echo "you chose to install ffmpeg prerequisites"
            setup_ffmpeg_directories
            install_apt_packages
            install_nasm
            install_libnuma
            install_x264
            install_droidsansmono_font
            ;;
        "Install ffmepg scripts")
            echo "you chose to install scripts only - these require special parameters in ffmpeg"
            install_ffmpeg_scripts
            ;;
        "Install ffmpeg only")
            echo "you chose to download and compile ffmpeg - this will fail without prerequisites"
            setup_ffmpeg_directories
            install_ffmpeg
            ;;
        "Quit")
            done="true"
            exit
            ;;
        *) echo invalid option;;
    esac
done
}

while [ "$done" != "true" ]
do
  show_menu
done

trap cleanup 0
trap 'error ${LINENO}' ERR

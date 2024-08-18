#!/bin/sh

if test -d target; then rm -r target; fi

if test ! -d build; then mkdir build; fi

mkdir target

mkdir build

INSTALL_TARGET=$(pwd)/target
INSTALL_LIB_DIR=$INSTALL_TARGET/usr/lib

check_err() {
	if [[ "$?" != "0" ]]; then
		echo error;
		exit
	fi
}

cd target
mkdir bin boot dev etc home lib lib64 media mnt opt proc root run sbin srv sys tmp usr var
cd usr
mkdir bin include lib libexec local sbin share
cd ..
cd dev
ln -s -T /proc/self/fd fd
ln -s -T /proc/self/fd/0 stdin
ln -s -T /proc/self/fd/1 stdout
ln -s -T /proc/self/fd/2 stderr
cd ..
cd ..

cd build

# https://kernel.org/
echo linux
if test ! -d linux-6.10.5; then wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.10.5.tar.xz; fi
cd linux-6.10.5
make all -j$(nproc) INSTALL_MOD_PATH=$INSTALL_TARGET
check_err
cp arch/x86/boot/bzImage $INSTALL_TARGET/boot
make modules_install -j$(nproc) INSTALL_MOD_PATH=$INSTALL_TARGET
check_err
cd ..

exists_or_clone() {
	if test ! -d $1; then git clone --depth 1 --single-branch $2; fi
}

# https://git.busybox.net/busybox/
echo busybox
exists_or_clone busybox https://git.busybox.net/busybox
cd busybox
make CONFIG_PREFIX=$INSTALL_TARGET install -j$(nproc)
check_err
cd ..

build_with_configure() {
	echo $1
	exists_or_clone $1 $2
	cd $1
	./configure --prefix=$INSTALL_TARGET
	make install -j$(nproc)
	check_err
	cd ..
}

build_with_configure glibc git://sourceware.org/git/glibc.git
build_with_configure libncurses https://github.com/projectceladon/libncurses.git
build_with_configure ncurses https://github.com/projectceladon/libncurses.git
build_with_configure zlib https://github.com/projectceladon/libncurses.git

# https://github.com/alsa-project/alsa-lib.git
echo alsa-lib
exists_or_clone alsa-lib https://github.com/alsa-project/alsa-lib.git
cd alsa-lib
./gitcompile --disable-aload --prefix=$INSTALL_TARGET/usr --libdir=$INSTALL_LIB_DIR \
	  --with-plugindir=$INSTALL_LIB_DIR/alsa-lib
	  --with-pkgconfdir=$INSTALL_LIB_DIR/pkgconfig
check_err
cd ..

# https://github.com/alsa-project/alsa-utils.git
echo alsa-utils
exists_or_clone alsa-utils https://github.com/alsa-project/alsa-utils.git
cd alsa-utils
./gitcompile --prefix=$INSTALL_TARGET \
	  --with-systemdsystemunitdir="$INSTALL_TARGET/$(pkg-config systemd --variable=systemdsystemunitdir)" \
	  --with-udev-rules-dir="$INSTALL_TARGET/$(pkg-config udev --variable=udevdir)"
check_err
cd ..

# https://git.ffmpeg.org/ffmpeg.git
echo ffmpeg
exists_or_clone ffmpeg https://git.ffmpeg.org/ffmpeg.git
cd ffmpeg
./configure --prefix=$INSTALL_TARGET --enable-libx264
make install -j$(nproc)
check_err
cd ..

cd ..

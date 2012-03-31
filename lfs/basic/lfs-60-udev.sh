#! /bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

. $dir/lfs-functions.sh

pack="udev-182.tar.xz"
patches=""
stage=""

prepare_compile "$@"

# mangle code
if [ ! -e "$compile_build/lfs-manual-patches" ]; then
( # subshell
	cd $compile_source

	tar -xvf $lfs_source/udev-config-20100128.tar.bz2 || \
		echo_exit "file $lfs_source/udev-config-20100128.tar.bz2 lost"
	# patch_patches "..."
	install -dv /lib/{firmware,udev/devices/pts}
	mknod -m0666 /lib/udev/devices/null c 1 3
) || exit 1
	touch "$compile_build/lfs-manual-patches"
fi

cd $compile_build || echo_exit "into compile build $compile_build failed"
[ "$1" = "all" ] && rm -fr $compile_build/*
if [ ! -e "Makefile" ]; then
	BLKID_CFLAGS="-I/usr/include/blkid"  \
	BLKID_LIBS="-L/lib -lblkid"          \
	KMOD_CFLAGS="-I/usr/include"         \
	KMOD_LIBS="-L/lib -lkmod"            \
	../configure \
		--build=$lfs_tgt \
		--prefix=/usr           \
		--with-rootprefix=''    \
		--bindir=/sbin          \
		--sysconfdir=/etc       \
		--libexecdir=/lib       \
		--enable-rule_generator \
		--disable-introspection \
		--disable-keymap        \
		--disable-gudev         \
		--with-usb-ids-path=no  \
		--with-pci-ids-path=no  \
		--with-systemdsystemunitdir=no \
		|| echo_exit "configure $pack failed"
fi

if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make -j$lfs_cpu_core && \
	make install && \
	true || echo_exit "make failed"

	( rmdir -fv /usr/share/doc/udev; true ) && \
	(
		cd $compile_source/udev-config-20100128 && \
		make install && \
		make install-doc
	) && \
	true || echo_exit "install doc failed"

	touch lfs-installed
fi

echo "$0 ok ............... ok"

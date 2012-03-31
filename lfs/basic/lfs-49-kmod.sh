#! /bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

. $dir/lfs-functions.sh

pack="kmod-7.tar.xz"
patches=""
stage=""

prepare_compile "$@"

# mangle code
if [ ! -e "$compile_build/lfs-manual-patches" ]; then
( # subshell
	cd $compile_source
	# patch_patches "..."
) || exit 1
	touch "$compile_build/lfs-manual-patches"
fi

cd $compile_build || echo_exit "into compile build $compile_build failed"
[ "$1" = "all" ] && rm -fr $compile_build/*
if [ ! -e "Makefile" ]; then
	liblzma_CFLAGS="-I/usr/include" \
	liblzma_LIBS="-L/lib -llzma"    \
	zlib_CFLAGS="-I/usr/include"    \
	zlib_LIBS="-L/lib -lz"          \
	../configure \
		--build=$lfs_tgt \
		--prefix=/usr       \
		--bindir=/bin       \
		--libdir=/lib       \
		--sysconfdir=/etc   \
		--with-xz           \
		--with-zlib         \
		|| echo_exit "configure $pack failed"
fi

if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make -j$lfs_cpu_core && \
	make pkgconfigdir=/usr/lib/pkgconfig install && \
	true || echo_exit "make failed"

	for target in depmod insmod modinfo modprobe rmmod; do
		ln -sv ../bin/kmod /sbin/$target
	done
	ln -sv kmod /bin/lsmod

	touch lfs-installed
fi

echo "$0 ok ............... ok"

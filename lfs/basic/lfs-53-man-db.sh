#! /bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

. $dir/lfs-functions.sh

pack="man-db-2.6.1.tar.gz"
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
	PKG_CONFIG=/tools/bin/true                       \
	libpipeline_CFLAGS=''                            \
	libpipeline_LIBS='-lpipeline'                    \
	../configure \
		--build=$lfs_tgt \
		--prefix=/usr                        \
		--libexecdir=/usr/lib                \
		--docdir=/usr/share/doc/man-db-2.6.1 \
		--sysconfdir=/etc                    \
		--disable-setuid                     \
		--with-browser=/usr/bin/lynx         \
		--with-vgrind=/usr/bin/vgrind        \
		--with-grap=/usr/bin/grap            \
		|| echo_exit "configure $pack failed"
fi

if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make -j$lfs_cpu_core && \
	make install && \
	true || echo_exit "make failed"

	touch lfs-installed
fi

echo "$0 ok ............... ok"
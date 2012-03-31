#! /bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

. $dir/lfs-functions.sh

pack="tar-1.26.tar.bz2"
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
	FORCE_UNSAFE_CONFIGURE=1  \
	../configure \
		--build=$lfs_tgt \
		--prefix=/usr \
		--bindir=/bin \
		--libexecdir=/usr/sbin \
		|| echo_exit "configure $pack failed"
fi

if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make -j$lfs_cpu_core && \
	make install && \
	make -C doc install-html docdir=/usr/share/doc/tar-1.26 && \
	true || echo_exit "make failed"

	touch lfs-installed
fi

echo "$0 ok ............... ok"

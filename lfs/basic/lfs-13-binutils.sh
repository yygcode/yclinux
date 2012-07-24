#! /bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

. $dir/lfs-functions.sh

pack="binutils-2.22.tar.bz2"
patches=
stage=

prepare_compile "$@"

if [ ! -e "$compile_build/lfs-manual-patches" ]; then
( # subshell
	cd $compile_source

	rm -fv etc/standards.info
	sed -i.bak '/^INFO/s/standards.info //' etc/Makefile.in

	sed -i "/exception_defines.h/d" ld/testsuite/ld-elf/new.cc
	sed -i "s/-fvtable-gc //" ld/testsuite/ld-selective/selective.exp

	patch_patches "binutils-2.22-build_fix-1.patch"
) || exit 1
fi
cd $compile_build || echo_exit "into compile build $compile_build failed"
[ "$1" = "all" ] && rm -fr $compile_build/*
if [ ! -e "Makefile" ]; then
	../configure \
		--build=$lfs_tgt \
		--prefix=/usr \
		--enable-shared \
		|| echo_exit "configure $pack failed"
fi

if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make -j$lfs_cpu_core toolsdir=/usr && \
	make -k check && \
	make -j$lfs_cpu_core check && \
	make toolsdir=/usr install \
	|| echo_exit "make failed"

	cp -v $compile_source/include/libiberty.h /usr/include
	touch lfs-installed
fi

echo "$0 ok ............... ok"

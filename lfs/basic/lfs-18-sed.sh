#! /bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

. $dir/lfs-functions.sh

pack="sed-4.2.1.tar.bz2"
patches=
stage=

prepare_compile "$@"

cd $compile_build || echo_exit "into compile build $compile_build failed"
[ "$1" = "all" ] && rm -fr $compile_build/*
if [ ! -e "Makefile" ]; then
	../configure \
		--build=$lfs_tgt \
		--prefix=/usr \
		--bindir=/bin \
		--htmldir=/usr/share/doc/sed-4.2.1 \
		|| echo_exit "configure $pack failed"
fi

if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make -j$lfs_cpu_core && \
	make html && \
	make install && \
	make -C doc install-html \
	|| echo_exit "make failed"

	touch lfs-installed
fi

echo "$0 ok ............... ok"

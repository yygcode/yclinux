#! /bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

. $dir/lfs-functions.sh

pack="bison-2.5.tar.bz2"
patches=
stage=

prepare_compile "$@"

cd $compile_build || echo_exit "into compile build $compile_build failed"
[ "$1" = "all" ] && rm -fr $compile_build/*
if [ ! -e "Makefile" ]; then
	../configure \
		--build=$lfs_tgt \
		--prefix=/usr \
		|| echo_exit "configure $pack failed"
	echo '#define YYENABLE_NLS 1' >> lib/config.h
fi

if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make -j$lfs_cpu_core \
	|| echo_exit "make failed"

	make install || echo_exit "install failed"

	touch lfs-installed
fi

echo "$0 ok ............... ok"

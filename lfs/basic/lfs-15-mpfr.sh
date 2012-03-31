#! /bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

. $dir/lfs-functions.sh

pack="mpfr-3.1.0.tar.bz2"
patches="mpfr-3.1.0-fixes-1.patch"
stage=

prepare_compile "$@"

cd $compile_build || echo_exit "into compile build $compile_build failed"
[ "$1" = "all" ] && rm -fr $compile_build/*
if [ ! -e "Makefile" ]; then
	../configure \
		--build=$lfs_tgt \
		--prefix=/usr \
		--enable-thread-safe \
		--docdir=/usr/share/doc/mpfr-3.1.0 \
		|| echo_exit "configure $pack failed"
fi

if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make -j$lfs_cpu_core && \
	make check && \
	make install \
	|| echo_exit "make failed"

	make html && \
	make install-html || echo "make html failed"

	touch lfs-installed
fi

echo "$0 ok ............... ok"

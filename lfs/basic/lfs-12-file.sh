#! /bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

. $dir/lfs-functions.sh

pack="file-5.11.tar.gz"
patches=
stage=

prepare_compile "$@"

cd $compile_source || echo_exit "into compile source $compile_source failed"
[ "$1" = "all" ] && { make clean; rm lfs-installed; }
if [ ! -e "Makefile" ]; then
	./configure \
		--build=$lfs_tgt \
		--prefix=/usr \
		|| echo_exit "configure $pack failed"
fi

if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make -j$lfs_cpu_core && \
	make -j$lfs_cpu_core check && \
	make install \
	|| echo_exit "make failed"

	touch lfs-installed
fi

echo "$0 ok ............... ok"

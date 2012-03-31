#! /bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

. $dir/lfs-functions.sh

pack="zlib-1.2.6.tar.bz2"
patches=
stage=

prepare_compile "$@"

cd $compile_source || echo_exit "into compile source $compile_source failed"
[ "$1" = "all" ] && { make clean; rm lfs-installed; }
./configure \
	--prefix=/usr \
	|| echo_exit "configure $unpack failed"

if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make -j$lfs_cpu_core && \
	make install \
	|| echo_exit "make failed"
	mv -v /usr/lib/libz.so.* /lib
	ln -sfv ../../lib/libz.so.1.2.6 /usr/lib/libz.so

	touch lfs-installed
fi

echo "$0 ok ............... ok"

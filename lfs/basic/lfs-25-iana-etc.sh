#! /bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

. $dir/lfs-functions.sh

pack="iana-etc-2.30.tar.bz2"
patches=
stage=

prepare_compile "$@"

cd $compile_source || echo_exit "into compile source $compile_source failed"
[ "$1" = "all" ] && { make clean; rm -f lfs-installed; }
if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make -j$lfs_cpu_core \
	|| echo_exit "make failed"
	make install || echo_exit "install failed"

	touch lfs-installed
fi

echo "$0 ok ............... ok"

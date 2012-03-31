#! /bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

. $dir/lfs-functions.sh

pack="procps-3.2.8.tar.gz"
patches="procps-3.2.8-fix_HZ_errors-1.patch procps-3.2.8-watch_unicode-1.patch"
stage=

prepare_compile "$@"

if [ ! -e "$compile_build/lfs-manual-patches" ]; then
( # subshell
	cd $compile_source

	sed -i -e 's@\*/module.mk@proc/module.mk ps/module.mk@' Makefile
) || exit 1
	touch "$compile_build/lfs-manual-patches"
fi

cd $compile_source || echo_exit "into compile source $compile_source failed"
[ "$1" = "all" ] && { make clean; rm -f lfs-installed; }
if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make -j$lfs_cpu_core \
	|| echo_exit "make failed"

	make install \
	|| echo_exit "install failed"

	touch lfs-installed
fi

echo "$0 ok ............... ok"

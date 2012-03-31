#! /bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

. $dir/lfs-functions.sh

pack="util-linux-2.21.tar.xz"
patches=
stage=

prepare_compile "$@"

# fix code
if [ ! -e "$compile_build/lfs-manual-patches" ]; then
( # subshell
	cd $compile_source

	sed -e 's@etc/adjtime@var/lib/hwclock/adjtime@g' -i \
		$(grep -rl '/etc/adjtime' .)
	mkdir -pv /var/lib/hwclock
) || exit 1
	touch "$compile_build/lfs-manual-patches"
fi

cd $compile_build || echo_exit "into compile build $compile_build failed"
[ "$1" = "all" ] && rm -fr $compile_build/*
if [ ! -e "Makefile" ]; then
	../configure \
		--build=$lfs_tgt \
		|| echo_exit "configure $pack failed"
fi

if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make -j$lfs_cpu_core && \
	make install \
	|| echo_exit "make failed"

	touch lfs-installed
fi

echo "$0 ok ............... ok"

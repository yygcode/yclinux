#! /bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

. $dir/lfs-functions.sh

pack="sysvinit-2.88dsf.tar.bz2"
patches=""
stage=""

prepare_compile "$@"

# mangle code
if [ ! -e "$compile_build/lfs-manual-patches" ]; then
( # subshell
	cd $compile_source

	sed -i 's@Sending processes@& configured via /etc/inittab@g' src/init.c

	sed -i -e 's/utmpdump wall/utmpdump/' \
	       -e '/= mountpoint/d' \
	       -e 's/mountpoint.1 wall.1//' src/Makefile
	# patch_patches "..."
) || exit 1
	touch "$compile_build/lfs-manual-patches"
fi

cd $compile_source || echo_exit "into compile source $compile_source failed"
[ "$1" = "all" ] && { make clean; rm -f lfs-installed; }
if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make -j$lfs_cpu_core -C src&& \
	make -C src install && \
	true || echo_exit "make failed"

	touch lfs-installed
fi

echo "$0 ok ............... ok"

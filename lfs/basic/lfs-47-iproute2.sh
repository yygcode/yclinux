#! /bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

. $dir/lfs-functions.sh

pack="iproute2-3.3.0.tar.xz"
patches=""
stage=""

prepare_compile "$@"

# mangle code
if [ ! -e "$compile_build/lfs-manual-patches" ]; then
( # subshell
	cd $compile_source
	sed -i '/^TARGETS/s@arpd@@g' misc/Makefile
	sed -i /ARPD/d Makefile
	rm man/man8/arpd.8
	# patch_patches "..."
) || exit 1
	touch "$compile_build/lfs-manual-patches"
fi

cd $compile_source || echo_exit "into compile source $compile_source failed"
[ "$1" = "all" ] && { make clean; rm -f lfs-installed; }
if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make -j$lfs_cpu_core DESTDIR= && \
	make DESTDIR= \
		MANDIR=/usr/share/man \
		DOCDIR=/usr/share/doc/iproute2-3.3.0 \
		install && \
	true || echo_exit "make failed"

	touch lfs-installed
fi

echo "$0 ok ............... ok"

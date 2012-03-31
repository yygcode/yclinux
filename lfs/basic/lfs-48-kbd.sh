#! /bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

. $dir/lfs-functions.sh

pack="kbd-1.15.2.tar.gz"
patches="kbd-1.15.2-backspace-1.patch"
stage=""

prepare_compile "$@"

# mangle code
if [ ! -e "$compile_build/lfs-manual-patches" ]; then
( # subshell
	cd $compile_source
	# patch_patches "..."
) || exit 1
	touch "$compile_build/lfs-manual-patches"
fi

cd $compile_build || echo_exit "into compile build $compile_build failed"
[ "$1" = "all" ] && rm -fr $compile_build/*
if [ ! -e "Makefile" ]; then
	../configure \
		--build=$lfs_tgt \
		--prefix=/usr \
		--datadir=/lib/kbd \
		|| echo_exit "configure $pack failed"
fi

if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make -j$lfs_cpu_core && \
	make install && \
	true || echo_exit "make failed"

	mv -v /usr/bin/{kbd_mode,loadkeys,openvt,setfont} /bin
	mkdir -v /usr/share/doc/kbd-1.15.2
	cp -R -v doc/* \
		/usr/share/doc/kbd-1.15.2

	touch lfs-installed
fi

echo "$0 ok ............... ok"

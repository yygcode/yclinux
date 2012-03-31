#! /bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

. $dir/lfs-functions.sh

pack="readline-6.2.tar.gz"
patches=""
stage=""

prepare_compile "$@"

# mangle code
if [ ! -e "$compile_build/lfs-manual-patches" ]; then
( # subshell
	cd $compile_source
	sed -i '/MV.*old/d' Makefile.in
	sed -i '/{OLDSUFF}/c:' support/shlib-install
	patch_patches "readline-6.2-fixes-1.patch"
) || exit 1
	touch "$compile_build/lfs-manual-patches"
fi

cd $compile_build || echo_exit "into compile build $compile_build failed"
[ "$1" = "all" ] && rm -fr $compile_build/*
if [ ! -e "Makefile" ]; then
	../configure \
		--build=$lfs_tgt \
		--prefix=/usr \
		--libdir=/lib \
		|| echo_exit "configure $pack failed"
fi

if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make -j$lfs_cpu_core SHLIB_LIBS=-lncurses && \
	make install && \
	true || echo_exit "make failed"

	mv -v /lib/lib{readline,history}.a /usr/lib

	rm -v /lib/lib{readline,history}.so
	ln -sfv ../../lib/libreadline.so.6 /usr/lib/libreadline.so
	ln -sfv ../../lib/libhistory.so.6 /usr/lib/libhistory.so

	mkdir -v /usr/share/doc/readline-6.2
	install -v -m644 doc/*.{ps,pdf,html,dvi} \
		/usr/share/doc/readline-6.2

	touch lfs-installed
fi

echo "$0 ok ............... ok"

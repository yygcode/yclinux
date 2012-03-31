#! /bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

. $dir/lfs-functions.sh

pack="gcc-4.7.0.tar.bz2"
patches=
stage=

prepare_compile "$@"

if [ ! -e "$compile_build/lfs-manual-patches" ]; then
( # subshell
	cd $compile_source

	sed -i 's/install_to_$(INSTALL_DEST) //' libiberty/Makefile.in
	case `uname -m` in
	i?86) sed -i 's/^T_CFLAGS =$/& -fomit-frame-pointer/' \
		gcc/Makefile.in ;;
	esac
	sed -i 's@\./fixinc\.sh@-c true@' gcc/Makefile.in
) || exit 1
fi

cd $compile_build || echo_exit "into compile build $compile_build failed"
[ "$1" = "all" ] && rm -fr $compile_build/*
if [ ! -e "Makefile" ]; then
	../configure \
		--build=$lfs_tgt			\
		--prefix=/usr				\
		--libexecdir=/usr/lib			\
		--enable-shared				\
		--enable-threads=posix			\
		--enable-__cxa_atexit			\
		--enable-clocale=gnu			\
		--enable-languages=c,c++		\
		--disable-multilib			\
		--disable-bootstrap			\
		--with-system-zlib			\
		|| echo_exit "configure $pack failed"
fi

if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make -j$lfs_cpu_core && \
	make install \
	|| echo_exit "make failed"

	ln -fsv ../usr/bin/cpp /lib
	ln -sv gcc /usr/bin/cc

	echo 'main(){}' > dummy.c
	cc dummy.c -v -Wl,--verbose &> dummy.log
	readelf -l a.out | grep ': /lib'

	grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log
	grep -B4 '^ /usr/include' dummy.log
	grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
	grep "/lib.*/libc.so.6 " dummy.log
	grep found dummy.log
	rm -v dummy.c a.out dummy.log

	case "$lfs_arch" in
	i?86) GDBDIR=/usr/share/gdb/auto-load/usr/lib/gcc/\
i686-yc-linux-gnu/4.7.0/ ;;
	*) GDBDIR=/usr/share/gdb/auto-load/usr/lib64/gcc/\
x86_64-pc-linux-gnu/4.7.0/ ;;
	    esac

	mkdir -pv $GDBDIR
	mv -v /usr/lib/*gdb.py $GDBDIR
	unset GDBDIR

	touch lfs-installed
fi

echo "$0 ok ............... ok"

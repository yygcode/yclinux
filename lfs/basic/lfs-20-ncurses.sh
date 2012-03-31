#! /bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

. $dir/lfs-functions.sh

pack="ncurses-5.9.tar.gz"
patches=
stage=

prepare_compile "$@"

cd $compile_build || echo_exit "into compile build $compile_build failed"
# configure
if [ ! -e "Makefile" ]; then
	../configure \
		--build=$lfs_tgt \
		--prefix=/usr \
		--with-shared \
		--without-debug \
		--enable-widec \
		|| echo_exit "configure $pack failed"
fi

if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make && \
	make install || echo_exit "make failed"

	mv -v /usr/lib/libncursesw.so.5* /lib
	ln -sfv ../../lib/libncursesw.so.5 /usr/lib/libncursesw.so
	for lib in ncurses form panel menu ; do \
		rm -vf /usr/lib/lib${lib}.so ; \
		echo "INPUT(-l${lib}w)" >/usr/lib/lib${lib}.so ; \
		ln -sfv lib${lib}w.a /usr/lib/lib${lib}.a ; \
	done
	ln -sfv libncurses++w.a /usr/lib/libncurses++.a

	rm -vf /usr/lib/libcursesw.so
	echo "INPUT(-lncursesw)" >/usr/lib/libcursesw.so
	ln -sfv libncurses.so /usr/lib/libcurses.so
	ln -sfv libncursesw.a /usr/lib/libcursesw.a
	ln -sfv libncurses.a /usr/lib/libcurses.a

	mkdir -v       /usr/share/doc/ncurses-5.9
	cp -v -R doc/* /usr/share/doc/ncurses-5.9

	touch lfs-installed
fi

echo "$0 ok ............... ok"

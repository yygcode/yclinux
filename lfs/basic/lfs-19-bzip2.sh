#! /bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

. $dir/lfs-functions.sh

pack="bzip2-1.0.6.tar.gz"
patches="bzip2-1.0.6-install_docs-1.patch"
stage=

prepare_compile "$@"

if [ ! -e "$compile_build/lfs-manual-patches" ]; then
( # subshell
	cd $compile_source

	sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
) || exit 1
	touch "$compile_build/lfs-manual-patches"
fi

cd $compile_source || echo_exit "into compile source $compile_source failed"
[ "$1" = "all" ] && { make clean; rm -f lfs-installed; }
if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make -f Makefile-libbz2_so && \
	make clean && \
	make
	make PREFIX=/usr install \
	|| echo_exit "make failed"

	cp -v bzip2-shared /bin/bzip2
	cp -av libbz2.so* /lib
	ln -sv ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so
	rm -v /usr/bin/{bunzip2,bzcat,bzip2}
	ln -sv bzip2 /bin/bunzip2
	ln -sv bzip2 /bin/bzcat

	touch lfs-installed
fi

echo "$0 ok ............... ok"

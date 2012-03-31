#! /bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

. $dir/lfs-functions.sh

pack="gmp-5.0.4.tar.xz"
patches=
stage=

prepare_compile "$@"

cd $compile_build || echo_exit "into compile build $compile_build failed"
[ "$1" = "all" ] && rm -fr $compile_build/*
if [ ! -e "Makefile" ]; then
	../configure \
		--build=$lfs_tgt \
		--prefix=/usr \
		--enable-cxx \
		--enable-mpbsd \
		|| echo_exit "configure $pack failed"
fi

if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make -j$lfs_cpu_core && \
	make check 2>&1 | tee gmp-check-log \
	|| echo_exit "make failed"

	awk '/tests passed/{total+=$2} ; END{print total}' gmp-check-log
	make install

	mkdir -v /usr/share/doc/gmp-5.0.4
	cp -v doc/{isa_abi_headache,configuration} doc/*.html \
		/usr/share/doc/gmp-5.0.4

	touch lfs-installed
fi

echo "$0 ok ............... ok"

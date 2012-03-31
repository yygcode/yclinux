#! /bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

. $dir/lfs-functions.sh

pack="shadow-4.1.5.tar.bz2"
patches="shadow-4.1.5-nscd-1.patch"
stage=""

prepare_compile "$@"

# mangle code
if [ ! -e "$compile_build/lfs-manual-patches" ]; then
( # subshell
	cd $compile_source

	sed -i 's/groups$(EXEEXT) //' src/Makefile.in
	find man -name Makefile.in -exec sed -i 's/groups\.1 / /' {} \;

	sed -i -e 's@#ENCRYPT_METHOD DES@ENCRYPT_METHOD SHA512@' \
	       -e 's@/var/spool/mail@/var/mail@' etc/login.defs
	# patch_patches "..."
) || exit 1
	touch "$compile_build/lfs-manual-patches"
fi

cd $compile_build || echo_exit "into compile build $compile_build failed"
[ "$1" = "all" ] && rm -fr $compile_build/*
if [ ! -e "Makefile" ]; then
	../configure \
		--build=$lfs_tgt \
		--sysconfdir=/etc \
		|| echo_exit "configure $pack failed"
fi

if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make -j$lfs_cpu_core && \
	make install && \
	true || echo_exit "make failed"

	mv -v /usr/bin/passwd /bin

	pwconv
	grpconv

	touch lfs-installed
fi

echo "$0 ok ............... ok"

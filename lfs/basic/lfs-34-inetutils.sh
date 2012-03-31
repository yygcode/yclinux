#! /bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

. $dir/lfs-functions.sh

pack="inetutils-1.9.1.tar.gz"
patches=""
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
		--build=$lfs_tgt	\
		--prefix=/usr		\
		--libexecdir=/usr/sbin	\
		--localstatedir=/var	\
		--disable-ifconfig	\
		--disable-logger	\
		--disable-syslogd	\
		--disable-whois		\
		--disable-servers	\
		|| echo_exit "configure $pack failed"
fi

if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make -j$lfs_cpu_core && \
	make install && \
	make -C doc html && \
	make -C doc install-html docdir=/usr/share/doc/inetutils-1.9.1 && \
	true || echo_exit "make failed"

	mv -v /usr/bin/{hostname,ping,ping6} /bin
	mv -v /usr/bin/traceroute /sbin

	touch lfs-installed
fi

echo "$0 ok ............... ok"

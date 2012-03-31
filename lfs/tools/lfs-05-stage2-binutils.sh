#! /bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

. $dir/getopt.sh

usage()
{
	echo -e "Usage: $cmd [OPTION]... stage1|stage2\n"
	echo -e "import and/or config lfs env."
	echo -e "\t-c, --config		config file"
	echo -e "\t-h, --help		print usage"
	echo -e ""

	exit ${1:-1}
}

eval "$(yc_getopt -plfs -xstage -vyes\
		"config,c,:" "help,h" \
		-- "$@" )"

[ "$lfs_help" = "yes" ] && usage 0

. $dir/lfs-functions.sh

pack="binutils-2.22.tar.bz2"
patches="binutils-2.22-build_fix-1.patch"
stage=stage2

prepare_compile "$@"

cd $compile_build || echo_exit "into compile build $compile_build failed"
[ "$1" = "all" ] && rm -fr $compile_build/*
if [ ! -e "Makefile" ]; then
	CC="$env_tgt-gcc -B/tools/lib/" \
	AR=$env_tgt-ar \
	RANLIB=$env_tgt-ranlib \
	../configure \
		--prefix=/tools \
		--build=$env_tgt \
		--disable-nls \
		--with-lib-path=/tools/lib \
		|| echo_exit "configure $pack failed"
fi

if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make -j$env_cpu_core && \
	make install || \
	echo_exit "make $pack failed"
	{
	# prepare the linker for the "Re-adjusting"
	make -C ld clean && \
	make -C ld LIB_PATH=/usr/lib:/lib && \
	cp -v ld/ld-new /tools/bin/
	}

	touch lfs-installed
fi

echo "$0 ok ............... ok"

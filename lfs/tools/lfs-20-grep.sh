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

pack=grep-2.11.tar.xz
patches=
stage=

prepare_compile "$@"

cd $compile_build || echo_exit "into compile build $compile_build failed"
[ "$1" = "all" ] && rm -fr $compile_build/*
if [ ! -e "Makefile" ]; then
	../configure \
		--prefix=/tools \
		--disable-perl-regexp \
		|| echo_exit "configure $pack failed"
fi

if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make -j$env_cpu_core && \
	make -j$env_cpu_core install || \
		echo_exit "make failed"

	touch lfs-installed
fi

echo "$0 ok ............... ok"

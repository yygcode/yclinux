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

pack="bzip2-1.0.6.tar.gz"
patches=
stage=

prepare_compile "$@"

cd $compile_source || echo_exit "into compile source $compile_source failed"
[ "$1" = "all" ] && { make clean; rm -f lfs-installed; }

if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make -j$env_cpu_core && \
	make PREFIX=/tools install || \
		echo_exit "make failed"

	touch lfs-installed
fi

echo "$0 ok ............... ok"

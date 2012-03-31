#! /bin/bash

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

pack="linux-3.3.tar.bz2"

prepare_compile "$@"

cd $compile_source || echo_exit "into compile source $compile_source failed"
make mrproper || echo_exit "make mrproper failed"
make headers_check || echo_exit "make headers check failed"
make INSTALL_HDR_PATH=$compile_build headers_install || \
	echo_exit "make headers_install failed"
cp -rv $compile_build/include/* /tools/include || \
	echo_exit "cp -rv $compile_build/include/* /tools/include failed"
echo "$0 ok ............... ok"

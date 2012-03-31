#! /tools/bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

. $dir/lfs-functions.sh

pack="linux-3.3.tar.bz2"

prepare_compile "$@"

cd $compile_source || echo_exit "into compile source $compile_source failed"
make mrproper || echo_exit "make mrproper failed"
make headers_check || echo_exit "make headers check failed"
make INSTALL_HDR_PATH=$compile_build headers_install || \
	echo_exit "make headers_install failed"
mkdir -p /usr/include || echo_exit "create /usr/include failed"
find $compile_build/include \( -name .install -o -name ..install.cmd \) -delete
cp -rv $compile_build/include/* /usr/include || \
	echo_exit "cp -rv $compile_build/include/* /usr/include failed"
echo "$0 ok ............... ok"

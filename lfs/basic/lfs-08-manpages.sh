#! /tools/bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

. $dir/lfs-functions.sh

pack="man-pages-3.38.tar.xz"

prepare_compile "$@"

cd $compile_source || echo_exit "into compile source $compile_source failed"
make install || echo_exit "make install failed"
echo "$0 ok ............... ok"

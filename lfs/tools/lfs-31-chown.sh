#! /bin/bash -x

dir=$(dirname $0)
. $dir/lfs-functions.sh

pack=
patches=
stage=

# import config
prepare_compile "$@"

sudo chown -R 0:0 $env_tools

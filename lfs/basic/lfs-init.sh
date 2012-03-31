#! /tools/bin/bash

on_exit()
{
	cd /
	umount /dev/pts
	umount /dev
	umount /proc
	umount /sys
	umount $lfs_root/lfs_source
	umount $lfs_root/lfs_basic
}

trap on_exit EXIT

dir=$(dirname $0)
cmd=$(basename $0)
config=$dir/lfs-env.config

. $dir/getopt.sh

echo -e "\nlfs Env:"
echo -e "\tPATH=$PATH"
echo -e "\tHOME=$HOME"
echo -e "\tlfs_basic=$lfs_basic"
echo -e "\tlfs_source=$lfs_source"
echo -e "\tlfs_tgt=$lfs_tgt"
echo -e "\tlfs_arch=$lfs_arch"
echo -e "\tlfs_cpu_core=$lfs_cpu_core"

ln -sfv /.lfs-basic $lfs_basic
ln -svf /.lfs-sources $lfs_source
cd
exec /tools/bin/bash --login

echo "Never get here ????"

exit 1

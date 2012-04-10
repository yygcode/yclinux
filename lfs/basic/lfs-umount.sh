#! /bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)
config=$dir/lfs-env.config

. $dir/getopt.sh

usage()
{
	echo -e "Usage: $cmd [OPTION]...\n"
	echo -e "import and/or config lfs env."
	echo -e "\t-r, --root		set root of the lfs directory"
	echo -e "\t-s, --source		package source directory of lfs"
	echo -e "\t-w, --work		compile directory of lfs"
	echo -e "\t-a, --arch		architecture of lfs"
	echo -e "\t-c, --cpu-core		cpu-core count"
	echo -e "\t-i, --img		lfs image file absolute pathname"
	echo -e "\t-m, --mount		mount point"
	echo -e "\t-h, --help		print usage"
	echo -e ""

	exit ${1:-1}
}

echo_exit()
{
	echo -e "$cmd err:\n\t$cmd: $@" >&2
	echo -e "---------" >&2

	usage
}

yes_no()
{
	echo -en "\n  Is it Correct (Yes/No)? "
	while read line; do
		line=$(echo $line | tr [a-z] [A-Z])
		case "$line" in
		YES|Y)
			break
			;;
		NO|N)
			echo -e "$@"
			exit 2
			;;
		*)
			echo -en "\n  Is it Correct (Yes/No)? "
			;;
		esac
	done
}

export env_root=
export env_source=
export env_work=
export env_arch=
export env_cpu_core=
export env_mount=

[ -e "$config" ] && . "$config" 2>/dev/null

env_help=no
eval $(yc_getopt --prefix='env' \
	"root,r,:" "source,s,:" "work,w,:" \
	"arch,a,:" "cpu-core,c,:" "img,i,:"\
	"user,u,:" "group,g,:" \
	"mount,m,:" "help,h" -- "$@")
[ "$env_help" != "no" ] && usage 0

# root dir
if [ -z "$env_root" ]; then
	echo_exit "root empty, You must specify a root for lfs."
fi
if [ -n "${env_root##/*}" ]; then
	echo_exit "root($env_root) is not a absolute directory."
fi
env_root=${env_root%/}

# source dir
[ -n "$env_source" ] || env_source=sources
if [ -n "${env_source##/*}" ]; then
	env_source=$env_root/$env_source
fi
env_source=${env_source%/}

# arch
[ -n "$env_arch" ] || env_arch=$(uname -m)
if [ -z "$env_arch" ]; then
	echo_exit "arch cannot be fetched"
fi

# cpu-core
[ -n "$env_cpu_core" ] || \
	env_cpu_core=$(cat /proc/cpuinfo | grep ^processor | wc -l)
[ -n "$env_cpu_core" ] || env_cpu_core=1
if [ -z "${env_cpu_core##*[!0-9]*}" ]; then
	echo_exit "cpu-core($env_cpu_core) invalid, it must be an integer."
fi

# image
[ -n "$env_img" ] || env_img=$env_arch.img
if [ -z "${env_img%%*/}" ]; then
	echo_exit "img cannot be a directory (must be a file)"
fi
if [ -n "${env_img##/*}" ]; then
	env_img=$env_root/$env_img
fi

# env_mount
[ -n "$env_mount" ] || env_mount=mount-$env_arch
if [ -n "${env_mount##/*}" ]; then
	env_mount=$env_root/$env_mount
fi
env_mount=${env_mount%/}

echo -e "  Env:"
echo -e "\troot:      $env_root"
echo -e "\tsource:    $env_source"
echo -e "\twork:      $env_work"
echo -e "\tarch:      $env_arch"
echo -e "\tcpu-core:  $env_cpu_core"
echo -e "\timg:       $env_img"
echo -e "\tmount:     $env_mount"

[ -e "$env_mount" ] || mkdir -p "$env_mount"
[ -e "$env_mount" ] || echo_exit "create directory mount($env_mount) failed."

# mount source and this directory first
lfs_root=$env_mount/home/lfs
lfs_basic=$env_mount/.lfs-basic
lfs_source=$env_mount/.lfs-sources
lfs_mount=$env_mount

mountpoint -q $lfs_source && \
	sudo umount $lfs_source

mountpoint -q $lfs_basic && \
	sudo umount $lfs_basic

mountpoint -q $lfs_mount/dev/pts && \
	sudo umount $lfs_mount/dev/pts

mountpoint -q $lfs_mount/dev/shm && \
	sudo umount $lfs_mount/dev/shm

mountpoint -q $lfs_mount/dev && \
	sudo umount $lfs_mount/dev
mountpoint -q $lfs_mount/proc && \
	sudo umount $lfs_mount/proc

mountpoint -q $lfs_mount/sys && \
	sudo umount $lfs_mount/sys

mountpoint -q $lfs_mount/ && \
	sudo umount $lfs_mount

exit 0
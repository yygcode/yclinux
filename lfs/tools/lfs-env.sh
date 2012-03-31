#! /bin/bash

dir=$(dirname $0)
cmd=$(basename $0)
config=$dir/lfs-env.config

. $dir/getopt.sh

usage()
{
	echo -e "Usage: $cmd [OPTION]...\n"
	echo -e "import and/or config lfs env."
	echo -e "\t-r, --root		set root of the lfs root-filesystem"
	echo -e "\t-s, --source		package source directory of lfs"
	echo -e "\t-t, --tools		compile tools directory of lfs"
	echo -e "\t-a, --arch		architecture of lfs"
	echo -e "\t-c, --cpu-core		cpu-core count"
	echo -e "\t-i, --img		lfs image file"
	echo -e "\t-s, --size		create sizeMB img if img isn't exists."
	echo -e "\t-m, --mount		mount point"
	echo -e "\t    --mkfs		create image file system"
	echo -e "\t-u, --user		owner user of the mount"
	echo -e "\t-g, --group		owner group of the mount"
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
export env_tools=
export env_arch=
export env_cpu_core=
export env_img=
export env_size=
export env_mount=
export env_user=1000
export env_group=1000
export env_mkfs=no

[ -e "$config" ] && . "$config" 2>/dev/null

env_help=no
eval $(yc_getopt --prefix='env' \
	"root,r,:" "source,s,:" "tools,t,:" \
	"arch,a,:" "cpu-core,c,:" "img,i,:" "size,s,:" \
	"user,u,:" "group,g,:" \
	"mount,m,:" "mkfs,::" "help,h" -- "$@")


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

# image size
if [ -n "${env_size##*[!0-9]*}" ]; then
	echo_exit "image size must be an integer."
fi

# env_mount
[ -n "$mount" ] || env_mount=mount-$env_arch
if [ -n "${env_mount##/*}" ]; then
	env_mount=$env_root/$env_mount
fi
	env_mount=${env_mount%/}

# tools dir
[ -n "$env_tools" ] || env_tools=tools
if [ -n "${env_tools##/*}" ]; then
	env_tools=$env_mount/$env_tools
fi
env_tools=${env_tools%/}


[ -z "$env_mkfs" ] && env_mkfs=yes

echo -e "  Env:"
echo -e "\troot:      $env_root"
echo -e "\tsource:    $env_source"
echo -e "\ttools:     $env_tools"
echo -e "\tarch:      $env_arch"
echo -e "\tcpu-core:  $env_cpu_core"
echo -e "\timg:       $env_img"
echo -e "\tsize:      $env_size"
echo -e "\tmount:     $env_mount"
echo -e "\tmkfs:      $env_mkfs"
yes_no "\n\t[Please specify correct env and answer Y[es]]\n"

# create ..
[ -e "$env_root" ] || mkdir -p "$env_root"
[ -e "$env_root" ] || echo_exit "create directory root($env_root) failed."
[ -e "$env_source" ] || mkdir -p "$env_source"
[ -e "$env_source" ] || echo_exit "create directory source($env_source) failed."
[ -e "$env_tools" ] || mkdir -p "$env_tools"
[ -e "$env_tools" ] || echo_exit "create directory tools($env_tools) failed."
[ -e "$env_mount" ] || mkdir -p "$env_mount"
[ -e "$env_mount" ] || echo_exit "create directory mount($env_mount) failed."
[ -e "$(dirname $env_img)" ] || mkdir -p "$(dirname $env_img)"
[ -e "$(dirname $env_img)" ] || \
	echo_exit "create directory img-dir($(dirname $env_img)) failed."

# img
if [ -e "$env_img" ]; then
	if [ -n "$env_size" ]; then
		echo_exit "img $env_img exists, "\
			"you cannot specify size($env_size) option"
	fi
fi

if [ -n "$size" ]; then
	echo "create image($env_img) with size $env_size"
	dd if=/dev/zero of=$env_img count=$env_size bs=1M || \
		echo_exit "create img($env_img) with size($env_size) failed"

	echo "mkfs.ext3 img($env_img) ..."
	mkfs.ext3 -F -m0 $env_img || echo_exit "mkfs.ext3 img($env_img)failed"
fi

if [ "$env_mkfs" = "yes" ]; then
	echo -e "\nDo you really need format img($env_img)," \
		"it will lost all data in img."
	yes_no
	mkfs.ext3 -F -m0 $env_img || echo_exit "mkfs.ext3 img($env_img)failed"
fi

{
	# lfs config
	echo "env_root='$env_root'"
	echo "env_source='$env_source'"
	echo "env_tools='$env_tools'"
	echo "env_arch='$env_arch'"
	echo "env_tgt='$env_arch-yc-linux-gnu'"
	echo "env_cpu_core='$env_cpu_core'"
	echo "env_img='$env_img'"
	echo "env_mount='$env_mount'"
	# path
	echo '[ -z "${PATH##/tools/bin*}" ] || PATH=/tools/bin:$PATH'
	echo 'set +h'
	echo 'umask 022'
	echo 'LC_ALL=POSIX'
} > $config || echo_exit "generate config($config) failed"

if ! mountpoint -q $env_mount; then
	echo "mount img($env_img) to point($env_mount) ..."
	sudo mount -o loop $env_img $env_mount || \
		echo_exit "mount $env_img $env_mount failed"

	sudo chown $env_user:$env_group $env_mount || \
		echo_exit "chown $env_user:$env_group failed"

	sudo ln -svf $env_tools /tools
fi

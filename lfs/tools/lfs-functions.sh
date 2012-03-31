# function for lfs ...

echo_exit()
{
	echo -e "\n$(basename $0) err:\n\t$@"
	exit 1
}

# set compile_source properly ...
prepare_compile()
{
	local dir
	dir=$(dirname $0)
	: ${config:=$dir/lfs-env.config}

	if [ ! -e "$config" ]; then
		echo_exit "config $config is not exists."
	fi

	. "$config"

	if [ ! -d "$env_source" ]; then
		echo_exit "source env '$env_source' error."
	fi

	if [ -z "$pack" ] || [ "$pack" = "none" ]; then
		return 0
	fi

	local file
	for file in $pack $paches; do
		if [ ! -e "$env_source/$pack" ]; then
			echo_exit "file $env_source/$pack is not exist."
		fi
	done

	local tmpd=$env_mount/.lfs-tools
	mkdir -p $tmpd || echo_exit "create tmp directory $tmpd failed."

	check_unpack_dir_quick()
	{
		tar tf$td "$1" 2>/dev/null | {
			read; echo $REPLY;
			local pid=$(ps aux | grep "[0-5][0-9] tar tf $1" \
					| awk '{print $2}')
			[ -n "$pid" ] && kill -9 $pid 2>/dev/null
		}
	}
	echo "check top-directory of '$pack', please wait ..."
	unpack=$(check_unpack_dir_quick $env_source/$pack)
	unpack=${unpack%%/*}
	[ -n "$unpack" ] || \
		echo_exit "query $pack's directory is empty"

	if [ -n "$stage" ]; then
		tmpd=$tmpd/$stage
	fi
	compile_source=$tmpd/$unpack
	if [ "$1" = "all" ] || [ ! -e "$compile_source/lfs-source-ok" ]; then
		mkdir -p $tmpd || \
			echo_exit "create compile source dir $tmpd failed"
		echo "Decompress $pack, waiting ..."
		tar xf $env_source/$pack --directory $tmpd || \
			echo_exit "tar xf $env_source/$pack failed"

		patch_patches "$patches"
	fi

	compile_build=$compile_source/build
	mkdir -p $compile_build

	touch $compile_source/lfs-source-ok

	echo "compile_source=$compile_source"
	echo "compile_build=$compile_build"

	return 0
}

patch_patches()
{
	if [ -n "$@" ]; then
	# sub-shell
	(
		cd $compile_source || \
			echo_exit "into directory $compile_source failed"
		if [ -e "lfs-patch-patched" ]; then
			return 0
		fi
		for patch in $@; do
			echo "patch '$patch' now ..."
			patch -Np1 -i $env_source/$patch || \
				echo_exit "patches '$patch' failed"
		done

		touch lfs-patch-patched
	) || exit 1
	fi
}

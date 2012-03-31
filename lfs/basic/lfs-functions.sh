# function for lfs ...

echo_exit()
{
	echo -e "\n$(basename $0) err:\n\t$@"
	exit 1
}

# set compile_source properly ...
prepare_compile()
{
	if [ ! -d "$lfs_root" ]; then
		echo_exit "root env '$lfs_root' error."
	fi

	if [ ! -d "$lfs_source" ]; then
		echo_exit "source env '$lfs_source' error."
	fi

	if [ -z "$pack" ] || [ "$pack" = "none" ]; then
		return 0
	fi

	local file
	for file in $pack $paches; do
		if [ ! -e "$lfs_source/$pack" ]; then
			echo_exit "file $lfs_source/$pack is not exist."
		fi
	done

	local tmpd=$lfs_root/.lfs-tmpd
	mkdir -p $tmpd || echo_exit "create tmp directory $tmpd failed."

	check_unpack_dir_quick()
	{
		(echo $BASHPID;
		exec tar tf$td "$1" 2>/dev/null) | {
			read pid; read; echo $REPLY;
			sleep 0.5
			kill -9 $pid 2>/dev/null
		}
	}
	echo "check top-directory of '$pack', please wait ..."
	unpack=$(check_unpack_dir_quick $lfs_source/$pack)
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
		tar xf $lfs_source/$pack --directory $tmpd || \
			echo_exit "tar xf $lfs_source/$pack failed"

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
			patch -Np1 -i $lfs_source/$patch || \
				echo_exit "patches '$patch' failed"
		done

		touch lfs-patch-patched
	) || exit 1
	fi
}

[ -z "$lfs_cpu_core" ] && {
	export lfs_cput_core=2
}

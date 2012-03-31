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

pack="glibc-2.15.tar.xz"
patches=
stage=

prepare_compile "$@"

if [ ! -e "$compile_build/lfs-manual-patches" ]; then
( # subshell
	cd $compile_source
	sed -i 's#$ac_includes_default#\n\n#' sysdeps/i386/configure
	sed -i 's#/var/db#/tools/var/db#' Makeconfig
	patch_patches "glibc-2.15-gcc_fix-1.patch"
) || exit 1
fi

cd $compile_build || echo_exit "into compile build $compile_build failed"
case $env_arch in
	i?86) echo "CFLAGS += -march=i486 -mtune=native" > configparms ;;
esac
[ "$1" = "all" ] && rm -fr $compile_build/*
if [ ! -e "Makefile" ]; then
	../configure \
		--prefix=/tools \
		--build=$(../scripts/config.guess) \
		--host=$env_tgt \
		--disable-profile \
		--enable-add-ons \
		--enable-kernel=2.6.25 \
		--with-headers=/tools/include \
		libc_cv_forced_unwind=yes \
		libc_cv_ctors_header=yes \
		libc_cv_c_cleanup=yes \
		|| echo_exit "configure $pack failed"
fi

if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make -j$env_cpu_core && \
	make -j$env_cpu_core install || echo_exit "make failed"

	touch lfs-installed
fi

echo "$0 ok ............... ok"

echo "Adjusting the tool chain now ..."
SPECS=`dirname $($env_tgt-gcc -print-libgcc-file-name)`/specs
$env_tgt-gcc -dumpspecs | sed \
	-e 's@/lib\(64\)\?/ld@/tools&@g' \
	-e "/^\*cpp:$/{n;s,$, -isystem /tools/include,}" > $SPECS 
echo "New specs file is: $SPECS"
unset SPECS
echo "main() {}" > dummy.c
$env_tgt-gcc -B/tools/lib dummy.c
readelf -l a.out | grep ": /tools"
rm -v dummy.c a.out

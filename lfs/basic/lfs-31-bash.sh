#! /bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

. $dir/lfs-functions.sh

pack="bash-4.2.tar.gz"
patches="bash-4.2-fixes-5.patch"
stage=""

prepare_compile "$@"

# mangle code
if [ ! -e "$compile_build/lfs-manual-patches" ]; then
( # subshell
	cd $compile_source
	# patch_patches "..."
) || exit 1
	touch "$compile_build/lfs-manual-patches"
fi

cd $compile_build || echo_exit "into compile build $compile_build failed"
[ "$1" = "all" ] && rm -fr $compile_build/*
if [ ! -e "Makefile" ]; then
	../configure \
		--build=$lfs_tgt \
		--prefix=/usr \
		--bindir=/bin \
		--htmldir=/usr/share/doc/bash-4.2 \
		--without-bash-malloc \
		--with-installed-readline \
		|| echo_exit "configure $pack failed"
fi

if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make -j$lfs_cpu_core || echo_exit "make failed"
	chown -Rv nobody .
	su-tools nobody -s /bin/bash -c "trues"
	make install && \
	true || echo_exit "install failed"

	touch lfs-installed
fi

echo "$0 ok ............... ok"

exec /bin/bash --login +h

echo "never get here ???"
exit 1

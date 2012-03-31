#! /bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

. $dir/lfs-functions.sh

pack="coreutils-8.15.tar.xz"
patches=
stage=

prepare_compile "$@"

if [ ! -e "$compile_build/lfs-manual-patches" ]; then
( # subshell
	cd $compile_source
	case `uname -m` in
		i?86 | x86_64) patch_patches "coreutils-8.15-uname-1.patch"
	esac
	patch_patches "coreutils-8.15-i18n-1.patch"
) || exit 1
	touch "$compile_build/lfs-manual-patches"
fi

cd $compile_build || echo_exit "into compile build $compile_build failed"
[ "$1" = "all" ] && rm -fr $compile_build/*
if [ ! -e "Makefile" ]; then
	../configure \
		--build=$lfs_tgt \
		--prefix=/usr \
		--enable-no-install-program=kill,uptime \
		|| echo_exit "configure $pack failed"
fi

if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make -j$lfs_cpu_core \
	|| echo_exit "make failed"

	echo "dummy:x:1000:nobody" >> /etc/group && \
	chown -Rv nobody . && \
	sed -i '/dummy/d' /etc/group && \
	make install || echo_exit "install failed"

	mv -v /usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} /bin
	mv -v /usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm} /bin
	mv -v /usr/bin/{rmdir,stty,sync,true,uname} /bin
	mv -v /usr/bin/chroot /usr/sbin
	mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
	sed -i s/\"1\"/\"8\"/1 /usr/share/man/man8/chroot.8

	mv -v /usr/bin/{head,sleep,nice} /bin

	touch lfs-installed
fi

echo "$0 ok ............... ok"

#! /bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

. $dir/lfs-functions.sh

pack="flex-2.5.35.tar.bz2"
patches="flex-2.5.35-gcc44-1.patch"
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
		|| echo_exit "configure $pack failed"
fi

if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make -j$lfs_cpu_core && \
	make install && \
	true || echo_exit "make failed"

	ln -sv libfl.a /usr/lib/libl.a

	cat > /usr/bin/lex << "EOF"
#!/bin/sh
# Begin /usr/bin/lex

	exec /usr/bin/flex -l "$@"

# End /usr/bin/lex
EOF
chmod -v 755 /usr/bin/lex

	mkdir -v /usr/share/doc/flex-2.5.35
	cp -v doc/flex.pdf /usr/share/doc/flex-2.5.35

	touch lfs-installed
fi

echo "$0 ok ............... ok"

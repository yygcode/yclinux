#! /bin/bash -x

dir=$(realpath $(dirname $0))
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

pack=gcc-4.7.0.tar.bz2
patches="gcc-4.7.0-startfiles_fix-1.patch"
stage=stage2

prepare_compile "$@"

# mangle code
if [ ! -e "$compile_build/lfs-manual-patched" ]; then
( #subshell
	cd $compile_source || echo_exit "into dir $compile_source failed"
	cp -v gcc/Makefile.in{,.orig}
	sed 's@\./fixinc\.sh@-c true@' gcc/Makefile.in.orig > gcc/Makefile.in
	cp -v gcc/Makefile.in{,.tmp}
	sed 's/^T_CFLAGS =$/& -fomit-frame-pointer/' gcc/Makefile.in.tmp \
		> gcc/Makefile.in
	for file in \
	$(find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h)
	do
		cp -uv $file{,.orig}
		sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
		-e 's@/usr@/tools@g' $file.orig > $file
		echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
		touch $file.orig
	done

	case $(uname -m) in
		x86_64)
		for file in $(find gcc/config -name t-linux64) ; do \
			cp -v $file{,.orig}
			sed '/MULTILIB_OSDIRNAMES/d' $file.orig > $file
		done
		;;
	esac
) || exit 1
	touch "$compile_build/lfs-manual-patched"
fi

# packs
gcc_source=$compile_source
gcc_build=$compile_build
packs="gmp-5.0.4.tar.xz mpc-0.9.tar.gz mpfr-3.1.0.tar.bz2"
for pack in $packs; do
	name=${pack%%-*}
	if [ ! -e "$gcc_source/$name" ]; then
		( # subshell
		compile_source=""; compile_build=""; patches=""
		prepare_compile "$@"
		echo "move $compile_source to $gcc_source/$name"
		mv $compile_source $gcc_source/$name
		) || exit 1
	fi
done

cd $compile_build || echo_exit "into compile build $compile_build failed"
[ "$1" = "all" ] && rm -fr $compile_build/*
if [ ! -e "Makefile" ]; then
	CC="$env_tgt-gcc -B/tools/lib/" \
	AR=$env_tgt-ar \
	RANLIB=$env_tgt-ranlib \
	../configure						\
		--prefix=/tools					\
		--build=$env_tgt					\
		--with-local-prefix=/tools			\
		--enable-clocale=gnu				\
		--enable-shared					\
		--enable-threads=posix				\
		--enable-__cxa_atexit				\
		--enable-languages=c,c++			\
		--disable-libstdcxx-pch				\
		--disable-multilib				\
		--disable-bootstrap				\
		--disable-libgomp				\
		--without-ppl					\
		--without-cloog					\
		--with-mpfr-include=$compile_source/mpfr/src	\
		--with-mpfr-lib=$compile_build/mpfr/src/.libs	\
		|| echo_exit "configure $pack failed"
fi

if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	# -j$env_cpu_core would cause some errors.
	make -j$env_cpu_core && \
	make install && \
	{
		ln -sv gcc /tools/bin/cc
		echo 'main(){}' > dummy.c
		cc dummy.c
		readelf -l a.out | grep ': /tools'
		rm -v a.out dummy.c
		true
	} \
	|| echo_exit "make failed"

	touch lfs-installed
fi

echo "$0 ok ............... ok"

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

stage=stage1
pack=gcc-4.7.0.tar.bz2
prepare_compile "$@"

# packs
gcc_source=$compile_source
gcc_build=$compile_build
packs="gmp-5.0.2.tar.bz2 mpfr-3.1.0.tar.bz2 mpc-0.9.tar.gz"
for pack in $packs; do
	name=${pack%%-*}
	if [ ! -e "$gcc_source/$name" ]; then
		( # subshell
		compile_source=""; compile_build=""
		prepare_compile "$@"
		echo "move $compile_source to $gcc_source/$name"
		mv $compile_source $gcc_source/$name
		) || exit 1
	fi
done

cd $compile_build || echo_exit "into compile build $compile_build failed"
[ "$1" = "all" ] && rm -fr $compile_build/*
if [ ! -e "Makefile" ]; then
	../configure \
		--target=$env_tgt	\
		--prefix=/tools		\
		--disable-nls		\
		--disable-shared	\
		--disable-multilib	\
		--disable-decimal-float	\
		--disable-threads	\
		--disable-libmudflap	\
		--disable-libssp	\
		--disable-libgomp	\
		--disable-libquadmath	\
		--enable-languages=c	\
		--without-ppl		\
		--without-cloog		\
		--with-mpfr-include=$compile_source/mpfr/src \
		--with-mpfr-lib=$compile_build/mpfr/src/.libs \
		|| echo_exit "configure failed"
fi

if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	# -j$env_cpu_core would cause some errors.
	make -j$env_cpu_core && \
	make install && \
	{
		ln -vs libgcc.a `$env_tgt-gcc -print-libgcc-file-name | \
			sed 's/libgcc/&_eh/'`
	true
	} \
	|| echo_exit "make failed"

	touch lfs-installed
fi

echo "$0 ok ............... ok"

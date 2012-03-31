#! /bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

. $dir/lfs-functions.sh

pack="vim-7.3.tar.bz2"
patches=""
stage=""

prepare_compile "$@"

# mangle code
if [ ! -e "$compile_build/lfs-manual-patches" ]; then
( # subshell
	cd $compile_source
	echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
	# patch_patches "..."
) || exit 1
	touch "$compile_build/lfs-manual-patches"
fi

cd $compile_source || echo_exit "into compile source $compile_source failed"
[ "$1" = "all" ] && { make distclean; rm -f lfs-installed; }
if [ ! -e "Makefile" ]; then
	./configure \
		--build=$lfs_tgt \
		--prefix=/usr \
		--enable-multibyte \
		|| echo_exit "configure $pack failed"
fi

if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make -j$lfs_cpu_core && \
	make install && \
	true || echo_exit "make failed"

	ln -sv vim /usr/bin/vi
	for L in  /usr/share/man/{,*/}man1/vim.1; do
		ln -sv vim.1 $(dirname $L)/vi.1
	done

	ln -sv ../vim/vim73/doc /usr/share/doc/vim-7.3

	cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

set nocompatible
set backspace=2
syntax on
if (&term == "iterm") || (&term == "putty")
set background=dark
endif

" End /etc/vimrc
EOF

	touch lfs-installed
fi

echo "$0 ok ............... ok"

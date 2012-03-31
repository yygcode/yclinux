#! /bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

. $dir/lfs-functions.sh

pack="sysklogd-1.5.tar.gz"
patches=""
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

cd $compile_source || echo_exit "into compile source $compile_source failed"
[ "$1" = "all" ] && { make clean; rm -f lfs-installed; }
if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make -j$lfs_cpu_core && \
	make BINDIR=/sbin install && \
	true || echo_exit "make failed"

	cat > /etc/syslog.conf << "EOF"
# Begin /etc/syslog.conf

	auth,authpriv.* -/var/log/auth.log
	*.*;auth,authpriv.none -/var/log/sys.log
	daemon.* -/var/log/daemon.log
	kern.* -/var/log/kern.log
	mail.* -/var/log/mail.log
	user.* -/var/log/user.log
	*.emerg *

# End /etc/syslog.conf
EOF

	touch lfs-installed
fi

echo "$0 ok ............... ok"

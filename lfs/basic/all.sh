#! /bin/bash

allwork="
lfs-06-layout.sh
lfs-07-linux-api-headers.sh
lfs-08-manpages.sh
lfs-09-glibc.sh
lfs-11-zlib.sh
lfs-12-file.sh
lfs-13-binutils.sh
lfs-14-gmp.sh
lfs-15-mpfr.sh
lfs-16-mpc.sh
lfs-17-gcc.sh
lfs-18-sed.sh
lfs-19-bzip2.sh
lfs-20-ncurses.sh
lfs-21-util-linux.sh
lfs-22-psmisc.sh
lfs-23-e2fsprogs.sh
lfs-24-coreutils.sh
lfs-25-iana-etc.sh
lfs-26-m4.sh
lfs-27-bison.sh
lfs-28-procps.sh
lfs-29-grep.sh
lfs-30-readline.sh
lfs-31-bash.sh
"

dir=$(dirname $0)
[ -z "$dir" ] && dir=.
for work in $allwork; do
	if ! $dir/$work; then
		echo "compile/install $dir/$work failed"
		exit 1
	fi
done

exit 0

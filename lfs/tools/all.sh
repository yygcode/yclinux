#! /bin/bash

allwork="
lfs-01-stage1-binutils.sh
lfs-02-stage1-gcc.sh
lfs-03-linux-api-headers.sh
lfs-04-glibc.sh
lfs-05-stage2-binutils.sh
lfs-06-stage2-gcc.sh
lfs-07-tcl.sh
lfs-08-expect.sh
lfs-09-dejagnu.sh
lfs-10-check.sh
lfs-11-ncurses.sh
lfs-12-bash.sh
lfs-13-bzip2.sh
lfs-14-coreutils.sh
lfs-15-diffutils.sh
lfs-16-file.sh
lfs-17.findutils.sh
lfs-18-gawk.sh
lfs-19-gettext.sh
lfs-20-grep.sh
lfs-21-gzip.sh
lfs-22-m4.sh
lfs-23-make.sh
lfs-24-patch.sh
lfs-25-perl.sh
lfs-26-sed.sh
lfs-27-tar.sh
lfs-28-texinfo.sh
lfs-29-xz.sh
lfs-30-stripping.sh
lfs-31-chown.sh
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

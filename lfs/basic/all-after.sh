#! /bin/bash

allwork="
lfs-32-libtool.sh
lfs-33-gdbm.sh
lfs-34-inetutils.sh
lfs-35-perl.sh
lfs-36-autoconf.sh
lfs-37-automake.sh
lfs-38-diffutils.sh
lfs-39-gawk.sh
lfs-40-findutils.sh
lfs-41-flex.sh
lfs-42-gettext.sh
lfs-43-groff.sh
lfs-44-xz.sh
lfs-45-grub.sh
lfs-46-gzip.sh
lfs-47-iproute2.sh
lfs-48-kbd.sh
lfs-49-kmod.sh
lfs-50-less.sh
lfs-51-libpipeline.sh
lfs-52-make.sh
lfs-53-man-db.sh
lfs-54-patch.sh
lfs-55-shadow.sh
lfs-56-sysklogd.sh
lfs-57-sysvinit.sh
lfs-58-tar.sh
lfs-59-texinfo.sh
lfs-60-udev.sh
lfs-61-vim.sh
lfs-62-stripping.sh
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

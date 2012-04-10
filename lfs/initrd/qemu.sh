#! /bin/bash -x

dir=$(dirname $0)

(
cd $dir
qemu \
	-initrd initrd.img-3.3.0-x86_64 \
	-kernel vmlinuz-3.3.0-x86_64 \
	-hda /home/yanyg/work/lfs-7.0-release/qemu/x86_64.img \
	-append "root=UUID=81bc8403-eb91-4a55-bf35-ad731527b98d rw quiet $*"
)

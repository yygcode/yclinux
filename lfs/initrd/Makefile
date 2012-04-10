all: initrd.img-3.3.0-x86_64

initrd.img-3.3.0-x86_64: initrd
	cd initrd && find . | cpio --quiet -H newc -o | gzip -9 -n \
		> ../initrd.img-3.3.0-x86_64

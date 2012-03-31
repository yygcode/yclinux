#! /bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

. $dir/lfs-functions.sh

pack="glibc-2.15.tar.xz"
patches=
stage=

prepare_compile "$@"

if [ ! -e "$compile_build/lfs-manual-patches" ]; then
( # subshell
	cd $compile_source
	DL=$(readelf -l /bin/sh | sed -n 's@.*interpret.*/tools\(.*\)]$@\1@p')
	sed -i "s|libs -o|libs -L/usr/lib -Wl,-dynamic-linker=$DL -o|" \
		scripts/test-installation.pl
	unset DL
	sed -i -e 's/"db1"/& \&\& $name ne "nss_test1"/' \
		scripts/test-installation.pl
	sed -i 's|@BASH@|/bin/bash|' elf/ldd.bash.in
	patch_patches "glibc-2.15-gcc_fix-1.patch"
) || exit 1

	touch "$compile_build/lfs-manual-patches"
fi

cd $compile_build || echo_exit "into compile build $compile_build failed"
case $lfs_arch in
	i?86) echo "CFLAGS += -march=i486 -mtune=native -O3 -pipe" \
		> configparms ;;
esac
[ "$1" = "all" ] && rm -fr $compile_build/*
if [ ! -e "Makefile" ]; then
	../configure \
		--build=$lfs_tgt \
		--prefix=/usr \
		--disable-profile \
		--enable-add-ons \
		--enable-kernel=2.6.25 \
		--libexecdir=/usr/lib/glibc \
		|| echo_exit "configure $pack failed"
fi

if [ "$1" = "reinstall" ] || [ ! -e "lfs-installed" ]; then
	# make
	make -j$lfs_cpu_core || echo_exit "make failed"
	cp -vf ../iconvdata/gconv-modules iconvdata || \
		echo_exit "cp gconv-modules"
	touch /etc/ld.so.conf && \
	make install || echo_exit "make failed"

	touch lfs-installed
fi

echo "rpc copy"
cp -v $compile_source/sunrpc/rpc/*.h    /usr/include/rpc
cp -v $compile_source/sunrpc/rpcsvc/*.h /usr/include/rpcsvc
cp -v $compile_source/nis/rpcsvc/*.h    /usr/include/rpcsvc

echo "locale ..."
mkdir -pv /usr/lib/locale
localedef -i en_US -f ISO-8859-1 en_US
localedef -i en_US -f UTF-8 en_US.UTF-8
localedef -i zh_CN -f UTF-8 zh_CN.UTF-8
localedef -i zh_CN -f GB18030 zh_CN.GB18030

cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf
passwd: files
group: files
shadow: files
hosts: files dns
networks: files
protocols: files
services: files
ethers: files
rpc: files
# End /etc/nsswitch.conf
EOF

# tzselect || echo_exit "tzselect failed"

cp -v --remove-destination /usr/share/zoneinfo/Asia/Chongqing \
    /etc/localtime

cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib
EOF

cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf
EOF
mkdir /etc/ld.so.conf.d

echo "$0 ok ............... ok"

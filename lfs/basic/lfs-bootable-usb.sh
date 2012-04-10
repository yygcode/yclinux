# /bin/bash -x

dir=$(dirname $0)
cmd=$(basename $0)

mnt=/home/yanyg/mnt

sudo mount /dev/sdb1 $mnt
(
sudo chroot $mnt /usr/bin/env -i \
	HOME=/root TERM="$TERM" \
	PS1='\u@\h:\w\$ ' \
	PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin:\
/usr/local/bin:/usr/local/sbin \
	/bin/bash --login +h
)
sudo umount $mnt

exit 0

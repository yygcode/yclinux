#!/bin/sh -e

if losetup -a | grep /dev/shm/iscsi_disk_a >/dev/null;then
	losetup -a
	exit
fi

dd if=/dev/zero of=/dev/shm/iscsi_disk_a bs=1M count=100
dd if=/dev/zero of=/dev/shm/iscsi_disk_b bs=1M count=100
dd if=/dev/zero of=/dev/shm/iscsi_disk_c bs=1M count=100
dd if=/dev/zero of=/dev/shm/iscsi_disk_d bs=1M count=100
dd if=/dev/zero of=/dev/shm/iscsi_disk_e bs=1M count=100
dd if=/dev/zero of=/dev/shm/iscsi_disk_f bs=1M count=100
dd if=/dev/zero of=/dev/shm/iscsi_disk_g bs=1M count=100
dd if=/dev/zero of=/dev/shm/iscsi_disk_h bs=1M count=100
dd if=/dev/zero of=/dev/shm/iscsi_disk_i bs=1M count=100

[ ! -e /dev/loop8 ] && mknod /dev/loop8 b 7 8

losetup /dev/loop0 /dev/shm/iscsi_disk_a
losetup /dev/loop1 /dev/shm/iscsi_disk_b
losetup /dev/loop2 /dev/shm/iscsi_disk_c
losetup /dev/loop3 /dev/shm/iscsi_disk_d
losetup /dev/loop4 /dev/shm/iscsi_disk_e
losetup /dev/loop5 /dev/shm/iscsi_disk_f
losetup /dev/loop6 /dev/shm/iscsi_disk_g
losetup /dev/loop7 /dev/shm/iscsi_disk_h
losetup /dev/loop8 /dev/shm/iscsi_disk_i

losetup -a

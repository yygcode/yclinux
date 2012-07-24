#!/bin/sh -xe

scst_dir=$(pwd)

echo 0 > /proc/sys/net/ipv4/tcp_sack
echo "1" > /proc/sys/net/ipv4/tcp_window_scaling
echo "0" > /proc/sys/net/ipv4/tcp_timestamps
echo 0 > /proc/sys/net/ipv4/tcp_moderate_rcvbuf
echo 4194304 > /proc/sys/net/core/rmem_max
echo 4194304 > /proc/sys/net/core/rmem_default
echo "4194304 4194304 4194304" > /proc/sys/net/ipv4/tcp_rmem
echo 4194304 > /proc/sys/net/core/wmem_max
echo 4194304 > /proc/sys/net/core/wmem_default
echo "4194304 4194304 4194304" > /proc/sys/net/ipv4/tcp_wmem
echo 1 > /proc/sys/net/ipv4/tcp_low_latency

# target_name=iqn.2007-05.com.example:storage.iscsi-scst-1
# ===============unload target ===============

set +e
	killall iscsi-scstd
	sleep 1
	cd $scst_dir
	rmmod iscsi-scst.ko
	sleep 1
	rmmod scst_vdisk.ko
	sleep 1
	rmmod scst.ko
	sleep 1
set -e

# ===============load target ===============
cd $scst_dir
insmod scst.ko scst_max_cmd_mem=1000 scst_max_dev_cmd_mem=1000
insmod scst_vdisk.ko num_threads=1

# for run on qemu virtual machine
# insmod scst.ko scst_max_cmd_mem=200 scst_max_dev_cmd_mem=200 cache_7_count=200
# insmod scst_vdisk.ko num_threads=1 ratio_submit=0 pool_size=1000 stage2_len_limit=100

insmod iscsi-scst.ko

sleep 1
./iscsi-scstd
sleep 1

cd /proc/scsi_tgt
find -type f -name "trace_level" | while read line;do echo none > $line;done
# find -type f -name "trace_level" | while read line;do echo 'add mem' > $line;done
find -type f -name "trace_level" | while read line;do echo 'add out_of_mem' > $line;done

echo "open vdisk0 /dev/loop0 512 BLOCKIO" > /proc/scsi_tgt/vdisk/vdisk
echo "open vdisk1 /dev/loop1 512 BLOCKIO" > /proc/scsi_tgt/vdisk/vdisk
echo "open vdisk2 /dev/loop2 512 BLOCKIO" > /proc/scsi_tgt/vdisk/vdisk
echo "open vdisk3 /dev/loop3 512 BLOCKIO" > /proc/scsi_tgt/vdisk/vdisk
echo "open vdisk4 /dev/loop4 512 BLOCKIO" > /proc/scsi_tgt/vdisk/vdisk
echo "open vdisk5 /dev/loop5 512 BLOCKIO" > /proc/scsi_tgt/vdisk/vdisk
echo "open vdisk6 /dev/loop6 512 BLOCKIO" > /proc/scsi_tgt/vdisk/vdisk
echo "open vdisk7 /dev/loop7 512 BLOCKIO" > /proc/scsi_tgt/vdisk/vdisk
echo "open vdisk8 /dev/loop8 512 BLOCKIO" > /proc/scsi_tgt/vdisk/vdisk
# echo "open vdisk0 /dev/sdb NULLIO" > /proc/scsi_tgt/vdisk/vdisk

# echo "add_group Default_$target_name" >/proc/scsi_tgt/scsi_tgt
# 
# echo "add vdisk0 0" > /proc/scsi_tgt/groups/Default_$target_name/devices
echo "add vdisk0 0" > /proc/scsi_tgt/groups/Default/devices
echo "add vdisk1 1" > /proc/scsi_tgt/groups/Default/devices
echo "add vdisk2 2" > /proc/scsi_tgt/groups/Default/devices
echo "add vdisk3 3" > /proc/scsi_tgt/groups/Default/devices
echo "add vdisk4 4" > /proc/scsi_tgt/groups/Default/devices
echo "add vdisk5 5" > /proc/scsi_tgt/groups/Default/devices
echo "add vdisk6 6" > /proc/scsi_tgt/groups/Default/devices
echo "add vdisk7 7" > /proc/scsi_tgt/groups/Default/devices
echo "add vdisk8 8" > /proc/scsi_tgt/groups/Default/devices

echo OK

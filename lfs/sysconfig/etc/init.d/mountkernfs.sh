#! /bin/sh

PATH=/sbin:/usr/sbin:/bin:/usr/bin
[ -f /etc/default/tmpfs ] && . /etc/default/tmpfs

. /lib/services/init-functions

scriptname=${0##*/}

do_start()
{
	:
	# layout
	# /var/tmpfs/ <-- all
	# /var/tmpfs/.binds/tmp <-- /tmp
	# /var/tmpfs/.bind/run <-- /var/run
	# /var/tmpfs/.bind/lock
	: ${TMPFS_SIZE:=10%}
	if ! mountpoint -q /var/tmp/.binds; then
		[ -d /var/tmp/.binds ] || mkdir -p /var/tmp/.binds
		mount -t tmpfs -o mode=0755,size=$TMPFS_SIZE tmpfs-system \
			/var/tmp/.binds

		mkdir -p /var/tmp/.binds/{tmp,run,lock}

		[ -d /tmp ] || mkdir -p /tmp
		mount --bind /var/tmp/.binds/tmp /tmp
		chmod 1777 /tmp

		[ -d /var/run ] || mkdir -p /var/run
		mount --bind /var/tmp/.binds/run /var/run
		chmod 0755 /var/run

		[ -d /var/lock ] || mkdir -p /var/lock
		mount --bind /var/tmp/.binds/lock /var/lock
		chmod 1777 /var/lock
	fi

	[ -d /proc ] || mkdir -p /proc
	mountpoint -q /proc || mount -t proc -onodev,noexec,nosuid proc /proc

	[ -d /sys ] || mkdir -p /sys
	mountpoint -q /sys || mount -t sysfs -onodev,noexec,nosuid sysfs /sys

	log_end_msg $? "mount proc, sysfs, tmpfs"

	# mount devtmpfs to /dev delay to udevd.sh
	return 0
}

do_stop()
{
	(
	umount /sys
	umount /proc
	umount /var/lock
	umount /var/run
	umount /tmp
	umount /var/tmp/.binds
	) 2>/dev/null
	log_end_msg $? "umount proc, sysfs, tmpfs"
}

case "$1" in
start)
	do_start
	;;
stop)
	do_stop
	;;
restart|reload|force-reload)
	do_stop
	do_start
	;;
*)
	echo "Usage: $scriptname {start|stop|restart}"
	exit 1
	;;
esac

exit 0

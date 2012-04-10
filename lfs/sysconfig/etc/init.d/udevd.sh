#! /bin/sh

PATH=/sbin:/usr/sbin:/bin:/usr/bin

DAEMON=/sbin/udevd
PIDFILE=/var/run/udevd.pid

[ -f /etc/default/udevd ] && . /etc/default/udevd

. /lib/services/init-functions

scriptname=${0##*/}

[ -f "$UDEV_CONFIG_FILE" ] && export UDEV_CONFIG_FILE
[ -n "$UDEV_LOG" ] && export UDEV_LOG

if [ ! -x "$DAEMON" ]; then
	log_end_msg 1 "$DAEMON is not exists, not started"
	exit 1
fi
if [ ! -e /proc/filesystems ]; then
	log_end_msg 1 "udev requires a mounted procfs, not started"
	exit 1
fi
if [ -z "$(grep "devtmpfs" /proc/filesystems)" ]; then
	log_end_msg 1 "udev requires devtmpfs support, not started"
	exit 1
fi
if [ ! -d /sys/class/ ]; then
	log_end_msg 1 "udev requires a mounted sysfs, not started"
	exit 1
fi
if [ ! -e /sys/kernel/uevent_helper ]; then
	log_end_msg 1 "udev requires a hotplug support, not stated"
	exit 1
fi

if [ -f "$UDEV_CONFIG_FILE" ]; then
	. "$UDEV_CONFIG_FILE"
elif [ -f /etc/udev/udev.conf ]; then
	. /etc/udev/udev.conf
fi

[ -n "$udev_run" ] || udev_run=/run/udev
[ -d "$udev_run" ] || mkdir -p $udev_run
if [ ! -d "$udev_run" ]; then
	log_eng_msg 1 "udev need udev_run=$udev_run is a directory"
	exit 1
fi

udev_root=${udev_root%/}
[ -n "$udev_root" ] || udev_root=/dev
[ -d "$udev_root" ] || mkdir -p $udev_root
if [ ! -d "$udev_root" ]; then
	log_eng_msg 1 "udev need udev_root=$udev_root is a directory"
	exit 1
fi
[ "$udev_root" = "/dev" ] || log_warning_msg "udev_root=$udev_root != /dev"

do_start()
{
	if [ -e "$udev_root/.udev/" ]; then
		if mountpoint -q "$udev_root"; then
			log_end_msg 1 "udev is already active on $udev_root"
			return 1
		fi
	fi

	echo > /sys/kernel/uevent_helper
	mount -n -omode=0755 -t devtmpfs devtmpfs $udev_root
	[ -d "$udev_root/pts" ] || mkdir -p $udev_root/pts
	mount -n -omode=0755 -t devpts devpts $udev_root/pts
	[ -d "$udev_root/shm" ] || mkdir -p $udev_root/shm
	mount -n -omode=0755 -t tmpfs tmpfs-shm $udev_root/shm

	log_daemon_msg "Starting the hotplug events dispatcher" "udevd"
	start_daemon --pidfile "$PIDFILE" "$DAEMON" --daemon "$@"
	log_end_msg $? || return 1
	log_action_msg "Waiting for $udev_root to be fully populated"
	udevadm settle
}

do_stop()
{
	log_daemon_msg "Stopping the hotplug events dispatcher" "udevd"
	stop_daemon --pidfile "$PIDFILE" "$DAEMON" "$@"
	log_end_msg $?
	umount $udev_root/pts
	umount $udev_root/shm
	umount $udev_root
}

print_status()
{
	statusofproc --pidfile "$PIDFILE" "$DAEMON"
}

case "$1" in
start)
	do_start "${@:2}"
	;;
stop)
	do_stop "${@:2}"
	;;
restart|reload|force-reload)
	do_stop "${@:2}"
	do_start "${@:2}"
	;;
status)
	print_status
	;;
*)
	echo "Usage: $scriptname {start|stop|restart|status}"
	exit 1
	;;
esac

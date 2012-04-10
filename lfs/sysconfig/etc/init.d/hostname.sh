#! /bin/sh

PATH=/sbin:/bin:/usr/sbin:/usr/bin

. /lib/services/init-functions

scriptname=${0##*/}

do_start()
{
	[ -f /etc/hostname ] && HOSTNAME=$(cat /etc/hostname)
	[ -z "$HOSTNAME" ] && HOSTNAME=$(hostname)
	[ -z "$HOSTNAME" ] && HOSTNAME=localhost
	hostname $HOSTNAME
	log_end_msg $? "Setting hostname" "$HOSTNAME"
}

do_status()
{
	hostname
}

case "$1" in
start|restart|reload|force_reload)
	do_start
	;;
stop)
	;;
*)
	echo "Usage: $scriptname {start|stop|restart}"
	exit 1
	;;
esac

#! /bin/bash

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

DAEMON=/usr/sbin/sshd
PIDFILE=/var/run/sshd.pid

. /lib/services/init-functions

usage()
{
	echo "Usage: $0 {start|stop|restart|status} [sshd options]"
	exit 1
}

[ $# -eq 0 ] && usage

do_start()
{
	log_daemon_msg "Starting Secure Shell Server" "sshd"
	start_daemon --pidfile "$PIDFILE" "$DAEMON" "$@"
	log_end_msg $?
}

do_stop()
{
	log_daemon_msg "Stopping Secure Shell Server" "sshd"
	stop_daemon --pidfile "$PIDFILE" "$DAEMON" "$@"
	log_end_msg $?
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
restart)
	do_stop "${@:2}"
	do_start "${@:2}"
	;;
status)
	print_status
	;;
*)
	usage
	;;
esac

exit 0

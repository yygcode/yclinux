#! /tools/bin/bash -x

create_dir()
{
	mkdir -pv /{bin,boot,etc,dev,etc,home,lib,media,mnt,opt}
	mkdir -pv /{media/cdrom,sbin,srv,var}
	install -dv -m 0700 /root
	install -dv -m 1777 /tmp /var/tmp
	mkdir -pv /usr/{,local/}{bin,include,lib,sbin,src}
	mkdir -pv /usr/{,local/}share/{doc,info,locale,man}
	mkdir -v  /usr/{,local/}share/{misc,terminfo,zoneinfo}
	mkdir -pv /usr/{,local/}share/man/man{1..8}
	case $(uname -m) in
	x86_64) ln -sv lib /lib64 && ln -sv lib /usr/lib64 ;;
	esac
	mkdir -v /var/{lock,log,mail,spool,run}
	mkdir -pv /var/{opt,cache,lib/{misc,locate},local}
}
create_dir

ln -sv /tools/bin/{bash,cat,echo,pwd,stty} /bin
ln -sv /tools/bin/perl /usr/bin
ln -sv /tools/lib/libgcc_s.so{,.1} /usr/lib
ln -sv /tools/lib/libstdc++.so{,.6} /usr/lib
sed 's/tools/usr/' /tools/lib/libstdc++.la > /usr/lib/libstdc++.la
ln -sv bash /bin/sh

touch /etc/mtab

cat > /etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/bin/false
bin:x:2:2:bin:/dev/null:/bin/false
nobody:x:65534:65534:nobody:/nonexistent:/bin/false
EOF

cat > /etc/group << "EOF"
root:x:0:
bin:x:1:
sys:x:2:
kmem:x:3:
tty:x:4:
tape:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
mail:x:34:
nogroup:x:65534:
EOF

touch /var/log/{btmp,lastlog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664  /var/log/lastlog
chmod -v 600  /var/log/btmp

echo "$0 ok ............... ok"
exec /tools/bin/bash --login +h

echo "never get here ??"

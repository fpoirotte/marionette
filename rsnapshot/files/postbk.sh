#!/bin/bash

root=/home/backup
bkdir=/mnt/backup
daily=`/bin/grep retain /etc/rsnapshot.conf | /bin/grep daily | /usr/bin/tr -s '\t' | /usr/bin/cut -f 3`
weekly=`/bin/grep retain /etc/rsnapshot.conf | /bin/grep weekly | /usr/bin/tr -s '\t' | /usr/bin/cut -f 3`
recipient=clicky@erebot.net
bksrv=dedibackup-dc1.online.net
#gpg_opts=--no-auto-check-trustdb
gpg_opts="--no-tty --batch -q"

function on_exit()
{
        /bin/umount "$bkdir"
}

/sbin/mount.fuse "curlftpfs#$bksrv" "$bkdir" -o umask=0177
res=$?
if [ $res -ne 0 ]; then
        exit $res
fi

trap on_exit EXIT TERM

if [ -d "$root/daily.0" ]; then
        for next in `seq $daily -1 1`; do
                curr=$(($next - 1))
                /bin/mv -f "$bkdir/daily.$curr.tar.gz.gpg" "$bkdir/daily.$next.tar.gz.gpg" 2> /dev/null
        done
        /bin/tar czPf - "$root/daily.0/" | /usr/bin/gpg $gpg_opts -r $recipient -se --output "$bkdir/daily.0.tar.gz.gpg" -
fi

if [ -d "$root/weekly.0" ]; then
        for next in `seq $weeklyi -1 1`; do
                curr=$(($next - 1))
                /bin/mv -f "$bkdir/weekly.$curr.tar.gz.gpg" "$bkdir/weekly.$next.tar.gz.gpg" 2> /dev/null
        done
        /bin/tar czPf - "$root/weekly.0/" | /usr/bin/gpg $gpg_opts -r $recipient -se --output "$bkdir/weekly.0.tar.gz.gpg" -
fi

exit 0


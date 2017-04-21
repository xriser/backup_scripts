#!/bin/bash

# 08/09/2016
# Mongo backup script by riser
# Prepare user bcp, sshfs, pigz
#

DOW=`date +%w`
day=`date +%d`
HOST=`hostname -f`

FTP_HOST=host
FTP_USER=user
FTP_PASS=pass


echo "[`date "+%d-%m-%y %H:%M"`] Starting mongo backup script" >>/var/log/mongobackup.log
#/usr/bin/find /bcp/mongo/ -type f \! -newermt '1 week ago' -exec rm {} \;


FREE=`df -h |grep "md0" | awk '{print $4}' | sed  's/G/ /g'`
echo "[`date "+%d-%m-%y %H:%M"`] Disk free: ${FREE}G " >> /var/log/mongobackup.log

if [ ${FREE} -gt 50 ]; then

echo "[`date "+%d-%m-%y %H:%M"`] Starting mongodump" >>/var/log/mongobackup.log
#mongodump --out /bcp/mongo/

mongodump --archive | pigz -6 -p 12 - > /bcp/mongo/mongo_m7_$DOW.gz

echo "[`date "+%d-%m-%y %H:%M"`] Starting targz mongo to dev" >>/var/log/mongobackup.log
#tar czf /bcp/dev/mongo_$DOW.tgz /bcp/mongo

#/usr/sbin/service mongod restart &

#tar cf - /bcp/mongo  | pigz -6 -p 12 >/bcp/dev/mongo_$DOW.gz

echo "[`date "+%d-%m-%y %H:%M"`] Starting lftp to dev" >>/var/log/mongobackup.log
lftp -e "mirror --reverse --only-newer /bcp/mongo/;bye;" $FTP_USER:$FTP_PASS@$FTP_HOST/sdd5/$HOST

fi

echo "[`date "+%d-%m-%y %H:%M"`] Finished " >>/var/log/mongobackup.log
echo "[`date "+%d-%m-%y %H:%M"`] ------------------------------------------------------  " >>/var/log/mongobackup.log
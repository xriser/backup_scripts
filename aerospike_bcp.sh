#!/bin/bash

# 05/09/2016
# AS backup script by riser
# Prepare user bcp, sshfs, pigz
# ssh-keygen
# ssh-copy-id root id_rsa.pub to user bcp on dev
# ssh-copy-id -i /root/.ssh/id_dsa.pub  bcp@dev.c8.net.ua

DOW=`date +%w`
HOST=`hostname -f`

FTP_HOST=host
FTP_USER=user
FTP_PASS=pass


echo "[`date "+%d-%m-%y %H:%M"`] Starting AS backup script" >>/var/log/asbackup.log


/usr/bin/find /db/bcp/as/ -type f \! -newermt '3 days ago' -exec rm {} \;

FREE=`df -h |grep "sda1" | awk '{print $4}' | sed  's/G/ /g'`
echo "[`date "+%d-%m-%y %H:%M"`] Disk free: ${FREE}G " >> /var/log/asbackup.log

if [ ${FREE} -gt 50 ]; then

echo "[`date "+%d-%m-%y %H:%M"`] Starting asbackup ssd namespace" >>/var/log/asbackup.log
asbackup --host 127.0.0.1 --namespace ssd --output-file - | pigz -6 -p 12 >/db/bcp/as/as_ssd_`date "+%w"`.gz

echo "[`date "+%d-%m-%y %H:%M"`] Starting copying ssd namespace to dev" >>/var/log/asbackup.log
#cp /db/bcp/as/as_ssd_`date "+%w"`.gz /bcp/dev/ &

echo "[`date "+%d-%m-%y %H:%M"`] Starting asbackup logs namespace" >>/var/log/asbackup.log
asbackup --host 127.0.0.1 --namespace logs --output-file - | pigz -6 -p 12 >/db/bcp/as/as_logs_`date "+%w"`.gz

echo "[`date "+%d-%m-%y %H:%M"`] Starting copying logs namespace to dev" >>/var/log/asbackup.log
#cp /db/bcp/as/as_logs_`date "+%w"`.gz /bcp/dev/

lftp -e "mirror --reverse --only-newer /db/bcp/as/;bye;" $FTP_USER:$FTP_PASS@$FTP_HOST/sdd5/$HOST
fi

echo "[`date "+%d-%m-%y %H:%M"`] Finished " >>/var/log/asbackup.log
echo "[`date "+%d-%m-%y %H:%M"`] ----------------------------------------------- " >>/var/log/asbackup.log

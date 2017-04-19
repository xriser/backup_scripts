#!/bin/bash

# backup by riser
#
# requirements
# prepare lftp (better mirroring)
#
# last update 07/09/16

day=`date +%d`
MBD=/bcp/configs
CODED=/bcp/code
HOST=`hostname -f`

FTP_HOST=ftphost.com
FTP_USER=ftpuser
FTP_PASS=password
DIRECTORY=/$HOST/configs
LOCAL_LOG=/var/log/bcp.log

SCRIPT_NAME="$0"
ARGS="$@"
NEW_FILE="bcp_configs.sh"
VERSION="2.1"

check_upgrade () {

echo "[`date "+%d-%m-%y %H:%M"`] Check updates..." >>$LOCAL_LOG

f1=`stat -c %y $0`
echo "[`date "+%d-%m-%y %H:%M"`] $f1" >>$LOCAL_LOG
    
cd /root/bin
wget -N ftp://$FTP_USER:$FTP_PASS@$FTP_HOST/sdd5/scripts/bcp_configs.sh

f2=`stat -c %y /root/bin/bcp_configs.sh`
echo "[`date "+%d-%m-%y %H:%M"`] $f2" >>$LOCAL_LOG

if [ "$f1" != "$f2" ]; then
   
   echo "[`date "+%d-%m-%y %H:%M"`] Update detected. Updating..." >>$LOCAL_LOG
   #cp /tmp/bcp_configs.sh /root/bin/bcp_configs.sh
   
   echo "[`date "+%d-%m-%y %H:%M"`] Running the new version... $SCRIPT_NAME $ARGS " >>$LOCAL_LOG
   $SCRIPT_NAME $ARGS
     
    echo "[`date "+%d-%m-%y %H:%M"`] Now exit this old instance" >>$LOCAL_LOG
    exit 0
  
fi

    #echo "[`date "+%d-%m-%y %H:%M"`] I'm VERSION $VERSION, already the latest version." >>$LOCAL_LOG

}


main () {


#update myself
cd /root/bin/
wget -N ftp://$FTP_USER:$FTP_PASS@$FTP_HOST/sdd5/scripts/bcp_configs.sh
chmod a+x bcp_configs.sh


if [ ! -d "$MBD" ]; then
  mkdir -p $MBD
fi

if [ ! -d "$CODED" ]; then
  mkdir -p $CODED
fi

cd $MBD

echo "[`date "+%d-%m-%y %H:%M"`] Backuping configs" >>$LOCAL_LOG
all_scripts=`find /usr/local/ -maxdepth 10 -regex ".*\.\(ini\|conf\|lua\|cnf\)"`
tar cfz scripts$day.tgz $all_scripts /root/bin/ /etc/init.d/ /usr/local/zabbix/exec /var/spool/cron
lftp -e "mirror --reverse --only-newer $MBD;bye;" $FTP_USER:$FTP_PASS@$FTP_HOST/sdd5/$HOST


cd $CODED

echo "[`date "+%d-%m-%y %H:%M"`] Backuping code" >>$LOCAL_LOG
all_code=`find /var/www/ -maxdepth 10 -regex ".*\.\(php\|conf\|lua\|gif\|png\|js\|json\|html\)">/tmp/codefiles`
tar cfz code$day.tgz -T /tmp/codefiles --exclude='/var/www/adserver'
lftp -e "mirror --reverse --only-newer $CODED;bye;" $FTP_USER:$FTP_PASS@$FTP_HOST/sdd5/$HOST

echo "[`date "+%d-%m-%y %H:%M"`] Finished" >>$LOCAL_LOG

}


echo "[`date "+%d-%m-%y %H:%M"`] ---------------------------------------------" >>$LOCAL_LOG
echo "[`date "+%d-%m-%y %H:%M"`] Starting backup scripts" >>$LOCAL_LOG
echo "[`date "+%d-%m-%y %H:%M"`] I'm VERSION $VERSION" >>$LOCAL_LOG

check_upgrade
main


#wput -nc -u -q  scripts$day.tgz  ftp://$FTP_USER:$FTP_PASS@$FTP_HOST/sdd5/$HOST/configs

#deploying
# echo y| apt-get install lftp
# cd /root/bin/
# wget -N ftp://$FTP_USER:$FTP_PASS@$FTP_HOST/sdd5/scripts/bcp_configs.sh
# chmod a+x bcp_configs.sh

#add 2 crontab
#1 4 1,5,10,15,20,25,30 * * /root/bin/bcp_configs.sh
#!/bin/bash
# better backup using lftp
# 

bcp_dir=/db/redis/
cd $MBD

HOST=`hostname -f`

FTP_HOST=host
FTP_USER=user
FTP_PASS=pass


lftp -e "mirror --reverse --only-newer --include-glob=*_0.rdb $bcp_dir;bye;" $FTP_USER:$FTP_PASS@$FTP_HOST/redis_db/$HOST

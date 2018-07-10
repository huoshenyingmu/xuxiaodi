#!/bin/bash
#对比目录下的所有文件的md5值，来判断文件是否没有变化，把没有变化的文件移到新的目录结构中去；
#参数设置：
#源视频存放目录：[可以自定义]，以下是获取脚步所在的路径，根据实际要求，更改路径，如：VOD_DIR=/video.app.m2o/mp4 等
VOD_DIR="pwd"
#存放视频目录，一般放在m2odata下，此目录一般较大
DATA_DIR=/m2odata/Mobile_video
#判断Mobile_video目录是否存在
 [ -d $DATA_DIR ] || mkdir -p $DATA_DIR && chmod 755 $DATA_DIR
find $VOD_DIR -type f -print0 |  xargs -0 md5sum > /tmp/system_45.md5
#休眠5分钟再次获取视频的md5值，时间可以自定义：【sleep 1s 睡眠1秒；sleep 1m 睡眠1分；sleep 1h 睡眠1小时】
sleep 5m
#5分钟后获取的md5值
find $VOD_DIR -type f -print0 |  xargs -0 md5sum > /tmp/system_46.md5
#新建5分钟后，没有变化视频的存放目录
mkdir -p $DATA_DIR/$(date "+%Y-%m-%d_%H:%M:%S")
#进行比较，并列出md5值不变的文件,
grep -f /tmp/system_46.md5 /tmp/system_45.md5 | awk '{print $2}' > /tmp/defalute.txt
#循环读取文件内容
for line in `cat /tmp/defalute.txt`
do
    mv $line $DATA_DIR/$(date "+%Y-%m-%d_%H:%M:%S")
done
#添加crontab计划任务
if [ `grep -c "video_md5" /var/spool/cron/root` -eq '0' ]; then
	#每5分钟执行一次，可以修改
	echo "*/5 * * * *  /bin/bash -x /m2odata/sh/video_md5.sh > /dev/null 2>&1" >> /var/spool/cron/root
	/etc/init.d/crond reload
else
	echo "已经修改的文件不需要重复修改!"
fi

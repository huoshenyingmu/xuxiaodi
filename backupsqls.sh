#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
 
Date=`date +%Y-%m-%d_%H:%M:%S`
BucketTime=`date +%Y%m`
OldDate=$(date -d "-7 days" "+%Y-%m-%d")
 
Host="oss-cn-hangzhou-internal.aliyuncs.com"
###oss的地址###
Bucket="bucketname"
###bucket名字###
Id="xxxxxxxx"
###Access ID###
Key="xxxxxxxxxx"
###Access Key###
OssHost=$Bucket.$Host
 
MYUSER="xxxxx"
MYPASS="xxxxxx"
###备份数据库账号信息###
DBS=`mysql -u$MYUSER -p$MYPASS -P3306 -Bse "show databases" | grep -v "information_schema" | grep -v "test"`
###罗列数据库信息###
#========================BackUp SQL========================
 
for DateName in $DBS; do
    mysqldump --single-transaction -u$MYUSER -p$MYPASS -P3306 $DateName > /tmp/$DateName.$Date.sql
    zip -P 密码 /tmp/$DateName.$Date.sql.zip /tmp/$DateName.$Date.sql
###zip压缩设置的密码###
    if [ -s /tmp/$DateName.$Date.sql.zip ] ; then
        
        source="/tmp/$DateName.$Date.sql.zip"
        dest="$BucketTime/$DateName.$Date.sql.zip"
        
        resource="/${Bucket}/${dest}"
        contentType=`file -ib ${source} |awk -F ";" '{print $1}'`
        dateValue="`TZ=GMT env LANG=en_US.UTF-8 date +'%a, %d %b %Y %H:%M:%S GMT'`"
        stringToSign="PUT\n\n${contentType}\n${dateValue}\n${resource}"
        signature=`echo -en $stringToSign | openssl sha1 -hmac ${Key} -binary | base64`
 
        url=http://${OssHost}/${dest}
        echo "upload ${source} to ${url}"
 
        curl -i -q -X PUT -T "${source}" \
            -H "Host: ${OssHost}" \
            -H "Date: ${dateValue}" \
            -H "Content-Type: ${contentType}" \
            -H "Authorization: OSS ${Id}:${signature}" \
            ${url}
 
        if [ $? -ne 0 ];then
            echo -e ""[$HOSTNAME] DateName $DateName $Date Fail Upload"" | mutt -s "'[$HOSTNAME] DateName $DateName $Date Fail Upload'" daobidao@daobidao.com  
        else
            echo -e ""[$HOSTNAME] DateName $DateName $Date Success"" | mutt -s "'[$HOSTNAME] DateName $DateName $Date Success'" daobidao@daobidao.com
            rm -rf /tmp/$DateName.$OldDate*
        fi
    
    else
        echo -e ""[$HOSTNAME] DateName $DateName $Date Fail Backup "" | mutt -s "'[$HOSTNAME] DateName $DateName $Date Fail Backup'" daobidao@daobidao.com
    fi
done
 
#========================BackUp SQL=======================

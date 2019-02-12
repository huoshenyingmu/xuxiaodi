#!/bin/bash
#auth:rookie
#date:2019.01.21
#作用：安装sftp，前提是不计较传输速度，但是文件传输是安全的
#判断是否有openssh-client openssh-server openssh-sftp-server三个文件，没有则安装
if [ `rpm -qa|grep openssh|wc -l` != 3 ];then
    yum -y install openssh-client openssh-server openssh-sftp-server
fi

stty erase ^H
read -p "请输入sftp的组的名称（默认：sftp-user）：" sftpgroup
sftpgroup=${sftpgroup:-sftp-user}
if [ `grep ${sftpgroup} /etc/group|wc -l` = 0 ];then
    groupadd $sftpgroup
fi

read -p "请输入${sftpgroup}的组中的用户（默认：sftp）：" sftpuser
sftpuser=${sftpuser:-sftp}
if [ `grep ${sftpuser} /etc/passwd|wc -l` = 0 ];then
    useradd -g ${sftpgroup} -m ${sftpuser}
    #useradd -s /sbin/nologin -d /sftp/test01 -m test01
    echo "不输入密码，使用自动生成的密码时，自动生成的密码是没有特殊字符的如：%！？等"
    read -s -p "请输入${sftuser}的密码：" userpasswd
    userpasswd=${userpasswd:-`date +%s%N | md5sum | head -c 20`}
    echo "${userpasswd}"|passwd ${sftuser} --stdin &> /dev/null
elif [ `groups ${sftpuser}|awk -F ":" '{print $2}'` != ${sftpgroup} ];then
    usermod -g ${sftpgroup} ${sftpuser}
fi

#修改sshd_config配置文件
if [ `grep -E '^\s*Subsystem' /etc/ssh/sshd_config |grep 'internal-sftp'|wc -l` != 1 ];then
    sed -i 's/^\s*Subsystem/#&/g' /etc/ssh/sshd_config
    read -p "请输入sftp路径（/data/ftp/）" sftpdir
    sftpdir=${sftpdir:-/data/ftp/}
    if [ ! -d ${sftpdir} ];then
        mkdir -p ${sftpdir}
    fi
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config`date -I`_bak
    echo -e "Subsystem       sftp    internal-sftp
Match Group ${sftpgroup}
#Match LocalPort 2222
ChrootDirectory ${sftpdir}%u
ForceCommand    internal-sftp
AllowTcpForwarding no
X11Forwarding no" >> /etc/ssh/sshd_config
fi

if [ `rpm -q centos-release|cut -d- -f3` = 6 ];then
    /etc/init.d/sshd restart
else
    systemctl restart sshd.service
fi

echo 用户：${sftpuser}，密码：${userpasswd},请妥善保管！
echo 用户：${sftpuser}，密码：${userpasswd},请妥善保管！>> /root/sftpuser.txt
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ >> /root/sftpuser.txt
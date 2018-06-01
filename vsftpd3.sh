#!/bin/bash
##ftp虚拟用户配置
##version:2.0
##作者:Rookie
##emial:1250957717@qq.com
##完成后需手动修改防火墙策略的顺序，第一次运行修改，以后不做修改
##虚拟用户根目录，依据实际情况修改
#适用centos6.x，centos7不适用
echo "ftp虚拟用户配置2.0版"
echo "ftp目录：如：
		/usr/local/hoge"
read -p "请输入目录路径：" local_root
#################################
##程序安装
if [ `rpm -qa|grep vsftpd|wc -l` = 1 ];then
	echo "vsftpd已经安装！"
else
	echo "vsftpd未安装！"
	yum -y install vsftpd
fi
##加入开机启动
if [ `chkconfig --list|grep vsftpd|wc -l` = 1 ];then
	echo "已经加入到启动项！"
else
	echo "未加入启动项！"
	chkconfig vsftpd on
fi
##重新编写vsftpd.conf
cd /etc/vsftpd
#判断vsftpd.conf是否是修改后的正式文件，防止重复删除，导致程序无法运行！
if [ `grep -c "listen_port=2101" vsftpd.conf` -eq '0' ]; then
    echo "vsftpd.conf是未修改的文件"
    cat << EOF > vsftpd.conf
anonymous_enable=NO
listen=YES
listen_port=2101
local_enable=YES
ascii_upload_enable=YES
ascii_download_enable=YES
pam_service_name=vsftpd
guest_enable=YES
guest_username=root
user_config_dir=/etc/vsftpd/vuser_conf
pasv_enable=YES
pasv_min_port=6000
pasv_max_port=6100
pasv_promiscuous=YES
xferlog_enable=YES
xferlog_std_format=YES
xferlog_file=/var/log/xferlog
dual_log_enable=YES
vsftpd_log_file=/var/log/vsftpd.log
EOF
else
    echo "vsftpd.conf是修改后的文件"
fi
##安装db
yum install db4 db4-utils -y
##用户的输入
read -p "请输入用户名:" name
read -p "请输入密码:" passwd
cat << EOF >> vuser_passwd.txt
$name
$passwd
EOF
db_load -T -t hash -f /etc/vsftpd/vuser_passwd.txt /etc/vsftpd/vuser_passwd.db
#修改pam下的vsftpd
if [ `grep -c "/etc/vsftpd/vuser_passwd" /etc/pam.d/vsftpd` -eq '0' ]; then
	echo "是未修改文件！"
	mv /etc/pam.d/vsftpd /etc/pam.d/vsftpd.bak
	cat << EOF > /etc/pam.d/vsftpd
auth required pam_userdb.so db=/etc/vsftpd/vuser_passwd
account required pam_userdb.so db=/etc/vsftpd/vuser_passwd
EOF
else
	echo "已经修改的文件不需要重复修改！"
fi
##判断vuser_conf是否存在
if [ ! -d "/etc/vsftpd/vuser_conf" ]; then
  mkdir -p /etc/vsftpd/vuser_conf
fi
##编写新用户的配置信息
cat << EOF > vuser_conf/$name
local_root=$local_root
write_enable=YES
anon_umask=022
anon_world_readable_only=NO
anon_upload_enable=YES
anon_mkdir_write_enable=YES
anon_other_write_enable=YES
EOF
##判断是否有local_root目录
if [ ! -d "$local_root" ]; then
  mkdir -p $local_root
fi
##判断iptables中是否存在此内容
if [ `grep -c "2101" /etc/sysconfig/iptables` -eq '0' ]; then
        iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 2101 -j ACCEPT
fi

if [ `grep -c "6000" /etc/sysconfig/iptables` -eq '0' ]; then
        iptables -A INPUT -p tcp -m tcp --dport 6000:6100 -j ACCEPT
fi
/etc/init.d/iptables save
service iptables restart
service vsftpd restart

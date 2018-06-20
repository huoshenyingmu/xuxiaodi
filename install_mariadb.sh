#!/bin/bash
#Auth:Rookie
#About:MariaDB10.0.21
#Version:1.0.0
#a.主机名和IP地址解析添加
function  check_env(){
echo "创建MySQL用户和组"
groupadd mysql
useradd -g mysql -s /sbin/nologin -M mysql
echo "加入主机名和IP到/etc/hosts"
IP1=`ifconfig $1|sed -n 2p|awk  '{ print $2 }'|awk -F : '{ print $2 }'`
hostname1=`hostname`
echo "$IP1 $hostname1"  >> /etc/hosts
echo "创建目录和授权"
        mkdir -p /data/mydata >>/dev/null 2>&1;
chown -R mysql:mysql /data/mydata;
echo "yum命令解决环境"
        yum -y install openssl openssl-devel cmake make bison gcc gcc-c++ ncurses ncurses-devel zlib zlib-devel libxml2 libxml2-devel bison bison-devel
echo "移除之前的MySQL命令"
yum -y remove mysql*
find / -name my.cnf -exec rm -rf {} \;
yum -y install sysstat
}
function  mariadb_upload (){
cd /tmp
/usr/bin/rz -bye "如果手动上传请屏蔽此条命令"
echo "请上传mariadb10.0.21"
sleep 3
tar -zxvf mariadb-10.0.21.tar.gz >> /dev/null 2>&1;
echo "mariadb上传解压完成"
}
function  mariadb_install(){
        echo "====Install mariadb-10.0.21===="
echo "指定数据存放目录"
Data_path=/data/mydata
cd /tmp/mariadb-10.0.21
        cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_DATADIR=$Data_path -DMYSQL_UNIX_ADDR=$Data_path/mariadb.sock -DMYSQL_TCP_PORT=3306 -DWITH_LIBWRAP=0 -DEXTRA_CHARSETS=all -DWITH_XTRADB_STORAGE_ENGINE=1 -DWITH_FEDERATEDX_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DWITH_SSL=system -DWITH_ZLIB=system -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci
make clean
make -j `cat /proc/cpuinfo | grep processor| wc -l`
make install
        \cp -rfp support-files/my-medium.cnf /etc/my.cnf
        /usr/local/mysql/scripts/mysql_install_db --user=mysql  --basedir=/usr/local/mysql --datadir=$Data_path
        chown -R mysql:mysql /usr/local/mysql/
        cp support-files/mysql.server /etc/init.d/mysqld
        chmod 755 /etc/init.d/mysqld
chkconfig --add mysqld
chkconfig --level 35 mysqld on
        echo "export PATH=/usr/local/mysql/bin:\$PATH" >> /root/.bash_profile
source /root/.bash_profile
        echo "====手动开启mariadb-10.0.21==="
}
check_env
mariadb_upload
mariadb_install

#可以使用 mysql_secure_installation 快速配置MySQL_secure
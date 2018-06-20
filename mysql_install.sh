#bin/bash
#数据库单个安装或者多实例的安装
declare flag=0
clear
while [ "$flag" -eq 0 ]
do
cat << EOF
----------------------------------------
|**********根据需要输入相应参数***********|
----------------------------------------
(1) 单个数据库安装
(2) 多实例数据库安装
(0) Quit
EOF
read -p "请输入参数[0-2]" input
case $input in
	1 )
		clear
		user=mysql
		basedir=/m2odata/server/mysql
		datadir=/m2odata/data/mysql
		iptables_conf=/etc/sysconfig/iptables
		#下载二进制文件
		cd /usr/local/src
		if [ -f mysql-5.6.37-linux-glibc2.12-x86_64.tar.gz ]; then
			echo "已经下载！"
		else
			wget "http://218.2.102.114:57624/src/mysql-5.6.37-linux-glibc2.12-x86_64.tar.gz"
			echo "完成!\n"
		fi
		#添加用户名
		if [ `grep -q mysql /etc/passwd` ]; then
		        echo "用户已存在！";
		else
		        useradd -M -s /sbin/nologin mysql
		fi
		#安装必要的包
		yum -y install compat-libstdc++-33.x86_64 libaio* libnuma* perl perl-devel
		#安装mysql-5.6.37
		if [ -d /m2odata/server/ ]; then
			echo "目录已经存在！"
		else
			mkdir -p /m2odata/server
		fi
		tar xzvf mysql-5.6.37-linux-glibc2.12-x86_64.tar.gz -C /m2odata/server
		chown -Rf $user:$user mysql-5.6.37-linux-glibc2.12-x86_64
		ln -sf /m2odata/server/mysql-5.6.37-linux-glibc2.12-x86_64 /m2odata/server/mysql
		#授权 && db路径
		chown -R $user:$user /m2odata/serer/mysql/
		if [ -d $datadir ]; then
			echo "目录已经存在！"
		else
			mkdir -p $datadir
		fi
		chown -R $user:$user $datadir
		#下载mysql配置文件
		mv /etc/my.cnf /etc/my.cnf.bak
		wget "http://218.2.102.114:57624/configfiles/my.cnf" -O /etc/my.cnf
		echo "mysql配置文件下载成功！"
		#初始化db,启动
		cd /m2odata/server/mysql
		./scripts/mysql_install_db --defaults-file=/etc/my.cnf --user=$user --basedir=$basedir --datadir=$datadir
		cp -f support-files/mysql.server /etc/rc.d/init.d/mysqld
		chown root:root /etc/rc.d/init.d/mysqld
		chmod 755 /etc/rc.d/init.d/mysqld
		chkconfig --add mysqld
		chkconfig mysqld on
		service mysqld start
		echo -e '完成!\n'
		#开放3306端口
		grep -w -q 3306 $iptables_conf
 		if [ $? != 0 ];then
        	sed -i '/-i lo/a -A INPUT -m state --state NEW -m tcp -p tcp --dport 3306 -j ACCEPT' $iptables_conf
        	/etc/init.d/iptables reload
    	fi
		#设置密码
		/m2odata/server/mysql/bin/mysql_secure_installation
		;;

	2)
		clear
cat << EOF
----------------------------------------
|**********根据需要输入相应参数***********|
----------------------------------------
(1) 已有mysql，安装其他实例
(2) 没有mysql，安装多实例
(0) Quit
EOF
		read -p "请输入对应的参数" input2
		clear
		case $input2 in
			1)
		
		#添加用户名
		if [ `grep -q mysql /etc/passwd` ]; then
		        echo "用户已存在！";
		else
		        useradd -M -s /sbin/nologin mysql
		fi
		#下载mysql
		cd /usr/local/src
		if [ -f mysql-5.6.37-linux-glibc2.12-x86_64.tar.gz ]; then
			echo "已经下载！"
		else
			wget "http://218.2.102.114:57624/src/mysql-5.6.37-linux-glibc2.12-x86_64.tar.gz"
			echo "完成!\n"
		fi
		#常见存放路径
		mkdir -p /m2odata/mysql/mysql{3307,3308}
		mkdir -p /m2odata/mysql/mysql3307/{data,log,tmp}
		mkdir -p /m2odata/mysql/mysql3308/{data,log,tmp}
		chown -Rf nobody:nobody /m2odata/mysql
		#添加环境变量
		echo 'export PATH=$PATH:/m2odata/server/mysql/bin' >>  /etc/profile
		source /etc/profile   
		;;
			2)
				echo "尽情期待"
		;;
			0)
			;;
			*)
				echo "请重新输入正确的值：【1/2/0】"
				clear
			;;
		esac
	;;
	0)
		clear
		exit 0
	;;

	*)
		echo "请重新输入正确的值：【1/2/0】"
		clear
		#sh `dirname $0`/`basename $0`   #造成子进程变多
	;;
esac
done
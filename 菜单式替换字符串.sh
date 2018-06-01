#!/bin/bash
#菜单式替换字符串
declare flag=0
clear
while [ "$flag" -eq 0 ]
do
cat << EOF
----------------------------------------
|**********根据需要输入相应参数***********|
----------------------------------------
(1) 固定目录下文件的字符串替换
(2) 自定义模式
(0) Quit
EOF
read -p "请输入参数[0-2]: " input
case $input in
	1)
		clear
		cat << EOF
		固定模式下主要替换如下的内容：
		1、/etc/hosts;
		2、/m2odata/server/nginx/conf/conf.d/ 下conf文件；
		3、/usr/local/m2o_vod_nginx/conf/ 下conf文件；
		4、/m2odata/www/下有要替换的文件
EOF
	read -p "请输入原字符串:" Ostring
	read -p "请输入替换字符串:" Cstring
	sed -i "s/$Ostring/$Cstring/g" `grep $Ostring -rl /etc/hosts`
	#判断/m2odata/server下是否正常安装nginx
	if [ ! -d /m2odata/server/nginx/conf ];then
		echo "/m2odata/server/nginx没有安装"
	else
		sed -i "s/$Ostring/$Cstring/g" `grep $Ostring -rl /m2odata/server/nginx/conf/conf.d/*`
	fi
	#判断是否安装了m2o_vod_nginx
	if [ ! -d /usr/local/m2o_vod_nginx ];then
		echo "/usr/local/m2o_vod_nginx没有安装"
	else
		sed -i "s/$Ostring/$Cstring/g" `grep $Ostring -rl /usr/local/m2o_vod_nginx/conf/*`
	fi
	#判断是否有m2odata/www目录
	if [ ! -d /m2odata/www ];then
		echo "没有www目录"
	else
		sed -i "s/$Ostring/$Cstring/g" `grep $Ostring -rl /m2odata/www/*`
	fi
	clear
	;;

	2)
		clear
		cat << EOF
		自定义模式：
		替换任意目录下的文件中想更换的字符串：
		路径或者文件：如：
		路径：/m2odata/server/nginx/conf/conf.d/
		文件：/etc/hosts 绝对路径下
EOF
	read -p "请输入原字符串:" Ostring
	read -p "请输入替换字符串:" Cstring
	read -p "请输入路径或者文件:" Pathfile
	sed -i "s/$Ostring/$Cstring/g" `grep $Ostring -rl $Pathfile`
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

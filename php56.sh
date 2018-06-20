#!/bin/bash
# update time: 2015-06-09 23:00
# 使用方法: 根据机器实际性能,修改MAX_CHILDREN参数为合适值,然后执行 ./php.sh

# set max_children
MAX_CHILDREN=100		# max_children in php-fpm.conf
yum -y install epel-release
yum install make apr* autoconf automake gcc gcc-c++ zlib-devel openssl openssl-devel pcre-devel gd  kernel keyutils patch perl kernel-headers compat* mpfr cpp glibc libgomp libstdc++-devel ppl cloog-ppl keyutils-libs-devel libcom_err-devel libsepol-devel libselinux-devel krb5-devel zlib-devel libXpm* freetype libjpeg* libpng* php-common php-gd ncurses* libtool* libxml2 libxml2-devel patch recode -y
# download php source code
echo 'download php source code'
cd /usr/local/src 

if [ -f php5.6.tar.gz ]; then
	echo 'already download'
else
	wget "http://47.52.24.217/src/php5.6.tar.gz"
fi

tar zxf php5.6.tar.gz
echo -e 'done\n'

# install php5.6.35
echo 'install php56'
cp -rf php56 /m2odata/server/

\cp -f php56/php-fpm56 /etc/init.d/

chown root:root /etc/rc.d/init.d/php-fpm56
chmod 755 /etc/rc.d/init.d/php-fpm56
chkconfig --add php-fpm56
chkconfig php-fpm56 on

mkdir -p /usr/local/mysqllib_php/lib/
\cp -f php56/libmysqlclient.so.18.0.0 /usr/local/mysqllib_php/lib/
ln -sf /usr/local/mysqllib_php/lib/libmysqlclient.so.18.0.0 /usr/lib64/libmysqlclient.so.18
chmod 755 /usr/local/mysqllib_php/lib/libmysqlclient.so.18.0.0

mkdir -p /usr/local/lib/
\cp -f php56/libmcrypt.so.4.4.8 /usr/local/lib/
ln -sf /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib64/libmcrypt.so.4
chmod 755 /usr/local/lib/libmcrypt.so.4.4.8

\cp -f php56/libiconv.so.2.5.1 /usr/local/lib/
ln -sf /usr/local/lib/libiconv.so.2.5.1 /usr/lib64/libiconv.so.2
chmod 755 /usr/local/lib/libiconv.so.2.5.1

wget -O /usr/lib64/libexslt.so.0.8.15 "http://47.52.24.217:/src/libexslt.so.0.8.15"
ln -s /usr/lib64/libexslt.so.0.8.15 /usr/lib64/libexslt.so.0

# configure php
echo 'configure php'
sed -i "/^display_errors/s/On/Off/"	/m2odata/server/php56/etc/php56.ini
if [ $MAX_CHILDREN != '' ];then
	sed -i "/max_children/s/256/$MAX_CHILDREN/"	/m2odata/server/php56/etc/php-fpm56.conf
fi
sed -i '/max_input_vars/s/1000/3000/' /m2odata/server/php56/etc/php56.ini
echo -e 'done\n'

# configure xcache
echo 'configure xcache'
cd /usr/local/src/

if [ ! -f xcache-3.1.2.tar.gz ]; then
	wget "http://47.52.24.217/src/xcache-3.1.2.tar.gz"
fi

tar zxvf xcache-3.1.2.tar.gz

if [ ! -d /m2odata/www/xcache ]; then
	mv xcache-3.1.2/htdocs /m2odata/www/xcache
fi

if [ -h /m2odata/server/nginx ]; then
echo -ne 'server {
        set $htdocs /m2odata/www/xcache;
        listen       80;
        server_name  xcache.app.m2o;
        location / {
        	root   $htdocs;
        	index  index.html index.htm index.php;
        }
        location ~ .*\.php?$ {
        	root          $htdocs;
        	fastcgi_pass unix:/dev/shm/php-cgi56.sock;
        	fastcgi_index  index.php;
        	include        fastcgi_params;
        }
}' > /m2odata/server/nginx/conf/conf.d/xcache.conf
fi
echo -e 'done\n'

# start php
echo 'start php-fpm'
if [ ! -S /dev/shm/php-cgi56.sock ]; then
	service php-fpm start
fi
echo -e 'done\n'
rm -rf /usr/local/src/php56

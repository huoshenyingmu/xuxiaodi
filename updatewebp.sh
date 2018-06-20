#!/bin/bash
#安装imagemagick、imagick和magickwand实现图片本地化

#安装epel-release
yum -y install epel-release

#下载ImageMagick
if [ ！ -f /usr/local/src/ImageMagick.tar.gz ];then
	cd /usr/local/src
	wget http://218.2.102.114:57624/src/ImageMagick.tar.gz
fi

#安装一些插件
yum -y groupinstall 'Development Tools'
yum -y install bzip2-devel freetype-devel libwebp-devel libjpig-devel libjpeg-devel libpng-devel libtiff-devel giflib-devel zlib-devel ghostscript-devel djvulibre-devel \ libwmf-devel jasper-devel libtool-ltdl-devel libX11-devel libXext-devel libXt-devel lcms-devel libxml2-devel librsvg2-devel OpenEXR-devel php-devel

#安装ImageMagick
if [ ! -d /usr/local/src/ImageMagick-7.0.7-33 ];then
	tar -zxvf /usr/local/src/ImageMagick.tar.gz
fi

if [ ! -f /usr/local/bin/convert ];then
	cd /usr/local/src/ImageMagick-7.0.7-33
	./configuer
	make && make install
else
	echo "ImageMagick 已安装过了！"
fi

#查看ImageMagick的webp参数有没有加载成功
a=`convert -list format|grep webp|wc -l`
if [ $a=1 ];then
	echo "ImageMagick支持webp"
	[ -f /usr/local/src/MagickWandForPHP-1.0.9-2.tar.gz ] || wget "http://218.2.102.114:57624/src/MagickWandForPHP-1.0.9-2.tar.gz" -O /usr/local/src/MagickWandForPHP-1.0.9-2.tar.gz
else
	echo "ImageMagick不支持webp"
	echo "请检查ImageMagick是否有正确的安装！！"
fi

#安装imagick使其生成imagick.so文件
if [ -d /usr/local/src/MagickWandForPHP-1.0.9 ];then
	echo "MagickWandForPHP-1.0.9已经存在"
	cd /usr/local/src/MagickWandForPHP-1.0.9
		if [ ! -f /m2odata/server/php/bin/phpize ];then
			echo "在php/bin中没有找到phpize，不用着急。。。。。。"
			yum install php-devel php-pear -y
			phpize
		else
			echo "phpize存在。程序会继续运行。。。。。。"
			/m2odata/server/php/bin/phpize 
		fi
else
	tar -zxvf /usr/local/src/MagickWandForPHP-1.0.9-2.tar.gz
	cd /usr/local/src/MagickWandForPHP-1.0.9
		if [ ! -f /m2odata/server/php/bin/phpize ];then
			echo "在php/bin中没有找到phpize，不用着急。。。。。。"
			yum install php-devel php-pear -y
			phpize
		else
			echo "phpize存在。程序会继续运行。。。。。。"
			/m2odata/server/php/bin/phpize 
		fi
fi

./configure --with-php-config=/m2odata/server/php/bin/php-config
make && make install

if [ $?=0 ];then
	echo "MagickWand安装成功"
else
	echo "没有安装成功请检查"
	exit
fi

#定义变量
magic=`cat /m2odata/server/php/etc/php.ini|grep magickwand|wc -l`

#在php.ini配置文件中加上动态库文件配置
if [ $magic=0 ]
then
        sed -i '/extension = "imagick.so"/aextension = "magickwand.so"' /m2odata/server/php/etc/php.ini
        sed -i '/extension = "imagick.so"/s/^;//' /m2odata/server/php/etc/php.ini
else
        echo "配置文件中已有magickwand库文件!" && exit
fi

#配置生成的进度条
arr=("|" "/" "-" "\\")  
i=0  
var=0  
ret=""  
tmp=""  
while [ $i -le 100 ]  
do  
    printf "\r[%-100s[%s%%]][%s]" ${tmp} ${var} ${arr[(($i%4))]}  
    ret=${ret}=  
    tmp=${ret}  
    let i++  
    let var++  
    sleep 1 
done  
printf "\n"
	
#!/bin/bash
#auth:Rookie
#date:2019/1/14
#作用：安装strongswan，并配置ipsec与vgw配置，主要配置ipsec.conf的文件
#strongswan.conf            strongSwan各组件的通用配置
#ipsec.conf                     IPsec相关的配置，定义IKE版本、验证方式、加密方式、连接属性等等
#ipsec.secrets                 定义各类密钥，例如：私钥、预共享密钥、用户账户和密码

#安装stongswan软件
if [ `rpm -q centos-release|cut -d- -f3` = 6 ];then
    if [ `rpm -qa|grep trousers|wc -l` = 0 ];then
        mv ./packages/trousers-0.3.13-2.el6.x86_64.rpm /usr/local/src/
        rpm -ivh /usr/local/src/trousers-0.3.13-2.el6.x86_64.rpm
    fi
    if [ `rpm -qa|grep strongswan|wc -l` = 0 ];then
        yum -y install strongswan
        chkconfig strongswan on
    fi
else
    if [ `rpm -qa|grep trousers|wc -l` = 0 ];then
        mv ./packages/trousers-0.3.14-2.el7.x86_64.rpm /usr/local/src/
        rpm -ivh /usr/local/src/trousers-0.3.14-2.el7.x86_64.rpm
    fi
    if [ `rpm -qa|grep strongswan|wc -l` = 0 ];then
        yum -y install strongswan
        systemctl enable strongswan
    fi
fi

#配置ipsec.conf配置文件
cp /etc/strongswan/ipsec.conf /etc/strongswan/ipsec.conf_`date +%s`_bak
#可以删除错误输入
stty erase ^H
read -p "请输入本地子网（172.12.16.0/14，0.0.0.0/0）：" leftsubnet
read -p "请输入主机公网：" left
read -p "请输入对端公网：" right
read -p "请输入对端子网（172.12.12.0/14，0.0.0.0/0）：" rightsubnet
#配置ipsec.conf文件
echo "config setup
     uniqueids=never
conn %default
     authby=psk
     type=tunnel
conn tomyidc
     keyexchange=ikev1
     left=${left}
     leftsubnet=${leftsubnet}
     leftid=${left}
     right=${right}
     rightsubnet=${rightsubnet}
     rightid=${right}
     auto=route
     ike=aes-sha1-modp1024
     ikelifetime=86400s
     esp=aes-sha1-modp1024
     lifetime=86400s
     type=tunnel" > /etc/strongswan/ipsec.conf

#配置ipsec.secrets
read -p "请输入共享密钥：" PSK
echo "${left} ${right} : PSK \"${PSK}"\" > /etc/strongswan/ipsec.secrets

#启动
if [ `rpm -q centos-release|cut -d- -f3` = 6 ];then
    /etc/init.d/strongswan restart
else
    systemctl restart strongswan
fi
#!/bin/bash
#auth:rookie
#date:2019.01.16
#作用：批量执行获取内容保存到本地
#使用方法：
if [ ! -d /root/PCI ];then
mkdir /root/PCI
fi
for ip in `cat /root/ip_more.txt`
do
#cat PCIAduitforlinux.txt | ssh -o ConnectTimeout=3 -o ConnectionAttempts=2 -o StrictHostKeyChecking=no  -o PasswordAuthentication=no -i /home/jumpapi/.ssh/id_rsa ltops@${ip} "cat - > /root/PCIAduitforlinux.sh,chmod +x /root/PCIAduitforlinux.sh,sh /root/PCIAduitforlinux.sh"
ssh root@${ip} -p 22 < /root/PCIAduitforlinux_2.txt &> test_${ip}.txt
done

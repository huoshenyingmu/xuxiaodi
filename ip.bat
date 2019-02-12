@Echo off
date /t > c:\Users\xxd\Desktop\IPList.txt
time /t >> c:\Users\xxd\Desktop\IPList.txt
echo =========== >> c:\Users\xxd\Desktop\IPList.txt
For /L %%f in (1,1,100) Do Ping.exe -n 2 10.100.23.%%f Find "Request timed out." & echo 10.100.23.%%f Timed Out >> c:\Users\xxd\Desktop\IPList.txt & echo off
cls
Echo Finished!
@Echo on

@echo off
echo 执行中，请稍后...
echo ping日期：%date% >> c:\Users\xxd\Desktop\pingall.txt
echo ping时间：%time% >> c:\Users\xxd\Desktop\pingall.txt
echo.>> c:\Users\xxd\Desktop\pingall.txt
echo 具体数据：>> c:\Users\xxd\Desktop\pingall.txt
for /l %%i in (1,1,255) do ping -n 1 -w 60 10.100.23%%i | find "回复" >> c:\Users\xxd\Desktop\pingall.txt
echo ----------------------------------------------------------- >> c:\Users\xxd\Desktop\pingall.txt
echo 执行结束，请双击打开pingall.txt查看。
# ubuntu 操作笔记

## 安装相关
* 安装视频
    * https://www.bilibili.com/video/BV1KA41177ui?spm_id_from=333.337.search-card.all.click

* apt 换源
    * ubuntu16.04换源  https://blog.csdn.net/qq_52385631/article/details/123646086
    * 
* 远程登录 linux 系统
    * 10.0.2.15
    * 远程连接工具  royal TSX
    * ubuntu 安装 ssh  
        * sudo apt install openssh-server
        * sudo ufw allow 22  #开启22号窗口



## 操作命令
```shell script
# 重启
sudo reboot

# 查看ip 
ifconfig
ip addr

# 修改root 密码，直接将root 密码设为1
sudo passwd root 
# 切换到root
su root
# 退出 root
exit

# 关机
shutdown -h now



# 安装 curl 软件
sudo apt-get install curl


```




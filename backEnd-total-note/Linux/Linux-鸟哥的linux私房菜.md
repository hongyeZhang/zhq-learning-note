

# 《常用命令速记》




## cahpter0-man-查看手册
* linux manual page  通常情况下，手册页是用 less 打开的，所以 less 命令的键盘快捷键在 man 中也可以使用
* 要准确的定位一份man文档，应该指出名字 + section
* man 文档基本遵循一套写作模板，对读者重要的章节有：
    * NAME：名字和一句话简单描述。
    * SYNOPSIS：语法格式，比如 shell 命令会罗列所有的 option 和 argument 用法。
    * DESCRIPTION：详细用法解释，内容比较多。可以根据自己感兴趣的点搜索。
    * EXAMPLES：用法举例，有时直接翻到最后看例子，会更容易理解。
* 语法格式
    * [-abc] ：表示中括号内任一一个 option 都是可选的。
    * -a|-b：竖线分隔的 option 不可同时出现
    * … ：表示可重复的
    * <>：表示必选
* 查找 man 文档的存储位置
    * man 文档是存储一个特定位置，通过命令 man -w [command] 可以定位文档



> man -k -k 选项，可以通过正则表达式模糊匹配某个命令，man -k printf 会搜索所有 man 文档中名字或描述包含 printf 关键字的
man -k "^print" 正则搜索，搜索名字或描述以 print 开头的
man printf 
man 3 printf printf是C语言的库函数
man -f printf 要列出所有 section，可以增加 -f 选项 



## chapter10 认识与学习bash


```shell
# 从键盘输入内容赋予指定的变量名
read -p "plaese keyin your name" -t 30 named

cat /etc/passwd | awk '{FS=":"} $3 '


# 所有人添加可执行权限：
chmod a+x 文件名；
# 文件所有者添加可执行权限：
chmod u+x 文件名；
# 所在组添加可执行权限：
chmod g+x 文件名；
# 所在组以外的人添加可执行权限：
chmod o+x 文件名；


```







### ssh
```shell
# 退出连接
ctrl + D / logout / exit 
```










## 查看基本信息

* 查看CPU使用率         
    * top 查看CPU访问率

### 查看端口的占用情况
lsof -i:端口号 用于查看某一端口的占用情况，比如查看8000端口使用情况，lsof -i:8000

netstat -tunlp |grep 端口号，用于查看指定的端口号的进程情况，如查看8000端口的情况，netstat -tunlp |grep 8000


### 关机
shutdown -r now 是立即重启
shutdown -h now 是立即关机




一、Linux服务器查找服务对应的端口

ps -ef|grep java 查找所有的Java进程

ps -ef | grep cms-client-web | grep -v grep    查看cms-client-web的端口号


nohup
nohup 命令运行由 Command参数和任何相关的 Arg参数指定的命令，忽略所有挂断（SIGHUP）信号。在注销后使用 nohup 命令运行后台中的程序。要运行后台中的 nohup 命令，添加 & （ 表示“and”的符号）到命令的尾部。
nohup 是 no hang up 的缩写，就是不挂断的意思。

nohup命令：如果你正在运行一个进程，而且你觉得在退出帐户时该进程还不会结束，那么可以使用nohup命令。该命令可以在你退出帐户/关闭终端之后继续运行相应的进程。
firewallfirewallfirewallfirewallfirewall
在缺省情况下该作业的所有输出都被重定向到一个名为nohup.out的文件中。
回到顶部
案例

1. nohup command > myout.file 2>&1 &
在上面的例子中，0 – stdin (standard input)，1 – stdout (standard output)，2 – stderr (standard error) ；
2>&1是将标准错误（2）重定向到标准输出（&1），标准输出（&1）再被重定向输入到myout.file文件中。

2. 0 22 * * * /usr/bin/python /home/pu/download_pdf/download_dfcf_pdf_to_oss.py > /home/pu/download_pdf/download_dfcf_pdf_to_oss.log 2>&1

这是放在crontab中的定时任务，晚上22点时候怕这个任务，启动这个python的脚本，并把日志写在download_dfcf_pdf_to_oss.log文件中
回到顶部
nohup和&的区别

& ： 指在后台运行

nohup ： 不挂断的运行，注意并没有后台运行的功能，，就是指，用nohup运行命令可以使命令永久的执行下去，和用户终端没有关系，例如我们断开SSH连接都不会影响他的运行，注意了nohup没有后台运行的意思；&才是后台运行

&是指在后台运行，但当用户推出(挂起)的时候，命令自动也跟着退出
那么，我们可以巧妙的吧他们结合起来用就是
nohup COMMAND &
这样就能使命令永久的在后台执行

==============  端口号占用  =============================

lsof -i:端口号 用于查看某一端口的占用情况，比如查看8000端口使用情况，lsof -i:8000

netstat -tunlp |grep 端口号，用于查看指定的端口号的进程情况，如查看8000端口的情况，netstat -tunlp |grep 8000
netstat -tunlp |grep 8000

lsof -i

lsof(list open files)是一个列出当前系统打开文件的工具。在linux环境下，任何事物都以文件的形式存在，通过文件不仅仅可以访问常规数据，还可以访问网络连接和硬件。
所以如传输控制协议 (TCP) 和用户数据报协议 (UDP) 套接字等，系统在后台都为该应用程序分配了一个文件描述符，无论这个文件的本质如何，
该文件描述符为应用程序与基础操作系统之间的交互提供了通用接口。因为应用程序打开文件的描述符列表提供了大量关于这个应用程序本身的信息，
因此通过lsof工具能够查看这个列表对系统监测以及排错将是很有帮助的。

2、netstat命令是一个监控TCP/IP网络的非常有用的工具，它可以显示路由表、实际的网络连接以及每一个网络接口设备的状态信息
     netstat -tunlp 显示tcp，udp的端口和进程等相关情况
     netstat -anp 也可以显示系统端口使用情况



==============  查看磁盘的占用空间  =============================
df -h  看磁盘的容量
在磁盘上建立文件的时候需要两个条件：
        1.磁盘空间，
        2.需要有inode  任何一个满了都回提示设备没有空间。

可以使用df -ia查看磁盘详细信息。  看inode是否满了
不管是磁盘满，还是节点满，解决方案都是删除文件

==============  通过进程名查看对应的端口  =============================
ps -ef | grep applicationName   获取PID
netstat -anp | grep PID  根据PID获取占用的端口

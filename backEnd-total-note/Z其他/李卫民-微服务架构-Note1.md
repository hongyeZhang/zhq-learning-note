
## 千峰教育-李卫民-微服务架构2.0

#### 学习备注
* 所有相关的基础模块笔记都已分散至对应的笔记模块
* 学习链接：https://www.bilibili.com/video/av62628434/


## 微服务概述
单体应用；开发多个模块，做成一个应用。
模块与模块之前耦合度高，
微服务解决复杂问题：高内聚、低耦合。
微服务架构是一张架构思想，真正的开始是采用分布式系统开发。
运行时：每个实例通常是一个云虚拟机或者一个docker容器
Docker容器化引擎，新一代虚拟化技术
微服务架构的三大指标：高可用、高性能、高并发
沙箱机制 ？？？
微服务：每个服务有一个属于自己的数据库，独立运行，可以进行水平扩展
数据库的访问压力也会减小，能够接受更多的访问请求
微服务的优点：
    （1）解决了复杂的问题。
    （2）每个服务可以有不同的团队专注开发，新建立的服务可以采用最新的技术，用新技术重写之前的服务代码工作量也不大。
    （3）每个微服务独立部署，使持续部署成为可能。
    （4）每个服务独立扩展，根据服务的性质不同（CPU密集型、内存密集型），可以选择不同服务器配置。
之前的单体应用模型，可以称为一个java的企业级开发，给企业内部用的程序，微服务可以开发的是互联网产品。

微服务的缺点：
    （1）未来的发展方向：一个方法部署成一个微服务，方法即服务。
    （2）分区数据库，不会选择分布式事务带来的挑战。最终一致性的方法对开发人员来说更具有挑战性。 因为分布式事务对性能的消耗很大。
    （3）部署和修改单个服务，操作复杂。PaaS（平台及服务）
    （4）最大、最难的问题：数据库的分区操作，分库、分表、表分区

CAP定理与BASE理论

CAP 理论为：一个分布式系统最多只能同时满足一致性（Consistency）、可用性（Availability）和分区容错性（Partition tolerance）这三项中的两项。

一致性(Consistency)： 一致性指 (all nodes see the same data at the same time)，即更新操作成功并返回客户端完成后，所有节点在同一时间的数据完全一致。
可用性(Availability)： 可用性指(Reads and writes always succeed)，即服务一直可用，而且是正常响应时间。
分区容错性(Partition tolerance)： 分区容错性指(the system continues to operate despite arbitrary message loss or failure of part of the system)，
即分布式系统在遇到某节点或网络分区故障的时候，仍然能够对外提供满足一致性和可用性的服务。

eBay 的架构师 Dan Pritchett 源于对大规模分布式系统的实践总结，在 ACM 上发表文章提出 BASE 理论，BASE 理论是对 CAP 理论的延伸，核心思想是即使无法做到强一致性（Strong Consistency，CAP 的一致性就是强一致性），但应用可以采用适合的方式达到最终一致性（Eventual Consitency）。

基本可用(Basically Available)： 基本可用是指分布式系统在出现故障的时候，允许损失部分可用性，即保证核心可用。电商大促时，为了应对访问量激增，部分用户可能会被引导到降级页面，服务层也可能只提供降级服务。这就是损失部分可用性的体现。
软状态(Soft State)： 软状态是指允许系统存在中间状态，而该中间状态不会影响系统整体可用性。分布式存储中一般一份数据至少会有三个副本，允许不同节点间副本同步的延时就是软状态的体现。MySQL Replication 的异步复制也是一种体现。
最终一致性(Eventual Consistency)： 最终一致性是指系统中的所有数据副本经过一定时间后，最终能够达到一致的状态。弱一致性和强一致性相反，最终一致性是弱一致性的一种特殊情况。

    一致性：
        强一致性：一起成功，或者一起失败
        弱一致性：
        顺序一致性：
    CDN:内容分发网络
CP系统：一致性系统： 金融级系统
AP系统：可用性系统：非金融级系统
N个9：可用性，99.999999%
数据库：为了避免主键冲突，可以采用双活（奇数自增和偶数自增）
主键必须是数字，不能够是字符串，字符串会影响搜索性能。

========== 如何应对高并发
提高系统的并发能力：
    （1）垂直扩展：
          提升单机处理能力，增强硬件性能；
          提升单机架构性能：使用 Cache 来减少 IO 次数，使用异步来增加单服务吞吐量，使用无锁数据结构来减少响应时间；
    （2）水平扩展（主要）：
          只要增加服务器数量，就能线性扩充系统性能。水平扩展对系统架构设计是有要求的，如何在架构各层进行可水平扩展的设计，
在互联网业务发展非常迅猛的早期，如果预算不是问题，强烈建议使用 “增强单机硬件性能” 的方式提升系统并发能力，因为这个阶段，公司的战略往往是发展业务抢时间，而 “增强单机硬件性能” 往往是最快的方法。
不管是提升单机硬件性能，还是提升单机架构性能，都有一个致命的不足：单机性能总是有极限的。所以互联网分布式架构设计高并发终极解决方案还是水平扩展。
分库、分表、表分区  ？？？

## linux基础
ubuntu 开源的，免费的，最潮、最安全
centos 稳定
选用 ubuntu 18.04
ubuntu server 虚拟机装机： https://www.bilibili.com/video/av62628434/?p=8

============  Linux远程控制
shutdown -h now

ip a   查看ip
ls -al 显示当前目录的列表
pwd  当前目录
根目录  cd /
当前用户家目录  cd ~
/etc  存放配置文件
/usr/local   手动安装软件的位置（不成文的规定）
/var   存放程序运行时数据的目录
安装软件时，默认安装的位置（以MySQL为例）：
    配置文件：/etc/mysql
    数据文件：/var/mysql
    可执行文件：/bin/mysql
echo hello > 1.txt  生成一个带内容的文件
echo hello2 >> 1.txt     一个箭头是重写文件，两个箭头是追加该文件
mv 1.txt .. 移动文件到上一级目录
find . -name test.txt  在当前目录下寻找一个名为text.txt的文件（会在当前目录和下一级的所有子目录中进行查找）
cat 1.txt | grep hello
压缩、解压缩  tar

	tar [-cxzjvf] 压缩打包文档的名称 欲打包目录
压缩文件夹：tar -zcvf test.tar.gz test\
解压文件夹：tar -zxvf test.tar.gz


============  Linux系统管理、用户和组管理
linux-ubuntu 虚拟机  用户名：zhq  密码：123456

重启  sudo reboot    sudo shutdown -r now
关机 shutdown -h now

远程

ll
ls -al

cat hello.txt | grep "hello"
cat hello.txt | grep hello  与上一句相同意思
cat hello.txt | grep "he*"  可以进行正则匹配
ln 1.txt 3.txt  建立两个文件之间的软链接，其中一个发生变化，另一个也会随之发生变化
more .bashrc  分页查看内容， ctrl + c 退出
tar czvf mytest.tar.gz .  将当前目录打包为 mytest.tar.gz
tar xzvf mytest.tar.gz  将文件进行解压

========  linux 系统管理命令
stat 1.txt 查看文件的信息
du . 当前目录占的空间  du -h .
ip a 和 ifconfig  都是查看ip的命令





stat	显示指定文件的相关信息,比 ls 命令显示内容更多
who	显示在线登录用户
hostname	显示主机名称
uname	显示系统信息
top	显示当前系统中耗费资源最多的进程
ps	显示瞬间的进程状态
du	显示指定的文件（目录）已使用的磁盘空间的总量   du -h fileName 以人类可读的方式展示一个文件的大小
df	显示文件系统磁盘空间的使用情况   df -h
free	显示当前内存和交换空间的使用情况  free -h
ifconfig	显示网络接口信息
ping	测试网络的连通性（心跳检测）  ping www.baidu.com，如果出现timeout，则说明网络环境不好
netstat	显示网络状态信息
clear	清屏
kill	杀死一个进程

运行模式
编辑模式：等待编辑命令输入
插入模式：编辑模式下，输入 i 进入插入模式，插入文本信息
命令模式：在编辑模式下，输入 : 进行命令模式
命令模式
:q：直接退出vi
:wq：保存后退出vi ，并可以新建文件
:q!：强制退出
:w file：将当前内容保存成某个文件
/：查找字符串
:set number： 在编辑文件显示行号
:set nonumber：在编辑文件不显示行号
:set paste：原样粘贴

sudo passwd root  给root用户修改密码，root 密码为  123456
su root/zhq  切换用户
ctrl + d  退出（注销）用户
vi etc/ssh/sshd_config， 允许root用户登录



Service ssh restart
更改ssh的链接权限，然后重启ssh。默认情况下，超级管理员不允许远程连接


d     文件类型（d目录 -文件）
rwx   用户权限（r-read  w-write  x-execute）
r-x   用户所在组权限
r-x   其他用户权限
chmod +x fileName  增加可执行的权限
chmod +x fileName  减少可执行的权限
chown user:user test.sh  改变文件的拥有者

数字设定法
数字设定法中数字表示的含义
0 表示没有任何权限
1 表示有可执行权限 = x
2 表示有可写权限 = w
4 表示有可读权限 = r
也可以用数字来表示权限如 chmod 755 file\_name

lsb_release -a 查看系统版本


常用 APT 命令
安装软件包：apt-get install <Package Name>
删除软件包：apt-get remove <Package Name>
更新软件包列表：apt-get update  (更新源的软件版本到最新)
升级有可用更新的系统(慎用)：apt-get upgrade
搜索：apt-cache search <Package Name>
获取包信息：apt-cache show <Package Name>
删除包及配置文件：apt-get remove <Package Name> --purge
了解使用依赖：apt-cache depends <Package Name>
查看被哪些包依赖：apt-cache rdepends <Package Name>
安装相关的编译环境：apt-get build-dep <Package Name>
下载源代码：apt-get source <Package Name>
清理无用的包：apt-get clean && apt-get autoclean
检查是否有损坏的依赖：apt-get check

=============  linux部署应用程序

whereis mysql 查看mysql的位置
（1）安装jdk1.8
tar -zxvf jdk-8u152-linux-x64.tar.gz
解压缩并移动到指定目录
解压缩：tar -zxvf jdk-8u152-linux-x64.tar.gz
创建目录：mkdir -p /usr/local/java
移动安装包：mv jdk1.8.0_152/ /usr/local/java/
设置所有者：chown -R root:root /usr/local/java/
配置环境变量
配置系统环境变量：vi /etc/environment
修改系统环境变量
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
export JAVA_HOME=/usr/local/java/jdk1.8.0_152
export JRE_HOME=/usr/local/java/jdk1.8.0_152/jre
export CLASSPATH=$CLASSPATH:$JAVA_HOME/lib:$JAVA_HOME/jre/lib
配置用户环境变量：vi /etc/profile
修改用户环境变量
if [ "$PS1" ]; then
  if [ "$BASH" ] && [ "$BASH" != "/bin/sh" ]; then
    # The file bash.bashrc already sets the default PS1.
    # PS1='\h:\w\$ '
    if [ -f /etc/bash.bashrc ]; then
      . /etc/bash.bashrc
    fi
  else
    if [ "`id -u`" -eq 0 ]; then
      PS1='# '
    else
      PS1='$ '
    fi
  fi
fi
export JAVA_HOME=/usr/local/java/jdk1.8.0_152
export JRE_HOME=/usr/local/java/jdk1.8.0_152/jre
export CLASSPATH=$CLASSPATH:$JAVA_HOME/lib:$JAVA_HOME/jre/lib
export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH:$HOME/bin
if [ -d /etc/profile.d ]; then
  for i in /etc/profile.d/*.sh; do
    if [ -r $i ]; then
      . $i
    fi
  done
  unset i
fi
使用户环境变量生效：source /etc/profile

验证安装是否成功
java -version
# 输出如下
java version "1.8.0_152"
Java(TM) SE Runtime Environment (build 1.8.0_152-b16)
Java HotSpot(TM) 64-Bit Server VM (build 25.152-b16, mixed mode)

（2）安装tomcat
解压缩并移动到指定目录
解压缩：tar -zxvf apache-tomcat-8.5.23.tar.gz
变更目录：mv apache-tomcat-8.5.23 tomcat
移动目录：mv tomcat/ /usr/local/
验证安装是否成功
启动：
/usr/local/tomcat/bin/startup.sh
./startup.sh
停止：
/usr/local/tomcat/bin/shutdown.sh
./shutdown.sh


（3）安装mysql
配置使用密码方式登录
在安装过程中可能没有提示密码设置的环节此时默认使用的是 auth_socket 方式登录，我们需要修改为 mysql_native_password 方式，操作步骤如下

本地登录 MySQL，此时无需输入密码
mysql -u root -p
切换数据库到 mysql
use mysql;
修改 root 账号密码
update user set authentication_string=password('123456') where user='root';
设置登录模式
update user set plugin="mysql_native_password";
刷新配置
flush privileges;
退出 MySQL
exit;
重新启动 MySQL
systemctl restart mysql
配置远程访问
修改配置文件
vi /etc/mysql/mysql.conf.d/mysqld.cnf
注释掉(语句前面加上 # 即可)：
# bind-address = 127.0.0.1
重启 MySQL
service mysql restart
登录 MySQL
mysql -u root -p
授权 root 用户允许所有人连接
grant all privileges on *.* to 'root'@'%' identified by 'Your Password';


mysql相关的命令
常用命令
查看版本：mysqladmin -p -u root version
启动：service mysql start
停止：service mysql stop
重启：service mysql restart
登录：mysql -u root -p
授权：grant all privileges on *.* to 'root'@'%' identified by 'Your Password';

在linux上面部署jar包只需要将文件上传到服务器，然后通过命令启动即可
nohup java -jar hello-world-0.0.1-SNAPSHOT.jar > nohup.out 2>&1 &


===========================  docker
容器化，新型的虚拟化技术，能够将进行隔离。
openStack 私有云
公有云、混合云

启动 tomcat
docker pull tomcat
docker run -p 8080:8080 tomcat

===========  操作镜像
docker images = docker image ls
docker system df  docker的镜像体积，显示下载镜像锁占用的磁盘空间
虚悬镜像、中间层镜像
docker rmi tomcat/ID 删除镜像（通过名字或者ID删除）

===========  操作容器
docker ps 正在运行的容器
docker ps -a 所有的容器，包括运行和不运行的
docker run -p 8080:8080 -d tomcat  后台运行，暴露端口
默认端口 http:80  https:443
docker start containerID  启动容器
docker stop containerID  停止容器
docker rm containerID/containerName 删除容器
docker rm -f containerID 强制删除容器
docker exec -it containerID/containerName  /bin/bash
ctrl + d 退出程序
docker container prune 删除所有已经停止的容器

===========  定制镜像
先编写 dockerFile 文件，然后 docker build -t imageName .（上下文） 命令构建一个镜像，即可运行。
将需要复制的文件放在跟  dockerFile  同一级的目录下面，可以进行分类。
DockerFile 指令：
COPY
ADD
CMD  只允许使用一次
ENTRYPOINT  同CMD  但是是在最后添加
docker images --help

docker指令
http://www.qfdmy.com/%E8%AF%BE%E7%A8%8B/%e5%be%ae%e6%9c%8d%e5%8a%a1%e6%9e%b6%e6%9e%84-2-0/lessons/dockerfile-%e6%8c%87%e4%bb%a4/

Docker Compose
容器编排工具，适用于开发环境和测试环境
安装 docker-Compose

curl -L https://get.daocloud.io/docker/compose/releases/download/1.24.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
==============
java12的新特性
==============

docker compose 的使用
（1）修改虚拟机的IP
// todo
DHCP协议 会自动分配一个IP，但是IP可能会变，因为有个租期，到期之后会自动续租，所以IP是不固定的
192.168.41.130/24(子网掩码,24代表24个1，从左往右= 255.255.255.0)
子网掩码(netmask)： 255.255.255.0
网关（路由器和交换机的地址）：192.168.41.1

修改IP地址
  （1） vi /etc/netplan/vi 50-cloud-init.yaml
  (2) 用以下内容覆盖
        network:
        	ethernets:
        		ens33:
        			addresses: [192.168.41.129/24]
        			gateway4: 192.168.41.2
        			nameservers:
        				addresses: [192.168.41.2]
        	version: 2
  （3）使IP改动生效  netplan apply


===============   ubuntu 18.04 设定静态IP地址   ==========================
!!!! 注意要先通过 route -n  查看本机的网关，然后进行配置，否则配置之后网络不通！！！！

具体步骤：
修改 IP 和 DNS
课程演示会采用多虚拟机模拟分布式场景，为防止 IP 冲突，无法联网等问题，需要预先设置好主机名、IP、DNS 配置

修改主机名
修改 cloud.cfg 防止重启后主机名还原
vi /etc/cloud/cloud.cfg
# 该配置默认为 false，修改为 true 即可
preserve_hostname: true
修改主机名
# 修改主机名
hostnamectl set-hostname deployment
# 配置 hosts
cat >> /etc/hosts << EOF
192.168.141.130 deployment
EOF
修改 IP
编辑 vi /etc/netplan/50-cloud-init.yaml 配置文件，修改内容如下

network:
    ethernets:
        ens33:
          addresses: [192.168.41.129/24]
          gateway4: 192.168.41.2
          nameservers:
            addresses: [192.168.41.2]
    version: 2
使用 netplan apply 命令让配置生效

修改 DNS
# 取消 DNS 行注释，并增加 DNS 配置如：114.114.114.114，修改后重启下计算机
vi /etc/systemd/resolved.conf


===================== docker compose  使用  =====================
vi 粘贴带有tab的文本时，会出现格式的错误，需要进行原样粘贴
进入命令模式，set paste, 再按i，就可以进行原样粘贴了。

启动一个tomcat实例
vi docker-compose.yml

version: '3.1'
services:
	tomcat:
		restart: always
		image: tomcat
		container_name: tomcat
		ports:
		  - 8080:8080
		  - 3306:3306 （- 表示数字形式的配置）


守护态启动运行  docker-compose up -d
yml 配置语言，不能使用制表符进行缩进，必须使用空格进行缩进，缩进几个格不重要，只要同样级别的配置对齐即可。

数据卷：容器通过数据卷将数据写到磁盘里面
交互式进入
docker exec -it tomcat /bin/bash

=================  docker-compose  部署 gitlab
GitHub   Gitee 码云
GitLab  公司内部用，git托管，不担心代码泄露
挑战：  手动安装  GitLab
Gravatar头像注册  全球公用头像

web 连接服务器时，不允许进行输入操作的，因为会堵塞线程，所以需要免密登录。
拉取代码的方式有  https   ssh 都可以，ssh方式需要配置秘钥

=================  docker-compose  部署 Nexus
maven  私服
SNAPSHOTS  快照（开发板），在版本号不变的情况下，可以进行修改代码，满足新的需求。
REEASE （发行版） 正式上线，不允许修改
V1（改架构的次数）.0（改功能的次数）.0（改bug的次数）
mvn deploy 将自己的jar包上传到私服
https://www.bilibili.com/video/av62628434/?p=31
挺好玩的，有空可以自己实现一波

=================  docker-compose  部署 Harbor
docker 私服
有时间自己玩一下

不同的容器默认是在不同的局域网中，互相不能够联通
docker network ls 可以查看网络
docker swarm
docker machine
生产环境最终选用 k8s

=================  再谈微服务
要符合微服务的思想，并不是用了微服务框架，写的就是微服务，要将功能分解到离散的各个服务中去，降低系统的耦合性，
并提供更加灵活的服务支持。
业务领域定义了边界，可以参考DDD  领域驱动设计
金融领域：
    业务领域： ==>  主业务逻辑
    存款、取款、查询
领域划分比较困难。

要实际的应用微服务，需要解决以下问题：
    客户端如何访问这些服务
        API网关
    每个服务之间如何通信
        （1）同步
            1.1 http （对外，restful，JSON 序列化2、反序列化2次，先序列化成json字符串，然后再序列化成二进制文件，效率比较低）
                跨防火墙
            1.2 RPC （对内，因为传输效率高，序列化、反序列化）
        （2）异步
            2.1 消息队列
    如此多的服务，如何实现？
    服务挂了，如何解决？（备份方案，应急处理机制）

分布式开发的最大特点：网络是不可靠的
重试机制、限流、熔断、负载均衡、降级（本地缓存）

微服务设计模式：
应用程序的核心是业务逻辑，按照业务或客户需求组织资源。最有生命的产品，而不是项目
后台服务贯彻单一职责原则
DevOps
VM -> Docker -> Kubernetes -> istio


========================= springBoot
bean 与 POJO 的区别是  bean 存在业务意义
spring web flux 实现全程异步化
无状态应用
HTTP 无状态
服务器请求前端，需要建立长链接，
webSocket
webFlux  基于 netty 实现异步响应式编程。
观察者模式



=========================  thymeleaf 简介
内嵌的tomcat容器时，不能使用jsp
JSP 动态技术
.html  动静分离
==== springMVC
hikariCP  基于  BoneCP 进行完善

tkMyBatis  国产的mybatis 插件
entity 成为 领域模型 domain
通过 mybatis的插件自动产生代码
！！！！！   利用前面几节课学习的内容进行增、删、改、查 + 分页    ！！！！
一定要进行练习！！！！！


https://github.com/funtl
看到47集

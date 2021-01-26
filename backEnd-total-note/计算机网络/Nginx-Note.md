### 简介

反向代理
负载均衡
动静分离
配置高可用集群
高性能的HTTP和反向代理服务器，占有内存少，并发能力强，max：5W并发连接数
支持热部署，

### 反向代理
（1）正向代理：浏览器（客户端）中配置代理服务器
（2）反向代理：客户端对代理是无感知的，客户端不需要做任何配置就可以访问，由反向代理选择目标服务器，隐藏真实服务器的地址
### 负载均衡
分发流量
### 动静分离
动态页面和静态页面由不同的服务器解析
静态文件：html  css js  nginx存放
动态文件：jsp  servlet  tomcat 部署


### 安装
apt install nginx

systemctl start nginx
systemctl stop nginx
/usr/sbin/nginx 启动脚本

nmap localhost 扫描本机端口

### 常用命令
./nginx -v  版本号
nginx -s stop 停止
nginx -s reload 重新加载配置文件

### 配置文件
nginx.conf  三部分组成
（1）全局块
worker_processes nginx 并发处理数量的配置

（2）events块
nginx服务器与用户的网络连接
worker_connections 768; 每个worker支持的最大连接数
（3）http块
配置最频繁，包括http全局块和server块
server块：与虚拟主机相关

一个server包含一个全局server块和location块
location /{

}

### nginx配置
（1）配置反向代理
做本机的tomcat配置

（2）
两个配置
		location ~ /vou/ {
			proxy_pass http://127.0.0.1:8081;
    }

    ~ : 正则表达式，区分大小写
    ~* : 正则表达式，不区分大小写

（3）配置负载均衡
http块中添加
upstream tomcatserver1 {
	server 192.168.41.129:8080 weight=3;
	server 192.168.41.129:8081;
}

server {
	listen       80;
	server_name  192.168.41.129;
	location / {
		proxy_pass   http://tomcatserver1;
		index  index.html index.htm;
	}
 }
 分配策略：轮询(默认)、权重（weight）、ip_hash（每个访客访问固定的服务器，解决session问题）、fair 根据后端服务器的响应时间分配


 ### 动静分离
 把动态和静态请求分开，而不仅仅是单纯的将动态页面与静态页面分离
 nginx处理静态页面，tomcat处理动态页面
 动态请求转发到tomcat，静态请求转发到静态资源服务器

 把静态资源放在独立的服务器中，独立成单独的域名
 location中设置 expires 参数，设置浏览器的缓存时间，状态码304 缓存


 实例： 访问html 和 图片
server {
  listen       80;
  server_name  192.168.41.129;

  location /www/ {
          root   	/data/;
          index  index.html index.htm;
      }
  location /image/ {
          root   	/data/;
  	      autoindex on; （列出当前文件夹下的内容）
      }
}

### 高可用集群
nginx 可能宕机，所有的请求都会失效，无法实现效果
nginx 主备部署(master backup)
主nginx挂掉，自动切换到备份服务器
keepalived 软件，通过脚本检测nginx服务器是否活着
虚拟IP 绑定到所有的nginx服务中，keepalived 起到路由的作用，高可用部署

![avatar](/picture/nginx/nginx高可用部署.png)


### 原理
一个master  多个worker
worker 争抢机制，抢到任务，转发到tomcat
（1）利于做热部署
（2）每个worker是独立的进程，不需要加锁，如果有一个worker出现问题，保证服务不被中断
（3）采用IO多路复用机制，每个进程中只有一个主线程，异步非阻塞来处理请求，


=======   第一节   分布式架构的演进
单点集中式：所有的东西都部署在同一台服务器上，比如单位的内部考勤系统，满足需求即可。

分布式演进的原因：流量
流量带来的烦恼：
1.必然会有高并发的问题
2.为了解决高并发，必要的手段：分布式
3.为了解决高并发，必要的手段：熔断、降级、异步MQ、缓存
4.需求的频繁更迭，会需要持续集成和持续发布（CI/CD），DevOps应运而生。
单点集中式
买了一台阿里云服务器，搭建BBS、blog。
     Jetty/Tomcat+MySQL+ftp
     LAMP   linux+apache+MySQL+PHP
     LNMP   linux+nginx+MySQL+PHP
     存在即是合理的。能够满足我的需求。
     缺点：数据库出了问题，应用肯定出问题。

应用服务和数据服务拆分
随着用户访问增多（流量增加）
系统压力越来越大，响应速度越来越慢。（一张表：最多几百万，通过SQL优化完全可以提高效率）
原因：应用服务器和数据库数据服务器互相之间影响。
解决办法：Jetty/Tomcat+MySQL+ftp 改为
          Tomcat服务器+MySQL服务器+文件服务器

使用缓存改善性能
随着用户访问增多（流量增加）
用户多了，访问数据库的操作也越来越多了。（oracle链接2000个）
导致：数据连接竞争激烈，数据链接数量是有限，系统响应速度过慢。

本地缓存（Guava、jcache、Ehcache）
分布式缓存（redis、memache）
    热点数据（区县市表、用户固定数据）

页面缓存（静态页面缓存、ESI、SSI）
应用：静态页面（nginx、apache、squid）用来 做缓存的服务器
      动态页面（静态+动态）<!--#include virtual=”xxxxx.shtml”-->

根本的原因：降低数据库负载压力。
访问速度：内存访问速度（数量有限） > 网络访问内存 > 硬盘的访问速度（从数据库读取数据）
有问题：
1.数据保持数据库和数据缓存之间同步。

缓存的策略（4种写，2种读）：
write-through
   同时写缓存和DB。可能存在原子性问题，不一致。这种写法带来的性能不高。
write-around
   直接写数据库，不写缓存。但是会让缓存立即失效。
write-behind
   先写缓存。当缓存的容量达到阈值，或者当达到一定时间间隔的时候，写入数据库。
cache-aside  标红的策略用的比较广泛
   应用层保证缓存结果和DB的数据一致性，应用层负责写入到数据并整理缓存。
read-through
   读取数据时，先从缓存里面试着读取数据，如果缓存里面没有，则从数据中读取数据，然后将数据写入缓存，方便下次读取。
refresh-ahead
   在缓存过期之前，自动去刷新缓存数据。
   60s过期，refresh参数是0.8，48秒后这个数据要开始刷新。
   0-48秒，正常从缓存里面取数据。
   48-60秒，缓存先将之前缓存的数据返回给客户端，然后异步从数据库中读取数据更新缓存。

应用服务器集群
随着用户访问增多（流量增加）
应用服务器处理不过来。因为一台服务器CPU、内存处理IO的吞吐能力是有限的。（Tomcat maxThread=1000）。到了应用服务器的瓶颈。
处理方案：服务器扩展
有什么问题：
   1.Session信息同步（SSO单点登录、redis+session 分布式session）。
   2.多台服务器本地缓存之间的同步。
   3.负载均衡的问题（多台tomcat工作分配的问题。nginx、lvs、硬件F5）

数据库读写分离
随着用户访问增多（流量增加）
经过缓存、动静分离，结果发现数据库压力非常大。
举个例子：一般情况刷微信、刷微博（看的多，写的少，20%写，80%读）。
解决方案：数据库读写分离（一主一从，一主多从，多主多从，异地机房）
会遇见什么问题：
1.数据同步（把master信息同步slave）

反向代理和CDN加速
随着用户访问增多（流量增加）
微博、微信、抖音、淘宝，这些APP都是针对全国性的。加快用户的访问速度，针对异地的情况部署CDN（在当地和区域服务提供商）

分布式缓存、CDN加速、动静分离：缓存
分布式数据库
随着用户访问增多（流量增加）
发现单张表压力过高，数据库压力仍然存在。
分库分表。淘宝用户过亿，商品数量几十亿数据。
分库分表。垂直（纵向）分 库、垂直分表，水平（横向）分库、水平分表
会遇见的问题：
1.分布式主键
2.关联查询
3.join问题
4.路由的问题
5 mycat的问题   limit  查第10000页的数据，5个分片，

水平分表：按照行进行抽取分表（可以按照地域来分，可拆分成很多片 sharding-jdbc ）
数据分片：将10亿数据 拆分成100张表==》每张1000万，位于100个数据库上。
垂直分表：按照列进行抽取分表 user_info_mian   user_info_extend
水平分库：
垂直分库：
目前互联网架构形态
随着用户访问增多（流量增加）====> 需求增加 ====> 需求变更频繁
SOA是什么东西？怎么感觉跟微服务一样？ESB又是一个什么东西？

微服务
为什么使用微服务？
一个war包的部署方式：下单、支付、物流====>war部署到服务器上去

有什么问题？
1.一个环节影响其他环节，牵一发而动全身
2.开发、部署的问题。

业务拆如何分？
  下单（登陆业务、商家搜索业务、下单成功业务）
  支付（支付确认，支付选择）
  物流
SOA  面向服务的架构

ESB是什么
企业服务总线（异构系统如何通信，不同协议之间的调用RMI、webservice、http、corba，带了一定的服务编排。笨重的）
微服务的服务注册与发现（dubbo：协议是一致的。轻量级）


微服务：
微服务架构强调的第一个重点就是业务系统需要彻底的组件化和服务化，原有的单个业务系统会拆分为多个可以独立开发，设计，运行和运维的小应用。每个小应用从前端webui，到控制层，逻辑层，数据库访问，数据库都完全是独立的一套。
商家搜索（webUI、controller、db）
下单成功业务（webUI、controller、db）
登陆业务（webUI、controller、db）
微服务就是去掉ESB的SOA。微服务没有SOA的ESB企业服务总线，去中心化，粒度更细。可以更加方便地进行敏捷开发、持续集成、持续部署。





======  第二节  nginx基础知识

Nginx介绍
为什么使用Nginx？
Nginx可以做网关（过滤、数据验证、请求验证、非法攻击、redis进行cache）、proxy_cache（js、css、png、jpg、gif）可以WEB缓存、负载均衡、代理服务器（正向、反向）、WEB服务器。

面试1：有一亿用户的黑或者白名单，怎么实现访问过滤？  黑白名单过滤
Nginx + redis + lua + MySQL

WEB服务器
WEB服务器有：Nginx、Apache、lighttpd。主要提供页面的展示等等
应用服务器：weblogic   tomcat   glassfish  IIS

Apache比Nginx优点：
1.rewrite指令比nginx强大
2.模块比Nginx多
3.超级稳定，bug比较少

Nginx比Apache的优点：
1.高并发，资源占用少 10W并发占内存只要150m
2.社区很活跃
3.异步非阻塞
Nginx号称1W到5W的并发


BIO / NIO
。简单来说 I/O 可分为两类：面向磁盘和面向网络，
BIO是堵塞状态，NIO不是堵塞状态
Nginx基于多路复用epoll（扩展知识：select/poll），比Apache（select模型）使用的模型更优秀，能处理更多的并发，资源耗费较低。
当服务器的thread线程上去之后，CPU耗费同样跟着上去


应用服务器
目前知名的应用服务器：BEA Weblogic、Tomcat、Jetty、IIS、IBM WebSphere、Glassfish、JBoss
负载均衡
硬件负载均衡：F5、Array、Netscaler、Redware等
硬件负载均衡价格昂贵，如F5一般价格在30万RMB。

软件负载均衡：LVS、Nginx等

LVS优点
1.基于4层协议的（扩展知识：物理层（网线）、链路层（网卡、交换机）、网络层（IP 路由器）、传输层TCP、会话层（session）、表示层（压缩、加解密、解码之类的）、应用层HTTP）
前三层是底层协议，跟物理硬件有关系
2.负载均衡算法较多：轮询、加权轮询、最小连接、带权最小连接
3.配置比较复杂，需要配置RS服务器
4.只关注负载均衡（十几万、几十万）
5.LVS性能可以达到硬件F5的60%，替代F5的工作
6.  可以LVS 和 nginx  当一台服务器挂掉时，nginx连接到另一台

Lvs 后面可以加 nginx ，用来做缓存和软负载均衡
Nginx 与 lvs的区别是是否保持与客户端的链接

Nginx优点
1.Nginx做代理服务器的时候，它吃了上家吃下家（Nginx保持和客户端的连接，同时和服务器连接）；
2.基于网络7层，可以提供更多的服务；
3.1.9.1版本支持网络4层。

为什么使用Nginx
1.使用简单
2.高扩展
3.高可用
4.低资源消耗
5.单机支持 50000-100000 并发数  5W - 10W
6.邮件服务
7.热部署（平滑升级、平滑重启）
8.开源BSD协议（Tenigne）
Nginx安装部署
1.下载nginx
  http://nginx.org/download/nginx-1.15.3.tar.gz

2.解压nginx（C/C++源码）
  tar  xvzf  nginx压缩包路径

3.编译安装
  编译安装nginx需要前置条件，安装各种依赖库
  yum install -y gcc gcc-c++ pcre pcre-devel zlib zlib-devel openssl openssl-devel

  编译安装的命令
  configure
  make & make install
Nginx使用
conf     存放配置文件的路径
html     默认WEB路径
sbin     nginx命令的路径
logs     默认日志和pid存放路径

默认启动配置文件: conf/nginx.conf

环节变量设置
# vim /etc/profile
export NGINX_HOME=/usr/local/c10k/nginx-1.15.0
export PATH=$PATH:$NGINX_HOME/sbin

# source /etc/profile
如何启动Nginx
./nginx [-c [filename]]
如何停止Nginx
使用nginx： nginx -s stop|reload|quit
信号量：TERM、QUIT、USR1、USR2、WINCH
暴力停止kill -9  nginx master进程编号
缓慢停止kill -QUIT  nginx master进程编号
如何对Nginx进行平滑升级
当nginx版本升级，或者我们要编译进的新的模块
1.编译新的版本。把原有的nginx二进制文件改名 nginx.old；
2.拷贝新编译好的nginx文件到sbin目录；
3.使用USR2信号量，启动一个新的nginx进程。新旧Nginx进程会一起工作；
4.使用WINCH信号量，平缓停止旧master进程对应的worker经常。这个时候所有请求由新的进程来处理；
5.选择启用新的nginx进程（commit），还是启用旧的nginx进程（rollback）。


高并发、高可用、高扩展（可伸缩性强）。

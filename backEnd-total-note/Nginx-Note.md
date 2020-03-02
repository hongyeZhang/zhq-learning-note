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

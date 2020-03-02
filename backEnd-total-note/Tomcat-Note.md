https://www.bilibili.com/video/av67233983?from=search&seid=14904371206196478796

## Tomcat专题

### Tomcat基础
软件架构：B/S  C/S
资源：
* 静态资源：所有用户访问的资源都相同。html js css jpg， 可以直接被浏览器解析
* 动态资源：servlet/jsp, php, asp

网络通信三要素：传输协议、主机、端口号
基础协议：
* tcp：安全协议，三次握手
* udp:不安全协议。速度快

常见的web服务器软件
webLogic（收费，大型） webSphere（收费，大型） JBOSS（收费，大型） Tomcat(免费的，中小型)

8.5版本
目录结构:
bin : startup.bat shutdown.bat
conf: logging.properties server.xml  tomcat-users.xml
web.xml（所有项目的配置）
lib:
webapps: tomcat默认的部署目录

### 源码下载以及运行
下载源码，将conf和webapp 移动到home目录下

### tomcat架构
HTTP 工作原理
应用层协议，传输层采用TCP协议
![avatar](/picture/tomcat/Http请求原理.png)

HTTP工作流程
HTTP服务器接受请求，将请求转发给servlet 容器，由容器决定调用哪个业务类，所有的业务类都需要实现servelet接口。
HTTP服务器与业务类实现解耦。

Servelet容器工作流程
![servelet1.png](/picture/tomcat/servlet1.png)
定位servlet, 加载servlet，响应servlet

连接器 -> 容器
Coyote  负责I/O
模型：NIO（默认的模型） NIO2 APR
HTTP1.1  HTTP2.0

### 连接器组件
ProtcocalHandler,
EndPoint  Porcessor  Aaapter

### 容器 catalina
是servletring器的实现
JavaEL
是tomcat 的核心
connector container(engine host context wrapper)
context 表示一个web应用程序，一个web可以包含多个wrapper，wrapper表示一个servlet
server.xml

### tomcat 启动流程
加载配置文件，初始化容器组件，监听对应的端口号
lifecycle  声明周期
先整体 init()  再整体 start()

### tomcat请求处理流程
NIOEndPoint 接受客户端请求，进行协议解析，

### jasper
ISP页面中可以编写java页面，可以把jsp看做运行在服务器端的脚本。
JSP是tomcat的JSP核心引擎，JSP本质是一个servlet，jasper对jsp语法进行解析，生成servlet并生成
class字节码，
JspServlet 处理 index.jsp 请求找到index.jsp， 并生成一个servlet.java，生成一个字节码文件，
### JSP编译方式
（1）运行时编译
（2）

### tomcat 服务器配置
/conf


server.xml
8005 监听shutdown，五个监听器

executor 配置共享线程池，
每个连接器使用自己的线程池


<connector>
一个service下面可以有多个connector ，如果HTTP1.1  则选择一个JAVA NIO 的连接器
redirect HTTP 8443  针对 https 协议进行访问的资源，自动重定向
connector可以指定每个executor使用的共享线程池

EngineHost
localhost  webapps  当前主机下部署应用的位置  autoDeploy 是否自动部署
unpackWars 自动解压war包，不自动解压，里面的内容也是可以访问的。不影响功能。
一个引擎下面可以有多个主机，多个主机下面可以有多个应用

Context：用于配置一个web应用  配置在一个任意的目录下


tomcat-user.xml



### web配置
web.xml
tomcat 文件中配置了相关的servlet，默认的和jsp 的servlet
配置欢迎页面（默认配置）

在工程目录下，同样可以配置web.xml，针对于当前web的配置
（1）context-param
配置初始化参数，可以在servlet中拿到，如何配置+怎样获取
（2）会话配置
HTTP无状态的，session（服务端） cookie（客户端） 来解决问题
服务器产生JSESSIONID 给客户端，作为客户端的cookie
配置session的有效期（30min），cookie
（3）Servlet配置
<init-param> 仅针对当前对象
<load-on-startup> 加载顺序，如果没有配置，在第一次访问时加载servlet，tomcat启动时不加载
（4）listener配置
启动顺序与编写的顺序一致
（5）filter配置
过滤器配置，过滤资源请求及响应，日志、加密等操作
（6）欢迎页面的配置
tomcat安装目录中有默认的配置，作为全局的配置。
工程的局部配置可以覆盖默认配置
（7）错误页面配置  与欢迎页面相同

### Tomcat 管理配置
#### host-manager
虚拟主机管理。
tomcat-user.xml
添加一个用户，管理虚拟主机

#### manager
管理部署在当前tomcat中的服务
    managerApp
查看所有部署的应用列表，启动、停止、重新加载web应用
还可以查看服务器的JVM 信息、线程池的信息、堆内存（年轻代、老年代）
meataspace


### JVM配置
需要熟悉JVM的内存模型，主要围绕堆内存进行配置
JVM内存分配设置的参数有四个
-Xmx Java Heap最大值，默认值为物理内存的1/4；
-Xms Java Heap初始值，Server端JVM最好将-Xms和-Xmx设为相同值，开发测试机JVM可以保留默认值；
-Xmn Java Heap Young区大小，不熟悉最好保留默认值；
-Xss 每个线程的Stack大小，不熟悉最好保留默认值；
-XX:PermSize：设定内存的永久保存区域；
-XX:MaxPermSize：设定最大内存的永久保存区域；
-XX:PermSize：设定内存的永久保存区域；
-XX:NewSize：设置JVM堆的'新生代'的默认大小；
-XX:MaxNewSize：设置JVM堆的'新生代'的最大大小；


-Xmn:新生代的内存大小，官方建议整个堆的3/8
操作 catalina.sh
JAVA_OPTS="-server -Xms2014m -Xmx2048m -XX:MetaspaceSize=256"
新生代与老年代的内存配比：NewRatio
可以通过managerApp 进行配置

### tomcat集群搭建
单台服务器的承载能力有限，
布置多台tomcat   需要修改端口号，修改3个端口号
暂且不操作，就是nginx + 布置多台tomcat

### session 共享
解决方案：
（1）ip_hash。一个ip访问固定的服务器，能够拿到session
（2）session复制。两个服务器中的session进行同步，通过tomcat集群的广播机制完成的
tomcat server.xml中添加集群配置, simpleTcpCluster，通过广播机制向其他机器复制session
不能在大型应用中使用，会耗费资源，如果同步过多，会耗费带宽。超过4个结点不推荐使用。
（3）SSO 单点登录。 single sign on
通过认证服务处理登录问题，信息存在redis中，应用服务器是无状态，无session的。

### tomcat安全
（1）运维：网络安全方面
#### 配置安全
（1）删除webapps目录下的所有文件，禁用管理界面
（2）更改shutdown指令和端口、或者禁用指令
telnet 127.0.0.1 8005
shutdown 即可关闭tomcat
修改端口号，更改shutdown指令。

（3）定义错误页面

#### 应用安全
认证（登录） + 授权（功能权限、数据权限）
springSecurity 或者 apache shiro  安全框架

HTTPS 超文本传输安全协议，HTTP协议的基础上加入SSL 进行数据加密，保证数据不泄露
SSL/TLS：加密协议
HTTP 效率高，不安全； HTTPS 效率低，不安全
HTTPS 默认443 端口，利于SEO

### Tomcat支持HTTPS
首先 keytool 产生证书，放置到conf文件目录下面
在server.xml 文件中进行配置，connector  监听8443 端口
自己产生的证书，浏览器不信任，因为不是像有关部门申请的，所以会提示不安全

### Tomcat性能调优
先了解当前tomcat的性能，处理速度，响应时间。
（1）响应时间
（2）吞吐量：TPS
压力测试工具: apache bench(ab)   jmeter  loadrunner（收费）

利用apache bench(ab) 进行压力测试
（1） yum install httpd-tools
(2) ab -v 查看版本
(3) linux安装tomcat   部署war包
（4）put 指令上传war包
（5）测试性能:
ab -n 1000 -c 100 -p data.json

-p : post请求的json数据
-n:请求的总次数
-c：一次产生的请求个数

查看tomcat 的启动日志： catalina.out
测试报告指标

request per second 吞吐量
time per request 每个请求执行耗时

### tomcat 性能优化
#### JVM 参数调优
内存优化 + 垃圾回收优化
-Xms
-Xmx  避免内存重新分匹配（建议可用内存的80%）
年轻代与老年代的比值： 2:1  不建议修改
eden区与survivor区的大小比值，默认为8，不建议修改
配置在 catalina.sh

压力测试多次，取平均值

jmap -heap PID  查看堆内存的使用情况（配置+使用 情况）

#### JVM垃圾回收策略调优
（1）吞吐量
（2）暂停时间：垃圾回收的停止次数、时间
不同类型的垃圾回收器
（1）串行收集器
（2）并行收集器
（3）并发收集器（垃圾回收和程序同时进行）
（4）CMS收集器（并发标记清楚收集器）
（5）G1收集器

#### 垃圾回收器配置
jconsole 查看当前连接的java程序  使用的垃圾回收器
jconsole  远程连接linux系统上的 tomcat应用，在windows中查看应用信息，实现远程查看
新生代和老年代的垃圾收集器  配对使用
-XX:+UesSerialGC
-XX:+UseG1GC
-XX:+PrintGCDetails  附加信息：打印垃圾回收细节
https://www.bilibili.com/video/av67233983/?p=46   所有的辅助配置信息

### 连接器配置调整
conf/server.xml
（1）maxConnections ： 多余的请求会堵塞直到连接数低于 maxConnections
ulimit -a 查看服务器的打开文件数限制，
对于CPU 要求较高时，不建议配置较高的值
建议配置在 2000 左右
（2）maxThreads 根据服务器的硬件进行配置
（3）acceptCount
最大排队请求数，当请求数到达 maxConnections 时，可以排队的请求数目。

### Tomcat附加功能

### WebSocket
WebSocket是HTML5的新增协议，双向通信的通道，服务器和客户端都可以主动发送消息
浏览器中的在线聊天功能。 可以通过轮询机制来曲线救国实现，但是消息不够实时，服务端压力过大。
实时聊天工具：websocket

websocket 是基于http协议实现的
客户端和服务端之间建立一个长链接，不是基于请求、响应模式。
websocket 必须由浏览器发起，请求头信息: conneciton:upgrade  upgraade : WebSocket
状态码变为HTTP101，使服务端将请求转为websocket 请求。
ws://

#### tomcat 对 websocket的支持
两种方式定义Endpoint
（1）编程式  继承endpoint
（2）注解式 @ServerEndpoint
生命周期的方法：
onOpen（开启一个新的会话时自动调用）
onClose（会话关闭时）
onError（出现错误时）
messageHandler 消息处理器接受消息
onMessage
RemoteEndpoint

通过websocket 实现简易的聊天室功能。系统广播：向所有用户发送消息







get post  put delete option
请求头：
response 返回的状态码
4开头的是客户端错误，5开头的都是服务器端错误
 HTTP 400 错误 - 请求无效 (Bad request)

在ajax请求后台数据时有时会报 HTTP 400 错误 - 请求无效 (Bad request);出现这个请求无效
报错说明请求没有进入到后台服务；
原因：1）前端提交数据的字段名称或者是字段类型和后台的实体类不一致，导致无法封装；
       2）前端提交的到后台的数据应该是json字符串类型，而前端没有将对象转化为字符串类型；

查状态码
500
502
503

套接字  socket  封装底层的TCP UDP
套接字通信：
serverSocket 服务器套接字
客户端套接字：

CRLF是Carriage-Return Line-Feed的缩写，意思是回车换行，就是回车(CR, ASCII 13, \r) 换行(LF, ASCII 10, \n)

TCP
三次握手：双向请求的建立
四次挥手

套接字的通信方式：
（1）单播  点对点通讯
（2）组播  一对多的传播方式，类似于群聊聊天
  IP范围：224.0.0.0- 239
  multicastSocket类
（3）广播  只能在局域网中通信
dataGramSocket

WEB应用通信机制


Tomcat整体架构

首先是server容器，
最外层：listener

server.xml
包括很多listenr
JNI  jana native interface
jasperListener

8005 监听tomcat关闭的请求

Dos攻击





































































































































### tomcat处理一次HTTP请求的过程

1、用户点击网页内容，请求被发送到本机端口8080，被在那里监听的Coyote HTTP/1.1 Connector获得。 2、Connector把该请求交给它所在的Service的Engine来处理，并等待Engine的回应。 3、Engine获得请求localhost/test/index.jsp，匹配所有的虚拟主机Host。 4、Engine匹配到名为localhost的Host（即使匹配不到也把请求交给该Host处理，因为该Host被定义为该Engine的默认主机），名为localhost的Host获得请求/test/index.jsp，匹配它所拥有的所有的Context。Host匹配到路径为/test的Context（如果匹配不到就把该请求交给路径名为“ ”的Context去处理）。 5、path=“/test”的Context获得请求/index.jsp，在它的mapping table中寻找出对应的Servlet。Context匹配到URL PATTERN为*.jsp的Servlet,对应于JspServlet类。 6、构造HttpServletRequest对象和HttpServletResponse对象，作为参数调用JspServlet的doGet（）或doPost（）.执行业务逻辑、数据存储等程序。 7、Context把执行完之后的HttpServletResponse对象返回给Host。 8、Host把HttpServletResponse对象返回给Engine。 9、Engine把HttpServletResponse对象返回Connector。 10、Connector把HttpServletResponse对象返回给客户Browser。


1、什么是JSP?
    JSP(Java Server Pages)是Sun 公司指定的一种服务器端动态页面技术的组件规范，Jsp是以“.jsp”为后缀的文件，在该文件中主要是html 和少量的java 代码。jsp 文件在容器中会转换成Servlet中执行。

2、什么是Servlet？
    Servlet (Server Applet)是Sun公司指定的一种用来扩展Web服务器功能的组件规范，属于服务器端程序，主要功能在于交互式地浏览和修改数据，生成动态Web内容。

借用知乎上java老师的一句话：jsp就是在html里面写java代码，servlet就是在java里面写html代码。
————————————————
版权声明：本文为CSDN博主「大白快跑8」的原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/zt15732625878/article/details/79951933

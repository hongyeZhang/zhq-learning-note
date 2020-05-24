
垂直分库
水平分表

本身是java写的

server.xml
rule.xml 分片的规则
schema.xml

schema 逻辑数据库



主从复制的配置
<writeHost>
<readHost>
<dataHost> 配置负载均衡的策略  读和写分别走哪个库


分库分表、读写分离

启动mycat
./mycat start


zk + mycat 实现高可用  动态的修改配置

重启mycat
./mycat stop
./mycat start
./mycat restart

### 简介
数据库中间件，连接数据库和java应用。
存在的问题：
（1）java与数据库紧耦合
（2）高访问量，高并发对数据库压力
（3）读、写请求数据不一致
java仅需要访问MyCat 就可以了，不需要关注数据库的个数

数据库中间件对比
（1）cobar 始于阿里，但停止维护了
（2）MyCat 基于cobar开发，二次开发
（3）OneProxy 收费的商业软件
（4）kingshard  go语言开发
（5）MySQLRoute
#### 作用
（1）读写分离
（2）单主单从；双主双从
（3）数据分片。垂直拆分（分库）、水平拆分（拆表）、分库分表
单表达到千万级，性能迅速降低，需要水平拆分，分表操作。
（4）多数据源整合。重要的表可以多主同时写入；  NoSQL MySQL
####  原理
“拦截”， 拦截SQL语句：分片分析、路由分析、缓存分析、读写分离分析。得到的结果进行合并、聚合分析
#### 安装
（1）rpm 安装。 .rpm安装包，按顺序安装
（2）yum 安装。
（3）解压后即可使用。
（4）解压后编译安装。

server.xml 定义用户以及系统相关变量，如端口等。
rule.xml 分片的规则
schema.xml 定义逻辑库、表、分片节点等内容。

### 第二章  安装启动

server.xml 逻辑库名定义
schema.xml

远程访问mysql 的主机
mysql -uroot -p123456 -h 192.168.41.130 -P 3306

启动：
（1）./mycat console  控制台启动，能够看到启动日志
./mycat start

登录后台管理窗口（运维人员使用的）：
mysql -uroot -p123456 -P 9066 -h 192.168.41.129

开发人员使用
mysql -uroot -p123456 -P 8066 -h 192.168.41.129

### 搭建读写分离
首先搭建mysql的主从复制。主机只能有一个，从机可以有多台。
原理：主机写binlog，从机读取主机的binlog，写入relaylog（中继日志），从机再执行，进行数据的同步。
Mysql 从接入点开始复制，不会从头开始复制数据，但是存在一定的延时。

主机设置：129  从机：130
vim /etc/my.cnf

statement：记录SQL语句
row行模式，记录每一行的变化。
MIXED：混合模式

主机配置：
server-id=1
log-bin=mysql-bin
binlog-do-db=testdb
从机配置：
server-id=2
relay-log=mysql-relay

systemctl restart mysqld 重启服务
systemctl status mysqld 查看状态

主机从机都关闭防火墙 firewall status  inactive
主机给从机开放数据复制的权限。
从机配置 从主机开始配置的数据复制点。

在搭建好主从复制的基础上，才能进行读写分离。
重新配置主从复制： stop slave;  reset master;
insert into mytbl values(@@hostname)  插入主机名

balance=0 不开启读写分离，
balance=1 双主双从
balance=2 读请求在写主机和读主机上随机分发。
balance=3 所有的读请求随机分发到readhost 执行，writeHost 不负责读压力。

### 双主双从
#### 双主双从配置
如果一个主机出现问题，则另一个主机接管。一共需要四台机器，M1 S1 M2 S2
M1和M2作为互备主机，M1复制M2，M2复制M1，通过SQL语句设置主机。
#### 双主双从的读写分离
通过mycat配置，balance=1，
writeType = 0, 所有的写操作配置到第一个writeHost
switchType=1， 配置自动切换。
抗风险验证：

### 垂直拆分——分库
查询压力划分到多个主机上。
分库原则：根据业务对库进行拆分。  用户系统、交易系统、订单系统。
两个库上的表，如果在同一个主机上，可以join关联查询。拆分时，不同库之间的表不能够有关联关系。
修改schema.xml 文件
```xml
<mycat:schema xmlns:mycat="http://io.mycat/">
	<schema name="TESTDB" checkSQLschema="false" sqlMaxLimit="100" dataNode="dn1">
	</schema>
	<dataNode name="dn1" dataHost="localhost1" database="testdb" />
	<dataHost name="localhost1" maxCon="1000" minCon="10" balance="0"
			  writeType="0" dbType="mysql" dbDriver="native" switchType="1"  slaveThreshold="100">
		<heartbeat>select user()</heartbeat>
		<!-- can have multi write hosts -->
		<writeHost host="hostM1" url="localhost:3306" user="root"
				   password="123456">
			<!-- can have multi read hosts -->
			<readHost host="hostS2" url="192.168.41.130:3306" user="root" password="123456" />
		</writeHost>
		<!-- <writeHost host="hostM2" url="localhost:3316" user="root" password="123456"/> -->
	</dataHost>
</mycat:schema>
```

### 水平拆分--拆表
当单张表的性能受到影响时，单表1000W就会达到瓶颈。
根据某个字段、某个规则，将数据分布在不同的库中的表中。多台机器、多个库、多个表。
划分字段的选择：
（1）根据主键或者创建时间：查询订单时注重时效，不大行
（2）根据userId 进行划分。
划分原则：（a）对于主机的数量取模。

```xml
<table name="travelrecord" dataNode="dn1,dn2,dn3" rule="module-rule" />

<--! rule.xml !-->
	<tableRule name="module-rule">
		<rule>
			<columns>userid</columns>
      用现成的算法即可，不需要自己实现
			<algorithm>rang-long</algorithm>
		</rule>
	</tableRule>

	<function name="mod-long" class="io.mycat.route.function.PartitionByMod">
		<!-- how many data nodes -->
		<property name="count">3</property>
	</function>

```
在mycat 的分片表里插入数据，INSERT 字段不能省略，否则会报错

#### 分片join
要想实现分片join，涉及到的表都需要进行分片。
关联的字段，进行拆分。
ER表进行分片，第二个表的order_id 对应于父表的id
<childTable> 设置订单详情表和订单表相同的分片策略。
设置一张表对应的子表，主表怎样分，子表就怎样分。

####
字典表。  对应不同数据节点的数据
全局表！！！ 与业务表相关的字典表，多个数据节点都需要。
（1）全局表的插入、更新操作会实时在所有节点上执行，保持各个分片的数据一致性。
（2）全局表的查询操作，只从一个节点上获取
（3）全局表可以跟任何一个表进行join操作
<table name = "" type="global">

#### 常用的分片规则
（1）取模、
（2）分片枚举（自己配置，比如根据省份和区县保存数据）
分库、分表之前需要先制作计划，结合实际业务场景，准备主机，空白的数据库，通过mycat执行建表语句，进行分库。
分表：订单归属区域表
rule="sharding_by_province"  需要自己提供配置信息。
（3）范围约定
支付信息表：order_id
rule: range-long
异常情况：设置默认节点，如果匹配不到，就存放到默认节点。
（4）按照日期（天）分片

#### 全局序列
（1）mycat本地文件，由mycat进行分配。但是存在单点隐患，不推荐
（2）时间戳方式，配置简单，太长
（3）数据库方式
（4）java代码生成。

### 高可用架构

#### 基于HA机制的MyCat高可用
HAProxy + keepalived 搭建高可用集群。

### 安全设置
#### 权限设置
中间逻辑数据库的读写权限配置
设置某一个用户可以访问哪些逻辑库，是否只读等读写权限
每个逻辑库都可以设置权限的增删改权限，进行权限校验，限定到表级别和增删改查级别。
#### SQ拦截白名单
<firewall> 设置白名单，SQL黑名单。
<writeHost> <blackList>
SQL拦截黑名单：是否允许增加、删除等操作。

### 监控工具
监控平台。  mycat-web  图形化运维平台。  zookeeper 作为配置中心，管理多个节点。
监控流量、连接、活动线程、内存、慢SQL、高频SQL
（1）安装zookeeper，tar 解压后即可使用
（2）下载 mycat-web.tar.gz
（3）cp zoo_sample.cfg zoo.cfg  复制一份配置文件
（4）zkServer.sh 启动zookeeper  ./zkServer.sh start
（5）netstat -ant | grep 2181 查看zookeeper占用的端口号
（6）mycat-web 安装，安装软件 默认  /usr/local/
（7）cp -r mycat-web /usr/local ， 直接运行/bin/start.sh & 后台启动，端口号默认8082
#### 监控平台控制指标
（1）先配置zookeepr地址
（2）再配置mycat的安装地址和对应的端口




构建用户画像：打点（埋点）  监听页面的停留时间
QPS 每秒处理（读）
MySQL单表性能： 1000W 以上优化，1500W 之后性能急剧下降
查历史记录查不到太远，因为历史数据已经被存档了，库里并没有

数据分表：添加一个路由规则，相当于在数据库层面做了负载均衡
优化一亿的  用户表  数据表思路：
（1）优化磁盘的占用空间
（2）优化查询效率
要求：
（1）用户角度快速查询订单
（2）商户角度快速查询用户
订单查用户，用户查订单，可以建立二者之间的关系表，但是存在一些问题。
为了提高查询的效率，可以将同样的数据保存两份，根据两个不同的维度进行分表，另一份通过binlog进行维护。
是会造成数据冗余，可以以空间换时间

过滤系统：用户写入的评论不能直接显示，根据questionId进行分表。

binlog：

建表三件套 primary key id, addtime, updatetime
如果用自增的主键作为userId,则可以通过爬虫探取到用户规模
分布式ID生成规则：有许多
snowflake、redis、数据库、mongodb、zookeeper、UUID等
snowflake算法可以根据自身项目的需要进行一定的修改。比如估算未来的数据中心个数，每个数据中心的机器数以及统一毫秒可以能的并发数来调整在算法中所需要的bit数。
优点：
1）不依赖于数据库，灵活方便，且性能优于数据库。
2）ID按照时间在单机上是递增的。
缺点：
1）在单机上是递增的，但是由于涉及到分布式环境，每台机器上的时钟不可能完全同步，也许有时候也会出现不是全局递增的情况。


MyCat  阿里巴巴插件
mycat类似于一个代理，连接多个mysql库，将一条sql解析，确定访问哪一个数据库和数据表
核心功能：分库、分表、读写分离、全局序号

分库：一张表分散到不同的库中
分表：一个库中有多个表的备份  tableXX1  tableXX2 tableXX3
mycat 和 shradingJDBC 的区别    没有最好的架构，只有最合适的
由DBA负责维护 mycat服务
shradingJDBC  直接写到代码里，对于维护的成本比较小

通过mycat 登录到mysql数据库
mysql -h127.0.0.1 -p8066 -utest -ptest -TESTDB

mycat不影响正常的sql逻辑
server.xml  schema.xml  rule.xml  三个配置文件


QPS  读、写、删除
cellar  tair前身

自动化运维平台
大规模分布式缓存服务 Tair 模块  集合了redis  memccache  levelDB 的中间件，

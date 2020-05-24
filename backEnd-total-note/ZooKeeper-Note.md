
https://www.funtl.com/zh/apache-dubbo-zookeeper/%E4%BB%80%E4%B9%88%E6%98%AF-Zookeeper.html#zookeeper-%E7%9A%84%E5%9F%BA%E6%9C%AC%E6%93%8D%E4%BD%9C
## 概述
ZooKeeper 是一种分布式协调服务，用于管理大型主机。在分布式环境中协调和管理服务是一个复杂的过程。ZooKeeper 通过其简单的架构和 API 解决了这个问题。ZooKeeper 允许开发人员专注于核心应用程序逻辑，而不必担心应用程序的分布式特性。

分布式协调技术主要用来解决分布式环境中的多个进程之间的同步控制，让他们有序的访问某种临界资源，防止造成脏数据。
协调的本质：分布式锁


## 常用命令
```
服务端
sh  zkServer.sh  start  启动
sh  zkServer.sh  status  查看状态
sh  zkServer.sh  stop  停止服务

客户端
sh zkCli.sh 启动客户端
help
ls /        查看根节点
ls /zookeeper    查询节点
create /node01 hello   创建节点
get /node01    查看节点
set /node01 hellodfr  修改节点数据
delete /node01     删除节点
rmr /node01 递归删除
create /park01 "dateStr" 普通持久节点
create -e /park01 "dateStr" 普通临时节点
create -s /park01 "dateStr" 顺序持久节点 
create -e -s /park01 "dateStr" 临时顺序节点 

./zkCli.sh –server 10.77.20.23:2181  远程连接

rmr path 删除当前路径节点及其所有子节点
stat path : 获取指定节点的状态信息
ls2 path : 是ls 和 stat两个命令的结合
create [-s] [-e] path data acl
-s 表示是顺序节点
-e 标识是临时节点
path 节点路径
data 节点数据
acl 节点权限

history 和 redo cmdno :查看客户端这次会话所执行的所有命令 和 执行指定历史命令



```

## 通过代码操作zookeeper











Zookeeper 的应用场景
## 分布式锁
这是雅虎研究员设计 Zookeeper 的初衷。利用 Zookeeper 的临时顺序节点，可以轻松实现分布式锁。
分布式锁应该具备哪些条件
    在分布式系统环境下，一个方法在同一时间只能被一个机器的一个线程执行
    高可用的获取锁与释放锁
    高性能的获取锁与释放锁
    具备可重入特性（可理解为重新进入，由多于一个任务并发使用，而不必担心数据错误）
    具备锁失效机制，防止死锁
    具备非阻塞锁特性，即没有获取到锁将直接返回获取锁失败

分布式锁的实现有哪些
Memcached：利用 Memcached 的 add 命令。此命令是原子性操作，只有在 key 不存在的情况下，才能 add 成功，也就意味着线程得到了锁。
Redis：和 Memcached 的方式类似，利用 Redis 的 setnx 命令。此命令同样是原子性操作，只有在 key 不存在的情况下，才能 set 成功。
Zookeeper：利用 Zookeeper 的顺序临时节点，来实现分布式锁和等待队列。Zookeeper 设计的初衷，就是为了实现分布式锁服务的。
Chubby：Google 公司实现的粗粒度分布式锁服务，底层利用了 Paxos 一致性算法。

https://www.funtl.com/zh/apache-dubbo-zookeeper/%E4%BB%80%E4%B9%88%E6%98%AF%E5%88%86%E5%B8%83%E5%BC%8F%E9%94%81.html#%E9%80%9A%E8%BF%87-redis-%E5%88%86%E5%B8%83%E5%BC%8F%E9%94%81%E7%9A%84%E5%AE%9E%E7%8E%B0%E7%90%86%E8%A7%A3%E5%9F%BA%E6%9C%AC%E6%A6%82%E5%BF%B5
分布式锁存在的问题：
    （1）setnx 和 expire 的非原子性
      设想一个极端场景，当某线程执行 setnx，成功得到了锁：setnx 刚执行成功，还未来得及执行 expire 指令，节点 1 挂掉了。
      这样一来，这把锁就没有设置过期时间，变成死锁，别的线程再也无法获得锁了。
      怎么解决呢？setnx 指令本身是不支持传入超时时间的，set 指令增加了可选参数，伪代码如下：
      set（lock_sale_商品ID，1，30，NX）
      这样就可以取代 setnx 指令
    （2）加锁的时间问题，可能锁时间过期的时候，工作线程并没有处理工作完毕，造成锁的误删除，
      解决方案：set的时候添加线程ID
      可以在 del 释放锁之前做一个判断，验证当前的锁是不是自己加的锁。至于具体的实现，可以在加锁的时候把当前的线程 ID 当做 value，并在删除之前验证 key 对应的 value 是不是自己线程的 ID。
      加锁：
    String threadId = Thread.currentThread().getId()
    set（key，threadId ，30，NX）
    解锁：

    if（threadId .equals(redisClient.get(key))）{
        del(key)
    }




# 服务注册和发现
ZooKeeper 是一种分布式协调服务，用于管理大型主机。在分布式环境中协调和管理服务是一个复杂的过程。ZooKeeper 通过其简单的架构和 API 解决了这个问题。ZooKeeper 允许开发人员专注于核心应用程序逻辑，而不必担心应用程序的分布式特性。
利用 Znode 和 Watcher，可以实现分布式服务的注册和发现。最著名的应用就是阿里的分布式 RPC 框架 Dubbo。


客户端： zkClient.jar
ZooKeeper的功能：
    （1）分布式锁
    （2）服务注册与发现服务器

树是由节点所组成，Zookeeper 的数据存储也同样是基于节点，这种节点叫做 Znode。但是，不同于树的节点，Znode 的引用方式是路径引用，类似于文件路径：
/动物/猫
/汽车/宝马
这样的层级结构，让每一个 Znode 节点拥有唯一的路径，就像命名空间一样对不同信息作出清晰的隔离。
Znode 包含哪些元素
      data：Znode 存储的数据信息。
      ACL：记录 Znode 的访问权限，即哪些人或哪些 IP 可以访问本节点。
      stat：包含 Znode 的各种元数据，比如事务 ID、版本号、时间戳、大小等等。
      child：当前节点的子节点引用
      这里需要注意一点，Zookeeper 是为读多写少的场景所设计。Znode 并不是用来存储大规模业务数据，而是用于存储少量的状态和配置信息，每个节点的数据最大不能超过 1MB。

zookeeper实现分布式锁：利用临时顺序节点
分布式协调技术：
    对临界资源的有序访问


# 共享配置和状态信息
Redis 的分布式解决方案 Codis，就利用了 Zookeeper 来存放数据路由表和 codis-proxy 节点的元信息。同时 codis-config 发起的命令都会通过 ZooKeeper 同步到各个存活的 codis-proxy。

此外，Kafka、HBase、Hadoop，也都依靠Zookeeper同步节点信息，实现高可用。

标准的二叉树结构，相当于目录结构
Znode

写操作：事务  watch机制
watcher 观察  ->  观察者模式

数据的结构：类似于二叉树
具备的功能：服务发现与注册，分布式锁

ZooKeeper 实现自身的高可用：
ZooKeeper的一致性问题：
单机环境下的zookeeper集群实现高可用：多个docker容器
解决的问题：
（1）数据同步：
主从模式：leader（主节点）  fellower
数据更新：先更新到主节点，再同步到从节点  读写分离
读数据：从任意节点读取即可
ZAB实现数据同步（数据一致性）
崩溃：主节点掉线，选举：从节点中选出主节点，
ZXID：事务编号，相当于自增事务ID
投票给事务最新的，ZXID最大的节点


# Zookeeper 的事件通知
我们可以把 Watch 理解成是注册在特定 Znode 上的触发器。当这个 Znode 发生改变，也就是调用了 create，delete，setData 方法的时候，将会触发 Znode 上注册的对应事件，请求 Watch 的客户端会接收到异步通知
Zookeeper Service 集群是一主多从结构。
在更新数据时，首先更新到主节点（这里的节点是指服务器，不是 Znode），再同步到从节点。
在读取数据时，直接读取任意从节点。
为了保证主从节点的数据一致性，Zookeeper 采用了 ZAB 协议，这种协议非常类似于一致性算法 Paxos 和 Raft。

# 什么是 ZAB
Zookeeper Atomic Broadcast，有效解决了 Zookeeper 集群崩溃恢复，以及主从同步数据的问题。

# ZAB 协议定义的三种节点状态
Looking ：选举状态。
Following ：Follower 节点（从节点）所处的状态。
Leading ：Leader 节点（主节点）所处状态。

什么是 ZAB
Zookeeper Atomic Broadcast，有效解决了 Zookeeper 集群崩溃恢复，以及主从同步数据的问题。

# ZAB 协议定义的三种节点状态
Looking ：选举状态。
Following ：Follower 节点（从节点）所处的状态。
Leading ：Leader 节点（主节点）所处状态。
# 最大 ZXID
最大 ZXID 也就是节点本地的最新事务编号，包含 epoch 和计数两部分。epoch 是纪元的意思，相当于 Raft 算法选主时候的 term。

# ZAB 的崩溃恢复（选举）
假如 Zookeeper 当前的主节点挂掉了，集群会进行崩溃恢复。ZAB 的崩溃恢复分成三个阶段：

Leader election

选举阶段，此时集群中的节点处于 Looking 状态。它们会各自向其他节点发起投票，投票当中包含自己的服务器 ID 和最新事务 ID（ZXID）。



接下来，节点会用自身的 ZXID 和从其他节点接收到的 ZXID 做比较，如果发现别人家的 ZXID 比自己大，也就是数据比自己新，那么就重新发起投票，投票给目前已知最大的 ZXID 所属节点。



每次投票后，服务器都会统计投票数量，判断是否有某个节点得到半数以上的投票。如果存在这样的节点，该节点将会成为准 Leader，状态变为 Leading。其他节点的状态变为 Following。

数据一致性：
    强一致性：
    弱一致性：
    顺序一致性：zookeeper

## zookeeper实现分布式锁
四种节点类型：

临时顺序节点：

分布式锁的三个核心要素：
  加锁：
  解锁：
  锁超时：不存在超时问题，watcher机制，观察到锁释放掉，就继续执行下一个
三个问题：
  保证原子性操作：
  防止误删锁：
  在误删的基础上，加一个守护线程，为锁续命

ZNode四种状态：

https://www.bilibili.com/video/av45646849/?p=10
zookeeper实现分布式锁：临时顺序节点！！！
分布式协调：对临界资源的有序访问

部署方式：
单机部署、集群部署、伪集群部署
docker 部署：真集群部署
集群>=3的奇数  3 5 7 9等

===================   基于 Docker 安装 Zookeeper

Zookeeper 部署有三种方式，单机模式、集群模式、伪集群模式，以下采用 Docker 的方式部署
注意： 集群为大于等于3个奇数，如 3、5、7,不宜太多，集群机器多了选举和数据同步耗时长，不稳定。

安装：
vi docker-compose.yml

单机部署时的内容
version: '3.1'
services:
    zoo1:
        image: zookeeper:3.4.13
        restart: always
        hostname: zoo1
        ports:
            - 2181:2181
        environment:
            ZOO_MY_ID: 1
            ZOO_SERVERS: server.1=zoo1:2888:3888

集群部署时的内容
version: '3.1'
services:
    zoo1:
        image: zookeeper:3.4.13
        restart: always
        hostname: zoo1
        ports:
            - 2181:2181
        environment:
            ZOO_MY_ID: 1
            ZOO_SERVERS: server.1=zoo1:2888:3888 server.2=zoo2:2888:3888 server.3=zoo3:2888:3888

    zoo2:
        image: zookeeper:3.4.13
        restart: always
        hostname: zoo2
        ports:
            - 2182:2181
        environment:
            ZOO_MY_ID: 2
            ZOO_SERVERS: server.1=zoo1:2888:3888 server.2=zoo2:2888:3888 server.3=zoo3:2888:3888

    zoo3:
        image: zookeeper:3.4.13
        restart: always
        hostname: zoo3
        ports:
            - 2183:2181
        environment:
            ZOO_MY_ID: 3
            ZOO_SERVERS: server.1=zoo1:2888:3888 server.2=zoo2:2888:3888 server.3=zoo3:2888:3888

docker-compose up -d
以交互式的方式进入容器查看：
docker exec -it zookeeper_zoo1_1 /bin/bash


===================   Zookeeper 配置说明
port:2181

### Zookeeper 的三种工作模式
    单机模式：存在单点故障
    集群模式：在多台机器上部署 Zookeeper 集群，适合线上环境使用。
    伪集群模式：在一台机器同时运行多个 Zookeeper 实例，仍然有单点故障问题，当然，其中配置的端口号要错开的，适合实验环境模拟集群使用。
### Zookeeper 的三种端口号
    2181：客户端连接 Zookeeper 集群使用的监听端口号
    3888：选举 leader 使用
    2888：集群内机器通讯使用（Leader 和 Follower 之间数据同步使用的端口号，Leader 监听此端口）

### Zookeeper 单机模式配置文件
配置文件路径：/conf/zoo.cfg
```
    clientPort=2181
    dataDir=/data
    dataLogDir=/datalog
    tickTime=2000
    clientPort：这个端口就是客户端连接 Zookeeper 服务器的端口，Zookeeper 会监听这个端口，接受客户端的访问请求。
    dataDir：Zookeeper 保存数据的目录。
    dataLogDir：Zookeeper 保存日志的目录。
    tickTime：这个时间是作为 Zookeeper 服务器之间或客户端与服务器之间维持心跳的时间间隔，也就是每隔 tickTime 时间就会发送一个心跳。
    #Zookeeper 集群模式配置
```


### Zookeeper 集群模式配置文件
配置文件路径：/conf/zoo.cfg
```
    clientPort=2181
    dataDir=/data
    dataLogDir=/datalog
    tickTime=2000
    initLimit=5
    syncLimit=2
    autopurge.snapRetainCount=3
    autopurge.purgeInterval=0
    maxClientCnxns=60
    server.1=192.168.0.1:2888:3888
    server.2=192.168.0.2:2888:3888
    server.3=192.168.0.3:2888:3888
```
  initLimit：配置 Zookeeper 接受客户端（这里所说的客户端不是用户连接 Zookeeper 服务器的客户端，而是 Zookeeper 服务器集群中连接到 Leader 的 Follower 服务器）初始化连接时最长能忍受多少个心跳时间间隔数。当已经超过 initLimit（默认为 10） 个心跳的时间（也就是 tickTime）长度后 Zookeeper 服务器还没有收到客户端的返回信息，那么表明这个客户端连接失败。总的时间长度就是 5 * 2000 = 10 秒

  syncLimit： 配置 Leader 与 Follower 之间发送消息，请求和应答时间长度，最长不能超过多少个 tickTime 的时间长度，总的时间长度就是 2 * 2000 = 4 秒
  定时清理（Zookeeper 从 3.4.0 开始提供了自动清理快照和事务日志的功能）以下两个参数配合使用：
  autopurge.purgeInterval：指定了清理频率，单位是小时，需要填写一个 1 或更大的整数，默认是 0，表示不开启自己清理功能。
  autopurge.snapRetainCount：指定了需要保留的文件数目。默认是保留 3 个。
  maxClientCnxns：限制连接到 Zookeeper 的客户端的数量，限制并发连接的数量，它通过 IP 来区分不同的客户端。此配置选项可以用来阻止某些类别的 Dos 攻击。将它设置为 0 或者忽略而不进行设置将会取消对并发连接的限制。
  server.A=B：C：D：其中 A 是一个数字，表示这个是第几号服务器。B 是这个服务器的 IP 地址。C 表示的是这个服务器与集群中的 Leader 服务器交换信息的端口(2888)；D 表示的是万一集群中的 Leader 服务器挂了，需要一个端口来重新进行选举，选出一个新的 Leader，而这个端口就是用来执行选举时服务器相互通信的端口(3888)。如果是伪集群的配置方式，由于 B 都是一样，所以不同的 Zookeeper 实例通信端口号不能一样，所以要给它们分配不同的端口号。
  注意： server.A 中的 A 是在 dataDir 配置的目录中创建一个名为 myid 的文件里的值（如：1）

## Zookeeper 常用命令
zkServer
启动服务  ./zkServer.sh start
停止服务  ./zkServer.sh stop
重启服务  ./zkServer.sh restart
执行状态  ./zkServer.sh status

zkClient
客户端连接服务器并进入 Bash 模式  ./zkCli.sh -server <ip>:<port>
创建节点（Bash 模式）  create /test "hello zookeeper"
查询节点（Bash 模式）  get /test
删除节点（Bash 模式）  delete /test


# zookeeper

## 基础知识
* 分布性：分布式系统里面的多台计算在空间上随意分布，而且机器的情况也是随时变动。
* 并发性：并发处理，协同工作。
* 故障总是会发生：网络、节点故障
* 缺乏全局时钟：2个事件或者2个消息，先后顺序。

## 基本命令
```shell
create /tomcat tomcat
get /tomcat
help
stat /tomcat
rmr 删除节点
只读操作 ls /
写操作：set
读操作: ls get ls2
create [-s] [-e] path data acl
ls2  /Test456   会把子节点也列出来
set /path data

```



## 节点ZNode
JTA 强一致性事务
TCC MQ  分布式事务，分布式事务：中间有网络，这其中是自己不能控制的
XA
事务协调器
2PC 3PC
DriudXADatasource

#### Quorum机制
为了保证数据的一致性。WARO(Write All Record one)写数据的时候（数据分区），必须保证所有的副本更新成功，这次操作才算成功，否则为失败。
假定有一个操作，要更新5个节点的数据（V1，V1，V1，V1，V1），只要更新过半成功，则该次操作成功，（V2，V2，V2，V1，V1）。

paxos(ZAB)

### cache写数据的四种模型

zookeeper 是基于netty的长连接
服务器三个角色： leader follower observer
leader: 写+读+选举
follower：读+选举
observer：读

### Zonde
ZooKeeper的数据模型，它是一种树形结构，类Unix文件目录形式。
只有目录的概念，没有文件的概念
ACL access control level
zxid 全局唯一的
create 创建
delete 删除 delete/rmr
read 只读
write 只写
节点类型：持久节点（顺序）、临时节点（顺序）
临时节点的 ephemeralOwner  sessionId

zookeeper作为配置中心，watch通知服务器热加载配置。
* 同一个节点下，不能创建同名的node
* 临时节点下面不能再创建节点

## 通过场景认识zookeeper
CAS  compare and set
CAS check and swap
WATCH：
应用场景：
* 发布订阅
* 负载均衡
* 服务注册与发现
* 分布式锁
* master选举
* 分布式队列（创建临时顺序节点，最小的节点拿到锁，）
* 分布式主键ID
* 配置管理
* 集群管理（通过watch监听临时节点，进行监控，发送告警）

## watch 和 ACL机制
set path [watch]
get path [watch]
ls / watch
watch  仅会生效一次，如果要多次生效，则要重新设置

curator 是最好的zookeeper客户端
一个路径可以有多个watcher
一个watcher可以对应多个znode
客户端编程，监听指定事件的操作

NodeDataChanged    节点数据发生变化  set /path data(setData)
NodeChildrenChanged 节点的子节点发生变化  create /path data、delete (create、delete)
NodeCreate          节点创建
NodeDelete          节点删除

#### ACL
access control level  访问控制等级
节点访问有5种：
READ（只读）
WRITE（只写）
CREATE（创建）
DELETE（删除）
ADMIN（节点管理操作）

```java
    @InterfaceAudience.Public
    public interface Perms {
        int READ = 1 << 0;

        int WRITE = 1 << 1;

        int CREATE = 1 << 2;

        int DELETE = 1 << 3;

        int ADMIN = 1 << 4;

        int ALL = READ | WRITE | CREATE | DELETE | ADMIN;
```

```
  getAcl / 返回结果：'world,' anyone: cdrwa
  权限模式分为4种：
  * world： 开放式权限，代表所有人可以访问
  * IP：    针对IP开放
  * digest： 用户密码模式
  * super： 超级用户模式
  create [-s] [-e] path data acl
  create /Tomcat 123
  ACL设置方式：
  Schema:ID:Permission
  创建节点带ACL控制：create [-s] [-e] path data Schema:ID:Permission

  connect ip:port 指定端口登录

  create /hhh hhh digest:test:12345:cdwra
  addauth digest user1:12345
  auth  存储用户验证信息
  setAcl
```

## Paxos 协议
分布式一致性协议
两台zookeeper节点可以工作吗？  可以
四个节点坏掉两台，就不能对外工作了
过半机制
google 三大论文
MapReduce
BigTable
BigFS

WARO
拜占庭将军问题

接受事物编号最新的请求
二阶段提交：
（1）prepare阶段
（2）accept阶段

## ZAB协议
ZXID 是一个64位的数据结构
高32位：epoch 年号 （leader重新选举之后，高32位会发生变化）
低32位：事物编号
ZXID  由leader产生，自增而且有顺序性
所有的事务性操作都是由leader产生的，即使是follower接收到，也会将事务性请求转发给leader

ZAB协议的三个阶段：
* 发现
* 同步
* 广播

zKcleanup.sh 清理日志
数据同步方式：
* 增量同步
* 全量同步
* 回滚再同步

两个更好用的客户端
* zkClient
* curator

#### master选举
* master节点是持久节点
*

hadoop 高可用，通过zookeeper 实现

选主原理介绍：zookeeper的节点有两种类型，持久节点跟临时节点。临时节点有个特性，就是如果注册这个节点的机器失去连接(通常是宕机)，那么这个节点会被zookeeper删除。选主过程就是利用这个特性，在服务器启动的时候，去zookeeper特定的一个目录下注册一个临时节点(这个节点作为master，谁注册了这个节点谁就是master)，注册的时候，如果发现该节点已经存在，则说明已经有别的服务器注册了(也就是有别的服务器已经抢主成功)，那么当前服务器只能放弃抢主，作为从机存在。同时，抢主失败的当前服务器需要订阅该临时节点的删除事件，以便该节点删除时(也就是注册该节点的服务器宕机了或者网络断了之类的)进行再次抢主操作。从机具体需要去哪里注册服务器列表的临时节点，节点保存什么信息，根据具体的业务不同自行约定。选主的过程，其实就是简单的争抢在zookeeper注册临时节点的操作，谁注册了约定的临时节点，谁就是master。

说明：在实际生产环境中，可能会由于插拔网线等导致网络短时的不稳定，也就是网络抖动。由于正式生产环境中可能server在zk上注册的信息是比较多的，而且server的数量也是比较多的，那么每一次切换主机，每台server要同步的数据量(比如要获取谁是master，当前有哪些salve等信息，具体视业务不同而定)也是比较大的。那么我们希望，这种短时间的网络抖动最好不要影响我们的系统稳定，也就是最好选出来的master还是原来的机器，那么就可以避免发现master更换后，各个salve因为要同步数据等导致的zk数据网络风暴。所以在WorkServer中，54-63行，我们抢主的时候，如果之前主机是本机，则立即抢主，否则延迟5s抢主。这样就给原来主机预留出一定时间让其在新一轮选主中占据优势，从而利于环境稳定。


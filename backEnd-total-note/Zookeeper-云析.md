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


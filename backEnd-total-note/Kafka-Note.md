# 初识kafaka
apache kafka
基于java scala 开发
开源流处理平台，消息中间件是个副业
#### 应用场景：
* 消息
* 网站活动跟踪
* 日志聚合 （kafka + ELK）
* 作为实时计算的输入
#### kafaka特点
（1）高性能
涉及到支付的时候，用rabbitMQ

#### 使用消息队列
* 解耦
* 异步
* 削峰
* 冗余
* 顺序化
* 扩展性非常灵活

分析PV UV 可以通过nginx access.log
程序埋点  javaassist   aop
RT（response time ）  接口>500ms  就需要优化了
SLA

可以作为流数据的处理。消息和批次（一组消息）
主题：对消息进行分类
分区：类似于分库分表。
基于磁盘的存储
顺序存储：充分利用磁盘磁头的特性，悬浮、冲停
分区：高并发分流
自动在线扩容，不需要重启机器

#### 与rabbitMQ比较
如果需要顺序消费消息，则需要单个分区的。
图片
rocketMQ  阿里系，资料太少
rabbitMQ  开源时间早，很成熟
#### 安装

# Kafka中的角色
模式：伪分布式、真分布式
每一台机器叫做一个borker，独立的服务器节点
消息是按照文件的形式存在的。所以伪分布式中每台机器的目录需要不一样

### 常用命令
```
./kafka-server-start.sh ../config/server.properties & 后台启动
./kafka-server-start.sh -daemon ../config/server.properties

./kafaka-server-stop.sh ../config/server.properties

./kafka-topics.sh --list --zookeeper 127.0.0.1:2181  查看topics列表
./kafka-topics.sh --describe --zookeeper 127.0.0.1:2181 --topic <topicname>

./kafka-topics.sh --create --zookeeper localhost:2181 --config max.message.bytes=12800000 --config flush.messages=1 --replication-factor 1 --partitions 1 --topic test

./kafka-topics.sh --delete --zookeeper localhost:2181 --topic <topicname>

产生及消费消息
./kafka-console-producer.sh --broker-list 192.168.41.129:9092,192.168.41.129:9093 --topic zhq1
./kafka-console-consumer.sh --bootstrap-server 192.168.41.129:9092,192.168.41.129:9093 --topic zhq1




```
分区和副本：高可用、高性能
分区：leader分区  follower 分区
producer 发送消息模式
acks=-1 所有节点都写入才算成功
acks=1 只有leader写入成功，才算成功
acks=0  不需要确认
* 同步方式
* 异步方式
* 发送了不管（one way）
分区复制为消息提供了冗余机制
分区：提高性能
副本：高可用
顺序性要求高：不分区
顺序性要求不高：分区

## kafka 客户端命令
topic就是数据
可以消息回溯
cli:  commond  line interface

数据倾斜：数据多的服务器压力比较大，计算任务的瓶颈，
解决数据倾斜：
kafka


消息有提交偏移量
* 自动提交偏移量
* 精确提交，指定确定的偏移量

客户端的再均衡机制：可能会造成消息的重复消费
同步加异步组合提交
机架感知
序列化 + 反序列化
不建议使用自定义的序列化和反序列化，建议使用标准的消息
格式，json、thrift、protobuff、avro 等等

## 日志和偏移量
分区是为了提高性能（分而治之）
副本是为了高可用（保证数据安全）
副本设置多少合适？不要超过broker的数量。最低数是多少？1个 即可
数据量大了，设置副本多了，性能会有问题。 比如大于500TB
hadoop默认的副本数量是3个
配置信息存放在zookeeper 中，上线、下线感知
topic是持久节点，partition 是持久节点，分区对应数据，不能删除

log.dirs 日志。
如果分配了机架，则可以避免所有的副本在同一个机架上
rackware 机架感知
数据分为两个部分：
（1）元数据：zookeeper
（2）数据（message offset）：硬盘上存储
xxxx.index   xxxxx.log  用来存储数据

kafka 存储机制
* 索引数据：
* 数据：
大文件管理旧消息效率不高
高并发分布式中心思想：分而治之

broker -> partition -> segment -> file(index, log)
涉及的kafka命令
kafka-dump-log.sh --files ./0000000.index
消费消息：
at-leat-once
at-most-once
exactly-once
AR assign repilcations
ISR in-synch-replicas
OR  outof-replicas

kafka分区策略
* 轮询：没有键值的时候
* 散列：根据键值散列
* 自定义

## kafka偏移量
分区：将消息分成多个块，放在不同的分区上。某一个分区是消息的子集，所有的分区合起来是消息的总量。
数据切割、冗余（拷贝、克隆）、存放
冗余3份或者5份就可以了

每个消息都有一个唯一的偏移量。
index -> offset -> position
使用消息的偏移量，以免消息重复消费，消息丢失。
如何确保 exactly once ?
允许自动提交 设置为true时，自动设置偏移量
_consumer_offsets 存储提交的偏移量
GUI：kafka tool、kafkaOffsetMonitor、kafka manager
ACK(offset)   持久化在硬盘


https://github.com/Morningstar/kafka-offset-monitor

自动提交不会丢失数据
max.block.ms = Long.MAXVALUE

```sh
#!/bin/bash
java -cp KafkaOffsetMonitor-assembly-0.4.6-SNAPSHOT.jar \
     com.quantifind.kafka.offsetapp.OffsetGetterWeb \
     --offsetStorage kafka \
     --kafkaBrokers 192.168.41.129:9092,192.168.41.129:9093,192.168.41.129:9094 \
     --zk localhost:2181 \
     --port 8088 \
     --refresh 10.seconds \
     --retain 2.days
```
安装、使用教程
https://blog.csdn.net/guang564610/article/details/80067011

consumer 可以指定从哪里开始消费消息

./kafka-topics.sh --create --zookeeper localhost:2181 --topic Topic-06 \

./kafka-producer-perf-test.sh  性能测试，测试消息的生产能力
./kafka-producer-perf-test.sh --Topic-06 --num-records 500 --throughput 1000 --record-size 3
--produce-props bootstrap.servers=192.168.41.129:9092,192.168.41.129:9093,192.168.41.129:9094

kafka-run-class.sh 运行kafka工具，

./kafka-run-class.sh kafka.tools.GetOffsetShell --brokerlist 192.168.41.129:9092 --topic Topic-06 --time -1

./kafka-console-consumer.sh --bootstrap-server <ip:host>  --from-begining
groupid.hashcode()%numofPartition  计算偏移量提交到那个_consumer_offset

./kafka-console-consumer.sh --bootstrap-server 192.168.41.129 --topic __consumer_offset
重新消费分区的文件



## kafka重点概念
分区、副本、偏移量
stream-api
connect-api


重试策略：指定偏移量，对于重要的数据，可以添加重试机制
如果设置手动提交，而不提交偏移量，会不会造成重复消费？

不同的消费者群组可以消费同一个分区的消息
只有将消息指定到某一个分区上，才能够顺序的消费消息。

./kafka-consumer-groups.sh --bootstrap-server 192.168.41.129:9092 --list  查看消费者组的列表
./kafka-consumer-groups.sh --bootstrap-server 192.168.41.129:9092
查看每个主题对应的

./kafka-console-consumer.sh --bootstrap-server 192.168.41.129:9092 --topic Topic05 -group
ConsumerGroup0001 --from-beginning
新开一个消费者组，从头消费已经存在的主题的消息，是可以证明多个消费者组可以消费同一个主题的

kafka消息消费是推模式
分区再均衡时，一定要提交偏移量，否则新添加的消费者可能会重复消费消息

## Kafka Connect
ETL(抽取、转换、加载)  ELT
做业务报表
comnect-file

* 单机模式
* 分布式模式

github 上搜索相关的中间数据connector
confluent Inc

### 分布式模式
connect-distributed.properties


yum install epel-release
yum install jp

curl localhost:8083/connector-plugins | jq

debezium

### kafka stream
用户的浏览数据 ===>  热搜榜  ===>  统计口径
浏览最高
统计用户的行为
* 流式计算
流：事件，流数据没有边界，不可以被改变
流式处理最关键的：事件窗口，按照几秒钟/几十毫秒处理一次，

## JMX监控
JMX (java management extensions java管理扩展)
如果要更改日志级别，方法：
* 更改properties
* zk 字节码技术

@managementResource
JMX MBean
* 监控系统的运行状态
* 重启加载配置文件

DashBoard产品


## kafka实践

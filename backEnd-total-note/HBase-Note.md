
# HBase学习

## 基础知识
* google
    * BigFS    HDFS 
    * MapReduce  
    * BigTable  HBase
* 过滤器 where
* 谓词下推


##





quorum n. 法定人数


1 摘要
本文是一篇HBase学习综述，将会介绍HBase的特点、对比其他数据存储技术、架构、存储、数据结构、使用、过滤器等。

关于Phoenix on HBase，即Sql化的HBase服务，可以参考Phoenix学习

未完成

2 HBase基础概念
2.1 HBase是什么
起源
HBase源于Google 2005年的论文Bigtable。由Powerset公司在2007年发布第一个版本，2008年成为Apache Hadoop子项目，2010年单独升级为Apache顶级项目。

设计目标
HBase的设计目标就是为了那些巨大的表，如数十亿行、数百万列。

一句话概括
HBase是一个开源的、分布式的、版本化、列式存储的非关系型数据库。

面向列
准确的说是面向列族。每行数据列可以不同。
HBase表

2.2 HBase相对于RDMBS能解决什么问题
扩展性	表设计	负载均衡	failover	事务	适用数据量
RDBMS	差	灵活性较弱	差	同步实现	支持	万级
HBase	强	十亿级行，百万级列;动态列，每行列可不同。且引入列族和数据多版本概念。	强	各组件都支持HA	MVCC, Produce LOCK;行级事务	亿级
2.3 HBase特点
HBase特点

HDFS支持的海量存储，链家PC存储PB级数据仍能有百毫秒内的响应速度。（扩展性十分好）
极易扩展（可添加很多RS节点进行处理能力扩展，也可添加多个HDFS DataNode进行存储能力扩展），表自动分片，且支持自动Failover
高效地、强一致性地读写海量数据，CP
MapReduce可读写HBase
JavaAPI, Thrift / REST API, Shell
依赖Blockcache和布隆过滤器提供实时查询
服务端侧的过滤器实现谓词下推，加速查询
可通过JMX监控HBase各指标
面向列，列式存储，且列可以按需动态增加
稀疏。空Cell不占空间
数据多版本
数据类型单一，都是字符串，无类型（要用类型可用Phoenix实现）
2.4 HBase与Hadoop
HBaseHadoop
作为曾经Hadoop项目的子项目，HBase还是与Hadoop生态关系密切。HBase底层存储用了HDFS，并可直接用MapReduce操作HBase

2.5 HBase与CAP
2.5.1 CAP简介
CAP定理指出，分布式系统可以保持以下三个特征中的两个：

Consistency，一致性
请求所有节点都看到相同的数据
Availability，可用性
每个请求都能及时收到响应，无论成功还是失败。
Partition tolerance，分区容忍
即使其他组件无法使用，系统也会继续运行。
2.5.2 HBase的取舍-CP
HBase选择的是一致性和分区容忍即CP。

这篇文章给出了为什么分区容忍重要的原因you-cant-sacrifice-partition-tolerance。

已经有测试证明 HBase面对网络分区情况时的正确性。

2.6 HBase使用场景
2.6.1 适用场景
持久化存储大量数据（TB、PB）
对扩展伸缩性有要求
需要良好的随机读写性能
简单的业务KV查询(不支持复杂的查询比如表关联等)
能够同时处理结构化和非结构化的数据
订单流水、交易记录、需要记录历史版本的数据等

2.6.2 不适用场景
几千、几百万那种还不如使用RDBMS
需要类型列（不过已经可以用Phoniex on HBase解决这个问题）
需要跨行事务，目前HBase只支持单行事务，需要跨行必须依赖第三方服务
SQL查询（不过可以用Phoniex on HBase解决这个问题）
硬件太少，因为HBase依赖服务挺多，比如至少5个HDFS DataNode，1个HDFS NameNode(为了安全还需要个备节点)，一个Zookeeper集群，然后还需要HBase自身的各节点
需要表间Join。HBase只适合Scan和Get，虽然Phoenix支持了SQL化使用HBase，但Join性能依然很差。如果非要用HBase做Join，只能再客户端代码做

# C2C 电商系统微服务架构

## chapter7 C2C电商社会化治理平台的解决方案介绍

## chapter8 C2C二手电商平台社会化治理系统整体架构设计
* 架构设计图


## chapter9 架构拆分设计
* 服务的拆分架构图



## chapter11 ZooKeeper、Eureka、Consul、Nacos 的选型对比
* zookeeper 基础知识以及基本结构原理
    * leader + follower 的角色配置
    * 服务注册：写入数据
    * ZAB协议
    * 典型的 CP ， partition(分区容错性) C(consistency 一致性) 尽可能保证读取到的数据是一致的，一旦leader崩溃，短时间内不可用，然后选主，进行数据同步

* eureka AP模型，保证可用性，数据一致性不是很高
* consul 基于raft算法的CP模型
* nacos 基于raft算法的CP模型  （未来的选择）  功能最为完善

## nacos注册中心架构原理
* 





















## 方法论
* [www.funtl.com](www.funtl.com)  通过vuepress 开发
* 持续交付、持续集成、持续部署
* 继续集成的关键： GitLab runner， 基于docker 安装 GitLab runner


## 编程相关工具
* notepad++ 安装32位版本，可以使用一些插件支持
*




## 简介
重构：改善既有的代码设计

价值互联网   区块链

物联网崛起
大数据：数据量大、维度广
数据挖掘：用户行为、
        ETL -> kettle
AI
区块链  ->  分布式存储系统  异地多活分布式存储系统
云计算
用户体验   -> 前端

计算机基础、计算机网络基础


微服务架构三套方案：
springboot + spring cloud netflix
springboot + dubbo + zookeeper
springboot + spring cloud alibaba
istio

云计算 + 微服务 + 前后分离
难点： SCC + 布局
精准营销：
        协同推荐
发展脉络：
（1）入门期：做项目
（2）发展期：大数据，精准营销
（3）大数据 + 人工智能阶段
（4）人工智能 + 区块链阶段

微服务：
    架构还不成熟，标准化过程，服务网格化 service mesh     istio
大数据：
    基于微服务架构BI商业智能 大数据解决方案
    计算引擎： Hadoop  Spark
    数据仓库： Hive  ElasticSearch   Hbase + phoenix
    流式计算： Flink  Blink
    数据可视化： powerBI
    人工智能：  Tensorflow
    区块链： Hyperledger  Ethereum

## 编程到底学什么
编程的佛学与玄学
道家思想与编程思想：有道无术，
    面向过程编程、
    面向对象编程：万物皆对象，面向对象三大特性：封装、继承、多态
        封装：将对象的属性和行为抽出来包装到类中
        继承：相同的属性和行为抽象出来包装成父类
        多态：相同的属性和行为，有不同的表达方式
        开：面向扩展开放，面向修改关闭
        口：接口隔离原则
        合：组合/聚合原则
        里：里氏替换原则
        最：最少知识原则（迪米特法则）
        单：单一职责原则
        依：依赖倒置原则
    面向接口编程：
        处理各个对象之间的协作关系，主要作用是将定义与实现分离，从而实现系统解耦的目的。
    面向服务编程

用批判性思维编程：
    最有效的教育方法不是告诉答案，而是向他们提问。
    21天养成一个行为习惯
    身体习惯：一般三个月

佛家思想与产品思维：
    禅宗人生




## 架构部署
同城双活容灾
zookeeper 三台高可用

项目起名：
project-api-XXX
project-common-XXX
project-service-XXX


springboot : http通信   springboot + spring cloud
RPC  通信框架 -> 微服务架构解决方案   springboot + dubbo + zookeeper

高可用（副本）  高并发  高性能
最大的问题 -> 网络是不可靠的
基于网络不可靠进行设计


分布式系统开发遇到的问题：
（1）客户端如何访问服务？  API网关
（2）服务于服务之间如何通信？
  同步通信：（1）HTTP(apache Http client)  （2）RPC （dubbo 只支持java， Apache thrift, gRPC）
  异步通信：
      消息队列：  kafka  rabbaitMQ  RocketMQ
（3）服务治理：
      服务注册与发现
        基于客户端的服务注册与发现：apache zookeeper
        基于服务端的服务注册与发现：netflix eureka
（4）服务挂了怎么办
      重试机制、服务熔断、降级、限流

zookeeper：分布式协调服务 服务治理，分布式锁的实现框架
控制的是进程，让进程的访问变的可控，本质是分布式锁

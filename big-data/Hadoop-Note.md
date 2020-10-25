# Hadoop 学习笔记
* http://hadoop.apache.org/


## 简介
Hadoop是一个由Apache基金会所开发的分布式系统基础架构。用户可以在不了解分布式底层细节的情况下，开发分布式程序。充分利用集群的威力进行高速运算和存储。
Hadoop实现了一个分布式文件系统（Hadoop Distributed File System），简称HDFS。HDFS有高容错性的特点，并且设计用来部署在低廉的（low-cost）硬件上；
而且它提供高吞吐量（high throughput）来访问应用程序的数据，适合那些有着超大数据集（large data set）的应用程序。HDFS放宽了（relax）POSIX的要求，
可以以流的形式访问（streaming access）文件系统中的数据。
Hadoop的框架最核心的设计就是：
* HDFS为海量的数据提供了存储
* MapReduce则为海量的数据提供了计算




## chapter1 
* hadoop的核心设计
    * HDFS (hadoop distributed file system)
    * MapReduce(基于java的计算框架)
* 安装 hadoop
    * JDK 1.8
    * hadoop的版本选择：hadoop3.1.1  版本的选择决定了能否使用 HBase
    * 下载 wget 
    * linux设置 4步
    * hadoop设置 4步
    * 验证使用 2步


* 相关命令
```shell script
# 创建用户并设置密码，密码为 hadoop
# 创建新用户
useradd hadoop -m -s /bin/bash -d /home/hadoop
# 新用户设置密码
passwd hadoop
# 给新加的用户添加权限
su -l hadoop

 
# 设置目录权限
chown -R hadoop:hadoop /usr/local/bigdata/hadoop/hadoop-3.1.4
# 在hadoop 用户目录下创建相关的数据目录
mkdir -p ./hdfs/name ./hdfs/data




```




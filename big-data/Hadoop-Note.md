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


HDFS采用了主从（Master/Slave）结构模型，一个HDFS集群是由一个NameNode和若干个DataNode组成的。其中NameNode作为主服务器，管理文件系统
的命名空间和客户端对文件的访问操作；集群中的DataNode管理存储的数据



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
* 启动方式
```shell script
# 第一种启动方式
start-all.sh
# 第二种启动方式(推荐使用)
start-dfs.sh
start-yarn.sh
```

192.168.41.29:50090
192.168.41.29:8088



### 操作命令

```shell script
hdfs dfs -ls /
# 创建目录
hdfs dfs -mkdir /hdfs
# 查看文件
hdfs dfs -cat + 文件

# 查看所有的操作命令
hdfs dfs 


# 启动命令
start-dfs.sh
start-yarn.sh
# 停止命令
stop-yarn.sh
stop-dfs.sh


# 列出HDFS下的文件
hdfs dfs -ls
# 显示HDFS中指定的文件的读写权限、大小、创建时间、路径等信息
hdfs dfs -ls -h payment.txt
# 查看目录中的文件
hdfs dfs -ls /home
# 将HDFS中的in文件复制到本地系统并命名为getin
hdfs dfs -get in getin
# 删除HDFS下名为home的目录
hdfs dfs -rm -r /home
# 查看HDFS下payment.txt文件中的内容
hdfs dfs -cat /home/payment.txt
# 建立目录 
hdfs dfs -mkdir /user/hadoop/examples
# 复制文件
hdfs dfs -copyFromLocal 源路径 路径

# 将文件上传到 hadoop 的 /input 目录
hdfs dfs -put payment.txt /input




```

### 管理命令
* 缓存
    * 当我们需要频繁访问HDFS中的热点公共资源文件和短期临时的热点数据文件时，可以使用Hadoop缓存。比如：需要频繁访问的报表数据、公共资源（如：jar依赖、计算包等）






## chapter2 Hadoop HDFS核心概念

### 一、基本概念

* 存储目录
    * name：存储元数据
    * data：存储数据
    * dfs：SecondaryNameNode执行Checkpoint合并（SNN合并）的存储目录
    * nm-local-dir：缓存目录
* 元数据
    * 抽象目录树
    * 数据和块的映射
    * 数据块的存储节点

### 二、 Hadoop底层五行元素
* NameNode
    * Namenode 维护着文件系统树(filesystem tree)以及文件树中所有的文件和文件夹的元数据(metadata)。管理这些信息的文件有两个，分别是
      镜像文件(Namespace image)和操作日志文件(edit log)。
    * 在HDFS中主要是通过两个数据结构FsImage和EditsLog来实现Metadata的更新。在启动HDFS时，会从FSImage文件中读取当前HDFS文件的Metadata，
      之后对HDFS的操作都会记录到EditsLog文件中。
* 镜像文件
    * FSImage 保存了最新的元数据检查点，包含了整个HDFS文件系统的所有目录和文件的信息。
    * 对于文件来说包括了数据块描述信息、修改时间、访问时间等；
    * 对于目录来说包括修改时间、访问权限控制信息(目录所属用户，所在组)等。
      简单的说，FSImage存储的信息就相当于整个HDFS在某一时刻的快照，就是这个时刻HDFS上所有的文件块和目录，分别的状态，位于哪些个datanode，各自的权限，各自的副本个数等。


* SecondaryNameNode
    * https://blog.csdn.net/xh16319/article/details/31375197
    * SecondaryNameNode的作用就是：根据规则被唤醒，然后进行FSImage文件与EditsLog文件的合并，防止editslog文件过大，从而导致NameNode启动时间过长
    * Secondary NameNode所做的不过是在文件系统中设置一个检查点来帮助NameNode更好的工作。它不是要取代掉NameNode也不是NameNode的备份。
    * 问题：如果NameNode在启动后发生的改变过多，势必会导致EditsLog文件变得非常大，那么在下一次NameNode启动的过程中，读取了FSImage文件后，会用
        这个无比巨大的EditsLog文件进行“启动阶段合并”，从而导致Hadoop启动时间过长
    * 为什么要合并？
        * 防止editslog文件过大，导致NameNode启动时间过长。
        * FSImage是一个元数据文件，并且保存着Hadoop的整个目录树结构。随着时间的推移，元数据也会越来越庞大，FSImage文件也会越来越大，
        而FSImage的目录树也越来越复杂，如果直接对FSImage进行修改，势必会影响到效率。所以先把操作记录到EditsLog日志文件中，而后在checkpoint点
        （合并了多长时间或者事务数达到多少条）上进行合并。

* NameNode 
* DataNode 



```shell script
netstat -natp   

```
### Hadoop 的四种机制
* 机架感知
* 负载均衡
* 心跳机制
* 安全机制

### Hadoop 的两大功能
* fastDFS
    * fastDFS 是以C语言开发的一项开源轻量级分布式文件系统，他对文件进行管理，主要功能有：文件存储，文件同步，文件访问（文件上传/下载）,特别适合
    以文件为载体的在线服务，如图片网站，视频网站等

### MapReduce 计算框架
* topN、互粉、join、根据日志分析PV
* 练习例子
```shell script
# 计算圆周率的例子
hadoop jar hadoop-mapreduce-examples-3.1.4.jar pi 22 66
hadoop jar hadoop-mapreduce-examples-3.1.4.jar pi 3 5

# 执行wordcount 的命令
hadoop jar hadoop-mapreduce-examples-3.1.4.jar wordcount /input/payment.txt /out/paymentOut
# 查看 wordcount的结果
hdfs dfs -cat /out/paymentOut/part-r-00000


```
* 文件有几个块，会产生几个map，从而对应产生几个 task
* 可以设置集群并行任务的节点
* 数据就近计算，节省网络开销
* 一个块 128M

* reduce 本质是多路归并，执行外排序

* map join
* 



## Yarn
* 资源管理，任务调度
* 动态上线，动态下线




## 其他
* 更简单的安装方式  ambari





 






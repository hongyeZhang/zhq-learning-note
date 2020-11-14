
# Hive 学习笔记

## chapter1-1 数据管理和数据仓库

### 数据管理



### 数据仓库
* data warehouse
* 大案牍术
* 本身不产生数据，也不消费数据，数据来源全部来源于外部。
* OLAP（侧重于分析）  OLTP(数据库，侧重于联机事务)
* 数据库面向事务，数据仓库面向主题
* 数据库一般存储业务数据，数据仓库侧重存放历史数据
* 数据库设计遵循范式，避免冗余，而数据仓库反范式设计，有意避免冗余，以空间换时间
* 数据库是为了捕获数据，数据仓库是为了分析数据

* 数据仓库的特点
    * 面向主题的：面向应用组织数据
    * 从多个异构、分散的、独立的数据源中ETL汇总到数据库，会遇到数据统一的矛盾：如单位不统一、长度不统一、字段类型不统一
    * 和时间有关
    * 不可更新
* 数据仓库的分层架构
    * 报表展示、即时分析、数据接口、数据挖掘与分析
    * HDFS完成存储 聚合数据、多维度数据集、
    * ODS 日志数据、数据库数据、爬虫数据、其他数据


## chapter1-2 Hive安装配置
### 什么是Hive
* Hive的优点是学习成本低，可以通过类似SQL语句实现快速MapReduce统计，使MapReduce变得更加简单，而不必开发专门的MapReduce应用程序。hive十分适合对数据仓库进行统计分析
* 将SQL 转化为 MapReduce 的任务

### 安装配置过程
```shell script
wget http://mirror.bit.edu.cn/apache/hive/hive-2.3.5/apache-hive-2.3.5-bin.tar.gz


export HIVE_HOME=/Hadoop/Hive/apache-hive-3.1.2-bin
export PATH=$PATH:$HIVE_HOME/bin
source /etc/profile

cp hive-env.sh.template hive-env.sh
cp hive-default.xml.template hive-site.xml
cp hive-exec-log4j2.properties.template hive-exec-log4j2.properties
cp hive-log4j2.properties.template  hive-log4j2.properties

export HADOOP_HOME=/Hadoop/hadoop-3.1.4
export HIVE_CONFIG_DIR=/Hadoop/Hive/apache-hive-3.1.2-bin/conf
export HIVE_AUX_JARS_PATH=/Hadoop/Hive/apache-hive-3.1.2-bin/lib

./schematool -initSchema -dbType mysql;
```




## chapter2 Hive 核心知识
* Hadoop三个核心: hdfs + mapreduce + yarn
* 连接的mysql用来存放表的元数据信息
* antlr SQL语法解析  HQL -> MapReduce， 具体过程可以参考  shardingJDBC 的实现原理
* 数据库OLTP   数据仓库 OLAP
* 模式
    * 读时模式 schema on read  hive
    * 写时模式 schema on write  mysql

* hadoop 尾部追加模式 append
* 需要中间计算结果的任务，会转化为 mapreduce 进行计算执行

* 用户接口: cli  JDBC/ODBC Web GUI
* 元数据管理：内嵌存储、本地存储、远程存储
* 核心：解释器、编译器、优化器、执行器。执行语法分析、词法分析、编译、优化、运行



```shell script

# 启动
hive 
# 退出
quit

beeline



show tables;
show databases;

create database zhq_test_db;
use zhq_test_db;


create table if not exists t1(id string, name string) row format delimited fields terminated by '\t';
desc t1;
desc formatted t1;

insert into t1 values('1','zhq');
select * from t1;
drop table t1;






```


### 数据类型



### 基本概念
* 表
    * 内部表
    * 外部表
    * 分区表
    * 桶

* Hive内部表与外部表的区别
    * 创建表时
        * 创建内部表：会将数据移动到数据仓库指向的路径；
        * 创建外部表：仅记录数据所在的路径， 不对数据的位置做任何改变。
    * 删除表时
        * 内部表的元数据和数据会被一起删除
        * 外部表只删除元数据，不删除数据。外部表相对来说更加安全，数据组织更加灵活，方便共享源数据。

作者：XinXing
链接：https://juejin.im/post/6844904186161676295
来源：掘金
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。


基本语法规则： 
create table table_name(column specify) raw format 

* 创建内部表
```shell script
create table if not exists t1(id string, name string) row format delimited fields terminated by '\t';
```


* 创建外部表
    * location 确定外部数据的存储路径
```shell script
create external table if not exists t2(id string, name string) row format delimited fields terminated by '\t' location '/hadoop/t2';
insert into t2 values('2','zhq2');

```


* 创建分区表
    * 静态分区
```shell script
create table if not exists part_books(id string, name string) partitioned by(location string, year string) row format delimited fields terminated by ',';

# 添加分区信息
alter table part_books add partition(location='beijing', year='1990');
alter table part_books add partition(location='beijing', year='1991');
alter table part_books add partition(location='shanghai', year='1990');
alter table part_books add partition(location='shanghai', year='1991');
# 展示分区信息
show partitions part_books;


create table if not exists books(id string, name string, location string, year string) row format delimited fields terminated by ',';
select * from books;
load data inpath '/input/books.txt' into table books;

insert into table part_books partition(location='beijing',year='1990') select id, name from books where location='beijing' and year = '1990';

select * from books where location='beijing' and year = '1990';


```

* 批量插入数据
```shell script
from books
insert into table part_books partition(location='beijing',year='1991') select id, name where location='beijing' and year = '1991'
insert into table part_books partition(location='shanghai',year='1990') select id, name where location='shanghai' and year = '1990'
insert into table part_books partition(location='shanghai',year='1991') select id, name where location='shanghai' and year = '1991';
```


* 创建分区表（动态分区）
```shell script
create table dyn_part_books(id string, name string) partitioned by(location string) row format delimited fields terminated by ',';
show partitions dyn_part_books;
desc formatted dyn_part_books;

# 查看hive相关的变量
set -v;

# 是否允许动态分区
set hive.exec.dynamic.partition;
# 是否使用动态分区的严格模式
set hive.exec.dynamic.partition.mode;
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;


# 单列创建语句
create table dyn_part_books(id string, name string) partitioned by(location string) row format delimited fields terminated by ',';
# 单列插入语句
insert overwrite table dyn_part_books partition(location) select id, name, location from books;

# 多列模式创建语句
create table dyn_part_books1(id string, name string) partitioned by(location string, year string) row format delimited fields terminated by ',';
# 多列模式插入语句
insert overwrite table dyn_part_books1 partition(location, year) select id, name, location, year from books;
# 展示分区信息
show partitions dyn_part_books1;
```


* 分桶建表
    * 将数据按照分桶规则分成几个文件去存储。
    * 可以提高 join 的效率   
```shell script
# 分桶操作
create table bucket_books(id string, name string) clustered by(id) sorted by (id) into 4 buckets row format delimited fields terminated by ',';
insert into table bucket_books select id, name from books;
select * from bucket_books;
select * from books cluster by id;
```
























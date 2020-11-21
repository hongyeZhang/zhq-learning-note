
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

## chapter3 DML


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


### 数据采样
```shell script
# 数据采样
select * from books tablesample(10 percent);
select * from books tablesample(3 rows);
select * from books tablesample(bucket 2 out of 4 on id);
```

### DML语句
```shell script
# 全局排序
select * from books order by id;   
# 
select * from books distribute by id;
# 局部排序，全局乱序
select * from books sort by id;
# 
select * from books cluster by id;

set mapreduce.job.reduces;


# 单条插入

# 多条插入

```


```shell script

load data [local] inpath 'filepath' [overwrite] into table_name [patition(part_col=val, part_col=val, ...)]

# 载入数据
load data inpath '/home/books' into table books;

```

* order by 全局排序
* sort by 局部排序，全局乱序
* distribute by 根据字段进行 hashcode 取模后分配到相应的 reduce。类似分桶，只分不排序
* cluster by  = distribute by + sort by

* 支持的操作
    * union \ union all \ like \ case when \ having \ group by \ order by \ in \ exists
    * semi join 


## chapter4 DDL和复杂类型
* load 装载数据时，不做数据检查， insert 做数据检查
* MANAGED TABLE 内部表
* EXTERNAL TABLE 外部表

````shell script
# 内部表转外部表
alter table table_name set tblproperties('EXTERNAL'='TRUE');
# 更改表名字
alter table table_name rename to table_name_new;
# 更改字段

# 添加字段 add 关键字
alter table table_name add columns(col_name data_type);

# 字段更改， change关键字
alter table table_name change old_column new_column new_data_type;
# 字段删除  replace 关键字
alter table table_name replace columns(col_name data_type, col_name data_type);

show partitions part_books;
# 添加分区
alter table part_books add partition(location='shenzhen', year='1990');
# 修改分区
alter table table_name partition(col_name=val, col_name=val) rename to partition(col_name=val1, col_name=val2);
# 删除分区
alter table table_name drop partition(col_name=val, col_name=val);



````

* hcatalog 元数据管理


### 删除表
```shell script
drop table table_name;
truncate table table_name;
```

### 查看表
```shell script
desc table_name;
desc formatted table_name;
desc extend table_name;
show partitions table_name;

```

### 视图
````shell script
create view books_view as select id, name, year from books;
select * from books_view;

create view books_group as select id from books group by id;

````

### 复杂类型 array
```shell script
create table t_array(id int, name string, location string, years array<int>)
row format delimited fields terminated by ','
collection items terminated by ':';

load data inpath '/input/txt_array.txt' into table t_array;
select id, name, location, concat(years[0], '-', years[1]) from t_array;
``` 

### 复杂类型 struct
```shell script
create table t_struct(id int, name string, inf struct<location:string, year:int>)
row format delimited fields terminated by ','
collection items terminated by ':';

load data inpath '/input/txt_struct.txt' into table t_struct;
select id, name, inf.location, inf.year from t_struct;
``` 

### 复杂类型 Map
```shell script
create table t_map(id int, name string, location string, inf map<string, string>)
row format delimited fields terminated by '\t'
collection items terminated by ','
map keys terminated by ':';

load data inpath '/input/txt_map.txt' into table t_map;
select id, name, location, concat(inf['from'],'-',inf['to'],inf['job']) from t_map;
``` 


## chapter5 Hive的存储和压缩
### fetch机制
* hive.fetch.task.conversation 关键参数，none\minimal\more
    * none 所有的任务执行 mapreduce
    * minimal select * , filter on partition column(where and having), limit only 不用执行mapreduce
    * more （0.14之后的默认值）  select, filter, limit only 

### join
* 内连接
```shell script
select t1.*, t2.* from t1 left outer join t2 on t1.id = t2.id;
select t1.*, t2.* from t1 right outer join t2 on t1.id = t2.id;
select t1.*, t2.* from t1 full outer join t2 on t1.id = t2.id;
select * from person left semi join person_detail on person.id = person_detail.id;
```
* 外连接
* 全外连接

* 半连接
    * 最早是因为 hive不支持 in exist
    * 在map端过滤了一些无效的数据，大大节省网络IO，减少reduce shuffle 的时间
```shell script
create table person(id int, name string) row format delimited fields terminated by ',';
create table person_detail(id int, email string, qq string, address string) row format delimited fields terminated by ',';

insert into person(id, name) values (1, 'james');
insert into person_detail(id, name, qq, address) values (1, 'james', '123456','street');
select * from person left semi join person_detail on person.id=person_detail.id;
```
* 内连接：指连接结果bai仅包含符合连接条件du的行，参与连接的两个表zhi都应该符合连接条件。dao
* 外连接：连接结果不仅包含符合连接条件的行同时也包含自身不符合条件的行。包括左外连接、右外连接和全外连接。
* 左外连接：左边表数据行全部保留，右边表保留符合连接条件的行。
* 右外连接：右边表数据行全部保留，左边表保留符合连接条件的行。
* 全外连接：左外连接 union 右外连接。

### 存储方式
#### 行式存储
* 相关的字段数据保存在一起，一行数据就是一条记录
* 方便进行DML操作
* 每列数据类型不一致，不容易获得较高的压缩比，空间利用率低
#### 列式存储
* 查询时，只有涉及到的列才会被读取，不会将所有的列读取出来，可以跳过不需要的列
* 获得较高的压缩比，可以节省存储空间
* 不适合扫描比较小的数据量



```shell script
create table t_sequence(id int, name string, address string)
row format delimited fields terminated by ','
stored as sequencefile;

insert into t_sequence(id, name, address) select id, name, location from books;

# 查看导入的数据
hdfs dfs -cat /hive/warehouse/zhq_test_db.db/t_sequence/000000_0
# 查看压缩的数据
hdfs dfs -text /hive/warehouse/zhq_test_db.db/t_sequence/000000_0
```

### 压缩方式
* hive.exec.compress.output    输出结果是否压缩
* hive.exec.compress.intermediate   中间过程是否压缩

## chapter6 hive内置和自定义函数

```shell script
# 查看所有的函数
show functions;

# 
desc function trim;
# 查看函数的简要信息
desc function array;
# 查看函数的详细信息
desc function extended array;

```
* hive内置函数的分类
    * 

```shell script
select array(1,2,3,4,5);
select explode(array(1,2,3,4,5));

# 实现wordcount
select t.word, count(1) from (select explode(split(line, ' ')) word from word_sample) t group by t.word;

```
### 自定义函数






## chapter7 hive事务和索引
### hive事务表
* 有9到10条的使用限制  桶表 orc文件



### hive并发模式
* hive.support.currency = true




### TBL properties
* 表属性，允许开发者定义一些自己的键值对信息

```shell script
# 创建一个不可变的表
create table t_immu(id int, name string) row format delimited fields terminated by ',' tblproperties('immutable'='true');
insert overwrite table t_immu select id, name from books; 
show tblproperties immu;

# 给一张表加上不可变的属性，加上之后这边表就无法变化
alter table t_immu set tblproperties('immutable'='false');


create table t_tbl_orc(id int, name string) row format delimited fields terminated by ',' stored as orcfile tblproperties('orc.compress'='SNAPPY');


# 创建事务表
create table t_transaction(id int, name string, location string, yeat int ) cluster by(id) into 4 buckets
row format delimited fields terminated by ','
stored as orcfile
tblproperties('transactional'='true');

# 允许的数据装载方式
from books insert into t_transaction select id, name, location, year;
# 不允许的数据装方式
insert overwrite table t_transaction select id, name, location, year from books;
load data inpath '/home/books.txt' into table t_transaction;
show transaction;



```

* 一般数据仓库的开发不会使用事务表，只需要读取就行了







## chapter8 hive 优化



























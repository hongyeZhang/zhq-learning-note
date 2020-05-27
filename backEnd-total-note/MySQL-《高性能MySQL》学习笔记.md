
## chapter1

show table status like 'user' \G
在MySQL的sql语句后加上\G，表示将查询结果进行按列打印，可以使每个字段打印到单独的行。即将查到的结构旋转90度变成纵向；

查看表结构： desc tabelName

MySQL 拥有分层的架构，上层是服务器层的服务和查询执行引擎，下层是存储引擎。

mysql架构层次
分层逻辑架构：
连接层、服务层、引擎层、存储层

存储引擎是真正负责MYSQL中数据的存储和提取,
服务器通过API与存储引擎进行通信,
不同的存储引擎提供的功能不同,
可以根据自己的实际需求来进行选取
常见的有：lnnoDB、MylSAM、Memory
lnnoDB 【Mysql默认】：它在设计的时候，它是事物优先.
原理：因为它是行锁，我每一条数据都要锁，
锁的太多，性能就降低了，虽然性能降低了，
但是我适合高并发了，就不容易出错了
MylSAM：性能优先
原理：因为它是表锁，
对于表里面的十条数据来说是不受影响的，
对十条锁一次就完了，所以性能快
Memroy:
memory存储引擎是MySQL中的一类特殊的存储引擎。其使用存储在内存中的内容来创建表，而且所有数据也放在内存中,因此，其基于内存中的特性，这类表的处理速度会非常快，但是，其数据易丢失，生命周期短



## chapter2 MySQL基准测试
基准测试没怎么看


## chapter3 服务器性能剖析

MySQL慢查询分析工具pt-query-digest详解

## chapter4 schema与数据类型优化

使用枚举（ENUM）

create table enum_test (
e enum('fish', 'apple', 'dog') not null
);

insert into enum_test(e) values('fish'),('dog'),('apple');
select e+0 from enum_test;

为了测试sql语句的效率，有时候要不用缓存来查询。
使用 SELECT SQL_NO_CACHE ... 语法即可

SQL_NO_CACHE的真正作用是禁止缓存查询结果，但并不意味着cache不作为结果返回给query。

SELECT SQL_NO_CACHE COUNT(*) from t_marketing_activity as a
JOIN t_marketing_activity_rai as b
on a.ID = b.ACTIVITY_ID

    using等价于join操作中的on，例如a和b根据id字段关联，那么以下等价
    using(id)
    on a.id=b.id
    以下2个实例等价：
    select a.name,b.age from test as a
    join test2 as b
    on a.id=b.id

    select a.name,b.age from test as a
    join test2 as b
    using(id)


数据库范式：
目前关系数据库有六种范式：第一范式（1NF）、第二范式（2NF）、第三范式（3NF）、巴斯-科德范式（BCNF）、第四范式(4NF）和第五范式（5NF，又称完美范式）。满足最低要求的范式是第一范式（1NF）。在第一范式的基础上进一步满足更多规范要求的称为第二范式（2NF），其余范式以次类推。一般来说，数据库只需满足第三范式(3NF）就行了。


## chapter5  创建高性能的索引
索引也称为 键
B tree 索引
哈希索引

主键与索引的区别：
1、主键一定是唯一性索引，唯一性索引并不一定就是主键。
2、一个表中可以有多个唯一性索引，但只能有一个主键。
3、主键列不允许空值，而唯一性索引列允许空值。

show create table

<> 是不等号的意思，也有的语言可以写作：#  或者 !=
聚簇索引并不是一种单独的索引类型，而是一种数据存储方式：数据行和相邻的键值紧凑的存储在一起
覆盖索引：一个索引包含所有需要查询的字段的值
查看执行计划： explain + 查询语句 + \G
mysql 不能在索引中执行like操作，可以做最左匹配的like比较，不能执行函数操作

check table 检查表是否发生了损坏
repair table  或者  alter table tableName ENGINE=InnoDB 可以修复表的索引错误
optimize table 或者导入再导出的方式重新整理数据



视图：虚拟表，和普通表一样使用



## chapter6  查询性能优化

explain中的 type 解释：
    EXPLAIN执行计划中type字段分为以下几种：
    ALL
    INDEX
    RANGE
    REF
    EQ_REF
    CONST,SYSTEM
    NULL
    自上而下，性能从最差到最好
    type = ALL，全表扫描，MYSQL扫描全表来找到匹配的行
    type = index，索引全扫描，MYSQL遍历整个索引来查找匹配的行。（虽然where条件中没有用到索引，但是要取出的列title是索引包含的列，所以只要全表扫描索引即可，直接使用索引树查找数据）
    type = range ，索引范围扫描，常见于<、<=、>、>=、between等操作符（因为customer_id是索引，所以只要查找索引的某个范围即可，通过索引找到具体的数据）
    type = ref ，使用非唯一性索引或者唯一索引的前缀扫描，返回匹配某个单独值的记录行。
    type = eq_ref，相对于ref来说就是使用的是唯一索引，对于每个索引键值，只有唯一的一条匹配记录（在联表查询中使用primary key或者unique key作为关联条件）
    type = const/system，单表中最多只有一条匹配行，查询起来非常迅速，所以这个匹配行中的其他列中的值可以被优化器在当前查询中当做常量来处理。例如根据主键或者唯一索引进行的查询
    type = NULL，MYSQL不用访问表或者索引就直接能到结果。

对于大量的数据删除需要做切分
delete from tabelName where updateTime < DATE_SUB(now(), interval 3 month)

delete from tabelName where updateTime < DATE_SUB(now(), interval 3 month) limit 10000

查询状态： show full processlist

mysql查询优化器提示(hint)
在MySQL中，当我们提交SQL查询时，查询优化器默认选择一些索引来获得最佳的查询计划，有时可能不是最好的，但是可通过使用名为USE INDEX的索引提示来推荐查询优化器应该使用的索引。
    一起看下MySQL USE INDEX提示的语法：
    SELECT select_list
    FROM table_name USE INDEX(index_list)
    WHERE condition;
    这个语法的作用是，USE INDEX指示查询优化器使用其中一个命名索引来查找表中的行。


### 触发器
简单的说，就是一张表发生了某件事（插入、删除、更新操作），然后自动触发了预先编写好的若干条SQL语句的执行；
特点及作用
特点：触发事件的操作和触发器里的SQL语句是一个事务操作，具有原子性,要么全部执行，要么都不执行；
作用：保证数据的完整性，起到约束的作用；
增加程序的复杂度，有些业务逻辑在代码中处理，有些业务逻辑用触发器处理，会使后期维护变得困难；


MySQL UNION 操作符用于连接两个以上的 SELECT 语句的结果组合到一个结果集合中。多个 SELECT 语句会删除重复的数据。
UNION ALL  不会删除重复的数据

group_concat()


concat()函数
1、功能：将多个字符串连接成一个字符串。
2、语法：concat(str1, str2,...)
返回结果为连接参数产生的字符串，如果有任何一个参数为null，则返回值为null。
3、举例：
例1:select concat (id, name, score) as info from tt2;


group_concat()
1、功能：将group by产生的同一个分组中的值连接起来，返回一个字符串结果。
2、语法：group_concat( [distinct] 要连接的字段 [order by 排序字段 asc/desc ] [separator '分隔符'] )
说明：通过使用distinct可以排除重复值；如果希望对结果中的值进行排序，可以使用order by子句；separator是一个字符串值，缺省为一个逗号。


exists
EXISTS用于检查子查询是否至少会返回一行数据，该子查询实际上并不返回任何数据，而是返回值True或False
EXISTS 指定一个子查询，检测 行 的存在。
语法： EXISTS subquery
参数： subquery 是一个受限的 SELECT 语句 (不允许有 COMPUTE 子句和 INTO 关键字)。
结果类型： Boolean 如果子查询包含行，则返回 TRUE ，否则返回 FLASE 。

　EXISTS(包括 NOT EXISTS )子句的返回值是一个BOOL值。 EXISTS内部有一个子查询语句(SELECT ... FROM...)， 我将其称为EXIST的内查询语句。其内查询语句返回一个结果集。 EXISTS子句根据其内查询语句的结果集空或者非空，返回一个布尔值。
一种通俗的可以理解为：将外查询表的每一行，代入内查询作为检验，如果内查询返回的结果取非空值，则EXISTS子句返回TRUE，这一行行可作为外查询的结果行，否则不能作为结果。

SELECT * FROM t_marketing_activity
WHERE EXISTS (SELECT NULL)

SELECT * from t_marketing_activity a
WHERE EXISTS (SELECT activity_id from t_marketing_activity_rai b WHERE b.activity_id = a.ID)
与上一句等价
SELECT * from t_marketing_activity a
WHERE EXISTS (SELECT 1 from t_marketing_activity_rai b WHERE b.activity_id = a.ID)











### 主键
一列或者多列（复合主键）
    主键约束即在表中定义一个主键来唯一确定表中每一行数据的标识符。主键可以是表中的某一列或者多列的组合，其中由多列组合的主键称为复合主键。主键应该遵守下面的规则：
    每个表只能定义一个主键。
    主键值必须唯一标识表中的每一行，且不能为 NULL，即表中不可能存在两行数据有相同的主键值。这是唯一性原则。
    一个列名只能在复合主键列表中出现一次。
    复合主键不能包含不必要的多余列。当把复合主键的某一列删除后，如果剩下的列构成的主键仍然满足唯一性原则，那么这个复合主键是不正确的。这是最小化原则。


### UUID

UUID 是 通用唯一识别码（Universally Unique Identifier）的缩写，是一种软件建构的标准，亦为 开放软件基金会 组织在 分布式计算 环境领域的一部分。其目的，是让分布式系统中的所有元素，都能有唯一的辨识信息，而不需要通过中央控制端来做辨识信息的指定。如此一来，每个人都可以创建不与其它人冲突的UUID。在这样的情况下，就不需考虑数据库创建时的名称重复问题。


### 聚簇索引
聚簇索引：将数据存储与索引放到了一块，找到索引也就找到了数据
非聚簇索引：将数据存储于索引分开结构，索引结构的叶子节点指向了数据的对应行，myisam通过key_buffer把索引先缓存到内存中，当需要访问数据时（通过索引访问数据），在内存中直接搜索索引，然后通过索引找到磁盘相应数据，这也就是为什么索引不在key buffer命中时，速度慢的原因
澄清一个概念：innodb中，在聚簇索引之上创建的索引称之为辅助索引，辅助索引访问数据总是需要二次查找，非聚簇索引都是辅助索引，像复合索引、前缀索引、唯一索引，辅助索引叶子节点存储的不再是行的物理位置，而是主键值

聚簇索引默认是主键，如果表中没有定义主键，InnoDB 会选择一个唯一的非空索引代替。如果没有这样的索引，InnoDB 会隐式定义一个主键来作为聚簇索引。InnoDB 只聚集在同一个页面中的记录。包含相邻健值的页面可能相距甚远。

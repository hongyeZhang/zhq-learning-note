
#  MySQL 学习笔记

* MySQL数据库
* RDBMS 即关系数据库管理系统(Relational Database Management System)

## 安装
连接到MySQL服务器：mysql -u root -p
密码：123456


查看mysql版本【未登录即可查看】： mysql -v
select version();

设置root账号的登录密码
set password for 'root'@'localhost' = password('123456');


mysql 允许外部连接操作步骤
use mysql;
修改权限：GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '123456' WITH GRANT OPTION;
root 用户，密码为123456
更新user： flush privileges;
查看  select host, user from user;



### centos 安装mysql5.7
* https://blog.csdn.net/qq_36582604/article/details/80526287
```
ALTER USER 'root'@'localhost' IDENTIFIED BY 'ZHQzhq123***';

执行以下命令开启远程访问限制（注意：下面命令开启的IP是 192.168.0.1，如要开启所有的，用%代替IP）：
grant all privileges on *.* to 'root'@'%' identified by 'ZHQzhq123***' with grant option;


vi /etc/my.cnf
[client]
default-character-set=utf8
character-set-server=utf8
collation-server=utf8_general_ci

service mysqld restart

开启binglog
show variables like '%log_bin%';

my.cnf添加如下：
log_bin=mysql_bin
binlog-format=Row
server-id=1

login: mysql -uroot -pZHQzhq123***


MySQL5.7版本中，my.cnf的位置一般在/etc/my.cnf，要在my.cnf中添加:

[mysqld]
log-bin=/var/log/mysql-binlog/mysql-binlog
server-id=1

slow_query_log=ON
slow_query_log_file=/var/log/mysql-show/mysql-slow.log
long_query_time=1

查询当前mysql数据库是否开启了慢查询日志功能：
show VARIABLES like '%slow%';

查询当前mysql数据库是否开启了binlog日志功能：
show VARIABLES like 'log_%';

查看binlog格式：
show variables like 'binlog_format';

获取binlog文件列表：
show binary logs;

查看当前正在写入的binlog文件：
show master status;

查看master上的binlog：
show master logs;

只查看第一个binlog文件的内容：
show binlog events;

查看指定binlog文件的内容：
show binlog events in 'mysql_bin.000001';

用命令查看binlog日志文件：
mysqlbinlog mysql_bin.000001
不报错的命令：
mysqlbinlog --no-defaults mysql-bin.000001
一是在MySQL的配置/etc/my.cnf中将default-character-set=utf8 修改为 character-set-server = utf8，
但是这需要重启MySQL服务，如果你的MySQL服务正在忙，那这样的代价会比较大。
二是用mysqlbinlog --no-defaults mysql-bin.000004 命令打开
以上命令的输出都看不懂的

输出解码：
mysqlbinlog  --base64-output=decode-rows -v  /var/lib/mysql/mysql_bin.000001|less


```

## 基础知识



### SQL分类
* DDL（Data Definition Languages）
    * 数据定义语言，这些语句定义了不同的数据段、数据库、表、列、索引等数据库对象的定义。
    * 常用的语句关键字主要包括 create、drop、alter等。
* DML（Data Manipulation Language）
    * 数据操纵语句，用于添加、删除、更新和查询数据库记录，并检查数据完整性，
    * 常用的语句关键字主要包括 insert、delete、udpate 和select 等。(增添改查）
* DCL（Data Control Language）
    * 数据控制语句，用于控制不同数据段直接的许可和访问级别的语句。
    * 这些语句定义了数据库、表、字段、用户的访问权限和安全级别。主要的语句关键字包括 grant、revoke 等。


### 数据类型：
* MySQL支持多种类型，大致可以分为三类：数值、日期/时间、字符串(字符)类型。
    - 严格数值数据类型(INTEGER、SMALLINT、DECIMAL和NUMERIC)，以及近似数值数据类型(FLOAT、REAL和DOUBLE PRECISION)。
    - 表示时间值的日期和时间类型为 DATETIME、DATE、TIMESTAMP、TIME和YEAR。
    - 字符串类型指 CHAR、VARCHAR、BINARY、VARBINARY、BLOB、TEXT、ENUM 和 SET。
    - blob text 数据类型慎用

#### blob
* Blob是一个二进制的对象，它是一个可以存储大量数据的容器(如图片，音乐等等)，且能容纳不同大小的数据。
    在MySQL中有四种Blob类型，他们的区别就是可以容纳的信息量不容分别是以下四种:
    * TinyBlob类型  最大能容纳255B的数据
    * Blob类型  最大能容纳65KB的
    * MediumBlob类型  最大能容纳16MB的数据
    * LongBlob类型  最大能容纳4GB的数据
* 如果Blob中存储的文件的大小过大的话，会导致数据库的性能很差。
* 插入Blob类型的数据以及读取Blob类型的数据的方式:
    * 插入Blob类型的数据
          插入Blob类型的数据时，需要注意必须要用 PreparedStatement，因为Blob类型的数据是不能
          够用字符串来拼的，在传入了SQL语句后，就需要去调用PreparedStatement对象中的setBlob(int index , InputStream in)方法来设置传入的的参数，
          其中index表示Blob类型的数据所对应的占位符(?)的位置，而InputStream类型的in表示被插入文件的节点流。
    * 读取Blob类型的数据
          读取Blob类型相对来说比较容易，当获取了查询的结果集之后，使用getBlob()方法读取到Blob
          对象，然后调用Blob的getBinaryStream()方法得到输入流，再使用IO操作进行文件的写入操作即可。


## SQL

### create

* 创建数据库 ：create database zhq; 
* 删除数据库：drop database zhq;
* 显示数据库： SHOW DATABASES;
* 修改密码：ALTER USER "root"@"localhost" IDENTIFIED  BY "你的新密码";
* 删除数据表：DROP TABLE table_name ;
* 判断表中内容为空：SELECT * FROM runoob_test_tbl WHERE runoob_count IS NULL;
* 非空判断：SELECT * from runoob_test_tbl WHERE runoob_count IS NOT NULL;

```mysql

CREATE TABLE IF NOT EXISTS `runoob_tbl`(
   `runoob_id` INT UNSIGNED AUTO_INCREMENT,
   `runoob_title` VARCHAR(100) NOT NULL,
   `runoob_author` VARCHAR(40) NOT NULL,
   `submission_date` DATE,
   PRIMARY KEY ( `runoob_id` )
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

create table example0(
id int,
name varchar(20),
sex boolean
);

create table example2(
stu_id int not null   primary key,
stu_name varchar(20),
stu_sex boolean
);

create table example3(
stu_id int,
stu_name varchar(20),
stu_sex boolean,
primary key(stu_name, stu_sex)
);


```
* 完整的字段包括字段名、数据类型、完整性约束条件
* 最好设置字段的属性为 NOT NULL， 在操作数据库时如果输入该字段的数据为NULL ，就会报错。
* AUTO_INCREMENT 定义列为自增的属性，一般用于主键，数值会自动加1。
* PRIMARY KEY 关键字用于定义列为主键。 您可以使用多列来定义主键，列间以逗号分隔。
* ENGINE 设置存储引擎，CHARSET 设置编码。
* 注意点的问题： 创建 MySql 的表时，表名和字段名外面的符号 ` 不是单引号，



### select

```mysql
SELECT column_name,column_name FROM table_name [WHERE Clause] [LIMIT N][ OFFSET M]

读取符合一定条件的数据
SELECT field1, field2,...fieldN
FROM table_name
WHERE field1 LIKE condition1 [AND [OR]] filed2 = 'somevalue'

SELECT * from runoob_tbl  WHERE runoob_author LIKE '%COM';


select 属性名表 form  表名和视图列表  [where 条件表达式1] [group by 属性名1 [having 条件表达式2]]
                                    [order by 属性名2 [ASC|DESC]]
# 单表查询
select * from <tableName> 但是不能规定属性的显示顺利
select propertyName1, propertyName2 from <tableName>
select * from <tableName> where name = 'zhq';
select * from <tableName> where id in | not in (1,2,3);
select * from <tableName> where age [not] between 15 and 25;
# 当like中不使用通配符的时候，like 与 = 作用一致
select * from <tableName> where name [not] like 'zhq';  
# 通配符  % 可以匹配任意长度，而 _ 只能匹配单个长度，匹配的字符串 单引号 和 双引号 都行
# 查询是null的字段记录
select * from <tableName> where propertyName is [not] null; 
# 多条件查询： and 全部符合，or 只有一个条件符合就行
select distinct <propertyName> from <tableName>  消除重复的属性
# 多个排序条件的时候，先按照第一个条件进行排序，在第一个条件相同的情况下，再按照之后的条件排序，以此类推
select * from <tableName> order by age ASC;

create table employee (
num int primary key,
id int,
name varchar(10),
age int,
sex varchar(2),
adress varchar(30)
)engine=InnoDB default charset=utf8;

insert into employee (num, id ,name, age, sex, adress) values (1,1001,'张三',20,'男','北京');
insert into employee (num, id ,name, age, sex, adress) values (2,1002,"张四",18,"女","上海");
insert into employee (num, id ,name, age, sex, adress) values (3,1003,'张五',19,'男','北京');
insert into employee (num, id ,name, age, sex, adress) values (4,1004,'张六',26,'男','深圳');
insert into employee (num, id ,name, age, sex, adress) values (5,1005,'张七',33,'女','青岛');

create table department (
id int,
d_name varchar(30),
function varchar(30),
d_address varchar(30)
)engine=InnoDB default charset=utf8;

insert into department (id, d_name, function, d_address) values (1001, '科研部', '研发产品', '研发一楼');
insert into department (id, d_name, function, d_address) values (1002, '生产部', '生产产品', '研发二楼');
insert into department (id, d_name, function, d_address) values (1003, '销售部', '销售产品', '研发三楼');
insert into department (id, d_name, function, d_address) values (1005, '后勤部', '保障产品', '研发四楼');


group by 关键字在单独使用时，只能查出每个组的一条记录，使用意义不大
select sex, group_concat(name) from employee group by sex;
select sex, count(sex) from employee group by sex;
# 其他函数 sum() max() min() avg()
having 条件加上限制结果
select sex, count(sex) from employee group by sex having count(sex)>=2;
# 最后显示所有记录的总和
select sex, count(sex) from employee group by sex with rollup;  

# 展示固定条数的记录数
select * from employee limit 2;
limit <初始位置， 记录数>
select * from employee limit 1,2;
select count(*) from employee; 统计一个表中的记录数
select id, count(*) from employee group by id;
select course, avg(score) from grade group by course;

# 连接查询：内连接查询、外连接查询、符合条件查询
# 内连接查询只查询出指定字段取值相同的记录
select num, name, age, sex, function, d_address from employee, department where employee.id = department.id;
# 符合条件查询，加上查询的限制条件
select num, name, age, sex, function, d_address from employee, department where employee.id = department.id and age>24;
左连接查询，可查询出左边表格的所有数据，而右边表格只能查询出匹配的数据；而右连接相反。
select num, name, age, sex, function, d_address from employee left | right join department on employee.id = department.id;
子连接查询
select * from employee where id in (select id from department);
比较运算符  != 和 <> 二者的意思相同
带有 exists 关键字的查询，结果是 true 或者 false
select * from employee where [not] exists (select name from department where id = 1001);
ANY:满足任意一个结果，all：满足所有的结果
select * from computer_stu where score >= any(select score from scholarship);
union关键字：合并之后去除重复记录， union all 合并之后不去除重复记录
select id from employee union select id from department;


select * from employee e where e.id = 1001;  表格取别名，其中e为表的别名
select id as id_id from employee;   字段取别名

正则表达式进行 模糊查询
属性名  regexp  '匹配方式'
select name from <tableName> where name regexp '^l'; 匹配以L开头的名字
select name from <tableName> where name regexp 'c$'; 匹配以c结尾的名字
select name from <tableName> where name regexp '^l..y$'; 匹配以L开头，y结尾的四字字符
select name from <tableName> where name regexp '[ceo]'; 匹配包含c e o 任意一个字符的字符串
select name from <tableName> where name regexp '[^ceo0-9]'; 匹配除了c e o和0-9的任意一个字符的字符串
select name from <tableName> where name regexp 'ic|uc|ab'; 匹配包括其中任意一个的字符串，中间不能够有空格，否则查询错误

```



### insert

* INSERT IGNORE 与INSERT INTO的区别就是INSERT IGNORE会忽略数据库中已经存在 的数据，如果数据库没有数据，就插入新的数据，
    如果有数据的话就跳过这条数据。这样就可以保留数据库中已经存在数据，达到在间隙中插入数据的目的。
* ON DUPLICATE KEY UPDATE  如果存在值，则插入，否则更新值


```mysql

# 插入所有的字段，要么全写，要么不写，字符串类型的数据必须要加上引号
insert into department (id, d_name, function, d_address) values (1005, '后勤部', '保障产品', '研发四楼');
insert into department values (1005, '后勤部', '保障产品', '研发四楼');
# 插入多条数据
insert into department (id, d_name, function, d_address) values (1007, '销售部', '销售产品', '研发三楼'),(1008, '销售部2', '销售产品2', '研发三楼2');
# 将查询出来的结果插入新的表格  
insert into product (name, property) select name, property from medicine;

INSERT INTO runoob_tbl (runoob_title, runoob_author, submission_date) VALUES ("学习 PHP", "菜鸟教程", NOW());





```


### update



### delete

```
1、当你不再需要该表时， 用 drop;
2、当你仍要保留该表，但要删除所有记录时， 用 truncate;
3、当你要删除部分记录时， 用 delete。

删除表内数据：delete from 表名 where 删除条件;
清除表内数据，保存表结构，用 truncate。truncate table 表名;

delete 操作以后，使用 optimize table table_name 会立刻释放磁盘空间，不管是 innodb 还是 myisam;
实例，删除学生表中姓名为 "张三" 的数据： delete from student where T_name = "张三";
实例，释放学生表的表空间： optimize table student;
```




### union

```mysql
SELECT country FROM Websites UNION SELECT country FROM apps ORDER BY country;
```


### join


### join
* JOIN的含义就如英文单词“join”一样，连接两张表，大致分为内连接，外连接，右连接，左连接，自然连接。

笛卡尔积：CROSS JOIN
要理解各种JOIN首先要理解笛卡尔积。笛卡尔积就是将A表的每一条记录与B表的每一条记录强行拼在一起。
所以，如果A表有n条记录，B表有m条记录，笛卡尔积产生的结果就会产生n*m条记录。下面的例子，
t_blog有10条记录，t_type有5条记录，所有他们俩的笛卡尔积有50条记录。有五种产生笛卡尔积的方式如下。
    SELECT * FROM t_blog CROSS JOIN t_type;
    SELECT * FROM t_blog INNER JOIN t_type;
    SELECT * FROM t_blog,t_type;
    SELECT * FROM t_blog NATURE JOIN t_type;
    select * from t_blog NATURA join t_type;

内连接：INNER JOIN
内连接INNER JOIN是最常用的连接操作。从数学的角度讲就是求两个表的交集，从笛卡尔积的角度讲
就是从笛卡尔积中挑出ON子句条件成立的记录。有INNER JOIN，WHERE（等值连接），STRAIGHT_JOIN,
JOIN(省略INNER)四种写法。
    SELECT * FROM t_blog INNER JOIN t_type ON t_blog.typeId=t_type.id;
    SELECT * FROM t_blog,t_type WHERE t_blog.typeId=t_type.id;
    SELECT * FROM t_blog STRAIGHT_JOIN t_type ON t_blog.typeId=t_type.id; --注意STRIGHT_JOIN有个下划线
    SELECT * FROM t_blog JOIN t_type ON t_blog.typeId=t_type.id;

左连接：LEFT JOIN
左连接LEFT JOIN的含义就是求两个表的交集外加左表剩下的数据。依旧从笛卡尔积的角度讲，就是
先从笛卡尔积中挑出ON子句条件成立的记录，然后加上左表中剩余的记录。
SELECT * FROM t_blog LEFT JOIN t_type ON t_blog.typeId=t_type.id;


右连接：RIGHT JOIN
同理右连接RIGHT JOIN就是求两个表的交集外加右表剩下的数据。再次从笛卡尔积的角度描述，
右连接就是从笛卡尔积中挑出ON子句条件成立的记录，然后加上右表中剩余的记录。
SELECT * FROM t_blog RIGHT JOIN t_type ON t_blog.typeId=t_type.id;

外连接：OUTER JOIN
外连接就是求两个集合的并集。从笛卡尔积的角度讲就是从笛卡尔积中挑出ON子句条件成立的记录，
然后加上左表中剩余的记录，最后加上右表中剩余的记录。
另外MySQL不支持OUTER JOIN，但是我们可以对左连接和右连接的结果做UNION操作来实现。
    SELECT * FROM t_blog LEFT JOIN t_type ON t_blog.typeId=t_type.id
    UNION
    SELECT * FROM t_blog RIGHT JOIN t_type ON t_blog.typeId=t_type.id;

USING子句

MySQL中连接SQL语句中，ON子句的语法格式为：table1.column_name = table2.column_name。
当模式设计对联接表的列采用了相同的命名样式时，就可以使用 USING 语法来简化 ON 语法，格式为：USING(column_name)。
所以，USING的功能相当于ON，区别在于USING指定一个属性名用于连接两个表，而ON指定一个条件。
另外，SELECT *时，USING会去除USING指定的列，而ON不会。实例如下。

SELECT * FROM t_blog INNER JOIN t_type USING(typeId);
    ERROR 1054 (42S22): Unknown column 'typeId' in 'from clause'
    SELECT * FROM t_blog INNER JOIN t_type USING(id); -- 应为t_blog的typeId与t_type的id不同名，无法用Using，这里用id代替下

自然连接：NATURE JOIN

自然连接就是USING子句的简化版，它找出两个表中相同的列作为连接条件进行连接。有左自然连接，
右自然连接和普通自然连接之分。在t_blog和t_type示例中，两个表相同的列是id，所以会拿id作为连接条件。
另外千万分清下面三条语句的区别 。
自然连接:SELECT * FROM t_blog NATURAL JOIN t_type;
笛卡尔积:SELECT * FROM t_blog NATURA JOIN t_type;
笛卡尔积:SELECT * FROM t_blog NATURE JOIN t_type;

* 内连接与外连接的区别
　　* 内连接,显示两个表中有联系的所有数据;
　　* 左链接,以左表为参照,显示所有数据;
　　* 右链接,以右表为参照显示数据;



### order by
```mysql
# 升序排列：
SELECT * from runoob_tbl ORDER BY submission_date ASC;
# 降序排列：
SELECT * from runoob_tbl ORDER BY submission_date DESC;
```


### group by
```mysql
# 使用 GROUP BY 语句 将数据表按名字进行分组，并统计每个人有多少条记录
SELECT name, COUNT(*) FROM employee_tbl GROUP BY name;

```


### 正则表达式
```mysql
# 查找name字段中以'st'为开头的所有数据：
SELECT name FROM person_tbl WHERE name REGEXP '^st';
# 查找name字段中以'ok'为结尾的所有数据：
SELECT name FROM person_tbl WHERE name REGEXP 'ok$';
# 查找name字段中包含'mar'字符串的所有数据：
SELECT name FROM person_tbl WHERE name REGEXP 'mar';
# 查找name字段中以元音字符开头或以'ok'字符串结尾的所有数据：
SELECT name FROM person_tbl WHERE name REGEXP '^[aeiou]|ok$';


```

### table 操作
```mysql
# 查看表结构
describe <tableName>  
desc <tableName>

# 查看表创立的详细信息
show create table <tableName>  

# 修改表的名字
alter table <originName> rename <newName>   
# 修改字段数据类型
alter table <tableName> modify <propertyName> <dataType>  
# 修改字段名 字段改名之后，会有部分约束条件消失，所以需要加上约束条件，查看表的状态
alter table <tableName> change <originPropertyName> <newPropertyName> <newPropertyDataType>  
# 表中添加字段
alter table <tableName> add <propertyName> <propertyDataType> [完整性约束条件] [first | after <propertyName2>]
alter table <tableName> drop <propertyName> 删除表中已经存在的字段
修改字段的排列位置
alter table <tableName> modify <propertyName1> <dataType1> [first | after] <propertyName2>
alter table <tableName> engine=MyISAM  更改数据引擎
# 删除外键约束
alter table <tableName> drop foreign key <alias>
drop table <tableName> 删除没有被关联的普通表
删除存在外键关联的表格时，需要首先删除外键约束，然后再执行删除表格的语句
```

### alter
```mysql
# 修改表名： 
ALTER TABLE testalter_tbl RENAME TO alter_tbl;
```


### 事务

* 事务四大特征(ACID)
    * 原子性(A)：事务是最小单位，不可再分
    * 一致性(C)：事务要求所有的DML语句操作的时候，必须保证同时成功或者同时失败
    * 隔离性(I)：事务A和事务B之间具有隔离性
    * 持久性(D)：是事务的保证，事务终结的标志(内存的数据持久到硬盘文件中)
* 事务隔离级别
    * 未提交读（Read uncommitted）
    * 已提交读(Read committed)
    * 可重复读(Repeatable read)
    * 可序列化(Serializable)。

* 更新丢失：最后的更新覆盖了其他事务之前的更新，而事务之间并不知道，发生更新丢失。更新丢失，可以完全避免，应用对访问的数据加锁即可。
* 脏读：(针对未提交的数据)一个事务在更新一条记录，未提交前，第二个事务读到了第一个事务更新后的记录，那么第二个事务就读到了脏数据，会产生对第一个未提交数据的依赖。一旦第一个事务回滚，那么第二个事务读到的数据，将是错误的脏数据。
* 不可重复读：（读取数据本身的对比）一个事务在读取某些数据后的一段时间后，再次读取这个数据，发现其读取出来的数据内容已经发生了改变，就是不可重复读。
* 幻读：（读取结果集条数的对比）一个事务按相同的查询条件查询之前检索过的数据，确发现检索出来的结果集条数变多或者减少（由其他事务插入、删除的），类似产生幻觉。

* MySQL 默认的级别是:Repeatable read 可重复读。
* 查看事务的隔离级别：show variables like '%isolation%';


* 用 BEGIN, ROLLBACK, COMMIT 来实现
    - BEGIN 开始一个事务
    - ROLLBACK 事务回滚
    - COMMIT 事务确认
* 直接用 SET 来改变 MySQL 的自动提交模式
    - SET AUTOCOMMIT=0 禁止自动提交
    - SET AUTOCOMMIT=1 开启自动提交
* 事务控制
    - BEGIN 或 START TRANSACTION；显式地开启一个事务；
    - COMMIT；也可以使用COMMIT WORK，不过二者是等价的。COMMIT会提交事务，并使已对数据库进行的所有修改称为永久性的；
    - ROLLBACK；有可以使用ROLLBACK WORK，不过二者是等价的。回滚会结束用户的事务，并撤销正在进行的所有未提交的修改；
    - SAVEPOINT identifier；SAVEPOINT允许在事务中创建一个保存点，一个事务中可以有多个SAVEPOINT；
    - RELEASE SAVEPOINT identifier；删除一个事务的保存点，当没有指定的保存点时，执行该语句会抛出一个异常；
    - ROLLBACK TO identifier；把事务回滚到标记点；
    - SET TRANSACTION；用来设置事务的隔离级别。
    - InnoDB 存储引擎提供事务的隔离级别有 READ UNCOMMITTED、READ COMMITTED、REPEATABLE READ 和 SERIALIZABLE。


### 索引
* 索引由数据库表中的一列或者多列组合而成，其目的是提高数据库中的查询速度
```mysql
# 在创建表的时候创建索引
create table index1 (
id int,
name varchar(20),
sex boolean,
index(id)
);
# 查看建立的信息
show create table index1\G;   
# 单列索引
create table index4 (
id int,
subject  varchar(20),
index index4_st(subject(10))
);

# 创建多列索引
create table index5 (
id int,
name  varchar(20),
sex varchar(5),
index index5(name, sex)
);

# 在已经存在的表上创建索引：
create index7_id on table example0(id);
# 创建唯一性索引
create unique index8_id on example1(id);
# 通过alter table语句也可以修改
alter table index1 add index index1_name(name(10));
# 删除索引： 
drop index <indexName> on <tableName>


# 展示表的索引
show index from employees.employees;

```



### 视图
* 视图是在原有的表或者视图的基础上重新定义的虚拟表，可以从原有的表上选取对用户有用的信息起到类似筛选的作用
```mysql
create view <viewName> as select * from <tableName>
create view <viewName> as select (property1, property2, ...) from <tableName>

# 两个及以上的表中创建视图 ：在department 表和 worker 表上
create algorithm = merge view <viewName> worker_view(name, department, sex)
as select name, department
from worker, department  where worker.id = department.id
with local check option;

# 查看视图：
desc <viewName>
show table status like <viewName>
show create view
# 修改或创建视图
create or replace algorithm = [temptable] view <viewName> <propertyList>
as select <propertyList> from <tableName>
# 仅仅是修改视图
alter view [后面的与其他几个命令一致]
# 删除视图：
drop view if exists <viewName1, viewName2>

```

### 触发器

```mysql
创建单个执行语句的触发器
create trigger <触发器名>  before|after <触发事件> on <tableName> for each row <执行语句>
创建多个执行语句的触发器
create trigger <触发器名>  before|after <触发事件> on <tableName> for each row
begin
<执行语句>
end

create table trigger_time (
exec_time datetime
);

create table student (
id int primary key,
name varchar(10)
);

create trigger trigger1 before insert on student for each row insert into trigger_time values(now());
show triggers;  查询触发器
drop trigger <triggerName> 删除触发器
```



### 外键

```mysql

CREATE TABLE IF NOT EXISTS `class`(
   `runoob_id` INT UNSIGNED AUTO_INCREMENT,
   `runoob_title` VARCHAR(100) NOT NULL,
   `runoob_author` VARCHAR(40) NOT NULL,
   `submission_date` DATE,
   PRIMARY KEY ( `runoob_id` )
)ENGINE=InnoDB DEFAULT CHARSET=utf8;


# 外键操作例子
SET FOREIGN_KEY_CHECKS = 0;
# 示例操作代码
create table if not exists teacher(
  id int primary key auto_increment,
  name varchar(20)
);
insert into teacher(name) value('ff'),('ff1'),('ff2');

create table if not exists course (
  id int primary key auto_increment,
  name varchar(20),
  teacher_id int unique,
  foreign key(teacher_id) references teacher(id)
  on delete cascade
  on update cascade
);
insert into course(teacher_id,name) value(2,'ee'),(1,'ee1'),(3,'ee2');
# 测试命令
delete from  teacher where  id=1;

```






### 运算符
```mysql
select a, a+3, a/3, a div 3 from t1;
create table t1(
a int
)engine=InnoDB default charset=utf8;

# 不等于 <>  !=   等于 = 或 <=>
# 操作符都不能用来判断null，如果需要判断，则使用 is null, is not null
# 通配符：_代表单个字符，% 代表任意多个字符
# && 与 and  表示与操作符  || 和 or  表示或运算
# 直接查看运行结果  select 1||null, null||null, 0||null;


```


### 函数
```mysql

select abs(-0.5), pi(), abs(0.5);
select rand(), rand(), rand(2), rand(2);
select concat('bei', 'jing'), concat_ws('-','bei','jing');
select repeat('mysql', 2);
# 日期和时间函数
select curdate(), current_date(), curtime(), current_time();
# now() 和 current_timestamp()都表示系统当前的日期和时间
# 将exp执行count次，返回执行的时间
select benchmark(count, exp); 


```


### 存储过程
* 存储过程和函数是在mysql服务其中执行的， 已经写好的一段sql语句
```mysql
# 创建存储过程：
create procedure num_from_employee(in emp_id int, out count_num int)
reads sql data
begin
select count(*) into count_num from employee where id = emp_id;
end

# 但是实际运行时，需要临时将结束符号替换
delimiter &&
create procedure num_from_employee(in emp_id int, out count_num int)
reads sql data
begin
select count(*) into count_num from employee where id = emp_id;
end&&
delimiter ;

# 创建函数
create function name_from_employee(emp_id int)
returns varchar(10)
begin
return (select name from employee where id = emp_id);
end
# 但是实际运行时
delimiter &&
create function name_from_employee(emp_id int)
returns varchar(10)
begin
return (select name from employee where id = emp_id);
end&&
delimiter ;
声明变量 declare <variableName> int default 10;
赋值变量 set mysql = 3;
声明光标：declare <cursorName> cursor for select name, age from employee;
打开光标：open <cursorName>
使用光标：fetch <cursorName> into emp_name, emp_age;
关闭：close

loop :循环执行，leave：跳出循环，iterate：跳出本次循环
存储过程：call调用，存储函数：与内部函数的使用方法一致，但是执行是需要execute权限
调用储存过程： call num_from_employee(1002, @shit);
查询储存过程或者函数
show procedure status like 'num_from_employee'\G;
show create procedure num_from_employee\G;  更加详细一些
show function  status like 'name_from_employee'\G;

修改存储过程
alter procedure num_from_employee
modifies sql data
sql security invoker;
删除：drop procedure | function <name>;
```


### 用户管理
```mysql
# mysql 数据库下存储权限表
# 新建用户
create user 'test1'@'localhost' identified by 'test1';
# 用户名：test1 主机名：localhost  密码：test1

(2) insert mysql.user(host, user, password) values(...)
执行完成之后使用户生效 flush privileges;

(3) grant语句

删除用户：drop user 'test1'@'localhost'
或者  delete from mysql.user where host = <hostName> and user = <userName>;
修改root用户的密码： mysqladmin -u username -p password "new_password"
root用户可以修改本身的密码以及其他账户的密码
自身修改  set password password("new_password");
修改其他用户的密码  set password for 'test1'@'localhost'=password("test");
grant select on *.* to 'test3'@'localhost' identified by 'mytest3';
grant  授权 revoke 收回权限
查看用户的授权  show grants for 'test1'@'localhost';


```

========================      Chapter18   性能优化     ==========================
show status like 'connections';  查询数据库的连接次数
分析查询语句：
explain select * from employee\G;
建立索引：create index index_name on student(name);
建立多列索引：create index index_birth_department on student(birth, department);
多列索引使用时，只有查询条件中使用了这个索引中的第一个字段时，才会起作用。





















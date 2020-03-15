

##
```mysql
# 5.7.29
SHOW VARIABLES LIKE 'innodb_version'\G  
SHOW VARIABLES LIKE 'innodb_%io_threads'\G
SHOW ENGINE INNODB STATUS\G
# 输出128M
SHOW VARIABLES LIKE 'innodb_buffer_pool_size'\G
SHOW TABLE STATUS LIKE 'order%'\G


# 指定执行使用的索引
SELECT * FROM t USE INDEX(a) WHERE a=1 AND b=2;
SELECT * FROM t FORCE INDEX(a) WHERE a=1 AND b=2;

```

* 缓冲池中页大小默认16KB
* 优化的LRU算法， midpoint insertion strategy, innodb_old_blocks_time
* checkpoint 机制将脏页刷回磁盘
    - sharp checkpoint
    - fuzzy checkpoint


* redo log buffer 重读日志缓冲
* 表的行格式： 
    - compact 
    - redundant: 对于varchar类型的NULL值，不占用任何存储空间，而char类型的NULL值需要占用空间
    - dynamic 
    - compressed  zlib算法进行压缩

### SQL语句的执行过程
MySQL 主要分为 Server 层和引擎层，Server 层主要包括连接器、查询缓存、分析器、优化器、执行器，同时还有一个日志模块（binlog），这个日志模块所有执行引擎都可以共用,redolog 只有 InnoDB 有。
•引擎层是插件式的，目前主要包括，MyISAM,InnoDB,Memory 等。
•SQL 等执行过程分为两类，一类对于查询等过程如下：权限校验---》查询缓存---》分析器---》优化器---》权限校验---》执行器---》引擎
•对于更新等语句执行流程如下：分析器----》权限校验----》执行器---》引擎---redo log prepare---》binlog---》redo log commit



### 锁

* 共享锁（S Lock）
* 排它锁（X Lock）

* 一致性的非锁定读  通过InnoDB行多版本控制读取当前执行时间数据库行的数据
* 一致性锁定读
    - select ... for update：对读取的记录加X锁，其他事物不能对已锁定的行加任何锁。
    - select ... lock in share mode：对读取的行加S锁，其他事物可以向被锁定的行加S锁，但是如果加X锁，会被堵塞。
* 多版本并发控制(MVCC)

* 行锁的三种算法
    - record lock ： 单个行记录上的锁，锁索引记录
    - gap lock：间隙锁，锁定一个范围，但不包含记录本身
    - next-key lock ： gap lock + record lock 锁定一个范围，并锁定记录本身
* 默认的隔离级别： read repeatable，采用 next-key lock 算法，避免了不可重复读的现象。
* wait for graph （等待图）进行死锁检测，检测到死锁时，回滚undo量最小的事务

* 锁升级：将当前所得粒度升高，比如将1000个行锁升级为一个页锁，或者将页锁升级为表锁。
  想避免锁的开销。

### 事务
* 事务的隔离性由锁来实现。原子性、一致性、持久性由数据库的redo log 和 undo log来实现
    - redo log 重做日志，保证事务的原子性和持久性，恢复提交事务修改的页操作
    - undo log 保证一致性，回滚记录到某个特定版本
        - undo是将数据库逻辑的恢复到原本的样子，实现MVCC

* 支持分布式事务
    - XA事务：资源管理器+事务管理器+应用程序
    - 两阶段提交   prepare + commit/rollback
    - java JTA 支持 MySQL分布式事务
    - binlog 和 InnoDB之间采用XA事务

* 长事务：将其分解成几个小事务来执行，发生故障时所需要的恢复时间短







#### latch
```mysql
SHOW ENGINE INNODB MUTEX;
```


* lock



## 实验
```mysql
# 分区
CREATE TABLE `m_test_db`.`Order` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `partition_key` INT NOT NULL,
  `amt` DECIMAL(5) NULL,
  PRIMARY KEY (`id`, `partition_key`)) PARTITION BY RANGE(partition_key) PARTITIONS 5( PARTITION part0 VALUES LESS THAN (201901),  PARTITION part1 VALUES LESS THAN (201902),  PARTITION part2 VALUES LESS THAN (201903),  PARTITION part3 VALUES LESS THAN (201904),  PARTITION part4 VALUES LESS THAN (201905)) ;

#创建一个5个hash分区的myisam表
CREATE TABLE `test`.`partition_t1`(  
  `id` INT UNSIGNED NOT NULL,
  `username` VARCHAR(30) NOT NULL,
  `email` VARCHAR(30) NOT NULL,
  `birth_date` DATE NOT NULL
) ENGINE=MYISAM
PARTITION BY HASH(MONTH(birth_date))
PARTITIONS 5;

CREATE TABLE mytest (
t1 VARCHAR(10),
t2 VARCHAR(10),
t3 CHAR(10),
t4 VARCHAR(10)
) ENGINE=INNODB, CHARSET=utf8, ROW_FORMAT=COMPACT;

INSERT INTO mytest VALUES ('a','bb','bb','ccc');
INSERT INTO mytest VALUES ('d','bb','bb','ccc');
INSERT INTO mytest VALUES ('e','bb','bb','ccc');

SHOW PLUGINS\G


```

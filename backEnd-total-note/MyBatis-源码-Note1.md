## chapter1  实战1 MyBatis简介
ibatis3.0 版本就是 MyBatis
工具：JDBC -> Dbutils -> jdbcTemplate
框架：
* Hibernate  全自动ORM(object relation mapping) 全自动全映射、HQL进行查询的定制化
* MyBatis
半自动化的ORM框架，简化了JDBC的一些固定步骤。
#### XML方式


### mybatis自动生成代码
使用example的坏处是新手不知道索引是怎么建立的


#### 作用域
sqlSessionFactory  作用域为应用级别：  因为作为一个bean被spring 管理
sqlSession 可以认为是线程级别的




## chapter2  实战2

### 自己写一个插件
* 实现interceptor接口
* 定义对谁做plugin

### 任务
* 写一个interceptor，将sql 和 parameters 打印出来
* 自己写一个分页的interceptor  plugin

### mapper文件
namespace  区分和映射sql 的
resultMap  类型映射的

batch 批量操作
* 循环  insert，性能低，每次都要DB操作
* <foreach>  拼接sql， 但是SQL的长度有限制，
MySQL长度有限制，一般是4M
写的批量操作方法需要检查大小，（一般情况下，性能最高）
* excutorType  BATCH  ，执行完成之后自增主键没有返回
*

### 分页
* 物理分页
  - 直接拼接SQL
  - pageHelper 分页插件
  -
* 逻辑分页
*

## chapter3  实战3
* 嵌套查询：效率低
* join查询：效率高

* 嵌套查询
* 嵌套结果


## chapter4  源码1
读配置文件，生成configuration

configxml -> configuration -> sqlSessionFactory -> sqlSession -> mapper -> DB

JDBC学习


* 解析mybatis-config.XML
  - XMLConfigBuilder.parseConfiguration()
  -  configuration.mappedStatements
* mapper 和  mapper.xml 怎样映射起来的
* mapper接口操作数据库，怎样操作的？
  - mapperProxy

主要是完成mapper接口与mapping的关联映射
mapper接口对开发者友好使用，对底层的sql进行一个映射

重构的点：
（1）configuration 进行重构
（2）jdbc返回的类型进行泛型

executor
* StatementHandler
* ResultSetHandler


* mysql 一级缓存 （默认开启）
* mysql 二级缓存 （非常鸡肋，不使用）
  - 多个sqlsession共享的缓存
  - 存在的问题
    -  多表联合查询存在问题
    -  基于namespace进行操作的
    -  更新策略也存在问题

## chapter5  源码
事务的实现
* JDBC中基于connection进行事务的管理
* ManagedTransaction 由容器进行管理时使用
* transFactoryManagement
* MyBatis自带事务，利用了JDBC事务，也提供了容器的实现

与spring整合
* MapperScannerConfigurer







一级缓存：同一个sqlsession里面存在，缓存用map存储。
      key:sqlsession.hashcode+statementId+sql value:查询出来的对象。

二级缓存：不同sqlsession之间共享查询结果集。
1、  在配置文件SqlMapConfig.xml中加入以下内容（开启二级缓存总开关）：cacheEnabled设置为 true
2、   每个mapper里面的每个sql可以配置useCache 来开启和关闭二级缓存。
————————————————
版权声明：本文为CSDN博主「xiaoguigui520」的原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/xiaoguigui520/article/details/82590395






### 源码中的关键类
MappedStatement表示的是XML中的一个SQL。类当中的很多字段都是SQL中对应的属性

## chapter1 实战1 MyBatis简介

ibatis3.0 版本就是 MyBatis 工具：JDBC -> Dbutils -> jdbcTemplate 框架：

* Hibernate 全自动ORM(object relation mapping) 全自动全映射、HQL进行查询的定制化
* MyBatis 半自动化的ORM框架，简化了JDBC的一些固定步骤。

#### XML方式

### mybatis自动生成代码

使用example的坏处是新手不知道索引是怎么建立的

#### 作用域

sqlSessionFactory 作用域为应用级别： 因为作为一个bean被spring 管理 sqlSession 可以认为是线程级别的

## chapter2 实战2

### 自己写一个插件

* 实现interceptor接口
* 定义对谁做plugin

### 任务

* 写一个interceptor，将sql 和 parameters 打印出来
* 自己写一个分页的interceptor plugin

### mapper文件

namespace 区分和映射sql 的 resultMap 类型映射的

batch 批量操作

* 循环 insert，性能低，每次都要DB操作
* <foreach>  拼接sql， 但是SQL的长度有限制，

MySQL长度有限制，一般是4M 写的批量操作方法需要检查大小，（一般情况下，性能最高）

* excutorType BATCH ，执行完成之后自增主键没有返回
*

### 分页

* 物理分页
    - 直接拼接SQL
    - pageHelper 分页插件
    -
* 逻辑分页
*

## chapter3 实战3

* 嵌套查询：效率低
* join查询：效率高

* 嵌套查询
* 嵌套结果

## chapter4 源码1

读配置文件，生成configuration

configxml -> configuration -> sqlSessionFactory -> sqlSession -> mapper -> DB

JDBC学习

* 解析mybatis-config.XML
    - XMLConfigBuilder.parseConfiguration()
    - configuration.mappedStatements
* mapper 和 mapper.xml 怎样映射起来的
* mapper接口操作数据库，怎样操作的？
    - mapperProxy

主要是完成mapper接口与mapping的关联映射 mapper接口对开发者友好使用，对底层的sql进行一个映射

重构的点： （1）configuration 进行重构 （2）jdbc返回的类型进行泛型

executor

* StatementHandler
* ResultSetHandler


* mysql 一级缓存 （默认开启）
* mysql 二级缓存 （非常鸡肋，不使用）
    - 多个sqlsession共享的缓存
    - 存在的问题
        - 多表联合查询存在问题
        - 基于namespace进行操作的
        - 更新策略也存在问题

## chapter5 源码

事务的实现

* JDBC中基于connection进行事务的管理
* ManagedTransaction 由容器进行管理时使用
* transFactoryManagement
* MyBatis自带事务，利用了JDBC事务，也提供了容器的实现

与spring整合

* MapperScannerConfigurer

一级缓存：同一个sqlsession里面存在，缓存用map存储。 key:sqlsession.hashcode+statementId+sql value:查询出来的对象。

二级缓存：不同sqlsession之间共享查询结果集。 1、 在配置文件SqlMapConfig.xml中加入以下内容（开启二级缓存总开关）：cacheEnabled设置为 true 2、
每个mapper里面的每个sql可以配置useCache 来开启和关闭二级缓存。 ———————————————— 版权声明：本文为CSDN博主「xiaoguigui520」的原创文章，遵循 CC 4.0 BY-SA
版权协议，转载请附上原文出处链接及本声明。 原文链接：https://blog.csdn.net/xiaoguigui520/article/details/82590395

### 源码中的关键类

MappedStatement表示的是XML中的一个SQL。类当中的很多字段都是SQL中对应的属性

### sqlSession

```java

public class DefaultSqlSession implements SqlSession {
    // 主要的成员变量
    private final Configuration configuration;
    private final Executor executor;
```

### mapper 和 mapper.xml的对应过程

（1）将所有的xml文件load到configuration

###

配置顺序

```
<?xml version="1.0" encoding="UTF-8"?>
<configuration><!--配置-->
	<properties/><!--属性-->
	<settings/><!--设置-->
	<typeAliases/><!--类型别名-->
	<typeHandlers/><!--类型处理器-->
	<objectFactory/><!--对象工厂-->
	<plugins/><!--插件-->
	<environments><!--配置环境-->
		<environment><!--环境变量-->
		<transactionManager/><!--事务管理器-->
			<dataSource/><!--数据源-->
		</environment>
	</environments>
	<databaseidProvider/><!--数据库厂商标识-->
	<mappers/><!--映射器-->
</configuration>

```

```java
(1)XMLConfigBuilder.parse()
private void parseConfiguration(XNode root){
        try{
        //issue #117 read properties first
        propertiesElement(root.evalNode("properties"));
        Properties settings=settingsAsProperties(root.evalNode("settings"));
        loadCustomVfs(settings);
        loadCustomLogImpl(settings);
        typeAliasesElement(root.evalNode("typeAliases"));
        pluginElement(root.evalNode("plugins"));
        objectFactoryElement(root.evalNode("objectFactory"));
        objectWrapperFactoryElement(root.evalNode("objectWrapperFactory"));
        reflectorFactoryElement(root.evalNode("reflectorFactory"));
        settingsElement(settings);
        // read it after objectFactory and objectWrapperFactory issue #631
        environmentsElement(root.evalNode("environments"));
        databaseIdProviderElement(root.evalNode("databaseIdProvider"));
        typeHandlerElement(root.evalNode("typeHandlers"));
        mapperElement(root.evalNode("mappers"));
        }catch(Exception e){
        throw new BuilderException("Error parsing SQL Mapper Configuration. Cause: "+e,e);
        }
        }

        （2）MapperProxy 作为所有mapper的实现类
        最终会调用sqlSession的方法，其实就是executor
        key： 命名空间+ID

        通过一个接口去实现功能，没有实现类，不可思议
        接口->SQL 一一对应

        TestMapper 对开发者友好使用，对底层的SQL进行映射






```

XmlConfigBuilder

```sql



```

## mybatis缓存

Eh Cache 是一个纯牌的Java 进程内的缓存框架，具有快速、精干等特点

====================== MyBatis 学习知识点 ============================ resultMap 中一对一关系与一对多关系的配置

```xml

<resultMap id="getStudentInfoResultMap" type="EStudent">
    <id property="id" column="a_id"/>
    <result property="name" column="a_name"/>
    <!-- 一对一关系 -->
    <association property="myClass" javaType="EClass">
        <id property="id" column="b_id"/>
        <result property="name" column="b_name"/>
    </association>
    <!-- 一对多关系 -->
    <collection property="teachers" ofType="ETeacher">
        <id property="id" column="c_id"/>
        <result property="name" column="c_name"/>
        <result property="classId" column="c_classId"/>
    </collection>
</resultMap>
```

mybatis generator mybatis plus tk

#### mybaits 与 JDBC的区别

JDBC是Java提供的一个操作数据库的API；
MyBatis是一个支持普通SQL查询，存储过程和高级映射的优秀持久层框架。MyBatis消除了几乎所有的JDBC代码和参数的手工设置以及对结果集的检索封装。MyBatis可以使用简单的XML或注解用于配置和原始映射，将接口和Java的POJO（Plain
Old Java Objects，普通的Java对象）映射成数据库中的记录。

JAVA程序通过JDBC链接数据库，这样我们就可以通过SQL对数据库进行编程。 JAVA链接数据库大致分为5步。 1.使用JDBC编程需要链接数据库，注册驱动和数据库信息。 2.操作Connection，打开Statement对象。
3.通过Statement执行SQL语句，返回结果放到ResultSet对象。 4.使用ResultSet读取数据。 5.关闭数据库相关的资源。

问题四，数据库链接创建、释放频繁造成系统资源浪费从而影响系统性能，如果使用数据库链接池可解决此问题。 解决方式：在 mybatis-config.xml 中，配置数据链接池，使用连接池管理数据库链接。 😈 当然，即使不使用 MyBatis
，也可以使用数据库连接池。 另外，MyBatis 默认提供了数据库连接池的实现，只是说，因为其它开源的数据库连接池性能更好，所以一般很少使用 MyBatis 自带的连接池实现。

## 分页

MyBatis的分页方式有物理分页和逻辑分页，所谓物理分页是指直接从数据库中拿出我们需要的数据，例如在Mysql中使用limit。而逻辑分页是指从数据库中拿出所有符合要求的数据，然后再从这些数据中拿到我们需要的分页数据。

* 物理分页
    * limit (pageNum-1)*pageSize , pageSize [pageNum表示取第几页的数据，pageSize表示每一页中的数据数量]
        * 虽然是物理分页，但是对于深分页来说，MySQL的新能会变差。比如 select * from test where val=4 limit 300000,5;
            * 需要查询300005次索引节点，查询300005次聚簇索引的数据，最后再将结果过滤掉前300000条，取出最后5条。MySQL耗费了大量随机I/O在查询聚簇索引的数据上，
            * 而有300000次随机I/O查询到的数据是不会出现在结果集当中的。
    * 在自动生成的example对象中，加入两个成员变量start、和limit
    * 修改 Example 的实现方式，
```java
public class Example {
    protected Integer leftLimit;
    protected Integer limitSize;

    public Integer getLeftLimit() {
        return leftLimit;
    }

    public void setLeftLimit(Integer leftLimit) {
        this.leftLimit = leftLimit;
    }

    public Integer getLimitSize() {
        return limitSize;
    }

    public void setLimitSize(Integer limitSize) {
        this.limitSize = limitSize;
    }
}
```

* 打开mapper.xml文件里面对应位置设置配置.例如在selectByExample方法中配置,添加条件
```xml
<if test="leftLimit != null &amp;&amp; limitSize!= null">
    limit ${leftLimit},${limitSize}
</if>

```



* 逻辑分页
    * RowBounds分页
        * SQL查询的是所有的数据，然后在业务层对数据进行可截取(即对ResultSet结果集进行分页)，该方式比较占用内存，在大数据量的情况下不推荐使用
        * RowBounds对象有2个属性，offset和limit。offset表示起始行数，limit表示需要的数据行数，他们结合起来就表示从第offset+1行开始，取limit行的数据。

```java
// example 的限制条件中，需要带有id的限制属性
public class Test {
    public List<UserRoundFairyDO> queryByExampleWithLimit(UserRoundFairyDOExample example, Integer limit) {
        if (example == null || limit == null || limit <= 0) {
            throw new FatalException(ErrorCode.BAD_PARAMS);
        }
        String orderByClause = example.getOrderByClause();
        if (StringUtils.isEmpty(orderByClause)) {
            orderByClause = "limit " + limit;
        } else {
            orderByClause = orderByClause + " limit " + limit;
        }
        example.setOrderByClause(orderByClause);
        return userRoundFairyDOMapper.selectByExample(example);
    }
}

```

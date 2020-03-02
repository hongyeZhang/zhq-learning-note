

#### mybaits 与 JDBC的区别

JDBC是Java提供的一个操作数据库的API；
MyBatis是一个支持普通SQL查询，存储过程和高级映射的优秀持久层框架。MyBatis消除了几乎所有的JDBC代码和参数的手工设置以及对结果集的检索封装。MyBatis可以使用简单的XML或注解用于配置和原始映射，将接口和Java的POJO（Plain Old Java Objects，普通的Java对象）映射成数据库中的记录。

JAVA程序通过JDBC链接数据库，这样我们就可以通过SQL对数据库进行编程。
JAVA链接数据库大致分为5步。
1.使用JDBC编程需要链接数据库，注册驱动和数据库信息。
2.操作Connection，打开Statement对象。
3.通过Statement执行SQL语句，返回结果放到ResultSet对象。
4.使用ResultSet读取数据。
5.关闭数据库相关的资源。


问题四，数据库链接创建、释放频繁造成系统资源浪费从而影响系统性能，如果使用数据库链接池可解决此问题。
解决方式：在 mybatis-config.xml 中，配置数据链接池，使用连接池管理数据库链接。
😈 当然，即使不使用 MyBatis ，也可以使用数据库连接池。
另外，MyBatis 默认提供了数据库连接池的实现，只是说，因为其它开源的数据库连接池性能更好，所以一般很少使用 MyBatis 自带的连接池实现。

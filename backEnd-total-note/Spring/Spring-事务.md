
## 源码笔记
* 事务管理器
    * 基础接口 PlatformTransactionManager
    * 基本抽象 AbstractPlatformTransactionManager
    * 使用 JDBC 或者 myBatis时，DataSourceTransactionManager
    * 使用不同的持久化方式，有不同的 TransactionManager

* 事务同步管理器（spring事务管理的基石）
    * TransactionSynchronizationManager
    * ThreadLocal 为不同事务线程提供了独立的资源副本，维护事务配置的属性和运行状态信息
    

* 事务传播（spring4 企业开发实战  P376）
    * TransactionDefinition
    * 7种事务传播行为，默认的事务传播行为  propagation_required  
    * propagation_required  如果没有事务，则新建；如果已经有事务，则加入

* 编程式事务管理
    * TransactionTemplate 线程安全的

* @Transactional
     * 建议添加到业务实现类的方法上，而不是添加到接口的方法上，因为注解不会被继承，容易造成一些潜在的问题。
     * 如果 proxy-target-class = true 时，就会造成响应的问题  
     * 可以在其中配置使用不同的事务管理器，写入指定的事务管理器名字就可以，每个事务管理器都可以绑定一个独立的数据源
     * 在相同线程中互相嵌套调用的事务方法工作在相同的事务中。如果互相嵌套调用的方法工作在不同的线程中，则不同线程下的事务方法工作在独立的事务中。

* AOP事务的注意事项
    * spring事务管理基于接口代理或者动态字节码技术，通过AOP实施事务增强。
    * 使用JDK接口代理的方法只能是 public 或者 public final 
    * 使用CGLib字节码动态代理的方案是通过扩展被增强类，动态产生子类进行AOP增强织入的, final static private 方法都不行
    * 如果不能被事务增强的方法工作在无事务的上下文中，则由于spring默认的传播行为，被调用的方法也会工作在无事务的状态下。
    * 能够从当前事务上下文中获取绑定的数据连接的工具类 DataSourceUtils 
     


    


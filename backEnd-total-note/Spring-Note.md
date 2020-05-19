
# Spring学习笔记

轻量级、一站式、开发框架
核心技术：控制反转Inversion of Control(IoC，控制反转)
Aspect-Oriented Programming(AOP，面向切面编程)

1 IoC技术
控制：对象的依赖关系Dependency Injection(DI,依赖注入)
IoC容器实现依赖注入，对象的创建与组合


2 AOP 面向切面编程
aspect-oriented Programming
日志
业务逻辑与非业务逻辑分离
IoC容器：对象创建、装配；声明周期管理、上下文环境等
AOP：
数据访问：JDBC支持、事务管理、ORM整合
Web：Servlet Based MVC  Web工具支持
Spring Framework：开发工具、框架整合

3 Web应用实例
===========  实例已完成  ============

2.1 IoC容器概述
core container
IoC容器 = ApplicationContext

Bean的作用域（有效范围）
创建、销毁时间
常用的作用域：
singleton（单例模式，默认） scope = "singleton"
prototype（每次引用创建新实例）scope = "prototype"
request scope
session scope
application scope
Bean生命周期回调
创建：申请资源 afterPropertiesSet()
销毁：释放资源

2.2 依赖注入
基于构造函数的注入：强依赖
基于Setter方法的注入：可选依赖（可配置的）
基本类型（int, String）
集合类
Bean
配置文件

注入集合
java  List
===================  通过构造函数进行依赖注入的例子已经完成  ===================
依赖注入2：主要介绍了构造函数注入和set注入两种方式

autowiring
byName、byType、constructor


3.1 AOP概述

优点：代码重用、解耦业务逻辑与非业务逻辑
Aspect :日志、安全等功能
join point:函数执行或者属性访问
advice：在某个函数执行点上要执行的切面功能
Pointcut：匹配横切目标函数的表达式

advice： before 、 after returning、after throwing、after finally around
spring AOP：非完整的AOP实现
XML schema-based AOP
@AspectJ annotation-based AOP

AOP使用
定义Aspect：
Pointcut表达式: designator(modifiers? return-type )


4.1 Spring JDBC- 成片（上）
数据库访问  JDBC
事务管理
ORM整合

DAO : data access object  数据访问相关接口
接口与实现相分离的方法
ORM （object relation mapping）  对象关系映射
数据访问步骤：
连接参数 -> 打开连接 -> 声明SQL语句及参数 -> 执行SQL，循环访问结果 -> 执行业务 -> 处理异常 -> 关闭连接
DataSource 声明连接参数(java EE 提供的)
驱动类名、连接地址、用户名、密码
getConnection
每一次连接： DriverManagerDatasource
连接池：BasicDataSource
=========================================================
jdbcTemplate(相关的概念以及用法很多，在实践之后需要再看一遍)
=========================================================




======================   Spring 实践笔记  ===================================
===================================
spring-web ： 第一个 spring 练手项目
===================================
根据业务对象和配置，由容器产生一个可用的对象
IoC容器： ApplicatioContext
定义一个类 -> 配置bean -> 获取bean -> 应用bean
scope = "prototype"时，可创建多个实例

<bean id = "screwDriver" class = "com.cmb.course.ScrewDriver" init-method = "init" destroy-method = "destroy"></bean>
通过init-method 和 destroy-method 设定初始化以及销毁的程序代码

集合传参  Map

一个bean依赖于另一个bean   配置方法
通过构造函数的方法来注入
<bean id = "screwDriver" class = "com.cmb.course.ScrewDriver">
  <constructor-arg>
    <ref bean = "straight"/>
  </constructor-arg>
</bean>

自动装配autowire
配置：	<bean id = "screwDriver" class = "com.cmb.course.ScrewDriver" autowire = "byName"></bean>
但是在类中需要加入set+BeanId的函数
@Component：定义bean
@Value：properties注入
@Autowired & @Resource: 自动装配依赖
@PostConstuct  @PreDestroy 声明周期回调
+ 配置

定义一个bean的名字  叫做  @Component("header")
在进行初始化的时候可以  setHeader(Header header)

JointPoint 获取函数的上下文信息
ProcessingJointPoint
returning获取返回值

事务注解的使用
@Transactional 注解应该只被应用到 public 方法上，这是由 Spring AOP 的本质决定的。
如果你在 protected、private 或者默认可见性的方法上使用 @Transactional 注解，这将被忽略，也不会抛出任何异常

=============             Spring  拦截器            =======================
在SpringMVC 中定义一个Interceptor是比较非常简单，主要有两种方式：
第一种：实现HandlerInterceptor 接口，或者是继承实现了HandlerInterceptor 接口的类，例如HandlerInterceptorAdapter；
第二种：实现Spring的WebRequestInterceptor接口，或者是继承实现了WebRequestInterceptor的类。
现在主要结合一个例子说一下第一种方式：实现HandlerInterceptor接口。
HandlerInterceptor接口主要定义了三个方法：
1. boolean preHandle (HttpServletRequest request, HttpServletResponse response, Object handle)方法：
该方法将在请求处理之前进行调用，只有该方法返回true，才会继续执行后续的Interceptor和Controller，
当返回值为true 时就会继续调用下一个Interceptor的preHandle 方法，如果已经是最后一个Interceptor的时候
就会是调用当前请求的Controller方法；
2.void postHandle (HttpServletRequest request, HttpServletResponse response, Object handle,
ModelAndView modelAndView)方法：该方法将在请求处理之后，DispatcherServlet进行视图返回渲染之前进行调用，
可以在这个方法中对Controller 处理之后的ModelAndView 对象进行操作。
3.void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handle, Exception ex)方法：该方法也是需要当前对应的Interceptor的preHandle方法的返回值为true时才会执行，该方法将在整个请求结束之后，也就是在DispatcherServlet 渲染了对应的视图之后执行。用于进行资源清理。




### Ioc
三种方式
构造器注入、setter注入、接口注入

两个容器
beanFactory
applicationContext


### 类继承体系结构分析

ClassPathXmlApplicationContext



Spring 提供了以下五种标准的事件：

    上下文更新事件（ContextRefreshedEvent）：该事件会在ApplicationContext 被初始化或者更新时发布。也可以在调用ConfigurableApplicationContext 接口中的 #refresh() 方法时被触发。
    上下文开始事件（ContextStartedEvent）：当容器调用ConfigurableApplicationContext 的 #start() 方法开始/重新开始容器时触发该事件。
    上下文停止事件（ContextStoppedEvent）：当容器调用 ConfigurableApplicationContext 的 #stop() 方法停止容器时触发该事件。
    上下文关闭事件（ContextClosedEvent）：当ApplicationContext 被关闭时触发该事件。容器被关闭时，其管理的所有单例 Bean 都被销毁。
    请求处理事件（RequestHandledEvent）：在 We b应用中，当一个HTTP 请求（request）结束触发该事件。


Spring Bean 支持 5 种 Scope ，分别如下：

    Singleton - 每个 Spring IoC 容器仅有一个单 Bean 实例。默认
    Prototype - 每次请求都会产生一个新的实例。
    Request - 每一次 HTTP 请求都会产生一个新的 Bean 实例，并且该 Bean 仅在当前 HTTP 请求内有效。
    Session - 每一个的 Session 都会产生一个新的 Bean 实例，同时该 Bean 仅在当前 HTTP Session 内有效。
    Application - 每一个 Web Application 都会产生一个新的 Bean ，同时该 Bean 仅在当前 Web Application 内有效。


#### spring bean 的生命周期

Spring Bean 的初始化流程如下：

    实例化 Bean 对象

        Spring 容器根据配置中的 Bean Definition(定义)中实例化 Bean 对象。

            Bean Definition 可以通过 XML，Java 注解或 Java Config 代码提供。

        Spring 使用依赖注入填充所有属性，如 Bean 中所定义的配置。
    Aware 相关的属性，注入到 Bean 对象
        如果 Bean 实现 BeanNameAware 接口，则工厂通过传递 Bean 的 beanName 来调用 #setBeanName(String name) 方法。
        如果 Bean 实现 BeanFactoryAware 接口，工厂通过传递自身的实例来调用 #setBeanFactory(BeanFactory beanFactory) 方法。
    调用相应的方法，进一步初始化 Bean 对象
        如果存在与 Bean 关联的任何 BeanPostProcessor 们，则调用 #preProcessBeforeInitialization(Object bean, String beanName) 方法。
        如果 Bean 实现 InitializingBean 接口，则会调用 #afterPropertiesSet() 方法。
        如果为 Bean 指定了 init 方法（例如 <bean /> 的 init-method 属性），那么将调用该方法。
        如果存在与 Bean 关联的任何 BeanPostProcessor 们，则将调用 #postProcessAfterInitialization(Object bean, String beanName) 方法。

Spring Bean 的销毁流程如下：

    如果 Bean 实现 DisposableBean 接口，当 spring 容器关闭时，会调用 #destroy() 方法。
    如果为 bean 指定了 destroy 方法（例如 <bean /> 的 destroy-method 属性），那么将调用该方法。



自动装配有哪些方式？

Spring 容器能够自动装配 Bean 。也就是说，可以通过检查 BeanFactory 的内容让 Spring 自动解析 Bean 的协作者。

自动装配的不同模式：

    no - 这是默认设置，表示没有自动装配。应使用显式 Bean 引用进行装配。
    byName - 它根据 Bean 的名称注入对象依赖项。它匹配并装配其属性与 XML 文件中由相同名称定义的 Bean 。
    【最常用】byType - 它根据类型注入对象依赖项。如果属性的类型与 XML 文件中的一个 Bean 类型匹配，则匹配并装配属性。
    构造函数 - 它通过调用类的构造函数来注入依赖项。它有大量的参数。
    autodetect - 首先容器尝试通过构造函数使用 autowire 装配，如果不能，则尝试通过 byType 自动装配。


### Spring 框架中的单例 Bean 是线程安全的么？




### 概念
AOP解决的问题：将核心业务代码与外围业务（日志记录、权限校验、异常处理、事务控制）代码分离出来，提高模块化，降低代码耦合度，使职责更单一。

    在 OOP 中，以类( Class )作为基本单元
    在 AOP 中，以切面( Aspect )作为基本单元。

#### Aspect
Aspect 由 PointCut 和 Advice 组成。

    它既包含了横切逻辑的定义，也包括了连接点的定义。
    Spring AOP 就是负责实施切面的框架，它将切面所定义的横切逻辑编织到切面所指定的连接点中。

AOP 的工作重心在于如何将增强编织目标对象的连接点上, 这里包含两个工作:

    如何通过 PointCut 和 Advice 定位到特定的 JoinPoint 上。
    如何在 Advice 中编写切面代码。

可以简单地认为, 使用 @Aspect 注解的类就是切面

#### Target
Target ，织入 Advice 的目标对象。目标对象也被称为 Advised Object 。

    因为 Spring AOP 使用运行时代理的方式来实现 Aspect ，因此 Advised Object 总是一个代理对象(Proxied Object) 。
    注意, Advised Object 指的不是原来的对象，而是织入 Advice 后所产生的代理对象。
    Advice + Target Object = Advised Object = Proxy 。

#### AOP 实现方式

实现 AOP 的技术，主要分为两大类：

    ① 静态代理 - 指使用 AOP 框架提供的命令进行编译，从而在编译阶段就可生成 AOP 代理类，因此也称为编译时增强。
        编译时编织（特殊编译器实现）

        类加载时编织（特殊的类加载器实现）。

            例如，SkyWalking 基于 Java Agent 机制，配置上 ByteBuddy 库，实现类加载时编织时增强，从而实现链路追踪的透明埋点。

    ② 动态代理 - 在运行时在内存中“临时”生成 AOP 动态代理类，因此也被称为运行时增强。目前 Spring 中使用了两种动态代理库：
        JDK 动态代理
        CGLIB

#### Spring AOP and AspectJ AOP 有什么区别？

    代理方式不同
        Spring AOP 基于动态代理方式实现。
        AspectJ AOP 基于静态代理方式实现。
    PointCut 支持力度不同
        Spring AOP 仅支持方法级别的 PointCut 。
        AspectJ AOP 提供了完全的 AOP 支持，它还支持属性级别的 PointCut 。




### 切点表达式函数

Spring 支持的AspectJ的切点指示器

    AspectJ 指示器 描述
    args() 限制连接点匹配参数为执行类型的执行方法
    @args() 限制连接点匹配参数由执行注解标注的执行方法
    execution() 匹配连接点的执行方法
    this() 限制连接点匹配AOP代理的Bean引用类型为指定类型的Bean
    target() 限制连接点匹配目标对象为指定类型的类
    @target() 限制连接点匹配目标对象被指定的注解标注的类
    within() 限制连接点匹配匹配指定的类型
    @within() 限制连接点匹配指定注解标注的类型
    @annotation 限制匹配带有指定注解的连接点

    匹配所有
    execution(“* * .*(..)”)

    匹配所有以set开头的方法
    execution(“* * .set*(..))

    匹配指定包下所有的方法
    execution(“* com.heisenberg.maven.learn.*(..))

    匹配指定包以及其子包下的所有方法
    execution(“* com.heisenberg.maven..*(..)”)

    匹配指定包以及其子包下 参数类型为String 的方法
    execution(“* com.heisenberg..*(java.lang.String))


### 应用场景
鉴权（interceptor 或者 aop）、统计方法执行时间、日志记录、权限校验、异常处理、事务控制等

StopWatch 统计spring中一个方法的调用时间

### springAop 与 aspectj 的区别





5、选择正确的框架
如果我们分析了本节中提出的所有论点, 我们就会开始理解, 一个框架比另一个架构更好。
简单地说, 选择很大程度上取决于我们的要求:
Spring AOP
AspectJ

![spring-aop-01.png](E:\AtomTest\picture\spring-aop-01.png)

框架: 如果应用程序没有使用 spring 框架, 那么我们就别无选择, 只能放弃使用 spring AOP 的想法, 因为它无法管理任何超出 spring 容器范围的东西。但是, 如果我们的应用程序是完全使用 spring 框架创建的, 那么我们可以使用 spring AOP, 因为它是简单的学习和应用

灵活性: 由于有限的 joinpoint 支持, Spring aop 不是一个完整的 aop 解决方案, 但它解决了程序员面临的最常见的问题。尽管如果我们想深入挖掘和开发 AOP 以达到其最大能力, 并希望得到广泛的可用 joinpoints 的支持, 那么最好选择 AspectJ

性能: 如果我们使用的是有限的切面, 那么就会有细微的性能差异。但有时, 应用程序有成千上万个切面的情况。我们不想在这样的情况下使用运行时编织, 所以最好选择 AspectJ。AspectJ 已知的速度比 Spring AOP 快8到35倍

两者的最佳之处: 这两个框架都是完全兼容的。我们总是可以利用 Spring AOP； 只要有可能, 仍然可以在不支持前者的地方使用 AspectJ 获得支持

作者：沈渊
链接：https://www.jianshu.com/p/872d3dbdc2ca


Spring Bean的完整生命周期从创建Spring容器开始，直到最终Spring容器销毁Bean，这其中包含了一系列关键点。

（1）实例化 BeanFactoryPostProcessor 实现类
（2）执行 BeanFactoryPostProcessor 的 postProcessBeanFactory 方法
（3）实例化 BeanPostProcessor 实现类
（4）实例化 InstantiationAwareBeanPostProcessorAdapter 实现类
（5）执行 InstantiationAwareBeanPostProcessor 的 postProcessBeforeInitialization 方法
（6）执行 bean 的构造器
（7）执行 InstantiationAwareBeanPostProcessor 的  postProcessProperties 方法
（8）为 bean 注入属性
（9）调用 beanNameAware 的 setBeanName 方法
（10）调用 BeanFactoryAware 的 setBeanFactory 方法
（11）执行 BeanPostProcessor 的  postProcessBeforeInitialization 方法
（12）调用 InitializingBean 的 afterPropertiesSet
（13）调用 <bean> 的 init-method 属性执行的初始化方法
（14）执行 BeanPostProcessor 的 postProcessAfterInitialization
（15）执行 InstantiationAwareBeanPostProcessor 的 postProcessAfterInitialization 方法
容器初始化成功，执行正常调用后，下面销毁容器。
调用 DisposibleBean 的 destory 方法
调用 <bean> 的 destory-method 属性执行的初始化方法



### 事务的特性指

指的是 ACID

事务的特性

    原子性 Atomicity ：一个事务（transaction）中的所有操作，或者全部完成，或者全部不完成，不会结束在中间某个环节。事务在执行过程中发生错误，会被恢复（Rollback）到事务开始前的状态，就像这个事务从来没有执行过一样。即，事务不可分割、不可约简。
    一致性 Consistency ：在事务开始之前和事务结束以后，数据库的完整性没有被破坏。这表示写入的资料必须完全符合所有的预设约束、触发器)、级联回滚等。
    隔离性 Isolation ：数据库允许多个并发事务同时对其数据进行读写和修改的能力，隔离性可以防止多个事务并发执行时由于交叉执行而导致数据的不一致。事务隔离分为不同级别，包括读未提交（Read uncommitted）、读提交（read committed）、可重复读（repeatable read）和串行化（Serializable）。
    持久性 Durability ：事务处理结束后，对数据的修改就是永久的，即便系统故障也不会丢失。

### Spring 支持的事务管理类型

目前 Spring 提供两种类型的事务管理：

    声明式事务：通过使用注解或基于 XML 的配置事务，从而事务管理与业务代码分离。
    编程式事务：通过编码的方式实现事务管理，需要在代码中显式的调用事务的获得、提交、回滚。它为您提供极大的灵活性，但维护起来非常困难。


### 为什么在 Spring 事务中不能切换数据源？

做过 Spring 多数据源的胖友，都会有个惨痛的经历，为什么在开启事务的 Service 层的方法中，无法切换数据源呢？因为，在 Spring 的事务管理中，所使用的数据库连接会和当前线程所绑定，即使我们设置了另外一个数据源，使用的还是当前的数据源连接。

另外，多个数据源且需要事务的场景，本身会带来多事务一致性的问题，暂时没有特别好的解决方案。


### @Transactional 注解有哪些属性？如何使用？


    一般情况下，我们直接使用 @Transactional 的所有属性默认值即可。

具体用法如下：

    @Transactional 可以作用于接口、接口方法、类以及类方法上。当作用于类上时，该类的所有 public 方法将都具有该类型的事务属性，同时，我们也可以在方法级别使用该标注来覆盖类级别的定义。
    虽然 @Transactional 注解可以作用于接口、接口方法、类以及类方法上，但是 Spring 建议不要在接口或者接口方法上使用该注解，因为这只有在使用基于接口的代理时它才会生效。另外， @Transactional 注解应该只被应用到 public 方法上，这是由 Spring AOP 的本质决定的。

**如果你在 protected、private 或者默认可见性的方法上使用 @Transactional 注解，这将被忽略，也不会抛出任何异常。这一点，非常需要注意。**

### 使用 Spring 事务有什么优点？

    通过 PlatformTransactionManager ，为不同的数据层持久框架提供统一的 API ，无需关心到底是原生 JDBC、Spring JDBC、JPA、Hibernate 还是 MyBatis 。
    通过使用声明式事务，使业务代码和事务管理的逻辑分离，更加清晰。

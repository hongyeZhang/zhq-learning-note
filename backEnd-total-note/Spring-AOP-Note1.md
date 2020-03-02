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

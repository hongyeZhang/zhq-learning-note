#### Transaction
Spring 简单而强大的事务管理功能，包括声明式事务和编程式事务。

#### JMS
JMS (Java Messaging Service)
提供了一个 JMS 集成框架，简化了 JMS API 的使用。

#### 依赖注入
Dependency Injection
原来，它叫 IoC 。
Martin Flower 发话了，是个框架都有 IoC ，这不足以新生容器反转的“如何定位插件的具体实现”，于是，它有了个新名字，Dependency Injection 。

其实，它就是一种将调用者与被调用者分离的思想，Uncle Bob 管它叫DIP（Dependency Inversion Principle），并把它归入OO设计原则。
同 Spring 相比，它更早进入我的大脑。一切都是那么朦胧，直至 Spring 出现。

慢慢的，我知道了它还分为三种：

    Interface Injection（type 1）
    Setter Injection（type 2）
    Constructor Injection（type 3）


#### 可以通过多少种方式完成依赖注入？

通常，依赖注入可以通过三种方式完成，即：

+ 接口注入
+ 构造函数注入
+ setter 注入

目前，在 Spring Framework 中，仅使用构造函数和 setter 注入这两种方式。

#### Spring 中有多少种 IoC 容器？

Spring 提供了两种( 不是“个” ) IoC 容器，分别是 BeanFactory、ApplicationContext 。


#### Spring 框架中有哪些不同类型的事件？
不会。

#### 什么是 Spring Bean ？
    Bean 由 Spring IoC 容器实例化，配置，装配和管理。
    Bean 是基于用户提供给 IoC 容器的配置元数据 Bean Definition 创建。

#### Spring 有哪些配置方式
单纯从 Spring Framework 提供的方式，一共有三种：

    1 XML 配置文件。
    2 注解配置。
    3 Java Config 配置。

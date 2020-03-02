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

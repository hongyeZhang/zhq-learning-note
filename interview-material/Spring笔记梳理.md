# Spring笔记

## Spring核心
* EJB (Enterprise Java Bean)  
    - Weblogic
    - JBoss 
* Spring 是指一个用于构造 Java 应用程序的轻量级框架，这句话两层意思：
    - 采用 Spring 来构造任何程序，这和 Apache Struts 这样的框架不同，仅仅被限定于WEB 应用
    - “轻量级”并不意味着类的数量很少，或者发行包尺寸很小。实际上，指的是Spring哲学原则——最少的侵入。

* Spring5.0
    - 基于Java8 与 java9 完全兼容




### Spring IOC
* 什么是Spring IOC 容器
    - 完成 **对象的创建** 和 **依赖注入** 等
* 由 Spring 负责控制对象的声明周期和对象之间的关系
* 设计模式六大原则
    - 单一原则 ：一个类或者一个方法只负责一个职责，各个职责的程序改动，不影响其它程序。
    - 里氏代换 ： 所有引用父类的地方必须能透明地使用其子类的对象，反过来则不成立。
    - 接口隔离 ： 建立单一接口，不要建立庞大臃肿的接口。一个接口只服务于一个子模块或业务逻辑。
    - 迪米特原则 ： 一个类对其他的类知道的越少越好，也就是对于被依赖的类的方法和属性尽量私有化。
    - 开闭原则 ： 对扩展开放，对修改关闭。
    - 依赖倒置（与IOC有很大的关系） ： 面向接口编程是依赖倒置原则的核心，上层定义接口，下层实现这个接口， 从而使得下层依赖于上层，降低耦合度。

### Spring 容器

* 启动容器
    - AbstractApplicationContext
        - refresh()


* BeanFactory
    - 工厂模式
        - 简单工厂：工厂模式（Factory Pattern）是最常用的设计模式之一。这种设计模式属于创建型模式，它提供了一种创建对象的最佳方式。
            在工厂模式中，我们在创建对象时不会对客户端暴露创建逻辑，而是通过使用一个共同的接口来指向新创建的对象。
        - 工厂方法 ：定义一个创建对象的接口，让子类决定实例化哪一个工厂类，工厂模式使其创建过程延迟到子类进行。
        - 抽象工厂：为创建一组相关或者是相互依赖的对象提供的一个接口，而不需要指定它们的具体类。抽象工厂和工厂方法的模式基本一样，
            区别在于：工厂方法是生产一个具体的产品，而抽象工厂可以用来生产一组产品。
    - BeanFactory 与 FactoryBean 的区别
        -  FactoryBean 本质是一个bean
* DefaultListableBeanFactory
    - DefaultListableBeanFactory是Bean加载的最核心部分，也是Spring注册及管理加载Bean的默认实现。
    DefaultListableBeanFactory继承自AbstractAutowireCapableBeanFactory并实现了ConfigurableListableBeanFactory以及BeanDefinitionRegistry接口。

* AutowireCapableBeanFactory
    - 自动装配，解析依赖

* 作用域
    - singleton
    - prototype

* AliasRegistry
     - 定义对alias的简单增删改查等操作
* BeanDefinitionRegistry
     - 向注册表中注册 BeanDefinition 实例，完成注册程
* SimpleAliasRegistry
     - 主要使用map作为alias的缓存，并对接口AliasRegistry进行实现
* SingletonBeanRegistry
     - 定义对单例的注册及获取
* BeanFactory
     - 定义获取Bean及各种属性
* DefaultSingletonBeanRegistry
     - 对接口SingletonBeanRegistry各函数的实现
* ListableBeanFactory
     - 根据各种条件获取Bean的列表
* HierarchicalBeanFactory
     - 继承BeanFactory，也就是在BeanFactory定义的功能的基础上增加了对parent BeanFactory的支持
* FactoryBeanRegistrySupport
     - 在DefaultSingletonBeanRegistry的基础上增加了对FactoryBean的处理功能
* ConfigurableBeanFactory
     - 提供配置Factory的各种方法
* AutowireCapableBeanFactory
     - 提供创建Bean、自动注入，初始化以及应用Bean的后处理器
* AbstractBeanFactory
     - FactoryBeanRegistrySupport和ConfigurableBeanFactory功能的集合
* AbstractAutowireCapableBeanFactory
     - 综合AbstractBeanFactory并对接口AutowireCapableBeanFactory进行实现
* ConfigurableListableBeanFactory
     - BeanFactory配置清单，指定忽略类型及接口等
* DefaultListableBeanFactory
    - 综合上面所有的功能


* ApplicationContext
    - ApplicationContext接口是由BeanFactory接口派生出来的，所以提供了BeanFactory的所有功能。除此之外，ApplicationContext还提供了如下功能：
        - 通过MessageSource访问i18n消息。
        - 通过ResourceLoader访问资源，如：URL和文件。 
        - 使用ApplicationEventPublisher接口，将事件发布到实现ApplicationListener接口的Bean。
        - 加载多个（分层）上下文，从而允许每个上下文通过HierarchicalBeanFactory接口集中在一个特定层上。如：Web层。

* BeanFactory和ApplicationContext
    - BeanFactory的核心概念就是Bean工厂，用于Bean生命周期的管理，而Applicationcontext除了具有BeanFactory
        的特性外，还包括消息国际化、资源访问、事件传播等功能。简而言之，BeanFactory提供了配置框架和基本功能，
        而ApplicationContext则添加了更多特定的功能。ApplicationContext是BeanFactory的完整超集。
    - 除非您有充分的理由，否则请使用ApplicationContext。因为ApplicationContext包含BeanFactory的所有功能，除非你需要完全控制Bean处理的方案。

* BeanDefinition
Spring IoC容器管理一个或多个Bean。这些Bean是根据程序提供给容器的配置元数据创建的，如：以XML <bean />格式的定义。而在容器内部，这些Bean需要表示为BeanDefinition对象，也就是有一个将Bean解析成Spring内部的BeanDefinition对象的过程。BeanDefinition包含以下元数据信息：
    ● 一个全限定的类名
    ● 用于声明Bean在容器中的行为信息（作用域，生命周期回调等）。
    ● 要完成自身工作需要引用其他的Bean，这些引用也称为依赖项。
    ● 要在新创建的对象中设置的其他配置，如：用于管理连接池的连接数，或池的大小限制。
    
    这些元数据构成每个BeanDefinition的一组属性：
    ● class
    ● name：Bean在容器内的唯一标识符。基于XML的配置，可以使用id或name属来指定Bean标识符
    ● scope：Bean的作用域
    ● constructor arguments：构造函数的参数
    ● properties：Bean包含的属性（依赖注入项）
    ● autowiring mode：自动装配模式
    ● lazy-initialization mode：延迟加载方法
    ● initialization method：初始化方法
    ● destruction method：销毁方法
    
    BeanDefinition继承了AttributeAccessor和BeanMetadataElement接口：
    ● AttributeAccessor：提供了访问属性的能力
    ● BeanMetadataElement：用来获取元数据元素的配置源对象

* XMLBeanDefinitionReader
    - BeanDefinitionReader  主要定义资源文件读取并转换为BeanDefinition的各个功能
    - EnvironmentCapable  定义获取Environment方法
    - DocumentLoader  定义从资源文件加载到转换为Document的功能
    - AbstractBeanDefinitionReader  对EnvironmentCapable、BeanDefinitionReader类定义的功能进行实现
    - BeanDefinitionDocumentReader  定义读取Document并注册BeanDefiniton功能
    - BeanDefinitionParserDelegate  定义解析Element的各种方法
    - 在XmlBeanDifinitonReader中主要包含以下几个步骤的处理：
        - 通过继承自AbstractBeanDefinitionReader中的方法，来使用ResourceLoader将资源文件路径转换为对应的Resource文件。
        - 通过DocumentLoader对Resource文件进行转换，将Resource文件转换为Document文件。
        - 通过实现接口BeanDefinitionDocumentReader的DefaultBeanDefinitionDocumentReader类对Document进行解析，
            并使用BeanDefinitionParserDelegate对Element进行解析。



### 路径解析和占位符
* 启动之前的第一步
* 占位符允许嵌套操作
```java
// 设置xml配置文件路径
public void setConfigLocations(String... locations) {
    if (locations != null) {
        Assert.noNullElements(locations, "Config locations must not be null");
        this.configLocations = new String[locations.length];
        for (int i = 0; i < locations.length; i++) {
            this.configLocations[i] = resolvePath(locations[i]).trim();
        }
    }
    else {
        this.configLocations = null;
    }
}

// 占位符号解析和替换
protected String resolvePath(String path) {
    return getEnvironment().resolveRequiredPlaceholders(path);
}

```

* Spring 环境和属性由四个部分组成：
    - PropertySource：属性源。key-value 属性对抽象，用于配置数据。
    - PropertyResolver：属性解析器。用于解析属性配置。
    - Profile：剖面。只有被激活的Profile才会将其中所对应的Bean注册到Spring容器中
    - Environment：环境。Profile 和 PropertyResolver 的组合

* PropertySource  提供了可配置属性源上的搜索操作。
* PropertyResolver  属性解析器，用于解析任何基础源的属性的接口
* ConfigurablePropertyResolver  提供属性类型转换的功能
* AbstractPropertyResolver  解析属性文件的抽象基类。设置了解析属性文件所需要ConversionService、prefix、suffix、valueSeparator等信息。
* PropertySourcesPropertyResolver  PropertyResolver 的实现，对一组 PropertySources 提供属性解析服务
* ConversionService  用于在运行时执行类型转换
* Environment  集成在容器中的抽象，它主要包含两个方面：Profiles和Properties
* ConfigurableEnvironment  设置激活的 profile 和默认的 profile 的功能以及操作 Properties 的工具


* 搜索过程是按照层次结构执行的。默认情况下，系统属性优先于环境变量。因此，在调用env.getProperty（"foo"）时，
    如果在系统属性和环境变量中都设置了foo属性，则系统变量将优先于环境变量。完整层次结构如下所示，优先级最高的条目位于顶部：
    - ServletConfig参数
    - ServletContext参数
    - JNDI环境变量（如："java:comp/env/"）
    - JVM system properties（"-D"命令行参数，如-Dfoo="abcd"）
    - JVM system environment（操作系统环境变量）
    - 注意，属性值不会被合并，而是会被前面的条目覆盖。 


* 详细解析过程见 word 文档



### Spring 启动流程




### Bean 生命周期


### 循环依赖


### Spring Context


### Spring AOP


### Spring Transaction


### Spring MVC


### 其他
* spring Web Flux



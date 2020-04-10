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

    <img src="E:\GIT_ZHQ\zhq-learning-note\interview-material\笔记图片\DefaultListableBeanFactory.png" alt="DefaultListableBeanFactory" style="zoom:100%;" />
    
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
* Spring的IoC容器在实现控制反转和依赖注入的过程中，可以划分为两个阶段：
    - 容器启动阶段
    - Bean实例化阶段



![spring启动流程](E:\GIT_ZHQ\zhq-learning-note\interview-material\笔记图片\spring启动流程.png)


* AbstractApplicationContext
```java
	@Override
	public void refresh() throws BeansException, IllegalStateException {
		synchronized (this.startupShutdownMonitor) {
			// Prepare this context for refreshing.
			prepareRefresh();

			// Tell the subclass to refresh the internal bean factory.
			ConfigurableListableBeanFactory beanFactory = obtainFreshBeanFactory();

			// Prepare the bean factory for use in this context.
			prepareBeanFactory(beanFactory);

			try {
				// Allows post-processing of the bean factory in context subclasses.
				postProcessBeanFactory(beanFactory);

				// Invoke factory processors registered as beans in the context.
				invokeBeanFactoryPostProcessors(beanFactory);

				// Register bean processors that intercept bean creation.
				registerBeanPostProcessors(beanFactory);

				// Initialize message source for this context.
				initMessageSource();

				// Initialize event multicaster for this context.
				initApplicationEventMulticaster();

				// Initialize other special beans in specific context subclasses.
				onRefresh();

				// Check for listener beans and register them.
				registerListeners();

				// Instantiate all remaining (non-lazy-init) singletons.
				finishBeanFactoryInitialization(beanFactory);

				// Last step: publish corresponding event.
				finishRefresh();
			}

			catch (BeansException ex) {
				if (logger.isWarnEnabled()) {
					logger.warn("Exception encountered during context initialization - " +
							"cancelling refresh attempt: " + ex);
				}

				// Destroy already created singletons to avoid dangling resources.
				destroyBeans();

				// Reset 'active' flag.
				cancelRefresh(ex);

				// Propagate exception to caller.
				throw ex;
			}

			finally {
				// Reset common introspection caches in Spring's core, since we
				// might not ever need metadata for singleton beans anymore...
				resetCommonCaches();
			}
		}
	}
```

* 整个refresh()的代码都是同步的，而对应的同步对象是startupShutdownMonitor。startupShutdownMonitor只在refresh()和close
()两个方法里被用到，而它是用来同步applicationContext的刷新和销毁。



* DefaultBeanDefinitionDocumentReader



#### 第三步 准备BeanFactory
这个阶段主要是当Spring获取了BeanFactory之后，还要做些处理工作（配置工厂的上下文），如：上下文的ClassLoader和BeanPostProcessor。


BeanExpressionResolver
通过将值作为表达式进行评估来解析值。它的唯一实现类是StandardBeanExpressionResolver。
PropertyEditor
Spring使用PropertyEditor的来实现对象和字符串之间的转换。有时用与对象本身不同的方式表示属性可能更为方便。如：“2019-09-13”字符串形式阅读起来更友好，但也可以将任何方便阅读的日期表现形式转换为日期对象。
Spring提供了很多内置的PropertyEditor，它们都位于org.springframework.beans.propertyeditors包中。默认情况下，大多数由BeanWrapperImpl注册。

Aware感知
如果在某个Bean里面想要使用Spring框架提供的功能，可以通过Aware接口来实现。通过实现 Aware 接口，Spring 可以在启动时，调用接口定义的方法，
并将 Spring 底层的一些组件注入到自定义的 Bean 中。

ApplicationContextAware  当ApplicationContext创建实现ApplicationContextAware接口的Bean实例时，将为该Bean实例提供对该ApplicationContext的引用。
ApplicationEventPublisherAware  为Bean实例提供对ApplicationEventPublisherAware的引用。
BeanFactoryAware  为Bean实例提供对BeanFactory的引用
BeanNameAware  获取Bean在BeanFactory中配置的名字
MessageSourceAware  为Bean实例提供对MessageSource的引用
EnvironmentAware  获得Environment支持，这样可以获取环境变量
ResourceLoaderAware  获得资源加载器以获得外部资源文件
BeanPostProcessor  如果想在Spring容器中完成Bean实例化、配置以及其他初始化方法前后要添加一些自己逻辑处理，就需要定义一个或多个BeanPostProcessor接口实现类，然后注册到Spring IoC容器中。


#### 第四步  BeanFactory后处理



* bean 的作用域
    - singleton （默认注册）
    - prototype （默认注册）
    - request 
    - session
    - globalSession
    - application


* WebApplicationContextUtils
    - 该类位于包`org.springframework.web.context.support`是一个使检索指定ServletContext的根WebApplicationContext的便捷工具类。它如下工具方法：
    - 1. 在Web容器启动过程中注册Web相关作用域Bean（request/session/globalSession/application）
    - 2. 在Web容器启动过程中注册相应类型的工厂Bean ，依赖注入的Bean时能访问到正确的对象（ServletRequest/ServletResponse/HttpSession/WebRequest）
    - 3. 在Web容器启动过程中注册Web相关环境Bean
    - 4. 在Web容器启动过程中初始化Servlet propertySources
    - 5. 在客户化Web视图或者MVC action中，使用该工具类可以很方便地在程序中访问Spring应用上下文(application context)。




#### 第五步  调用后处理器

* BeanFactoryPostProcessor
    - BeanFactoryPostProcessor接口与BeanPostProcessor相似，但有一个主要区别：BeanFactoryPostProcessor用来操作Bean
      的配置元数据。也就是说，Spring IoC容器允许BeanFactoryPostProcessor读取配置元数据，并能在容器实例化任何Bean之前更改这些元数据。
      换句话说 ：就是可以让我们随心所欲地修改BeanFactory内所有BeanDefinition定义数据。
    - 可以在项目中配置多个BeanFactoryPostProcessor，同时通过设置Order属性来控制这些BeanFactoryPostProcessor的执行顺序，
      当然仅当BeanFactoryPostProcessor实现Ordered接口时，才可以设置此属性。


* BeanDefinitionRegistryPostProcessor  
    - 是对标准BeanFactoryPostProcessor的扩展，允许在进行常规BeanFactoryPostProcessor检测之前注册其他Bean
       定义。特别是，BeanDefinitionRegistryPostProcessor注册的Bean定义又定义了BeanFactoryPostProcessor实例。





#### 第六步  注册后处理器

* 实例化和初始化是不是一回事？
    - instantiation 实例化
    - Initialization 初始化
    - BeanPostProcessor 在 bean 实例化之后，执行初始化的相关操作
        - postProcessBeforeInitialization
        - postProcessAfterInitialization 
        - AOP 自动代理相关
    - InstantiationAwareBeanPostProcessor
        - postProcessBeforeInstantiation
        - postProcessAfterInstantiation



* 实例化是在什么时候进行的？


* Spring Bean的生命周期只有四个阶段：
    - 1. 实例化（Instantiation）：调用构造函数
    - 2. 属性赋值（Populate）：设置依赖注入
    - 3. 初始化（Initialization）：调用 init 方法
    - 4. 销毁（Destruction）：调用 destory 方法

![bean的生命周期](E:\GIT_ZHQ\zhq-learning-note\interview-material\笔记图片\bean的生命周期.png)


生命周期也可以理解为四个等级。每个等级中都用有相应的接口，实现其中某个接口或者将实现类注入到Spring容器，容器就会在相应的时机调用其方法。
1. 工厂级处理器接口
2. 容器级生命周期接口
3. Bean级生命周期接口
4. Bean本身方法


    BeanFactoryPostProcessor
    工厂后处理器接口
    容器创建完毕，装配Bean源后立即调用
    
    InstantiationAwareBeanPostProcessor
    容器后处理器接口
    分别在调用构造之前，注入属性之前，实例化完成时调用
    
    BeanPostProcessor
    容器后处理器接口
    分别在Bean的初始化方法调用前后执行
    
    BeanNameAware
    Bean级后置处理器接口
    注入属性后调用
    
    BeanFactoryAware
    Bean级后置处理器接口
    注入属性后调用
    
    InitializingBean
    Bean级后置处理器接口
    在类本身的初始化方法之前调用其方法（本身也是初始化方法）
    
    DisposableBean
    Bean级后置处理器接口
    在类本身的销毁方法执行之前调用其方法（本身也是销毁方法）
    
    init方法
    Bean本身方法
    在注入属性之后调用初始化方法
    
    destroy方法
    Bean本身方法
    在关闭容器的时候进行销毁



Spring Bean的生命周期：
    - 1. Spring对Bean进行实例化，调用Bean的构造参数
        - 2. 设置对象属性，调用Bean的set方法，将属性注入到bean的属性中
    - 3. 检查Bean是否实现BeanNameAware、BeanFactoryAware、ApplicationContextAware接口，如果实现了这几个接口Spring会分别调用其中实现的方法。
    - 4. 如果Bean是否实现BeanPostProcessor接口，Spring会在初始化方法的前后分别调用postProcessBeforeInitialization和postProcessAfterInitialization方法
    - 5. 如果Bean是否实现InitalizingBean接口，将调用afterPropertiesSet()方法
    - 6. 如果Bean声明初始化方法，也会被调用
    - 7. 使用Bean。Bean将会一直保留在应用的上下文中，直到该应用上下文被销毁。
    - 8. 检查Bean是否实现DisposableBean接口，Spring会调用它们的destory方法
    - 9. 如果Bean声明销毁方法，该方法也会被调用

![bean的声明周期2](E:\GIT_ZHQ\zhq-learning-note\interview-material\笔记图片\bean的声明周期2.png)



* Bean的创建过程









* 怎样解决循环依赖问题？
    - Spring循环依赖的理论依据其实是Java基于引用传递，当我们获取到对象的引用时，对象的field或者或属性是可以延后设置的。
    - Spring单例构造器循环依赖
        - 目前Spring是无法解决的
    - Field 循环依赖
        - 提前暴露实例化Bean + 缓存不同阶段的bean(三级缓存)进行依赖排除
        - Spring首先从singletonObjects（一级缓存）中尝试获取，如果获取不到并且对象在创建中，则尝试从earlySingletonObjects(二级缓存)
           中获取，如果还是获取不到并且允许从singletonFactories通过getObject获取，则通过三级缓存获取，即通过singletonFactory.getObject()。
           如果获取到了，将其存入二级缓存，并清除三级缓存。
        - 如果缓存中没有bean对象，那么Spring会创建Bean对象，将实例化的bean提前曝光，并且加入缓存中。
          

```java
/** Cache of singleton objects: bean name --> bean instance */
// 一级缓存：维护着所有创建完成的Bean
private final Map<String, Object> singletonObjects = new ConcurrentHashMap<String, Object>(256);

/** Cache of early singleton objects: bean name --> bean instance */
// 二级缓存：维护早期暴露的Bean(只进行了实例化，并未进行属性注入)
private final Map<String, Object> earlySingletonObjects = new HashMap<String, Object>(16);

/** Cache of singleton factories: bean name --> ObjectFactory */
// 三级缓存：维护创建中Bean的ObjectFactory(解决循环依赖的关键)
private final Map<String, ObjectFactory<?>> singletonFactories = new HashMap<String, ObjectFactory<?>>(16);
```












### Bean 生命周期


### 循环依赖


### Spring Context


### Spring AOP


### Spring Transaction


### Spring MVC
#### SpringMVC 的运行流程
* 从 URL 到 method 的过程是怎样做到的？

* DispatcherServlet 匹配所有的请求
* doGet()
    - doService()
        - doDispatch(request, response)
            - HandlerExecutionChain mappedHandler = getHandler(processedRequest)
            - HandlerAdapter ha = getHandlerAdapter(mappedHandler.getHandler());
            - RequestMappingHandlerAdapter
            - 

* doDispatch 主要流程
    - 1.调用handlerMapping获取handlerChain
    - 2.获取支持该handler解析的HandlerAdapter
    - 3.使用HandlerAdapter完成handler处理
    - 4.视图处理(页面渲染)

* HandleMapping
    - 子类 RequestMappingHandlerMapping
    - 定义: 请求路径-处理过程映射管理
    - 打个比方就是根据你的http请求的路径得到可以处理的handler(你的Controller方法)

* HandleAdapter
    - 定义: 根据 HandlerMapping.getHandler()得到的Handler信息,对http请求参数解析并绑定
    - 根据HandlerMethod信息,对http请求进行参数解析,并完成调用


* request请求过程
    - 调用doDispatch()
    - 遍历handlerMappings 与request 获取一个执行链 getHandl er()
    - 遍历handleAdapters 与 handle 获取一个handle 适配器 RequestMappingHandlerAdapter 记性参数解析并完成调用
    - 通过执行链去调用拦截器当中的 preHandle() 方法 ，进行预处理。
    - 基于handle 适配器 去调用handle 方法,返回 modelAndView
    - 通过执行链 去调用拦截器当中的 PostHandle() 方法 ，进行拦截处理。
    - processDispatchResult()
    - 正常：调用render()进行视图解析
        - 1 基于 遍历 viewResol vers 工与 viewname 获取View
        - 2 调用view.render() 进行视图解析和返回,设置model 至request
    - 异常：遍历handlerExceptionResolvers 调用resolveExcepti on(),返回 mv,最后跳转至异常 mv

#### SpringMVC 源码分析






### 其他
* spring Web Flux



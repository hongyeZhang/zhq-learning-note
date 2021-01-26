# Spring源码阅读笔记
* 参考学习链接  http://svip.iocoder.cn/categories/Spring/


## 学习进度记录
### 1【死磕 Spring】—— IoC 之深入理解 Spring IoC
* ClassPathXmlApplicationContext 类体系的继承结构，基本上包含了 IoC 体系中大部分的核心类和接口。
* Resource 体系
* ResourceLoader 体系
* BeanFactory 体系
    * 是一个非常纯粹的 bean 容器，它是 IoC 必备的数据结构，其中 BeanDefinition 是它的基本结构。BeanFactory 内部维护着一个BeanDefinition map ，
    并可根据 BeanDefinition 的描述进行 bean 的创建和管理。
    * BeanFactory 有三个直接子类 ListableBeanFactory、HierarchicalBeanFactory 和 AutowireCapableBeanFactory。
    * DefaultListableBeanFactory 为最终默认实现，它实现了所有接口。                                          
* BeanDefinition 体系
* BeanDefinitionReader 体系
* ApplicationContext 体系
    * 这个就是大名鼎鼎的 Spring 容器，它叫做应用上下文，与我们应用息息相关。它继承 BeanFactory ，所以它是 BeanFactory 的扩展升级版，
    如果BeanFactory 是屌丝的话，那么 ApplicationContext 则是名副其实的高富帅
    * 


### 2 【死磕 Spring】—— IoC 之 Spring 统一资源加载策略
* java.net.URL 的局限性迫使 Spring 必须实现自己的资源加载策略
* 1. 统一资源：Resource
    * FileSystemResource ：对 java.io.File 类型资源的封装，只要是跟 File 打交道的，基本上与 FileSystemResource 也可以打交道。支持文件和 URL 的形式，实现 WritableResource 接口，且从 Spring Framework 5.0 开始，FileSystemResource 使用 NIO2 API进行读/写交互。
    * ByteArrayResource ：对字节数组提供的数据的封装。如果通过 InputStream 形式访问该类型的资源，该实现会根据字节数组的数据构造一个相应的 ByteArrayInputStream。
    * UrlResource ：对 java.net.URL类型资源的封装。内部委派 URL 进行具体的资源操作。
    * ClassPathResource ：class path 类型资源的实现。使用给定的 ClassLoader 或者给定的 Class 来加载资源。
    * InputStreamResource ：将给定的 InputStream 作为一种资源的 Resource 的实现类。
    * 如果我们想要实现自定义的 Resource ，记住不要实现 Resource 接口，而应该继承 AbstractResource 抽象类，然后根据当前的具体资源特性覆盖相应的方法即可
* 统一资源定位：ResourceLoader
    * org.springframework.core.io.ResourceLoader 为 Spring 资源加载的统一抽象，具体的资源加载则由相应的实现类来完成
    * 该方法的主要实现是在其子类 DefaultResourceLoader 中实现
    * 我们不需要直接继承 DefaultResourceLoader，改为实现 ProtocolResolver 接口也可以实现自定义的 ResourceLoader。
* 2.3 ClassRelativeResourceLoader
    * 可以根据给定的class 所在包或者所在包的子包下加载资源。
* 2.4 ResourcePatternResolver
* 2.5 PathMatchingResourcePatternResolver

### 3 【死磕 Spring】—— IoC 之加载 BeanDefinition
* IoC 容器的使用过程
    * 获取资源
    * 获取 BeanFactory
    * 根据新建的 BeanFactory 创建一个 BeanDefinitionReader 对象，该 Reader 对象为资源的解析器
    * 装载资源

* 资源定位。我们一般用外部资源来描述 Bean 对象，所以在初始化 IoC 容器的第一步就是需要定位这个外部资源
* 装载。装载就是 BeanDefinition 的载入。BeanDefinitionReader 读取、解析 Resource 资源，也就是将用户定义的 Bean 表示成 IoC 容器的内部数据结构：BeanDefinition 。
* 注册。向 IoC 容器注册在第二步解析好的 BeanDefinition，这个过程是通过 BeanDefinitionRegistry 接口来实现的。在 IoC 容器内部其实是将第二
    个过程解析得到的 BeanDefinition 注入到一个 HashMap 容器中，IoC 容器就是通过这个 HashMap 来维护这些 BeanDefinition 的
    * 在这里需要注意的一点是这个过程并没有完成依赖注入（Bean 创建），Bean 创建是发生在应用第一次调用 #getBean(...) 方法，向容器索要 Bean 时。
    * 当然我们可以通过设置预处理，即对某个 Bean 设置 lazyinit = false 属性，那么这个 Bean 的依赖注入就会在容器初始化的时候完成。
* XML Resource => XML Document => Bean Definition 

* XmlBeanDefinitionReader
    * 调用 #getValidationModeForResource(Resource resource) 方法，获取指定资源（xml）的验证模式。
    * 调用 DocumentLoader#loadDocument(InputSource inputSource, EntityResolver entityResolver,ErrorHandler errorHandler, 
        int validationMode, boolean namespaceAware) 方法，获取 XML Document 实例。
    * 调用 #registerBeanDefinitions(Document doc, Resource resource) 方法，根据获取的 Document 实例，注册 Bean 信息。

### 4【死磕 Spring】—— IoC 之获取验证模型
* XML 文件的验证模式保证了 XML 文件的正确性。
* DTD
* XSD

* DTD(Document Type Definition)，即文档类型定义，为 XML 文件的验证机制，属于 XML 文件中组成的一部分。其实 DTD 就相当于 XML 中的 “词汇”和“语法”，
我们可以通过比较 XML 文件和 DTD 文件 来看文档是否符合规范，元素和标签使用是否正确
* XSD（XML Schemas Definition）即 XML Schema 语言。XML Schema 本身就是一个 XML文档，使用的是 XML 语法，因此可以很方便的解析 XSD 文档。
* doLoadBeanDefinitions(InputSource inputSource, Resource resource)
    * getValidationModeForResource(Resource resource)
* XmlValidationModeDetector


### 5【死磕 Spring】—— IoC 之获取 Document 对象
* DocumentLoader#loadDocument(InputSource inputSource, EntityResolver entityResolver, ErrorHandler errorHandler, int validationMode, boolean namespaceAware)
* 获取 Document 的策略，由接口 org.springframework.beans.factory.xml.DocumentLoader 定义

* EntityResolver
    * EntityResolver 的作用就是，通过实现它，应用可以自定义如何寻找【验证文件】的逻辑。
    * org.springframework.beans.factory.xm.BeansDtdResolver ：实现 EntityResolver 接口，Spring Bean dtd 解码器，用来从 classpath 或者 jar 文件中加载 dtd
    * org.springframework.beans.factory.xml.PluggableSchemaResolver ，实现 EntityResolver 接口，读取 classpath 下的所有 "META-INF/spring.schemas" 成一个 namespaceURI 与 Schema 文件地址的 map 
    * org.springframework.beans.factory.xml.DelegatingEntityResolver ：实现 EntityResolver 接口，分别代理 dtd 的 BeansDtdResolver 和 xml schemas 的 PluggableSchemaResolver
    * org.springframework.beans.factory.xml.ResourceEntityResolver ：继承自 DelegatingEntityResolver 类，通过 ResourceLoader 来解析实体的引用
    * EntityResolver 的重点，是在于如何获取【验证文件】，从而验证用户写的 XML 是否通过验证。

### 6【死磕 Spring】—— IoC 之注册 BeanDefinitions
* XmlBeanDefinitionReader#registerBeanDefinitions(Document doc, Resource resource) 方法，开始注册 BeanDefinitions 之旅
* BeanDefinitionDocumentReader
    * registerBeanDefinitions  从给定的 Document 对象中解析定义的 BeanDefinition 并将他们注册到注册表中
    
* Spring 有两种 Bean 声明方式：
    * 配置文件式声明：<bean id="studentService" class="org.springframework.core.StudentService" /> 。对应 <1> 处。
    * 自定义注解方式：<tx:annotation-driven> 。对应 <2> 处。
* XmlBeanDefinitionReader#doLoadBeanDefinitions(InputSource inputSource, Resource resource) 方法中，做的三件事情已经全部分析完毕，
  下面将对 BeanDefinition 的解析过程做详细分析说明。
* 另外，XmlBeanDefinitionReader#doLoadBeanDefinitions(InputSource inputSource, Resource resource) 方法


### 7【死磕 Spring】—— IoC 之解析Bean：解析 import 标签
* 如果根节点或者子节点采用默认命名空间的话，则调用 #parseDefaultElement(...) 方法，进行默认标签解析
* 否则，调用 BeanDefinitionParserDelegate#parseCustomElement(...) 方法，进行自定义解析。
* Spring 使用 #importBeanDefinitionResource(Element ele) 方法，完成对 import 标签的解析

* 解析 import 标签的过程较为清晰，整个过程如下：
    * 获取 source 属性的值，该值表示资源的路径。
    * 解析路径中的系统属性，如 "${user.dir}" 。
    * 判断资源路径 location 是绝对路径还是相对路径。详细解析，见 「2.1 判断路径」 。
    * 如果是绝对路径，则调递归调用 Bean 的解析过程，进行另一次的解析。详细解析，见 「2.2 处理绝对路径」 。
    * 如果是相对路径，则先计算出绝对路径得到 Resource，然后进行解析。详细解析，见 「2.3 处理相对路径」 。
    * 通知监听器，完成解析。
* 整个过程比较清晰明了：获取 source 属性值，得到正确的资源路径，然后调用 XmlBeanDefinitionReader#loadBeanDefinitions(Resource... resources) 
    方法，进行递归的 BeanDefinition 加载。


### 8 【死磕 Spring】—— IoC 之解析 <bean> 标签：开启解析进程
* processBeanDefinition
* 在方法 #parseDefaultElement(...) 方法中，如果遇到标签为 bean 时，则调用 #processBeanDefinition(Element ele, BeanDefinitionParserDelegate delegate) 
    方法，进行 bean 标签的解析

### 9 【死磕 Spring】—— IoC 之解析 <bean> 标签：BeanDefinition
* 解析 bean 标签的过程其实就是构造一个 BeanDefinition 对象的过程。<bean> 元素标签拥有的配置属性，BeanDefinition 均提供了相应的属性，与之一一对应
我们常用的三个实现类有：
org.springframework.beans.factory.support.ChildBeanDefinition
org.springframework.beans.factory.support.RootBeanDefinition
org.springframework.beans.factory.support.GenericBeanDefinition

如果配置文件中定义了父 <bean> 和 子 <bean> ，则父 <bean> 用 RootBeanDefinition 表示，子 <bean> 用 ChildBeanDefinition 表示，而没有父 <bean> 的就使用RootBeanDefinition 表示。

### 10 【死磕 Spring】—— IoC 之解析 <bean> 标签：meta、lookup-method、replace-method
* <meta> ：元数据。
* <lookup-method> ：Spring 动态改变 bean 里方法的实现。方法执行返回的对象，使用 Spring 内原有的这类对象替换，通过改变方法返回值来动态改变方法。内部实现为使用 cglib 方法，重新生成子类，重写配置的方法和返回对象，达到动态改变的效果。
* <replace-method> ：Spring 动态改变 bean 里方法的实现。需要改变的方法，使用 Spring 内原有其他类（需要继承接口org.springframework.beans.factory.support.MethodReplacer）的逻辑，替换这个方法。通过改变方法执行逻辑来动态改变方法。

### 11 【死磕 Spring】—— IoC 之解析 <bean> 标签：constructor-arg、property、qualifier
* parseConstructorArgElements(Element beanEle, BeanDefinition bd) 方法，完成 constructor-arg 子元素的解析
首先获取 index、type、name 三个属性值，然后根据是否存在 index 来区分，执行后续逻辑。其实两者逻辑都差不多，总共分为如下几个步骤（以有 index 为例）：
在 <1> 处，构造 ConstructorArgumentEntry 对象并将其加入到 ParseState 队列中。ConstructorArgumentEntry 表示构造函数的参数。
在 <2> 处，调用 #parsePropertyValue(Element ele, BeanDefinition bd, String propertyName) 方法，解析 constructor-arg 子元素，返回结果值。详细解析，见 「1.4 parsePropertyValue」 。
在 <3> 处，根据解析的结果值，构造ConstructorArgumentValues.ValueHolder 实例对象，并将 type、name 设置到 ValueHolder 中
在 <4> 处，最后，将 ValueHolder 实例对象添加到 indexedArgumentValues 集合中。
无 index 的处理逻辑差不多，只有几点不同：
构造 ConstructorArgumentEntry 对象时是调用无参构造函数
最后是将 ValueHolder 实例添加到 genericArgumentValues 集合中。


### 12 【死磕 Spring】—— IoC 之解析 <bean> 标签：解析自定义标签
解析 BeanDefinition 的入口在 DefaultBeanDefinitionDocumentReader 的#parseBeanDefinitions(Element root, BeanDefinitionParserDelegate delegate) 方法。该方法会根据命令空间来判断标签是默认标签还是自定义标签，其中：

* 默认标签，由 #parseDefaultElement(Element ele, BeanDefinitionParserDelegate delegate) 方法来实现
* 自定义标签，由 BeanDefinitionParserDelegate 的 #parseCustomElement(Element ele, @Nullable BeanDefinition containingBd) 方法来实现。
* 在默认标签解析中，会根据标签名称的不同进行 import、alias、bean、beans 四大标签进行处理。其中 bean 标签的解析为核心，它由 processBeanDefinition(Element ele, BeanDefinitionParserDelegate delegate) 方法实现。

* processBeanDefinition(Element ele, BeanDefinitionParserDelegate delegate) 方法，开始进入解析核心工作，分为三步：

* 解析默认标签的默认标签：BeanDefinitionParserDelegate#parseBeanDefinitionElement(Element ele, ...) 方法。该方法会依次解析 <bean> 标签的属性、各个子元素，解析完成后返回一个 GenericBeanDefinition 实例对象。
* 解析默认标签下的自定义标签：BeanDefinitionParserDelegate#decorateBeanDefinitionIfRequired(Element ele, BeanDefinitionHolder definitionHolder) 方法。
* 注册解析的 BeanDefinition：BeanDefinitionReaderUtils#registerBeanDefinition(BeanDefinitionHolder definitionHolder, BeanDefinitionRegistry registry) 方法。


### 13 【死磕 Spring】—— IoC 之解析自定义标签





























































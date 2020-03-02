


classpath就是代表  /WEB-INF /classes/  这个路径（如果不理解该路径，就把一个web工程发布为war包，然后用winrar查看其包内路径就理解啦）


## Resource

```
  FileSystemResource ：对 java.io.File 类型资源的封装，只要是跟 File 打交道的，基本上与 FileSystemResource 也可以打交道。支持文件和 URL 的形式，实现 WritableResource 接口，且从 Spring Framework 5.0 开始，FileSystemResource 使用 NIO2 API进行读/写交互。
  ByteArrayResource ：对字节数组提供的数据的封装。如果通过 InputStream 形式访问该类型的资源，该实现会根据字节数组的数据构造一个相应的 ByteArrayInputStream。
  UrlResource ：对 java.net.URL类型资源的封装。内部委派 URL 进行具体的资源操作。
  ClassPathResource ：class path 类型资源的实现。使用给定的 ClassLoader 或者给定的 Class 来加载资源。
  InputStreamResource ：将给定的 InputStream 作为一种资源的 Resource 的实现类。
```

 Spring 将资源的定义和资源的加载区分开了，Resource 定义了统一的资源，那资源的加载则由 ResourceLoader 来统一定义


 ## ClassLoader
 JVM 中内置了三个重要的 ClassLoader，分别是 BootstrapClassLoader、ExtensionClassLoader 和 AppClassLoader。

 ## IoC 之加载 BeanDefinition


## 应用上下文
spring应用上下文，说的简单点就是容器的对象，是对spring容器抽象的实现，我们常见的ApplicationContext本质上来说是一种维护Bean的定义和对象之间协作关系的高级接口，spring的核心是容器，有且不止一个容器：
① AnnotationConfigApplicationContext:从一个或多个基于java的配置类中加载上下文定义，适用于java注解的方式；

　　　　② ClassPathXmlApplicationContext:从类路径下的一个或多个xml配置文件中加载上下文定义，适用于xml配置的方式；

　　　　③ FileSystemXmlApplicationContext:从文件系统下的一个或多个xml配置文件中加载上下文定义，也就是说系统盘符中加载xml配置文件；

　　　　④ AnnotationConfigWebApplicationContext:专门为web应用准备的，适用于注解方式；

　　　　⑤ XmlWebApplicationContext:从web应用下的一个或多个xml配置文件加载上下文定义，适用于xml配置方式。

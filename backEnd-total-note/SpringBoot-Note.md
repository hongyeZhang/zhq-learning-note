
# SpringBoot 学习笔记

## 自动配置

### 注解学习
* @EnableConfigurationProperties 
    * 开启资源实体类的加载，也就是说开启配置文件映射为资源实体类的功能
    * 使使用 @ConfigurationProperties 注解的类生效
    * 如果一个配置类只配@Component注解，而没有使用@ConfigurationProperties，那么在IOC容器中是能获取到bean， 但会bean对象参数为null，
        报异常：java.lang.IllegalArgumentException: Key argument cannot be null.
    * 如果一个配置类只配置@ConfigurationProperties注解，而没有使用@Component，那么在IOC容器中是获取不到properties 配置文件转化的bean。
        说白了 @EnableConfigurationProperties 相当于把使用 @ConfigurationProperties 的类进行了一次注入。

* @ConditionalOnProperty
    * 解是开启条件化配置



### 启动流程
这篇文章讲的非常好！！！
https://www.cnblogs.com/zheting/p/6707035.html

自动配置实现
，最关键的要属@Import(EnableAutoConfigurationImportSelector.class)，借助EnableAutoConfigurationImportSelector，@EnableAutoConfiguration可以帮助SpringBoot应用将所有符合条件的@Configuration配置都加载到当前SpringBoot
创建并使用的IoC容器。
借助于Spring框架原有的一个工具类：SpringFactoriesLoader的支持，@EnableAutoConfiguration可以智能的自动配置功效才
得以大功告成！

SpringFactoriesLoader属于Spring框架私有的一种扩展方案，其主要功能就是从指定的配置文件META-INF/spring.factories加载配置。

@EnableAutoConfiguration自动配置的魔法骑士就变成了：从classpath中搜寻所有的META-INF/spring.factories配置文件，并将其中org.springframework.boot.autoconfigure.EnableutoConfiguration对应的配置项通过反射（Java Refletion）实例化为对应的标注了@Configuration的JavaConfig形式的IoC容器配置类，然后汇总为一个并加载到IoC容器。


#### SpringApplication执行流程
SpringApplication的run方法的实现是我们本次旅程的主要线路，该方法的主要流程大体可以归纳如下：

1） 如果我们使用的是SpringApplication的静态run方法，那么，这个方法里面首先要创建一个SpringApplication对象实例，然后调用这个创建好的SpringApplication的实例方法。在SpringApplication实例初始化的时候，它会提前做几件事情：

    根据classpath里面是否存在某个特征类（org.springframework.web.context.ConfigurableWebApplicationContext）来决定是否应该创建一个为Web应用使用的ApplicationContext类型。

    使用SpringFactoriesLoader在应用的classpath中查找并加载所有可用的ApplicationContextInitializer。

    使用SpringFactoriesLoader在应用的classpath中查找并加载所有可用的ApplicationListener。

    推断并设置main方法的定义类。

2） SpringApplication实例初始化完成并且完成设置后，就开始执行run方法的逻辑了，方法执行伊始，首先遍历执行所有通过SpringFactoriesLoader可以查找到并加载的SpringApplicationRunListener。调用它们的started()方法，告诉这些SpringApplicationRunListener，“嘿，SpringBoot应用要开始执行咯！”。

3） 创建并配置当前Spring Boot应用将要使用的Environment（包括配置要使用的PropertySource以及Profile）。

4） 遍历调用所有SpringApplicationRunListener的environmentPrepared()的方法，告诉他们：“当前SpringBoot应用使用的Environment准备好了咯！”。

5） 如果SpringApplication的showBanner属性被设置为true，则打印banner。

6） 根据用户是否明确设置了applicationContextClass类型以及初始化阶段的推断结果，决定该为当前SpringBoot应用创建什么类型的ApplicationContext并创建完成，然后根据条件决定是否添加ShutdownHook，决定是否使用自定义的BeanNameGenerator，决定是否使用自定义的ResourceLoader，当然，最重要的，将之前准备好的Environment设置给创建好的ApplicationContext使用。

7） ApplicationContext创建好之后，SpringApplication会再次借助Spring-FactoriesLoader，查找并加载classpath中所有可用的ApplicationContext-Initializer，然后遍历调用这些ApplicationContextInitializer的initialize（applicationContext）方法来对已经创建好的ApplicationContext进行进一步的处理。

8） 遍历调用所有SpringApplicationRunListener的contextPrepared()方法。

9） 最核心的一步，将之前通过@EnableAutoConfiguration获取的所有配置以及其他形式的IoC容器配置加载到已经准备完毕的ApplicationContext。

10） 遍历调用所有SpringApplicationRunListener的contextLoaded()方法。

11） 调用ApplicationContext的refresh()方法，完成IoC容器可用的最后一道工序。

12） 查找当前ApplicationContext中是否注册有CommandLineRunner，如果有，则遍历执行它们。

13） 正常情况下，遍历执行SpringApplicationRunListener的finished()方法、（如果整个过程出现异常，则依然调用所有SpringApplicationRunListener的finished()方法，只不过这种情况下会将异常信息一并传入处理）


================   基本操作   ====================
默认引入jar包，内置了tomcat等

springboot   dev-tools 提供热部署功能，代码改变之后重新启动部署，提高调试速度。
IDEA  中进行热部署

右键 -> show in explorer  快速打开当前文件所在的目录
maven  package 将程序打包，java -jar 将打好的包运行

netstat -aon|findstr "8080"   查询指定端口的PID 号
然后通过任务管理器可以将应用杀死。
或者 使用命令行  taskkill /pid 12448 -t -f    其中12448为PID号


================   chapter 3 4 配置文件   ====================
classpath 路径
1、spring boot默认加载文件的路径：
    /META-INF/resources/
    /resources/
    /static/
    /public/

我们也可以从spring boot源码也可以看到：
private static final String[] CLASSPATH_RESOURCE_LOCATIONS = {
    "classpath:/META-INF/resources/",
    "classpath:/resources/",
    "classpath:/static/",
    "classpath:/public/" };

YAML配置文件：springboot 的官方推荐配置文件形式
（1）冒号后面需要添加空格
多环境配置：
可以将公共的配置文件配置在  application.properties
将多个环境的配置于application-dev.properties   application-test.properties  等
maven 打包  clean + package
在命令行运行不同环境： java -jar  jarName.jar --spring.profiles.active=test

YAML 中  通过三个横线区分不同的使用环境

================   chapter 5 日志配置   ====================
logback-spring.xml  默认logback  可以设置日志的存储位置、打印格式等
如果想改成log4j2，则需要将logback对应的包从pom依赖中去除

性能比较：Log4J2 和 Logback 都优于 log4j（不推荐使用）
配置方式：Logback最简洁，spring boot默认，推荐使用


================   chapter6  模板引擎 freemarker   ====================
写html的   但是后缀名为ftl，没有做到前后端分离

================   chapter7  模板引擎 thymeleaf   ====================
没什么可写的

================   chapter9  错误处理   ====================
针对 /error  路径重新改写了一些内容，重新定义error页面的内容，没什么可写的

================   chapter10  servlet filter listener   ====================
有三种配置方法
方法一：通过注册 ServletRegistrationBean、 FilterRegistrationBean 和 ServletListenerRegistrationBean 获得控制
方法二：通过实现 ServletContextInitializer 接口直接注册

implements ServletContextInitializer {

@Override
public void onStartup(ServletContext servletContext) throws
ServletException {
servletContext.addServlet("customServlet", new
CustomServlet()).addMapping("/roncoo"); servletContext.addFilter("customFilter", new
CustomFilter()).addMappingForServletNames(EnumSet.of(DispatcherType.REQUES T), true, "customServlet");
servletContext.addListener(new CustomListener());
}

  方法三：在 SpringBootApplication 上使用@ServletComponentScan 注解后，直接通过@WebServlet、
@WebFilter、@WebListener 注解自动注册

================   chapter11  cors支持   ====================
跨域请求的相关配置

================   chapter12  文件上传   ====================
spring.servlet.multipart  多文件上传的springboot默认配置


================   chapter13  使用SQL关系型数据库   ====================
(1) 嵌入式数据库（如h2），只需引入对应的jar包
jdbcTempalte的使用，基本的使用方式，没什么可写的


================   chapter17  redis使用   ====================
spring-data-jpa


================   chapter18  mongoDB使用   ====================
作为任务系统的学习一下


================   chapter19  Caching EhCache   ====================
hCache 是一个纯Java的进程内缓存框架，具有快速、精干等特点，是Hibernate中默认的CacheProvider。


================   基本操作   ====================
默认引入jar包，内置了tomcat等

springboot   dev-tools 提供热部署功能，代码改变之后重新启动部署，提高调试速度。
IDEA  中进行热部署

右键 -> show in explorer  快速打开当前文件所在的目录
maven  package 将程序打包，java -jar 将打好的包运行

netstat -aon|findstr "8080"   查询指定端口的PID 号
然后通过任务管理器可以将应用杀死。
或者 使用命令行  taskkill /pid 12448 -t -f    其中12448为PID号


================   chapter 3 4 配置文件   ====================
classpath 路径
1、spring boot默认加载文件的路径：
    /META-INF/resources/
    /resources/
    /static/
    /public/

我们也可以从spring boot源码也可以看到：
private static final String[] CLASSPATH_RESOURCE_LOCATIONS = {
    "classpath:/META-INF/resources/",
    "classpath:/resources/",
    "classpath:/static/",
    "classpath:/public/" };

YAML配置文件：springboot 的官方推荐配置文件形式
（1）冒号后面需要添加空格
多环境配置：
可以将公共的配置文件配置在  application.properties
将多个环境的配置于application-dev.properties   application-test.properties  等
maven 打包  clean + package
在命令行运行不同环境： java -jar  jarName.jar --spring.profiles.active=test

YAML 中  通过三个横线区分不同的使用环境

================   chapter 5 日志配置   ====================
logback-spring.xml  默认logback  可以设置日志的存储位置、打印格式等
如果想改成log4j2，则需要将logback对应的包从pom依赖中去除

性能比较：Log4J2 和 Logback 都优于 log4j（不推荐使用）
配置方式：Logback最简洁，spring boot默认，推荐使用


================   chapter6  模板引擎 freemarker   ====================
写html的   但是后缀名为ftl，没有做到前后端分离

================   chapter7  模板引擎 thymeleaf   ====================
没什么可写的

================   chapter9  错误处理   ====================
针对 /error  路径重新改写了一些内容，重新定义error页面的内容，没什么可写的

================   chapter10  servlet filter listener   ====================
有三种配置方法
方法一：通过注册 ServletRegistrationBean、 FilterRegistrationBean 和 ServletListenerRegistrationBean 获得控制
方法二：通过实现 ServletContextInitializer 接口直接注册

implements ServletContextInitializer {

@Override
public void onStartup(ServletContext servletContext) throws
ServletException {
servletContext.addServlet("customServlet", new
CustomServlet()).addMapping("/roncoo"); servletContext.addFilter("customFilter", new
CustomFilter()).addMappingForServletNames(EnumSet.of(DispatcherType.REQUES T), true, "customServlet");
servletContext.addListener(new CustomListener());
}

  方法三：在 SpringBootApplication 上使用@ServletComponentScan 注解后，直接通过@WebServlet、
@WebFilter、@WebListener 注解自动注册

================   chapter11  cors支持   ====================
跨域请求的相关配置

================   chapter12  文件上传   ====================
spring.servlet.multipart  多文件上传的springboot默认配置


================   chapter13  使用SQL关系型数据库   ====================
(1) 嵌入式数据库（如h2），只需引入对应的jar包
jdbcTempalte的使用，基本的使用方式，没什么可写的


================   chapter14  使用SQL关系型数据库   ====================
spring-data-jpa

此教程就是扫盲的，


==============  chapter01  简介  =====================
使用spring生态下所有技术的框架
四大核心机制：
（1）起步依赖机制，简化jar包的引用，解决jar版本冲突等
（2）自动配置。简单配置以搭建整套框架
（3）springboot cli  命令行
（4）actuator  程序监控器：监控bean controller 以及程序的健康情况等。

框架构建方式  四种 网站建立项目、cli、手动引入jar包等
项目结构：
static：静态资源的默认存放路径
tempaltes：动态资源的默认存放路径
application.properties  程序的相关参数配置

==============  chapter02  springboot起步依赖机制  =====================
降低项目依赖的复杂性，起步依赖的版本是根据springboot的版本确定的
<exclusions> </exclusions>
在pom文件中去掉指定的jar包，选择自己喜欢的jar包
引入自己需要的jar版本，则会自动覆盖springboot的默认依赖版本

==============  chapter03  springboot自动配置  =====================
是一个程序启动时的过程，决定用哪个配置
eg： jdbcTempalte的使用
JdbcTemplateAutoConfiguration   根据datasource 等进行自动配置
@ConditionalOnClass({ DataSource.class, JdbcTemplate.class })
@ConfigurationProperties(prefix = "spring.datasource") 将配置文件中的项目注入该类的变量
可以通过该注释自己写一个配置类，在配置文件中定义相关的配置属性

==============  chapter04  springboot cli  =====================
没仔细看，待有需要再说

==============  chapter05  actuator  =====================
在应用程序里提供众多的web端点，了解应用程序运行时的内部状况
引入对应的maven依赖就可以使用
dev-tools 启动自动build之后，若pom文件发生改变，则需要手动重启应用才能生效
management.endpoints.web.exposure.include = *  设置暴露或者隐藏端口
可以通过端点路径配置  去掉 /actuator 前缀
/actuator
/configprops   /info  将要获取的信息  /conditions   /mappings   /httptrace 等重要端口
/shutdown 端口需要额外配置

==============  chapter06  热部署  =====================
spring-boot-devtools  热部署，不需要重启
 pom文件中还需要做对应的设置
 <optional> 取消传递依赖
 additional-path  监听的文件夹配置
 spring.devtools.restart.exclude = 默认不重启目录
通过更改目录，确定哪些目录的修改能够导致重启，哪些不能

 ==============  chapter07  mybatis集成  =====================
dependency:
mybatis-spring-boot-starter
mysql-connnector-java
配置：DataSource
配置映射：mapper:  classpath:mapper/*.xml，可以直接在resources文件下建立对应的目录
@mapper的映射  定义接口，添加对应的xml文件

 ==============  chapter08  Security集成  =====================
spring-boot-starter-security
在启动时默认生成一个user  security  password  作为请求页面接口时的一个密码
user   UUID
可以通过属性配置来确定登录的用户名和密码   application.properties
主要是涉及到权限部分，比较简单的实现，实际不会如视频中一样操作。

 ==============  chapter09  redis集成  =====================
引入依赖，配置连接参数
spring-boot-setarter-data-redis
jedis 客户端， 配置jedis pool 连接池的配置


## SpringApplication构造方法
SpringApplication类的作用

　　　　SpringApplication用于从java main方法引导和启动Spring应用程序，默认情况下，将执行以下步骤来引导我们的应用程序：
　　　　　　1、创建一个恰当的ApplicationContext实例（取决于类路径）
　　　　　　2、注册CommandLinePropertySource，将命令行参数公开为Spring属性
　　　　　　3、刷新应用程序上下文，加载所有单例bean
　　　　　　4、触发全部CommandLineRunner bean
　　　　   大多数情况下，像SpringApplication.run(ShiroApplication.class, args);这样启动我们的应用，也可以在运行之前创建和
           自定义SpringApplication实例，具体可以参考注释中示例。
　　　　    SpringApplication可以从各种不同的源读取bean。 通常建议使用单个@Configuration类来引导，但是我们也可以通过以下方式来设置资源：
　　　　　　1、通过AnnotatedBeanDefinitionReader加载完全限定类名
　　　　　　2、通过XmlBeanDefinitionReader加载XML资源位置，或者是通过GroovyBeanDefinitionReader加载groovy脚本位置
　　　　　　3、通过ClassPathBeanDefinitionScanner扫描包名称


SpringApplication构造方法主要是三个函数
deduceWebApplicationType();

getSpringFactoriesInstances(xxx.class);

deduceMainApplicationClass();

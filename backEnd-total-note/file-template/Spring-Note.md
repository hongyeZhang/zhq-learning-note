

## Sring 配置文件模板
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
                           http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context.xsd">
</beans>
```


## 配置文件解释

xmlns, xmlns:xsi, xsi:schemaLocation 解释
xmlnsxsischemaLocation
我们在写 xml 文件时，尤其是 spring 、mybatis 的配置文件时，经常会用到上 xmlns、xmlns:xsi、xsi:schemaLocation 等元素，但多数时候大家都是直接拷贝，并未真正理解这三个元素的具体含义。

```xml
<?xml version="1.0" encoding="utf-8" ?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
                           http://www.springframework.org/schema/beans/spring-beans-4.3.xsd">

    <bean id="bean" class="com.feshfans.Bean"></bean>
</beans>
```
xmlns
xmlns 的全称为 xml namespace，即 xml 命名空间，这个很好理解，和 java 中 package 和 c# 中 namespace 的概念基本一致，起的作用也基本一致：区分重复元素

xmlns 格式定义如下：
xmlns[:name] = "uri"

默认命名空间
name 可以忽略不填，即为默认命名空间，如：

xmlns="http://www.springframework.org/schema/beans"
表现效果则为命名空间中的元素可以不加前辍，在此 xml 中直接使用，如上面的

<bean id="bean" class="com.feshfans.Bean"></bean>   // bean 元素可以直接使用
自定义命名空间
我们也可以自定义命名空间的名称，如：

xmlns:context = "http://www.springframework.org/schema/context"  // context 名称可以随便起，如 abc
表现效果为，我们在 xml 文件中使用此命名空间下的元素时，必须加上 context 前辍，如：

<context:component-scan base-package="com.feshfans"></context:component-scan>
为什么？
假如 xml 没有命名空间，spring 定义了 bean 元素，mybatis 也定义了 bean 元素，那么我们使用的是哪个 bean 元素呢？显示易见， xmlns 解决了元素冲突的问题

xmlns:xsi
这本质就是声明一个名为 xsi 的命名空间，其值为一个标准的命名空间

xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
此命名空间还定义了 xsi:type, xsi:nil, xsi:schemaLocation 等属性

虽然 xsi 也可以随意用别的名称替换，但不建议这样做。xsi 已经是通用的写法, 是 xml schema instance 的缩写，可以看成是固定写法。

xsi:schemaLocation
此为 xsi 命名空间中定义的一个属性，用于通知 xml 处理器 xml 文档与 xsd 文件的关联关系。

xsi:schemaLocation="http://www.springframework.org/schema/beans
                           http://www.springframework.org/schema/beans/spring-beans-4.3.xsd">
这里需要注意的是：命名空间和 命名空间的 xsd (xml schema defination，定义了命名空间下元素的写法) 必须成对出现，中间用空格分分隔；可以填写多个对应关系。
这也是一个通用的写法，可以理解为固定写法。

其实，命名空间与其对应的 xsd 文件我们在 jar 中一般都是可以发现的，以 spring-beans.jar 为例：
在 META-INF 目录下，spring.tooling 文件中可以找到命名空间的值，在 spring.schemas 文件中可以找到 xsd 文件的值，同时此文件中也定义了离线 xsd 文件的位置。



schemaLocation提供了一个xml namespace到对应的XSD文件的一个映射，所以我们可以看到，在xsi:schemaLocation后面配置的字符串都是成对的，前面的是namespace的URI，后面是xsd文件的URI。


## 为什么在Spring的配置里，最好不要配置xsd文件的版本号
我们的应用的Spring配置文件里有类似的配置：
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:dubbo="http://code.alibabatech.com/schema/dubbo"
  xsi:schemaLocation="http://www.springframework.org/schema/beans
          http://www.springframework.org/schema/beans/spring-beans.xsd
          http://code.alibabatech.com/schema/dubbo
          http://code.alibabatech.com/schema/dubbo/dubbo.xsd">
我们都知道Spring在启动时是要检验XML文件的。或者为什么在Eclipse里xml没有错误提示？

比如这样的一个Spring配置：

<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">
</beans>
我们也可以在后面加上版本号：

xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-3.0.xsd">
有这个版本号和没有有什么区别呢？

XML的一些概念
首先来看下xml的一些概念：

xml的schema里有namespace，可以给它起个别名。比如常见的spring的namespace：

xmlns:mvc="http://www.springframework.org/schema/mvc"
  xmlns:context="http://www.springframework.org/schema/context"
通常情况下，namespace对应的URI是一个存放XSD的地址，尽管规范没有这么要求。如果没有提供schemaLocation，那么Spring的XML解析器会从namespace的URI里加载XSD文件。我们可以把配置文件改成这个样子，也是可以正常工作的：

<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans/spring-beans.xsd"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
schemaLocation提供了一个xml namespace到对应的XSD文件的一个映射，所以我们可以看到，在xsi:schemaLocation后面配置的字符串都是成对的，前面的是namespace的URI，后面是xsd文件的URI。比如：

xsi:schemaLocation="http://www.springframework.org/schema/beans
  http://www.springframework.org/schema/beans/spring-beans.xsd
  http://www.springframework.org/schema/security
  http://www.springframework.org/schema/security/spring-security.xsd"
Spring是如何校验XML的
Spring默认在启动时是要加载XSD文件来验证xml文件的，所以如果有的时候断网了，或者一些开源软件切换域名，那么就很容易碰到应用启动不了。我记得当时Oracle收购Sun公司时，遇到过这个情况。

为了防止这种情况，Spring提供了一种机制，默认从本地加载XSD文件。打开spring-context-3.2.0.RELEASE.jar，可以看到里面有两个特别的文件：

spring.handlers

http\://www.springframework.org/schema/context=org.springframework.context.config.ContextNamespaceHandler
http\://www.springframework.org/schema/jee=org.springframework.ejb.config.JeeNamespaceHandler
http\://www.springframework.org/schema/lang=org.springframework.scripting.config.LangNamespaceHandler
http\://www.springframework.org/schema/task=org.springframework.scheduling.config.TaskNamespaceHandler
http\://www.springframework.org/schema/cache=org.springframework.cache.config.CacheNamespaceHandler
spring.schemas

http\://www.springframework.org/schema/context/spring-context-2.5.xsd=org/springframework/context/config/spring-context-2.5.xsd
http\://www.springframework.org/schema/context/spring-context-3.0.xsd=org/springframework/context/config/spring-context-3.0.xsd
http\://www.springframework.org/schema/context/spring-context-3.1.xsd=org/springframework/context/config/spring-context-3.1.xsd
http\://www.springframework.org/schema/context/spring-context-3.2.xsd=org/springframework/context/config/spring-context-3.2.xsd
http\://www.springframework.org/schema/context/spring-context.xsd=org/springframework/context/config/spring-context-3.2.xsd
...
再打开jar包里的org/springframework/context/config/ 目录，可以看到下面有

spring-context-2.5.xsd
spring-context-3.0.xsd
spring-context-3.1.xsd
spring-context-3.2.xsd

很明显，可以想到Spring是把XSD文件放到本地了，再在spring.schemas里做了一个映射，优先从本地里加载XSD文件。

并且Spring很贴心，把旧版本的XSD文件也全放了。这样可以防止升级了Spring版本，而配置文件里用的还是旧版本的XSD文件，然后断网了，应用启动不了。

我们还可以看到，在没有配置版本号时，用的就是当前版本的XSD文件：

http\://www.springframework.org/schema/context/spring-context.xsd=org/springframework/context/config/spring-context-3.2.xsd
同样，我们打开dubbo的jar包，可以在它的spring.schemas文件里看到有这样的配置：

http\://code.alibabatech.com/schema/dubbo/dubbo.xsd=META-INF/dubbo.xsd
所以，Spring在加载dubbo时，会从dubbo的jar里加载dubbo.xsd。

如何跳过Spring的XML校验？
可以用这样的方式来跳过校验：

GenericXmlApplicationContext context = new GenericXmlApplicationContext();
context.setValidating(false);
如何写一个自己的spring xml namespace扩展
可以参考Spring的文档，实际上是相当简单的。只要实现自己的NamespaceHandler，再配置一下spring.handlers和spring.schemas就可以了。

http://docs.spring.io/spring/docs/current/spring-framework-reference/html/extensible-xml.html

其它的一些东东
防止XSD加载不成功的一个思路
http://hellojava.info/?p=135

齐全的Spring的namespace的列表
http://stackoverflow.com/questions/11174286/spring-xml-namespaces-how-do-i-find-what-are-the-implementing-classes-behind-t

Spring core
aop  -  AopNamespaceHandler
c  -  SimpleConstructorNamespaceHandler
cache  -  CacheNamespaceHandler
context  -  ContextNamespaceHandler
jdbc  -  JdbcNamespaceHandler
jee  -  JeeNamespaceHandler
jms  -  JmsNamespaceHandler
lang  -  LangNamespaceHandler
mvc  -  MvcNamespaceHandler
oxm  -  OxmNamespaceHandler
p  -  SimplePropertyNamespaceHandler
task  -  TaskNamespaceHandler
tx  -  TxNamespaceHandler
util  -  UtilNamespaceHandler
Spring Security
security  -  SecurityNamespaceHandler
oauth  -  OAuthSecurityNamespaceHandler
Spring integration
int  -  IntegrationNamespaceHandler
amqp  -  AmqpNamespaceHandler
event  -  EventNamespaceHandler
feed  -  FeedNamespaceHandler
file  -  FileNamespaceHandler
ftp  -  FtpNamespaceHandler
gemfire  -  GemfireIntegrationNamespaceHandler
groovy  -  GroovyNamespaceHandler
http  -  HttpNamespaceHandler
ip  -  IpNamespaceHandler
jdbc  -  JdbcNamespaceHandler
jms  -  JmsNamespaceHandler
jmx  -  JmxNamespaceHandler
mail  -  MailNamespaceHandler
redis  -  RedisNamespaceHandler
rmi  -  RmiNamespaceHandler
script  -  ScriptNamespaceHandler
security  -  IntegrationSecurityNamespaceHandler
sftp  -  SftpNamespaceHandler
stream  -  StreamNamespaceHandler
twitter  -  TwitterNamespaceHandler
ws  -  WsNamespaceHandler
xml  -  IntegrationXmlNamespaceHandler
xmpp  -  XmppNamespaceHandler
总结：
为什么不要在Spring的配置里，配置上XSD的版本号？
因为如果没有配置版本号，取的就是当前jar里的XSD文件，减少了各种风险。
而且 这样约定大于配置的方式很优雅。


## Dubbo 源码学习笔记
* reference   http://svip.iocoder.cn/Dubbo/configuration-api-2/


## 基础
* URL 作为一个通用模型，贯穿整个 RPC 流程


## 初始化过程
### 1 解析服务
* 基于 dubbo.jar 内的 META-INF/spring.handlers 配置，Spring 在遇到 dubbo 名称空间时，会回调 DubboNamespaceHandler。
* 所有 dubbo 的标签，都统一用 DubboBeanDefinitionParser 进行解析，基于一对一属性映射，将 XML 标签解析为 Bean 对象。
* 在 ServiceConfig.export() 或 ReferenceConfig.get() 初始化时，将 Bean 对象转换 URL 格式，所有 Bean 属性转成 URL 的参数。
* 将 URL 传给 协议扩展点，基于扩展点的 扩展点自适应机制，根据 URL 的协议头，进行不同协议的服务暴露或引用。



* 在Spring初始化完成Bean的组装，会调用InitializingBean的afterPropertiesSet方法，在Spring容器加载完成，会接收到事件ContextRefreshedEvent，
    调用ApplicationListener的onApplicationEvent方法
* 在afterPropertiesSet中，和onApplicationEvent中，会调用export()，在export()中，会暴露dubbo服务，具体区别在于是否配置了delay属性，是否延迟暴露，
    如果delay不为null，或者不为-1时，会在afterPropertiesSet中调用export()暴露dubbo服务，如果为null,或者为-1时，会在Spring容器初始化完成，
    接收到ContextRefreshedEvent事件，调用onApplicationEvent，暴露dubbo服务

作者：一滴水的坚持
链接：https://www.jianshu.com/p/7f3871492c71
来源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

链接：https://www.jianshu.com/p/7f3871492c71


### 2 解析服务



## 与spring 整合的方式
* duubo作为spring的扩展 
    * spring提供了对schema的扩展，开发者可以自己定义schema文件，并定义其相应的解析器以及与spring ioc的集成
    * 实现schema扩展一般的步骤
        * 定义xsd文件
        * 定义NamespaceHandler  DubboNamespaceHandler
        * 定义BeanDefinitionParse，即Bean的解析器
        * 配置NameSpace对应的xsd文件
        * 配置NameSpace对应的Handler类
    * spring会调用DubboNamespaceHandler中的init方法，注册dubbo标签对应的BeanDefinitionParser解析器以及其对应的实现










## chapter1 精尽 Dubbo 源码分析 —— API 配置（一）之应用
所有配置最终都将转换为 Dubbo URL 表示，并由服务提供方生成，经注册中心传递给消费方，各属性对应 URL 的参数，参见配置项一览表中的 “对应URL参数” 列

dubbo://192.168.3.17:20880/com.alibaba.dubbo.demo.DemoService?anyhost=true&application=demo-provider&default.delay=-1&default.retries=0&default.service.filter=demoFilter&delay=-1&dubbo=2.0.0&generic=false&interface=com.alibaba.dubbo.demo.DemoService&methods=sayHello&pid=19031&side=provider&timestamp=1519651641799


## chapter2 精尽 Dubbo 源码分析 —— API 配置（二）之服务提供者



## chapter8 精尽 Dubbo 源码分析 —— 核心流程一览
















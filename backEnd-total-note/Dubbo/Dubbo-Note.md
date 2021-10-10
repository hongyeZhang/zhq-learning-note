
# Dubbo

## 1 简介
* 三大核心能力：面向接口的远程方法调用、智能容错和负载均衡、服务自动注册与发现
* 通过分层的方式来架构，服务提供者: provider 服务消费者: consumer

* 通信模型：
    * BIO 同步并堵塞
    * NIO 同步非堵塞
    * AIO 彻底的异步通信

* 五大组件角色：
    * provider: 暴露服务的服务提供方
    * consumer: 调用远程服务的服务消费方
    * registry: 服务注册与发现的注册中心
    * monitor: 统计服务的调用次数和调用时间的监控中心
    * container: 服务运行容器

## 2 实战笔记
* 启动 dubbo-admin 后台管理系统
```shell script
mvn --projects dubbo-admin-server spring-boot:run
cd dubbo-admin-distribution/target; java -jar dubbo-admin-0.1.jar
```

### dubbo接口的mock功能
* https://www.jianshu.com/p/e1a78e95a4d6
dubbo中的不是用来测试的，是用来降级使用的。用于服务降级，比如某验权服务，当服务提供方全部挂掉后，客户端不抛出异常，而是通过 Mock 数据返回授权失败。


mock怎么使用？
同stub，mock也有两种使用方式

在相同接口的包中创建一个名为InterfaceName+Mock的类，该类必须实现该Interface，设置@Reference(mock = "true")
Consumer端自定义Mock类，名字随意，设置全限定名@Reference(mock = "com....MyMock")






## 3 源码笔记
### 3.1 整体框架设计

![dubbo-framework](../picture/dubbo/dubbo-framework.jpeg)


### dubbo SPI 
* com.alibaba.dubbo.common.extension.ExtensionLoader#getExtension

createExtension

* injectExtension
    * 通过 set 方法进行注入，类似于一个IOC的过程


* dubbo 为什么要自己设计一套 SPI 
    * java SPI 的不支持单独获取某一个实例，必须是循环获取
    * java SPI 没有缓存的体系
    * dubbo可以支持默认的设置
    * java SPI 不支持 IOC  AOP


* 服务发布初步流程
    * ServiceBean
    * 暴露本地服务
    * 暴露远程服务
    * 启动netty
    * 注册、监听 zookeeper
* 服务引入的流程
    * ReferenceBean

    

* 服务发布和导出
    * com.alibaba.dubbo.config.spring.ServiceBean#export
    
* 服务暴露 exporter -> invoker 
* 服务引入 refer -> invoker



### consumer 问题
* consumer 监听 configurators routers providers





## 服务降级与负载均衡













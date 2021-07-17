
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

## 3 源码笔记
### 3.1 整体框架设计

![dubbo-framework](../picture/dubbo/dubbo-framework.jpeg)


### dubbo SPI 









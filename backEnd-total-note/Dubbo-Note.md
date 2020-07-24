
# Dubbo

## 参考链接
* http://dubbo.apache.org/zh-cn/blog/dubbo-invoke.html






## 简介
三大核心能力：
面向接口的远程方法调用、智能容错和负载均衡、服务自动注册与发现
通过分层的方式来架构，
服务提供者: provider
服务消费者: consumer

http://dubbo.apache.org/zh-cn/blog/dubbo-101.html
通过官网上的快速开始文档学习


通信模型：
BIO 同步并堵塞
NIO 同步非堵塞
AIO 彻底的异步通信

五大组件角色：
provider: 暴露服务的服务提供方
consumer: 调用远程服务的服务消费方
registry: 服务注册与发现的注册中心
monitor: 统计服务的调用次数和调用时间的监控中心
container: 服务运行容器


启动dubbo的后台管理系统
mvn --projects dubbo-admin-server spring-boot:run
或者
cd dubbo-admin-distribution/target; java -jar dubbo-admin-0.1.jar


===========================  dubbo  第一个程序
com.zhq
hello-dubbo-service-user-api
hello-dubbo-service-user-provider

消费者的实现视频
https://www.bilibili.com/video/av35685648/?p=19


## 实战笔记
### 调用方式

* 






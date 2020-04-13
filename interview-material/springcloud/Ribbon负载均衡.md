# Ribbon负载均衡

**eureka-provider**  ==> {localhost:8070, localhost:8071, localhost:8072} （一个可用服务的列表）



## Ribbon配置

<clientName>.<nameSpace>.<propertyName>=<value>

如果配置项没有<clientName>，表示全局配置。

详细配置项参考：**CommonClientConfigKey**



## 重试机制

```properties
## 断路器超时时间
hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=1000
## 请求连接超时时间
eurekaClient.ribbon.ConnectTimeout=200
## 请求处理超时时间
eurekaClient.ribbon.ReadTimeout=200
## 对所有操作请求都进行重试
eurekaClient.ribbon.OkToRetryOnAllOperations=true
## 切换实例的重试次数
eurekaClient.ribbon.MaxAutoRetriesNextServer=2
## 对当前实例的重试次数
eurekaClient.ribbon.MaxAutoRetries=1
```



RestTemplate 就是封装了不同的Http客户端

Apache HttpClient 是一种Http客户端

OkHttp3 一种HTTP客户端



### **ClientHttpRequestFactory**

```java
public RestTemplate(ClientHttpRequestFactory requestFactory) {
    this();
    setRequestFactory(requestFactory);
}
```










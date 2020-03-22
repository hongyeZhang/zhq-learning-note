# Eureka 高可用

## 服务端高可用

spring.profiles.active=peer1

```java
## Eureka注册中心实例名
spring.application.name=eureka-server
## Eureka注册中心端口
server.port=9091

## 关闭Actuator验证开关
management.security.enabled=false

## 不向注册中心获取服务列表
eureka.client.fetch-registry=true
## 不注册到注册中心上
eureka.client.register-with-eureka=true

## 配置 注册中心的 地址
eureka.client.service-url.defaultZone=http://localhost:9092/eureka

## 关闭自我保护机制  不建议用
#eureka.server.enable-self-preservation=false

```



spring.profiles.active=peer2

```java
## Eureka注册中心实例名
spring.application.name=eureka-server
## Eureka注册中心端口
server.port=9092

## 关闭Actuator验证开关
management.security.enabled=false

## 不向注册中心获取服务列表
eureka.client.fetch-registry=true
## 不注册到注册中心上
eureka.client.register-with-eureka=true

## 配置 注册中心的 地址
eureka.client.service-url.defaultZone=http://localhost:9091/eureka

## 关闭自我保护机制  不建议用
#eureka.server.enable-self-preservation=false

```





Eureka Server 两个就足够了 

A  B

A(X)  B

A  B(X)  



## 客户端高可用





# Eureka 原理分析

@EnableDiscoveryClient



启动DiscoveryClient

![1556281809051](C:\Users\luopeng\AppData\Roaming\Typora\typora-user-images\1556281809051.png)

接口：org.springframework.cloud.client.discovery.**DiscoveryClient**



接口：com.netflix.discovery.**EurekaClient**

类：com.netflix.discovery.**DiscoveryClient**



### EurekaClient

**Applications**：注册在Eureka Server上的应用集合。-- 对应多个**Application**

**Application**：具体的一个应用（eureka-provider）。-- 对应多个**InstanceInfo**(localhost:8070, localhost:8071, localhost:8072)

**InstanceInfo**：应用实例。 IP + Port





## 初始化

```java
if (clientConfig.shouldFetchRegistry()) {
            // registry cache refresh timer
            int registryFetchIntervalSeconds = clientConfig.getRegistryFetchIntervalSeconds();
            int expBackOffBound = clientConfig.getCacheRefreshExecutorExponentialBackOffBound();
            scheduler.schedule(
                    new TimedSupervisorTask(
                            "cacheRefresh",
                            scheduler,
                            cacheRefreshExecutor,
                            registryFetchIntervalSeconds,
                            TimeUnit.SECONDS,
                            expBackOffBound,
                            new CacheRefreshThread()
                    ),
                    registryFetchIntervalSeconds, TimeUnit.SECONDS);
        }
```

1、一个从注册中心获取服务列表的任务，频率：registryFetchIntervalSeconds（默认30s）

```java
// Heartbeat timer
            scheduler.schedule(
                    new TimedSupervisorTask(
                            "heartbeat",
                            scheduler,
                            heartbeatExecutor,
                            renewalIntervalInSecs,
                            TimeUnit.SECONDS,
                            expBackOffBound,
                            new HeartbeatThread()
                    ),
                    renewalIntervalInSecs, TimeUnit.SECONDS);
```

2、客户端启动一个心跳线程，向注册中心发送心跳，频率：renewalIntervalInSecs（默认30s）



```java
instanceInfoReplicator = new InstanceInfoReplicator(
                    this,
                    instanceInfo,
                    clientConfig.getInstanceInfoReplicationIntervalSeconds(),
                    2); // burstSize
```

3、客户端想注册中心注册自己，频率：InstanceInfoReplicationIntervalSeconds（默认30s）

定时的上报自己的信息 。





## 获取服务列表

客户端缓存服务列表：**DiscoveryClient**

```java
private final AtomicReference<Applications> localRegionApps = new AtomicReference<Applications>();
```



调用了一个'apps/'   get方法



serviceUrl: http://localhost:9091/eureka/apps/

服务端处理：**ResponseCacheImpl.getValue(Key, boolean)**

全量更新接口：com.netflix.eureka.resources.ApplicationsResource.getContainers(String, String, String, String, UriInfo, String)

```java
    @VisibleForTesting
    Value getValue(final Key key, boolean useReadOnlyCache) {
        Value payload = null;
        try {
            if (useReadOnlyCache) {
                final Value currentPayload = readOnlyCacheMap.get(key);
                if (currentPayload != null) {
                    payload = currentPayload;
                } else {
                    payload = readWriteCacheMap.get(key);
                    readOnlyCacheMap.put(key, payload);
                }
            } else {
                payload = readWriteCacheMap.get(key);
            }
        } catch (Throwable t) {
            logger.error("Cannot get value for key :" + key, t);
        }
        return payload;
    }
```



客户端读缓存（readOnlyCacheMap）存储了一份全量的服务列表，还有一份增量的服务列表



举例

客户端A 启动  获取客户端B+C(C1 C2 C3)		         	调用C1  失败   降级 重试  C2 C3

客户端B

客户端C（C1 C2 C3）                                          -（C1）宕机

服务端X





## 服务注册

每一个服务  Instance    -> Application  

IP + Port

客户端注册时， 不是注册为永久节点， 都有一个超时时间戳  90s



客户端请求： apps/appName   这是一个Post请求

```java
private final ConcurrentHashMap<String, Map<String, Lease<InstanceInfo>>> registry = new ConcurrentHashMap<String, Map<String, Lease<InstanceInfo>>>();
```

 instanceId 作为 实例的Key



**问题：**

- 1、什么时候新来的时间戳比本地的时间戳小？

A（任务）30 发一次注册请求     

​	第一次12:12:10：发送请求   网络延时了    50s（12:13:00）    old  过时

​	第二次12:12:40： 正常发送        12:12:41      对于客户端来说，  第二次是最新的实例  

- 2、那个老的如果是可用的 不注册 那这个服务还有什么用呢？

不是不注册， 只是网络没有到达

- sping cloud 注册的应用，怎么控制哪些方法暴露，哪些方法不暴露

注册中心只负责注册实例（IP+Port），具体的方法暴露 ，SpringCloud有两种方式  ：1、RestTemplate（Ribbon）；2、Feign

- client端获取appcations列表，再次获取增量appcations时，如果**增量appcations列表里有A**, 原来的appcations也有用哪个

如果“增量appcations列表里有A”，说明A更新了，A是最新的。 客户端一定会保存A 替换掉原来

## 心跳

 ### 客户端

调用了一个API： /apps/appName/id    Put 方法



客户端每一次续约 90s     lastUpdateTimestamp有效租约时间戳

```java
    public void renew() {
        lastUpdateTimestamp = System.currentTimeMillis() + duration;
    }
```



## 服务下线

```properties
## 启用shutdown
endpoints.shutdown.enabled=true
## 关闭密码验证
endpoints.shutdown.sensitive=false
```

调用了一个API： /apps/appName/id    Delete 方法

```Java
Map<String, Lease<InstanceInfo>> gMap = registry.get(appName);
Lease<InstanceInfo> leaseToCancel = null;
if (gMap != null) {
    leaseToCancel = gMap.remove(id);
}
```

设置evictionTimestamp ： 被移除的时间戳

```java
public void cancel() {
    if (evictionTimestamp <= 0) {
        evictionTimestamp = System.currentTimeMillis();
    }
}
```


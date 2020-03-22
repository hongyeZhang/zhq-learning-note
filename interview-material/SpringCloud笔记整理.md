
# SpringCloud 全家桶梳理

## Eureka
* spring cloud eureka 对 netflix eureka 做了二次封装
  使用适配器模式
* 客户端模式进行服务治理
* 自我保护机制，不立即注销，CAP中选择了AP
* Consul 强一致性 可用性的下降  CAP中，选择了CP， 放弃了A（可用性）

### 高可用原理
* 服务端高可用：两个eureka服务互相注册，保证高可用，两个即可
* 客户端高可用：将每个应用注册到两个eureka中


* 初始化，拉注册信息，获取服务列表， registryFetchIntervalSeconds 配置，默认30s
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

* 客户端启动一个心跳线程，向注册中心发送心跳， renewalIntervalInSecs 默认时间间隔30s
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

* 客户端向注册中心注册自己，instanceInfoReplicationIntervalSeconds  默认30s
```java
	private int instanceInfoReplicationIntervalSeconds = 30;
instanceInfoReplicator = new InstanceInfoReplicator(
        this,
        instanceInfo,
        clientConfig.getInstanceInfoReplicationIntervalSeconds(),
        2); // burstSize
```


#### 服务端原理

* 每个实例的默认续约时间是90s，通过心跳线程进行发送，每30s进行一次续约
* 服务下线
    - springboot 主动下线  调用/shutdown 接口，但是要关闭endpoint的密码验证





## Ribbon
* 负载均衡方式（与注册中心的实现方式有关）
    - 客户端负载均衡
    - 服务端负载均衡

* 使用时同样可以不需要与eureka完全绑定，直接引入，配置 app-name.ribbon.listOfServers:localhost:8081, localhost:8082 



```java
	public RestTemplate(ClientHttpRequestFactory requestFactory) {
		this();
		setRequestFactory(requestFactory);
	}
```




## Netflix-Hystrix容错保护
* 隔离分布式服务的故障
* 提供熔断器，当失败率超过阈值的时候，自动触发降级，请求直接降级，而不会走原来的流程，比如当发生网络故障的时候。
当网络情况好的时候，熔断器会自动恢复原来的流程，使用半开关的状态进行尝试性的恢复。


* hystrix 的核心线程数满了之后，没有拿到hystrix线程的tomcat任务将会直接走降级策略，而不是等待线程池中任务执行完毕

* 隔离的方式
    - 线程池
    - 信号量，能够节省线程的资源

1.业务场景
    * 功能:  线程隔离   目的: 管理线程资源   使得线程不会泛滥      最终的目的 为了保护服务节点 保障可用性
	* 场景:  并发的场景   都可以使用 
	
2.fallback怎么执行的	
	
熔断的三个统计条件: 时间长度\请求数量\错误比例
    作用: 保护服务,使它不会因为过载而无法提供服务
	
* 请求缓存 hystrix  请求折叠器
* 请求合并 

* TODO  源码分析部分暂停不看





## Feign

* 默认使用 ribbon 懒加载的模式，只有真正调用时才会加载，可以开启ribbon的饥饿加载模式
```properties
# 开启饥饿加载模式
ribbon.eager-load.enabled=true
# 指定加载的客户端名称
ribbon.eager-load.clients=product-service
```

### 生成 FeignClient 代理对象
#### 主要构造及请求流程
* 1、@FeignClient注解接口被代理；
* 2、根据@FeignClient注解与@RequestMapping注解的元数据封装请求；
* 3、通过代理对象执行请求；

**具体实现**
* ReflectiveFeign  newInstance
* SynchronousMethodHandler：MethodHandler的实现类，用于方法调用真正的拦截处理
* BuildTemplateByResolvingArgs：通过方法调用的参数，具体封装请求
* FeignInvocationHandler：FeignClient 动态代理对象中的InvocationHandler， 真正做请求拦截处理的角色
* LoadBalancerFeignClient
* LoadBalancerContext

### 连接池的配置问题










## Zuul

* 主要作用
    - 路由
    - 过滤
    - 认证
    - 
 
* 一系列 filter，基于JVM的路由器和负载均衡器

* demo实战
```properties
zuul: 9999
provider: 9091
consumer: 9092
eureka:8761
config-server:11000


```
 
 
 nginx -> zuul























## 与dubbo的区别

* SpringCloud 是个全家桶，功能点非常齐全










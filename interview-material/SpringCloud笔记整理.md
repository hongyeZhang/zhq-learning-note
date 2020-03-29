
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


zuulServlet  zuul的本质是通过servlet实现的
zuulController
HandlerMapping


本质是一些过滤器

springMVC
@requestMapping 精确匹配、正则匹配


zuul  1和2两个版本
springboot2.0 以上才能使用 gateway
实际使用 zuul1 版本


handler 是通过 url 将zuulController 找到

* preRoute() 可以做验证，里面是否有 token 之类的
* route()
* postRoute() 数据脱敏，计算执行时间等等 与AOP很像


```java
ZuulFilter 
String filterType();

int filterOrder();

boolean shouldFilter();

Object run();

```

当一个请求进来时，首先是进入 pre 过滤器，可以做一些鉴权，记录调试日志等操作。之后进入 routing 过滤器进行路由转发，转发可以使用 Apache HttpClient 或者是 Ribbon 。post 过滤器呢则是处理服务响应之后的数据，可以进行一些包装来返回客户端。 error 则是在有异常发生时才会调用，相当于是全局异常拦截器。





## Bus 消息总线
* 在微服务系统架构中，通常会使用消息代理来构建共用的消息主题，由于该主题中产生的消息会被所有实
  例监听和消费，故称之为消息总线

消息代理在应用程序之间进行消息调度并解耦应用间的依赖。消息代理的场景：
* 路由消息到一个或者多个目的地
* 将消息转化为其他表现形式
* 执行消息聚集、分解，并将结果发送到目的地
* 调用服务来检索数据
* 响应时间或错误
* 使用发布订阅模式来提供内容

主要用于实现微服务之间的通信

接受消息，发送事件



## Stream 
* 构建消息总线的基础

* 消息源头 source(output)  
* 消息接受者 sink(input)

绑定时不知道怎样实现， github 搜索 springcloud 即可
turbine  zipkin 
kafka 流处理平台

两个接口  sink  source  相加 = processor
* 消息聚合
* 消息分流：设置消息（header）， 消息体body(payload)

MessageBuilder  withHeader  通过设置不同的 header 内容，设置分流的 content
然后在 streamListener 中设置监听的  condition 来达到分流的目的


kafka -> 转换消息服务（比如数据脱敏 IP  ETL等） -> kafka

一个服务既是消费者也是生产者， @transformer


spring integration   轻量级的消息代理框架


binder : kafka rabbitMq redis 


SPI : service provider interface （厂商或者插件） 
* Dubbo
* sharding -jdbc
* atomikos  

通过配置文件的形式加载
spring SPI 的加载机制： 通过 spring.factories 配置文件





## sleuth
* JVM加载class文件的时候，利用工具将要监控的代码片段植入

* javassist （class method）
* asm (基于字节码的 cglib)

* java agent （无侵入式监控、热部署） 
    - java.lang.instrument.Instrumentation
    

服务端： zipkin 配置服务地址，采样率等
     - 增加 springcloud sleuth 依赖  zipkin server 依赖 zipkin-ui
     - 


* zipkin1 
    - http 拦截 
    - 数据持久

* zipkin2

* 采集 -> 存储 -> 分析挖掘
* springcloud sleuth -> kafka -> elasticsearch



* 服务监控框架
    - pinpoint
    - skywalking
    - zipkin
    - 阿里的鹰眼,美团的CAT


## config-server




```properties
#配置文件存放在本地的情况
#注意：文件夹要有访问权限
spring.profiles.active=native
spring.cloud.config.server.native.search-locations=C:/IdeaProjets/demo_configs/
```
















## 与dubbo的区别

* SpringCloud 是个全家桶，功能点非常齐全










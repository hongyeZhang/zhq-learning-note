# Feign

## 应用

1. 在消费者上引用依赖

   ```xml
       <dependency>
         <groupId>org.springframework.cloud</groupId>
         <artifactId>spring-cloud-starter-openfeign</artifactId>
       </dependency>
   ```

2. 在消费这创建客户端

   ```java
   /**
    * TODO : Feign客户端  -- 指向哪个服务呢？
    *
    * @author:Five-云析学院
    * @since:2019年05月12日 20:43
    */
   @FeignClient(name="product-service")
   public interface ProductService {
   
       @GetMapping("/updateProduct/{productName}/{num}")
       public String updateProduct(@PathVariable("productName") String productName, @PathVariable("num") Integer num) ;
   }
   ```

3. 在启动类添加注解 `@EnableFeignClients`

   ```java
   @SpringBootApplication
   @EnableDiscoveryClient
   @EnableFeignClients(clients = {ProductService.class})
   public class OrderApplication {
   
   	public static void main(String[] args) {
   		SpringApplication.run(OrderApplication.class, args);
   	}
   }
   ```

4. 使用-直接通过依赖注入调用API

   ```java
   @Autowired
   private ProductService productService;
   /***
        * 下单接口 --  调用服务提供者provider /updateProduct 接口
        * @param productName
        * @param num
        * @return
        */
   @GetMapping("/order/{productName}/{num}")
   public String order(@PathVariable("productName") String productName, @PathVariable("num") Integer num){
   
       if(productName != null && !productName.isEmpty()){
           list.add(new OrderInfo(productName, num));
   
           // 调用服务提供者
           //  String result = restTemplate.getForObject("http://product-service/updateProduct/" + productName + "/" + num, String.class);
   
           // 使用Feign调用客户端API
           String result = productService.updateProduct(productName, num);
           return result;
       }
       return null;
   }
   ```

   



## Ribbon饥饿加载模式

```properties
# 开启饥饿加载模式
ribbon.eager-load.enabled=true
# 指定加载的客户端名称
ribbon.eager-load.clients=product-service,product-service
```





## Feign源码分析

> 1、@FeignClient注解接口被代理；
> 2、根据@FeignClient注解与@RequestMapping注解的元数据封装请求；
> 3、通过代理对象执行请求；



### 第一步： 动态代理生成一个对象（FeignClient）



**ReflectiveFeign**

```java
public <T> T newInstance(Target<T> target) {
    // 建立FeignClient 中 方法与MethodHandler的映射关系
    Map<String, MethodHandler> nameToHandler = targetToHandlersByName.apply(target);
    // Method与MethodHandler的映射关系
    Map<Method, MethodHandler> methodToHandler = new LinkedHashMap<Method, MethodHandler>();
    List<DefaultMethodHandler> defaultMethodHandlers = new LinkedList<DefaultMethodHandler>();

    for (Method method : target.type().getMethods()) {
      if (method.getDeclaringClass() == Object.class) {
        continue;
      } else if(Util.isDefault(method)) {
        DefaultMethodHandler handler = new DefaultMethodHandler(method);
        defaultMethodHandlers.add(handler);
        methodToHandler.put(method, handler);
      } else {
        methodToHandler.put(method, nameToHandler.get(Feign.configKey(target.type(), method)));
      }
    }
    // 创建 具体的InvocationHandler
    InvocationHandler handler = factory.create(target, methodToHandler);
    // 创建代理对象
    T proxy = (T) Proxy.newProxyInstance(target.type().getClassLoader(), new Class<?>[]{target.type()}, handler);

    for(DefaultMethodHandler defaultMethodHandler : defaultMethodHandlers) {
      defaultMethodHandler.bindTo(proxy);
    }
    return proxy;
  }

```



SynchronousMethodHandler：MethodHandler的实现类，用于方法调用真正的拦截处理

```java
@Override
  public Object invoke(Object[] argv) throws Throwable {
    // 通过BuildTemplateByResolvingArgs 以及请求的参数， 创建RequestTemplate 请求模板
    RequestTemplate template = buildTemplateFromArgs.create(argv);
    Retryer retryer = this.retryer.clone();
    while (true) {
      try {
        return executeAndDecode(template);
      } catch (RetryableException e) {
        retryer.continueOrPropagate(e);
        if (logLevel != Logger.Level.NONE) {
          logger.logRetry(metadata.configKey(), logLevel);
        }
        continue;
      }
    }
  }
```



MethodMetadata： 方法的元数据



BuildTemplateByResolvingArgs：通过方法调用的参数，具体封装请求

```java
@Override
public RequestTemplate create(Object[] argv) {
    RequestTemplate mutable = new RequestTemplate(metadata.template());
    if (metadata.urlIndex() != null) {
        int urlIndex = metadata.urlIndex();
        checkArgument(argv[urlIndex] != null, "URI parameter %s was null", urlIndex);
        mutable.insert(0, String.valueOf(argv[urlIndex]));
    }
    Map<String, Object> varBuilder = new LinkedHashMap<String, Object>();
    for (Entry<Integer, Collection<String>> entry : metadata.indexToName().entrySet()) {
        int i = entry.getKey();
        Object value = argv[entry.getKey()];
        if (value != null) { // Null values are skipped.
            if (indexToExpander.containsKey(i)) {
                value = expandElements(indexToExpander.get(i), value);
            }
            for (String name : entry.getValue()) {
                varBuilder.put(name, value);
            }
        }
    }

    // 根据请求模板与参数信息， 拼装真正的请求URL
    RequestTemplate template = resolve(argv, mutable, varBuilder);
    if (metadata.queryMapIndex() != null) {
        // add query map parameters after initial resolve so that they take
        // precedence over any predefined values
        template = addQueryMapQueryParameters(argv, template);
    }

    if (metadata.headerMapIndex() != null) {
        template = addHeaderMapHeaders(argv, template);
    }

    return template;
}
```



FeignInvocationHandler：FeignClient 动态代理对象中的InvocationHandler， 真正做请求拦截处理的角色

```java
@Override
public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
if ("equals".equals(method.getName())) {
try {
Object
otherHandler =
args.length > 0 && args[0] != null ? Proxy.getInvocationHandler(args[0]) : null;
return equals(otherHandler);
} catch (IllegalArgumentException e) {
return false;
}
} else if ("hashCode".equals(method.getName())) {
return hashCode();
} else if ("toString".equals(method.getName())) {
return toString();
}
// 从Method与MethodHandler的映射中拿到具体的MethodHandler(实现类：SynchronousMethodHandler)
return dispatch.get(method).invoke(args);
}
```





LoadBalancerFeignClient

```java
public Response execute(Request request, Request.Options options) throws IOException {
    try {
        URI asUri = URI.create(request.url());
        String clientName = asUri.getHost();
        URI uriWithoutHost = cleanUrl(request.url(), clientName);
        FeignLoadBalancer.RibbonRequest ribbonRequest = new FeignLoadBalancer.RibbonRequest(
            this.delegate, request, uriWithoutHost);

        IClientConfig requestConfig = getClientConfig(options, clientName);
        //executeWithLoadBalancer()
        return lbClient(clientName).executeWithLoadBalancer(ribbonRequest,
                                                            requestConfig).toResponse();
    }
    catch (ClientException e) {
        IOException io = findIOException(e);
        if (io != null) {
            throw io;
        }
        throw new RuntimeException(e);
    }
}
```



LoadBalancerContext

```java
public Server getServerFromLoadBalancer(@Nullable URI original, @Nullable Object loadBalancerKey) throws ClientException {
String host = null;
int port = -1;
if (original != null) {
host = original.getHost();
}
if (original != null) {
Pair<String, Integer> schemeAndPort = deriveSchemeAndPortFromPartialUri(original);        
port = schemeAndPort.second();
}

// Various Supported Cases
// The loadbalancer to use and the instances it has is based on how it was registered
// In each of these cases, the client might come in using Full Url or Partial URL
ILoadBalancer lb = getLoadBalancer();
if (host == null) {
// Partial URI or no URI Case
// well we have to just get the right instances from lb - or we fall back
if (lb != null){
Server svc = lb.chooseServer(loadBalancerKey);
if (svc == null){
throw new ClientException(ClientException.ErrorType.GENERAL,
"Load balancer does not have available server for client: "
+ clientName);
}
host = svc.getHost();
if (host == null){
throw new ClientException(ClientException.ErrorType.GENERAL,
"Invalid Server for :" + svc);
}
logger.debug("{} using LB returned Server: {} for request {}", new Object[]{clientName, svc, original});
return svc;
} else {
// No Full URL - and we dont have a LoadBalancer registered to
// obtain a server
// if we have a vipAddress that came with the registration, we
// can use that else we
// bail out
if (vipAddresses != null && vipAddresses.contains(",")) {
throw new ClientException(
ClientException.ErrorType.GENERAL,
"Method is invoked for client " + clientName + " with partial URI of ("
+ original
+ ") with no load balancer configured."
+ " Also, there are multiple vipAddresses and hence no vip address can be chosen"
+ " to complete this partial uri");
} else if (vipAddresses != null) {
try {
Pair<String,Integer> hostAndPort = deriveHostAndPortFromVipAddress(vipAddresses);
host = hostAndPort.first();
port = hostAndPort.second();
} catch (URISyntaxException e) {
throw new ClientException(
ClientException.ErrorType.GENERAL,
"Method is invoked for client " + clientName + " with partial URI of ("
+ original
+ ") with no load balancer configured. "
+ " Also, the configured/registered vipAddress is unparseable (to determine host and port)");
}
} else {
throw new ClientException(
ClientException.ErrorType.GENERAL,
this.clientName
+ " has no LoadBalancer registered and passed in a partial URL request (with no host:port)."
+ " Also has no vipAddress registered");
}
}
} else {
// Full URL Case
// This could either be a vipAddress or a hostAndPort or a real DNS
// if vipAddress or hostAndPort, we just have to consult the loadbalancer
// but if it does not return a server, we should just proceed anyways
// and assume its a DNS
// For restClients registered using a vipAddress AND executing a request
// by passing in the full URL (including host and port), we should only
// consult lb IFF the URL passed is registered as vipAddress in Discovery
boolean shouldInterpretAsVip = false;

if (lb != null) {
shouldInterpretAsVip = isVipRecognized(original.getAuthority());
}
if (shouldInterpretAsVip) {
Server svc = lb.chooseServer(loadBalancerKey);
if (svc != null){
host = svc.getHost();
if (host == null){
throw new ClientException(ClientException.ErrorType.GENERAL,
"Invalid Server for :" + svc);
}
logger.debug("using LB returned Server: {} for request: {}", svc, original);
return svc;
} else {
// just fall back as real DNS
logger.debug("{}:{} assumed to be a valid VIP address or exists in the DNS", host, port);
}
} else {
// consult LB to obtain vipAddress backed instance given full URL
//Full URL execute request - where url!=vipAddress
logger.debug("Using full URL passed in by caller (not using load balancer): {}", original);
}
}
// end of creating final URL
if (host == null){
throw new ClientException(ClientException.ErrorType.GENERAL,"Request contains no HOST to talk to");
}
// just verify that at this point we have a full URL

return new Server(host, port);
}
```





作业： 画出Feign流程图
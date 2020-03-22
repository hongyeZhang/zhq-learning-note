# Ribbon 源码分析

为什么在RestTemplate上面加一个@LoadBalanced注解，就可以使用Ribbon进行负载均衡？

加注解的目的无非就是要增强原来的实现。 



请求路径

 原来：http://eureka-provider/order/...

 实际：http://localhost:8081/order/...    肯定会经过一些算法 ， 自然也会涉及到负载均衡



## 为RestTemplate添加 LoadBalancerInterceptor 拦截器

**Class:LoadBalancerAutoConfiguration**

```java
@Configuration
@ConditionalOnMissingClass("org.springframework.retry.support.RetryTemplate")
static class LoadBalancerInterceptorConfig {
    @Bean
    public LoadBalancerInterceptor ribbonInterceptor(
        LoadBalancerClient loadBalancerClient,
        LoadBalancerRequestFactory requestFactory) {
        return new LoadBalancerInterceptor(loadBalancerClient, requestFactory);
    }

    @Bean
    @ConditionalOnMissingBean
    public RestTemplateCustomizer restTemplateCustomizer(
        final LoadBalancerInterceptor loadBalancerInterceptor) {
        return new RestTemplateCustomizer() {
            @Override
            public void customize(RestTemplate restTemplate) {
                List<ClientHttpRequestInterceptor> list = new ArrayList<>(
                    restTemplate.getInterceptors());
                // 在原来的拦截器的基础上，再增加一个LoadBalancerInterceptor
                list.add(loadBalancerInterceptor);
                restTemplate.setInterceptors(list);
            }
        };
    }
}
```

### LoadBalancerInterceptor 实际上 是一个 ClientHttpRequestInterceptor



## 调用接口时，通过LoadBalancerInterceptor拦截器处理具体服务调用

org.springframework.http.client.**ClientHttpResponse**

```java
public ClientHttpResponse execute(HttpRequest request, final byte[] body) throws IOException {
    if (this.iterator.hasNext()) {
        ClientHttpRequestInterceptor nextInterceptor = this.iterator.next();
        return nextInterceptor.intercept(request, body, this);
    }
    else {
        ClientHttpRequest delegate = requestFactory.createRequest(request.getURI(), request.getMethod());
        for (Map.Entry<String, List<String>> entry : request.getHeaders().entrySet()) {
            List<String> values = entry.getValue();
            for (String value : values) {
                delegate.getHeaders().add(entry.getKey(), value);
            }
        }
        if (body.length > 0) {
            if (delegate instanceof StreamingHttpOutputMessage) {
                StreamingHttpOutputMessage streamingOutputMessage = (StreamingHttpOutputMessage) delegate;
                streamingOutputMessage.setBody(new StreamingHttpOutputMessage.Body() {
                    @Override
                    public void writeTo(final OutputStream outputStream) throws IOException {
                        StreamUtils.copy(body, outputStream);
                    }
                });
            }
            else {
                StreamUtils.copy(body, delegate.getBody());
            }
        }
        return delegate.execute();
    }
}
```

**LoadBalancerInterceptor**具体的拦截处理方式

```java
public class LoadBalancerInterceptor implements ClientHttpRequestInterceptor {

	private LoadBalancerClient loadBalancer;
	private LoadBalancerRequestFactory requestFactory;

	public LoadBalancerInterceptor(LoadBalancerClient loadBalancer, LoadBalancerRequestFactory requestFactory) {
		this.loadBalancer = loadBalancer;
		this.requestFactory = requestFactory;
	}

	public LoadBalancerInterceptor(LoadBalancerClient loadBalancer) {
		// for backwards compatibility
		this(loadBalancer, new LoadBalancerRequestFactory(loadBalancer));
	}

	@Override
	public ClientHttpResponse intercept(final HttpRequest request, final byte[] body,
			final ClientHttpRequestExecution execution) throws IOException {
		final URI originalUri = request.getURI();
		String serviceName = originalUri.getHost();
		Assert.state(serviceName != null, "Request URI does not contain a valid hostname: " + originalUri);
        // 调用LoadBalancerClient  -- 实现类 ： RibbonLoadBalancerClient
		return this.loadBalancer.execute(serviceName, requestFactory.createRequest(request, body, execution));
	}
}
```



## RibbonLoadBalancerClient客户端负载均衡实现

**RibbonLoadBalancerClient**

```java
@Override
public <T> T execute(String serviceId, LoadBalancerRequest<T> request) throws IOException {
    // 拿到可用的服务列表
    ILoadBalancer loadBalancer = getLoadBalancer(serviceId);
    // 通过一定算法 得到一个服务
    Server server = getServer(loadBalancer);
    if (server == null) {
        throw new IllegalStateException("No instances available for " + serviceId);
    }
    RibbonServer ribbonServer = new RibbonServer(serviceId, server, isSecure(server,
                                                                             serviceId), serverIntrospector(serviceId).getMetadata(server));

    return execute(serviceId, ribbonServer, request);
}
```

org.springframework.cloud.context.named.NamedContextFactory.getInstance(String, Class<T>)

```java
public <T> T getInstance(String name, Class<T> type) {
    AnnotationConfigApplicationContext context = getContext(name);
    if (BeanFactoryUtils.beanNamesForTypeIncludingAncestors(context,
                                                            type).length > 0) {
        // 得到一个ILoadBalancer  
        return context.getBean(type);
    }
    return null;
}
```

ILoadBalancer  -- 

```properties
DynamicServerListLoadBalancer:{
	NFLoadBalancer: name = eureka - provider,
	current list of Servers = [localhost: 8072, localhost: 8071],
	Load balancer stats = Zone stats: {
		unknown = [Zone: unknown;Instance count: 2;Active connections count: 0;Circuit breaker tripped count: 0;Active connections per server: 0.0;]
	},
	Server stats: [
		[Server: localhost: 8072;Zone: UNKNOWN;Total Requests: 0;Successive connection failure: 0;Total blackout seconds: 0;Last connection made: Thu Jan 01 08: 00: 00 CST 1970;First connection made: Thu Jan 01 08: 00: 00 CST 1970;Active Connections: 0;total failure count in last(1000) msecs: 0;average resp time: 0.0;90 percentile resp time: 0.0;95 percentile resp time: 0.0;min resp time: 0.0;max resp time: 0.0;stddev resp time: 0.0],
		[Server: localhost: 8071;Zone: UNKNOWN;Total Requests: 0;Successive connection failure: 0;Total blackout seconds: 0;Last connection made: Thu Jan 01 08: 00: 00 CST 1970;First connection made: Thu Jan 01 08: 00: 00 CST 1970;Active Connections: 0;total failure count in last(1000) msecs: 0;average resp time: 0.0;90 percentile resp time: 0.0;95 percentile resp time: 0.0;min resp time: 0.0;max resp time: 0.0;stddev resp time: 0.0]
	]
}ServerList:com.netflix.loadbalancer.ConfigurationBasedServerList@5353dd09
```



ILoadBalancer实例化

**RibbonClientConfiguration**.ribbonLoadBalancer(IClientConfig, ServerList<Server>, ServerListFilter<Server>, IRule, IPing, ServerListUpdater)

```java
	@Bean
	@ConditionalOnMissingBean
	public ILoadBalancer ribbonLoadBalancer(IClientConfig config,
			ServerList<Server> serverList, ServerListFilter<Server> serverListFilter,
			IRule rule, IPing ping, ServerListUpdater serverListUpdater) {
		if (this.propertiesFactory.isSet(ILoadBalancer.class, name)) {
			return this.propertiesFactory.get(ILoadBalancer.class, config, name);
		}
		return new ZoneAwareLoadBalancer<>(config, rule, ping, serverList,
				serverListFilter, serverListUpdater);
	}
```



IRule实例化

```java
	@Bean
	@ConditionalOnMissingBean
	public IRule ribbonRule(IClientConfig config) {
		if (this.propertiesFactory.isSet(IRule.class, name)) {
			return this.propertiesFactory.get(IRule.class, config, name);
		}
		ZoneAvoidanceRule rule = new ZoneAvoidanceRule();
		rule.initWithNiwsConfig(config);
		return rule;
	}
```



默认：ZoneAvoidanceRule   规避区域选择   




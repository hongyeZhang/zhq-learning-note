## spring cloud netflix



配置中心： 阿波罗  携程
配置文件
application-dev
application-prod
application-test






在使用Spring Cloud feign使用中在使用服务发现的时候提到了两种注解，一种为@EnableDiscoveryClient,一种为@EnableEurekaClient,用法上基本一致。

spring cloud中discovery service有许多种实现（eureka、consul、zookeeper等等），@EnableDiscoveryClient基于spring-cloud-commons, @EnableEurekaClient基于spring-cloud-netflix。
其实用更简单的话来说，就是如果选用的注册中心是eureka，那么就推荐@EnableEurekaClient，如果是其他的注册中心，那么推荐使用@EnableDiscoveryClient。



健康检查：springboot - admin


localhost:8769/api/b/hi?message=helloSpring&token=123

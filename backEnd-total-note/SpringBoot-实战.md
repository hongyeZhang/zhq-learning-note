
# SpringBoot 实战技巧总结


## 开机启动
* CommandLineRunner
* ApplicationRunner
* 二者区别：args 的入参形式不一样

* 在启动流程的最后进行调用

```java
	private void callRunners(ApplicationContext context, ApplicationArguments args) {
		List<Object> runners = new ArrayList<>();
		runners.addAll(context.getBeansOfType(ApplicationRunner.class).values());
		runners.addAll(context.getBeansOfType(CommandLineRunner.class).values());
		AnnotationAwareOrderComparator.sort(runners);
		for (Object runner : new LinkedHashSet<>(runners)) {
			if (runner instanceof ApplicationRunner) {
				callRunner((ApplicationRunner) runner, args);
			}
			if (runner instanceof CommandLineRunner) {
				callRunner((CommandLineRunner) runner, args);
			}
		}
	}
```




## 优雅关机
* 在对应用进程发送停止指令之后，能保证正在执行的业务操作不受影响。应用接收到停止指令之后的步骤应该是，停止接收访问请求，
    等待已经接收到的请求处理完成，并能成功返回，这时才真正停止应用

* 实现思路
    * kill -2 相当于快捷键 Ctrl + C 会触发 Java 的 ShutdownHook 事件处理
    * java 优雅停机
        * Java的优雅停机通常通过注册JDK的ShutdownHook（钩子）来实现，当系统接收到退出指令后，
            首先标记系统处于退出状态，不再接收新的消息，然后将积压的消息处理完，最后调用资源回收接口将资源销毁，最后各线程退出执行。
    * springboot 2.3 之后，内置功能，直接配置即可
    * 微服务优雅停机
        * 服务的优雅停机没有统一的解决方案，只要抓住核心思想进行设计即可： 引流 → 挡板 → 等待停机
        * 所有微服务应用都应该支持优雅停机 
        * 优先注销注册中心注册的服务实例 
        * 待停机的服务应用的接入点标记拒绝服务 
        * 上游服务支持故障转移因优雅停机而拒绝的服务 
        * 根据具体业务也提供适当的停机接口 




## 仅仅更改某一个类的日志打印级别 : 通过在命令行添加该类的参数
java -jar ./target/spring-boot-in-aciton-0.0.1-SNAPSHOT.jar --logging.level.com.learning.zhq.springbootinaciton.controller.HelloConroller=DEBUG

## springboot指定端口号启动
java -jar xxx.jar --server.port=8080
java -jar ./stream-hello/target/stream-hello-0.0.1-SNAPSHOT.jar --server.port=13000
java -jar ./stream-hello/target/stream-hello-0.0.1-SNAPSHOT.jar --server.port=13001

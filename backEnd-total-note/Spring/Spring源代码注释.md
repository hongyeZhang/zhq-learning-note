# Spring启动流程源代码注释

## 基本启动流程
* org.springframework.context.support.AbstractApplicationContext#refresh
* 整个refresh()的代码都是同步的，而对应的同步对象是startupShutdownMonitor。startupShutdownMonitor只在refresh()和close()两个方法里
    被用到，而它是用来同步applicationContext的刷新和销毁。
* Spring的registerShutdownHook和close有什么区别？
    * 当close()被调用时会立即关闭或者停止ApplicationContext；而调用registerShutdownHook()将在稍后JVM关闭时关闭或停止ApplicationContext，
    该方法主要通过JVM ShutdownHook来实现。
* ShutdownHook
    * Java 语言提供一种 ShutdownHook（钩子）机制，当 JVM 接受到系统的关闭通知之后，调用 ShutdownHook 内的方法，用以完成清理操作，从而实现平滑退出应用。

```java
public class AbstractApplicationContext {
	@Override
	public void refresh() throws BeansException, IllegalStateException {
        
        // 方法加锁避免多线程同时刷新Spring上下文
		synchronized (this.startupShutdownMonitor) {
			// Prepare this context for refreshing.
            // 1. 准备上下文刷新
			prepareRefresh();

			// Tell the subclass to refresh the internal bean factory.
            // 2. 告诉子类刷新内部的beanFactory返回新的BeanFactory
			ConfigurableListableBeanFactory beanFactory = obtainFreshBeanFactory();

			// Prepare the bean factory for use in this context.
            // 3. 在当前上下文中准备要beanFactory
			prepareBeanFactory(beanFactory);

			try {
				// Allows post-processing of the bean factory in context subclasses.
                // 4. 允许在上下文子类中对beanFactory进行后置处理
				postProcessBeanFactory(beanFactory);

				// Invoke factory processors registered as beans in the context.
                // 5. 在上下文中将BeanFactory处理器注册为Bean
				invokeBeanFactoryPostProcessors(beanFactory);

				// Register bean processors that intercept bean creation.
                // 6. 注册Bean处理器用于拦截Bean的创建
				registerBeanPostProcessors(beanFactory);

				// Initialize message source for this context.
                // 7. 在上下文中初始化国际化信息
				initMessageSource();

				// Initialize event multicaster for this context.
                // 8. 在上下文中初始化event multicaster（事件多播器）
				initApplicationEventMulticaster();

				// Initialize other special beans in specific context subclasses.
                // 9. 在指定的上下文子类中初始化其他指定的beans
				onRefresh();

				// Check for listener beans and register them.
                // 10. 检查并注册事件监听
				registerListeners();

				// Instantiate all remaining (non-lazy-init) singletons.
                // 11. 实例化所有剩余的（非延迟初始化）单例
				finishBeanFactoryInitialization(beanFactory);

				// Last step: publish corresponding event.
                // 12. 最后一步：发布相应的事件
				finishRefresh();
			}

			catch (BeansException ex) {
				if (logger.isWarnEnabled()) {
					logger.warn("Exception encountered during context initialization - " +
							"cancelling refresh attempt: " + ex);
				}

				// Destroy already created singletons to avoid dangling resources.
                // 13. 如果出现异常则销毁已创建的单例
				destroyBeans();

				// Reset 'active' flag.
                // 14. 重置活动标志。
				cancelRefresh(ex);

				// Propagate exception to caller.
				throw ex;
			}

			finally {
				// Reset common introspection caches in Spring's core, since we
				// might not ever need metadata for singleton beans anymore...
				resetCommonCaches();
			}
		}
	}
}

```


## 1 prepareRefresh
```java
public class AbstractApplicationContext {
    protected void prepareRefresh() {
        // 设置启动时间。当前毫秒数代表当前applicationContext的创建时间
        this.startupDate = System.currentTimeMillis();
        // 设置容器关闭标志
        this.closed.set(false);
        // 设置启动标志
        this.active.set(true);
    
        if (logger.isInfoEnabled()) {
            logger.info("Refreshing " + this);
        }
    
        // 初始化属性资源
        initPropertySources();
    
        // 验证所有的属性是否都是可解析的
        getEnvironment().validateRequiredProperties();

		if (this.earlyApplicationListeners == null) {
			this.earlyApplicationListeners = new LinkedHashSet<>(this.applicationListeners);
		}
		else {
			// Reset local application listeners to pre-refresh state.
			this.applicationListeners.clear();
			this.applicationListeners.addAll(this.earlyApplicationListeners);
		}

		// Allow for the collection of early ApplicationEvents,
		// to be published once the multicaster is available...
		this.earlyApplicationEvents = new LinkedHashSet<>();
    }
}

```


## 2 obtainFreshBeanFactory()

```java
public class AbstractRefreshableApplicationContext {

    @Override
        protected final void refreshBeanFactory() throws BeansException {
            // 判断是否已经存在一个BeanFactory 
            if (hasBeanFactory()) {
                // 销毁已经存在BeanFactory中的所有Bean
                destroyBeans();
                // 关闭BeanFactory
                closeBeanFactory();
            }
            try {
                // 创建新的BeanFactory对象（DefaultListableBeanFactory）
                DefaultListableBeanFactory beanFactory = createBeanFactory();
                // 给BeanFactory设置Id
                beanFactory.setSerializationId(getId());
                // 自定义 beanFactory 是否允许bean名称覆盖，是否允许循环依赖
                customizeBeanFactory(beanFactory);
                // 加载配置文件
                loadBeanDefinitions(beanFactory);
                synchronized (this.beanFactoryMonitor) {
                    // 新创建的BeanFactory赋给成员变量beanFactory
                    this.beanFactory = beanFactory;
                }
            }
            catch (IOException ex) {
                throw new ApplicationContextException("I/O error parsing bean definition source for " + getDisplayName(), ex);
            }
        }
}
```





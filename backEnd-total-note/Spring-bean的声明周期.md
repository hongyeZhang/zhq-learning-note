Spring Bean的完整生命周期从创建Spring容器开始，直到最终Spring容器销毁Bean，这其中包含了一系列关键点。

（1）实例化 BeanFactoryPostProcessor 实现类
（2）执行 BeanFactoryPostProcessor 的 postProcessBeanFactory 方法
（3）实例化 BeanPostProcessor 实现类
（4）实例化 InstantiationAwareBeanPostProcessorAdapter 实现类
（5）执行 InstantiationAwareBeanPostProcessor 的 postProcessBeforeInitialization 方法
（6）执行 bean 的构造器
（7）执行 InstantiationAwareBeanPostProcessor 的  postProcessProperties 方法
（8）为 bean 注入属性
（9）调用 beanNameAware 的 setBeanName 方法
（10）调用 BeanFactoryAware 的 setBeanFactory 方法
（11）执行 BeanPostProcessor 的  postProcessBeforeInitialization 方法
（12）调用 InitializingBean 的 afterPropertiesSet
（13）调用 <bean> 的 init-method 属性执行的初始化方法
（14）执行 BeanPostProcessor 的 postProcessAfterInitialization
（15）执行 InstantiationAwareBeanPostProcessor 的 postProcessAfterInitialization 方法
容器初始化成功，执行正常调用后，下面销毁容器。
调用 DisposibleBean 的 destory 方法
调用 <bean> 的 destory-method 属性执行的初始化方法

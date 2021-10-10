

## 框架暴露的感知接口
InitializingBean ， 主要是用到了他的afterPropertiesSet方法，在对象实例化完毕后，调用该方法，做一些值的初始化
DisposableBean ， 主要用到他的destroy() 方法， 在spring容器showdown的时候调用。
ApplicationContextAware， 为了得到applicationContext


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


## STEP1 prepareRefresh
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


## STEP2 ConfigurableListableBeanFactory beanFactory = obtainFreshBeanFactory();

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

```java
public class DefaultSingletonBeanRegistry {
    
    // 当前这个单例是否正在被销毁
    // true：表示单例已经执行了destroy方法，或者出现异常时执行了destroySingleton方法
    private boolean singletonsCurrentlyInDestruction = false;
    
    // 缓存两个Bean之间的包含关系。如：一个Bean中包含了一个内部Bean。
    private final Map<String, Set<String>> containedBeanMap = new ConcurrentHashMap<String, Set<String>>(16);
    
    // 缓存Bean与其他依赖Bean的关系
    private final Map<String, Set<String>> dependentBeanMap = new ConcurrentHashMap<String, Set<String>>(64);
    
    // 缓存被依赖Bean与其他依赖Bean的关系
    private final Map<String, Set<String>> dependenciesForBeanMap = new ConcurrentHashMap<String, Set<String>>(64);
    
    // 销毁所有的Bean实例
    public void destroySingletons() {
        if (logger.isDebugEnabled()) {
            logger.debug("Destroying singletons in " + this);
        }
        synchronized (this.singletonObjects) {
            // 设置销毁标志
            this.singletonsCurrentlyInDestruction = true;
        }
    
        // 销毁disposableBeans缓存中所有单例bean
        String[] disposableBeanNames;
        synchronized (this.disposableBeans) {
            disposableBeanNames = StringUtils.toStringArray(this.disposableBeans.keySet());
        }
        for (int i = disposableBeanNames.length - 1; i >= 0; i--) {
            destroySingleton(disposableBeanNames[i]);
        }
    
        // 清空包含关系
        this.containedBeanMap.clear();
        // 清空依赖和被依赖关系
        this.dependentBeanMap.clear();
        this.dependenciesForBeanMap.clear();
    
        // 清空缓存
        clearSingletonCache();
    }

}
```

### 加载配置

```java
public class AbstractXmlApplicationContext {
    protected void loadBeanDefinitions(XmlBeanDefinitionReader reader) throws BeansException, IOException {
        // 以Resource方式加载配置
        Resource[] configResources = getConfigResources();
        if (configResources != null) {
            // 读取配置文件
            reader.loadBeanDefinitions(configResources);
        }
        // 以String方式加载配置
        String[] configLocations = getConfigLocations();
        if (configLocations != null) {
            // 读取配置文件
            reader.loadBeanDefinitions(configLocations);
        }
    }
}
```

* bean 的加载
```java
public class XmlBeanDefinitionReader {
    // 从配置文件中加载Bean
    public int loadBeanDefinitions(EncodedResource encodedResource) throws BeanDefinitionStoreException {
        Assert.notNull(encodedResource, "EncodedResource must not be null");
        if (logger.isInfoEnabled()) {
            logger.info("Loading XML bean definitions from " + encodedResource);
        }
    
        Set<EncodedResource> currentResources = this.resourcesCurrentlyBeingLoaded.get();
        if (currentResources == null) {
            currentResources = new HashSet<EncodedResource>(4);
            this.resourcesCurrentlyBeingLoaded.set(currentResources);
        }
        if (!currentResources.add(encodedResource)) {
            throw new BeanDefinitionStoreException(
                "Detected cyclic loading of " + encodedResource + " - check your import definitions!");
        }
        try {
            // 将Resource资源转化为输入流InputStream
            InputStream inputStream = encodedResource.getResource().getInputStream();
            try {
                InputSource inputSource = new InputSource(inputStream);
                if (encodedResource.getEncoding() != null) {
                    inputSource.setEncoding(encodedResource.getEncoding());
                }
                // 执行加载Bean的过程
                return doLoadBeanDefinitions(inputSource, encodedResource.getResource());
            }
            finally {
                inputStream.close();
            }
        }
        catch (IOException ex) {
            throw new BeanDefinitionStoreException(
                "IOException parsing XML document from " + encodedResource.getResource(), ex);
        }
        finally {
            currentResources.remove(encodedResource);
            if (currentResources.isEmpty()) {
                this.resourcesCurrentlyBeingLoaded.remove();
            }
        }
    }
    
    // 加载Bean的函数
    protected int doLoadBeanDefinitions(InputSource inputSource, Resource resource)
        throws BeanDefinitionStoreException {
        try {
            // 加载XML文件，构造XML Document对象
            Document doc = doLoadDocument(inputSource, resource);
            // 注册Bean
            return registerBeanDefinitions(doc, resource);
        }
        // 抛出各种异常
        ......
    }

}
```

* bean的解析与注册
```java
public class DefaultBeanDefinitionDocumentReader{
    // XML配置文件中beans元素
    public static final String NESTED_BEANS_ELEMENT = "beans";
    // XML配置文件中alias别名元素
    public static final String ALIAS_ELEMENT = "alias";
    // XML配置文件中name属性
    public static final String NAME_ATTRIBUTE = "name";
    // XML配置文件中alias属性
    public static final String ALIAS_ATTRIBUTE = "alias";
    // XML配置文件中import元素
    public static final String IMPORT_ELEMENT = "import";
    // XML配置文件中resource属性
    public static final String RESOURCE_ATTRIBUTE = "resource";
    // XML配置文件中profile属性
    public static final String PROFILE_ATTRIBUTE = "profile";
    
    protected void doRegisterBeanDefinitions(Element root) {
        BeanDefinitionParserDelegate parent = this.delegate;
        // 创建Bean解析代理工具类
        this.delegate = createDelegate(getReaderContext(), root, parent);
    
        if (this.delegate.isDefaultNamespace(root)) {
            // 解析profile属性
            String profileSpec = root.getAttribute(PROFILE_ATTRIBUTE);
            if (StringUtils.hasText(profileSpec)) {
                String[] specifiedProfiles = StringUtils.tokenizeToStringArray(
                    profileSpec, BeanDefinitionParserDelegate.MULTI_VALUE_ATTRIBUTE_DELIMITERS);
                if (!getReaderContext().getEnvironment().acceptsProfiles(specifiedProfiles)) {
                    if (logger.isInfoEnabled()) {
                        logger.info("Skipped XML bean definition file due to specified profiles [" + profileSpec +
                                    "] not matching: " + getReaderContext().getResource());
                    }
                    return;
                }
            }
        }
    
        preProcessXml(root);
        // 解析XML并执行Bean注册
        parseBeanDefinitions(root, this.delegate);
        postProcessXml(root);
    
        this.delegate = parent;
    }
    
    protected void parseBeanDefinitions(Element root, BeanDefinitionParserDelegate delegate) {
        // root根节点是默认标签
        if (delegate.isDefaultNamespace(root)) {
            NodeList nl = root.getChildNodes();
            // 遍历XML Document的每个节点
            for (int i = 0; i < nl.getLength(); i++) {
                Node node = nl.item(i);
                if (node instanceof Element) {
                    Element ele = (Element) node;
                    if (delegate.isDefaultNamespace(ele)) {
                        // 解析默认标签
                        parseDefaultElement(ele, delegate);
                    }
                    else {
                        // 解析自定义标签
                        delegate.parseCustomElement(ele);
                    }
                }
            }
        }
        // root根节点是自定义标签
        else {
            delegate.parseCustomElement(root);
        }
    }
    
    // 解析XML配置文件的节点元素
    private void parseDefaultElement(Element ele, BeanDefinitionParserDelegate delegate) {
        // 如果是Import元素
        if (delegate.nodeNameEquals(ele, IMPORT_ELEMENT)) {
            importBeanDefinitionResource(ele);
        }
        // 如果是Alias别名元素
        else if (delegate.nodeNameEquals(ele, ALIAS_ELEMENT)) {
            processAliasRegistration(ele);
        }
        // 如果是Bean元素
        else if (delegate.nodeNameEquals(ele, BEAN_ELEMENT)) {
            processBeanDefinition(ele, delegate);
        }
        // 如果是嵌套Bean元素（Beans）
        else if (delegate.nodeNameEquals(ele, NESTED_BEANS_ELEMENT)) {
            // recurse
            doRegisterBeanDefinitions(ele);
        }
    }

}


```

* Import解析
虽然每个单独的XML配置文件都代表体系结构中的逻辑层或模块，但我们可以从多个XML片段中加载Bean定义。如项目中有多个Resource位置，可以使用一个或多个
<import />从另外的XML文件中加载Bean定义。标签用法示例：
```xml
<import resource="applicationDao.xml" />
<import resource="applicationService.xml" />
```


```java
public class DefaultBeanDefinitionDocumentReader {

    protected void importBeanDefinitionResource(Element ele) {
        String location = ele.getAttribute(RESOURCE_ATTRIBUTE);
        if (!StringUtils.hasText(location)) {
            getReaderContext().error("Resource location must not be empty", ele);
            return;
        }
    
        // 解析路径和占位符
        location = getReaderContext().getEnvironment().resolveRequiredPlaceholders(location);
    
        // 解析好的资源要放到Set里面
        Set<Resource> actualResources = new LinkedHashSet<Resource>(4);
    
        // 解析location是相对路径还是绝对路径
        boolean absoluteLocation = false;
        try {
            absoluteLocation = ResourcePatternUtils.isUrl(location) || ResourceUtils.toURI(location).isAbsolute();
        }
        catch (URISyntaxException ex) {
            // cannot convert to an URI, considering the location relative
            // unless it is the well-known Spring prefix "classpath*:"
        }
    
        // 如果是绝对路径
        if (absoluteLocation) {
            try {
                // 直接根据路径加载相应的配置文件
                int importCount = getReaderContext().getReader().loadBeanDefinitions(location, actualResources);
                if (logger.isDebugEnabled()) {
                    logger.debug("Imported " + importCount + " bean definitions from URL location [" + location + "]");
                }
            }
            catch (BeanDefinitionStoreException ex) {
                getReaderContext().error(
                    "Failed to import bean definitions from URL location [" + location + "]", ele, ex);
            }
        }
        else {
            try {
                int importCount;
                // 如果是相对路径，则先根据路径得到Resource
                Resource relativeResource = getReaderContext().getResource().createRelative(location);
                // 如果Resource存在
                if (relativeResource.exists()) {
                    importCount = getReaderContext().getReader().loadBeanDefinitions(relativeResource);
                    actualResources.add(relativeResource);
                }
                else {
                    // Resource类解析不成功，在classpath路径中去加载。如果没有则抛出异常
                    String baseLocation = getReaderContext().getResource().getURL().toString();
                    importCount = getReaderContext().getReader().loadBeanDefinitions(
                        StringUtils.applyRelativePath(baseLocation, location), actualResources);
                }
                if (logger.isDebugEnabled()) {
                    logger.debug("Imported " + importCount + " bean definitions from relative location [" + location + "]");
                }
            }
            catch (IOException ex) {
                getReaderContext().error("Failed to resolve current resource location", ele, ex);
            }
            catch (BeanDefinitionStoreException ex) {
                getReaderContext().error("Failed to import bean definitions from relative location [" + location + "]",
                                         ele, ex);
            }
        }
        Resource[] actResArray = actualResources.toArray(new Resource[actualResources.size()]);
        getReaderContext().fireImportProcessed(location, actResArray, extractSource(ele));
    }
}
```


* Alias别名注册
每个bean具有一个或多个标识符。这些标识符在承载Bean的容器内必须是唯一的。 Bean通常只有一个标识符，但是如果需要多个标识符，则多余的标识符可以被视为别名。
标签用法示例：
```xml
<alias name="dataSource" alias="systemA-dataSource"/>
<alias name="dataSource" alias="systemB-dataSource"/>
```

```java
public class SimpleAliasRegistry {
    // 存放别名的缓存
    private final Map<String, String> aliasMap = new ConcurrentHashMap<String, String>
    
    // 根据Bean的别名进行注册
    public void registerAlias(String name, String alias) {
        Assert.hasText(name, "'name' must not be empty");
        Assert.hasText(alias, "'alias' must not be empty");
        synchronized (this.aliasMap) {
            // 如果别名和名字相同
            if (alias.equals(name)) {
                this.aliasMap.remove(alias);
            }
            else {
                // 如果别名和名字不相同，根据别名获取Bean名称
                String registeredName = this.aliasMap.get(alias);
                if (registeredName != null) {
                    // 如果缓存中已经存在该别名，不需要注册到缓存
                    if (registeredName.equals(name)) {
                        // An existing alias - no need to re-register
                        return;
                    }
                    // 如果不允许相同的Bean使用不同的名称则抛出异常
                    if (!allowAliasOverriding()) {
                        throw new IllegalStateException("Cannot register alias '" + alias + "' for name '" +
                                                        name + "': It is already registered for name '" + registeredName + "'.");
                    }
                }
                // 对别名进行循环检查
                checkForAliasCircle(name, alias);
                // 把别名放入别名缓存
                this.aliasMap.put(alias, name);
            }
        }
    }
    
    // 别名循环检查
    public boolean hasAlias(String name, String alias) {
        for (Map.Entry<String, String> entry : this.aliasMap.entrySet()) {
            // 获取Bean注册名
            String registeredName = entry.getValue();
            // 判断name参数和Bean注册名是否相同
            if (registeredName.equals(name)) {
                // 获取别名
                String registeredAlias = entry.getKey();
                // 判断别名是否相同
                // 递归调用hasAlias
                if (registeredAlias.equals(alias) || hasAlias(registeredAlias, alias)) {
                    return true;
                }
            }
        }
        return false;
    }
}
```

* bean 的注册
Spring会自动检测构造型类，并向容器注册相应的BeanDefinition
```java
public class DefaultBeanDefinitionDocumentReader {

    protected void processBeanDefinition(Element ele, BeanDefinitionParserDelegate delegate) {
        // 解析XML中的BeanDefinition元素
        BeanDefinitionHolder bdHolder = delegate.parseBeanDefinitionElement(ele);
        if (bdHolder != null) {
            bdHolder = delegate.decorateBeanDefinitionIfRequired(ele, bdHolder);
            try {
                // 注册BeanDefinition
                BeanDefinitionReaderUtils.registerBeanDefinition(bdHolder, getReaderContext().getRegistry());
            }
            catch (BeanDefinitionStoreException ex) {
                getReaderContext().error("Failed to register bean definition with name '" +
                                         bdHolder.getBeanName() + "'", ele, ex);
            }
            // 发送注册事件
            getReaderContext().fireComponentRegistered(new BeanComponentDefinition(bdHolder));
        }
    }
}

```

基于单一职责的缘故，BeanDefinitionParserDelegate专门负责解析XML元素的工作，而DefaultBeanDefinitionDocumentReader则主要负责读取XML配置文件的职责。

```java
public class BeanDefinitionParserDelegate {

    public BeanDefinitionHolder parseBeanDefinitionElement(Element ele, BeanDefinition containingBean) {
        // 获取id属性
        String id = ele.getAttribute(ID_ATTRIBUTE);
        // 获取name属性
        String nameAttr = ele.getAttribute(NAME_ATTRIBUTE);
    
        // 定义别名list
        List<String> aliases = new ArrayList<String>();
        if (StringUtils.hasLength(nameAttr)) {
            // 因为可以多个别名用，所以解析成别名数组
            String[] nameArr = StringUtils.tokenizeToStringArray(nameAttr, MULTI_VALUE_ATTRIBUTE_DELIMITERS);
            aliases.addAll(Arrays.asList(nameArr));
        }
    
        // beanName默认为id
        String beanName = id;
        // 如果没有beanName，那么取出别名数组中的第一个作为beanName
        if (!StringUtils.hasText(beanName) && !aliases.isEmpty()) {
            beanName = aliases.remove(0);
            if (logger.isDebugEnabled()) {
                logger.debug("No XML 'id' specified - using '" + beanName +
                             "' as bean name and " + aliases + " as aliases");
            }
        }
    
        if (containingBean == null) {
            checkNameUniqueness(beanName, aliases, ele);
        }
    
        AbstractBeanDefinition beanDefinition = parseBeanDefinitionElement(ele, beanName, containingBean);
        if (beanDefinition != null) {
            if (!StringUtils.hasText(beanName)) {
                try {
                    if (containingBean != null) {
                        // 生成Bean名
                        beanName = BeanDefinitionReaderUtils.generateBeanName(
                            beanDefinition, this.readerContext.getRegistry(), true);
                    }
                    else {
                        // 生成Bean名
                        beanName = this.readerContext.generateBeanName(beanDefinition);
                        String beanClassName = beanDefinition.getBeanClassName();
                        if (beanClassName != null &&
                            beanName.startsWith(beanClassName) && beanName.length() > beanClassName.length() &&
                            !this.readerContext.getRegistry().isBeanNameInUse(beanClassName)) {
                            aliases.add(beanClassName);
                        }
                    }
                    if (logger.isDebugEnabled()) {
                        logger.debug("Neither XML 'id' nor 'name' specified - " +
                                     "using generated bean name [" + beanName + "]");
                    }
                }
                catch (Exception ex) {
                    error(ex.getMessage(), ele);
                    return null;
                }
            }
            String[] aliasesArray = StringUtils.toStringArray(aliases);
            return new BeanDefinitionHolder(beanDefinition, beanName, aliasesArray);
        }
    
        return null;
    }
    
    // 解析Bean定义不考虑名称或别名。如果在Bean解析过程中产生异常，则返回null
    public AbstractBeanDefinition parseBeanDefinitionElement(
        Element ele, String beanName, BeanDefinition containingBean) {
    
        this.parseState.push(new BeanEntry(beanName));
    
        String className = null;
        // 解析Bean的class属性
        if (ele.hasAttribute(CLASS_ATTRIBUTE)) {
            className = ele.getAttribute(CLASS_ATTRIBUTE).trim();
        }
    
        try {
            String parent = null;
            // 解析parent属性
            if (ele.hasAttribute(PARENT_ATTRIBUTE)) {
                parent = ele.getAttribute(PARENT_ATTRIBUTE);
            }
            // 为指定的类名和Parent名称创建一个BeanDefinition
            AbstractBeanDefinition bd = createBeanDefinition(className, parent);
    
            // 解析Bean元素的属性并应用于Bean
            parseBeanDefinitionAttributes(ele, beanName, containingBean, bd);
            // 设置Bean的描述信息
            bd.setDescription(DomUtils.getChildElementValueByTagName(ele, DESCRIPTION_ELEMENT));
    
            // 解析Bean定义的元数据信息（meta以键值对形式存在）
            parseMetaElements(ele, bd);
            // 解析lookup-method元素
            parseLookupOverrideSubElements(ele, bd.getMethodOverrides());
            // 解析replaced-method元素
            parseReplacedMethodSubElements(ele, bd.getMethodOverrides());
    
            // 解析构造函数参数
            parseConstructorArgElements(ele, bd);
            // 解析property元素
            parsePropertyElements(ele, bd);
            // 解析qualifier元素
            parseQualifierElements(ele, bd);
    
            bd.setResource(this.readerContext.getResource());
            bd.setSource(extractSource(ele));
    
            return bd;
        }
        catch (ClassNotFoundException ex) {
            error("Bean class [" + className + "] not found", ele, ex);
        }
        catch (NoClassDefFoundError err) {
            error("Class that bean class [" + className + "] depends on not found", ele, err);
        }
        catch (Throwable ex) {
            error("Unexpected failure during bean definition parsing", ele, ex);
        }
        finally {
            this.parseState.pop();
        }
    
        return null;
    }
}


```


* BeanDefinitionReaderUtils 该类的主要职责用于生产新的BeanDefiniti实例，给Bean生成一个名称及调用BeanDefinitionRegistry进行Bean的注

```java
public class BeanDefinitionReaderUtils {

    public static String generateBeanName(
        BeanDefinition definition, BeanDefinitionRegistry registry, boolean isInnerBean)
        throws BeanDefinitionStoreException {
    
        String generatedBeanName = definition.getBeanClassName();
        if (generatedBeanName == null) {
            // 如果有父类，名称为：definition.getParentName() + “$child”
            if (definition.getParentName() != null) {
                generatedBeanName = definition.getParentName() + "$child";
            }
            // 如果有指定的工厂类，名称为：definition.getFactoryBeanName() + “$created”
            else if (definition.getFactoryBeanName() != null) {
                generatedBeanName = definition.getFactoryBeanName() + "$created";
            }
        }
        if (!StringUtils.hasText(generatedBeanName)) {
            throw new BeanDefinitionStoreException("Unnamed bean definition specifies neither " +
                                                   "'class' nor 'parent' nor 'factory-bean' - can't generate bean name");
        }
    
        String id = generatedBeanName;
        if (isInnerBean) {
            // 如果是innerBean，名称为
            id = generatedBeanName + GENERATED_BEAN_NAME_SEPARATOR + ObjectUtils.getIdentityHexString(definition);
        }
        else {
            // 如果不是InnerBean则为顶层Bean，使用简单的类名。计数器加1
            int counter = -1;
            while (counter == -1 || registry.containsBeanDefinition(id)) {
                counter++;
                id = generatedBeanName + GENERATED_BEAN_NAME_SEPARATOR + counter;
            }
        }
        return id;
    }
}


```

● parent
Bean定义可以包含许多配置信息，包括容器相关的信息（比如初始化方法，静态工厂方法等等）以及构造函数参数和属性的值。子Bean可以定义从父Bean定义中继承配置数据，而后它可以根据需要覆盖某些值，或添加其他值。使用父子Bean可以节省很多输入工作。
● lookup-method
lookup-method注入是容器重写Bean上的方法的一种能力，它可以在容器中根据一个Bean的名字返回查找结果。lookup-method通常涉及Prototype Bean。Spring框架通过使用CGLIB来覆盖该方法的子类以实现lookup-method的注入。该功能可用于在一些可插拔的功能上解除依赖。
● replace-method
用于在运行时调用使用新的方法替换原有的方法，还能动态的改变原有方法的逻辑。


```java
public class DefaultListableBeanFactory {

    // 手动注册的单例名称列表
    private volatile Set<String> manualSingletonNames = new LinkedHashSet<String>(16);
    
    public void registerBeanDefinition(String beanName, BeanDefinition beanDefinition)
    			throws BeanDefinitionStoreException {
    
        Assert.hasText(beanName, "Bean name must not be empty");
        Assert.notNull(beanDefinition, "BeanDefinition must not be null");
    
        if (beanDefinition instanceof AbstractBeanDefinition) {
            try {
                // 对于AbstractBeanDefinition属性中的methodOverrides校验
                // 校验methodOverrides是否与工厂方法并存或者methodOverrides对应的方法根本不存在
                ((AbstractBeanDefinition) beanDefinition).validate();
            }
            catch (BeanDefinitionValidationException ex) {
                throw new BeanDefinitionStoreException(beanDefinition.getResourceDescription(), beanName,
                                                       "Validation of bean definition failed", ex);
            }
        }
    
        // 从缓存中根据beanName获取BeanDefinition
        BeanDefinition existingDefinition = this.beanDefinitionMap.get(beanName);
        if (existingDefinition != null) {
            // 如果BeanDefinition存在并且不允许同名覆盖，则抛出异常
            if (!isAllowBeanDefinitionOverriding()) {
                throw new BeanDefinitionStoreException(beanDefinition.getResourceDescription(), beanName,
                                                       "Cannot register bean definition [" + beanDefinition + "] for bean '" + beanName +
                                                       "': There is already [" + existingDefinition + "] bound.");
            }
            // Bean的角色检查
            else if (existingDefinition.getRole() < beanDefinition.getRole()) {
                // e.g. was ROLE_APPLICATION, now overriding with ROLE_SUPPORT or ROLE_INFRASTRUCTURE
                if (logger.isWarnEnabled()) {
                    logger.warn("Overriding user-defined bean definition for bean '" + beanName +
                                "' with a framework-generated bean definition: replacing [" +
                                existingDefinition + "] with [" + beanDefinition + "]");
                }
            }
            // 如果名字相同，但是BeanDefinition不同打印覆盖日志
            else if (!beanDefinition.equals(existingDefinition)) {
                if (logger.isInfoEnabled()) {
                    logger.info("Overriding bean definition for bean '" + beanName +
                                "' with a different definition: replacing [" + existingDefinition +
                                "] with [" + beanDefinition + "]");
                }
            }
            else {
                if (logger.isDebugEnabled()) {
                    logger.debug("Overriding bean definition for bean '" + beanName +
                                 "' with an equivalent definition: replacing [" + existingDefinition +
                                 "] with [" + beanDefinition + "]");
                }
            }
            // 在缓存中注册Bean
            this.beanDefinitionMap.put(beanName, beanDefinition);
        }
        else {
            // 检查工厂的Bean创建阶段是否已经开始
            if (hasBeanCreationStarted()) {
                // 进入创建阶段，此时无法再修改启动时集合元素（为了稳定迭代）
                synchronized (this.beanDefinitionMap) {
                    this.beanDefinitionMap.put(beanName, beanDefinition);
                    List<String> updatedDefinitions = new ArrayList<String>(this.beanDefinitionNames.size() + 1);
                    updatedDefinitions.addAll(this.beanDefinitionNames);
                    updatedDefinitions.add(beanName);
                    this.beanDefinitionNames = updatedDefinitions;
                    // beanName在manualSingletonNames中，说明是手动注册
                    if (this.manualSingletonNames.contains(beanName)) {
                        Set<String> updatedSingletons = new LinkedHashSet<String>(this.manualSingletonNames);
                        updatedSingletons.remove(beanName);
                        this.manualSingletonNames = updatedSingletons;
                    }
                }
            }
            else {
                // 工厂还未到创建阶段，仍然在注册阶段
                this.beanDefinitionMap.put(beanName, beanDefinition);
                this.beanDefinitionNames.add(beanName);
                this.manualSingletonNames.remove(beanName);
            }
            this.frozenBeanDefinitionNames = null;
        }
    
        // 待注册的Bean的已经在beanDefinitionMap缓存中存在，或者已经存在于单例Bean缓存中
        if (existingDefinition != null || containsSingleton(beanName)) {
            // 重置给定Bean的所有BeanDefinition缓存，包括从其派生的Bean的缓存
            resetBeanDefinition(beanName);
        }
    }

}
```


## STEP3 prepareBeanFactory(beanFactory);
这个阶段主要是当Spring获取了BeanFactory之后，还要做些处理工作（配置工厂的上下文），如：上下文的ClassLoader和BeanPostProcessor。


```java
public class AbstractApplicationContext {

    protected void prepareBeanFactory(ConfigurableListableBeanFactory beanFactory) {
        // 内部BeanFactory使用Context上下文的类加载器
        beanFactory.setBeanClassLoader(getClassLoader());
        beanFactory.setBeanExpressionResolver(new StandardBeanExpressionResolver(beanFactory.getBeanClassLoader()));
        beanFactory.addPropertyEditorRegistrar(new ResourceEditorRegistrar(this, getEnvironment()));
    
        // 配置BeanFactory的Context上下文回调
        beanFactory.addBeanPostProcessor(new ApplicationContextAwareProcessor(this));
        beanFactory.ignoreDependencyInterface(EnvironmentAware.class);
        beanFactory.ignoreDependencyInterface(EmbeddedValueResolverAware.class);
        beanFactory.ignoreDependencyInterface(ResourceLoaderAware.class);
        beanFactory.ignoreDependencyInterface(ApplicationEventPublisherAware.class);
        beanFactory.ignoreDependencyInterface(MessageSourceAware.class);
        beanFactory.ignoreDependencyInterface(ApplicationContextAware.class);
    
        // BeanFactory接口不在普通工厂中注册为可解析类型
        // MessageSource 注册（找到并自动装配）为一个Bean
        beanFactory.registerResolvableDependency(BeanFactory.class, beanFactory);
        beanFactory.registerResolvableDependency(ResourceLoader.class, this);
        beanFactory.registerResolvableDependency(ApplicationEventPublisher.class, this);
        beanFactory.registerResolvableDependency(ApplicationContext.class, this);
    
        // Register early post-processor for detecting inner beans as ApplicationListeners.
        // 注册早期的后处理器用来将内部Bean检测为ApplicationListeners。
        beanFactory.addBeanPostProcessor(new ApplicationListenerDetector(this));
    
        // 如果发现LoadTimeWeaver，则准备织入
        if (beanFactory.containsBean(LOAD_TIME_WEAVER_BEAN_NAME)) {
            beanFactory.addBeanPostProcessor(new LoadTimeWeaverAwareProcessor(beanFactory));
            // 给类型匹配设置一个临时的ClassLoader
            beanFactory.setTempClassLoader(new ContextTypeMatchClassLoader(beanFactory.getBeanClassLoader()));
        }
    
        // 注册默认的environment
        if (!beanFactory.containsLocalBean(ENVIRONMENT_BEAN_NAME)) {
            beanFactory.registerSingleton(ENVIRONMENT_BEAN_NAME, getEnvironment());
        }
        // 注册systemProperties
        if (!beanFactory.containsLocalBean(SYSTEM_PROPERTIES_BEAN_NAME)) {
            beanFactory.registerSingleton(SYSTEM_PROPERTIES_BEAN_NAME, getEnvironment().getSystemProperties());
        }
        // 注册systemEnvironment
        if (!beanFactory.containsLocalBean(SYSTEM_ENVIRONMENT_BEAN_NAME)) {
            beanFactory.registerSingleton(SYSTEM_ENVIRONMENT_BEAN_NAME, getEnvironment().getSystemEnvironment());
        }
    }

}
```

BeanExpressionResolver
通过将值作为表达式进行评估来解析值。它的唯一实现类是StandardBeanExpressionResolver。
PropertyEditor
Spring使用PropertyEditor的来实现对象和字符串之间的转换。有时用与对象本身不同的方式表示属性可能更为方便。如：“2019-09-13”字符串形式阅读起来更友好，但也可以将任何方便阅读的日期表现形式转换为日期对象。


* Aware感知
如果在某个Bean里面想要使用Spring框架提供的功能，可以通过Aware接口来实现。通过实现 Aware 接口，Spring 可以在启动时，调用接口定义的方法，并将 Spring 底层的一些组件注入到自定义的 Bean 中。
ApplicationContextAware	   当ApplicationContext创建实现ApplicationContextAware接口的Bean实例时，将为该Bean实例提供对该ApplicationContext的引用。
ApplicationEventPublisherAware	   为Bean实例提供对ApplicationEventPublisherAware的引用。
BeanFactoryAware	   为Bean实例提供对BeanFactory的引用
BeanNameAware	     获取Bean在BeanFactory中配置的名字
MessageSourceAware	  为Bean实例提供对MessageSource的引用
EnvironmentAware	  获得Environment支持，这样可以获取环境变量
ResourceLoaderAware	  获得资源加载器以获得外部资源文件


BeanPostProcessor
如果想在Spring容器中完成Bean实例化、配置以及其他初始化方法前后要添加一些自己逻辑处理，就需要定义一个或多个BeanPostProcessor接口实现类，然后注册到Spring IoC容器中。


## STEP4 postProcessBeanFactory(beanFactory);

```java
public class AbstractRefreshableWebApplicationContext {

    protected void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) {
        // ServletContextAwareProcessor中拿到应用上下文持有的servletContext引用和servletConfig引用
        // 添加ServletContextAwareProcessor后处理器
        beanFactory.addBeanPostProcessor(new ServletContextAwareProcessor(this.servletContext, this.servletConfig));
        
        // 在自动注入时忽略指定的依赖接口
        beanFactory.ignoreDependencyInterface(ServletContextAware.class);
        beanFactory.ignoreDependencyInterface(ServletConfigAware.class);
    
        // 向WebApplicationContext使用的BeanFactory注册Web相关作用域对象
        WebApplicationContextUtils.registerWebApplicationScopes(beanFactory, this.servletContext);
        
        // 注册和Environment有关的beans
        WebApplicationContextUtils.registerEnvironmentBeans(beanFactory, this.servletContext, this.servletConfig);
    }

}
```

WebApplicationContextUtils
该类位于包`org.springframework.web.context.support`是一个使检索指定ServletContext的根WebApplicationContext的便捷工具类。它如下工具方法：
1. 在Web容器启动过程中注册Web相关作用域Bean（request/session/globalSession/application）
2. 在Web容器启动过程中注册相应类型的工厂Bean ，依赖注入的Bean时能访问到正确的对象（ServletRequest/ServletResponse/HttpSession/WebRequest）
3. 在Web容器启动过程中注册Web相关环境Bean
4. 在Web容器启动过程中初始化Servlet propertySources
5. 在客户化Web视图或者MVC action中，使用该工具类可以很方便地在程序中访问Spring应用上下文(application context)。


自定义作用域
Scope也称作用域，在Soring Ioc容器指其创建的Bean对象对其他Bean对象的请求可见范围，是用来声明IoC容器中的对象应该处的限定场景或者说该对象的存活空间，即在IOC容器在对象进入相应的Scope之前，生成并装配这些对象，在该对象不再处于这些scope的限定之后，容器通常会销毁这些对象。
诸如WebApplicationContext之类的ApplicationContext可以注册相对于标准作用域（Singleton/Prototype）的特定环境Scope作用域，例如：“request”和“session”作用域。
Bean的Scope作用域范围同样是可扩展的：即可以定义自己的范围，甚至重新定义现有范围，但不能覆盖内置的Singleton和Prototype范围。




## STEP5 invokeBeanFactoryPostProcessors(beanFactory);

```java
public class AbstractApplicationContext {
    protected void invokeBeanFactoryPostProcessors(ConfigurableListableBeanFactory beanFactory) {
        PostProcessorRegistrationDelegate.invokeBeanFactoryPostProcessors(beanFactory, getBeanFactoryPostProcessors());
    
        // Detect a LoadTimeWeaver and prepare for weaving, if found in the meantime
        // (e.g. through an @Bean method registered by ConfigurationClassPostProcessor)
        if (beanFactory.getTempClassLoader() == null && beanFactory.containsBean(LOAD_TIME_WEAVER_BEAN_NAME)) {
            beanFactory.addBeanPostProcessor(new LoadTimeWeaverAwareProcessor(beanFactory));
            beanFactory.setTempClassLoader(new ContextTypeMatchClassLoader(beanFactory.getBeanClassLoader()));
        }
    }

}
```

BeanFactoryPostProcessor
BeanFactoryPostProcessor接口与BeanPostProcessor相似，但有一个主要区别：BeanFactoryPostProcessor用来操作Bean的配置元数据。也就是说，
Spring IoC容器允许BeanFactoryPostProcessor读取配置元数据，并能在容器实例化任何Bean之前更改这些元数据。换句话说 ：就是可以让我们随心所欲地
修改BeanFactory内所有BeanDefinition定义数据。

BeanDefinitionRegistryPostProcessor  是对标准BeanFactoryPostProcessor的扩展，允许在进行常规BeanFactoryPostProcessor检测之前注册
其他Bean定义。特别是，BeanDefinitionRegistryPostProcessor注册的Bean定义又定义了BeanFactoryPostProcessor实例。

可以在项目中配置多个BeanFactoryPostProcessor，同时通过设置Order属性来控制这些BeanFactoryPostProcessor的执行顺序，当然仅当
BeanFactoryPostProcessor实现Ordered接口时，才可以设置此属性

Spring排序接口
Spring框架中有很多实现了相同接口的类，那么这些实现类之间必定会有优先级的问题。Spring提供了Ordered接口来处理相同接口实现类的优先级问题。
Ordered接口，顾名思义，就是用来排序的。



```java
public class PostProcessorRegistrationDelegate {

    public static void invokeBeanFactoryPostProcessors(
    			ConfigurableListableBeanFactory beanFactory, List<BeanFactoryPostProcessor> beanFactoryPostProcessors) {
    
        // 临时缓存，用来记录已经调用过的BeanFactoryPostProcessor
        Set<String> processedBeans = new HashSet<String>();
    
        // 如果BeanFactory实现了BeanDefinitionRegistry接口
        // 从类图上可以看到其实是指DefaultListableBeanFactory或者GenericApplicationContext
        if (beanFactory instanceof BeanDefinitionRegistry) {
            BeanDefinitionRegistry registry = (BeanDefinitionRegistry) beanFactory;
            // 存放普通BeanFactoryPostProcessor
            List<BeanFactoryPostProcessor> regularPostProcessors = new LinkedList<BeanFactoryPostProcessor>();
            // 存放BeanDefinitionRegistryPostProcessor
            List<BeanDefinitionRegistryPostProcessor> registryProcessors = new LinkedList<BeanDefinitionRegistryPostProcessor>();
    
            // 循环applicationContext中已经注册的BeanFactoryPostProcessor
            for (BeanFactoryPostProcessor postProcessor : beanFactoryPostProcessors) {
                // 如果是实现了BeanDefinitionRegistryPostProcessor的后处理器
                if (postProcessor instanceof BeanDefinitionRegistryPostProcessor) {
                    BeanDefinitionRegistryPostProcessor registryProcessor =
                        (BeanDefinitionRegistryPostProcessor) postProcessor;
                    // 执行postProcessBeanDefinitionRegistry回调
                    registryProcessor.postProcessBeanDefinitionRegistry(registry);
                    // 把该后处理器加入到registryProcessors
                    registryProcessors.add(registryProcessor);
                }
                else {
                    // 否则就是普通的后处理器
                    regularPostProcessors.add(postProcessor);
                }
            }
    
            // 在这里先不初始化FactoryBeans，因为需要保留这些Beans让BeanFactoryPostProcessor进行处理
            // BeanDefinitionRegistryPostProcessor将按照PriorityOrdered，Ordered进行分类
            
            // 临时缓存，用来记录待执行回调方法的BeanFactoryPostProcessor
            List<BeanDefinitionRegistryPostProcessor> currentRegistryProcessors = new ArrayList<BeanDefinitionRegistryPostProcessor>();
    
            // 首先，处理实现了PriorityOrdered接口的BeanDefinitionRegistryPostProcessor
            String[] postProcessorNames =
                beanFactory.getBeanNamesForType(BeanDefinitionRegistryPostProcessor.class, true, false);
            for (String ppName : postProcessorNames) {
                if (beanFactory.isTypeMatch(ppName, PriorityOrdered.class)) {
                    // 保存到待执行BeanFactoryPostProcess回调的缓存
                    currentRegistryProcessors.add(beanFactory.getBean(ppName, BeanDefinitionRegistryPostProcessor.class));
                    // 保存到已经执行过BeanFactoryPostProcess回调的缓存
                    processedBeans.add(ppName);
                }
            }
            // 对待执行缓存进行排序
            sortPostProcessors(currentRegistryProcessors, beanFactory);
            registryProcessors.addAll(currentRegistryProcessors);
            // 执行BeanFactoryPostProcess的回调函数
            invokeBeanDefinitionRegistryPostProcessors(currentRegistryProcessors, registry);
            // 清空待执行BeanFactoryPostProcess回调的缓存
            currentRegistryProcessors.clear();
    
            // 其次，再处理实现了Ordered接口的BeanDefinitionRegistryPostProcessor
            Next, invoke the BeanDefinitionRegistryPostProcessors that implement Ordered.
            postProcessorNames = beanFactory.getBeanNamesForType(BeanDefinitionRegistryPostProcessor.class, true, false);
            for (String ppName : postProcessorNames) {
                if (!processedBeans.contains(ppName) && beanFactory.isTypeMatch(ppName, Ordered.class)) {
                    // 保存到待执行BeanFactoryPostProcess回调的缓存
                    currentRegistryProcessors.add(beanFactory.getBean(ppName, BeanDefinitionRegistryPostProcessor.class));
                    // 保存到已经执行过BeanFactoryPostProcess回调的缓存
                    processedBeans.add(ppName);
                }
            }
            // 对待执行缓存进行排序
            sortPostProcessors(currentRegistryProcessors, beanFactory);
            registryProcessors.addAll(currentRegistryProcessors);
            // 执行BeanFactoryPostProcess的回调函数
            invokeBeanDefinitionRegistryPostProcessors(currentRegistryProcessors, registry);
            // 清空待执行BeanFactoryPostProcess回调的缓存
            currentRegistryProcessors.clear();
    
            // 最后，处理所有其他BeanDefinitionRegistryPostProcessor
            boolean reiterate = true;
            // 循环处理其他BeanDefinitionRegistryPostProcessor
            while (reiterate) {
                reiterate = false;
                // 把所有实现BeanDefinitionRegistryPostProcessor的类名取出来
                postProcessorNames = beanFactory.getBeanNamesForType(BeanDefinitionRegistryPostProcessor.class, true, false);
                // 遍历postProcessorNames
                for (String ppName : postProcessorNames) {
                    // 已经处理过的缓存不包含该类名
                    if (!processedBeans.contains(ppName)) {
                        // 保存到待执行BeanFactoryPostProcess回调的缓存
                        currentRegistryProcessors.add(beanFactory.getBean(ppName, BeanDefinitionRegistryPostProcessor.class));
                        // 保存到已经执行过BeanFactoryPostProcess回调的缓存
                        processedBeans.add(ppName);
                        reiterate = true;
                    }
                }
                // 对待执行缓存进行排序
                sortPostProcessors(currentRegistryProcessors, beanFactory);
                registryProcessors.addAll(currentRegistryProcessors);
                // 执行BeanFactoryPostProcess的回调函数
                invokeBeanDefinitionRegistryPostProcessors(currentRegistryProcessors, registry);
                // 清空待执行BeanFactoryPostProcess回调的缓存
                currentRegistryProcessors.clear();
            }
    
            // 处理所有处理器，并执行postProcessBeanFactory回调
            invokeBeanFactoryPostProcessors(registryProcessors, beanFactory);
            invokeBeanFactoryPostProcessors(regularPostProcessors, beanFactory);
        }
        else {
            // 调用在上下文中注册的工厂处理器
            invokeBeanFactoryPostProcessors(beanFactoryPostProcessors, beanFactory);
        }
    
        // 在这里不初始化FactoryBeans，因为需要让BeanFactoryPostProcessor来进行处理
        // 获取所有实现了BeanFactoryPostProcessor接口的类名称
        String[] postProcessorNames =
            beanFactory.getBeanNamesForType(BeanFactoryPostProcessor.class, true, false);
    
        // 实现了PriorityOrdered接口的PostProcessor缓存
        List<BeanFactoryPostProcessor> priorityOrderedPostProcessors = new ArrayList<BeanFactoryPostProcessor>();
        // 实现了Ordered接口的PostProcessor缓存
        List<String> orderedPostProcessorNames = new ArrayList<String>();
        // 没有实现任何Order接口的PostProcessor缓存
        List<String> nonOrderedPostProcessorNames = new ArrayList<String>();
        // 遍历postProcessorNames开始处理BeanFactoryPostProcessor
        for (String ppName : postProcessorNames) {
            if (processedBeans.contains(ppName)) {
                // 如果包含，代表在上面的代码已经处理过则跳过
            }
            // 首先，处理实现了PriorityOrdered接口的BeanFactoryPostProcessor
            else if (beanFactory.isTypeMatch(ppName, PriorityOrdered.class)) {
                priorityOrderedPostProcessors.add(beanFactory.getBean(ppName, BeanFactoryPostProcessor.class));
            }
            // 其次，处理实现了Ordered接口的BeanFactoryPostProcessor
            else if (beanFactory.isTypeMatch(ppName, Ordered.class)) {
                orderedPostProcessorNames.add(ppName);
            }
            // 最后，处理没有实现任何Order接口接口的BeanFactoryPostProcessor
            else {
                nonOrderedPostProcessorNames.add(ppName);
            }
        }
    
        // 首先，处理实现了PriorityOrdered接口的BeanFactoryPostProcessor
        sortPostProcessors(priorityOrderedPostProcessors, beanFactory);
        invokeBeanFactoryPostProcessors(priorityOrderedPostProcessors, beanFactory);
    
        // // 其次，再处理实现了Ordered接口的BeanFactoryPostProcessor
        List<BeanFactoryPostProcessor> orderedPostProcessors = new ArrayList<BeanFactoryPostProcessor>();
        for (String postProcessorName : orderedPostProcessorNames) {
            orderedPostProcessors.add(beanFactory.getBean(postProcessorName, BeanFactoryPostProcessor.class));
        }
        sortPostProcessors(orderedPostProcessors, beanFactory);
        invokeBeanFactoryPostProcessors(orderedPostProcessors, beanFactory);
    
        // // 最后，处理所有其他BeanFactoryPostProcessor
        List<BeanFactoryPostProcessor> nonOrderedPostProcessors = new ArrayList<BeanFactoryPostProcessor>();
        for (String postProcessorName : nonOrderedPostProcessorNames) {
            nonOrderedPostProcessors.add(beanFactory.getBean(postProcessorName, BeanFactoryPostProcessor.class));
        }
        invokeBeanFactoryPostProcessors(nonOrderedPostProcessors, beanFactory);
    
        // 清除被缓存的BeanDefinition，因为后处理器可能已经修改了原始元数据，例如：替换占位符
        beanFactory.clearMetadataCache();
    }

}
```


## STEP6 registerBeanPostProcessors(beanFactory);

```java
public class AbstractApplicationContext {
    // 实例化并且注册所有BeanPostProcessors
    protected void registerBeanPostProcessors(ConfigurableListableBeanFactory beanFactory) {
        PostProcessorRegistrationDelegate.registerBeanPostProcessors(beanFactory, this);
    }

}
```

BeanPostProcessor
BeanPostProcessor是Spring的Bean工厂中一个非常重要的接口，允许Spring框架在新创建Bean实例时对其进行定制化修改。比如我们对Bean内容进行修改、
创建代理对象等等。也就是说，Spring IoC容器实例化了一个Bean，而后BeanPostProcessor开始完成它们的工作。
BeanPostProcessor接口定义了回调方法，可以实现这些方法，以提供自己的实例化逻辑（或覆盖容器的默认值），依赖关系解析逻辑等。如果您想在Spring容器
完成Bean的实例化、配置和初始化之后实现一些自定义逻辑，则可以插入一个或多个自定义BeanPostProcessor实现。

```java
public interface BeanPostProcessor {
    // Bean初始化之前调用
    Object postProcessBeforeInitialization(Object bean, String beanName) throws BeansException;
    
    // Bean初始化之后调用
    Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException;
}

```

InstantiationAwareBeanPostProcessor
InstantiationAwareBeanPostProcessor实际上继承了BeanPostProcessor接口，主要作用于实例化阶段的前后。


```java
public class PostProcessorRegistrationDelegate {

    public static void registerBeanPostProcessors(
    			ConfigurableListableBeanFactory beanFactory, AbstractApplicationContext applicationContext) {
    
        // 从BeanFactory中获取所有BeanPostProcessor的名字
        String[] postProcessorNames = beanFactory.getBeanNamesForType(BeanPostProcessor.class, true, false);
    
        // 注册BeanPostProcessorChecker，以便在BeanPostProcessor实例化期间创建一个Bean时记录一条info消息
        int beanProcessorTargetCount = beanFactory.getBeanPostProcessorCount() + 1 + postProcessorNames.length;
        beanFactory.addBeanPostProcessor(new BeanPostProcessorChecker(beanFactory, beanProcessorTargetCount));
    
        // 对BeanPostProcessor按照实现的接口PriorityOrdered，Ordered进行分类并存储
        // 保存实现PriorityOrdered接口的BeanPostProcessor
        List<BeanPostProcessor> priorityOrderedPostProcessors = new ArrayList<BeanPostProcessor>();
        List<BeanPostProcessor> internalPostProcessors = new ArrayList<BeanPostProcessor>();
        // 保存实现Ordered接口的BeanPostProcessor
        List<String> orderedPostProcessorNames = new ArrayList<String>();
        // 保存没有实现PriorityOrdered和Ordered接口的BeanPostProcessor
        List<String> nonOrderedPostProcessorNames = new ArrayList<String>();
        // 遍历postProcessorNames所有的BeanPostProcessor
        for (String ppName : postProcessorNames) {
            // 如果调用适配函数，发现该类实现了PriorityOrdered接口
            if (beanFactory.isTypeMatch(ppName, PriorityOrdered.class)) {
                // 从容器中取出BeanPostProcessor
                BeanPostProcessor pp = beanFactory.getBean(ppName, BeanPostProcessor.class);
                // 保存到List集合中
                priorityOrderedPostProcessors.add(pp);
                // 如果这个类实现了MergedBeanDefinitionPostProcessor接口
                if (pp instanceof MergedBeanDefinitionPostProcessor接口) {
                    internalPostProcessors.add(pp);
                }
            }
            // 如果调用适配函数，发现该类实现了Ordered接口
            else if (beanFactory.isTypeMatch(ppName, Ordered.class)) {
                orderedPostProcessorNames.add(ppName);
            }
            // 既没有实现PriorityOrdered接口也没有实现Ordered接口
            else {
                nonOrderedPostProcessorNames.add(ppName);
            }
        }
    
        // 首先，处理实现PriorityOrdered接口的BeanPostProcessor
        // 对BeanPostProcessor进行排序
        sortPostProcessors(priorityOrderedPostProcessors, beanFactory);
        // 注册BeanPostProcessor
        registerBeanPostProcessors(beanFactory, priorityOrderedPostProcessors);
    
        // 其次，处理实现Ordered接口的BeanPostProcessor
        List<BeanPostProcessor> orderedPostProcessors = new ArrayList<BeanPostProcessor>();
        for (String ppName : orderedPostProcessorNames) {
            BeanPostProcessor pp = beanFactory.getBean(ppName, BeanPostProcessor.class);
            orderedPostProcessors.add(pp);
            if (pp instanceof MergedBeanDefinitionPostProcessor) {
                internalPostProcessors.add(pp);
            }
        }
        // 对BeanPostProcessor进行排序
        sortPostProcessors(orderedPostProcessors, beanFactory);
        // 注册BeanPostProcessor
        registerBeanPostProcessors(beanFactory, orderedPostProcessors);
    
        // 处理其他普通的BeanPostProcessor
        List<BeanPostProcessor> nonOrderedPostProcessors = new ArrayList<BeanPostProcessor>();
        for (String ppName : nonOrderedPostProcessorNames) {
            BeanPostProcessor pp = beanFactory.getBean(ppName, BeanPostProcessor.class);
            nonOrderedPostProcessors.add(pp);
            if (pp instanceof MergedBeanDefinitionPostProcessor) {
                internalPostProcessors.add(pp);
            }
        }
        registerBeanPostProcessors(beanFactory, nonOrderedPostProcessors);
    
        // 对BeanPostProcessor进行排序.
        sortPostProcessors(internalPostProcessors, beanFactory);
        // 注册BeanPostProcessor
        registerBeanPostProcessors(beanFactory, internalPostProcessors);
    
        // 重新注册后BeanPostProcessor，用于内部Bean检测为ApplicationListener，//将其移至处理器链的末尾（用于拾取代理等）
        // Re-register post-processor for detecting inner beans as ApplicationListeners,
        // moving it to the end of the processor chain (for picking up proxies etc).
        beanFactory.addBeanPostProcessor(new ApplicationListenerDetector(applicationContext));
    }

}
```

Bean的类型
Spring中有两种类型的Bean：
● 普通Bean
● 工厂Bean（即：FactoryBean）
FactoryBean
普通Bean可以直接使用Xml进行配置，但如果你的Bean拥有复杂的初始化代码（如涉及到很多其他的Bean），使用XML配置方式比较困难，这时就可以使用FactoryBean，并在该类中编写复杂的初始化，然后将自定义FactoryBean插入容器。

```java
public interface FactoryBean<T> {
    T getObject() throws Exception;   // 返回此工厂创建的对象实例
    Class<?> getObjectType();         // 返回的对象类型，如果对象类型未知则返回null
    boolean isSingleton();            // 如果FactoryBean返回单例返回true，否则返回false。
}
```

这个接口使你可以提供一个复杂的逻辑来生成Bean。它本质是一个Bean，但这个Bean不是用来注入到其它地方像Service、Dao一样使用的，它是用来生成其它Bean使用的。
Spring框架中的许多地方都使用了FactoryBean概念和接口，Spring附带了50多个FactoryBean接口实现。很多开源项目在集成Spring 时也都使用到FactoryBean，
比如 MyBatis3 提供 mybatis-spring项目中的 org.mybatis.spring.SqlSessionFactoryBean。


* Bean生命周期
Spring Bean的生命周期只有四个阶段：
1. 实例化（Instantiation）：调用构造函数
2. 属性赋值（Populate）：设置依赖注入
3. 初始化（Initialization）：调用init方法
4. 销毁（Destruction）：调用destory方法


* bean 的获取

```java
public class AbstractBeanFactory {
        
    protected <T> T doGetBean(final String name, final Class<T> requiredType, final Object[] args, boolean typeCheckOnly) throws BeansException {
    
        // 将别名解析为规范Bean名称，如果是FactoryBean还需删除前缀
        final String beanName = transformedBeanName(name);
        Object bean;
    
        // 检查缓存是否有对象
        // 循环依赖解决的关键入口
        Object sharedInstance = getSingleton(beanName);
        if (sharedInstance != null && args == null) {
            if (logger.isDebugEnabled()) {
                // 该Bean是否正在创建中
                if (isSingletonCurrentlyInCreation(beanName)) {
                    // logger.debug(.....) 打印日志（略）
                }
                else {
                    // logger.debug(.....) 打印日志（略）
                }
            }
            bean = getObjectForBeanInstance(sharedInstance, name, beanName, null);
        }
    
        else {
            // 如果已经创建了Bean实例则抛出异常，因为可能在循环引用中
            if (isPrototypeCurrentlyInCreation(beanName)) {
                throw new BeanCurrentlyInCreationException(beanName);
            }
    
            // 检查工厂中是否存在Bean定义
            BeanFactory parentBeanFactory = getParentBeanFactory();
            if (parentBeanFactory != null && !containsBeanDefinition(beanName)) {
                // Not found -> check parent.
                String nameToLookup = originalBeanName(name);
                if (args != null) {
                    // Delegation to parent with explicit args.
                    return (T) parentBeanFactory.getBean(nameToLookup, args);
                }
                else {
                    // No args -> delegate to standard getBean method.
                    return parentBeanFactory.getBean(nameToLookup, requiredType);
                }
            }
    
            if (!typeCheckOnly) {
                markBeanAsCreated(beanName);
            }
    
            try {
                // 合并BeanDefinition。合并主要是因为BeanDefinition可能存在parent BeanDefinition
                // 所以要依据合并后的BeanDefinition来实例化和初始化
                final RootBeanDefinition mbd = getMergedLocalBeanDefinition(beanName);
                // 检查合并后的BeanDefinition。主要是检查是否是abstract
                checkMergedBeanDefinition(mbd, beanName, args);
    
                // 获取依赖信息
                String[] dependsOn = mbd.getDependsOn();
                if (dependsOn != null) {
                    // 确保当前Bean依赖的Bean初始化
                    for (String dep : dependsOn) {
                        if (isDependent(beanName, dep)) {
                            // throw异常（略）
                        }
    
                        try {
                            // 注册依赖Bean
                            registerDependentBean(dep, beanName);
                            // 获取依赖Bean
                            getBean(dep);
                        } catch (NoSuchBeanDefinitionException ex) {
                            // throw异常（略）
                        }
                    }
                }
    
                // 创建Bean实例
                // 如果是单例对象
                if (mbd.isSingleton()) {
                    // 使用匿名对象工厂来创建Bean
                    sharedInstance = getSingleton(beanName, new ObjectFactory<Object>() {
                        @Override
                        public Object getObject() throws BeansException {
                            try {
                                // 创建Bean
                                return createBean(beanName, mbd, args);
                            }
                            catch (BeansException ex) {
                                // 从单例缓存中显式删除实例。在创建过程可能将它提前引用缓存中，以方便循环引用解析。
                                // 还要删除所有对该Bean临时引用的Bean
                                destroySingleton(beanName);
                                throw ex;
                            }
                        }
                    });
                    bean = getObjectForBeanInstance(sharedInstance, name, beanName, mbd);
                }
            // 如果是Prototype对象
                else if (mbd.isPrototype()) {
                    // It's a prototype -> create a new instance.
                    Object prototypeInstance = null;
                    try {
                        // 记录到当前创建的原型对象缓存
                        beforePrototypeCreation(beanName);
                        // 创建Bean
                        prototypeInstance = createBean(beanName, mbd, args);
                    }
                    finally {
                        // 创建完毕，从当前创建的原型对象缓存移除
                        afterPrototypeCreation(beanName);
                    }
                    bean = getObjectForBeanInstance(prototypeInstance, name, beanName, mbd);
                }
                // 既不是Singleton也不是Prototype，可能是自定义scope的对象
                else {
                    // 获取Scope名称
                    String scopeName = mbd.getScope();
                    // 根据名称解析出对应的Scope对象
                    final Scope scope = this.scopes.get(scopeName);
                    if (scope == null) {
                        throw new IllegalStateException("No Scope registered for scope name '" + scopeName + "'");
                    }
                    try {
                        Object scopedInstance = scope.get(beanName, new ObjectFactory<Object>() {
                            @Override
                            public Object getObject() throws BeansException {
                                // 记录到当前创建的原型对象缓存
                                beforePrototypeCreation(beanName);
                                try {
                                    // 创建Bean
                                    return createBean(beanName, mbd, args);
                                }
                                finally {
                                    // 创建完毕，从当前创建的原型对象缓存移除
                                    afterPrototypeCreation(beanName);
                                }
                            }
                        });
                        bean = getObjectForBeanInstance(scopedInstance, name, beanName, mbd);
                    }
                    catch (IllegalStateException ex) {
                        // throw异常（略）
                    }
                }
            }
            catch (BeansException ex) {
                cleanupAfterBeanCreationFailure(beanName);
                throw ex;
            }
        }
    
        // 所需的类型与实际Bean实例类型进行匹配转换
        if (requiredType != null && bean != null && !requiredType.isInstance(bean)) {
            try {
                // 转换成需要的类型
                return getTypeConverter().convertIfNecessary(bean, requiredType);
            }
            catch (TypeMismatchException ex) {
                if (logger.isDebugEnabled()) {
                    logger.debug("Failed to convert bean '" + name + "' to required type '" +
                                 ClassUtils.getQualifiedName(requiredType) + "'", ex);
                }
                throw new BeanNotOfRequiredTypeException(name, requiredType, bean.getClass());
            }
        }
        return (T) bean;
    }

}
```


```java
public class DefaultSingletonBeanRegistry {

    // 根据Bean注册名称返回单例对象，检查已经实例化的单例，并允许提前曝光当前创建的单例对象（解析循环引用）
    protected Object getSingleton(String beanName, boolean allowEarlyReference) {
        Object singletonObject = this.singletonObjects.get(beanName);
        if (singletonObject == null && isSingletonCurrentlyInCreation(beanName)) {
            synchronized (this.singletonObjects) {
                singletonObject = this.earlySingletonObjects.get(beanName);
                if (singletonObject == null && allowEarlyReference) {
                    ObjectFactory<?> singletonFactory = this.singletonFactories.get(beanName);
                    if (singletonFactory != null) {
                        singletonObject = singletonFactory.getObject();
                        this.earlySingletonObjects.put(beanName, singletonObject);
                        this.singletonFactories.remove(beanName);
                    }
                }
            }
        }
        return (singletonObject != NULL_OBJECT ? singletonObject : null);
    }
    
    // 根据Bean注册名称返回单例对象。如果尚未注册，则创建并注册一个新的
    public Object getSingleton(String beanName, ObjectFactory<?> singletonFactory) {
        Assert.notNull(beanName, "'beanName' must not be null");
        // 注意synchronized
        synchronized (this.singletonObjects) {
            // 根据Bean名称从单例缓存中获取实例
            Object singletonObject = this.singletonObjects.get(beanName);
            if (singletonObject == null) {
                if (this.singletonsCurrentlyInDestruction) {
                    // 抛出异常。原因：工厂单例销毁时不允许创建Bean实例
                    // throw new BeanCreationNotAllowedException(.......);
                }
                if (logger.isDebugEnabled()) {
                    logger.debug("Creating shared instance of singleton bean '" + beanName + "'");
                }
                // 创建前检查，主要检查两项。如果不成功抛出异常
                // 1. 正在创建缓存inCreationCheckExclusions中不包含该Bean
                // 2. 待创建缓存singletonsCurrentlyInCreation中可以添加该Bean
                beforeSingletonCreation(beanName);
                boolean newSingleton = false;
                boolean recordSuppressedExceptions = (this.suppressedExceptions == null);
                if (recordSuppressedExceptions) {
                    this.suppressedExceptions = new LinkedHashSet<Exception>();
                }
                try {
                    // 从工厂中获取单例对象
                    singletonObject = singletonFactory.getObject();
                    // 创建成功则为true
                    newSingleton = true;
                }
                catch (IllegalStateException ex) {
                    // 如果出现异常，则从单例缓存中获取
                    singletonObject = this.singletonObjects.get(beanName);
                    if (singletonObject == null) {
                        throw ex;
                    }
                }
                catch (BeanCreationException ex) {
                    if (recordSuppressedExceptions) {
                        for (Exception suppressedException : this.suppressedExceptions) {
                            ex.addRelatedCause(suppressedException);
                        }
                    }
                    throw ex;
                }
                finally {
                    if (recordSuppressedExceptions) {
                        this.suppressedExceptions = null;
                    }
                    // 创建后检查，仍然是两项检查：
                    // 1. 正在创建缓存inCreationCheckExclusions中不包含该Bean
                    // 2. 待创建缓存singletonsCurrentlyInCreation中可以移除该Bean
                    afterSingletonCreation(beanName);
                }
                // 创建成功同步几个重要的缓存
                if (newSingleton) {
                    // 同步缓存：
                    // 1. singletonObjects中添加单例对象
                    // 2. singletonFactories移除该Bean
                    // 3. earlySingletonObjects移除该Bean
                    // 4. registeredSingletons添加该BeanName
                    addSingleton(beanName, singletonObject);
                }
            }
            return (singletonObject != NULL_OBJECT ? singletonObject : null);
        }
    }


    

}
```


```java
public class AbstractAutowireCapableBeanFactory {

    // 创建实例，填充实例，应用后处理器
    protected Object createBean(String beanName, RootBeanDefinition mbd, Object[] args) throws BeanCreationException {
        if (logger.isDebugEnabled()) {
            logger.debug("Creating instance of bean '" + beanName + "'");
        }
        // 合并的BeanDefinition
        RootBeanDefinition mbdToUse = mbd;
    
        // 确保解析并加载Bean的Class
        Class<?> resolvedClass = resolveBeanClass(mbd, beanName);
        // 如果解析的类在合并的BeanDefinition不存在，则克隆Bean定义
        if (resolvedClass != null && !mbd.hasBeanClass() && mbd.getBeanClassName() != null) {
            mbdToUse = new RootBeanDefinition(mbd);
            // 设置Bean的Class
            mbdToUse.setBeanClass(resolvedClass);
        }
    
        try {
            // Spring将lookup-method和replace-method统称为override method，这里主要就是处理这2个函数
            mbdToUse.prepareMethodOverrides();
        }
        catch (BeanDefinitionValidationException ex) {
            throw new BeanDefinitionStoreException(mbdToUse.getResourceDescription(),
                                                   beanName, "Validation of method overrides failed", ex);
        }
    
        try {
            // 该函数的作用是给 BeanPostProcessors 后置处理器返回一个代理对象的机会
            // 这里是实现AOP处理的重要地方
            // AOP是通过BeanPostProcessor机制实现的，而接口InstantiationAwareBeanPostProcessor是实现代理的重点
            Object bean = resolveBeforeInstantiation(beanName, mbdToUse);
            if (bean != null) {
                return bean;
            }
        }
        catch (Throwable ex) {
            throw new BeanCreationException(mbdToUse.getResourceDescription(), beanName,
                                            "BeanPostProcessor before instantiation of bean failed", ex);
        }
    
        // 如果后处理器返回的Bean为空，则调用doCreateBean执行创建Bean的过程
        Object beanInstance = doCreateBean(beanName, mbdToUse, args);
        if (logger.isDebugEnabled()) {
            logger.debug("Finished creating instance of bean '" + beanName + "'");
        }
        return beanInstance;
    }
    
    // 实际创建指定的Bean
    protected Object doCreateBean(final String beanName, final RootBeanDefinition mbd, final Object[] args)
    			throws BeanCreationException {
    
        // BeanWrapper 是一个用于包装Bean实例的接口，通过这个接口可以设置/获取Bean实例的属性
        BeanWrapper instanceWrapper = null;
        if (mbd.isSingleton()) {
            // 从未完成的实例缓存中获取
            instanceWrapper = this.factoryBeanInstanceCache.remove(beanName);
        }
        // 如果缓存中不存在，则执行创建（三种方式）
        if (instanceWrapper == null) {
            // 创建 bean 实例，并将实例封装在BeanWrapper中返回。createBeanInstance中包含三种创建方式：
            // 1.工厂方法创建Bean实例
            // 2.通过构造方法自动注入（autowire by constructor）的方式创建
            // 3.通过无参构造方法方法创建
            // 如果Bean配置了lookup-method和replace-method，则使用CGLIB增强Bean实例
            instanceWrapper = createBeanInstance(beanName, mbd, args);
        }
        // 获取包装的Bean实例
        final Object bean = (instanceWrapper != null ? instanceWrapper.getWrappedInstance() : null);
        // 获取包装的Class
        Class<?> beanType = (instanceWrapper != null ? instanceWrapper.getWrappedClass() : null);
        // 待解析的目标类型
        mbd.resolvedTargetType = beanType;
    
        // 允许BeanPostProcessor修改合并的BeanDefinition。这里主要是合并Bean的定义信息
        // Autowired等注解就是在这一步完成预解析，并且将注解需要的信息放入缓存
        synchronized (mbd.postProcessingLock) {
            if (!mbd.postProcessed) {
                try {
                    // 应用MergedBeanDefinitionPostProcessor后处理器
                    applyMergedBeanDefinitionPostProcessors(mbd, beanType, beanName);
                }
                catch (Throwable ex) {
                    throw new BeanCreationException(mbd.getResourceDescription(), beanName,
                                                    "Post-processing of merged bean definition failed", ex);
                }
                mbd.postProcessed = true;
            }
        }
    
        // earlySingletonExposure 是一个重要的变量，用于表示是否提前暴露单例Bean，用于解决循环依赖。
        // earlySingletonExposure 由三个条件组成：是否是单例、是否允许循环引用、当前Bean是否处于创建的状态中
        boolean earlySingletonExposure = (mbd.isSingleton() && this.allowCircularReferences &&
                                          isSingletonCurrentlyInCreation(beanName));
        if (earlySingletonExposure) {
            if (logger.isDebugEnabled()) {
                logger.debug("Eagerly caching bean '" + beanName +
                             "' to allow for resolving potential circular references");
            }
            // 避免循环依赖，在Bean初始化完成前添加ObjectFactory到singletonFactories缓存。
            addSingletonFactory(beanName, new ObjectFactory<Object>() {
                @Override
                public Object getObject() throws BeansException {
                    // 此回调使后处理器有机会提前曝光Bean（即在目标Bean完全初始化之前）。通常是为了解决循环依赖
                    return getEarlyBeanReference(beanName, mbd, bean);
                }
            });
        }
    
        // 下面是初始化Bean的流程
        Object exposedObject = bean;
        try {
            // 使用BeanDefinintion的属性值填充Bean实例
            populateBean(beanName, mbd, instanceWrapper);
            if (exposedObject != null) {
                // 初始化Bean
                // 如果Bean实现了BeanNameAware、BeanClassLoaderAware、BeanFactoryAware接口则设置
                // 应用BeanPostProcessor后处理器
                // 执行自定义init-method方法
                exposedObject = initializeBean(beanName, exposedObject, mbd);
            }
        }
        catch (Throwable ex) {
            if (ex instanceof BeanCreationException && beanName.equals(((BeanCreationException) ex).getBeanName())) {
                throw (BeanCreationException) ex;
            }
            else {
                throw new BeanCreationException(
                    mbd.getResourceDescription(), beanName, "Initialization of bean failed", ex);
            }
        }
    
        if (earlySingletonExposure) {
            // 从提前曝光的Bean缓存中查询，目的是验证是否存在循环依赖
    	// 如果存在循环依赖，在这里earlySingletonReference不为空
            Object earlySingletonReference = getSingleton(beanName, false);
            // 在检测到循环依赖的情况下，earlySingletonReference不会为null
            if (earlySingletonReference != null) {
                // 如果exposedObject没有在initializeBean初始化方法中被改变，说明没有被增强
                // 初始化之后的Bean等于原始的bean说明不是proxy对象
                if (exposedObject == bean) {
                    exposedObject = earlySingletonReference;
                }
                else if (!this.allowRawInjectionDespiteWrapping && hasDependentBean(beanName)) {
                    // 确定是否已经给指定的beanName称注册了依赖
                    String[] dependentBeans = getDependentBeans(beanName);
                    Set<String> actualDependentBeans = new LinkedHashSet<String>(dependentBeans.length);
                    for (String dependentBean : dependentBeans) {
                        if (!removeSingletonIfCreatedForTypeCheckOnly(dependentBean)) {
                            actualDependentBeans.add(dependentBean);
                        }
                    }
                    // Bean创建后其依赖的Bean一定也是已经创建的
                    // 如果actualDependentBeans不为空，则表示依赖的Bean并没有被创建完，即存在循环依赖
                    if (!actualDependentBeans.isEmpty()) {
                        // 抛出异常
                        // throw new BeanCurrentlyInCreationException(....)
                    }
                }
            }    }
    
        // Register bean as disposable.
        // 如果Bean实现了Disposable，则注册该Bean为
        try {
            registerDisposableBeanIfNecessary(beanName, bean, mbd);
        }
        catch (BeanDefinitionValidationException ex) {
            throw new BeanCreationException(
                mbd.getResourceDescription(), beanName, "Invalid destruction signature", ex);
        }
    
        return exposedObject;
    }
    
    // 创建Bean实例
    protected BeanWrapper createBeanInstance(String beanName, RootBeanDefinition mbd, Object[] args) {
        // Make sure bean class is actually resolved at this point.
        Class<?> beanClass = resolveBeanClass(mbd, beanName);
    
        if (beanClass != null && !Modifier.isPublic(beanClass.getModifiers()) && !mbd.isNonPublicAccessAllowed()) {
            // 抛出异常
            // throw new BeanCreationException(.....);
        }
    
        // 如果工厂方法不为空
        if (mbd.getFactoryMethodName() != null) {
            // 使用工厂方法创建实例
            return instantiateUsingFactoryMethod(beanName, mbd, args);
        }
    
        // Shortcut when re-creating the same bean...
        boolean resolved = false;
        boolean autowireNecessary = false;
        if (args == null) {
            synchronized (mbd.constructorArgumentLock) {
                if (mbd.resolvedConstructorOrFactoryMethod != null) {
                    resolved = true;
                    autowireNecessary = mbd.constructorArgumentsResolved;
                }
            }
        }
        if (resolved) {
            if (autowireNecessary) {
                return autowireConstructor(beanName, mbd, null, null);
            }
            else {
                return instantiateBean(beanName, mbd);
            }
        }
    
        // Candidate constructors for autowiring?
        Constructor<?>[] ctors = determineConstructorsFromBeanPostProcessors(beanClass, beanName);
        if (ctors != null || mbd.getResolvedAutowireMode() == AUTOWIRE_CONSTRUCTOR ||
            mbd.hasConstructorArgumentValues() || !ObjectUtils.isEmpty(args)) {
            return autowireConstructor(beanName, mbd, ctors, args);
        }
    
        // 调用实例化策略接口来实例化Bean，这里使用无参构造
        return instantiateBean(beanName, mbd);
    }
    
    // 实例化Bean
    protected BeanWrapper instantiateBean(final String beanName, final RootBeanDefinition mbd) {
        try {
            Object beanInstance;
            final BeanFactory parent = this;
            if (System.getSecurityManager() != null) {
                beanInstance = AccessController.doPrivileged(new PrivilegedAction<Object>() {
                    @Override
                    public Object run() {
                        return getInstantiationStrategy().instantiate(mbd, beanName, parent);
                    }
                }, getAccessControlContext());
            }
            else {
                // InstantiationStrategy负责进行实例化
                // SimpleInstantiationStrategy是一个简单的用于Bean实例化的类。如：由Bean类的默认构造函数、带参构造函数或者工厂方法等来实例化Bean。不支持方法注入。
                // CglibSubclassingInstantiationStrategy如果方法需要被覆盖来实现“方法注入”，使用CGLIB动态生成子类
                beanInstance = getInstantiationStrategy().instantiate(mbd, beanName, parent);
            }
            // 实例化后的Bean使用BeanWrapper包装。BeanWrapper可以设置以及访问被包装对象的属性值
            BeanWrapper bw = new BeanWrapperImpl(beanInstance);
            // 初始化BeanWrapper包装包含了2个工作：设置ConversionService和CustomerEditor
            initBeanWrapper(bw);
            return bw;
        }
        catch (Throwable ex) {
            throw new BeanCreationException(
                mbd.getResourceDescription(), beanName, "Instantiation of bean failed", ex);
        }
    }
    
    // 初始化Bean
    protected Object initializeBean(final String beanName, final Object bean, RootBeanDefinition mbd) {
        if (System.getSecurityManager() != null) {
            AccessController.doPrivileged(new PrivilegedAction<Object>() {
                @Override
                public Object run() {
                    invokeAwareMethods(beanName, bean);
                    return null;
                }
            }, getAccessControlContext());
        }
        else {
            // 设置Aware
            invokeAwareMethods(beanName, bean);
        }
    
        Object wrappedBean = bean;
        if (mbd == null || !mbd.isSynthetic()) {
            // 调用初始化前处理器
            wrappedBean = applyBeanPostProcessorsBeforeInitialization(wrappedBean, beanName);
        }
    
        try {
            // 执行自定义初始化方法
            invokeInitMethods(beanName, wrappedBean, mbd);
        }
        catch (Throwable ex) {
            throw new BeanCreationException(
                (mbd != null ? mbd.getResourceDescription() : null),
                beanName, "Invocation of init method failed", ex);
        }
        if (mbd == null || !mbd.isSynthetic()) {
            // 调用初始化后处理器
            wrappedBean = applyBeanPostProcessorsAfterInitialization(wrappedBean, beanName);
        }
        return wrappedBean;
    }

}
```




```java
public class DefaultSingletonBeanRegistry {

    // 注册名称返回单例对象，检查已经实例化的单例，并允许提前引用当前创建的单例对象（解析循环引用）
    protected Object getSingleton(String beanName, boolean allowEarlyReference) {
        // 从单例缓存中根据Bean名字获取单例对象
        Object singletonObject = this.singletonObjects.get(beanName);
        // 如果单例对象为空，并且单例对象正在创建中
        if (singletonObject == null && isSingletonCurrentlyInCreation(beanName)) {
            // 注意synchronized关键字
            synchronized (this.singletonObjects) {
                // 从earlySingletonObjects缓存中通过Bean名称获取对象
                singletonObject = this.earlySingletonObjects.get(beanName);
                // 如果单例对象仍然为空，并且允许提前引用为true
                // allowEarlyReference参数含义：是否允许提前曝光
                if (singletonObject == null && allowEarlyReference) {
                    // 从singletonFactories中根据Bean名称获取对应的单例工厂
                    ObjectFactory<?> singletonFactory = this.singletonFactories.get(beanName);
                    if (singletonFactory != null) {
                        // 通过工厂创建单例对象（此时还未进行依赖注入）
                        singletonObject = singletonFactory.getObject();
                        // 把创建的单例对象放到提前引用的缓存
                        this.earlySingletonObjects.put(beanName, singletonObject);
                        // 移除该单例对象的工厂
                        this.singletonFactories.remove(beanName);
                    }
                }
            }
        }
    }
}
```

代码中出现的缓存：
1. 一级缓存：singletonObjects：初始化完成的单例对象缓存；
2. 二级缓存：earlySingletonObjects：提前曝光的单例对象缓存；
3. 三级缓存：singletonFactories：单例Bean的工厂函数对象缓存；
4. singletonsCurrentlyInCreation：即将创建的单例集合


## STEP7 initMessageSource();
TODO


## STEP8 initApplicationEventMulticaster();
* 容器生命周期
BeanPostProcessor及Bean的初始和销毁回调这些事件都是建立在容器已经成功启动的基础上，如果我们想在容器本身的生命周期。

常规的Lifecycle接口只在容器上下文显式的调用start()/stop()方法时，才会去回调Lifecycle实现类的start/stop方法逻辑。并不意味着在上下文刷新时自动启动。
另外，LifeCycle Bean在销毁之前不能保证会收到停止通知。正常关闭时，所有Lifecycle Bean在销毁回调之前首先会收到停止通知，但是在上下文的生命周期内进行热刷新或中止刷新尝试时，只会调用destroy方法。



事件机制
Spring事件机制中除了事件对象和监听者者两个角色之外，“事件广播器”则负责把事件转发给监听者：


## STEP9 onRefresh();
* 初始化主题  跟 web 有关系 
SpringMVC框架主题可以设置应用程序的整体外观，从而增强用户体验。主题是静态资源的集合，通常有css样式表和图片构成，这些css样式和图片会直接影响应用程序的视觉样式。
要在Web应用中使用主题，必须实现ThemeSource接口，WebApplicationContext接口就扩展了ThemeSource，但将其职责委托给专用的实现。
默认委托将是ResourceBundleThemeSource，该实现从类路径的根加载主题属性文件。要使用自定义ThemeSource或需要配置ResourceBundleThemeSource的属性，
可以在应用程序上下文中注册使用保留名称'themeSource'的Bean，Web应用程序上下文会自动检测到具有'themeSource'名称的Bean并使用它。

## STEP10 registerListeners();
* 注册事件监听

```java
public class AbstractApplicationContext {

    protected void registerListeners() {
        // 注册静态指定的监听器
        for (ApplicationListener<?> listener : getApplicationListeners()) {
            getApplicationEventMulticaster().addApplicationListener(listener);
        }
    
        // 从BeanFactory中获取listener的名称，并注册
        String[] listenerBeanNames = getBeanNamesForType(ApplicationListener.class, true, false);
        for (String listenerBeanName : listenerBeanNames) {
            getApplicationEventMulticaster().addApplicationListenerBean(listenerBeanName);
        }
    
        // 发布早期事件
        Set<ApplicationEvent> earlyEventsToProcess = this.earlyApplicationEvents;
        this.earlyApplicationEvents = null;
        if (earlyEventsToProcess != null) {
            for (ApplicationEvent earlyEvent : earlyEventsToProcess) {
                getApplicationEventMulticaster().multicastEvent(earlyEvent);
            }
        }
    }

}


```





## STEP11 finishBeanFactoryInitialization(beanFactory);
* 完成初始化


## STEP12 finishRefresh();
* 


## STEP13 











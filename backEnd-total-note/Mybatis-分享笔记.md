

### sqlSession
```java

public class DefaultSqlSession implements SqlSession {
  // 主要的成员变量
  private final Configuration configuration;
  private final Executor executor;
```

### mapper 和 mapper.xml的对应过程

（1）将所有的xml文件load到configuration
###

配置顺序
```
<?xml version="1.0" encoding="UTF-8"?>
<configuration><!--配置-->
	<properties/><!--属性-->
	<settings/><!--设置-->
	<typeAliases/><!--类型别名-->
	<typeHandlers/><!--类型处理器-->
	<objectFactory/><!--对象工厂-->
	<plugins/><!--插件-->
	<environments><!--配置环境-->
		<environment><!--环境变量-->
		<transactionManager/><!--事务管理器-->
			<dataSource/><!--数据源-->
		</environment>
	</environments>
	<databaseidProvider/><!--数据库厂商标识-->
	<mappers/><!--映射器-->
</configuration>

```


```java
(1) XMLConfigBuilder.parse()
  private void parseConfiguration(XNode root) {
    try {
      //issue #117 read properties first
      propertiesElement(root.evalNode("properties"));
      Properties settings = settingsAsProperties(root.evalNode("settings"));
      loadCustomVfs(settings);
      loadCustomLogImpl(settings);
      typeAliasesElement(root.evalNode("typeAliases"));
      pluginElement(root.evalNode("plugins"));
      objectFactoryElement(root.evalNode("objectFactory"));
      objectWrapperFactoryElement(root.evalNode("objectWrapperFactory"));
      reflectorFactoryElement(root.evalNode("reflectorFactory"));
      settingsElement(settings);
      // read it after objectFactory and objectWrapperFactory issue #631
      environmentsElement(root.evalNode("environments"));
      databaseIdProviderElement(root.evalNode("databaseIdProvider"));
      typeHandlerElement(root.evalNode("typeHandlers"));
      mapperElement(root.evalNode("mappers"));
    } catch (Exception e) {
      throw new BuilderException("Error parsing SQL Mapper Configuration. Cause: " + e, e);
    }
  }

（2）MapperProxy 作为所有mapper的实现类
最终会调用sqlSession的方法，其实就是executor
key： 命名空间+ID

通过一个接口去实现功能，没有实现类，不可思议
接口 -> SQL 一一对应

TestMapper 对开发者友好使用，对底层的SQL进行映射






```



XmlConfigBuilder

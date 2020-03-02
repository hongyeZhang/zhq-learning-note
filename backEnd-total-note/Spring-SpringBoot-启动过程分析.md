## SpringApplication构造方法
SpringApplication类的作用

　　　　SpringApplication用于从java main方法引导和启动Spring应用程序，默认情况下，将执行以下步骤来引导我们的应用程序：
　　　　　　1、创建一个恰当的ApplicationContext实例（取决于类路径）
　　　　　　2、注册CommandLinePropertySource，将命令行参数公开为Spring属性
　　　　　　3、刷新应用程序上下文，加载所有单例bean
　　　　　　4、触发全部CommandLineRunner bean
　　　　   大多数情况下，像SpringApplication.run(ShiroApplication.class, args);这样启动我们的应用，也可以在运行之前创建和
           自定义SpringApplication实例，具体可以参考注释中示例。
　　　　    SpringApplication可以从各种不同的源读取bean。 通常建议使用单个@Configuration类来引导，但是我们也可以通过以下方式来设置资源：
　　　　　　1、通过AnnotatedBeanDefinitionReader加载完全限定类名
　　　　　　2、通过XmlBeanDefinitionReader加载XML资源位置，或者是通过GroovyBeanDefinitionReader加载groovy脚本位置
　　　　　　3、通过ClassPathBeanDefinitionScanner扫描包名称


SpringApplication构造方法主要是三个函数
deduceWebApplicationType();

getSpringFactoriesInstances(xxx.class);

deduceMainApplicationClass();

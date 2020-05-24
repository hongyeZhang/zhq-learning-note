
## 单元测试

在工作中，当被问到“如何提高代码质量”，回答无非如下几个，增加评审，代码规约，单元测试。
不知起自何年何月，如今一些机构开始引入“单元测试覆盖率”的概念，并由此对程序员提出了覆盖率
要达到70%，90%，以此来评判程序员工作的质量，以及产品的质量。

#### 什么是单元测试

单元测试是开发者编写的一小段代码，用于检验被测代码的一个很小的、很明确的功能是否正确，通常而言，一个单元测试是用于判断某个特定条件（或者场景）下某个特定函数的行为。
3.1好处

    1，单元测试不但会使你的工作完成得更轻松。而且会令你的设计会变得更好，甚至大大减少你花在调试上面的时间
    2，提高代码质量
    3，减少bug，快速定位bug
    4，放心地修改、重构
    5，显得专业（玩笑话）

3.2注意

    1，不能只测试一条正确执行路径，要考虑到所有可能的情况
    2，要确保所有测试都能够通过，避免间接损害
    3，如果一个函数复杂到无法单测，那就说明模块的抽象有问题

（1）语句覆盖法
（2）分支覆盖法
（3）条件覆盖法
（4）组合条件覆盖法

**展示测试报告**
1）启动单元测试覆盖模式（Run “*” with Coverage）


## mockito 框架
```
（1） 在使用mock进行初始化时
@Before
public void setUp() {
    MockitoAnnotations.initMocks(this);
}
与
@RunWith(MockitoJUnitRunner.class)
效果是一样的，可以避免空指针错误，二者应用一个就可以了
```

Mock不是真实的对象，它只是用类型的class创建了一个虚拟对象，并可以设置对象行为
Spy是一个真实的对象，但它可以设置对象行为
InjectMocks创建这个类的对象并自动将标记@Mock、@Spy等注解的属性值注入到这个中


**spy 与 mock 的区别**
标题@Spy与@Mock区别和实践
@Spy修饰的外部类，必须是真实存在的，如果没有我们要自己生成创建
@Mock修饰的外部类,是完全模拟出来的，就算项目中没有这个类的实例，也能自己mock出来一个。

spy的原理是，如果不打桩默认都会执行真实的方法，如果打桩则返回桩实现。
除了支持@Mock，Mockito支持的注解还有@Spy（监视真实的对象），
@Captor（参数捕获器），@InjectMocks（mock对象自动注入）。


## powerMock

@Mock: 创建一个Mock.
@InjectMocks: 创建一个实例，其余用@Mock（或@Spy）注解创建的mock将被注入到用该实例中。
注意：必须使用@RunWith(MockitoJUnitRunner.class) 或 Mockito.initMocks(this)进行mocks的初始化和注入。

在单元测试中，没有启动 spring 框架，此时就需要通过
InjectMocks完成依赖注入。InjectMocks会将带有@Spy 和@Mock 注解的对象尝试注入到被
测试的目标类中。


相信有些朋友也碰到和我一样的问题，mockito结合powermock做单元测试会碰到一些明明程序看起来没问题，却始终报错。
有可能的问题就是版本使用不对，大家如果遇到这样的问题可以试试。（PS:当然也不绝对一定是版本的问题）

Mockito                     | PowerMock
--| --|
2.0.0-beta - 2.0.42-beta    |   1.6.5+
二者存在版本对应关系


```
<properties>
        <java.version>1.8</java.version>
        <powermock.version>1.7.4</powermock.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>

        <!-- https://mvnrepository.com/artifact/org.mockito/mockito-core -->
        <dependency>
            <groupId>org.mockito</groupId>
            <artifactId>mockito-core</artifactId>
            <version>2.8.9</version>
            <scope>test</scope>
        </dependency>

        <dependency>
            <groupId>org.powermock</groupId>
            <artifactId>powermock-module-junit4</artifactId>
            <version>${powermock.version}</version>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.powermock</groupId>
            <artifactId>powermock-api-mockito2</artifactId>
            <version>${powermock.version}</version>
            <scope>test</scope>
        </dependency>

        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.12</version>
        </dependency>

```

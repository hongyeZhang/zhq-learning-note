

### @ComponentScan


### @RequestMapping
@RequestMapping 中method的默认值是什么?

没有默认值，如果不配置method，
则以任何请求形式
RequestMethod.GET，
RequestMethod.POST，
RequestMethod.PUT，
RequestMethod.DELETE都可以访问得到。

### @Repository
@Repository 只能标注在 DAO 类上呢？这是因为该注解的作用不只是将类识别为Bean，
同时它还能将所标注的类中抛出的数据访问异常封装为 Spring 的数据访问异常类型。 Spring本身
提供了一个丰富的并且是与具体的数据访问技术无关的数据访问异常结构，用于封装不同的持久层框架
抛出的异常，使得异常独立于底层的框架。

### @RequestParam
GET和POST请求传的参数会自动转换赋值到@RequestParam 所注解的变量上
@RequestParam（org.springframework.web.bind.annotation.RequestParam）用于将指定的请求参数赋值给方法中的形参。
也可以不使用@RequestParam，直接接收，此时要求controller方法中的参数名称要跟form中name名称一致

### @RequestParam
用来处理Content-Type: 为 application/x-www-form-urlencoded编码的内容。提交方式为get或post。（Http协议中，如果不指定Content-Type，则默认传递的参数就是application/x-www-form-urlencoded类型）
RequestParam实质是将Request.getParameter() 中的Key-Value参数Map利用Spring的转化机制ConversionService配置，转化成参数接收对象或字段。
get方式中query String的值，和post方式中body data的值都会被Servlet接受到并转化到Request.getParameter()参数集中，所以@RequestParam可以获取的到。

### @RequestBody
@RequestBody注解可以接收json格式的数据，并将其转换成对应的数据类型。

@RequestBody处理HttpEntity传递过来的数据，一般用来处理非Content-Type: application/x-www-form-urlencoded编码格式的数据。
GET请求中，因为没有HttpEntity，所以@RequestBody并不适用。
POST请求中，通过HttpEntity传递的参数，必须要在请求头中声明数据的类型Content-Type，SpringMVC通过使用HandlerAdapter 配置的HttpMessageConverters来解析HttpEntity中的数据，然后绑定到相应的bean上。
@RequestBody用于post请求，不能用于get请求


在@RequestMapping注解方法中获取URL变量-@PathVariable
@RequestMapping("/find/{id}/{name}")
public User getUser(@PathVariable("id") int myId, @PathVariable("name") String myName) {
    User user = new User();
    user.setId(myId);
    user.setName(myName);
    user.setDate(new Date());

    return user;
}

### @Nullable
@Nullable 表示定义的参数可以为空.

    @NonNull可以标注在方法、字段、参数之上，表示对应的值不可以为空
    @Nullable注解可以标注在方法、字段、参数之上，表示对应的值可以为空

    以上两个注解在程序运行的过程中不会起任何作用，只会在IDE、编译器、FindBugs检查、生成文档的时候有做提示；我使用的IDE是STS，不会做自动的检查，只有安装了FindBugs插件并运行后会做对应的提示，

```
public Reflections(final String prefix, @Nullable final Scanner... scanners) {
        this((Object) prefix, scanners);
    }
```

### @SuppressWarnings
简介：java.lang.SuppressWarnings是J2SE 5.0中标准的Annotation之一。可以标注在类、字段、方法、参数、构造方法，以及局部变量上。
作用：告诉编译器忽略指定的警告，不用在编译完成后出现警告信息。
使用：
@SuppressWarnings(“”)
@SuppressWarnings({})
@SuppressWarnings(value={})

根据sun的官方文档描述：
value - 将由编译器在注释的元素中取消显示的警告集。允许使用重复的名称。忽略第二个和后面出现的名称。出现未被识别的警告名不是 错误：编译器必须忽略无法识别的所有警告名。但如果某个注释包含未被识别的警告名，那么编译器可以随意发出一个警告。
各编译器供应商应该将它们所支持的警告名连同注释类型一起记录。鼓励各供应商之间相互合作，确保在多个编译器中使用相同的名称。
示例：
· @SuppressWarnings("unchecked")
告诉编译器忽略 unchecked 警告信息，如使用List，ArrayList等未进行参数化产生的警告信息。
· @SuppressWarnings("serial")
如果编译器出现这样的警告信息：The serializable class WmailCalendar does not declare a static final serialVersionUID field of type long
使用这个注释将警告信息去掉。
· @SuppressWarnings("deprecation")
如果使用了使用@Deprecated注释的方法，编译器将出现警告信息。
使用这个注释将警告信息去掉。
· @SuppressWarnings("unchecked", "deprecation")
告诉编译器同时忽略unchecked和deprecation的警告信息。
· @SuppressWarnings(value={"unchecked", "deprecation"})

等同于@SuppressWarnings("unchecked", "deprecation")

@SuppressWarnings可以抑制一些能通过编译但是存在有可能运行异常的代码会发出警告，你确定代码运行时不会出现警告提示的情况下，可以使用这个注释。
("serial") 是序列化警告，当实现了序列化接口的类上缺少serialVersionUID属性的定义时，会出现黄色警告。可以使用@SuppressWarnings将警告关闭

### @ConfigurationProperties
我们想把配置文件的信息，读取并自动封装成实体类，这样子，我们在代码里面使用就轻松方便多了，这时候，我们就可以使用@ConfigurationProperties，它可以把同类的配置信息自动封装成实体类


### @FunctionalInterface  java

    该注解是信息类注解，用于表示使用的接口是一个 Java 语言规范定义的功能性接口（如果一个接口中包含不止一个抽象方法，添加该注解后编译会报错）；
    使用该注解的接口只能有一个抽象方法，默认方法、静态方法都不算抽象方法；
    接口中重写 Object 的方法也不算抽象方法；
    无论接口中是否存在 @FunctionalInterface 注解，编译器都会将满足功能接口定义的任何接口视为功能接口。

spring不但支持自己定义的@Autowired注解，还支持几个由JSR-250规范定义的注解，它们分别是@Resource、@PostConstruct以及@PreDestroy。
　　@Resource的作用相当于@Autowired，只不过@Autowired按byType自动注入，而@Resource默认按 byName自动注入罢了。@Resource有两个属性是比较重要的，分是name和type，Spring将@Resource注解的name属性解析为bean的名字，而type属性则解析为bean的类型。所以如果使用name属性，则使用byName的自动注入策略，而使用type属性时则使用byType自动注入策略。如果既不指定name也不指定type属性，这时将通过反射机制使用byName自动注入策略。
　　@Resource装配顺序
　　1. 如果同时指定了name和type，则从Spring上下文中找到唯一匹配的bean进行装配，找不到则抛出异常
　　2. 如果指定了name，则从上下文中查找名称（id）匹配的bean进行装配，找不到则抛出异常
　　3. 如果指定了type，则从上下文中找到类型匹配的唯一bean进行装配，找不到或者找到多个，都会抛出异常
　　4. 如果既没有指定name，又没有指定type，则自动按照byName方式进行装配；如果没有匹配，则回退为一个原始类型进行匹配，如果匹配则自动装配；


### @import
把用到的bean导入当前的容器

@qualifier
@Autowired是根据类型进行自动装配的。如果当Spring上下文中存在不止一个UserDao类型的bean时，就会抛出BeanCreationException异常;如果Spring上下文中不存在UserDao类型的bean，也会抛出BeanCreationException异常。我们可以使用@Qualifier配合@Autowired来解决这些问题。如下：

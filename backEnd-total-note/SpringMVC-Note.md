=====================   Spring MVC Note ====================================
(1) ModelAndView
使用ModelAndView类用来存储处理完后的结果数据，以及显示该数据的视图。从名字上
看ModelAndView中的Model代表模型，View代表视图，这个名字就很好地解释了该类的作用。
业务处理器调用模型层处理完用户请求后，把结果数据存储在该类的model属性中，把要返回的
视图信息存储在该类的view属性中，然后让该ModelAndView返回该Spring MVC框架
框架通过调用配置文件中定义的视图解析器，对该对象进行解析，最后把结果数据显示在指定的页面上。

(2)
@Controller 注解，在对应的方法上，视图解析器可以解析return 的jsp,html页面，并且跳转到相应页面
若返回json等内容到页面，则需要加@ResponseBody注解

<context:component-scan base-package=”com.eric.spring”>

其中base-package为需要扫描的包（含所有子包），多个包可以用逗号分隔。@Service用于标注业务层组件，
@Controller用于标注控制层组件（如struts中的action），@Repository用于标注数据访问组件，即DAO组件，
而@Component泛指组件，当组件不好归类的时候，我们可以使用这个注解进行标注。



主要的设计思路
mvc分层的原理

首先这是现在最基本的分层方式，结合了SSH架构。
1.modle层就是对应的数据库表的实体类。
2.Dao层是使用了hibernate连接数据库、操作数据库（增删改查）。
3.Service层：引用对应的Dao数据库操作，在这里可以编写自己需要的代码（比如简单的判断）。
4.Action层：引用对应的Service层，在这里结合Struts的配置文件，跳转到指定的页面，当然也能接受页面传递的请求数据，也可以做些计算处理。
以上的Hibernate，Struts，都需要注入到spring的配置文件中，Spring把这些联系起来，成为一个整体。

一般Java都是三层架构 数据访问层（dao） 业务逻辑层（biz 或者services） 界面层（ui）。

1.action 是业务层的一部分，是一个管理器 （总开关）（作用是取掉转）（取出前台界面的数据，调用biz方法，转发到下一个action或者页面）

2.模型成（model）一般是实体对象(把现实的的事物变成java中的对象)作用是一暂时存储数据方便持久化（存入数据库或者写入文件）而是 作为一个包裹封装一些数据来在不同的层以及各种java对象中使用

3.  dao是数据访问层 就是用来访问数据库实现数据的持久化（把内存中的数据永久保存到硬盘中）



1.Dao主要做数据库的交互工作

2.Modle 是模型 存放你的实体类

3.Service 做相应的业务逻辑处理

4.Action是一个控制器

最基本的分层方式，结合了SSH架构。
1.modle层就是对应的数据库表的实体类(如User类)。
2.Dao层，一般可以再分为***Dao接口和***DaoImpl实现类，如userDao接口和userDaoImpl实现类,接口负责定义数据库curd的操作方法，实现类负责具体的实现，即实现Dao接口定义的方法。
3.Service层，引用对应的Dao层数据库操作，在这里可以编写自己需要的代码（比如简单的判断），也可以再细分为Service接口和ServiceImpl实现类。
4.Action层：引用对应的Service层实现业务逻辑，在这里结合Struts的配置文件，跳转到指定的页面，当然也能接受页面传递的请求数据，也可以做些计算处理、前端输入合法性检验(前端可修改网页绕过前端合法性检验，需在后台加一层)。



1. Action像是服务员，顾客点什么菜，菜上给几号桌，都是ta的职责；

2.Service是厨师，action送来的菜单上的菜全是ta做的；

3.Dao是厨房的小工，和原材料(通过hibernate操作数据库)打交道的事情全是ta管。



   对象的调用流程：JSP—Action—Service—DAO—Hibernate—数据库


   九、Spring中的拦截器：
   Spring为我们提供了：
   org.springframework.web.servlet.HandlerInterceptor接口，

   org.springframework.web.servlet.handler.HandlerInterceptorAdapter适配器，
   实现这个接口或继承此类，可以非常方便的实现自己的拦截器。

   有以下三个方法：

   Action之前执行:
    public boolean preHandle(HttpServletRequest request,
      HttpServletResponse response, Object handler);

   生成视图之前执行
    public void postHandle(HttpServletRequest request,
      HttpServletResponse response, Object handler,
      ModelAndView modelAndView);

   最后执行，可用于释放资源
    public void afterCompletion(HttpServletRequest request,
      HttpServletResponse response, Object handler, Exception ex)


   分别实现预处理、后处理（调用了Service并返回ModelAndView，但未进行页面渲染）、返回处理（已经渲染了页面）
   在preHandle中，可以进行编码、安全控制等处理；
   在postHandle中，有机会修改ModelAndView；
   在afterCompletion中，可以根据ex是否为null判断是否发生了异常，进行日志记录。
   参数中的Object handler是下一个拦截器。

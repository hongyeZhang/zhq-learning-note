================   servlet  笔记 =====================

配置环境，做本章的练习题，5月30日实践内容
手机呼叫震动问题
听筒声音小的问题

1 简介
servlet = server + applet，运行在服务端的java程序，提供基于请求-响应的Web服务
servlet容器：创建和管理servlet：创建、执行、销毁，本质是服务端程序，将请求转发给
servlet处理。
===========================
05-30晚  做练习：一个servelt的处理程序  001 servlet技术《已完成》
===========================
处理流程：见视频
2 servlet接口与实现类
servlet生命周期
init -> service(doget dopost) -> destory(销毁)
===========================
05-30晚  做练习：002 servlet接口与实现类（destroy销毁没有实现）
===========================
GET方法： 通过HTTP header进行传输，URL是可见的，主要是获取数据
POST方法：通过HTTP body进行传输，URL不可见，提交数据无限制，发送数据到服务器
POST方法安全性更高
servlet配置参数
SerlvetConfig
===========================
05-30晚 servlet配置练习 做练习：002 servlet接口与实现类《已完成》
===========================
不同Servlet共享配置信息
servletContext 读取事先知道的共享信息
两个页面，用户选购、结算处理
动态信息共享练习
servletContext：
（1）通过配置文件共享全局配置信息
（2）通过ServletContext属性实现不同Servlet之间的通信
读取外部资源配置信息：
主要方法：

Web应用程序基本结构
webapp
web.xml文件：部署描述符
支持多个servlet pattern 支持同一个servlet
XML语法：设置web应用 程序的部署信息
url-pattern 支持模糊匹配
ServletMapping匹配规则（优先级顺序）
完全匹配 -> 最长路径匹配（最长长度匹配） ->扩展名匹配 ->  default匹配
访问页面不存在：
load-on-startup 改变servlet默认初始化时间，在部署完、未发出请求时进行初始化

欢迎页面：（设置默认制定的文件）
<welcome-file-list>

MIME类型映射：多用途互联网邮件扩展类型
<mime-mapping>

005 Cookie 与 Session
会话：HTTP请求加响应
会话使用场景：偏好记录、自动登录、浏览记录
原理：客户端或者服务端保存数据
Cookie ： 将会话数据保存在浏览器客户端 key-value
Session: 将会话数据保存在服务器端
Cookie声明周期：默认会话结束后失效（会话cookie） setMaxAge
大小、数量限制
HttpSession：
invalidate:使Session失效

006 转发与重定向
请求转发 servletA -> servletB，浏览器地址不变
将当前额request response 对象交给指定的web组件处理
RequestDispatcher
两个主要方法：forward方法 和 include方法
获取转发对象：HttpServletRequest
ServletContext

请求重定向
sendRedirect :两次请求，两次响应
============
做练习
============
请求转发：地址栏不会发生变化，同一个web应用之内，一次请求，一次响应
请求重定向：地址栏会发生变化，可以跨web应用和服务器，两次请求，两次响应

007 过滤器与监听器
过滤器：过滤请求与响应，自定义过滤规则，
客户端 <-> 过滤器 <-> Servlet容器
过滤器应用场景：用户认证、编解码处理、数据压缩处理
filter生命周期：
init -> doFilter -> destroy
过滤器链：
监听器：  事件源 <-> 监听器
监听事件发生，在事件发生前后能够做出相应处理的web应用组件
监听器分类：监听应用程序环境、监听用户请求对象、监听用户会话对象
应用场景：应用统计、任务触发、业务需求
启动顺序：监听器 -> 过滤器 -> Servlet

008 Servlet 并发处理
单实例：一个servlet对象、多线程、线程不安全。
ServletContext线程不安全、HttpSession理论上线程安全、ServletRequest线程安全
Servlet中不再建立别的线程
synchronized 同步块做加锁处理
==========================================
线程不安全实例（注意string name的建立位置）
==========================================

009 JSP
java server page  动态网页技术标准，简化的servlet

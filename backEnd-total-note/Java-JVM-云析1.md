## class文件结构（上）
类文件结构：
（1）是不是只有java编译器才能将java文件编译成class字节码文件？
不是。Jython/Scala/Groovy/JRuby都是可以编译成字节码文件的。

（2）class文件包含：虚拟机指令、符号表、其他辅助信息。共有两种数据结构：表、无符号数

知识1：什么是u1 u2 u4 u8   是数据结构
	u1一个字节；
	u2二个字节；
	u4四个字节；
	u8八个字节；

知识2：字节码的具体解释
第一个u4字节代表这是一个class文件：cafe babe（固定的）
第二个u4字节代表JDK编译的版本号：JDK7 ===> 51，JDK8 ===> 52
需要注意，否则编译的时候会报错误
无符号数：就是数值；

============ class  常量池
常量池计数器
表，是一个结构：xxxx_info{u4,u2,u1...}
无符号数：就是数值
常量池主要存放量的类常量： 字面量、符号引用
字面量：int m = 3; (字面量就是=号右边的东西)
符号引用：
命令行：javap -v name.class
javap是 Java class文件分解器，可以反编译（即对javac编译的文件进行反编译），也可以查看java编译器生成的字节码。用于分解class文件。

init和clinit
init：实例化初始化方法
clinit：类和接口的初始化
class Example{
   static int m = 3*(int)(Math.random()*5.0);
}

class Example{
   static int m;
   static{
      m = 3*(int)(Math.random()*5.0);
   }
}
所有的类变量初始化语句和静态初始化语句都被Java编译搜集到一起，放到clinit;
init：
	调用new初始化对象的时候；
	调用反射的时候newInstance()；
	调用clone方法的时候
	ObjectInpustream.getObject序列化的时候；

解读虚拟机指令，如（按图索骥）：
invokespecial #1
第一步，到常量池里面找#1常量（#1：MethodRef #4，#22）
        #4  指向Class_info的索引项（u2类型数据）
        #22 指向的就NameAndType的索引项（u2类型数据）

第二步：找#4号常量（#4号常量是Class： java/lang/Thread）
第三步：找#22号常量（#7：#8）
第四步：NameAndType的数据结构（u2：名称常量项的索引；u2：描述符常量项的索引）
第五步：#7对应<init>
第六步：#8对应()V
搜索的结果：V java/lang/Thread.<init>()

其他的字段表示可以看ppt
类的元数据：描述类的数据

其后跟着的是access_flags   访问标志
再往后是   类索引、父类索引、接口索引集合

问题3：类名应该多长？
       不能超过256

访问控制标志：0x0001|0x0020=0x0021 这就是为什么字节码是00 21

类索引、父类索引、接口计数器、接口1、接口1
00 03    00 04     00 02        00 05   00 06
00 03代表3#常量索引：ai/yunxi/classfile/TestCF
00 04代表4#常量索引：java/lang/Thread
00 02代表有几个接口，当前是2个（Serializable, Comparable）
00 05代表5#常量索引：就是接口java/io/Serializable
00 06代表6#常量索引：就是接口java/io/Serializable


## class文件结构（下）
主要是讲解了class文件如何看，涉及到code  exception  tableNumber等内容
后面没有仔细去看，如果有需要，再讲这些课程看一遍，配合《JVM虚拟机》的书
关于方法表的查找方法：
步骤	查找内容		字节码	翻译后内容
1	找到访问控制	access_flag	00 01	public
2	找到简单名字	name_index	00 17	inc
3	找到描述符	descriptor_index	00 18	()I
翻译后过来：public int inc()

4	找到属性计数器	attribute_count	00 01	有一个属性表
5	对照属性表	attribute_info	(u2, u4, u1*length)
6	找到属性名字索引	attribute_name_index	00 11	Code
7	找到属性长度	attribute_length	00 00 00 be	190

8	找到最大栈深	max_stacks	00 01	最大栈深为1
9	对照最大变量数	max_locals	00 05	变量数为5
10	找到代码行数	code_length	00 00 00 18	代码行数24
11	找到字节码	0x04         =====>  iconst_1
0x3c         =====>  istore_1
putstatic #3  =====>  b3 xx xx
max_stacks  方法的栈深
max_locals  方法的本地变量数量
args_size   方法的参数有多少个（默认是this，如果方法是static那么就是0）
字节码指令参考：https://segmentfault.com/a/1190000008722128

12.	异常表
字节码顺序：00 00 00 04 00 08 00 02
翻译后内容：from:0  to:4  target:8  index:#2(java/lang/Exception)
如果没有异常表，会出现如下问题：
	debug断点的问题
	错误日志没有行号

13.	本地变量表(LocalVariableTable)
     Start+length:一个本地变量的作用域
     Slot：几个槽来存储
 Name：简单名字

14.	Signature
     伪泛型。


第二课 虚拟机加载机制

加载class文件到内存
1.加载（三件事）
	这个文件在哪个地方？它是jar包还是class文件？
          java estClass
          java -jar
	静态存储结构转化方法区的运行时数据结构
	Java堆里面生成一个Class对象（相当于一个句柄），去访问方法区。

2.验证
  魔数
  版本

3.解析



==========================  虚拟机类的加载机制  =====================
第一步：加载
1.获取二进制字节流
2.静态存储结构转化为方法区的运行时数据结构
3.在Java堆里面生成一个类对象，作为方法区的访问入口。
运行时数据区：包括方法区、堆、虚拟机栈、本地方法栈、程序计数器
new object 中放类的实例，存入堆区。
 类从被加载到虚拟内存中开始，到卸载内存为止，整个生命周期包括五步：
 加载、连接（验证、准备、解析）、初始化、使用、卸载

第二步：验证
1.验证Class文件的标识：魔数Magic Number
2.验证Class文件的版本号
3.验证常量池（常量类型、常量类型数据结构是否正确、UTF8是否符合标准）
4.Class文件的每个部分（字段表、方法表等）是否正确
5.元数据验证（父类验证、继承验证、final验证）
6.字节码验证（指令验证）
7.符号引用验证（通过符号引用是否能找到字段、方法、类）

IncompatibleClassChangeError
Unsupported major.minor version xx.x主要版本有问题
IllegalAccessError
NoSuchFieldError
NoSuchMethodError

第三步：准备
为类变量分配内存并且设置类变量的初始化阶段。
只对static类变量进行内存分配。
static int n = 2;
初始化值是0，而不是2。因为这个时候还没执行任何Java方法（<clinit>）。

static final int n = 2;
对应到常量池 ConstantValue，在准备阶段n必须被赋值成2。

类变量：一般称为静态变量。
实例变量：当对象被实例化的时候，实例变量就跟着确定。随着对象销毁而销毁。


第四步：解析

第四步：解析
对符号引用进行解析。
直接引用：指向目标的指针或者偏移量。
符号引号====>直接引用
主要涉及：类、接口、字段、方法（接口、类）等。
CONSTANT_Class_info
CONSTANT_Fieldref_info
CONSTANT_Methodref_info
CONSTANT_InterfaceMethodref_info
CONSTANT_MethodType_info
CONSTANT_MethodHandler_info（方法=>vtable 接口=>itable）
CONSTANT_invokeDynamic_info
匹配规则：简单名字+描述符同时满足
1.字段的解析
  class A extends B implements C, D{
     private String str; //字段的解析
  }
  在本类里面去找有没有匹配的字段===>如果类有接口，往上层接口找匹配的字段===>搜索父类
  解析字段的顺序：A(分类)===>C, D(父接口)===>B(父类)===>Object(根类)
  如果找到了，但是没有权限：java.lang.IllegalAccessError
  如果失败（没找到）：java.lang.NoSuchFieldError

2.类方法的解析
  class A extends B implements C, D{
     private void inc(); //方法的解析
  }
  在本类里面去找有没有匹配的方法===>父类去找匹配的方法===>接口列表里面去找匹配方法（代表本类是一个抽象类，查找结束，抛出java.lang.AbstractMethodError异常）
  如果找到了，但是没有权限：java.lang.IllegalAccessError
  如果失败（没找到）：java.lang.NoSuchMethodError

3.接口方法的解析
  在本类里面去找有没有匹配的方法===>父类接口中递归查找
  如果失败（没找到）：java.lang.NoSuchMethodError


虚方法表vtable 索引来代替元数据查找以提高性能，虚方法表中存放着各个方法的实际入口地址

第五步：初始化
   初始化就是执行<clinit>()方法的过程。
   <clinit>如果没有静态块，静态变量则没有<clinit>
   <init>类的实例构造器
   class A {
       static int i = 2;
       static {
          System.out.println(“”);
       }
       int n;
   }
<clinit>静态变量，静态块的初始化
<init>类的初始化



==========================  类加载器  =====================
类加载器：
sun.misc.Launcher
.........
var1 = Launcher.ExtClassLoader.getExtClassLoader();
this.loader = Launcher.AppClassLoader.getAppClassLoader(var1);
.........

问题：ExtClassLoader 和AppClassLoader有什么关系？
while(c!=null){
   System.out.println(c)
   c = c.getParent();
}
代码运行结果：
sun.misc.Launcher$AppClassLoader@18b4aac2
sun.misc.Launcher$ExtClassLoader@6d6f6e28

AppClassLoader有一个干爹：ExtClassLoader
问题：ExtClassLoader有没有干爹呢？
// 是不是同时只有一个可以loadClass，同时保证Class唯一性
synchronized (getClassLoadingLock(name)) {
   Class<?> c = findLoadedClass(name);
   if (c==null)
   .........
}

// native代表调用一个本地方法。本地方法是由C/C++编写而成
private native Class<?> findBootstrapClass(String name);

ExtClassLoader有一个干爹：BootstrapClassLoader
一个类的加载顺序是：自顶向下
一个类的检查顺序是：自底向上
机制：双亲委任/双亲委派
目的：安全
1.父类加载的不给子类加载
2.一个加载一次

判断两个对象相对不相对，最重要的条件：是不是一个类加载器。
自定义类加载器


==========================  java虚拟机运行时数据区  =====================
静态编译：将java文件变为字节码class文件，class文件以静态方式存在
类加载器：将class字节码文件加载到内存中。

方法区（method area）： 存放一些类的元数据（简单名字、描述符等）
堆区（heap）：new出来的object，主要用来存放对象实例。
栈区（stack）：虚拟机栈、本地方法栈、程序计数器
JDK内存规范：
堆和方法区是在运行时所有线程共享。栈是线程私有的，执行逻辑的位置。
程序 = 数据 + 算法
遇到outofmemeory的时候，考虑：
（1）是否有非常大的对象
（2）。。。 计算java对象大小的方法
方法区存放：已被虚拟机加载的类信息、常量、静态变量、即时编译器编译后的代码（JIT？）

java -- 静态编译 --> byteCode -- 动态编译 --> 本地指令（机器指令）
JIT : 热点代码编译后存储在方法区
程序计数器（寄存器）：program counter  存放下一条指令的地址
栈：栈帧（存放调用逻辑）

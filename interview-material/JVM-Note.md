
## JVM调优相关
内存分析工具MAT(Memory Analyzer Tool)
建立一套同JVM参数模板，设置一些常见的参数，稀奇古怪的拉七八糟的参数不要设置

## 一份JVM参数设置模板(4C8G)
```
-Xms4096M
-Xmx4096M
-Xmn3072M
-Xss1M
-XX:MetaspaceSize=256M
-XX:MaxMetaspaceSize=256M
-XX:+UseParNewGC
-XX:+UseConcMarkSweepGC
-XX:CMSInitiatingOccupancyFaction=92
-XX:+UseCMSCompactAtFullCollection
-XX:CMSFullGCsBeforeCompaction=0
-XX:+CMSParallelInitialMarkEnabled
-XX:+CMSScavengeBeforeRemark
-XX:+DisableExplicitGC
-XX:+PrintGCDetails
-Xloggc:gc.log (可以不要)
-XX:+HeapDumpOnOutOfMemoryError
-XX:HeapDumpPath=/usr/local/app/oom
```

* QPS：每秒多少个请求
* TPS: 每秒的事务量，一般用于数据库层面

* 启动参数中建议要加的
```
-XX:+DisableExplicitGC
-XX:CMSFullGCsBeforeCompaction=0  强制让CMS收集器每次FullGC之后整理老年代的碎片
-XX:CMSScavengeBeforeRemark 让CMS收集器在FullGC之前强制做一个MinorGC
-XX:+HeapDumpOnOutOfMemoryError  发生OOM时自动dump二进制文件
-XX:HeapDumpPath=/usr/local/app/oom 


```

```
-Xms10m
-Xmx10m
-XX:+HeapDumpOnOutOfMemoryError  异常时自动打印
-XX:HeapDumpPath=D:\dump\HeapOOM.hprof
-XX:+PrintGCDetails  打印GC日志
-Xss 虚拟机栈+本地方法栈容量大小 
   XSS含义：每个线程的堆栈大小。
   JDK5.0以后每个线程堆栈大小为1M,以前每个线程堆栈大小为256K.更具应用的线程所需内存大小进行 调整.在相同物理内存下,减小这个值能生成更多的线程.但是操作系统对一个进程内的线程数还是有限制的,不能无限生成,经验值在3000~5000左右
   一般小的应用， 如果栈不是很深， 应该是128k够用的 大的应用建议使用256k。这个选项对性能影响比较大，需要严格的测试。（校长）
-XX:+TraceClassLoading  跟踪显示类加载机制




```

* 获得堆转储文件  jmap -dump:format=b,file=<dumpfile.hprof> <pid>

元数据空间解析
used:加载类的空间量；
capacity:当前分配块的元数据的空间；
committed:空间块的数量；
reserved:元数据的空间保留（但不一定提交的量）



## 实战调优


## 将java文件打成jar包
javac Demo1.java
jar cvf Demo1.jar Demo1.class



### 实现YoungGC
```
// 参数设置
-XX:NewSize=5242880
-XX:MaxNewSize=5242880
-XX:InitialHeapSize=10485760
-XX:MaxHeapSize=10485760
-XX:SurvivorRatio=8
-XX:PretenureSizeThreshold=10485760
-XX:+UseParNewGC
-XX:+UseConcMarkSweepGC
-XX:+PrintGCDetails
-XX:+PrintGCTimeStamps
-Xloggc:gc.log

```



### 对象由新生代进入老年代
```
// 参数设置
-XX:NewSize=10485760
-XX:MaxNewSize=10485760
-XX:InitialHeapSize=20971520
-XX:MaxHeapSize=20971520
-XX:SurvivorRatio=8
-XX:MaxTenuringThreshold=15
-XX:PretenureSizeThreshold=10485760
-XX:+UseParNewGC
-XX:+UseConcMarkSweepGC
-XX:+PrintGCDetails
-XX:+PrintGCTimeStamps
-Xloggc:gc2.log

```

### 对象由新生代进入老年代
```
// 参数设置
-XX:NewSize=104857600
-XX:MaxNewSize=104857600
-XX:InitialHeapSize=209715200
-XX:MaxHeapSize=209715200
-XX:SurvivorRatio=8
-XX:MaxTenuringThreshold=15
-XX:PretenureSizeThreshold=3145728
-XX:+UseParNewGC
-XX:+UseConcMarkSweepGC
-XX:+PrintGCDetails
-XX:+PrintGCTimeStamps
-Xloggc:gc3.log

jstat -gc 7268 1000 1000
```


### 实战命令
```
jstat -gc PID

每秒钟打印一次，可以分析每秒钟系统会新增多少对象，一共统计10次
jstat -gc PID 1000 10 

jmap -heap PID
jmap -histo PID 了解系统运行时的对象分布
生成堆内存数据
jmap -dump:live,format=b,file=dump.hprof PID
jhat dump.hprof -port 7000 在浏览器中分析堆转出快照

```









### java性能调优的七种武器

#### java命令行
jps
jinfo
jstat
jmap
线上运行的服务，谨慎使用jmap

java mission control

####  memory analyzer(mat)

https://www.cnblogs.com/AloneSword/p/3821569.html


### 简介
JVM从软件层面屏蔽不同操作系统在底层硬件和指令上的区别



### 常用工具

## jmap

打印指定Java进程(或核心文件、远程调试服务器)的共享对象内存映射或堆内存细节。

jmap命令可以获得运行中的jvm的堆的快照，从而可以离线分析堆，以检查内存泄漏，检查一些严重影响性能的大对象的创建，
检查系统中什么对象最多，各种对象所占内存的大小等等。可以使用jmap生成Heap Dump。

java memory = direct memory（直接内存） + jvm memory(MaxPermSize +Xmx)

1)直接内存跟堆
直接内存则是一块由程序本身管理的一块内存空间，它的效率要比标准内存池要高，主要用于存放网络通信时数据缓冲和磁盘数据交换时的数据缓冲。
DirectMemory容量可以通过 -XX:MaxDirectMemorySize指定，如果不指定，则默认为与Java堆的最大值（-Xmx指定）一样。但是，在OSX上的最新版本的 JVM，对直接内存的默认大小进行修订，改为“在不指定直接内存大小的时默认分配的直接内存大小为64MB”，可以通过 -XX:MaxMemorySize来显示指定直接内存的大小。
2)堆(Heap)和非堆(Non-heap)内存

按照官方的说法：“Java 虚拟机具有一个堆，堆是运行时数据区域，所有类实例和数组的内存均从此处分配。堆是在 Java 虚拟机启动时创建的。”“在JVM中堆之外的内存称为非堆内存(Non-heap memory)”。
可以看出JVM主要管理两种类型的内存：堆和非堆。简单来说堆就是Java代码可及的内存，是留给开发人员使用的；非堆就是JVM留给自己用的，
所以方法区、JVM内部处理或优化所需的内存(如JIT编译后的代码缓存)、每个类结构(如运行时常数池、字段和方法数据)以及方法和构造方法的代码都在非堆内存中。

3)栈与堆

栈解决程序的运行问题，即程序如何执行，或者说如何处理数据；堆解决的是数据存储的问题，即数据怎么放、放在哪儿。

在Java中一个线程就会相应有一个线程栈与之对应，这点很容易理解，因为不同的线程执行逻辑有所不同，因此需要一个独立的线程栈。而堆则是所有线程共享的。栈因为是运行单位，因此里面存储的信息都是跟当前线程（或程序）相关信息的。包括局部变量、程序运行状态、方法返回值等等；而堆只负责存储对象信息。

Java的堆是一个运行时数据区,类的(对象从中分配空间。这些对象通过new、newarray、anewarray和multianewarray等 指令建立，它们不需要程序代码来显式的释放。堆是由垃圾回收来负责的，堆的优势是可以动态地分配内存大小，生存期也不必事先告诉编译器，因为它是在运行时 动态分配内存的，Java的垃圾收集器会自动收走这些不再使用的数据。但缺点是，由于要在运行时动态分配内存，存取速度较慢。 栈的优势是，存取速度比堆要快，仅次于寄存器，栈数据可以共享。但缺点是，存在栈中的数据大小与生存期必须是确定的，缺乏灵活性。栈中主要存放一些基本类 型的变量（,int, short, long, byte, float, double, boolean, char）和对象句柄。

线程占用大小在MaxPermSize中进行内存申请和分配


什么是堆Dump

堆Dump是反应Java堆使用情况的内存镜像，其中主要包括系统信息、虚拟机属性、完整的线程Dump、所有类和对象的状态等。 一般，在内存不足、GC异常等情况下，我们就会怀疑有内存泄露。这个时候我们就可以制作堆Dump来查看具体情况。分析原因。
基础知识

Java虚拟机的内存组成以及堆内存介绍 Java GC工作原理 常见内存错误：

   outOfMemoryError 年老代内存不足。
   outOfMemoryError:PermGen Space 永久代内存不足。
   outOfMemoryError:GC overhead limit exceed 垃圾回收时间占用系统运行时间的98%或以上。

打印出某个java进程（使用pid）内存内的，所有‘对象’的情况（如：产生那些对象，及其数量）。它的用途是为了展示java进程的内存映射信息，或者堆内存详情。

可以输出所有内存中对象的工具，甚至可以将VM 中的heap，以二进制输出成文本。

jmap -heap:format=b pid   bin格式  javaversion 1.5
jmap -dump:format=b,file=filename pid javaversion >1.6

jmap -dump:format=b,file=outfile 3024可以将3024进程的内存heap输出出来到outfile文件里，再配合MAT（内存分析工具(Memory Analysis Tool）或与jhat (Java Heap Analysis Tool)一起使用，能够以图像的形式直观的展示当前内存是否有问题。

64位机上使用需要使用如下方式：

jmap -J-d64 -heap pid


## javac
javac [ options ] [ sourcefiles ] [ @files ]
参数可按任意次序排列。
options命令行选项。sourcefiles一个或多个要编译的源文件（例如 MyClass.java）。@files一个或多个对源文件进行列表的文件。

```
使用java命令运行class文件提示“错误：找不到或无法加载主类“的问题分析
有时候我们需要直接用jdk提供的java命令来执行class文件让软件运行起来，特别是很多初学者，但经常会发现如下提示：
用eclipse或用ant则没有问题。

其实原因很简单，我们忽略了2个细节。
1.java指令默认在寻找class文件的地址是通过CLASSPATH环境变量中指定的目录中寻找的。
2.我们忽略了package的影响。

第一个问题好解决：
我们直接在CLASSPATH环境变量中加入“.;”即可。“.”的意思是搜索当前目录
第二个问题看下面分析：
看下面两个类
                  类A                                                                   类B
类A和类B的唯一差别就是没有定义包名。
我们的工程路径是D:\HelloWorld,在HelloWorld文件夹中建立一个src文件夹，类B的源代码文件就放在src中。用javac编译完以后
会在src文件夹中生成NewsManager.class,如下
执行如下：
现在我们再把源代码换成类A

为什么加入了package后就不对了呢？

类A中package的路径是org.will.app.main。按照java规定，我们应该按照package定义的路径来存放源文件，类A应该放入：

src\org\will\app\main下，如下：

然后我们编译执行：

依然有问题，为什么，其实大家再回去看看java的书籍就会发现，一个类的全名应该是包名+类名。类A的全名：org.will.app.main.NewsManager

好的，再试试：

还是不对。为什么？

仔细看上面的图，我们在main目录下让java命令去执行org.will.app.main.NewsManager,其实它会以为类的路径是：

D:\HelloWorld\src\org\will\app\main\org\will\app\main\NewsManager，大家看到了吧，路径重复了。


一、java执行class文件是根据CLASSPATH指定的地方来找，不是我们理解当前目录。如果希望它查询当前目录，需要在CLASSPATH中加入“.;”,代表当前目录。

二、java执行class文件对package的路径是强依赖的。它在执行的时候会严格以当前用户路径为基础，按照package指定的包路径转化为文件路径去搜索class文件。各位同学以后注意就OK啦。\
至于网上说的要在CLASSPATH要加各种包等等都是泛泛而谈，真正静下心分析这个问题的资料不多。很多都没有说到点子上，会误导人的。
```

## jstack
jstack是java虚拟机自带的一种堆栈跟踪工具。jstack用于打印出给定的java进程ID或core file或远程调试服务的Java堆栈信息，如果是在64位机器上，需要指定选项"-J-d64"，Windows的jstack使用方式只支持以下的这种方式：
jstack [-l] pid

主要分为两个功能：
a．  针对活着的进程做本地的或远程的线程dump；
b．  针对core文件做线程dump。

jstack用于生成java虚拟机当前时刻的线程快照。线程快照是当前java虚拟机内每一条线程正在执行的方法堆栈的集合，生成线程快照的主要目的是定位线程出现长时间停顿的原因，如线程间死锁、死循环、请求外部资源导致的长时间等待等。 线程出现停顿的时候通过jstack来查看各个线程的调用堆栈，就可以知道没有响应的线程到底在后台做什么事情，或者等待什么资源。 如果java程序崩溃生成core文件，jstack工具可以用来获得core文件的java stack和native stack的信息，从而可以轻松地知道java程序是如何崩溃和在程序何处发生问题。另外，jstack工具还可以附属到正在运行的java程序中，看到当时运行的java程序的java stack和native stack的信息, 如果现在运行的java程序呈现hung的状态，jstack是非常有用的。

jstack命令主要用来查看Java线程的调用堆栈的，可以用来分析线程问题（如死锁）
线程状态
想要通过jstack命令来分析线程的情况的话，首先要知道线程都有哪些状态，下面这些状态是我们使用jstack命令查看线程堆栈信息时可能会看到的线程的几种状态：
NEW,未启动的。不会出现在Dump中。
RUNNABLE,在虚拟机内执行的。运行中状态，可能里面还能看到locked字样，表明它获得了某把锁。
BLOCKED,受阻塞并等待监视器锁。被某个锁(synchronizers)給block住了。
WATING,无限期等待另一个线程执行特定操作。等待某个condition或monitor发生，一般停留在park(), wait(), sleep(),join() 等语句里。
TIMED_WATING,有时限的等待另一个线程的特定操作。和WAITING的区别是wait() 等语句加上了时间限制 wait(timeout)。
TERMINATED,已退出的。

#### Monitor
```
在多线程的 JAVA程序中，实现线程之间的同步，就要说说 Monitor。 Monitor是 Java中用以实现线程之间的互斥与协作的主要手段，它可以看成是对象或者 Class的锁。每一个对象都有，也仅有一个 monitor。下 面这个图，描述了线程和 Monitor之间关系，以 及线程的状态转换图：
thread
进入区(Entrt Set):表示线程通过synchronized要求获取对象的锁。如果对象未被锁住,则迚入拥有者;否则则在进入区等待。一旦对象锁被其他线程释放,立即参与竞争。
拥有者(The Owner):表示某一线程成功竞争到对象锁。
等待区(Wait Set):表示线程通过对象的wait方法,释放对象的锁,并在等待区等待被唤醒。
从图中可以看出，一个 Monitor在某个时刻，只能被一个线程拥有，该线程就是 “Active Thread”，而其它线程都是 “Waiting Thread”，分别在两个队列 “ Entry Set”和 “Wait Set”里面等候。在 “Entry Set”中等待的线程状态是 “Waiting for monitor entry”，而在“Wait Set”中等待的线程状态是 “in Object.wait()”。 先看 “Entry Set”里面的线程。我们称被 synchronized保护起来的代码段为临界区。当一个线程申请进入临界区时，它就进入了 “Entry Set”队列。对应的 code就像：
synchronized(obj) {
.........

}

调用修饰
表示线程在方法调用时,额外的重要的操作。线程Dump分析的重要信息。修饰上方的方法调用。
locked <地址> 目标：使用synchronized申请对象锁成功,监视器的拥有者。
waiting to lock <地址> 目标：使用synchronized申请对象锁未成功,在迚入区等待。
waiting on <地址> 目标：使用synchronized申请对象锁成功后,释放锁幵在等待区等待。
parking to wait for <地址> 目标
```


## jps
```
 jps是jdk提供的一个查看当前java进程的小工具， 可以看做是JavaVirtual Machine Process Status Tool的缩写。非常简单实用。

       命令格式：jps [options ] [ hostid ]

       [options]选项 ：
-q：仅输出VM标识符，不包括classname,jar name,arguments in main method
-m：输出main method的参数
-l：输出完全的包名，应用主类名，jar的完全路径名
-v：输出jvm参数
-V：输出通过flag文件传递到JVM中的参数(.hotspotrc文件或-XX:Flags=所指定的文件
-Joption：传递参数到vm,例如:-J-Xms512m

        [hostid]：

[protocol:][[//]hostname][:port][/servername]

        命令的输出格式 ：
lvmid [ [ classname| JARfilename | "Unknown"] [ arg* ] [ jvmarg* ] ]

1）jps
2）jps –l: 输出主类或者jar的完全路径名
3）jps –v :输出jvm参数
4）jps –q ：仅仅显示java进程号
5)jps -mlv10.134.68.173
注意：如果需要查看其他机器上的jvm进程，需要在待查看机器上启动jstatd。



1. 列出PID和Java主类名

jps

2017 Bootstrap
2576 Jps

2. 列出pid和java完整主类名

jps -l

2017 org.apache.catalina.startup.Bootstrap
2612 sun.tools.jps.Jps

3. 列出pid、主类全称和应用程序参数

jps -lm

2017 org.apache.catalina.startup.Bootstrap start
2588 sun.tools.jps.Jps -lm

4. 列出pid和JVM参数

jps -v

2017 Bootstrap -Djava.util.logging.config.file=/usr/local/tomcat-web/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Dfile.encoding=UTF-8 -Xms256m -Xmx1024m -XX:PermSize=256m -XX:MaxPermSize=512m -verbose:gc -Xloggc:/usr/local/tomcat-web/logs/gc.log-2014-02-07 -XX:+UseConcMarkSweepGC -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -Xnoclassgc -Djava.endorsed.dirs=/usr/local/tomcat-web/endorsed -Dcatalina.base=/usr/local/tomcat-web -Dcatalina.home=/usr/local/tomcat-web -Djava.io.tmpdir=/usr/local/tomcat-web/temp
2624 Jps -Dapplication.home=/usr/lib/jvm/jdk1.6.0_43 -Xms8m

5. 和【ps -ef | grep java】类似的输出

jps -lvm

2017 org.apache.catalina.startup.Bootstrap start -Djava.util.logging.config.file=/usr/local/tomcat-web/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Dfile.encoding=UTF-8 -Xms256m -Xmx1024m -XX:PermSize=256m -XX:MaxPermSize=512m -verbose:gc -Xloggc:/usr/local/tomcat-web/logs/gc.log-2014-02-07 -XX:+UseConcMarkSweepGC -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -Xnoclassgc -Djava.endorsed.dirs=/usr/local/tomcat-web/endorsed -Dcatalina.base=/usr/local/tomcat-web -Dcatalina.home=/usr/local/tomcat-web -Djava.io.tmpdir=/usr/local/tomcat-web/temp
2645 sun.tools.jps.Jps -lvm -Dapplication.home=/usr/lib/jvm/jdk1.6.0_43 -Xms8m
```

## javap
在命令行中直接输入javap或javap -help可以看到javap的options有如下选项：
一般常用的是-v -l -c三个选项。
javap -v classxx，不仅会输出行号、本地变量表信息、反编译汇编代码，还会输出当前类用到的常量池等信息。
javap -l 会输出行号和本地变量表信息。
javap -c 会对当前class字节码进行反编译生成汇编代码。


## jconsole
JConsole 是一个内置 Java 性能分析器，可以从命令行或在 GUI shell 中运行。您可以轻松地使用 JConsole（或者，它更高端的 “近亲” VisualVM ）来监控 Java 应用程序性能和跟踪 Java 中的代码





## 存储
JVM按照其存储数据的内容将所需内存分配为堆区与非堆区两个部分：所谓堆区即为通过new的方式创建的对象（类实例）所占用的内存空间；非堆区即为代码、常量、外部访问（如文件访问流所占资源）等。然而虽然java的垃圾回收机制虽然能够很好的解决内存浪费的问题，但是这种机制也仅仅的是回收堆区的资源，而对于非堆区的资源就束手无策了，针对这样的资源回收只能凭借开发人员自身的约束来解决。就算是这样
（堆区有java回收机制、非堆区开发人员能够很好的解决），当运行时所需内存瞬间激增的时候JVM无奈
的也要中止程序的运行。所以本文讲述的是如何解决后者的问题。


## 参数配置
#### 堆内存配置
Java 虚拟机具有一个堆，堆是运行时数据区域，所有类实例和数组的内存均从此处分配。堆是在 Java 虚拟机启动时创建的。对象的堆内存由称为垃圾回收器的自动内存管理系统回收。堆的大小可以固定，也可以扩大和缩小。堆的内存不需要是连续空间。

**-Xms** 表示java虚拟机堆区内存初始内存分配的大小，默认为物理内存的1/64
**-Xmx** 表示java虚拟机堆区内存可被分配的最大上限，默认为物理内存的1/4。
开发过程中，通常会将 -Xms 与 -Xmx两个参数的配置相同的值，其目的是为了能够在java垃圾回收机制清理完堆区后不需要重新分隔计算堆区的大小而浪费资源。
**-XX:newSize** 表示新生代初始内存的大小，应该小于 -Xms的值
**-XX:MaxnewSize** 表示新生代可被分配的内存的最大上限；当然这个值应该小于 -Xmx的值；
**-Xmn** 新生代大小。是对 -XX:newSize、-XX:MaxnewSize两个参数的同时配置，也就是说如果通过-Xmn来配置新生代的内存大小，那么-XX:newSize = -XX:MaxnewSize = -Xmn
**-XX:NewRatio** 设置新生代和老年代的比值。默认年轻代与老年代比值为1：2
**-XX:SurvivorRatio** 新生代中Eden区与两个Survivor区的比值。默认Eden：Survivor=8：1，一个Survivor区占整个新生代的1/10  
**-XX:MaxTenuringThreshold** 设置转入老年代的存活次数。如果是0，则直接跳过新生代进入老年代


#### 非堆内存配置
Java 虚拟机管理堆之外的内存（称为非堆内存）。Java 虚拟机具有一个由所有线程共享的方法区。方法区属于非堆内存。它存储每个类结构，如运行时常数池、字段和方法数据，以及方法和构造方法的代码。它是在 Java 虚拟机启动时创建的。方法区在逻辑上属于堆，但 Java 虚拟机实现可以选择不对其进行回收或压缩。与堆类似，方法区的大小可以固定，也可以扩大和缩小。方法区的内存不需要是连续空间。除了方法区外，Java 虚拟机实现可能需要用于内部处理或优化的内存，这种内存也是非堆内存。例如，JIT 编译器需要内存来存储从 Java 虚拟机代码转换而来的本机代码，从而获得高性能。

java虚拟机对非堆区内存配置的两个参数：
**PermSize** 非堆内存初始值，默认是物理内存的1/64  （Java8以前）
**MaxPermSize** 最大非堆内存的大小，默认是物理内存的1/4 （Java8以前）
此处内存是不会被java垃圾回收机制进行处理的地方。并且更加要注意的是 最大堆内存与最大非堆内存的和绝对不能够超出操作系统的可用内存。
**-XX:MetaspaceSize** ： 元空间最小大小
**-XX:MaxMetaspaceSize** ：分别设置与最大大小（Java8以后）

**-Xss** 	每个线程的堆栈大小
JDK5.0以后每个线程堆栈大小为1M,以前每个线程堆栈大小为256K.更具应用的线程所需内存大小进行
调整.在相同物理内存下,减小这个值能生成更多的线程.但是操作系统对一个进程内的线程数还是有限制的,
不能无限生成,经验值在3000~5000左右
一般小的应用， 如果栈不是很深， 应该是128k够用的 大的应用建议使用256k。这个选项对性能影响比较大，需要严格的测试。（校长）
和threadstacksize选项解释很类似,官方文档似乎没有解释,在论坛中有这样一句话:"”
-Xss is translated in a VM flag named ThreadStackSize”
一般设置这个值就可以了
-Xss 设置每个线程可使用的内存大小，即栈的大小。在相同物理内存下，减小这个值能生成更多的线程，当然操作系统对一个进程内的线程数还是有限制的，不能无限生成。线程栈的大小是个双刃剑，如果设置过小，可能会出现栈溢出，特别是在该线程内有递归、大的循环时出现溢出的可能性更大，如果该值设置过大，就有影响到创建栈的数量，如果是多线程的应用，就会出现内存溢出的错误。

#### 收集器设置
-XX:+UseSerialGC:设置串行收集器
-XX:+UseParallelGC:设置并行收集器
-XX:+UseParalledlOldGC:设置并行老年代收集器
-XX:+UseConcMarkSweepGC:设置并发收集器

#### 垃圾回收统计信息
-XX:+PrintGC
-XX:+PrintGCDetails
-XX:+PrintGCTimeStamps
-Xloggc:filename

#### 并行收集器设置
-XX:ParallelGCThreads=n:设置并行收集器收集时使用的CPU数。并行收集线程数。
-XX:MaxGCPauseMillis=n:设置并行收集最大暂停时间
-XX:GCTimeRatio=n:设置垃圾回收时间占程序运行时间的百分比。公式为1/(1+n)
并发收集器设置
-XX:+CMSIncrementalMode:设置为增量模式。适用于单CPU情况。
-XX:ParallelGCThreads=n:设置并发收集器新生代收集方式为并行收集时，使用的CPU数。并行收集线程数。






### 方法区
方法区：是JVM的一种规范，存放类信息、常量、静态变量、即时编译器编译后的代码等；
永久代：是HotSpot的一种具体实现，实际指的就是方法区，
备注：由于方法区主要存储类的相关信息，所以对于动态生成类的情况比较容易出现永久代的内存溢出。最典型的场景就是，在 jsp 页面比较多的情况，容易出现永久代内存溢出。

元空间的本质和永久代类似，都是对JVM规范中方法区的实现。不过元空间与永久代之间最大的区别在于：元空间并不在虚拟机中，而是使用本地内存。因此，默认情况下，元空间的大小仅受本地内存限制，但可以通过以下参数来指定元空间的大小：

-XX:MetaspaceSize，初始空间大小，达到该值就会触发垃圾收集进行类型卸载，同时GC会对该值进行调整：如果释放了大量的空间，就适当降低该值；如果释放了很少的空间，那么在不超过MaxMetaspaceSize时，适当提高该值。
-XX:MaxMetaspaceSize，最大空间，默认是没有限制的。

除了上面两个指定大小的选项以外，还有两个与 GC 相关的属性：
-XX:MinMetaspaceFreeRatio，在GC之后，最小的Metaspace剩余空间容量的百分比，减少为分配空间所导致的垃圾收集
-XX:MaxMetaspaceFreeRatio，在GC之后，最大的Metaspace剩余空间容量的百分比，减少为释放空间所导致的垃圾收集


通过上面分析，大家应该大致了解了 JVM 的内存划分，也清楚了 JDK 8 中永久代向元空间的转换。不过大家应该都有一个疑问，就是为什么要做这个转换？所以，最后给大家总结以下几点原因：
　　1、字符串存在永久代中，容易出现性能问题和内存溢出。
　　2、类及方法的信息等比较难确定其大小，因此对于永久代的大小指定比较困难，太小容易出现永久代溢出，太大则容易导致老年代溢出。
　　3、永久代会为 GC 带来不必要的复杂度，并且回收效率偏低。
　　4、Oracle 可能会将HotSpot 与 JRockit 合二为一。









## GC
### Minor GC
从年轻代空间（包括 Eden 和 Survivor 区域）回收内存被称为 Minor GC。这一定义既清晰又易于理解。但是，当发生Minor GC事件的时候，有一些有趣的地方需要注意到：
当 JVM 无法为一个新的对象分配空间时会触发 Minor GC，比如当 Eden 区满了。所以分配率越高，越频繁执行 Minor GC。

内存池被填满的时候，其中的内容全部会被复制，指针会从0开始跟踪空闲内存。Eden 和 Survivor 区进行了标记和复制操作，取代了经典的标记、扫描、压缩、清理操作。所以 Eden 和 Survivor 区不存在内存碎片。写指针总是停留在所使用内存池的顶部。
执行 Minor GC 操作时，不会影响到永久代。从永久代到年轻代的引用被当成 GC roots，从年轻代到永久代的引用在标记阶段被直接忽略掉。

质疑常规的认知，所有的 Minor GC 都会触发“全世界的暂停（stop-the-world）”，停止应用程序的线程。对于大部分应用程序，停顿导致的延迟都是可以忽略不计的。其中的真相就 是，大部分 Eden 区中的对象都能被认为是垃圾，永远也不会被复制到 Survivor 区或者老年代空间。如果正好相反，Eden 区大部分新生对象不符合 GC 条件，Minor GC 执行时暂停的时间将会长很多。
所以 Minor GC 的情况就相当清楚了——每次 Minor GC 会清理年轻代的内存。

### Major GC vs Full GC
大家应该注意到，目前，这些术语无论是在 JVM 规范还是在垃圾收集研究论文中都没有正式的定义。
但是我们一看就知道这些在我们已经知道的基础之上做出的定义是正确的，Minor GC 清理年轻带内存应该被设计得简单：
Major GC 是清理老年代。
Full GC 是清理整个堆空间—包括年轻代和老年代。

所有通过new创建的对象的内存都在堆中分配，其大小可以通过-Xmx和-Xms来控制。
堆被划分为新生代和旧生代，新生代又被进一步划分为Eden和Survivor区，
最后Survivor由From Space和To Space组成，


## 调优

JVM调优总结 -Xms -Xmx -Xmn -Xss


### 堆大小设置
JVM 中最大堆大小有三方面限制：相关操作系统的数据模型（32-bt还是64-bit）限制；系统的可用虚拟内存限制；系统的可用物理内存限制。32位系统 下，一般限制在1.5G~2G；64为操作系统对内存无限制。我在Windows Server 2003 系统，3.5G物理内存，JDK5.0下测试，最大可设置为1478m。
```
典型设置：
java -Xmx3550m -Xms3550m -Xmn2g -Xss128k
-Xmx3550m：设置JVM最大可用内存为3550M。

-Xms3550m：设置JVM促使内存为3550m。此值可以设置与-Xmx相同，以避免每次垃圾回收完成后JVM重新分配内存。

-Xmn2g：设置年轻代大小为2G。整个JVM内存大小=年轻代大小 + 年老代大小 + 持久代大小。持久代一般固定大小为64m，所以增大年轻代后，将会减小年老代大小。此值对系统性能影响较大，Sun官方推荐配置为整个堆的3/8。

-Xss128k： 设置每个线程的堆栈大小。JDK5.0以后每个线程堆栈大小为1M，以前每个线程堆栈大小为256K。更具应用的线程所需内存大小进行调整。在相同物理内 存下，减小这个值能生成更多的线程。但是操作系统对一个进程内的线程数还是有限制的，不能无限生成，经验值在3000~5000左右。

java -Xmx3550m -Xms3550m -Xss128k -XX:NewRatio=4 -XX:SurvivorRatio=4 -XX:MaxPermSize=16m -XX:MaxTenuringThreshold=0

-XX:NewRatio=4:设置年轻代（包括Eden和两个Survivor区）与年老代的比值（除去持久代）。设置为4，则年轻代与年老代所占比值为1：4，年轻代占整个堆栈的1/5

-XX:SurvivorRatio=4：设置年轻代中Eden区与Survivor区的大小比值。设置为4，则两个Survivor区与一个Eden区的比值为2:4，一个Survivor区占整个年轻代的1/6

-XX:MaxPermSize=16m:设置持久代大小为16m。

-XX:MaxTenuringThreshold=0：设置垃圾最大年龄。如果设置为0的话，则年轻代对象不经过Survivor区，直接进入年老代。对于年老代比较多的应用，可以提高效率。如果将此值设置为一个较大值，则年轻代对象会在Survivor区进行多次复制，这样可以增加对象再年轻代的存活时间，增加在年轻代即被回收的概论。
### 回收器选择
JVM给了三种选择：串行收集器、并行收集器、并发收集器，但是串行收集器只适用于小数据量的情况，所以这里的选择主要针对并行收集器和并发收集器。默认情况下，JDK5.0以前都是使用串行收集器，如果想使用其他收集器需要在启动时加入相应参数。JDK5.0以后，JVM会根据当前系统配置进行判断。

吞吐量优先的并行收集器
如上文所述，并行收集器主要以到达一定的吞吐量为目标，适用于科学技术和后台处理等。
典型配置：
   java -Xmx3800m -Xms3800m -Xmn2g -Xss128k -XX:+UseParallelGC -XX:ParallelGCThreads=20

   -XX:+UseParallelGC：选择垃圾收集器为并行收集器。此配置仅对年轻代有效。即上述配置下，年轻代使用并发收集，而年老代仍旧使用串行收集。

   -XX:ParallelGCThreads=20：配置并行收集器的线程数，即：同时多少个线程一起进行垃圾回收。此值最好配置与处理器数目相等。
   java -Xmx3550m -Xms3550m -Xmn2g -Xss128k -XX:+UseParallelGC -XX:ParallelGCThreads=20 -XX:+UseParallelOldGC

   -XX:+UseParallelOldGC：配置年老代垃圾收集方式为并行收集。JDK6.0支持对年老代并行收集。
   java -Xmx3550m -Xms3550m -Xmn2g -Xss128k -XX:+UseParallelGC  -XX:MaxGCPauseMillis=100

   -XX:MaxGCPauseMillis=100:设置每次年轻代垃圾回收的最长时间，如果无法满足此时间，JVM会自动调整年轻代大小，以满足此值。
   java -Xmx3550m -Xms3550m -Xmn2g -Xss128k -XX:+UseParallelGC  -XX:MaxGCPauseMillis=100 -XX:+UseAdaptiveSizePolicy

   -XX:+UseAdaptiveSizePolicy：设置此选项后，并行收集器会自动选择年轻代区大小和相应的Survivor区比例，以达到目标系统规定的最低相应时间或者收集频率等，此值建议使用并行收集器时，一直打开。

响应时间优先的并发收集器
如上文所述，并发收集器主要是保证系统的响应时间，减少垃圾收集时的停顿时间。适用于应用服务器、电信领域等。
典型配置：
   java -Xmx3550m -Xms3550m -Xmn2g -Xss128k -XX:ParallelGCThreads=20 -XX:+UseConcMarkSweepGC -XX:+UseParNewGC

   -XX:+UseConcMarkSweepGC：设置年老代为并发收集。测试中配置这个以后，-XX:NewRatio=4的配置失效了，原因不明。所以，此时年轻代大小最好用-Xmn设置。

   -XX:+UseParNewGC:设置年轻代为并行收集。可与CMS收集同时使用。JDK5.0以上，JVM会根据系统配置自行设置，所以无需再设置此值。
   java -Xmx3550m -Xms3550m -Xmn2g -Xss128k -XX:+UseConcMarkSweepGC -XX:CMSFullGCsBeforeCompaction=5 -XX:+UseCMSCompactAtFullCollection

   -XX:CMSFullGCsBeforeCompaction：由于并发收集器不对内存空间进行压缩、整理，所以运行一段时间以后会产生“碎片”，使得运行效率降低。此值设置运行多少次GC以后对内存空间进行压缩、整理。
   -XX:+UseCMSCompactAtFullCollection：打开对年老代的压缩。可能会影响性能，但是可以消除碎片
```

**辅助信息**
 JVM提供了大量命令行参数，打印信息，供调试使用。主要有以下一些：
 ```
       -XX:+PrintGC
       输出形式：[GC 118250K->113543K(130112K), 0.0094143 secs]

                       [Full GC 121376K->10414K(130112K), 0.0650971 secs]

       -XX:+PrintGCDetails
       输出形式：[GC [DefNew: 8614K->781K(9088K), 0.0123035 secs] 118250K->113543K(130112K), 0.0124633 secs]

                       [GC [DefNew: 8614K->8614K(9088K), 0.0000665 secs][Tenured: 112761K->10414K(121024K), 0.0433488 secs] 121376K->10414K(130112K), 0.0436268 secs]

       -XX:+PrintGCTimeStamps -XX:+PrintGC：PrintGCTimeStamps可与上面两个混合使用
       输出形式：11.851: [GC 98328K->93620K(130112K), 0.0082960 secs]

       -XX:+PrintGCApplicationConcurrentTime:打印每次垃圾回收前，程序未中断的执行时间。可与上面混合使用
       输出形式：Application time: 0.5291524 seconds

       -XX:+PrintGCApplicationStoppedTime：打印垃圾回收期间程序暂停的时间。可与上面混合使用
       输出形式：Total time for which application threads were stopped: 0.0468229 seconds

       -XX:PrintHeapAtGC:打印GC前后的详细堆栈信息
       输出形式：
       34.702: [GC {Heap before gc invocations=7:
        def new generation   total 55296K, used 52568K [0x1ebd0000, 0x227d0000, 0x227d0000)
       eden space 49152K,  99% used [0x1ebd0000, 0x21bce430, 0x21bd0000)
       from space 6144K,  55% used [0x221d0000, 0x22527e10, 0x227d0000)
         to   space 6144K,   0% used [0x21bd0000, 0x21bd0000, 0x221d0000)
        tenured generation   total 69632K, used 2696K [0x227d0000, 0x26bd0000, 0x26bd0000)
       the space 69632K,   3% used [0x227d0000, 0x22a720f8, 0x22a72200, 0x26bd0000)
        compacting perm gen  total 8192K, used 2898K [0x26bd0000, 0x273d0000, 0x2abd0000)
          the space 8192K,  35% used [0x26bd0000, 0x26ea4ba8, 0x26ea4c00, 0x273d0000)
           ro space 8192K,  66% used [0x2abd0000, 0x2b12bcc0, 0x2b12be00, 0x2b3d0000)
           rw space 12288K,  46% used [0x2b3d0000, 0x2b972060, 0x2b972200, 0x2bfd0000)
       34.735: [DefNew: 52568K->3433K(55296K), 0.0072126 secs] 55264K->6615K(124928K)Heap after gc invocations=8:
        def new generation   total 55296K, used 3433K [0x1ebd0000, 0x227d0000, 0x227d0000)
       eden space 49152K,   0% used [0x1ebd0000, 0x1ebd0000, 0x21bd0000)
         from space 6144K,  55% used [0x21bd0000, 0x21f2a5e8, 0x221d0000)
         to   space 6144K,   0% used [0x221d0000, 0x221d0000, 0x227d0000)
        tenured generation   total 69632K, used 3182K [0x227d0000, 0x26bd0000, 0x26bd0000)
       the space 69632K,   4% used [0x227d0000, 0x22aeb958, 0x22aeba00, 0x26bd0000)
        compacting perm gen  total 8192K, used 2898K [0x26bd0000, 0x273d0000, 0x2abd0000)
          the space 8192K,  35% used [0x26bd0000, 0x26ea4ba8, 0x26ea4c00, 0x273d0000)
           ro space 8192K,  66% used [0x2abd0000, 0x2b12bcc0, 0x2b12be00, 0x2b3d0000)
           rw space 12288K,  46% used [0x2b3d0000, 0x2b972060, 0x2b972200, 0x2bfd0000)
       }
       , 0.0757599 secs]

-Xloggc:filename:与上面几个配合使用，把相关日志信息记录到文件以便分析。
常见配置汇总
堆设置
 -Xms:初始堆大小
 -Xmx:最大堆大小
 -XX:NewSize=n:设置年轻代大小
 -XX:NewRatio=n:设置年轻代和年老代的比值。如:为3，表示年轻代与年老代比值为1：3，年轻代占整个年轻代年老代和的1/4
 -XX:SurvivorRatio=n:年轻代中Eden区与两个Survivor区的比值。注意Survivor区有两个。如：3，表示Eden：Survivor=3：2，一个Survivor区占整个年轻代的1/5
 -XX:MaxPermSize=n:设置持久代大小
收集器设置
 -XX:+UseSerialGC:设置串行收集器
 -XX:+UseParallelGC:设置并行收集器
 -XX:+UseParalledlOldGC:设置并行年老代收集器
 -XX:+UseConcMarkSweepGC:设置并发收集器
垃圾回收统计信息
 -XX:+PrintGC
 -XX:+PrintGCDetails
 -XX:+PrintGCTimeStamps
 -Xloggc:filename
并行收集器设置
 -XX:ParallelGCThreads=n:设置并行收集器收集时使用的CPU数。并行收集线程数。
 -XX:MaxGCPauseMillis=n:设置并行收集最大暂停时间
 -XX:GCTimeRatio=n:设置垃圾回收时间占程序运行时间的百分比。公式为1/(1+n)
并发收集器设置
 -XX:+CMSIncrementalMode:设置为增量模式。适用于单CPU情况。
 -XX:ParallelGCThreads=n:设置并发收集器年轻代收集方式为并行收集时，使用的CPU数。并行收集线程数。
```

### 调优总结

**年轻代大小选择**
响应时间优先的应用：尽可能设大，直到接近系统的最低响应时间限制（根据实际情况选择）。在此种情况下，年轻代收集发生的频率也是最小的。同时，减少到达年老代的对象。
吞吐量优先的应用：尽可能的设置大，可能到达Gbit的程度。因为对响应时间没有要求，垃圾收集可以并行进行，一般适合8CPU以上的应用。

**年老代大小选择**
响应时间优先的应用：年老代使用并发收集器，所以其大小需要小心设置，一般要考虑并发会话率和会话持续时间等一些参数。如果堆设置小了，可以会造成内存碎片、高回收频率以及应用暂停而使用传统的标记清除方式；如果堆大了，则需要较长的收集时间。最优化的方案，一般需要参考以下数据获得：
   并发垃圾收集信息
   持久代并发收集次数
   传统GC信息
   花在年轻代和年老代回收上的时间比例
减少年轻代和年老代花费的时间，一般会提高应用的效率
吞吐量优先的应用：一般吞吐量优先的应用都有一个很大的年轻代和一个较小的年老代。原因是，这样可以尽可能回收掉大部分短期对象，减少中期的对象，而年老代尽存放长期存活对象。

**较小堆引起的碎片问题**
因为年老代的并发收集器使用标记、清除算法，所以不会对堆进行压缩。当收集器回 收时，他会把相邻的空间进行合并，这样可以分配给较大的对象。但是，当堆空间较小时，运行一段时间以后，就会出现“碎片”，如果并发收集器找不到足够的空 间，那么并发收集器将会停止，然后使用传统的标记、清除方式进行回收。如果出现“碎片”，可能需要进行如下配置：
-XX:+UseCMSCompactAtFullCollection：使用并发收集器时，开启对年老代的压缩。
-XX:CMSFullGCsBeforeCompaction=0：上面配置开启的情况下，这里设置多少次Full GC后，对年老代进行压缩




### 非堆内存

```
如果-Xmx不指定或者指定偏小，应用可能会导致java.lang.OutOfMemory错误，此错误来自JVM不是Throwable的，无法用try…catch捕捉。
PermSize和MaxPermSize指明虚拟机为java永久生成对象（Permanate generation）如，class对象、方法对象这些可反射（reflective）对象分配内存限制，这些内存不包括在Heap（堆内存）区之中。
-XX:MaxPermSize分配过小会导致：java.lang.OutOfMemoryError: PermGen space。
MaxPermSize缺省值和-server -client选项相关：-server选项下默认MaxPermSize为64m、-client选项下默认MaxPermSize为32m。

```


#### 申请一块内存的过程
* JVM会试图为相关Java对象在Eden中初始化一块内存区域
* 当Eden空间足够时，内存申请结束。否则到下一步
* JVM试图释放在Eden中所有不活跃的对象（这属于1或更高级的垃圾回收）；释放后若Eden空间仍然不足以放入新对象，则试图将部分Eden中活跃对象放入Survivor区/OLD区
* Survivor区被用来作为Eden及OLD的中间交换区域，当OLD区空间足够时，Survivor区的对象会被移到Old区，否则会被保留在Survivor区
* 当OLD区空间不够时，JVM会在OLD区进行完全的垃圾收集（0级）
* 完全垃圾收集后，若Survivor及OLD区仍然无法存放从Eden复制过来的部分对象，导致JVM无法在Eden区为新对象创建内存区域，则出现”out of memory错误”




# 《深入理解java虚拟机》

## chapter2 java内存区域与内存溢出异常

### JIT编译器

    JIT 是 just in time 的缩写, 也就是即时编译编译器。使用即时编译器技术，能够加速 Java 程序的执行速度。下面，就对该编译器技术做个简单的讲解。
    首先，我们大家都知道，通常通过 javac 将程序源代码编译，转换成 java 字节码，JVM 通过解释字节码将其翻译成对应的机器指令，逐条读入，逐条解释翻译。
    很显然，经过解释执行，其执行速度必然会比可执行的二进制字节码程序慢很多。为了提高执行速度，引入了 JIT 技术。
    在运行时 JIT 会把翻译过的机器码保存起来，以备下次使用，因此从理论上来说，采用该 JIT 技术可以接近以前纯编译技术。下面我们看看，JIT 的工作过程。
    JIT 编译过程
    当 JIT 编译启用时（默认是启用的），JVM 读入.class 文件解释后，将其发给 JIT 编译器。JIT 编译器将字节码编译成本机机器代码，下图展示了该过程。
    当 JVM 执行代码时，它并不立即开始编译代码。这主要有两个原因：
    首先，如果这段代码本身在将来只会被执行一次，那么从本质上看，编译就是在浪费精力。因为将代码翻译成 java 字节码相对于编译这段代码并执行代码来说，要快很多。
    当然，如果一段代码频繁的调用方法，或是一个循环，也就是这段代码被多次执行，那么编译就非常值得了。因此，编译器具有的这种权衡能力会首先执行解释后的代码，
    然后再去分辨哪些方法会被频繁调用来保证其本身的编译。其实说简单点，就是 JIT 在起作用，我们知道，对于 Java 代码，刚开始都是被编译器编译成字节码文件，
    然后字节码文件会被交由 JVM 解释执行，所以可以说 Java 本身是一种半编译半解释执行的语言。Hot Spot VM 采用了 JIT compile 技术，将运行频率很高的字节码直接编译为机器指令执行以提高性能，所以当字节码被 JIT 编译为机器码的时候，要说它是编译执行的也可以。也就是说，运行时，部分代码可能由 JIT 翻译为目标机器指令（以 method 为翻译单位，还会保存起来，第二次执行就不用翻译了）直接执行。
    第二个原因是最优化，当 JVM 执行某一方法或遍历循环的次数越多，就会更加了解代码结构，那么 JVM 在编译代码的时候就做出相应的优化。
    我们将在后面讲解这些优化策略，这里，先举一个简单的例子：我们知道 equals() 这个方法存在于每一个 Java Object 中（因为是从 Object class 继承而来）
    而且经常被覆写。当解释器遇到 b = obj1.equals(obj2) 这样一句代码，它则会查询 obj1 的类型从而得知到底运行哪一个 equals() 方法。
    而这个动态查询的过程从某种程度上说是很耗时的。

#### 内存泄露
    Java中的内存泄露，广义并通俗的说，就是：不再会被使用的对象的内存不能被回收，就是内存泄露。Java中的内存泄露与C++中的表现有所不同。
    在C++中，所有被分配了内存的对象，不再使用后，都必须程序员手动的释放他们。所以，每个类，都会含有一个析构函数，作用就是完成清理工作，如果我们忘记了某些对象的释放，就会造成内存泄露。
    但是在Java中，我们不用（也没办法）自己释放内存，无用的对象由GC自动清理，这也极大的简化了我们的编程工作。但，实际有时候一些不再会被使用的对象，在GC看来不能被释放，就会造成内存泄露。
    我们知道，对象都是有生命周期的，有的长，有的短，如果长生命周期的对象持有短生命周期的引用，就很可能会出现内存泄露。


#### Client模式与Server模式
    JVM有两种运行模式Server与Client。两种模式的区别在于，Client模式启动速度较快，Server模式启动较慢；但是启动进入稳定期长期运行
    之后Server模式的程序运行速度比Client要快很多。这是因为Server模式启动的JVM采用的是重量级的虚拟机，对程序采用了更多的优化；
    而Client模式启动的JVM采用的是轻量级的虚拟机。所以Server启动慢，但稳定后速度比Client远远要快。
    



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


===================  第五节  运行时数据区
-Xss 默认值1m  最小108K

java垃圾回收策略：主要是靠记忆，多看多记

本地方法栈：存放本地方法的位置 C或C++写的，本地方法库，为了支撑native方法的调用和执行
虚拟机栈：分配基本类型和自定义对象的引用，局部变量表等

String str1 = "hello";
String str2 = new String("hello");
System.out.println(str1 == str2);
System.out.println(str1.equals(str2));
答案：false 和 true 因为str1 和str2的地址是不相等的，str1直接指向常量区的字符串，而str2是指向堆区的对象地址，所以false

栈：里面的栈帧是按照先进后出的原则
运行时数据区：方法区、堆、虚拟机栈、本地方法栈、程序计数器

=========================  垃圾回收策略
需要回收的区域： 堆和方法区，因为栈是线程私有的，不需要回收
jvm为每个新创建的线程都分配一个堆栈。堆栈以帧为单位保存线程的状态。jvm对堆栈只进行两种操作：以帧为单位的压栈和出栈操作。

栈帧(Stack Frame)是用于支持虚拟机进行方法调用和方法执行的数据结构，它是虚拟机运行时数据区的虚拟机栈(Virtual Machine Stack)的栈元素。
栈帧存储了方法的局部变量表，操作数栈，动态连接和方法返回地址等信息。
第一个方法从调用开始到执行完成，就对应着一个栈帧在虚拟机栈中从入栈到出栈的过程。
什么情况下回收？
对象不再引用的时候
强引用：person = new object()
局部变量，当用完了之后，要复制为null

-XX:+PrintGC 参看GC回收情况
-XX:+PrintGCDetails 参看GC回收详情
参数输入格式：
[名称：GC前内存占用->GC后内存占用(该区域内存总大小)，GC占用时间]
-XX:+UseSerialGC

标记——清除算法：效率不高，产生大量不连续的空间碎片
复制算法：内存分两块，但是利用率低
标记整理算法：标记清除的基础上再整理
JVM 用可达性分析，分析的时候进行标记
商业算法：分代，根据对象存活周期
示意图见PPT
没听明白分代收集，eden from to old

新生代收集：minorGC ==> 小内存
           majorGC
           fullGC ==> 要尽量少出现

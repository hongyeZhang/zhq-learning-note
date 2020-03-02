## jmap

jdk安装后会自带一些小工具，jmap命令(Java Memory Map)是其中之一。主要用于打印指定Java进程(或核心文件、远程调试服务器)的共享对象内存映射或堆内存细节。

jmap命令可以获得运行中的jvm的堆的快照，从而可以离线分析堆，以检查内存泄漏，检查一些严重影响性能的大对象的创建，检查系统中什么对象最多，各种对象所占内存的大小等等。可以使用jmap生成Heap Dump。

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


## JVM调优相关
内存分析工具MAT(Memory Analyzer Tool)

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

#### JVM指令


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
used:加载类的空间量；capacity:当前分配块的元数据的空间；committed:空间块的数量；reserved:元数据的空间保留（但不一定提交的量）



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


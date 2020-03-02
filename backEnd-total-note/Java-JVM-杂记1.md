
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

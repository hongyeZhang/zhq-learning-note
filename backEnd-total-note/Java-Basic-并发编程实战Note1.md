## chapter2  线程安全性
```
一个对象，如果没有状态，只有方法，则是线程安全的。
竞态条件：先检查后执行 场景下容易发生
（1）延迟初始化
单例模式的例子
（2）读取——修改——写入
count++

获得对象内置锁的唯一途径是进入由这个锁保护的同步代码块或方法
内置锁是可重入的

在没有同步的情况下，编译器、处理器可能对操作的执行顺序进行重排序，得到一些意想不到的调整。
对于double和long数据，其读写操作不是原子的，如果没有volatile修饰，也是不安全的

加锁的含义不仅仅局限于互斥行为，还包括了内存可见性
volatile变量的典型用法 ： 检查某个标记的状态，判断是否退出循环，但是不能确保++操作的原子性，
总之，仅仅保证可见性，不能保证原子性。
而加锁机制既可以保证可见性，又可以保证原子性。
volatile boolean asleep;
while(!asleep)
  countSomeSheep();

发布对象：
（1）将该对象的引用保存在一个公有的静态变量中。

除非某个域是可变的，否则声明为final是个好习惯
```
## chapter4  对象的组合
CopyOnWrite容器即写时复制的容器。通俗的理解是当我们往一个容器添加元素的时候，不直接往当前容器添加，
而是先将当前容器进行Copy，复制出一个新的容器，然后新的容器里添加元素，添加完元素之后，再将原容器
的引用指向新的容器。这样做的好处是我们可以对CopyOnWrite容器进行并发的读，而不需要加锁，因为当前
容器不会添加任何元素。所以CopyOnWrite容器也是一种读写分离的思想，读和写不同的容器。

CopyOnWrite并发容器用于读多写少的并发场景。比如白名单，黑名单，商品类目的访问和更新场景，假如
我们有一个搜索网站，用户在这个网站的搜索框中，输入关键字搜索内容，但是某些关键字不允许被搜索。
这些不能被搜索的关键字会被放在一个黑名单当中，黑名单每天晚上更新一次。当用户搜索时，会检查当前
关键字在不在黑名单当中，如果在，则提示不能搜索

　　CopyOnWrite容器有很多优点，但是同时也存在两个问题，即内存占用问题和数据一致性问题。所以在开发的时候需要注意一下。
　　内存占用问题。因为CopyOnWrite的写时复制机制，所以在进行写操作的时候，内存里会同时驻扎两个对象的内存，旧的对象和新写入的对象（注意:在复制的时候只是复制容器里的引用，只是在写的时候会创建新对象添加到新容器里，而旧容器的对象还在使用，所以有两份对象内存）。如果这些对象占用的内存比较大，比如说200M左右，那么再写入100M数据进去，内存就会占用300M，那么这个时候很有可能造成频繁的Yong GC和Full GC。之前我们系统中使用了一个服务由于每晚使用CopyOnWrite机制更新大对象，造成了每晚15秒的Full GC，应用响应时间也随之变长。
　　针对内存占用问题，可以通过压缩容器中的元素的方法来减少大对象的内存消耗，比如，如果元素全是10进制的数字，可以考虑把它压缩成36进制或64进制。或者不使用CopyOnWrite容器，而使用其他的并发容器，如ConcurrentHashMap。
　　数据一致性问题。CopyOnWrite容器只能保证数据的最终一致性，不能保证数据的实时一致性。所以如果你希望写入的的数据，马上能读到，请不要使用CopyOnWrite容器。



堵塞队列适应于  生产者——消费者模式
双端队列适用于  工作密取，适应于既是消费者，又是生产者的问题


===============   chapter1  多线程的创建与停止   ===================
每个线程都有独立运行栈和程序计数器，线程间切换开销小。
优势：提高CPU利用率、并发执行提高系统性能
（1）安全性：线程交替无须执行
JVM调优会对代码进行指令的重排序，实际执行顺序与看到的顺序不一致。
（2） 活跃性：死锁、饥饿、活锁
（3）性能问题
线程之间的调度、数据同步会导致系统整体性能下降，包括服务时间响应过长，吞吐量下降、资源过度消耗。
具体举例：JVM  JDBC  RPC  定时任务、应用服务器
线程创建：
（1）继承thread
创建thread子类，重写run方法，调用start方法
（2）实现runnable接口
实现runnable接口、重写run方法、构造thread、调用start方法。
（3）future callable
实现callable接口、重写call方法、构造future task、构造thread、调用start方法

其中后两种的demo

public class MyThread2 {
    public static void main(String[] args) {
        System.out.println(Thread.currentThread().getName());
        new Thread(new Runnable() {
            @Override
            public void run() {
                System.out.println(Thread.currentThread().getName());
            }
        }).start();
    }

public class MyThread3 {
    public static void main(String[] args) throws Exception {
        AtomicInteger counter = new AtomicInteger();
        FutureTask<Integer> task = new FutureTask(new Callable() {
            @Override
            public Object call() throws Exception {
                return counter.incrementAndGet();
            }
        });
        new Thread(task).start();
        System.out.println(task.get());
    }
}

callbale 可以带有返回值的方法  但是runnable是不可以的
task.get() 会在主线程中堵塞，直到获得响应结果
优缺点分析：
（1）继承thread，代码编写简单，但是由于java单继承模式，无法继承其他父类，扩展性差。
（2）runnable和callable接口的扩展性强，callable支持返回值
（3）runnable和callable可以实现多线程之间处理共享资源
线程的停止：
（1）thread.stop()方法：
非安全的停止方法，强制停止，目前已经被废弃
（2）interrupt方法
非即时的终止线程，只是设置了一个中断标志，线程在收到标志之后会在合适的时间点停止线程
（3）使用退出标志
使用voaltile标志，但是无法快速的终止一个堵塞的线程
综上所述，应该使用interrupt方法进行线程的停止，对于堵塞还是非堵塞的线程，都可以优雅的进行停止。


===============   chapter2  线程状态、优先级、守护线程   ===================
============== 线程状态
六种状态：新建NEW、运行RUNNABLE（就绪、运行中）、堵塞BLOCK、定时等待TIMED_WAITING、等待WAITING、停止TERMINATED
wait() sleep() lockSpport.park()进入等待状态之后，只能由其他线程唤起notify notifyall。
run() 或者interrupt异常终端信号 执行完毕之后，线程进入终止状态
书上有线程的状态跳转图。
synchronized 对象锁，将锁加载对象上
二者的区别需要注意：
wait() 方法调用时，释放锁。其他线程可以获得这个锁
sleep() 当前线程休眠，不会释放锁，其他线程也只能等待
============== 线程优先级
优先级1-10设定，1最低，优先级越高，获得CPU时间的可能性越高，每个java版本不同，与操作系统和虚拟机有关
由调度线程决定哪个线程被执行，默认普通优先级5，在调用start方法之前设置才会起作用
不能保证优先级高的线程肯定执行
============== 守护线程
线程分类：（1）普通（用户）线程 （2）守护线程
守护线程：在后台提供一种通用的公共服务，保证所有用户对该线程的请求都能有响应。
eg: JVM垃圾回收  设置方式： thread.setDaemon(true)
不管守护线程是否运行完毕，只要用户线程运行完毕，程序就会退出。

===============   chapter3  thread详解   ===================
============== 基本属性
name:可重复，没有指定会自动生成
id：线程ID  唯一值，创建线程时指定
priority：优先级，数值越高优先级越大
state：线程六种状态
threadgroup: 线程组，每个线程都属于一个数组，创建时唯一，若创建时没有指定线程数组，则默认属于当前线程数组，看源码可以解释
线程组是个树形的结构，根节点是system，system包含main
System -> main -> 我们未明确指定的线程
设置线程组好处：方便统一管理，线程组可以进行复制，统一进行异常处理，统一进行设置
threadgroup属于java.lang的内容，不是并发包的，与线程池区别开来
============== 构造方法
group：
target：运行其中的runnable，run()中定义并调用
推荐定义线程时给定名字
stacksize：线程的预期栈的大小，默认为0，jvm负责
最终调用init()方法

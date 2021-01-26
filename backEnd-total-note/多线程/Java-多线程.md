# Java多线程笔记

## Thread
### 6种线程状态
* 1 NEW	新创建	还未调用 start() 方法；
* 2 RUNNABLE	就绪的	调用了 start() ，此时线程已经准备好被执行，处于就绪队列；是活着的(alive)
    - 2 RUNNING	运行中	线程获得 CPU 资源，正在执行任务；活着的 (与上一种合并了)
* 3 BLOCKED	阻塞的	线程阻塞于锁或者调用了 sleep；
* 4 WAITING	等待中	线程由于某种原因等待其他线程；
* 5 TIME_WAITING	超时等待	与 WAITING 的区别是可以在特定时间后自动返回；活着的
* 6 TERMINATED	终止	执行完毕或者被其他线程杀死；不是活着的

### 三种创建线程的方法
* 1.2 实现Runnable接口(推荐)
* 1.3 实现Callable接口
* Java中，类仅支持单继承，如果一个类继承了Thread类，就无法再继承其它类，因此，如果一个类既要继承其它的类，又必须创建为一个线程，就可以使用实现Runable接口的方式。
* 使用实现Runable接口的方式创建的线程可以处理同一资源，实现资源的共享。
* 使用实现Callable接口的方式创建的线程，可以获取到线程执行的返回值、是否执行完成等信息。

### 主要方法
* sleep()
    * 静态方法 public static native void sleep(long millis) throws InterruptedException;
    * 使当前所在线程进入阻塞，
    * 让出 CPU，不释放对象锁，如果当前线程持有对某个对象的锁，即使调用sleep方法，其他线程也无法访问这个对象。
    * 由于休眠时间结束后不一定会立即被 CPU 调度，因此线程休眠的时间可能大于传入参数
    * 如果调用了sleep方法，必须捕获InterruptedException异常或者将该异常向上层抛出。如果被中断会抛出 InterruptedException
    * 由于 sleep 是静态方法，它的作用时使当前所在线程阻塞。因此最好在线程内部直接调用 Thread.sleep()，如果在主线程调用某个线程的 sleep() 方法，其实阻塞的是主线程
* yield()
    * 这个方法没啥作用，一般不用
    * public static native void yield() 是一个静态方法，不会释放锁，
    * 暂停当前线程，让出 CPU 给优先级与当前线程相同，或者优先级比当前线程更高的就绪状态的线程。使正在运行中的线程重新变成就绪状态，并重新竞争 CPU 的调度权。它可能会获取到，也有可能被其他线程获取到
    * 不会进入到阻塞状态，而是进入到就绪状态。
    * 让当前线程暂停一下，重新进入就绪的线程池中。
    * 不能控制具体的交出CPU的时间，只能让拥有相同优先级的线程有获取CPU执行时间的机会。
* stop()
    * 已废弃的方法，是一个不安全的方法，调用stop方法会直接终止run方法的调用
    * 会抛出一个ThreadDeath错误，如果线程持有某个对象锁的话，会完全释放锁，导致对象状态不一致
* join()
    * 线程合并，调用线程会进入阻塞状态，需要等待被调用线程结束后才可以执行。
    * “等待该线程终止”，该线程是指的主线程等待子线程的终止。在子线程调用了join()方法后面的代码，只有等到子线程结束了才能执行
* suspend()
    * 已废弃，容易造成死锁
    
### 线程取得控制权的方法
* 执行对象的某个同步实例方法。
* 执行对象对应类的同步静态方法。
* 执行对该对象加同步锁的同步块。`synchronized(this){ }` 等价于 `public synchronized void method(){}`
* 同步分为类级别和对象级别，分别对应着类锁和对象锁。类锁是每个类只有一个，如果static的方法被synchronized关键字修饰，则在这个方法被执行前必须获得类锁；对象锁类同。
* wait(),notify(),notifyAll()不属于Thread类,而是属于Object基础类,也就是说每个对像都有wait(),notify(),notifyAll()的功能。
* 守护线程和用户线程的区别在于：守护线程依赖于创建它的线程，而用户线程则不依赖。
  举个简单的例子：如果在main线程中创建了一个守护线程，当main方法运行完毕之后，守护线程也会随着消亡。
  而用户线程则不会，用户线程会一直运行直到其运行完毕。在JVM中，像垃圾收集器线程就是守护线程。
* 抢占式调度，由CPU分配给线程时间片，操作系统根据线程的优先级选择下一个进行调度的线程不要将程序构建功能的正确性依赖于优先级

### 线程优先级
* 线程优先级
    - 1~10 默认5，尽量优先，并不保证绝对优先，线程运行具有随机性
    - 继承性： 线程A启动线程B，则A和B具有同样的优先级
* 守护线程
    - 一般用于执行后台任务
    - JVM GC 线程
    - 所有用户进程结束时，程序终止，同时会杀死所有的守护线程。
    - setDaemon() 必须在线程运行之前设置 
* 用户线程
    - 执行用户级的任务
    
## Object 方法
* wait()
    * 线程进入阻塞状态，释放线程占有的锁，并交出CPU执行权限。
    * 接触堵塞的方法
        * 其他线程调用该线程的interrupt()方法，使处于阻塞状态的线程抛出一个异常，中断一个正处于阻塞状态的线程；
        * 其他线程调用 notify() notifyAll() 方法
    * 通过interrupt方法和isInterrupted()方法来停止正在运行的线程。
    * 如果配合isInterrupted()能够中断正在运行的线程，因为调用interrupt方法相当于将中断标志位置为true，那么可以通过调用isInterrupted()判断中断标志是否被置位来中断线程的执行。
       但是一般情况下不建议通过这种方式来中断线程，一般会在MyThread类中增加一个属性 isStop来标志是否结束while循环，然后再在while循环中判断isStop的值。
    * 等待对象的同步锁,需要获得该对象的同步锁才可以调用这个方法,否则编译可以通过，但运行时会收到一个异常：IllegalMonitorStateException。
* notify()
    * 唤醒在等待该对象同步锁的线程(只唤醒一个),注意并不能确切的唤醒某一个等待状态的线程，而是由JVM确定唤醒哪个线程，不是按优先级唤醒。
    * 调用任意对象的notify()方法则导致因调用该对象的 wait()方法而阻塞的线程中随机选择的一个解除阻塞（但要等到获得锁后才真正可执行）。
    * 只有获得锁之后，才能够调用notify()
* notifyAll():
    * 唤醒所有等待的线程,注意唤醒的是 notify之前 wait的线程,对于notify之后的wait线程是没有效果的。
    * 调用obj的wait(), notify()方法前，必须获得obj锁，也就是必须写在synchronized(obj){...} 代码段内。
* 挂起：一般是主动的，由系统或程序发出，甚至于辅存中去。（不释放CPU，可能释放内存，放在外存）
* 阻塞：一般是被动的，在抢占资源中得不到资源，被动的挂起在内存，等待某种资源或信号量（即有了资源）将他唤醒。（释放CPU，不释放内存）


## synchronized
### synchronized特性
* 1.原子性：确保线程互斥的访问同步代码;
* 2.可见性：保证共享变量的修改能够及时可见。通过Java内存模型中的 “对一个变量unlock操作之前，必须要同步到主内存中；如果对一个变量进行lock操作，
   会清空工作内存中此变量的值，需要重新从主内存中load操作；
* 3.有序性：有效解决重排序问题。
  即 “一个unlock操作先行发生(happen-before)于后面对同一个锁的lock操作”
  从语法上讲，Synchronized可以把任何一个非null对象作为"锁"，
  在HotSpot JVM实现中，锁有个专门的名字：对象监视器（Object Monitor）
* synchronized 内置锁 是一种 对象锁（锁的是对象而非引用变量），作用粒度是对象 ，可以实现对临界资源的同步互斥访问 ，是可重入的。
   可重入最大的作用是避免死锁，如：子类同步方法调用了父类同步方法，如没有可重入的特性，则会发生死锁。
* 会引起上下问切换，带来线程调度开销

### synchronized原理
* Synchronized的语义底层是通过一个monitor的对象来完成，
* wait/notify等方法也依赖于monitor对象，这就是为什么只有在同步的块或者方法中才能调用wait/notify等方法，否则会抛出java.lang.IllegalMonitorStateException的异常
* 同步代码块的实现： monitor enter  monitor exit
* 同步方法： ACC_SYNCHRONIZED 标示符。JVM就是根据该标示符来实现方法的同步。方法的同步是一种隐式的方式来实现，无需通过字节码来完成
* 锁住的是什么？随着锁级别的不同，对象头里会存储不同的内容。
    - 偏向锁存储的是当前占用此对象的线程ID；
    - 轻量级则存储指向线程栈中锁记录的指针。

### synchronized实现
* 监视器（Monitor）。任何一个对象都有一个Monitor与之关联，当且一个Monitor被持有后，它将处于锁定状态
* Synchronized在JVM里的实现都是基于进入和退出Monitor对象来实现方法同步和代码块同步，虽然具体实现细节不一样，但是都可以通过成对的MonitorEnter和MonitorExit指令来实现。
    * MonitorEnter指令：插入在同步代码块的开始位置，当代码执行到该指令时，将会尝试获取该对象Monitor的所有权，即尝试获得该对象的锁；
    * MonitorExit指令：插入在方法结束处和异常处，JVM保证每个MonitorEnter必须有对应的MonitorExit；
* 在Java虚拟机（HotSpot）中，Monitor是由ObjectMonitor实现的，（位于HotSpot虚拟机源码ObjectMonitor.hpp文件，C++实现的）：
* ObjectMonitor中有两个队列，_WaitSet 和 _EntryList，用来保存ObjectWaiter对象列表（ 每个等待锁的线程都会被封装成ObjectWaiter对象 ），
  _owner指向持有ObjectMonitor对象的线程，当多个线程同时访问一段同步代码时：首先会进入 _EntryList 集合，当线程获取到对象的monitor后，
  进入_Owner区域并把monitor中的owner变量设置为当前线程，同时monitor中的计数器count加1；若线程调用 wait() 方法，将释放当前持有的monitor，
  owner变量恢复为null，count自减1，同时该线程进入 WaitSet集合中等待被唤醒；若当前线程执行完毕，释放monitor（锁）并复位count的值，
  以便其他线程进入获取monitor(锁)；
* Monitor对象存在于每个Java对象的对象头Mark Word中（存储指针的指向），Synchronized锁便是通过这种方式获取锁的，这也是为什么Java中任意对象可以作为锁的原因，
  同时notify/notifyAll/wait等方法会使用到Monitor锁对象，所以必须在同步代码块中使用

### synchronized优化
* 从JDK5引入了现代操作系统新增加的CAS原子操作（JDK5中并没有对synchronized关键字做优化，而是体现在J.U.C中，所以在该版本concurrent包有更好的性能 ），
* 从JDK6开始，就对synchronized的实现机制进行了较大调整，包括使用JDK5引进的CAS自旋之外，还增加了：自适应的CAS自旋、锁消除、锁粗化、偏向锁、轻量级锁这些优化策略。
   由于此关键字的优化使得性能极大提高，同时语义清晰、操作简单、无需手动关闭，所以推荐在允许的情况下尽量使用此关键字，同时在性能上此关键字还有优化的空间。


### synchronized 四种状态 
无锁状态 -> 偏向锁状态 -> 轻量级锁 -> 重量级锁 （只能升级，不能降级）
* 偏向锁
    - 偏向锁是在单线程执行代码块时使用的机制，如果在多线程并发的环境下（即线程A尚未执行完同步代码块，线程B发起了申请锁的申请），则一定会转化为轻量级锁或者重量级锁。
    - 本质上偏向锁就是为了消除CAS，降低Cache一致性流量
    - 当一个线程访问同步块并获取锁时，会在对象头和栈帧中的锁记录里存储锁偏向的线程ID，以后该线程进入和退出同步块时不需要花费CAS操作来争夺锁资源，
      只需要检查是否为偏向锁、锁标识为以及ThreadID即可，
* 轻量级锁
    - 引入轻量级锁的主要目的是在没有多线程竞争的前提下，减少传统的重量级锁使用操作系统互斥量产生的性能消耗。当关闭偏向锁功能或者多个线程竞争偏向锁导致偏向锁升级为轻量级锁
    - 轻量级锁适应的场景是线程交替执行同步块的情况，如果存在同一时间大量线程访问同一锁的情况，必然就会导致轻量级锁膨胀为重量级锁
* 重量级锁
    - Synchronized是通过对象内部的一个叫做 监视器锁（Monitor）来实现的。但是监视器锁本质又是依赖于底层的操作系统的Mutex Lock来实现的。
      操作系统实现线程之间的切换这就需要从用户态转换到核心态，这个成本非常高，状态之间的转换需要相对比较长的时间，这就是为什么Synchronized效率低的原因。
      因此，这种依赖于操作系统Mutex Lock所实现的锁我们称之为 “重量级锁
* 其他
    - 如果是单线程使用，那偏向锁毫无疑问代价最小，并且它就能解决问题，连CAS都不用做，仅仅在内存中比较下对象头就可以了；
      如果出现了其他线程竞争，则偏向锁就会升级为轻量级锁；如果其他线程通过一定次数的CAS尝试没有成功，则进入重量级锁；
      在第3种情况下进入同步代码块就要做偏向锁建立、偏向锁撤销、轻量级锁建立、升级到重量级锁，最终还是得靠重量级锁来解决问题，那这样的代价就比直接用重量级锁要大不少了。
### synchronized 线程通信
* 管道输入流  输出流
* PipedWriter PipedReader

### 使用示例

```java
public class ThreadSafeCount {

    private Long value;

    // 虽然是读操作，此处的 synchronized 不能去掉，因为需要 synchronized 保证内存的可见性
    public synchronized Long getCount() {
        return value;
    }

    public synchronized void inc() {
        value++;
    }
}
```


## volatile
* volatile 是一种轻量级的同步机制。
* 硬件系统架构演进，CPU高速缓存诞生，该缓存为某个CPU独有，只与在CPU运行的线程有关
    - CPU三级缓存架构
        - L1 cache ： 
        - L2 cache ： 
        - L3 cache ： 与主内存打交道
    - CPU缓存机制的条件下，如何保证各个CPU之间的缓存数据一致性？
        - 直写 (write-through)
        - 回写 (write-back)
    - 解决缓存一致性的方案
        - 通过在总线加lock
        - 缓存一致性协议 ： 窥探技术  MESI协议（缓存行四种状态的首字母缩写）
    
* 保证共享变量的可见性，不能保证原子性，也不能保证线程安全，可以避免重排序和内存可见性问题
    * 写 volatile 变量时，可以确保 volatile 之前的变量不会被编译器重排序到 volatile 之后
    * 读 volatile 变量时，可以确保 volatile 读之后的操作不会被编译器重排序到 volatile 读之前
* 作用是确保所有线程在同一时刻读取到的共享变量的值是一致的
* 如果某个线程对 volatile 修饰的共享变量进行更新，那么其他线程可以立即看到这个更新

* as if serial
    - 编译器和处理器不会改变存在数据依赖关系的两个操作的执行顺序。如果没有数据依赖关系，则可能被重排序
    - 编译器和处理器不管怎样重排序，单线程程序的执行结果不能被改变。
* 指令重排序
    - 编译器优化重排序
    - 指令级并行重排序，将多条指令折叠执行
    - 内存系统重排序，使用缓存 读/写缓冲区

* volatile内存语义
    - 1 保证数据可见性，不保证原子性
        - 实现方式：通过内存屏障来实现
            - LoadLoad
            - LoadStore
            - StoreLoad
            - StoreStore
        - 如何保证原子性
            - 加锁：使用 synchronized 加锁
            - 使用 AtomicInteger
        - happen-before
            - 顺序规则
            - 监视器锁规则
            - volatile 变量规则 
    - 2 禁止指令重排序
        - 实现方式：通过内存屏障来实现

### 使用volatile的场景
* 写入的变量值不依赖变量的当前值的时候，如果是 获取-计算-写入的三步操作，则volatile不能够保证原子性


### 伪共享
多线程条件下访问同一个缓存行中的多个变量





## 锁
* 乐观锁和悲观锁（从数据库中引入的概念）
    * 悲观锁：假定数据每次都会被修改， select ... for update 对数据库的行进行加锁，保证每次只有一个线程对数据进行修改
    * 悲观锁：假定数据不会被修改，通过data 的版本号来实现校验。 version + 1, 如果不能成功，则根据业务逻辑决定一直重试还是重试有限的次数。
      类似于CAS的自旋操作，不会产生任何的死锁
* 公平锁和非公平锁
    * 公平锁：先到先得
    * 非公平锁：直接抢占，未必先到先得  ReentrantLock 可以指定公平还是非公平，默认非公平
* 独占锁和共享锁
    * 根据锁只能被单个线程持有还是能够对多个线程持有进行划分
    * 独占锁  ReentrantLock 是一种悲观锁
    * 共享锁  ReadWriteLock 是一种乐观锁
* 可重入锁
    * synchronized 锁的内部标识锁被哪个线程占用，通过维护一个计数器count记录加锁的次数
* 自旋锁
    * 因为一个线程由用户态切换为核心态的开销比较大，因此通过不放弃CPU使用权的情况下多次尝试获取锁，使用CPU的时间获取线程堵塞与调度的开销
      但是很可能CPU时间白白浪费没有成果








## CAS(compare and swap)
* 非堵塞的原子性操作，通过硬件保证操作的原子性 Unsafe 类
* 存在一个经典的ABA问题，AtomicStampedReference 通过时间戳可以避免ABA问题的发生
- 取值，询问，修改
- CAS在底层的硬件级别给你保证一定是原子的，同一时间只有一个线程可以执行CAS，先比较再设置，其他的线程的CAS同时间
  去执行此时会失败





## Semaphore信号量
Semaphore类是一个计数信号量，必须由获取它的线程释放，通常用于限制可以访问某些资源（物理或逻辑的）线程数目。
一个信号量有且仅有3种操作，且它们全部是原子的：初始化、增加和减少
增加可以为一个进程解除阻塞；
减少可以让一个进程进入阻塞。

```java
public class SemaphoreDemo {
    private Semaphore smp = new Semaphore(3,true); //公平策略
    private Random rnd = new Random();

    class Task implements Runnable{
        private String id;
        Task(String id){
            this.id = id;
        }

        public void run(){
            try {
                smp.acquire();
                //smp.acquire(int permits);//使用有参数方法可以使用permits个许可
                System.out.println("Thread " + id + " is working");
                //System.out.println("在等待的线程数目："+ smp.getQueueLength());
                work();
                System.out.println("Thread " + id + " is over");
            } catch (InterruptedException e) {
            }
            finally
            {
                smp.release();
            }
        }

        public void work() {
            //假装在工作，实际在睡觉
            int worktime = rnd.nextInt(1000);
            System.out.println("Thread " + id + " worktime  is "+ worktime);
            try {
                Thread.sleep(worktime);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }

    public static void main(String[] args){
        SemaphoreDemo semaphoreDemo = new SemaphoreDemo();
        ExecutorService se = Executors.newCachedThreadPool();
        se.submit(semaphoreDemo.new Task("a"));
        se.submit(semaphoreDemo.new Task("b"));
        se.submit(semaphoreDemo.new Task("c"));
        se.submit(semaphoreDemo.new Task("d"));
        se.submit(semaphoreDemo.new Task("e"));
        se.submit(semaphoreDemo.new Task("f"));
        se.shutdown();
    }
}
```




## 线程池
* submit 和 execute 分别有什么区别呢？
    - execute 没有返回值，如果不需要知道线程的结果就使用 execute 方法，性能会好很多。
    - submit 返回一个 Future 对象，如果想知道线程结果就使用 submit 提交，而且它能在主线程中通过 Future 的 get 方法捕获线程中的异常。

### 线程

在IDEA 中启动一个main函数时，实际JVM启动了6个线程，有两个活跃的线程输出为：
System.out.println(Thread.activeCount());
Thread.currentThread().getThreadGroup().list();
可以发现当前线程组包含：main和Monitor Ctrl-Break
```
其中启动的所有线程的名称输出为：
    // 获取java线程的管理MXBean
            ThreadMXBean tmxb = ManagementFactory.getThreadMXBean();
            // 不需要获取同步的Monitor和synchronizer信息，仅获取线程和线程堆栈信息
            ThreadInfo[] threadInfos = tmxb.dumpAllThreads(false, false);
            // 遍历线程信息，打印出ID和名称
            for (ThreadInfo info : threadInfos) {
                System.out.println("[" + info.getThreadId() + "] " + info.getThreadName());
            }

    [6] Monitor Ctrl-Break
    [5] Attach Listener
    [4] Signal Dispatcher
    [3] Finalizer
    [2] Reference Handler
    [1] main
```



**进程**每个进程都有独立的代码和数据空间（进程上下文），进程间的切换会有较大的开销，一个进程包含1--n个线程。
**线程**同一类线程共享代码和数据空间，每个线程有独立的运行栈和程序计数器(PC)，线程切换开销小。
线程和进程一样分为五个阶段：创建、就绪、运行、阻塞、终止。
多进程是指操作系统能同时运行多个任务（程序）。
多线程是指在同一程序中有多个顺序流在执行。


start()方法的调用后并不是立即执行多线程代码，而是使得该线程变为可运行态（Runnable），什么时候运行是由操作系统决定的。
从程序运行的结果可以发现，多线程程序是乱序执行。因此，只有乱序执行的代码才有必要设计为多线程。
Thread.sleep()方法调用目的是不让当前线程独自霸占该进程所获取的CPU资源，以留出一定时间给其他线程执行的机会。
实际上所有的多线程代码执行顺序都是不确定的，每次执行的结果都是随机的。

### thread 与 Runnable 的区别
实现Runnable接口比继承Thread类所具有的优势：
1）：适合多个相同的程序代码的线程去处理同一个资源
2）：可以避免java中的单继承的限制
3）：增加程序的健壮性，代码可以被多个线程共享，代码和数据独立

第一点：通过创建线程方式可以看出，一个是继承一个是实现接口，但是Java是只能继承一个父类，可以实现多个接口的一个特性，所以说采用Runnable方式可以避免Thread方式由于Java单继承带来的缺陷。
第二点：Runnable的代码可以被多个线程共享（Thread实例），适合于多个多个线程处理统一资源的情况。
举例说明：模拟卖票，假设还剩5张票，分别采用两种方式来创建线程模拟
TicketThread.java //采用继承方式模拟3个窗口卖5张票的情况

```
public class Main {

    public static void main(String[] args) {

        //测试Runnable
        MyThread1 t1 = new MyThread1();
        new Thread(t1).start();//同一个t1，如果在Thread中就不行，会报错
        new Thread(t1).start();
        new Thread(t1).start();

    }

}
class MyThread1 implements Runnable{
    private int ticket = 10;
    @Override
    //记得要资源公共，要在run方法之前加上synchronized关键字，要不然会出现抢资源的情况
    public synchronized  void  run() {
        for (int i = 0; i <10; i++) {
            if (this.ticket>0) {
                System.out.println("卖票：ticket"+this.ticket--);
            }
        }

    }

}
```

### ThreadPoolExecutor
总结一下，主要有以下四点：

    当有任务提交的时候，会创建核心线程去执行任务（即使有核心线程空闲仍会创建）；
    当核心线程数达到corePoolSize时，后续提交的都会进BlockingQueue中排队；
    当BlockingQueue满了(offer失败)，就会创建临时线程(临时线程空闲超过一定时间后，会被销毁)；
    当线程总数达到maximumPoolSize时，后续提交的任务都会被RejectedExecutionHandler拒绝。

    prestartAllCoreThreads方法可以直接创建所有核心线程并启动。

    BlockingQueue使用无限容量的阻塞队列(如LinkedBlockingQueue)时，不会创建临时线程(因为队列不会满)，所以线程数保持corePoolSize。

    BlockingQueue使用没有容量的同步队列(如SynchronousQueue)时，任务不会入队，而是直接创建临时线程去执行任务。


1. 计算密集型任务与IO密集型任务

大多数刚接触线程池的人会认为有一个准确的值作为线程数能让线程池适用在程序的各个地方。然而大多数情况下并没有放之四海而皆准的值，很多时候我们要根据任务类型来决定线程池大小以达到最佳性能。

计算密集型任务以CPU计算为主，这个过程中会涉及到一些内存数据的存取（速度明显快于IO），执行任务时CPU处于忙碌状态。

IO密集型任务以IO为主，比如读写磁盘文件、读写数据库、网络请求等阻塞操作，执行IO操作时，CPU处于等待状态，等待过程中操作系统会把CPU时间片分给其他线程。
2. 计算密集型任务

下面写一个计算密集型任务的例子：
```
public class ComputeThreadPoolTest {

    final static ThreadPoolExecutor computeExecutor;

    final static List<Callable<Long>> computeTasks;

    final static int task_count = 5000;

    static {
        computeExecutor = (ThreadPoolExecutor) Executors.newFixedThreadPool(1);

        // 创建5000个计算任务
        computeTasks = new ArrayList<>(task_count);
        for (int i = 0; i < task_count; i++) {
            computeTasks.add(new ComputeTask());
        }
    }

    static class ComputeTask implements Callable<Long> {
        // 计算一至五十万数的总和(纯计算任务)
        @Override
        public Long call() {
            long sum = 0;
            for (long i = 0; i < 50_0000; i++) {
                sum += i;
            }
            return sum;
        }
    }

    public static void main(String[] args) throws InterruptedException {
        // 我电脑是四核处理器
        int processorsCount = Runtime.getRuntime().availableProcessors();
        // 逐一增加线程池的线程数
        for (int i = 1; i <=  processorsCount * 5; i++) {
            computeExecutor.setCorePoolSize(i);
            computeExecutor.setMaximumPoolSize(i);
            computeExecutor.prestartAllCoreThreads();
            System.out.print(i);
            computeExecutor.invokeAll(computeTasks); // warm up all thread
            System.out.print("\t");
            testExecutor(computeExecutor, computeTasks);
            System.out.println();
            // 一定要让cpu休息会儿，Windows桌面操作系统不会让应用长时间霸占CPU
            // 否则Windows回收应用程序的CPU核心数将会导致测试结果不准确
            TimeUnit.SECONDS.sleep(5);// cpu rest
        }
        computeExecutor.shutdown();
    }

    private static <T> void testExecutor(ExecutorService executor, List<Callable<T>> tasks)
        throws InterruptedException {
        for (int i = 0; i < 8; i++) {
            long start = System.currentTimeMillis();
            executor.invokeAll(tasks); // ignore result
            long end = System.currentTimeMillis();
            System.out.print(end - start); // 记录时间间隔
            System.out.print("\t");
            TimeUnit.SECONDS.sleep(1); // cpu rest
        }
    }
}
```
将程序生成的数据粘贴到excel中，并对数据进行均值统计

    注意如果相同的线程数两次执行的时间相差比较大，说明测试的结果不准确。

测试生成数据

    测试程序生成的数据可以从这下载

对数据生成折线图

线程池线程数与计算密集型任务执行时间关系图

由于我笔记本的CPU有四个处理器，所以会发现当线程数达到4之后，5000个任务的执行时间并没有变得更少，基本上是在600毫秒左右徘徊。

因为计算机只有四个处理器可以使用，当创建更多线程的时候，这些线程是得不到CPU的执行的。

所以对于计算密集型任务，应该将线程数设置为CPU的处理个数，可以使用Runtime.availableProcessors方法获取可用处理器的个数。

    《并发编程实战》一书中对于IO密集型任务建议线程池大小设为Ncpu+1

    Ncpu​+1，原因是当计算密集型线程偶尔由于页缺失故障或其他原因而暂停时，这个“额外的”线程也能确保这段时间内的CPU始终周期不会被浪费。

对于计算密集型任务，不要创建过多的线程，由于线程有执行栈等内存消耗，创建过多的线程不会加快计算速度，反而会消耗更多的内存空间；另一方面线程过多，频繁切换线程上下文也会影响线程池的性能。
3. 每个程序员都应该知道的延迟数

IO操作包括读写磁盘文件、读写数据库、网络请求等阻塞操作，执行这些操作，线程将处于等待状态。

为了能更准确的模拟IO操作的阻塞，我觉得有必要将https://people.eecs.berkeley.edu/~rcs/research/interactive_latency.html中列举的延迟数整理出来。
事件 	纳秒 	微秒 	毫秒 	对照
一级缓存 	0.5 	- 	- 	-
二级缓存 	7 	- 	- 	一级缓存时间14倍
互斥锁定/解锁 	25.0 	- 	- 	-
主存参考 	100.0 	- 	- 	二级缓存20倍，一级缓存200倍
使用Zippy压缩1K字节 	3,000.0 	3 	- 	-
通过1Gbps网络发送1K字节 	10,000.0 	10 	- 	-
从SSD中随机读取4K 	150,000.0 	150 	- 	1GB/秒的读取速度的SSD硬盘
从内存中顺序读取1MB 	250,000.0 	250 	- 	-
在同一数据中心局域网内往返 	500,000.0 	500 	- 	-
从SSD顺序读取1MB 	1,000,000.0 	1000 	1 	1GB/秒SSD，4X 内存
磁盘搜寻 	10,000,000.0 	10000 	10 	20X 数据中心往返
从磁盘顺序读取1MB 	20,000,000.0 	20000 	20 	80X 内存，20X SSD
发送一个数据包
美国加州→荷兰→加州 	150,000,000.0 	150000 	150 	-
4. IO密集型任务

这里用sleep方式模拟IO阻塞：
```
public class IOThreadPoolTest {

    // 使用无限线程数的CacheThreadPool线程池
    static ThreadPoolExecutor cachedThreadPool = (ThreadPoolExecutor) Executors.newCachedThreadPool();

    static List<Callable<Object>> tasks;

    // 仍然是5000个任务
    static int taskNum = 5000;

    static {
        tasks = new ArrayList<>(taskNum);
        for (int i = 0; i < taskNum; i++) {
            tasks.add(Executors.callable(new IOTask()));
        }
    }

    static class IOTask implements Runnable {

        @Override
        public void run() {
            try {
                TimeUnit.SECONDS.sleep(1);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }

    public static void main(String[] args) throws InterruptedException {
        cachedThreadPool.invokeAll(tasks);// warm up all thread
        testExecutor(cachedThreadPool, tasks);
        // 看看执行过程中创建了多少个线程
        int largestPoolSize = cachedThreadPool.getLargestPoolSize();
        System.out.println("largestPoolSize:" + largestPoolSize);
        cachedThreadPool.shutdown();
    }

    private static void testExecutor(ExecutorService executor, List<Callable<Object>> tasks)
        throws InterruptedException {
        long start = System.currentTimeMillis();
        executor.invokeAll(tasks);
        long end = System.currentTimeMillis();
        System.out.println(end - start);
    }

}
```

```
这里使用无线程数限制的CachedThreadPool线程池，也就是说这里的5000个任务会被5000个线程同时处理，
由于所有的线程都只是阻塞而不消耗CPU资源，所以5000个任务在不到2秒的时间内就执行完了。

很明显使用CachedThreadPool能有效提高IO密集型任务的吞吐量，而且由于CachedThreadPool中的线程会在空闲60秒自动回收，所以不会消耗过多的资源。

但是打开任务管理器你会发现执行任务的同时内存会飙升到接近400M，因为每个线程都消耗了一部分内存，在5000个线程创建之后，内存消耗达到了峰值。

内存飙升

所以使用CacheThreadPool的时候应该避免提交大量长时间阻塞的任务，以防止内存溢出；
另一种替代方案是，使用固定大小的线程池，并给一个较大的线程数(不会内存溢出)，同时为了在空闲时节省内存资源，调用allowCoreThreadTimeOut允许核心线程超时。

    线程执行栈的大小可以通过-Xsssize或-XX:ThreadStackSize参数调整

5. 混合型任务

大多数任务并不是单一的计算型或IO型，而是IO伴随计算两者混合执行的任务——即使简单的Http请求也会有请求的构造过程。

混合型任务要根据任务等待阻塞时间与CPU计算时间的比重来决定线程数量：

threads=cores1–blockingCoefficient=cores∗(1+waitTimecomputeTime)

threads=1–blockingCoefficientcores​=cores∗(1+computeTimewaitTime​)

比如一个任务包含一次数据库读写(0.1ms)，并在内存中对读取的数据进行分组过滤等操作(5μs)，那么线程数应该为80左右。

线程数与阻塞比例的关系图大致如下：

线程数与阻塞比例关系图

当阻塞比例为0，也就是纯计算任务，线程数等于核心数(这里是4)；阻塞比例越大，线程池的线程数应该更多。

    《Java并发编程实战》中最原始的公式是这样的：
    Nthreads=Ncpu∗Ucpu∗(1+WC)

Nthreads​=Ncpu​∗Ucpu​∗(1+CW​)
NcpuNcpu​代表CPU的个数，UcpuUcpu​代表CPU利用率的期望值(0<Ucpu<10<Ucpu​<1)，WC

    CW​仍然是等待时间与计算时间的比例。

    我上面提供的公式相当于目标CPU利用率为100%。

    通常系统中不止一个线程池，所以实际配置线程数应该将目标CPU利用率计算进去。

6. 总结

线程池的大小取决于任务的类型以及系统的特性，避免“过大”和“过小”两种极端。线程池过大，
大量的线程将在相对更少的CPU和有限的内存资源上竞争，这不仅影响并发性能，还会因过高的内存消耗导致OOM；
线程池过小，将导致处理器得不到充分利用，降低吞吐率。

要想正确的设置线程池大小，需要了解部署的系统中有多少个CPU，多大的内存，提交的任务是计算密集型、IO密集型还是两者兼有。

虽然线程池和JDBC连接池的目的都是对稀缺资源的重复利用，但通常一个应用只需要一个JDBC连接池，而线程池通常不止一个。如果一个系统要执行不同类型的任务，并且它们的行为差异较大，那么应该考虑使用多个线程池，使每个线程池可以根据各自的任务类型以及工作负载来调整。
```



## 栅栏
栅栏类似于闭锁，它能阻塞一组线程直到某个事件的发生。栅栏与闭锁的关键区别在于，
所有的线程必须同时到达栅栏位置，才能继续执行。闭锁用于等待事件，而栅栏用于等待其他线程。

CyclicBarrier可以使一定数量的线程反复地在栅栏位置处汇集。当线程到达栅栏位置时将调用await方法，
这个方法将阻塞直到所有线程都到达栅栏位置。如果所有线程都到达栅栏位置，那么栅栏将打开，
此时所有的线程都将被释放，而栅栏将被重置以便下次使用。

CyclicBarrier源码解析
CyclicBarrier的类图如下：

```
通过类图我们可以看到，CyclicBarrier内部使用了ReentrantLock和Condition两个类。它有两个构造函数：

    public CyclicBarrier(int parties) {
        this(parties, null);
    }

    public CyclicBarrier(int parties, Runnable barrierAction) {
        if (parties <= 0) throw new IllegalArgumentException();
        this.parties = parties;
        this.count = parties;
        this.barrierCommand = barrierAction;
    }
```
CyclicBarrier默认的构造方法是CyclicBarrier(int parties)，其参数表示屏障拦截的线程数量，
每个线程使用await()方法告诉CyclicBarrier我已经到达了屏障，然后当前线程被阻塞。

CyclicBarrier的另一个构造函数CyclicBarrier(int parties, Runnable barrierAction)，用于线程到达屏障时，
优先执行barrierAction，方便处理更复杂的业务场景。
await方法

调用await方法的线程告诉CyclicBarrier自己已经到达同步点，然后当前线程被阻塞。直到parties个参与线程调用了
await方法，CyclicBarrier同样提供带超时时间的await和不带超时时间的await方法：


 
 






## 面试题集锦
```
1. 进程和线程之间有什么不同？

一个进程是一个独立(self contained)的运行环境，它可以被看作一个程序或者一个应用。而线程是在进程中执行的一个任务。Java运行环境是一个包含了不同的类和程序的单一进程。线程可以被称为轻量级进程。线程需要较少的资源来创建和驻留在进程中，并且可以共享进程中的资源。
2. 多线程编程的好处是什么？

在多线程程序中，多个线程被并发的执行以提高程序的效率，CPU不会因为某个线程需要等待资源而进入空闲状态。多个线程共享堆内存(heap memory)，因此创建多个线程去执行一些任务会比创建多个进程更好。举个例子，Servlets比CGI更好，是因为Servlets支持多线程而CGI不支持。
3. 用户线程和守护线程有什么区别？

当我们在Java程序中创建一个线程，它就被称为用户线程。一个守护线程是在后台执行并且不会阻止JVM终止的线程。当没有用户线程在运行的时候，JVM关闭程序并且退出。一个守护线程创建的子线程依然是守护线程。
4. 我们如何创建一个线程？

有两种创建线程的方法：一是实现Runnable接口，然后将它传递给Thread的构造函数，创建一个Thread对象；二是直接继承Thread类。若想了解更多可以阅读这篇关于如何在Java中创建线程的文章。
5. 有哪些不同的线程生命周期？

当我们在Java程序中新建一个线程时，它的状态是New。当我们调用线程的start()方法时，状态被改变为Runnable。线程调度器会为Runnable线程池中的线程分配CPU时间并且讲它们的状态改变为Running。其他的线程状态还有Waiting，Blocked 和Dead。读这篇文章可以了解更多关于线程生命周期的知识。
6. 可以直接调用Thread类的run()方法么？

当然可以，但是如果我们调用了Thread的run()方法，它的行为就会和普通的方法一样，为了在新的线程中执行我们的代码，必须使用Thread.start()方法。
7. 如何让正在运行的线程暂停一段时间？

我们可以使用Thread类的Sleep()方法让线程暂停一段时间。需要注意的是，这并不会让线程终止，一旦从休眠中唤醒线程，线程的状态将会被改变为Runnable，并且根据线程调度，它将得到执行。
8. 你对线程优先级的理解是什么？

每一个线程都是有优先级的，一般来说，高优先级的线程在运行时会具有优先权，但这依赖于线程调度的实现，这个实现是和操作系统相关的(OS dependent)。我们可以定义线程的优先级，但是这并不能保证高优先级的线程会在低优先级的线程前执行。线程优先级是一个int变量(从1-10)，1代表最低优先级，10代表最高优先级。
9. 什么是线程调度器(Thread Scheduler)和时间分片(Time Slicing)？

线程调度器是一个操作系统服务，它负责为Runnable状态的线程分配CPU时间。一旦我们创建一个线程并启动它，它的执行便依赖于线程调度器的实现。时间分片是指将可用的CPU时间分配给可用的Runnable线程的过程。分配CPU时间可以基于线程优先级或者线程等待的时间。线程调度并不受到Java虚拟机控制，所以由应用程序来控制它是更好的选择（也就是说不要让你的程序依赖于线程的优先级）。
10. 在多线程中，什么是上下文切换(context-switching)？

上下文切换是存储和恢复CPU状态的过程，它使得线程执行能够从中断点恢复执行。上下文切换是多任务操作系统和多线程环境的基本特征。
11. 你如何确保main()方法所在的线程是Java程序最后结束的线程？

我们可以使用Thread类的joint()方法来确保所有程序创建的线程在main()方法退出前结束。这里有一篇文章关于Thread类的joint()方法。
12.线程之间是如何通信的？

当线程间是可以共享资源时，线程间通信是协调它们的重要的手段。Object类中wait()\notify()\notifyAll()方法可以用于线程间通信关于资源的锁的状态。点击这里有更多关于线程wait, notify和notifyAll.
13.为什么线程通信的方法wait(), notify()和notifyAll()被定义在Object类里？

Java的每个对象中都有一个锁(monitor，也可以成为监视器) 并且wait()，notify()等方法用于等待对象的锁或者通知其他线程对象的监视器可用。在Java的线程中并没有可供任何对象使用的锁和同步器。这就是为什么这些方法是Object类的一部分，这样Java的每一个类都有用于线程间通信的基本方法
14. 为什么wait(), notify()和notifyAll()必须在同步方法或者同步块中被调用？

当一个线程需要调用对象的wait()方法的时候，这个线程必须拥有该对象的锁，接着它就会释放这个对象锁并进入等待状态直到其他线程调用这个对象上的notify()方法。同样的，当一个线程需要调用对象的notify()方法时，它会释放这个对象的锁，以便其他在等待的线程就可以得到这个对象锁。由于所有的这些方法都需要线程持有对象的锁，这样就只能通过同步来实现，所以他们只能在同步方法或者同步块中被调用。
15. 为什么Thread类的sleep()和yield()方法是静态的？

Thread类的sleep()和yield()方法将在当前正在执行的线程上运行。所以在其他处于等待状态的线程上调用这些方法是没有意义的。这就是为什么这些方法是静态的。它们可以在当前正在执行的线程中工作，并避免程序员错误的认为可以在其他非运行线程调用这些方法。
16.如何确保线程安全？

在Java中可以有很多方法来保证线程安全——同步，使用原子类(atomic concurrent classes)，实现并发锁，使用volatile关键字，使用不变类和线程安全类。在线程安全教程中，你可以学到更多。
17. volatile关键字在Java中有什么作用？

当我们使用volatile关键字去修饰变量的时候，所以线程都会直接读取该变量并且不缓存它。这就确保了线程读取到的变量是同内存中是一致的。
18. 同步方法和同步块，哪个是更好的选择？

同步块是更好的选择，因为它不会锁住整个对象（当然你也可以让它锁住整个对象）。同步方法会锁住整个对象，哪怕这个类中有多个不相关联的同步块，这通常会导致他们停止执行并需要等待获得这个对象上的锁。
19.如何创建守护线程？

使用Thread类的setDaemon(true)方法可以将线程设置为守护线程，需要注意的是，需要在调用start()方法前调用这个方法，否则会抛出IllegalThreadStateException异常。
20. 什么是ThreadLocal?

ThreadLocal用于创建线程的本地变量，我们知道一个对象的所有线程会共享它的全局变量，所以这些变量不是线程安全的，我们可以使用同步技术。但是当我们不想使用同步的时候，我们可以选择ThreadLocal变量。

每个线程都会拥有他们自己的Thread变量，它们可以使用get()\set()方法去获取他们的默认值或者在线程内部改变他们的值。ThreadLocal实例通常是希望它们同线程状态关联起来是private static属性。在ThreadLocal例子这篇文章中你可以看到一个关于ThreadLocal的小程序。
21. 什么是Thread Group？为什么不建议使用它？

ThreadGroup是一个类，它的目的是提供关于线程组的信息。

ThreadGroup API比较薄弱，它并没有比Thread提供了更多的功能。它有两个主要的功能：一是获取线程组中处于活跃状态线程的列表；二是设置为线程设置未捕获异常处理器(ncaught exception handler)。但在Java 1.5中Thread类也添加了setUncaughtExceptionHandler(UncaughtExceptionHandler eh) 方法，所以ThreadGroup是已经过时的，不建议继续使用。
22. 什么是Java线程转储(Thread Dump)，如何得到它？

线程转储是一个JVM活动线程的列表，它对于分析系统瓶颈和死锁非常有用。有很多方法可以获取线程转储——使用Profiler，Kill -3命令，jstack工具等等。我更喜欢jstack工具，因为它容易使用并且是JDK自带的。由于它是一个基于终端的工具，所以我们可以编写一些脚本去定时的产生线程转储以待分析。读这篇文档可以了解更多关于产生线程转储的知识。
23. 什么是死锁(Deadlock)？如何分析和避免死锁？

死锁是指两个以上的线程永远阻塞的情况，这种情况产生至少需要两个以上的线程和两个以上的资源。

分析死锁，我们需要查看Java应用程序的线程转储。我们需要找出那些状态为BLOCKED的线程和他们等待的资源。每个资源都有一个唯一的id，用这个id我们可以找出哪些线程已经拥有了它的对象锁。

避免嵌套锁，只在需要的地方使用锁和避免无限期等待是避免死锁的通常办法，阅读这篇文章去学习如何分析死锁。
24. 什么是Java Timer类？如何创建一个有特定时间间隔的任务？

java.util.Timer是一个工具类，可以用于安排一个线程在未来的某个特定时间执行。Timer类可以用安排一次性任务或者周期任务。

java.util.TimerTask是一个实现了Runnable接口的抽象类，我们需要去继承这个类来创建我们自己的定时任务并使用Timer去安排它的执行。

这里有关于java Timer的例子。
25. 什么是线程池？如何创建一个Java线程池？

一个线程池管理了一组工作线程，同时它还包括了一个用于放置等待执行的任务的队列。

java.util.concurrent.Executors提供了一个 java.util.concurrent.Executor接口的实现用于创建线程池。线程池例子展现了如何创建和使用线程池，或者阅读ScheduledThreadPoolExecutor例子，了解如何创建一个周期任务。
Java并发面试问题
1. 什么是原子操作？在Java Concurrency API中有哪些原子类(atomic classes)？

原子操作是指一个不受其他操作影响的操作任务单元。原子操作是在多线程环境下避免数据不一致必须的手段。

int++并不是一个原子操作，所以当一个线程读取它的值并加1时，另外一个线程有可能会读到之前的值，这就会引发错误。

为了解决这个问题，必须保证增加操作是原子的，在JDK1.5之前我们可以使用同步技术来做到这一点。到JDK1.5，java.util.concurrent.atomic包提供了int和long类型的装类，它们可以自动的保证对于他们的操作是原子的并且不需要使用同步。可以阅读这篇文章来了解Java的atomic类。
2. Java Concurrency API中的Lock接口(Lock interface)是什么？对比同步它有什么优势？

Lock接口比同步方法和同步块提供了更具扩展性的锁操作。他们允许更灵活的结构，可以具有完全不同的性质，并且可以支持多个相关类的条件对象。

它的优势有：

    可以使锁更公平
    可以使线程在等待锁的时候响应中断
    可以让线程尝试获取锁，并在无法获取锁的时候立即返回或者等待一段时间
    可以在不同的范围，以不同的顺序获取和释放锁

阅读更多关于锁的例子
3. 什么是Executors框架？

Executor框架同java.util.concurrent.Executor 接口在Java 5中被引入。Executor框架是一个根据一组执行策略调用，调度，执行和控制的异步任务的框架。

无限制的创建线程会引起应用程序内存溢出。所以创建一个线程池是个更好的的解决方案，因为可以限制线程的数量并且可以回收再利用这些线程。利用Executors框架可以非常方便的创建一个线程池，阅读这篇文章可以了解如何使用Executor框架创建一个线程池。
4. 什么是阻塞队列？如何使用阻塞队列来实现生产者-消费者模型？

java.util.concurrent.BlockingQueue的特性是：当队列是空的时，从队列中获取或删除元素的操作将会被阻塞，或者当队列是满时，往队列里添加元素的操作会被阻塞。

阻塞队列不接受空值，当你尝试向队列中添加空值的时候，它会抛出NullPointerException。

阻塞队列的实现都是线程安全的，所有的查询方法都是原子的并且使用了内部锁或者其他形式的并发控制。

BlockingQueue 接口是java collections框架的一部分，它主要用于实现生产者-消费者问题。

阅读这篇文章了解如何使用阻塞队列实现生产者-消费者问题。
5. 什么是Callable和Future?

Java 5在concurrency包中引入了java.util.concurrent.Callable 接口，它和Runnable接口很相似，但它可以返回一个对象或者抛出一个异常。

Callable接口使用泛型去定义它的返回类型。Executors类提供了一些有用的方法去在线程池中执行Callable内的任务。由于Callable任务是并行的，我们必须等待它返回的结果。java.util.concurrent.Future对象为我们解决了这个问题。在线程池提交Callable任务后返回了一个Future对象，使用它我们可以知道Callable任务的状态和得到Callable返回的执行结果。Future提供了get()方法让我们可以等待Callable结束并获取它的执行结果。

阅读这篇文章了解更多关于Callable，Future的例子。
6. 什么是FutureTask?

FutureTask是Future的一个基础实现，我们可以将它同Executors使用处理异步任务。通常我们不需要使用FutureTask类，单当我们打算重写Future接口的一些方法并保持原来基础的实现是，它就变得非常有用。我们可以仅仅继承于它并重写我们需要的方法。阅读Java FutureTask例子，学习如何使用它。
7.什么是并发容器的实现？

Java集合类都是快速失败的，这就意味着当集合被改变且一个线程在使用迭代器遍历集合的时候，迭代器的next()方法将抛出ConcurrentModificationException异常。

并发容器支持并发的遍历和并发的更新。

主要的类有ConcurrentHashMap, CopyOnWriteArrayList 和CopyOnWriteArraySet，阅读这篇文章了解如何避免ConcurrentModificationException。
8. Executors类是什么？

Executors为Executor，ExecutorService，ScheduledExecutorService，ThreadFactory和Callable类提供了一些工具方法。

Executors可以用于方便的创建线程池

9.为什么说ConcurrentHashMap是弱一致性的？以及为何多个线程并发修改ConcurrentHashMap时不会报ConcurrentModificationException？

　　参考：http://ifeve.com/java-concurrent-hashmap-2/

　　　　   http://ifeve.com/concurrenthashmap-weakly-consistent/

　　　　　http://blog.csdn.net/liuzhengkang/article/details/2916620
```



































# Java 并发编程实战

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




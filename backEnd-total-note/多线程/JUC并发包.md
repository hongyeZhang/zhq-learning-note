# JUC并发包

## AtomicLong 源码笔记
* CAS操作，通过Unsafe类进行实现的，CAS属于非堵塞算法，但是在高并发环境下还是会存在一些性能问题
  多个线程竞争同一个共享资源时，可能会造成CPU的浪费
* 可以通过 LongAdder 解决高并发下的性能问题

## LongAdder
* 将一个变量分解为多个变量，让同样多的线程去竞争多个资源，解决性能问题
* 内部维护了多个 Cell 变量，和一个基变量base。每个 Cell 有一个初始值为 0 的long 变量，CAS自旋失败之后，会到其他的 Cell 上面尝试，大大增加成功的概率。
* 获取当前值时，是将所有的 Cell 变量累加起来，再加上 base 值之后计算返回的

* 通过 @sun.misc.Contended 对缓存行进行填充，防止 Cell数组中的多个元素共用一个缓存行，提升性能
```java
    @sun.misc.Contended static final class Cell {
        volatile long value;
        Cell(long x) { value = x; }
        final boolean cas(long cmp, long val) {
            return UNSAFE.compareAndSwapLong(this, valueOffset, cmp, val);
        }

        // Unsafe mechanics
        private static final sun.misc.Unsafe UNSAFE;
        private static final long valueOffset;
        static {
            try {
                UNSAFE = sun.misc.Unsafe.getUnsafe();
                Class<?> ak = Cell.class;
                valueOffset = UNSAFE.objectFieldOffset
                    (ak.getDeclaredField("value"));
            } catch (Exception e) {
                throw new Error(e);
            }
        }
    }
```


## List 集合
### CopyOnWriteArrayList
* 在写元素的时候加锁，通过复制一个新的数组来实现，使用写时复制策略来保证list的一致性
* 获取-修改-写入三步操作不是原子性的，在过程中都使用了独占锁，保证同一时间仅仅有一个线程进行修改
* Iterator 迭代器存在弱一致性问题，因为迭代时遍历的数组是一个snapshot，导致在迭代期间如果有其他线程修改了数组的内容，当前迭代器的遍历是看不到的

## LockSupport
* park() 挂起当前的线程
* unpark(thread) 将thread线程解除挂起状态



## 抽象同步队列 AQS
### 基本方法
* 基本的抽象方法，获取各种锁的基本框架

### 条件变量的支持 signal await
* LOCK.newCondition() 的作用是创建一个 ConditionObject 对象，ConditionObject 是 AQS 的内部类，在每个条件变量的内部都维护了一个条件队列，
用来存放调用条件变量的 await() 方法的线程
* condition.signal() 被调用时，会把条件队列里面列队头的一个线程节点从条件队列里面移除并放入AQS的堵塞队列里面，然后激活这个线程


```java
// 获取条件变量
private static final Condition CONDITION = LOCK.newCondition();
```


### 基于AQS实现自定义的同步器
* 自定义AQS需要重写一部分函数，定义原子变量state的含义，




## ReentrantLock
* 底层通过AQS实现的可重入独占锁，有公平和非公平两种实现，默认非公平
* 同一时刻只有一个线程会获取该锁


## ReentrantReadWriteLock
* 解决实际中读多写少的场景，采用读写分离的策略，允许多个线程同时获取锁
* AQS 中 state 变量的高16位代表读锁的个数，低16位代表写锁的线程可冲入次数，通过 CAS 操作实现了读写分离
* 用读写锁实现一个线程安全的list  TODO


## StampedLock
* 提供不可重入锁的实现，通过提供乐观读锁在多线程多读的情况下提供了更好的性能
* 支持三种读写模式的锁
    * 写锁 writeLock
    * 悲观读锁 readLock
    * 乐观读锁  tryOptimisticRead 


## 并发队列
* 堵塞队列 锁实现
* 非堵塞队列 CAS非堵塞算法实现

### ConcurrentLinkedQueue
* 线程安全的无界非堵塞队列
* 使用单向链表实现
* 入队和出队通过CAS实现线程安全
    * 通过无限循环不断进行 CAS 尝试的方式来代替堵塞算法挂起调用的线程，这是使用 CPU 资源换取堵塞
* 由于使用CAS 操作，没有加锁，所以计算size时可能进行了 offer poll remove 等操作，导致元素个数不精确，因此在并发情况下，size 函数不是很有用


### LinkedBlockingQueue
* 使用独占锁实现的堵塞队列，本质是一个 生产者-消费者 模型
* 可以自己设置队列大小，有界堵塞队列
* 使用单向链表实现，入队是对尾节点进行操作，出队是对头结点进行操作
* 对入队、出队分别使用单独的独占锁保证原子性，同时对于独占锁分别配备了条件队列，结合的入队、出队操作实现了一个生产、消费模型


### ArrayBlockingQueue
* 通过使用全局独占锁实现了同时只能有一个线程进行入队或者出队操作，锁的粒度比较大，类似于在方法上添加 synchronized 的意思
* size（） 的操作结果是精确的，因为在获取 count 的时候加锁了


### PriorityBlockingQueue
* 带优先级的无界堵塞队列，内部使用平衡二叉树堆实现，直接遍历队列元素不保证有序
* 内部使用二叉树堆维护元素优先级，使用数组作为元素存储的数据结构，数组可以扩容。当超过最大容量时，会通过CAS算法扩容，出队时始终保持出队元素是堆的根节点
* 使用独占锁控制同事只有一个线程可以入队和出队


### DelayQueue
* 内部使用 PriorityQueue 存储数据，使用 ReentrantLock 实现线程同步
* 队列里面的元素要实现 Delayed 接口，判断元素的过期时间
* 实现元素之互相比较的方法






### CountDownLatch
* 主线程等待所有的子线程执行完毕之后进行汇总，之前使用join方法实现，但有诸多不便之处
* 在使用线程池的时候，一般都是传入 runnable， 调用 join 方法不方便，使用 CountDownLatch 更方便一些
* 使用AQS的状态变量 state 来当做计数器 count 的值，线程调用 countDown() 使计数器减一，调用 await() 方法使线程进入堵塞队列，当state变为0时，唤醒堵塞的队列




### CyclicBarrier
* 实现 CountDownLatch 相同的功能，当所有子线程都执行完毕之后，开始执行后面的任务
* 可以执行循环的任务。所有线程的step1先执行，再执行所有线程的step2，然后执行所有线程的step3
* 可以复用的，特别适合分段有序任务的执行，通过独占锁 ReentrantLock 实现计数器的原子性更新，并使用条件变量队列实现线程同步



### Semaphore


























 





















 
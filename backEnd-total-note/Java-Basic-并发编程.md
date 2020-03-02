
# Java并发编程


## Thread 

一般来说，线程包括以下这几个状态：
`创建(new)、运行(runnable、running)、阻塞(blocked)、超时等待(time waiting)、等待(waiting)、结束（terminated）`

    当需要新起一个线程来执行某个子任务时，就创建了一个线程。但是线程创建之后，不会立即进入就绪状态，
    因为线程的运行需要一些条件（比如内存资源、程序计数器、Java栈、本地方法栈都是线程私有的，所以需要为线程分配一定的内存空间），
    只有线程运行需要的所有条件满足了，才进入就绪状态。
    当线程进入就绪状态后，不代表立刻就能获取CPU执行时间，也许此时CPU正在执行其他的事情，因此它要等待。当得到CPU执行时间之后，线程便真正进入运行状态。
    线程在运行状态过程中，可能有多个原因导致当前线程不继续运行下去，比如用户主动让线程睡眠（睡眠一定的时间之后再重新执行）、用户主动让线程等待，
    或者被同步块给阻塞，此时就对应着多个状态：
    time waiting（睡眠或等待一定的事件）、waiting（等待被唤醒）、blocked（阻塞）。当由于突然中断或者子任务执行完毕，线程就会被消亡。

## 方法介绍
### sleep()
    不会释放锁，也就是说如果当前线程持有对某个对象的锁，则即使调用sleep方法，其他线程也无法访问这个对象。
    如果调用了sleep方法，必须捕获InterruptedException异常或者将该异常向上层抛出。当线程睡眠时间满后，
    不一定会立即得到执行，因为此时可能CPU正在执行其他的任务。所以说调用sleep方法相当于让线程进入阻塞状态。

### yield()
    调用yield方法会让当前线程交出CPU权限，让CPU去执行其他的线程。它跟sleep方法类似，同样不会释放锁。
    但是yield不能控制具体的交出CPU的时间，另外，yield方法只能让拥有相同优先级的线程有获取CPU执行时间的机会。

### stop()
    stop方法已经是一个废弃的方法，它是一个不安全的方法。因为调用stop方法会直接终止run方法的调用，
    并且会抛出一个ThreadDeath错误，如果线程持有某个对象锁的话，会完全释放锁，导致对象状态不一致。所以stop方法基本是不会被用到的。

### join()
    作用是：“等待该线程终止”，这里需要理解的就是该线程是指的主线程等待子线程的终止。也就是 在子线程调用了join()方法后面的代码，
    只有等到子线程结束了才能执行

## 启动线程的方法
**（1） 实现一个runnable接口**
```
Thread thread1 = new Thread(new Runnable() {
    private int i = 0;
    @Override
    public void run() {
        while (i < 20) {
            System.out.println(i++);
        }
    }
});
thread1.start();
```
**（2） 继承thread类，并实现run方法**


## 线程取得控制权的方法
    1.执行对象的某个同步实例方法。
    2.执行对象对应类的同步静态方法。
    3.执行对该对象加同步锁的同步块。
`synchronized(this){ }` 等价于 `publicsynchronized void method(){}`
     
     同步分为类级别和对象级别，分别对应着类锁和对象锁。类锁是每个类只有一个，如果static的方法
     被synchronized关键字修饰，则在这个方法被执行前必须获得类锁；对象锁类同。
     wait(),notify(),notifyAll()不属于Thread类,而是属于Object基础类,也就是说每个对像都有wait(),notify(),notifyAll()的功能。
     因为都个对像都有锁,锁是每个对像的基础,当然操作锁的方法也是最基础了。

    守护线程和用户线程的区别在于：守护线程依赖于创建它的线程，而用户线程则不依赖。举个简单的例子：
    如果在main线程中创建了一个守护线程，当main方法运行完毕之后，守护线程也会随着消亡。
    而用户线程则不会，用户线程会一直运行直到其运行完毕。在JVM中，像垃圾收集器线程就是守护线程。
### 被弃用的方法：
    stop ： 不安全，容易破坏对象
    suspend : 容易造成死锁

* 抢占式调度，由CPU分配给线程时间片，操作系统根据线程的优先级选择下一个进行调度的线程不要将程序构建功能的正确性依赖于优先级
    
## Object 相关方法
### wait()
    会让线程进入阻塞状态，并且会释放线程占有的锁，并交出CPU执行权限。
    interrupt，顾名思义，即中断的意思。单独调用interrupt方法可以使得处于阻塞状态的线程抛出一个异常，
    也就说，它可以用来中断一个正处于阻塞状态的线程；另外，通过interrupt方法和isInterrupted()方法来停止正在运行的线程。
    但是如果配合isInterrupted()能够中断正在运行的线程，因为调用interrupt方法相当于将中断标志
    位置为true，那么可以通过调用isInterrupted()判断中断标志是否被置位来中断线程的执行。
    但是一般情况下不建议通过这种方式来中断线程，一般会在MyThread类中增加一个属性 isStop来标志
    是否结束while循环，然后再在while循环中判断isStop的值。
    等待对象的同步锁,需要获得该对象的同步锁才可以调用这个方法,否则编译可以通过，但运行时会收到一个异常：IllegalMonitorStateException。
    调用任意对象的 wait() 方法导致该线程阻塞，该线程不可继续执行，并且该对象上的锁被释放。

### notify()
    唤醒在等待该对象同步锁的线程(只唤醒一个,如果有多个在等待),注意的是在调用此方法的时候，并不能确切的唤醒某一个等待状态的线程，
    而是由JVM确定唤醒哪个线程，而且不是按优先级。调用任意对象的notify()方法则导致因调用该对象的 wait()方法而阻塞的线程中
    随机选择的一个解除阻塞（但要等到获得锁后才真正可执行）。

### notifyAll():
    唤醒所有等待的线程,注意唤醒的是 notify之前 wait的线程,对于notify之后的wait线程是没有效果的。
    调用obj的wait(), notify()方法前，必须获得obj锁，也就是必须写在synchronized(obj){...} 代码段内。





## ThreadLocal
    ThreadLocal用于保存某个线程共享变量：对于同一个static ThreadLocal，不同线程只能从中get，set，remove自己的变量，而不会影响其他线程的变量。
    1、ThreadLocal.get: 获取ThreadLocal中当前线程共享变量的值。
    2、ThreadLocal.set: 设置ThreadLocal中当前线程共享变量的值。
    3、ThreadLocal.remove: 移除ThreadLocal中当前线程共享变量的值。
    4、ThreadLocal.initialValue: ThreadLocal没有被当前线程赋值时或当前线程刚调用remove方法后调用get方法，返回此方法值。

```java
package Chapter8;

/**
 * @program: multi-thread
 * @description:
 * @author: ZHQ
 * @create: 2019-02-12 21:11
 **/
public class MyThreadLocal {
    private static final ThreadLocal<Object> threadLocal = new ThreadLocal<Object>() {
        /**
         * ThreadLocal没有被当前线程赋值时或当前线程刚调用remove方法后调用get方法，返回此方法值
         */
        @Override
        protected Object initialValue() {
            System.out.println("调用get方法时，当前线程共享变量没有设置，调用initialValue获取默认值！");
            return null;
        }
    };


    public static void main(String[] args) {
        new Thread(new MyIntegerTask("IntegerTask1")).start();
        new Thread(new MyStringTask("StringTask1")).start();
        new Thread(new MyIntegerTask("IntegerTask2")).start();
        new Thread(new MyStringTask("StringTask2")).start();
    }


    public static class MyIntegerTask implements Runnable {
        private String name;

        MyIntegerTask(String name) {
            this.name = name;
        }

        @Override
        public void run() {
            for (int i = 0; i < 5; i++) {
                // ThreadLocal.get方法获取线程变量
                if (null == MyThreadLocal.threadLocal.get()) {
                    // ThreadLocal.et方法设置线程变量
                    MyThreadLocal.threadLocal.set(0);
                    System.out.println("线程" + name + ": 0");
                } else {
                    int num = (Integer) MyThreadLocal.threadLocal.get();
                    MyThreadLocal.threadLocal.set(num + 1);
                    System.out.println("线程" + name + ": " + MyThreadLocal.threadLocal.get());
                    if (i == 3) {
                        MyThreadLocal.threadLocal.remove();
                    }
                }
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }

    }

    public static class MyStringTask implements Runnable {
        private String name;

        MyStringTask(String name) {
            this.name = name;
        }

        @Override
        public void run() {
            for (int i = 0; i < 5; i++) {
                if (null == MyThreadLocal.threadLocal.get()) {
                    MyThreadLocal.threadLocal.set("a");
                    System.out.println("线程" + name + ": a");
                } else {
                    String str = (String) MyThreadLocal.threadLocal.get();
                    MyThreadLocal.threadLocal.set(str + "a");
                    System.out.println("线程" + name + ": " + MyThreadLocal.threadLocal.get());
                }
                try {
                    Thread.sleep(800);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }

    }
}
```


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

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

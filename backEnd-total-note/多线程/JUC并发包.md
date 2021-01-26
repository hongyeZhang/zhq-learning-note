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

### LockSupport
* park() 挂起当前的线程
* unpark(thread) 将thread线程解除挂起状态

### 抽象同步队列 AQS











 





















 

# JDK源码类阅读

### HashMap  JDK1.8
    https://segmentfault.com/a/1190000012926722?utm_source=tag-newest
    
    evict  驱逐 赶出
    阈值可由容量乘上负载因子计
    threshold = capacity * loadFactor
    
    找到大于或等于 cap 的最小2的幂
    static final int tableSizeFor(int cap) {
        int n = cap - 1;
        n |= n >>> 1;
        n |= n >>> 2;
        n |= n >>> 4;
        n |= n >>> 8;
        n |= n >>> 16;
        return (n < 0) ? 1 : (n >= MAXIMUM_CAPACITY) ? MAXIMUM_CAPACITY : n + 1;
    }


### Unsafe
    Unsafe类提供了硬件级别的原子操作，Java无法直接访问到操作系统底层（如系统硬件等)，为此Java使用native方法来扩展Java
    程序的功能。Java并发包(java.util.concurrent)中大量使用了Unsafe类提供的CAS方法。Unsafe类还提供了阻塞和唤醒线程的
    方法，以及volatile read/write操作等。
    
    链接：https://www.jianshu.com/p/b5e8f48ae0ba


### ConcurrentHashMap  JDK1.8
    1. 原理解析
    利用 ==CAS + synchronized== 来保证并发更新的安全
    底层使用==数组+链表+红黑树==来实现
    
    https://blog.csdn.net/programmer_at/article/details/79715177

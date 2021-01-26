# ThreadLocal
## 基本知识
* 主要作用
    - 保存线程的上下文信息，在需要的地方可以获取
    - 线程安全的，避免某些情况需要考虑线程安全必须同步带来的性能损失
* ThreadLocal用于保存某个线程共享变量：对于同一个static ThreadLocal，不同线程能从中get，set，remove自己的变量，而不会影响其他线程的变量。
    * 1、ThreadLocal.get: 获取ThreadLocal中当前线程共享变量的值。
    * 2、ThreadLocal.set: 设置ThreadLocal中当前线程共享变量的值。
    * 3、ThreadLocal.remove: 移除ThreadLocal中当前线程共享变量的值。
    * 4、ThreadLocal.initialValue: ThreadLocal没有被当前线程赋值时或当前线程刚调用remove方法后调用get方法，返回此方法值。
* 每个线程内部都有一个名为 threadLocals 的变量，类型为HashMap，其中key为ThreadLocal变量的this引用，value为我们set方法设置的值。每个线程的
  本地变量存放在线程自己的内存变量 threadLocals 中，如果线程不消亡，这些变量会一直存在，容易造成内存溢出，因此使用完毕之后需要调用 remove 方法
* 不能继承，子线程不能拿到父线程设置的变量值

## 源码解析
* get()
* set()
* 主要是理解 ThreadLocalMap 的存储方式
* hash碰撞的解决方式： 线性探测法
* JDK 中hashmap 碰撞的解决方式： 链表 + 红黑树

## 内存泄露
* 在线程池中，线程执行完后不被回收，而是返回线程池中，Thread有个强引用指向ThreadLocalMap,ThreadLocalMap有强引用指向Entry,Entry的key是弱引用的ThreadLocal对象。
  如果ThreadLocal使用一次后就不在有任何引用指向它，JVM GC 会将ThreadLocal对象回收掉。导致Entry变为{null : value}。
  此时这个Entry已经无效，因为key被回收了，而value无法被回收，一直存在内存中。
* 结论：在执行了ThreadLocal.set()方法之后一定要记得使用ThreadLocal.remove(),将不要的数据移除掉，避免内存泄漏。

## InheritableThreadLocal
* 子线程可以拿到父线程的本地变量


## 例子

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


* 变量继承例子
```java
public class ThreadLocalTest2 {

    private static ThreadLocal<String> local = new InheritableThreadLocal<>();

    public static void main(String[] args) {
        local.set("hello world");
        Thread thread = new Thread(new Runnable() {
            @Override
            public void run() {
                System.out.println("thread get " + local.get());
            }
        });

        thread.start();
        System.out.println("main get " + local.get());

    }
}
```



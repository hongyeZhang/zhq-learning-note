
## 集合
Multiset就是无序的，但是可以重复的集合

你看到JDK提供的unmodifiable的缺陷了吗？实际上，Collections.unmodifiableXxx所返回的集合和源集合是同一个对象，只不过可以对集合做出改变的API都被override，会抛出UnsupportedOperationException。也即是说我们改变源集合，导致不可变视图（unmodifiable View）也会发生变化，oh my god!

一对多：Multimap

双向：BiMap

本地缓存  CacheLoader

我们可以通过guava对JDK提供的线程池进行装饰，让其具有异步回调监听功能，然后在设置监听器即可！

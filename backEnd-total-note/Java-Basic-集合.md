
# 集合



## 集合迭代器
### Iterator
hasNext() next() remove()
### ListIterator
可以实现集合元素的增删改查

## 队列
实现方式：interface 与 implementation 分离
* 循环数组
* 链表


    编译器会将 forEach() 循环翻译为 带有 迭代器的循环
    迭代器：查找一个元素的唯一操作就是next(), 执行查找操作时，迭代器的位置随之向前移动，迭代器可以认为处于两个元素之间
    删除一个元素：eg: 删除第一个元素
```
Iterator<String> iterator = c.iterator();
iterator.next();
iterator.remove()
```

删除两个相邻的元素：
```
iterator.remove();
iterator.next();
iterator.remove();
```

抽象类负责实现一些方法，子类就不需要进行一一实现
```
public abstract class AbstractCollection<E> implements Collection<E>
```

## 具体集合
    ArrayList LinkedList
    ArrayDeque
    HashSet TreeSet EnumSet LinkedHashSet
    PriorityQueue
    HashMap  TreeMap EnumMap  LinkedHashMap weakHashMap  IdentityHashMap

    数组（数组链表）的缺点：从数组的中间位置删除一个元素要付出很大的代价，插入元素也是如此。
    所有链表都是双向链表
    只有对自然有序的集合通过迭代器添加元素才会有意义
    ListIterator 迭代器可以进行反向遍历列表: `previous() hasPrevious() set()`
    add方法只依赖于迭代器的位置，而remove方法依赖于迭代器的状态
    链表不支持快速的随机访问
    String obj = list.get(n)  效率很低
    迭代器保持着当前位置的计数值，可以返回当前位置的索引
    使用链表的唯一理由是减小在列表中间插入和删除元素锁带来的代价
    Vector中的所有方法都是同步的

### 散列集：
    可以快速查找元素，但是无法控制元素的出现顺序
    散列表为每个对象计算一个整数，成为散列码，java中散列表通过链表数组来实现，每个列表成为桶
    可能出现 散列冲突
    超过装填因子（默认0.75），就需要进行再散列
    hashCode() 返回对象的散列码
    树集：TreeSet，是一个有序集合，排序采用红黑树来完成，假定插入的元素实现了Comparable接口.
    可以通过将Comparator对象传递给TreeSet的构造器 确定要进行排序的方法
```
ItemComparator comp = new ItemComparator();
SortedSet<Item> sortByDescription = new TreeSet(comp);
```

如果两个对象相等
```
if(x.equals(y)) <==> x.hashcode() == y.hashCode()
```

### 队列
双端队列：在队列的头部和尾部同时方便的添加和删除对象，不支持在队列中间添加元素
```
public interface Deque<E> extends Queue<E>
```
    ArrayDeque : add  offer poll peek

#### 优先级队列
优先级队列采用的数据结构是  堆，典型使用场景是任务调度。 PriorityQueue

### 映射表
    HashMap  TreeMap，实现Map接口，如果不需要按照排列顺序访问键，则选择散列。键必须是唯一的。
    三个视图：keySet()   values()   entrySet()

### 专用集与映射表类
    weakHashMap 使用弱引用来保存键，与垃圾回收有关
    LinkedHashMap、LinkedHashSet可以记住插入元素项的顺序
    Java 中的每一个枚举都继承自 java.lang.Enum 类。当定义一个枚举类型时，
    每一个枚举类型成员都可以看作是 Enum 类的实例，这些枚举成员默认都被 final、public, static 修饰，
    当使用枚举类型成员时，直接使用枚举名称调用成员即可。
    所有枚举实例都可以调用 Enum 类的方法，常用方法如表 1 所示。

| 方法名称 | 描述 |
| ------ | ------ |
| values() | 以数组形式返回枚举类型的所有成员 |
| valueOf() | 将普通字符串转换为枚举实例 |

### 集合框架
集合两个基本接口：Collection  Map
#### 试图与包装器
集合的子范围
```
list group2 = staff.subList(beginIndex, endIndex);
```

#### 视图
　　java中的视图，可以说其实就是一个具有限制的集合对象，只不过这里的不是集合对象，而是一个视图对象。例如：这里有一个Test类
```
Test[] tests = new Test[10];
List<Test> testList = Arrays.asList(tests);
```
这里的testList是一个视图对象，具有访问数组元素set，get的方法。但是如果调用改变数组的方法就会抛出异常。所以可以说视图对象可以说是具有限制的集合对象。
利用java类库中的方法我们可以获得不可更改视图，子视图等等，这些视图对于原对象具有不同的操作权限。

##### 同步视图
```
Map<String, Employee> map = Collections.synchronizedMap(new HashMap<>);
```
视图有一些局限性，可能只可以读、无法改变大小、只支持删除而不支持插入。

### 批量操作
求集合的交集
```
Set<String> result = new HashSet<>(a);
result.retainAll(b);
```
### 集合与数组之间的互相转换
```
Arrays.asList(String[] names);
Object[] values = staff.toArray();
String[] values = staff.toArray(new String[0]);
```

### 排序
```
List<String> staff = new LinkedList();
Collections.sort(staff);
// 降序排列
Collections.sort(staff, Collections.reverseOrder());
//可以传入比较器，自定义排序规则
Collections.sort(staff, ItemComparator);
Collections.sort(staff, Collections.reverseOrder(ItemComparator));
// 随机打乱集合中的元素
Collections.shuffle(list);
```
Collections类中的简单算法：
`min max copy fill addAll replaceAll swap reverse frequency`

### 遗留的集合
    Hashtable 与 HashMap 基本一样，但是里面所有的方法都是同步的
    Enumeration
    属性映射表  class Properties extends Hashtable<Object,Object>
    Stack  pop() push()  peek()
    BitSet 位集，存储于字节中。 get set clear and or xor andnot

### 总结部分
  Java将集合分成两大类，一类是具有关联关系的集合（即映射关系，以Map为代表的根接口），另一类是无关联关系的集合（像链表、集合之类的，以Collection
  为代表的根接口），也就是Collection和Map是所有Java集合的根接口，从它们两个派生出了很多具体的集合实现类；

### Collection的直接子接口
无关联集合，其下直接派生出了三种接口，Set、List、Queue
+ Set：无序、不可重复集合；
+ List：有序、可重复集合；
+ Queue：队列，特殊的无关联集合（FIFO）

#### Map的直接子接口
关联集合，保存键值对，其下派生出了很多实现类，其中最常用的几种有
+ HashMap：线程不安全，键值允许为null
+ HashTable：线程安全，键值不能为null
+ SortedMap：有序Map
+ EnumMap：枚举Map

Java集合都重载了toString方法，因此可以直接打印出其中的元素！

#### Collection接口
    1) 是所有无关联集合的根接口，其中的方法在所有派生类中都存在（也就是在Set、List、Queue以及其实现类中都可以使用）；
    2) 接下来介绍的都是Collection的对象方法；
    3) 添加元素：成功添加返回true
         i. boolean add(Object o); // 添加一个元素
         ii. boolean addAll(Collection c);  // 将c中的所有元素加入
    4) 删除元素：成功删除返回true
         i. boolean remove(Object o);  // 删除指定元素，只删除第一个找到的
         ii. boolean removeAll(Collection c);  // 删除c中所有的元素，相当于集合相减
         iii. boolean retainAll(Collection c);  // 删除c中不包含的元素，相当于集合相交
         iv. void clear(); // 清空集合
    5) 检查是否包含某个元素：
         i. boolean contains(Object o);  // 是否包含指定元元素o
         ii. boolean contains(Collection c);  // 是否包含集合c中的所有元素
    6) 功能方法：
         i. 查看集合中元素的个数：int size();
         ii. 判空：boolean isEmpty();
         iii. 把集合转换成一个数组：Object[] toArray();

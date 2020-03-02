
# java基础知识笔记





## 字符串

### StringBuffer
    StringBuffer类中的方法主要偏重于对于字符串的变化，例如追加、插入和删除等，这个也是StringBuffer和String类的主要区别。
    public StringBuffer append(boolean b)
    该方法的作用是追加内容到当前StringBuffer对象的末尾，类似于字符串的连接。调用该方法以后，StringBuffer对象的内容也发生改变，例如：
    b、deleteCharAt方法
    public StringBuffer deleteCharAt(int index)
    该方法的作用是删除指定位置的字符，然后将剩余的内容形成新的字符串。例如：
    StringBuffer sb = new StringBuffer(“Test”);
    还存在一个功能类似的delete方法：
    public StringBuffer delete(int start,int end)
    该方法的作用是删除指定区间以内的所有字符，包含start，不包含end索引值的区间。例如：
    该代码的作用是删除索引值1(包括)到索引值4(不包括)之间的所有字符，剩余的字符形成新的字符串。则对象sb的值是”TString”。
    c、insert方法
    public StringBuffer insert(int offset, boolean b)
    该方法的作用是在StringBuffer对象中插入内容，然后形成新的字符串。例如：
    StringBuffer sb = new StringBuffer(“TestString”);
    sb.insert(4,false);
    该示例代码的作用是在对象sb的索引值4的位置插入false值，形成新的字符串，则执行以后对象sb的值是”TestfalseString”。
    d、reverse方法
    public StringBuffer reverse()
    该方法的作用是将StringBuffer对象中的内容反转，然后形成新的字符串。例如：
    StringBuffer sb = new StringBuffer(“abc”);
    sb.reverse();
    经过反转以后，对象sb中的内容将变为”cba”。
    e、setCharAt方法
    public void setCharAt(int index, char ch)
    该方法的作用是修改对象中索引值为index位置的字符为新的字符ch。例如：
    StringBuffer sb = new StringBuffer(“abc”);
    sb.setCharAt(1,’D’);
    则对象sb的值将变成”aDc”。
    f、trimToSize方法
    public void trimToSize()
    该方法的作用是将StringBuffer对象的中存储空间缩小到和字符串长度一样的长度，减少空间的浪费。


## 泛型
    使用泛型能够避免过多的强制类型转换, E 表示集合元素  K V 表示关键字和值
    public class Pair<T,U>{
    }
```
class ArrayAlg{
    public static <T> T getMiddle(T... a){
    // 类型变量放在修饰符后面，返回类型的前面
  }
}
// 限制实现Comparable的接口
public static <T extends Comparable> T min(T... a);
<T extends Comparable & Serializable>
```

    因为虚拟机中没有泛型类型，所以要进行类型擦除，没有限定类型的T替换为Object，不会像C++那样产生模板代码膨胀。
    所有的类型参数都用它们的限定参数替换。
    不能同基本类型实例化类型参数，因为类型擦除后是object
```
由于类型擦除，下面二者相等，都是只检查是否为Pair对象
        Pair<String> pair1 = new Pair<String>();
        Pair<Double> pair2 = new Pair<Double>();
        System.out.println(pair1.getClass() == pair2.getClass());
```

    由于类型参数，不允许创建参数类型的数组
    不能实例化类型变量
    new T() // error
    泛型类的静态上下文中类型变量无效，禁止使用带有类型变量的静态域和方法。

### 泛型类型的继承规则
    无论S与T有什么关系，Pair<S> 与 Pair<T> 没有什么关系
    但是与之类似的数组有区别，可以将Manager[] 赋值给 Employee[]
### 通配符类型
```
Pair<? extends Employee>

// 限制为Manger的所有超类型
? super Manager
带有超类型限定的通配符可以向泛型对象写入，带有子类型限定的通配符可以从泛型对象读取。
Pair<?> 无限定通配符

```

### 反射和泛型
    Class类是泛型的，String.class 实际上是Class<String>的对象








##  运算符
```
^是位异或运算符,按二进制位每个对应为做异或
java中有三种移位运算符
<<      :     左移运算符，num << 1,相当于num乘以2
>>      :     右移运算符，num >> 1,相当于num除以2， 可以这么理解，但不是绝对的
>>>    :     无符号右移，忽略符号位，空位都以0补齐
```








## 反射
    先了解一些基本的概念：运行时，编译时，编译型，解释型，类加载器，动态加载类
    什么是编译？将原程序翻译成计算机语言，就是二进制代码，在java中是将.java文件也就是源程序翻译成.class的字节码
    什么是编译时？将原程序翻译成计算机语言的过程中，将.java翻译为.class文件的过程
    什么是运行时？就是在启动这个程序的时候，在java中是,类加载器加载.class文件，并交给jvm处理
    什么是编译型语言？将原程序一次性全部转换为二进制代码，然后执行程序
    什么是解释型语言？转换一句，执行一句，java是既编译又解释的语言
    编译型语言和解释型语言的区别：编译型语言效率高，依赖于编译器，但是跨平台差，解释型的效率低，依赖于解释器，但跨平台强
    什么是类加载器？类加载器就是JVM中的类装载器，作用就是将编译好的.class字节码运到检查器进行安全检查的，检查通过后开始解释执行
    什么是运行时动态加载类？
    反射就是可以将一个程序（类）在运行的时候获得该程序（类）的信息的机制，也就是获得在编译期不可能获得的类的信息，因为这些信息是保存在Class对象中的，
    而这个Class对象是在程序运行时动态加载的
    它 就是可以在程序运行的时候动态装载类，查看类的信息，生成对象，或操作生成对象。类在运行的时候，可以得到该类的信息，并且 可以动态的修改这些信息。
    class对象是在运行的时候产生的，通过class对象操作类的信息是在运行时进行的，当运行 程序的时候，类加载器会加载真正需要的类，
    什么是真正需要的呢？就是该类真正起作用，如：有该类的对象实例，或该类调用了静态方法属性等

```
A a = (A)Class.forName(“package.A”).newInstance();
反射分为类的反射以及方法的反射

public class ReflectServiceImpl {
    public void sayHello(String name) {
        System.out.println("hello " + name);
    }
}

JDK动态代理
public static Object reflect() {
    ReflectServiceImpl object = null;
    try{
        object = (ReflectServiceImpl) Class.forName("reflect.ReflectServiceImpl").newInstance();
        Method method = object.getClass().getMethod("sayHello", String.class);
        method.invoke(object, "zhqzhq");
    } catch (Exception e) {
        e.getStackTrace();
    }
    return object;
}
```










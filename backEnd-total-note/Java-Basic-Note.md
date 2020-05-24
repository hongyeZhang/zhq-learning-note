
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



# java查漏补缺

#### 双括号初始化 / 匿名内部类初始化法
    // 新建一个列表并赋初值 A、B、C
    ArrayList<String> list = new ArrayList<String>() {{
        add("A");
        add("B");
        add("C");
    }};
    还有其他集合比如HashMap的初始化：
    Map map = new HashMap() {{
    　　put("Name", "Unmi");
    　　put("QQ", "1125535");
    }};
    双大括号初始化（double brace initialization）或者匿名内部类初始化法

    理解：
    这里以ArrayList的例子解释，首先第一层花括号定义了一个继承于ArrayList的匿名内部类 (Anonymous Inner Class)：
    //定义了一个继承于ArrayList的类，它没有名字
    new ArrayList<String>(){
      //在这里对这个类进行具体定义
    };
    第二层花括号实际上是这个匿名内部类实例初始化块 (Instance Initializer Block)（或称为非静态初始化块）：
    new ArrayList<String>(){
      {
        //这里是实例初始化块，可以直接调用父类的非私有方法或访问非私有成员
      }
    };
    我们通过new得到这个ArrayList的子类的实例并向上转型为ArrayList的引用：
     ArrayList<String> list = new ArrayList<String>() {{}};

* 工作中不要使用，容易造成内存泄露

#### &&和&的区别
    Java中&&和&都是表示与的逻辑运算符，都表示逻辑运输符and，当两边的表达式都为true的时候，整个运算结果才为true，否则为false。
    &&的短路功能，当第一个表达式的值为false的时候，则不再计算第二个表达式；&则两个表达式都执行。
    &可以用作位运算符，当&两边的表达式不是Boolean类型的时候，&表示按位操作。

#### 先解释下Java中的对象序列化
    在讨论transient之前，有必要先搞清楚Java中序列化的含义；
    Java中对象的序列化指的是将对象转换成以字节序列的形式来表示，这些字节序列包含了对象的数据和信息，一个序列化后的对象可以
    被写到数据库或文件中，也可用于网络传输，一般当我们使用缓存cache（内存空间不够有可能会本地存储到硬盘）或远程调用rpc
    （网络传输）的时候，经常需要让我们的实体类实现Serializable接口，目的就是为了让其可序列化。
    当然，序列化后的最终目的是为了反序列化，恢复成原先的Java对象，要不然序列化后干嘛呢，所以序列化后的字节序列都是可以恢复
    成Java对象的，这个过程就是反序列化。

#### transient
    Java中transient关键字的作用，简单地说，就是让某些被修饰的成员属性变量不被序列化，这一看好像很好理解，就是不被序列化，那么什么情况下，一个对象的某些字段不需要被序列化呢？如果有如下情况，可以考虑使用关键字transient修饰：
    1、类中的字段值可以根据其它字段推导出来，如一个长方形类有三个属性：长度、宽度、面积（示例而已，一般不会这样设计），那么在序列化的时候，面积这个属性就没必要被序列化了；
    2、其它，看具体业务需求吧，哪些字段不想被序列化；
    PS，记得之前看HashMap源码的时候，发现有个字段是用transient修饰的，我觉得还是有道理的，确实没必要对这个modCount
    字段进行序列化，因为没有意义，modCount主要用于判断HashMap是否被修改（像put、remove操作的时候，modCount都会自增），对于这种变量，一开始可以为任何值，0当然也是可以（new出来、反序列化出来、或者克隆clone出来的时候都是为0的），没必要持久化其值。


### ==
    基本数据类型（也称原始数据类型） ：byte,short,char,int,long,float,double,boolean。
    他们之间的比较，应用双等号（==）,比较的是他们的值。
    引用数据类型：当他们用（==）进行比较的时候，比较的是他们在内存中的存放地址（确切的说，是堆内存地址）。
    注：对于第二种类型，除非是同一个new出来的对象，他们的比较后的结果为true，否则比较后结果为false。
    因为每new一次，都会重新开辟堆内存空间。

#### == 和 equals()
    JAVA当中所有的类都是继承于Object这个超类的，在Object类中定义了一个equals的方法，equals的源码是这样写的：
    public boolean equals(Object obj) {
        //this - s1
        //obj - s2
        return (this == obj);
    }
    可以看到，这个方法的初始默认行为是比较对象的内存地址值，一般来说，意义不大。所以，在一些类库当中这个方法被重写了，
    如String、Integer、Date。在这些类当中equals有其自身的实现（一般都是用来比较对象的成员变量值是否相同），而不再是比较类在堆内存中的存放地址了。
    所以说，对于复合数据类型之间进行equals比较，在没有覆写equals方法的情况下，他们之间的比较还是内存中的存放位置的地址值，跟双等号（==）的结果相同；如果被复写，按照复写的要求来。
    我们对上面的两段内容做个总结吧：
     == 的作用：
    　　基本类型：比较的就是值是否相同
    　　引用类型：比较的就是地址值是否相同
    equals 的作用:
    　　引用类型：默认情况下，比较的是地址值。
    注：不过，我们可以根据情况自己重写该方法。一般重写都是自动生成，比较对象的成员变量值是否相同
    枚举类型中：使用== 和使用equals方法的执行结果是一样的。

#### final
    修饰类
    final修饰类时，说明该类你不想被别人继承！一个类不被别的类继承就可以使用final来修饰
    注意 final类中的所有成员方法都会被隐式地指定为final方法。
    修饰方法
    当一个方法被final修饰后，就代表该方法无法被重写，如果你想明确禁止该方法在子类中被覆盖的情况下才将方法设置为final的，
    你就无法重写该方法了，但是！同时注意 如果父类的 final修饰的方法设置为private，则子类可以写一个同名的方法，此时 ，
    该同名的方法不再产生final的报错，而是在子类重新定义了一个方法（注：类的private方法会隐式地被指定为final方法。）

    修饰变量
    被final修饰的变量其实就相当于定义了一个常量，无法被修改的变量，如果final修饰的是一个基本数据类型的变量，那么这个变量的值就定了，
    不能变了，而如果修饰的是一个引用变量，那么该变量存的是一个内存地址，该地址就不能变了，但是该内存地址所指向的那个对象还是可以变的，

    方法定义的参数是 final类型的，是不想别人在方法内部修改参数的值，如果final修饰的是一个基本类型，那么是可以的，
    如果修饰的是引用类型，那么便不行了，因为就如上文那个str.append 对象的内容是可以变化的！




#### Optional
    Optional。这也是一个模仿 Scala 语言中的概念，作为一个容器，它可能含有某值，或者不包含。
    使用它的目的是尽可能避免 NullPointerException。
    在更复杂的 if (xx != null) 的情况中，使用 Optional 代码的可读性更好，而且它提供的是编译时检查，
    能极大的降低 NPE 这种 Runtime Exception 对程序的影响，或者迫使程序员更早的
    在编码阶段处理空值问题，而不是留到运行时再发现和调试。
```
    public static void print(String input) {
        Optional.ofNullable(input).ifPresent(System.out::println);
    }
    
    public static int getLength(String input) {
        return Optional.ofNullable(input).map(String::length).orElse(-1);
    }
    
    public static void main(String[] args) {
        String str1 = null;
        print(str1);
        System.out.println(getLength(str1));
    
        String str2 = "hello world";
        print(str2);
        System.out.println(getLength(str2));
    
    }
```

### 位操作符
    a|=b的意思就是把a和b按位或然后赋值给a 按位或的意思就是先把a和b都换成2进制，然后用或操作，相当于a=a|b




## 内部类
    下面说一说内部类（Inner Class）和静态内部类（Static Nested Class）的区别：
    定义在一个类内部的类叫内部类，包含内部类的类称为外部类。内部类可以声明public、protected、private等访问限制，
    可以声明 为abstract的供其他内部类或外部类继承与扩展，或者声明为static、final的，也可以实现特定的接口。
    外部类按常规的类访问方式使用内部类，唯一的差别是外部类可以访问内部类的所有方法与属性，包括私有方法与属性。
    
    (1)创建实例
       OutClass.InnerClass obj = outClassInstance.new InnerClass(); //注意是外部类实例.new，内部类
       AAA.StaticInner in = new AAA.StaticInner();//注意是外部类本身，静态内部类
    
    (2)内部类中的this
       内部类中的this与其他类一样是指的本身。创建内部类对象时，它会与创造它的外围对象有了某种联系，于是能访问外围类的所有成员，
       不需任何特殊条件，可理解为内部类链接到外部类。用外部类创建内部类对象时，此内部类对象会秘密的捕获一个指向外部类的引用，
       于是，可以通过这个引用来访问外围类的成员。
    
    (3)外部类访问内部类
       内部类类似外部类的属性，因此访问内部类对象时总是需要一个创建好的外部类对象。
       内部类对象通过‘外部类名.this.xxx’的形式访问外部类的属性与方法。如：
           System.out.println("Print in inner Outer.index=" + pouter.this.index);
           System.out.println("Print in inner Inner.index=" + this.index);
    
    （4）内部类向上转型
       内部类也可以和普通类一样拥有向上转型的特性。将内部类向上转型为基类型，尤其是接口时，内部类就有了用武之地。如果内部类是private的，
       只可以被它的外部类问，从而完全隐藏实现的细节。
    
    （5）方法内的类
       方法内创建的类（注意方法中也能定义类），不能加访问修饰符。另外，方法内部的类也不是在调用方法时才会创建的，它们一样也被事先编译了。
    
    （6）静态内部类
       定义静态内部类：在定义内部类的时候，可以在其前面加上一个权限修饰符static。此时这个内部类就变为了静态内部类。通常称为嵌套类，当内部类是static时，意味着：
       [1]要创建嵌套类的对象，并不需要其外围类的对象；
       [2]不能从嵌套类的对象中访问非静态的外围类对象（不能够从静态内部类的对象中访问外部类的非静态成员）；
       嵌 套类与普通的内部类还有一个区别：普通内部类的字段与方法，只能放在类的外部层次上，所以普通的内部类不能有static数据和static字段， 
       也不能包含嵌套类。但是在嵌套类里可以包含所有这些东西。也就是说，在非静态内部类中不可以声明静态成员，只有将某个内部类修饰为静态类，
       然后才能够在这 个类中定义静态的成员变量与成员方法。
       另外，在创建静态内部类时不需要将静态内部类的实例绑定在外部类的实例上。普通非静态内部类的 对象是依附在外部类对象之中的，
       要在一个外部类中定义一个静态的内部类，不需要利用关键字new来创建内部类的实例。静态类和方法只属于类本身，并不属于该类的对象，
       更不属于其他外部类的对象。
    
    （7）内部类标识符
       每个类会产生一个.class文件，文件名即为类名。同样，内部类也会产生这么一个.class文件，但是它的名称却不是内部类的类名，
       而是有着严格的限制：外围类的名字，加上$,再加上内部类名字。
    
    （8）为何要用内部类？
       1.   内部类一般只为其外部类使用；
       2.   内部类提供了某种进入外部类的窗户；
       3.   也是最吸引人的原因，每个内部类都能独立地继承一个接口，而无论外部类是否已经继承了某个接口。因此，内部类使多重继承的解决方案变得更加完整。

```
package com.test.xml;
public class OutClassTest {
    static int a;

    int b;

    public static void test() {
        System.out.println("outer class static function");
    }

    public static void main(String[] args) {
        OutClassTest oc = new OutClassTest();
        // new一个外部类
        OutClassTest oc1 = new OutClassTest();
        // 通过外部类的对象new一个非静态的内部类
        OutClassTest.InnerClass no_static_inner = oc1.new InnerClass();
        // 调用非静态内部类的方法
        System.out.println(no_static_inner.getKey());

        // 调用静态内部类的静态变量
        System.out.println(OutClassTest.InnerStaticClass.static_value);
        // 不依赖于外部类实例,直接实例化内部静态类
        OutClassTest.InnerStaticClass inner = new OutClassTest.InnerStaticClass();
        // 调用静态内部类的非静态方法
        System.out.println(inner.getValue());
        // 调用内部静态类的静态方法
        System.out.println(OutClassTest.InnerStaticClass.getMessage());
    }

    private class InnerClass {
        // 只有在静态内部类中才能够声明或定义静态成员
        // private static String tt = "0";
        private int flag = 0;

        public InnerClass() {            // 三.非静态内部类的非静态成员可以访问外部类的非静态变量和静态变量            System.out.println("InnerClass create a:" + a);            System.out.println("InnerClass create b:" + b);            System.out.println("InnerClass create flag:" + flag);            //            System.out.println("InnerClass call outer static function");            // 调用外部类的静态方法            test();        }        public  String getKey() {            return "no-static-inner";        }    }    private static class InnerStaticClass {        // 静态内部类可以有静态成员，而非静态内部类则不能有静态成员。        private static String static_value = "0";        private int flag = 0;        public InnerStaticClass() {            System.out.println("InnerClass create a:" + a);            // 静态内部类不能够访问外部类的非静态成员            // System.out.println("InnerClass create b:" + b);            System.out.println("InnerStaticClass flag is " + flag);            System.out.println("InnerStaticClass tt is " + static_value);        }        public int getValue() {            // 静态内部类访问外部类的静态方法            test();            return 1;        }        public static String getMessage() {            return "static-inner";        }    }    public OutClassTest() {        // new一个非静态的内部类        InnerClass ic = new InnerClass();        System.out.println("OuterClass create");    }}

/**
 * 总结：
 * 1.静态内部类可以有静态成员(方法，属性)，而非静态内部类则不能有静态成员(方法，属性)。
 * 2.静态内部类只能够访问外部类的静态成员,而非静态内部类则可以访问外部类的所有成员(方法，属性)。
 * 3.实例化一个非静态的内部类的方法：
 *  a.先生成一个外部类对象实例
 *  OutClassTest oc1 = new OutClassTest();
 *  b.通过外部类的对象实例生成内部类对象
 *  OutClassTest.InnerClass no_static_inner = oc1.new InnerClass();
 *  4.实例化一个静态内部类的方法：
 *  a.不依赖于外部类的实例,直接实例化内部类对象
 *  OutClassTest.InnerStaticClass inner = new OutClassTest.InnerStaticClass();
 *  b.调用内部静态类的方法或静态变量,通过类名直接调用
 *  OutClassTest.InnerStaticClass.static_value
 *  OutClassTest.InnerStaticClass.getMessage()
 */
```

```
java允许在一个类中定义另外一个类，这就叫类嵌套。类嵌套分为两种，静态的称为静态嵌套类，非静态的又称为内部类。

使用嵌套类的原因：
能够将仅在一个地方使用的类合理地组合。如果一个类可能只对于另外一个类有用，此时将前者
组合到后者，可以使得程序包更加简洁。
增强封装性。假如由两个类A和B，B类需要使用A类中的成员，而恰好该成员又是仅类内部
可见（private）的，如果将B定义为A的嵌套类，则B可以使用A的任何成员，而且B也可以声明
为外部不可见（private），将B隐藏起来。
能够使代码可读性和维护性更强。嵌套的类代码相较于顶级类，更靠近它被使用的地方，方便查看。

  嵌套类也属于类的成员，因此也可使用类成员的可视范围控制修饰词（public，protect，private），
  内部类能够使用其所在类的其他类成员，而静态嵌套类则不能使用其所在类的其他类成员。

静态嵌套类
与静态方法与静态字段类似，静态嵌套类是与其所在类相关的。静态嵌套类不能直接使用实例变量或者实例字段，而只能通过一个对象引用，可将静态嵌套类视为跟其他顶级类一样，只不过是内嵌在其他类里面，方便打包。
静态嵌套类的使用方法与类中的其他类成员类似，一下演示如何创建静态嵌套类对象：

//StaticNestedClass为OuterClass的一个嵌套类
OuterClass.StaticNestedClass nestedObject = new OuterClass.StaticNestedClass();

内部类（非静态嵌套类）
内部类是与其所在类的实例相关的  ，能够直接使用实例对象的方法和字段，内部类与实例相关，所以内部类不能定义静态的成员。
如果需要创建内部类对象，首先需要创建该内部类所在的类的对象，如下所示：

//1创建内部类所在类的对象
OuterClass outerObject=new OuterClass();
//2创建内部类对象
//注意与静态嵌套类的构造器使用方法的差异
OuterClass.InnerClass innerObject = outerObject.new InnerClass();
```





## 注解

    注解(Annotation)相当于一种标记，在程序中加入注解就等于为程序打上某种标记，没有加，
    则等于没有任何标记，以后，javac编译器、开发工具和其他程序可以通过反射来了解你的类及各种元素上有无何种标记，
    看你的程序有什么标记，就去干相应的事，标记可以加在包、类，属性、方法，方法的参数以及局部变量上。

### Retention
    　　当在Java源程序上加了一个注解，这个Java源程序要由javac去编译，javac把java源文件编译成.class文件，
    在编译成class时可能会把Java源程序上的一些注解给去掉，java编译器(javac)在处理java源程序时，可能会认为这个注解没有用了，
    于是就把这个注解去掉了，那么此时在编译好的class中就找不到注解了， 这是编译器编译java源程序时对注解进行处理的第一种可能情况，
    假设java编译器在把java源程序编译成class时，没有把java源程序中的注解去掉，那么此时在编译好的class中就可以找到注解，当程序
    使用编译好的class文件时，需要用类加载器把class文件加载到内存中，class文件中的东西不是字节码，class文件里面的东西由类加载器
    加载到内存中去，类加载器在加载class文件时，会对class文件里面的东西进行处理，如安全检查，处理完以后得到的最终在内存中的二进制的
    东西才是字节码，类加载器在把class文件加载到内存中时也有转换，转换时是否把class文件中的注解保留下来，这也有说法，所以说一个注解
    的生命周期有三个阶段：java源文件是一个阶段，class文件是一个阶段，内存中的字节码是一个阶段,javac把java源文件编译成.class文件时，
    有可能去掉里面的注解，类加载器把.class文件加载到内存时也有可能去掉里面的注解，因此在自定义注解时就可以使用Retention注解指明自定义
    注解的生命周期，自定义注解的生命周期是在RetentionPolicy.SOURCE阶段(java源文件阶段)，还是在RetentionPolicy.CLASS阶段(class文件阶段)，
    或者是在RetentionPolicy.RUNTIME阶段(内存中的字节码运行时阶段)，根据JDK提供的API可以知道默认是在RetentionPolicy.CLASS阶段
    (JDK的API写到：the retention policy defaults to RetentionPolicy.CLASS.)


其实从代码的写法上来看，注解更像是一种特殊的接口，注解的属性定义方式就和接口中定义方法的方式一样，而应用了注解的类可以认为是实现了这个特殊的接口
```
java中元注解有四个： @Retention @Target @Document @Inherited；

　　 @Retention：注解的保留位置　　　　　　　　　
　　　　　　@Retention(RetentionPolicy.SOURCE)   //注解仅存在于源码中，在class字节码文件中不包含
　　　　　　@Retention(RetentionPolicy.CLASS)     // 默认的保留策略，注解会在class字节码文件中存在，但运行时无法获得，
　　　　　　@Retention(RetentionPolicy.RUNTIME)  // 注解会在class字节码文件中存在，在运行时可以通过反射获取到
　　
　　@Target:注解的作用目标
　　　　　　　　
　　　　　　　　@Target(ElementType.TYPE)   //接口、类、枚举、注解
　　　　　　　　@Target(ElementType.FIELD) //字段、枚举的常量
　　　　　　　　@Target(ElementType.METHOD) //方法
　　　　　　　　@Target(ElementType.PARAMETER) //方法参数
　　　　　　　　@Target(ElementType.CONSTRUCTOR)  //构造函数
　　　　　　　　@Target(ElementType.LOCAL_VARIABLE)//局部变量
　　　　　　　　@Target(ElementType.ANNOTATION_TYPE)//注解
　　　　　　　　@Target(ElementType.PACKAGE) ///包

     @Document：说明该注解将被包含在javadoc中

　  @Inherited：说明子类可以继承父类中的该注解
```

### 序列化
    serialVersionUID适用于java序列化机制。简单来说，JAVA序列化的机制是通过判断类的serialVersionUID来验证的版本一致的。
    在进行反序列化时，JVM会把传来的字节流中的serialVersionUID于本地相应实体类的serialVersionUID进行比较。
    如果相同说明是一致的，可以进行反序列化，否则会出现反序列化版本一致的异常，即是InvalidCastException。
    
    区分同一个类的不同版本


### 对象比较
* 自己构造类的时候，实现 comparable 接口
* 我们设计类的时候，可能没有考虑到让类实现Comparable接口，需要用到另外的一个比较器接口 Comparator。对于本身不能进行排序的对象，
又不能修改对象本身，可写一个构造器进行排序


### java8 default关键字
    default是在java8中引入的关键字，也可称为Virtual
    extension methods——虚拟扩展方法。是指，在接口内部包含了一些默认的方法实现（也就是接口中可以包含方法体，
    这打破了Java之前版本对接口的语法限制），从而使得接口在进行扩展的时候，不会破坏与接口相关的实现类代码。
#### 为什么要有这个特性？
    首先，之前的接口是个双刃剑，好处是面向抽象而不是面向具体编程，缺陷是，当需要修改接口时候，需要修改全部实现该接口的类，
    目前的java8之前的集合框架没有foreach方法，通常能想到的解决办法是在JDK里给相关的接口添加新的方法及实现。
    然而，对于已经发布的版本，是没法在给接口添加新方法的同时不影响已有的实现。所以引进的默认方法。
    他们的目的是为了解决接口的修改与现有的实现不兼容的问题。









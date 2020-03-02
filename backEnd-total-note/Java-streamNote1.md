## stream流操作
流的操作类型分为两种：
Intermediate：一个流可以后面跟随零个或多个 intermediate 操作。其目的主要是打开流，
做出某种程度的数据映射/过滤，然后返回一个新的流，交给下一个操作使用。这类操作都是
惰性化的（lazy），就是说，仅仅调用到这类方法，并没有真正开始流的遍历。
Terminal：一个流只能有一个 terminal 操作，当这个操作执行后，流就被使用“光”了，
无法再被操作。所以这必定是流的最后一个操作。Terminal 操作的执行，才会真正开始流的遍历，
并且会生成一个结果，或者一个 side effect。

简单说，对 Stream 的使用就是实现一个 filter-map-reduce 过程，产生一个最终结果

```
构造流的几种常用的方法
// 1. Individual values
Stream stream = Stream.of("a", "b", "c");
// 2. Arrays
String [] strArray = new String[] {"a", "b", "c"};
stream = Stream.of(strArray);
stream = Arrays.stream(strArray);
// 3. Collections
List<String> list = Arrays.asList(strArray);
stream = list.stream();

基本数据类型的包装
IntStream、LongStream、DoubleStream
IntStream.of(new int[]{1, 2, 3}).forEach(System.out::println);

将流转化为其他数据结构
// 1. Array
String[] strArray1 = stream.toArray(String[]::new);
// 2. Collection
List<String> list1 = stream.collect(Collectors.toList());
List<String> list2 = stream.collect(Collectors.toCollection(ArrayList::new));
Set set1 = stream.collect(Collectors.toSet());
Stack stack1 = stream.collect(Collectors.toCollection(Stack::new));
// 3. String
String str = stream.collect(Collectors.joining()).toString();

```

###  map  flatMap
map : 把 input Stream 的每一个元素，映射成 output Stream 的另外一个元素。
map 生成的是个 1:1 映射，每个输入元素，都按照规则转换成为另外一个元素。
还有一些场景，是一对多映射关系的，这时需要 flatMap。

```
// map test
//        List<String> wordList = Arrays.asList("hello", "world");
//        List<String> upperWorldList = wordList.stream().map(String::toUpperCase).collect(Collectors.toList());
//        System.out.println(upperWorldList);

//        List<Integer> nums = Arrays.asList(1, 2, 3, 4);
//        List<Integer> squareNum = nums.stream().map(item -> item * item).collect(Collectors.toList());
//        System.out.println(squareNum);

// flatMap Test
//        Stream<List<Integer>> inputStream = Stream.of(Arrays.asList(1,2), Arrays.asList(3,4), Arrays.asList(5,6));
//        Stream<Integer> outputStream = inputStream.flatMap(childList -> childList.stream());
//        outputStream.forEach(System.out::print);

================================   filter  =====================================
filter 对原始 Stream 进行某项测试，通过测试的元素被留下来生成一个新 Stream。
// filter
int[] nums = {1,2,3,4,5,6};
int[] evenNum = Arrays.stream(nums).filter(item -> item % 2 == 0).toArray();
for (int item : evenNum)
    System.out.println(item);

把单词全部挑出来
    List<String> output = reader.lines().
     flatMap(line -> Stream.of(line.split(REGEXP))).
     filter(word -> word.length() > 0).
     collect(Collectors.toList());

================================   forEach  =====================================
forEach 方法接收一个 Lambda 表达式，然后在 Stream 的每一个元素上执行该表达式。
一般认为，forEach 和常规 for 循环的差异不涉及到性能，它们仅仅是函数式风格与传统 Java 风格的差别

Arrays.asList(1,2,3).stream().forEach( p -> System.out.print(" " + p));
forEach 是 terminal 操作，因此它执行后，Stream 的元素就被“消费”掉了，你无法对一个 Stream 进行两次 terminal 运算。
具有相似功能的 intermediate 操作 peek 可以达到上述目的
List<String> words = Stream.of("one", "two", "three", "four").filter(word -> word.length() > 3).peek(word -> System.out.print(" " + word))
                .map(String::toUpperCase).peek(word -> System.out.print(" " + word)).collect(Collectors.toList());
        System.out.println("================");
        System.out.println(words);

forEach 不能修改自己包含的本地变量值，也不能用 break/return 之类的关键字提前结束循环。


================================   findFirst  =====================================
这是一个 termimal 兼 short-circuiting 操作，它总是返回 Stream 的第一个元素，或者空。





================================   reduce  =====================================
这个方法的主要作用是把 Stream 元素组合起来。它提供一个起始值（种子），然后依照运算规则（BinaryOperator），
和前面 Stream 的第一个、第二个、第 n 个元素组合。从这个意义上说，字符串拼接、
数值的 sum、min、max、average 都是特殊的 reduce。
没有设初始值的时候，返回的是optional对象，此时可以使用get（）操作
此处的方法引用String::concat 方法引用，可以理解为lambda表达式的简写形式
System.out.println(Stream.of("a","b","c","d").reduce("",String::concat));
System.out.println(Stream.of("a","b","c","d").reduce(String::concat).get());
System.out.println(Stream.of(1.0,2.0,-1.0,3.0).reduce(Double.MAX_VALUE, Double::min));
System.out.println(Stream.of(1,2,3,4).reduce(Integer::sum).get());
System.out.println(Stream.of(1,2,3,4).filter(p -> p > 2).reduce(Integer::sum).get());

方法引用：



================================   limit / skip  =====================================
limit 返回 Stream 的前面 n 个元素；skip 则是扔掉前 n 个元素（它是由一个叫 subStream 的方法改名而来）。



================================   sorted  =====================================
对 Stream 的排序通过 sorted 进行，它比数组的排序更强之处在于你可以首先对 Stream 进行各
类 map、filter、limit、skip 甚至 distinct 来减少元素数量后，再排序，这能帮助程序明显缩短执行时间。
public static void testSorted() {
    List<Person> people = new ArrayList<>();
    for (int i=1; i <= 5; ++i) {
        people.add(new Person(i, "name" + i));
    }
    people.stream().limit(2).sorted((a, b) -> a.getName().compareTo(b.getName())).forEach(item -> System.out.print(" " +item.getName()));
}


自己生成流
iterate
iterate 跟 reduce 操作很像，接受一个种子值，和一个 UnaryOperator（例如 f）。然后种子值
成为 Stream 的第一个元素，f(seed) 为第二个，f(f(seed)) 第三个，以此类推

```

## Lambda表达式的语法
```
lambda表达式的一般语法
(Type1 param1, Type2 param2, ..., TypeN paramN) -> {
  statment1;
  statment2;
  //.............
  return statmentM;
}

1.1.2单参数语法
param1 -> {
  statment1;
  statment2;
  //.............
  return statmentM;
}
当lambda表达式的参数个数只有一个，可以省略小括号
param1 -> statment  当lambda表达式只包含一条语句时，可以省略大括号、return和语句结尾的分号

基本语法: (parameters) -> expression 或 (parameters) ->{ statements; }
Lambda表达式本质上是一个匿名方法

// 1. 不需要参数,返回值为 5
() -> 5

// 2. 接收一个参数(数字类型),返回其2倍的值
x -> 2 * x

// 3. 接受2个参数(数字),并返回他们的差值
(x, y) -> x – y

// 4. 接收2个int型整数,返回他们的和
(int x, int y) -> x + y

// 5. 接受一个 string 对象,并在控制台打印,不返回任何值(看起来像是返回void)
(String s) -> System.out.print(s)

// 1.1 使用匿名内部类根据 name 排序 players
/*        Arrays.sort(atp, new Comparator<String>() {
    @Override
    public int compare(String o1, String o2) {
        return (o1.compareTo(o2));
    }
});*/

// 1.2 使用 lambda expression 排序 players
Comparator<String> sortByName = (String s1, String s2) -> (s1.compareTo(s2));
Arrays.sort(players, sortByName);

// 1.2 lambda expression
Arrays.sort(atp, (String a, String b) -> (a.compareTo(b)));



========================    具体实例  ===============================
System.out.println("给程序员加薪 5% :");
Consumer<Person> giveRaise = e -> e.setSalary(e.getSalary() / 100 * 5 + e.getSalary());

javaProgrammers.forEach(giveRaise);
phpProgrammers.forEach(giveRaise);


=======================  重新定义过滤器  ============================
// 定义 filters
Predicate<Person> ageFilter = (p) -> (p.getAge() > 25);
Predicate<Person> salaryFilter = (p) -> (p.getSalary() > 1400);
Predicate<Person> genderFilter = (p) -> ("female".equals(p.getGender()));

System.out.println("下面是年龄大于 24岁且月薪在$1,400以上的女PHP程序员:");
phpProgrammers.stream()
          .filter(ageFilter)
          .filter(salaryFilter)
          .filter(genderFilter)
          .forEach((p) -> System.out.printf("%s %s; ", p.getFirstName(), p.getLastName()));

// 重用filters
System.out.println("年龄大于 24岁的女性 Java programmers:");
javaProgrammers.stream()
          .filter(ageFilter)
          .filter(genderFilter)
          .forEach((p) -> System.out.printf("%s %s; ", p.getFirstName(), p.getLastName()));

```

**用在多线程中**

我们首先看一个java实现多线程的lambda表达式的例子
```
Runnable runnable = new Runnable(){
            @Override
            public void run() {
                System.out.println("多线程");
            }};

lambda形式
Runnable runnable = () -> {
            System.out.println("多线程");
        };

简洁
此方法使用的场景只能是实现的方法中只有一行语句。

Runnable runnable = () -> System.out.println("多线程");
```

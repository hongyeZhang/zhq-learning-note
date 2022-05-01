# 《C++ prime plus 第六版》



 
## 5-Chapter5 循环和关系表达式
* 不能用关系运算符来比较字符串，但是可以用来比较字符。字符串的比较 #include <cstring>  里面的 strcmp() 函数，主要是用来比较 C 风格的字符串。 string 类对象的字符串是可以直接比较的，因为对运算符进行了重载

* 基于范围的for循环
```cpp
#include <iostream>

using namespace std;

int main(void)
{
    double prices[5] = {1.23, 2.22, 3.33, 4.44, 5.55};
    for (double price : prices)
    {
        cout << price << endl;
    }
    // 改变 price 的值
    for (double &price : prices)
    {
        price *= 2;
        cout << price << endl;
    }
    return 0;
}
```

## 6-Chapter6 分支语句和逻辑语句
* 没啥可以记录的

## 7-Chapter7 函数--C++的编程模块
* 要提高编程效率，可更深入的学习 STL 和 BOOST C++ 提供的功能
* 函数原型：复制函数定义的函数头，将参数的变量名去掉，提供类型列表即可。
* C++ 按值传递参数。将数组名解释为第一个元素的地址 cookies = &cookies[0]。
* 将指针作为函数参数传递时，可以使用指向 const 的指针来保护数据。
* 函数指针 ：指向函数的指针
```cpp
arr[i] == *(ar + i);
&arr[i] == ar + i;

voif f_modify(double arr[], int n);
// 如果函数不修改输入的数组，则入参应该声明为 const
void f_no_change(const double arr[], int n);

// 数组求和的两种子函数方式： arr[] 和 两个指针
int sumArr(int *arr, int n)
{
    int sum = 0;
    for (int i = 0; i < n; ++i)
    {
        sum += arr[i];
    }
    return sum;
}

int sumArr2(const int *begin, const int *end)
{
    int sum = 0;
    const int *pt;
    for (pt = begin; pt != end; ++pt)
    {
        sum += *pt;
    }
    return sum;
}

int age = 29;
// *pt 的值为 const， 不能修改
const int *pt = &age;

int sloth = 3;
// a pointer to const int
const int * pt = &sloth;
// a const pointer to int 
int * const pt = &sloth;


```


## 8-Chapter8 函数探幽
* 内联函数(inline) ：省略原型，将整个定义（函数头+函数代码）放在本应提供原型的地方
* 引用：必须在声明引用时将其初始化，不能像指针那样，先声明，再赋值。分为左值引用和右值引用
* 尽可能的使用const,可以避免无意中修改数据的编程错误，能够同时处理const和 非const的实参；
* 函数传参使用引用的好处：不用复制参数的结构和数据，能够节省时间和内存
* 函数重载：关键是函数的参数列表（特征标）要不相同。
* 函数模板：提供一种通用的处理方法，由编译器根据不同的参数生成不同的函数。如果存在多个原型，则编译器在选择原型时，非模板版本优先于模板版本和显式具体化版本。显式实例化、隐式实例化

```cpp
#include <iostream>

using namespace std;

// 函数模板的使用例子,将 typename 换成 class 也可以，兼容以前的C++98老版本
template <typename T>
void swapNum(T &a, T &b);

int main(void)
{
    int a = 3, b = 5;
    swapNum(a, b);
    cout << "a=" << a << " b=" << b << endl;

    double c = 4.5, d = 7.6;
    swapNum(c, d);
    cout << "c=" << c << " d=" << d << endl;
}

template <typename T>
void swapNum(T &a, T &b)
{
    T tmp = a;
    a = b;
    b = tmp;
}

```


## 9-Chapter9 内存模型和名称空间
### 9.1 存储持续性、作用域、链接性
* 存储持续性：自动存储持续性、静态存储持续性、线程存储持续性、动态存储持续性。
* auto 关键字用于自动类型推断。如果要在多个文件中使用外部变量，只需要在一个文件中包含该变量的定义，在其他文件中用 extern 声明即可。
* 部分说明符和限定符：auto register static extern thread_local mutable 
* new 负责在堆中找到一个能够满足要求的内存块。可以在指定的内存块上分配内存
### 9.2 命名空间
* using声明：是一个名称可用 + using编译指令：使所有的名称可用。尽量使用名称空间，减少使用编译指令。


## 10-Chapter10 对象和类
* 类与结构体的区别，除了有数据之外，还有操作数据的方法
* 方法可以访问类的私有成员。定义位于类生命中的函数是内联函数


## 12-Chapter12 类和动态内存分配
* new 和 delete 操作符
* 

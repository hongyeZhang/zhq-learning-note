# 《Python学习笔记》

## 基础知识
### 基本的数据类型 
* Numbers（数字）
* String（字符串）
* List（列表）
* Tuple（元组）
* Dictionary（字典）


### 面向对象

#### 函数入参
*参数与**参数是Python参数中的重点知识，他们都被称为可变参数（任意参数），我们经常会在代码中看到*args、**kwargs
作为函数定义时：
1、*参数收集所有未匹配的位置参数组成一个tuple对象，局部变量args指向此tuple对象
2、**参数收集所有未匹配的关键字参数组成一个dict对象，局部变量kwargs指向此dict对象



### 常用包总结
### os 
* os就是提供了一些方便使用操作系统相关功能的函数




list和tuple是Python内置的有序集合，一个可变，一个不可变

========================   函数式编程    =======================================
函数式编程就是一种抽象程度很高的编程范式，纯粹的函数式编程语言编写的函数没有变量，因此，任意一个函数，只要输入是确定的，输出就是确定的，这种纯函数我们称之为没有副作用。而允许使用变量的程序设计语言，由于函数内部的变量状态不确定，同样的输入，可能得到不同的输出，因此，这种函数是有副作用的。
函数式编程的一个特点就是，允许把函数本身作为参数传入另一个函数，还允许返回一个函数！
Python对函数式编程提供部分支持。由于Python允许使用变量，因此，Python不是纯函数式编程语言。

函数名也是变量
函数名是什么呢？函数名其实就是指向函数的变量！对于abs()这个函数，完全可以把函数名abs看成变量，它指向一个可以计算绝对值的函数！
f = bas
print(f(-10))

传递的参数可以是函数，此时的add即为高阶函数
def add(x, y, f):
    return f(x) + f(y)
print(add(-5, 6, abs))

(1) map函数，f依次作用于迭代器
        def f(x):
            return x*x
        inputList = list(range(10))
        outputList = list(map(f, inputList))
        print(outputList)

(2) reduce函数：把一个函数作用在一个序列[x1, x2, x3, ...]上，这个函数必须接收两个参数，
reduce把结果继续和序列的下一个元素做累积计算，其效果就是： reduce(f, [x1, x2, x3, x4]) = f(f(f(x1, x2), x3), x4)
from functools import reduce

将str转化为int
DIGITS = {'0': 0, '1': 1, '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7, '8': 8, '9': 9}
def str2int(s):
    def fn(x, y):
        return x * 10 + y
    def char2num(s):
        return DIGITS[s]
    return reduce(fn, map(char2num, s))


    def calc_sum(*args):
        sum = 0
        for arg in args:
            sum = sum + arg
        return sum
    print(calc_sum(1, 2, 3, 4))

    def lazy_sum(*args):
        def sum():
            ax = 0
            for n in args:
                ax = ax + n
            return ax
        return sum
    当我们调用lazy_sum()时，返回的并不是求和结果，而是求和函数：
    >>> f = lazy_sum(1, 3, 5, 7, 9)
    >>> f
    <function lazy_sum.<locals>.sum at 0x101c6ed90>
    调用函数f时，才真正计算求和的结果：
    >>> f()
    25
    在这个例子中，我们在函数lazy_sum中又定义了函数sum，并且，内部函数sum可以引用外部函数lazy_sum的参数和局部变量，
    当lazy_sum返回函数sum时，相关参数和变量都保存在返回的函数中，这种称为“闭包（Closure）”的程序结构拥有极大的威力。

匿名函数：
匿名函数有个限制，就是只能有一个表达式，不用写return，返回值就是该表达式的结果。
list1 = list(map(lambda x: x*x, [1,2,3,4,5]))
f = lambda x: x * x
print(f(5))

def now():
    print("2018-12-09")
print(now.__name__)

==============================      模块      ==================================

作用域
在一个模块中，我们可能会定义很多函数和变量，但有的函数和变量我们希望给别人使用，有的函数和变量我们希望仅仅在模块内部使用。在Python中，是通过_前缀来实现的。
正常的函数和变量名是公开的（public），可以被直接引用，比如：abc，x123，PI等；
类似__xxx__这样的变量是特殊变量，可以被直接引用，但是有特殊用途，比如上面的__author__，__name__就是特殊变量，hello模块定义的文档注释也可以用特殊变量__doc__访问，我们自己的变量一般不要用这种变量名；
类似_xxx和__xxx这样的函数或变量就是非公开的（private），不应该被直接引用，比如_abc，__abc等；
之所以我们说，private函数和变量“不应该”被直接引用，而不是“不能”被直接引用，是因为Python并没有一种方法可以完全限制访问private函数或变量，但是，从编程习惯上不应该引用private函数或变量。
private函数或变量不应该被别人引用，那它们有什么用呢？请看例子：
def _private_1(name):
    return 'Hello, %s' % name

def _private_2(name):
    return 'Hi, %s' % name

def greeting(name):
    if len(name) > 3:
        return _private_1(name)
    else:
        return _private_2(name)

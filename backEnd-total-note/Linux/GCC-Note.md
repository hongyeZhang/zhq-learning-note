
# GCC 学习笔记
## 基础
* GCC (GNU Compiler Collection) 为 GNU 操作系统专门编写的编译器。
* 预处理(Preprocessing) -> 编译(compilation) -> 汇编(assembly) -> 连接(linking)
    * 预处理器 cpp ：头文件展开，展开宏，去掉注释
    * 编译器 gcc ：将C程序编译成汇编程序
    * 汇编器 as ：将汇编文件变为二进制文件
    * 链接器 ld ：将相应的代码组合到目标文件中

* 基本步骤
> 1、预处理,生成 .i 的文件[预处理器cpp]
> 2、将预处理后的文件转换成汇编语言, 生成文件 .s [编译器egcs]
> 3、有汇编变为目标代码(机器代码)生成 .o 的文件[汇编器as]
> 4、连接目标代码, 生成可执行程序 [链接器ld]

* 基本语法格式
> gcc [参数] 待编译的文件 [参数] [目标文件]
> -c 只激活预处理,编译,和汇编,也就是他只把程序做成obj文件
> -S 只激活预处理和编译，就是指把文件编译成为汇编代码。
> -o 制定目标名称, 默认的时候, gcc 编译出来的文件是 a.out
> -g 编译时加入调试信息，方便gdb 的调试




## 基本命令

```shell
# 查看版本
gcc -v

# 将test.c预处理、汇编、编译并链接形成可执行文件。这里未指定输出文件，默认输出为a.out
gcc test.c
# 将test.c预处理、汇编、编译并链接形成可执行文件test。-o选项用来指定输出文件的文件名。
gcc test.c -o test


# 多个文件一起编译,将testfun.c和test.c分别编译后链接成test可执行文件
gcc testfun.c test.c -o test



# 分别编译各个源文件，之后对编译后输出的目标文件链接。
#gcc -c testfun.c //将testfun.c编译成testfun.o
#gcc -c test.c   //将test.c编译成test.o
# 将testfun.o和test.o链接成test
gcc -o testfun.o test.o -o test 

gcc -g test.c -o mytest



```


## Makefile
* 自动化编译脚本








# GDB学习笔记


## 基础知识
* GDB 全称“GNU symbolic debugger”，它诞生于 GNU 计划（同时诞生的还有 GCC、Emacs 等），是 Linux 下常用的程序调试器。当下的 GDB 支持调试多种编程语言编写的程序，包括 C、C++、Go、Objective-C、OpenCL、Ada等。实际场景中，GDB 更常用来调试 C 和 C++程序



## 调试命令
* https://zhuanlan.zhihu.com/p/357360607
* https://www.cnblogs.com/gqtcgq/p/7511974.html

> gdb -v  看版本
gdb test -q      <-- 启动gdb进行调试
(gdb) l            <-- 显示带行号的源代码，默认情况下，l 选项只显示 10 行源代码，如果查看后续代码，按 Enter 回车键即可
(gdb) b 7          <-- 在第7行源代码处打断点
(gdb) r            <-- 运行程序，遇到断点停止
(gdb) print n      <-- 查看代码中变量 n 的值
(gdb) n            <-- 单步执行程序
(gdb) c            <-- 继续执行程序
(gdb) q            <-- 退出调试


* 查看源代码和输出
> list ：简记为 l ，其作用就是列出程序的源代码，默认每次显示10行。
list 行号：将显示当前文件以“行号”为中心的前后10行代码，如：list 12
list 函数名：将显示“函数名”所在函数的源代码，如：list main
print 表达式：简记为 p ，其中“表达式”可以是任何当前正在被测试程序的有效表达式，比如当前正在调试C语言的程序，那么“表达式”可以是任何C语言的有效表达式，包括数字，变量甚至是函数调用。
print a：将显示整数 a 的值
print/x <my_var> 用16进制表示var
i r rax: 表示rax寄存器的值
i r：表示所有寄存器的值
layout src：显示源代码窗口
layout asm：显示反汇编窗口


* 【启动程序】 默认情况下，run 指令会一直执行程序，直到执行结束。如果程序中手动设置有断点，则 run指令会执行程序至第一个断点处；start 指令会执行程序至main()主函数的起始位置，即在main()函数的第一行语句处停止执行（该行代码尚未执行）。

* 【print命令】它的功能就是在 GDB 调试程序的过程中，输出或者修改指定变量或者表达式的值。print 命令可以缩写为 p，最常用的语法格式如下所示：
    > (gdb) print num
    (gdb) p num

* 【step命令】通常情况下，step 命令和next命令的功能相同，都是单步执行程序。不同之处在于，当step 命令所执行的代码行中包含函数时，会进入该函数内部，并在函数第一行代码处停止执行。
step 命令可以缩写为 s命令




# Shell 学习

## 参考学习资料
* 参考学习资料
    * 千锋 Shell 脚本自动化编程
    * 基础命令查询 + 基本笔记 : 菜鸟教程 https://www.runoob.com/linux/linux-shell.html

## chapter1 shell 作用
* 自动化批量系统初始化程序 (update、软件安装、时区设置)
* 批量软件部署(LAMP LNMP Tomcat LVS Nginx)
* zabbix 信息采集等

## 基础知识
* Shell 的分类
    * 默认的shell ： /bin/bash、csh ksh tcsh sh  nologin zsh（最庞大的）

```bash
# 自动补全的命令
yum -y install bash-completion
# 历史命令记忆
history n 
# ！+ 命令的序号
! commandNum  


# 添加别名、显示前5行、取消别名（临时生效），将别名添加到系统 .bashrc 文件中永久生效
alias h5='head -5'
unalias h5 
cat /etc/passwd | head -5 


```

## chapter2 bash的初始化
* bash环境变量文件的加载
    * /etc/profile 全局公有配置，所有用户登录时都会读取该文件
    * /etc/bashrc 全局配置文件，centos中，ubuntu 没有
    * ~/.profile 
    * ~/.bash_login
    * ~/.bash_profile
    * ~/.bashrc
    * ~/.bash_logout

* bash 快捷键
> ctrl + a 
ctrl + c  强制终止当前命令
ctrl + d 退出当前终端
Ctrl + z 暂停并放入后台

* 前后台作业控制: 也是前后台进程，有对应的 pid
    * 前台作业：用户可以参与及控制的
    * 后台作业：内存中自由运行，用户无法参与或者ctrl+c来终止的

> command + & 后台运行
ctrl + z 将当前的命令切换到后台
jobs 查看后台的作业状态
fg %n 将后台运行的作业n切换到前台
bg %n 让指定的作业n在后台运行
kill %n 将指定的作业杀死

## chapter7 输入、输出重定向
* 硬件设备和文件描述符 
    * 0 stdin 标准输入文件  键盘
    * 1 stdout 标准输出文件  显示器
    * 2 stderr 标准错误输出文件  显示器
 
### 7.1 输出重定向
> command >file 以覆盖的方式，将 command 的正确输出结果输出到 file 文件中
command >>file  以追加的方式
command 2>file  将错误信息输出
command >file 2>&1  覆盖方式，将正确和错误信息都保存到同一个文件中
command >file1 2>file2  正确的覆盖到 file1，错误的覆盖到 file2

ls / &>/dev/null 将正确和错误的结果都导入到回收站中

### 7.2 输入重定向
> wc -l < readme.txt

```shell 
#!/bin/bash
# 读入文件并打印
while read str; do
	echo $str
done <readme.txt
```

### 7.3 管道
* | tee

> cat /etc/passwd | tee hello.txt


### 7.4 命令排序
* && || 具备逻辑判断功能
* ; 分号可以连接两个命令，不具备判断性，不会形成逻辑上的短路

### 7.5通配符
```shell
ls /etc/???.conf
ls /etc/*.conf
ls file*
```

## chapter8 shell脚本规范
* 第一行需要有 shebang(#!) 指定脚本的解释器
* 脚本调试
> -n 不执行 script，仅检查语法问题
-v 执行 script 前，先将 script 输出到屏幕
-x 
chmod a+x a.sh 给脚本添加执行权限
. test.sh / source test.sh


### 作业脱机管理
* nohup 忽略所有的挂断信号
```shell

nohup ./echo_time.sh
nohup ./echo_time.sh >temp2.log 2>&1 &
```


## chapter11 shell变量
```shell
# 设置、输出、取消变量
dir=`pwd`
echo $dir 
unset dir

echo $PATH


```
* "" 双引号是弱引用  '' 是强引用 `` 反引号等价于 $() 

```shell
touch `date +%F`_file1.txt
touch $(date +%F)_file1.txt

# 变量运算
# 整数运算
expr 1 + 1
expr $a + $b
echo $[5+2]
echo $(($a+$b))
let sum=2+3; echo $sum

# bc 是个任意精度的计算器
echo "2*4" | bc
echo "print 5/2" | python
echo "print(5/2)" | python3

```













#### EOF
EOF本意是 End Of File，表明到了文件末尾。
```
使用格式基本是这样的：
命令 << EOF
内容段
EOF
将“内容段”整个作为命令的输入。
```


#### linux shell 指令 诸如-d, -f, -e之类的判断表达式
```
文件比较运算符
-e filename 	如果 filename存在，则为真 	[ -e /var/log/syslog ]
-d filename 	如果 filename为目录，则为真 	[ -d /tmp/mydir ]
-f filename 	如果 filename为常规文件，则为真 	[ -f /usr/bin/grep ]
-L filename 	如果 filename为符号链接，则为真 	[ -L /usr/bin/grep ]
-r filename 	如果 filename可读，则为真 	[ -r /var/log/syslog ]
-w filename 	如果 filename可写，则为真 	[ -w /var/mytmp.txt ]
-x filename 	如果 filename可执行，则为真 	[ -L /usr/bin/grep ]
filename1-nt filename2 	如果 filename1比 filename2新，则为真 	[ /tmp/install/etc/services -nt /etc/services ]
filename1-ot filename2 	如果 filename1比 filename2旧，则为真 	[ /boot/bzImage -ot arch/i386/boot/bzImage ]
字符串比较运算符 （请注意引号的使用，这是防止空格扰乱代码的好方法）
-z string 	如果 string长度为零，则为真 	[ -z "$myvar" ]
-n string 	如果 string长度非零，则为真 	[ -n "$myvar" ]
string1= string2 	如果 string1与 string2相同，则为真 	[ "$myvar" = "one two three" ]
string1!= string2 	如果 string1与 string2不同，则为真 	[ "$myvar" != "one two three" ]
算术比较运算符
num1-eq num2 	等于	[ 3 -eq $mynum ]
num1-ne num2 	不等于	[ 3 -ne $mynum ]
num1-lt num2 	小于	[ 3 -lt $mynum ]
num1-le num2 	小于或等于	[ 3 -le $mynum ]
num1-gt num2 	大于	[ 3 -gt $mynum ]
num1-ge num2 	大于或等于	[ 3 -ge $mynum ]
```

#### echo
echo命令是内建的shell命令，用于显示变量的值或者打印一行文本。

1.echo命令我们经常使用的选项有两个，一个是-n，表示输出之后不换行。另外一个是-e，
表示对于转义字符按对应的方式处理，假设不加-e那么对于转义字符会按普通字符处理。

2.echo输出时的转义字符
```
\b 表示删除前面的空格
\n 表示换行
\t 表示水平制表符
\v 表示垂直制表符
\c \c后面的字符将不会输出，同一时候，输出完毕后也不会换行
\r 输出回车符（可是你会发现\r前面的字符没有了）
\a 表示输出一个警告声音
```

3.echo中的重定向
能够把内容输出到文件里而不是标准输出


如果你希望查看当前 Linux 的默认 Shell，那么可以输出 SHELL 环境变量：
$ echo $SHELL

对于普通用户，Base shell 默认的提示符是美元符号$；对于超级用户（root 用户），Bash Shell
默认的提示符是井号#。该符号表示 Shell 等待输入命令。

Shell 通过PS1和PS2两个环境变量来控制提示符格式：
PS1 控制最外层命令行的提示符格式。
PS2 控制第二层命令行的提示符格式。

#!/bin/bash
echo "Hello World !"  #这是一条语句
第 1 行的#!是一个约定的标记，它告诉系统这个脚本需要什么解释器来执行，即使用哪一种Shell；
后面的/bin/bash就是指明了解释器的具体位置。
第 2 行的 echo 命令用于向标准输出文件（Standard Output，stdout，一般就是指终端）输出文本。
在.sh文件中使用命令与在终端直接输入命令的效果是一样的。

================================   这个脚本的问题在哪
#!/bin/bash
# Copyright (c) http://c.biancheng.net/shell/
echo "What is your name ?"
read PERSON
echo "Hello, $PERSON"
第 5 行中表示从终端读取用户输入的数据，并赋值给 PERSON 变量。read 命令用来从标准输入文件
（Standard Input，stdin，一般就是指终端）读取用户输入的数据。
第 6 行表示输出变量 PERSON 的内容。注意在变量名前边要加上$，否则变量名会作为字符串的一部分处理。


$ cd demo  #切换到 test.sh 所在的目录
$ chmod +x ./test.sh  #使脚本具有执行权限
$ ./test.sh  #执行脚本

执行未赋予执行权限的sh文件方法：
sh test.sh
source test.sh



脚本语言在定义变量时通常不需要指明类型，直接赋值就可以，Shell 变量也遵循这个规则。
在 Bash shell 中，每一个变量的值都是字符串，无论你给变量赋值时有没有使用引号，值都会以字符串的形式存储。
如果有必要，你也可以使用 declare 关键字显式定义变量的类型，但在一般情况下没有这个需求，Shell 开发者在编写代码时
自行注意值的类型即可。

Shell 支持以下三种定义变量的方式：

variable=value
variable='value'
variable="value"
variable 是变量名，value 是赋给变量的值。如果 value 不包含任何空白符（例如空格、Tab 缩进等），那么可以不使用引号；
如果 value 包含了空白符，那么就必须使用引号包围起来。使用单引号和使用双引号也是有区别的，稍后我们会详细说明。

注意，赋值号=的周围不能有空格，这可能和你熟悉的大部分编程语言都不一样。
使用一个定义过的变量，只要在变量名前面加美元符号$即可

变量名外面的花括号{ }是可选的，加不加都行，加花括号是为了帮助解释器识别变量的边界，比如下面这种情况：
    skill="Java"
    echo "I am good at ${skill}Script"
推荐给所有变量加上花括号{ }，这是个良好的编程习惯。

前面我们还留下一个疑问，定义变量时，变量的值可以由单引号' '包围，也可以由双引号" "包围，它们到底有什么区别呢？不妨以下面的代码为例来说明：

    #!/bin/bash
    url="http://c.biancheng.net"
    website1='C语言中文网：${url}'
    website2="C语言中文网：${url}"
    echo $website1
    echo $website2

运行结果：
C语言中文网：${url}
C语言中文网：http://c.biancheng.net

以单引号' '包围变量的值时，单引号里面是什么就输出什么，即使内容中有变量和命令（命令需要反引起来）也会把它们原样输出。
这种方式比较适合定义显示纯字符串的情况，即不希望解析变量、命令等的场景。
以双引号" "包围变量的值时，输出时会先解析里面的变量和命令，而不是把双引号中的变量名和命令原样输出。
这种方式比较适合字符串中附带有变量和命令并且想将其解析后再输出的变量定义。

Shell 也支持将命令的执行结果赋值给变量，常见的有以下两种方式：

variable=`command`
variable=$(command)
第一种方式把命令用反引号` `（位于 Esc 键的下方）包围起来，反引号和单引号非常相似，容易产生混淆，
所以不推荐使用这种方式；第二种方式把命令用$()包围起来，区分更加明显，所以推荐使用这种方式。

使用 unset 命令可以删除变量。语法：
    unset variable_name
变量被删除后不能再次使用；unset 命令不能删除只读变量。

Shell 变量的作用域可以分为三种：
    有的变量可以在当前 Shell 会话中使用，这叫做全局变量（global variable）；
    有的变量只能在函数内部使用，这叫做局部变量（local variable）；
    而有的变量还可以在其它 Shell 中使用，这叫做环境变量（environment variable）。
在 Shell 中定义的变量，默认就是全局变量。

全局变量的作用范围是当前的 Shell 会话，而不是当前的 Shell 脚本文件，它们是不同的概念。
打开一个 Shell 窗口就创建了一个 Shell 会话，打开多个 Shell 窗口就创建了多个 Shell 会话，
每个 Shell 会话都是独立的进程，拥有不同的进程 ID。在一个 Shell 会话中，可以执行多个 Shell
脚本文件，此时全局变量在这些脚本文件中都有效。



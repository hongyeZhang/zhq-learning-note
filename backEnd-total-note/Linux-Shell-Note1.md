

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

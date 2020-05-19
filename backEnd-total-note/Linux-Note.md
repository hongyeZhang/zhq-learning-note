# Linux 常用命令


### 帮助查看
* 内部命令与外部命令
    - 在linux系统中有存储位置的命令为外部命令；
    - 没有存储位置的为内部命令，可以理解为内部命令嵌入在linux的shell中，所以看不到。
    - type来判断到底为内部命令还是内部命令

* 内部命令
    - help cd
* 大多数外部命令都可以使用--help来获取帮助，如果这个命令没有--help选项，则会显示简单的命令 格式   命令字  --help
    - date --help     //日期帮助
* man命令
    - man rm                 //常用写法
    - man passwd

```shell
[root@localhost ~]# type help    //查看help命令的内外类型
help is a shell builtin        //可以看到help为内部命令
[root@localhost ~]# type passwd    //查看passwd这条命令是否在linux系统中存在
passwd is /usr/bin/passwd          //可以看到passwd的存储位置，因此存在，为外部命令
[root@localhost ~]# type cd
cd is a shell builtin
//那么passwd即为外部命令，那么cd为内部命令
```



## 系统操作

### df
* df命令的功能是用来检查linux服务器的文件系统的磁盘空间占用情况。可以利用该命令来获取硬盘被占用了多少空间，
    目前还剩下多少空间等信息。显示指定磁盘文件的可用空间。
    - df -h 以易读的方式显示目前磁盘空间和使用情况。
    - df -i 以inode模式来显示磁盘使用情况。
    - df -h   去删除比较大无用的文件-----------大文件占用大量的磁盘容量。
    - df -i   去删除数量过多的小文件-----------过多的文件占用了大量的inode号。
    
### source
* source /etc/profile命令可以使新建立的环境变量立刻生效而不用重新启动系统,该命令通常用命令“.”来替代。
* source命令用法  source FileName
* 使用：
 - source filename
 - . filename #（中间有空格）

### nohup
* nohup 命令运行由 Command参数和任何相关的 Arg参数指定的命令，忽略所有挂断（SIGHUP）信号。要运行后台中的 nohup 命令，添加 & （ 表示“and”的符号）到命令的尾部。
    nohup 是 no hang up 的缩写，就是不挂断的意思。在缺省情况下该作业的所有输出都被重定向到一个名为 nohup.out 的文件


* nohup command > myout.file 2>&1 &
    - 0 – stdin (standard input)，1 – stdout (standard output)，2 – stderr (standard error) 
    - 2>&1是将标准错误（2）重定向到标准输出（&1），标准输出（&1）再被重定向输入到myout.file文件中。
* nohup和&的区别
    - & ： 指在后台运行
    - nohup ： 不挂断的运行，注意并没有后台运行的功能，就是指用nohup运行命令可以使命令永久的执行下去，和用户终端没有关系，
    - 例如我们断开SSH连接都不会影响他的运行，注意了nohup没有后台运行的意思；&才是后台运行
    - &是指在后台运行，但当用户推出(挂起)的时候，命令自动也跟着退出
    - nohup COMMAND &  这样就能使命令永久的在后台执行

### ps
* ps命令能够给出当前系统中进程的快照。它能捕获系统在某一事件的进程状态。
* 显示所有当前进程.使用 -a 参数。-a 代表 all。同时加上x参数会显示没有控制终端的进程。
    - ps -ax
    - ps -ax | less
* 根据 CPU 使用来升序排序
    - ps -aux --sort -pcpu | less
* 根据 内存使用 来升序排序
    - ps -aux --sort -pmem | less
* 通过进程名和PID过滤
    - 使用 -C 参数，后面跟你要找的进程的名字。比如想显示一个名为getty的进程的信息，就可以使用下面的命令：
    - $ ps -C getty
    - 如果想要看到更多的细节，我们可以使用-f参数来查看格式化的信息列表
    - $ ps -f -C getty  





### 环境变量
* 查看PATH：echo $PATH
* 以添加mongodb server为列
    * 修改方法一：
        - export PATH=/usr/local/mongodb/bin:$PATH
        - //配置完后可以通过echo $PATH查看配置结果。
        - 生效方法：立即生效
        - 有效期限：临时改变，只能在当前的终端窗口中有效，当前窗口关闭后就会恢复原有的path配置
        - 用户局限：仅对当前用户
    
    * 修改方法二：
        - 通过修改.bashrc文件:vim ~/.bashrc
        - //在最后一行添上：
        - export PATH=/usr/local/mongodb/bin:$PATH
        - 生效方法：（有以下两种）
        - 1、关闭当前终端窗口，重新打开一个新终端窗口就能生效
        - 2、输入“source ~/.bashrc”命令，立即生效
        - 有效期限：永久有效
        - 用户局限：仅对当前用户
    
    * 修改方法三:
        - 通过修改profile文件: vim /etc/profile
        - //找到设置PATH的行，添加  export PATH=/usr/local/mongodb/bin:$PATH
        - 生效方法：系统重启
        - 有效期限：永久有效
        - 用户局限：对所有用户
    
    * 修改方法四:
        - 通过修改environment文件: vim /etc/environment
        - 在PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"中加入“:/usr/local/mongodb/bin”
        - 生效方法：系统重启
        - 有效期限：永久有效
        - 用户局限：对所有用户



## 文件操作

### 文件权限
* ls -l xxx.xxx （xxx.xxx是文件名）查看的是xxx文件之中的文件权限
    - 十位数字
    - 【1】：类型
    - 【2-4】：所有者（user）权限
    - 【5-7】：组群（group）权限
    - 【8-10】：其他人（other）权限
    - r 表示文件可以被读（read）
    - w 表示文件可以被写（write）
    - x 表示文件可以被执行（如果它是程序的话）
    - - 表示相应的权限还没有被授予
    - r ------------4
    - w -----------2
    - x ------------1
    - - ------------0
    - rw------- (600) 只有所有者才有读和写的权限
    - rw-r--r-- (644) 只有所有者才有读和写的权限，组群和其他人只有读的权限
    - rwx------ (700) 只有所有者才有读，写，执行的权限
    - rwxr-xr-x (755) 只有所有者才有读，写，执行的权限，组群和其他人只有读和执行的权限
    - rwx--x--x (711) 只有所有者才有读，写，执行的权限，组群和其他人只有执行的权限
    - rw-rw-rw- (666) 每个人都有读写的权限
    - rwxrwxrwx (777) 每个人都有读写和执行的权限



* 改变文件的权限操作
    - chmod [options] mode files
    - 只能文件属主或特权用户才能使用该功能来改变文件存取模式。mode可以是数字形式或以who opcode permission形式表示。
    - who是可选的，默认是a(所有用户)。只能选择一个opcode(操作码)。可指定多个mode，以逗号分开。
    - -c，--changes 只输出被改变文件的信息
    - -f，--silent，--quiet 当chmod不能改变文件模式时，不通知文件的用户
    - --help 输出帮助信息。
    - -R，--recursive 可递归遍历子目录，把修改应到目录下所有文件和子目录
    - --reference=filename 参照filename的权限来设置权限
    - -v，--verbose 无论修改是否成功，输出每个文件的信息

```
$ chmod u+x file                　　　   给file的属主增加执行权限
$ chmod 751 file                　　　   给file的属主分配读、写、执行(7)的权限，给file的所在组分配读、执行(5)的权限，给其他用户分配执行(1)的权限
$ chmod u=rwx,g=rx,o=x file      上例的另一种形式
$ chmod =r file                 　　　　为所有用户分配读权限
$ chmod 444 file              　　　　 同上例
$ chmod a-wx,a+r   file   　　 　   同上例
$ chmod -R u+r directory       　   递归地给directory目录下所有文件和子目录的属主分配读的权限
$ chmod 4755                          　　设置用ID，给属主分配读、写和执行权限，给组和其他用户分配读、执行的权限。
```



### makedir
mkdir [-p] dirName -p 确保目录名称存在，不存在的就建一个。

### mv
* 用来移动文件或者将文件改名（move (rename) files）
* 命令格式：mv [选项] 源文件或目录 目标文件或目录
    - 视mv命令中第二个参数类型的不同（是目标文件还是目标目录），mv命令将文件重命名或将其移至一个新的目录中。
    - 当第二个参数类型是文件时，mv命令完成文件重命名。
    - 当第二个参数是已存在的目录名称时，源文件或目录参数可以有多个，mv命令将各参数指定的源文件均移至目标目录中。
* 命令参数
    -b ：若需覆盖文件，则覆盖前先行备份。
    -f ：force 强制的意思，如果目标文件已经存在，不会询问而直接覆盖；
    -i ：若目标文件 (destination) 已经存在时，就会询问是否覆盖！
    -u ：若目标文件已经存在，且 source 比较新，才会更新(update)
    -t ：该选项适用于移动多个源文件到一个目录的情况，此时目标目录在前，源文件在后。

### rm
* 删除文件夹：rm -rf <directoryName> 递归删除，不管级联基层，一并删除
* rm -i <fileName>  删除文件之前显示确认
* rm -r 删除目录
* rm cms-*  删除所有以cms开头的文件


### grep

* grep (global search regular expression(RE) and print out the line,全面搜索正则表达式并把行打印出来)
    是一种强大的文本搜索工具，它能使用正则表达式搜索文本，并把匹配的行打印出来。

* 输出附近的几行
    - grep -C 5 foo file 显示file文件里匹配foo字串那行以及上下5行
    - grep -B 5 foo file 显示foo及前5行
    - grep -A 5 foo file 显示foo及后5行
* 使用选项 -R, -r, --recursive 会递归指定目录下的所有文件，并匹配其内容：
    - grep -r 'world' ~/projects/
* Grep 默认的匹配规则区分字符的大小写，使用选项 -i (小写字母i), --ignore-case 会在匹配中忽略字符大小写
    - grep -i 'hello' email1
* Grep 默认会输出匹配到的内容所在的整个行，使用选项 -o, --only-matching 则只输出匹配到的内容
    - echo "abc 123 test" | grep -o '[0-9]\{1,3\}'
* grep -v 反向查找
    - grep -v grep 就是查找不含有 grep 字段的行

### 管道
* 管道符是一个神奇的工具，它可以轻易地连接两个毫不相关的程序，把一个程序的结果交给另一个来处理，甚至，不停地交接处理。
    - ps –ef |grep  python
    - Ps是linux中非常强大的进程查看工具，其中-e为显示所有进程，-f为全格式显示。

* 输出重定向
    - Linux输出重定向 > 和 >> 区别如下：
        - >> 追加文件，也就是如果文件里面有内容会把新内容追加到文件尾。
        - >  是定向输出到文件，如果文件不存在，就创建文件；如果文件存在，就将其清空。


### less
* less 工具也是对文件或其它输出进行分页显示的工具，应该说是linux正统查看文件内容的工具，功能极其强大。
    less 与 more 类似，但使用 less 可以随意浏览文件，而 more 仅能向前移动，却不能向后移动，而且 less 在查看之前不会加载整个文件。
    * -b 《缓冲区大小》 设置缓冲区的大小
    * -e 当文件显示结束后，自动离开
    * -f 强迫打开特殊文件，例如外围设备代号、目录和二进制文件
    * -g 只标志最后搜索的关键词
    * -i 忽略搜索时的大小写
    * -m 显示类似more命令的百分比
    * -N 显示每行的行号
    * -o 《文件名》 将less 输出的内容在指定文件中保存起来
    * -Q 不使用警告音
    * -s 显示连续空行为一行
    * -S 行过长时间将超出部分舍弃
    * -x 《数字》 将“tab”键显示为规定的数字空格
    * /字符串：向下搜索“字符串”的功能
    * ？字符串：向上搜索“字符串”的功能
    * n：重复前一个搜索（与 / 或 ？ 有关）
    * N：反向重复前一个搜索（与 / 或 ？ 有关）
    * b 向后翻一页
    * d 向后翻半页
    * h 显示帮助界面
    * Q 退出less 命令
    * u 向前滚动半页
    * y 向前滚动一行
    * 空格键 滚动一行
    * 回车键 滚动一页
    * [pagedown]： 向下翻动一页
    * [pageup]： 向上翻动一页

### tail

* 1、tail -f filename
    * 说明：监视filename文件的尾部内容（默认10行，相当于增加参数 -n 10），刷新显示在屏幕上。退出，按下CTRL+C。
* 2、tail -n 20 filename
    * 说明：显示filename最后20行。
* 3、tail -n +20 filename
    * 说明：显示filename前面20行。
* 4、tail -r -n 10 filename
    * 说明：逆序显示filename最后10行。

* 跟tail功能相似的命令还有：
    - cat 从第一行開始显示档案内容。
    - tac 从最后一行開始显示档案内容。
    - more 分页显示档案内容。
    - less 与 more 相似，但支持向前翻页
    - head 仅仅显示前面几行
    - tail 仅仅显示后面几行
    - n 带行号显示档案内容
    - od 以二进制方式显示档案内容


## 网络
### curl
* 基本用法
    - 等于 GET方法
    - curl http://www.linux.com
* -X
    - -X参数指定 HTTP 请求的方法。
    - curl -X POST https://www.example.com
* -x
    - 指定 HTTP 请求的代理
    - curl -x 192.168.100.100:1080 http://www.linux.com
* -o
    - 将服务器的回应保存成文件，等同于wget命令
    - curl -o baidu.html http://www.baidu.com
    - curl http://www.linux.com >> linux.html 使用linux的重定向功能保存
    - curl -o /dev/null -s -w %{http_code} www.linux.com  在脚本中，这是很常见的测试网站是否正常的用法
* -O
    - -O参数将服务器回应保存成文件，并将 URL 的最后部分当作文件名
    - curl -O https://www.example.com/foo/bar.html
    - 循环下载 curl -O http://www.linux.com/dodo[1-5].JPG
    - 下载重命名
        - curl -O http://www.linux.com/{hello,bb}/dodo[1-5].JPG
        - 由于下载的hello与bb中的文件名都是dodo1，dodo2，dodo3，dodo4，dodo5。因此第二次下载的会把第一次下载的覆盖，这样就需要对文件进行重命名。
        - curl -o #1_#2.JPG http://www.linux.com/{hello,bb}/dodo[1-5].JPG
        - 这样在hello/dodo1.JPG的文件下载下来就会变成hello_dodo1.JPG,其他文件依此类推，从而有效的避免了文件被覆盖
    - 分块下载
        - 有时候下载的东西会比较大，这个时候我们可以分段下载。使用内置option：-r
        - curl -r 0-100 -o dodo1_part1.JPG http://www.linux.com/dodo1.JPG
        - curl -r 100-200 -o dodo1_part2.JPG http://www.linux.com/dodo1.JPG
        - curl -r 200- -o dodo1_part3.JPG http://www.linux.com/dodo1.JPG
        - cat dodo1_part* > dodo1.JPG
    - 显示下载进度条
        - curl -# -O http://www.linux.com/dodo1.JPG
    - 断点续传
        - curl -C -O http://www.linux.com/dodo1.JPG
* -c
    - 将服务器设置的 Cookie 写入一个文件
    - curl -c cookies.txt https://www.google.com
* -D
    - 保存http的response里面的header信息。内置option: -D
    - curl -D cookied.txt http://www.linux.com
    - -c(小写)产生的cookie和-D里面的cookie是不一样的。
* -d
    - 发送 POST 请求的数据体
    - curl -d'login=emma＆password=123'-X POST https://google.com/login
    - curl -d 'login=emma' -d 'password=123' -X POST  https://google.com/login
* -b
    - 用来向服务器发送 Cookie
    - curl -b 'foo=bar' https://google.com
    - curl -b cookies.txt https://www.google.com

* -A
    - 可以让我们指定浏览器去访问网站,有些网站需要使用特定的浏览器去访问他们，有些还需要使用某些特定的版本
    - curl -A "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.0)" http://www.linux.com
    - 这样服务器端就会认为是使用IE8.0去访问的

* -e
    - 设置 HTTP 的标头Referer，表示请求的来源。伪造referer（盗链）
    - 很多服务器会检查http访问的referer从而来控制访问。比如：你是先访问首页，然后再访问首页中的邮箱页面，
       这里访问邮箱的referer地址就是访问首页成功后的页面地址，如果服务器发现对邮箱页面访问的referer地址不是首页的地址，就断定那是个盗连了
    - curl -e "www.linux.com" http://mail.linux.com

### netstat
* netstat命令用于显示与IP、TCP、UDP和ICMP协议相关的统计数据，一般用于检验本机各端口的网络连接情况。
    netstat是在内核中访问网络及相关信息的程序，它能提供TCP连接，TCP和UDP监听，进程内存管理的相关报告。

* 常用组合命令
    - netstat -tlnp
* netstat -lntup  
    - 说明： l:listening   n:num   t:tcp  u:udp  p:process
* TCP 状态说明
    - LISTEN：侦听来自远方的TCP端口的连接请求
    - SYN-SENT：再发送连接请求后等待匹配的连接请求（如果有大量这样的状态包，检查是否中招了）
    - SYN-RECEIVED：再收到和发送一个连接请求后等待对方对连接请求的确认（如有大量此状态，估计被flood攻击了）
    - ESTABLISHED：代表一个打开的连接
    - FIN-WAIT-1：等待远程TCP连接中断请求，或先前的连接中断请求的确认
    - FIN-WAIT-2：从远程TCP等待连接中断请求
    - CLOSE-WAIT：等待从本地用户发来的连接中断请求
    - CLOSING：等待远程TCP对连接中断的确认
    - LAST-ACK：等待原来的发向远程TCP的连接中断请求的确认（不是什么好东西，此项出现，检查是否被攻击）
    - TIME-WAIT：等待足够的时间以确保远程TCP接收到连接中断请求的确认
    - CLOSED：没有任何连接状态
* netstat –r 显示路由信息
* 统计机器中网络连接各个状态个数 
    - netstat -an | awk '/^tcp/ {++S[$NF]}  END {for (a in S) print a,S[a]} '
* 把状态全都取出来后使用uniq -c统计后再进行排序
    - netstat -ant|awk '{print $6}'|sort|uniq –c
* 查看连接某服务端口最多的的IP地址
    - netstat -ant|grep "192.168.25.*"|awk '{print $5}'|awk -F: '{print $1}'|sort -nr|uniq –c




### 防火墙
* ubuntu
    - 1.查看防火墙当前状态  sudo ufw status
    - 2.开启防火墙 sudo ufw enable
    - 3.关闭防火墙 sudo ufw disable
    - 4.查看防火墙版本 sudo ufw version
    - 5.默认允许外部访问本机 sudo ufw default allow
    - 6.默认拒绝外部访问主机 sudo ufw default deny
    - 7.允许外部访问53端口 sudo ufw allow 53
    - 8.拒绝外部访问53端口 sudo ufw deny 53
    - 9.允许某个IP地址访问本机所有端口 sudo ufw allow from 192.168.0.1

* centOS
    * 1.firewalld 的基本使用
        - 启动： systemctl start firewalld
        - 查看状态： systemctl status firewalld
        - 禁用，禁止开机启动： systemctl disable firewalld
        - 停止运行： systemctl stop firewalld
        - 启动一个服务：systemctl start firewalld.service
        - 关闭一个服务：systemctl stop firewalld.service
        - 重启一个服务：systemctl restart firewalld.service
        - 显示一个服务的状态：systemctl status firewalld.service
        - 在开机时启用一个服务：systemctl enable firewalld.service
        - 在开机时禁用一个服务：systemctl disable firewalld.service
        - 查看服务是否开机启动：systemctl is-enabled firewalld.service
        - 查看已启动的服务列表：systemctl list-unit-files|grep enabled
        - 查看启动失败的服务列表：systemctl --failed
    * 2.配置firewalld-cmd
        - 查看版本： firewall-cmd --version
        - 查看帮助： firewall-cmd --help
        - 显示状态： firewall-cmd --state
        - 查看所有打开的端口： firewall-cmd --zone=public --list-ports
        - 更新防火墙规则： firewall-cmd --reload
        - 更新防火墙规则，重启服务： firewall-cmd --completely-reload
        - 查看已激活的Zone信息:  firewall-cmd --get-active-zones
        - 查看指定接口所属区域： firewall-cmd --get-zone-of-interface=eth0
        - 拒绝所有包：firewall-cmd --panic-on
        - 取消拒绝状态： firewall-cmd --panic-off
        - 查看是否拒绝： firewall-cmd --query-panic



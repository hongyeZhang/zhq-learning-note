


## 基本使用
* 


## 开发环境搭建
* 常用的开发工具
> dash 文档查询工具，支持多种编程语言
iterm2 替代原生终端



## 基础操作
> 锁屏  ctrl + shift + power
截屏 shift + command + 3/4/5 各种不同的截屏方式




* 查看环境变量 env
* echo + 环境变量名


* 修改环境变量
```shell script


#查看环境变量
cat ~/.bash_profile

#GRADLE
GRADLE_HOME=/Users/ZHQ/Desktop/software/gradle/gradle-6.5
GRADLE_USER_HOME=/Users/ZHQ/Desktop/software/gradle/localRepo
PATH=$PATH:$GRADLE_HOME/bin
export GRADLE_HOME GRADLE_USER_HOME PATH


#MAVEN
export M2_HOME=/Users/ZHQ/Desktop/software/maven/apache-maven-3.6.3
export PATH=$PATH:$M2_HOME/bin

#ZK
export ZK_HOME=/Users/ZHQ/Desktop/software/zookeeper/zookeeper-3.4.14
export PATH=$PATH:$ZK_HOME/bin



#修改的环境变量立即生效
source ~/.bash_profile

#查看开启的端口
lsof -i:3306

```

## 系统安装软件
* 分屏软件 rectangle
* 视屏播放 IINA




## 软件安装
* homebrew
    * Homebrew 是 mac 下的包管理器，基于命令行模式，使用命令 brew 管理软件。类似 ubuntu 下的 apt-get 、fedora 下的 yum
    * homebrew 国内安装脚本
    * ruby 写的

```shell

# 查看有哪些指令可以使用
brew help 

# 安裝 MongoDB
brew install mongodb 
# 列出目前已安裝的软件
brew list 
# 查看已安裝软件信息
brew info mongodb 
# 移除 MongoDB
brew uninstall mongodb 
# 查询有哪些软件版本已经过期
brew outdated 

brew install tree

# 更新 MongoDB
brew upgrade mongodb 
# 更新 Homebrew 和系统上的所有软件
brew update && brew upgrade && brew doctor 





```



## tmux
* 需要分清楚窗口和会话的概念
    * https://zhuanlan.zhihu.com/p/383565309

> tmux 启动
Ctrl+d 或者显式输入exit命令
tmux new -s <session-name> 新建一个指定名称的会话
tmux att -t <session-name> 回到已经在后天运行的窗口



exit 退出某一个窗格

【分离会话】 按下Ctrl+b d或者输入tmux detach命令，就会将当前会话与窗口分离
Ctrl+b %：划分左右两个窗格。
Ctrl+b "：划分上下两个窗格。
Ctrl+b ：光标切换到其他窗格。是指向要切换到的窗格的方向键，比如切换到下方窗格，就按方向键↓。
Ctrl+b ;：光标切换到上一个窗格。
Ctrl+b o：光标切换到下一个窗格。在窗格之间进行来回切换
Ctrl+b {：当前窗格左移。
Ctrl+b }：当前窗格右移。
Ctrl+b Ctrl+o：当前窗格上移。
Ctrl+b Alt+o：当前窗格下移。
Ctrl+b x：关闭当前窗格。
Ctrl+b !：将当前窗格拆分为一个独立窗口。
Ctrl+b z：当前窗格全屏显示，再使用一次会变回原来大小。
Ctrl+b Ctrl+：按箭头方向调整窗格大小。
Ctrl+b q：显示窗格编号。
Ctrl+b ?：查看命令帮助
Ctrl+b c：新建一个窗口
Ctrl+b d：退出当前的会话
Ctrl+b s：列出所有的会话，并进行选择


* Tmux 窗口有大量的快捷键。所有快捷键都要通过前缀键唤起。默认的前缀键是Ctrl+b，即先按下Ctrl+b，快捷键才会生效


## 学习资料
* mac 云课堂 、 老威
* 
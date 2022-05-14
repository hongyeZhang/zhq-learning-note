
# 《VSCODE开发C++简单记录》

## 1-基本操作
* 安装code 环境变量
```shell script
# 每次重启电脑之后都需要再安装
vscode -> shift + command + p -> shell command -> install code path
```

* 基本的命令行操作
```cpp
// 编译并生成默认的文件
g++ main.cpp
// 编译并生成单个可执行文件  -g 生成带调试信息的可执行文件 -o 指定的输出文件
g++ -g ./TemplateFunctionTest.cpp -o test
./a.out

// 编译多个文件并生成对应的可执行文件
g++ -g ./main.cpp ./swap.cpp -o multi_bin


// 运行多文件的项目，修改 code-runner 的 executorMap 将CPP的文件参数改为 *.cpp
"code-runner.executorMap": {    
    "cpp": "cd $dir && g++ *.cpp -o $fileNameWithoutExt -std=c++11 && $dir$fileNameWithoutExt"
},


```


* gcc 的相关命令
> -E 只激活预处理,这个不生成文件, 你需要把它重定向到一个输出文件里面。
-S 只激活预处理和编译，就是指把文件编译成为汇编代码
-o 制定目标名称, 默认的时候, gcc 编译出来的文件是 a.out
-c 只激活预处理,编译,和汇编,也就是他只把程序做成obj文






## 2-文件配置
launch.json 用于设置调试、运行时的东东；
tasks.json 用于设置编译时的东东。



## 使用cmake编译文件
```shell script
// 1 编写 CMakeLists
// 2 vscode -> command + shift + p -> cmake configure -> 生成一个 build 文件夹
// 3 cmake ..
// 4 make 生成编译的文件

```



## Question
* clang  
* command line tools 
* 

## 快捷键
command + alt + 下 ： 将前面的一行向下复制一行



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






## 基础操作
### mbp编译并运行cpp文件
1、进入.cpp文件所在路径；
2、g++ -o 输出文件名 待编译文件名;
3、./输出文件名。



### C++ 开发环境搭建
```shell
gcc --version
g++ --verison
```





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


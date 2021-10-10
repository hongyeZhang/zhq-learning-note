## 概述
一种编程框架，主要用来构建应用程序
灵活，构建粒度更低
兼容性高，具有ant maven 的所有功能

## 基础知识
* 操作符 << 在Gradle 4.x中被弃用，并且在Gradle 5.0 被移除了。解决办法直接去掉 << 或者使用doLast 即可解决
* gradle.properties 保存属性的配置文件



```shell script
#排除某个任务
gradle -x 
gradle -q helloWorld --daemon
gradle -q helloWorld --no-daemon
#手动停止守护进程 
gradle --stop 
#可配置标准和属性的列表
gradle --properties
#包装器
gradle wrapper:wrapper
#通过 -P 命令来传参
gradle -q -P myProperties='this is -P params'  printMyProperties
#通过-D来定义JVM的系统参数
gradle -q -D org.gradle.project.myProperties='this is -D params'  printMyProperties


#查看所有的任务
gradle -q tasks --all

#执行一个task：
gradle taskName
#获取脚本中所有的task：
gradle tasks --all
#减少执行时的杂音，增加 -q 选项
gradle -q tasks --all



gradle :app:dependencies




```


## 常用命令

```shell script
#查看所有可用的task
gradle task
gradle -q tasks

#编译（编译过程中会进行单元测试）
gradle build

#单元测试
gradle test

#编译时跳过单元测试
gradle build -x test

#直接运行项目 
gradle run

#清空所有编译、打包生成的文件(即：清空build目录)
gradle clean

#生成mybatis的model、mapper、xml映射文件，注： 生成前，先修改src/main/resources/generatorConfig.xml 文件中的相关参数 ， 比如：mysql连接串，目标文件的生成路径等等
gradle mybatisGenerate

#生成可运行的jar包，生成的文件在build/install/hello-gradle下，其中子目录bin下为启动脚本， 子目录lib为生成的jar包
gradle installApp

#打包源代码，打包后的源代码，在build/libs目录下
gradle sourcesJar

#安装到本机maven仓库，此命令跟maven install的效果一样
gradle install

#生成pom.xml文件，将会在build根目录下生成pom.xml文件，把它复制项目根目录下，即可将gradle方便转成maven项目
gradle createPom


```




## Gradle学习4——深入了解Task和构建生命周期



## 生命周期
* 无论什么时候执行Gradle构建，都会运行三个不同的生命周期阶段：初始化、配置和执行

initialization
configuration
execution

初始化（Initialization）
Gradle为每个项目创建一个Project实例，在多项目构建中，Gradle会找出哪些项目依赖需要参与到构建中。
配置（Configuration）
执行所有项目的构建脚本，也就是执行每个项目的build.gradle文件。这里需要注意的是，task里的配置代码也会在这个阶段执行。
执行（Execution）
Gradle按照依赖顺序依次执行task


## project
build.gradle

## Gradle学习5——Gradle增量式构建


### task

* doLast有一种等价操作叫做leftShift，leftShift可以缩写为 << ，下面几种写法效果是一模一样的：
* << 已经被废弃了
```groovy
myTask1.doLast {
    println "task1 doLast"
}

myTask1 << {
    println "task1 doLast<<"
}

myTask1.leftShift {
    println "task1 doLast leftShift"
}
```

* 创建 task 的集中写法
```groovy
task myTask1 {
    doLast {
        println "doLast in task1"
    }
}

task myTask2 << {
    println "doLast in task2"
}

//采用 Project.task(String name) 方法来创建
project.task("myTask3").doLast {
    println "doLast in task3"
}

//采用 TaskContainer.create(String name) 方法来创建
project.tasks.create("myTask4").doLast {
    println "doLast in task4"
}

project.tasks.create("myTask5") << {
    println "doLast in task5"
}

task myTask3(description: "这是task3的描述", group: "myTaskGroup", dependsOn: [myTask1, myTask2], overwrite: true) << {
    println "doLast in task3, this is new task"
}

```


### 概述
一种编程框架，主要用来构建应用程序
灵活，构建粒度更低
兼容性高，具有ant maven 的所有功能

## 常用命令

```shell script
#查看所有可用的task
gradle task

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




## 生命周期
initialization
configuration
execution


## project
build.gradle

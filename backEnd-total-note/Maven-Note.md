
## Maven笔记



## maven概述
Maven：项目构建和依赖管理的工具，下载依赖包、编写源码、配置文件。
* 默认限定了目录结构
* 第三方依赖管理
* 一致的项目构建管理方式
* 原则：约定优先于配置
* 标准的目录结构: 源代码.java src/main/java
* 项目描述符：pom.xml，定义一个maven项目
* 项目类型：pom jar war
* 属性 ${property}
* 依赖、构建配置、多项目（继承）
* 通过 groupId、artifactId、version 三个属性就能定位一个jar包

#### maven坐标
* artifactId（项目标识符） ：域名反转，保证全球唯一
* 语义化版本规范
  - 1.0.0  第一个版本
  - 1.0.1  改bug
  - 1.1.0  功能的增加与减少
  - 2.0.0  项目结构变化（大升级）

#### maven版本
* 发行版（1.0.0-RELEASE）：里面的东西不能更改
* 快照版（1.0.0-SNAPSHOT）:


#### 其他
* 默认仓库： C:\Users\用户名.m2 目录下
* ${basedir}

#### maven属性


## 生命周期
每个Maven项目，都有三个相互独立的生命周期，其中包括：
* clean生命周期：负责项目的清理工作；
* default生命周期：负责项目的部署；
* site生命周期：负责创建项目的文档站点；

例如clean生命周期下有pre-clean、clean和post-clean三个阶段，分别负责项目清理前的工作、清理上次构建的项目和项目清理后的工作，这些阶段是顺序执行的，也就是说，当你执行pre-clean阶段的时候，clean和post-clean阶段不会被执行，当你执行clean阶段的时候，pre-clean阶段和clean阶段会被执行，post-clean阶段不会被执行，当你执行post-clean阶段时候,pre-clean、clean和post-clean这三个阶段都会依次被执行。同理，default生命周期和site生命周期下也分为各个不同的阶段，这些阶段和clean生命周期下的各个阶段一样，后面阶段的执行依赖于前面的阶段执行。


#### clean生命周期
清理项目，包含三个phase。
* pre-clean：执行清理前需要完成的工作
* clean：清理上一次构建生成的文件
* post-clean：执行清理后需要完成的工作

#### default生命周期
构建项目，重要的phase如下。
* validate：验证工程是否正确，所有需要的资源是否可用。
* compile：编译项目的源代码。
* test：使用合适的单元测试框架来测试已编译的源代码。这些测试不需要已打包和布署。
* Package：把已编译的代码打包成可发布的格式，比如jar。
* integration-test：如有需要，将包处理和发布到一个能够进行集成测试的环境。
* verify：运行所有检查，验证包是否有效且达到质量标准。
* install：把包安装到maven本地仓库，可以被其他工程作为依赖来使用。
* Deploy：在集成或者发布环境下执行，将最终版本的包拷贝到远程的repository，使得其他的开发者或者工程可以共享。

#### site生命周
建立和发布项目站点，phase如下
* pre-site：生成项目站点之前需要完成的工作
* site：生成项目站点文档
* post-site：生成项目站点之后需要完成的工作
* site-deploy：将项目站点发布到服务器

#### default详细的生命周期
default生命周期定义了真正构件时所需要执行的所有步骤，它是生命周期中最核心的部分，它包含的阶段如下：
* validate 验证项目是否正确和所有需要的相关资源是否可用
* initialize 初始化构建
* generate-sources
* process-sources 处理源代码
* generate-resources
* process-resources 处理项目主资源文件。对src/main/resources目录的内容进行变量替换等工作后，复制到项目输出的主classpath目录中。
* compile 编译项目的主源代码
* process-classes
* generate-test-sources
* process-test-sources 处理项目测试资源文件
* generate-test-resources
* process-test-resources 处理测试的资源文件
* test-compile 编译项目的测试代码
* process-test-classes
* test 使用单元测试框架运行测试，测试代码不会被打包或部署
* prepare-package 做好打包的准备
* package 接受编译好的代码，打包成可发布的格式
* pre-integration-test
* integration-test
* postintegration-test
* verify
* install 将包安装到Maven本地仓库，供本地其他Maven项目使用
* deploy 将最终的包复制到远程仓库，供其他开发人员和Maven项目使用
* 原文链接:https://blog.csdn.net/qq_28165595/article/details/80952714


## 操作命令
```
mvn archetype:generate    使用模板生成命令
mvn compile               编译源代码
mvn test                  单元测试
mvn package               打包
mvn deploy                部署
mvn site                  项目相关网站
mvn clean                 清理
```



## 插件
一个插件通常可以完成多个任务，每一个任务就叫做插件的一个目标Maven的生命周期是抽象的，实际需要插件来完成任务，这一过程是通过将插件的目标（goal）绑定到生命周期的具体阶段（phase）来完成的。如：

* 将maven-compiler-plugin插件的compile目标绑定到default生命周期的compile阶段，完成项目的源代码编译：


#### Tomcat-Maven插件
```
mvn tomcat7:run
mvn tomcat7:deploy
```


## pom文件
#### dependencyManagement
主要是用来做版本控制的.dependencyManagement元素提供了一种管理依赖版本号的方式。在dependencyManagement元素中声明所依赖的jar包的版本号等信息，那么所有子项目再次引入此依赖jar包时则无需显式的列出版本号。Maven会沿着父子层级向上寻找拥有dependencyManagement 元素的项目，然后使用它指定的版本号。如果有多个子项目都引用同一样依赖，则可以避免在每个使用的子项目里都声明一个版本号。当想升级或切换到另一个版本时，只需要在顶层父容器里更新，而不需要逐个修改子项目；另外如果某个子项目需要另外的一个版本，只需要声明version即可。dependencyManagement中定义的只是依赖的声明，并不实现引入，因此子项目需要显式的声明需要用的依赖。

```xml
在父项目的POM.xml中配置,此配置即生命了spring-boot的版本信息。
  <dependencyManagement>
      <dependencies>
          <dependency>
              <groupId>org.springframework.boot</groupId>
              <artifactId>spring-boot-starter-web</artifactId>
              <version>1.2.3.RELEASE</version>
          </dependency>
      </dependencies>
  </dependencyManagement>

子项目则无需指定版本信息：
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>

```

#### packaging
* jar：默认的打包方式，打包成jar用作jar包使用。存放一些其他工程都会使用的类，工具类。我们可以在其他工程的pom文件中去引用它
* war：将会打包成war，发布在服务器上，如网站或服务。可以通过浏览器直接访问，或者是通过发布服务被别的工程调用
* pom：用在父级工程或聚合工程中，用来做jar包的版本控制，必须指明这个聚合工程的打包方式为pom

#### scope
* test范围指的是测试范围有效，在编译和打包时都不会使用这个依赖
* compile范围指的是编译范围有效，在编译和打包时都会将依赖存储进去
* provided依赖：在编译和测试的过程有效，最后生成war包时不会加入，诸如：servlet-api，因为servlet-api，tomcat等web服务器已经存在了，如果再打包会冲突
* runtime在运行的时候依赖，在编译的时候不依赖
* 默认的依赖范围是compile
* 作用域是test的包不会传递到引用这个项目的其它项目，但如果不是test会传递依赖到其它项目。

## 实用技巧
#### maven 实战命令
```
mvn clean install -U                                   打包安装时强制更新依赖
mvn clean compile -pl project-name                     单独编译某一个模块
mvn clean package -Dmaven.test.skip=true               打包时忽略测试（实际上是配置maven-surefire-plugin 的目标）
mvn clean install -Dmaven.test.skip=true               编译、打包并安装到本地仓库
mvn clean package -DskipTests 跳过测试的运行
mvn clean package -Dmaven.test.skip=true 跳过测试代码的编译和运行

mvn clean package -pl cms-admin-service -am -DskipTests 


```

#### IDEA can not download source问题
有时候用IDEA无法下载源码，可以在命令行项目根目录下，执行如下命令下载：
```
mvn dependency:resolve -Dclassifier=sources
```

#### IDEA 中maven设置
* idea中全局设置settings ： file -> other settings -> default settings
* 打出的war包，部署在tomcat时，要选择 war-exploded，通过以目录的形式来进行部署

#### idea中隐藏.idea文件夹和.iml文件
idea中的.idea文件夹和.iml是平常几乎不使用的文件，在创建父子工程或者聚合工程时反而会对我们操作产生干扰，所以，一般情况下，我们都将其隐藏掉，具体百度

#### mvnw
mvnw是一个maven wrapper script,它可以让你在没有安装maven或者maven版本不兼容的条件下运行maven的命令.
原理:
1. 它会寻找maven在你电脑环境变量path中的路径
2. 如果没有找到这个路径它就会自动下载maven到一个默认的路径下,之后你就可以运行maven命令了
3. 有时你会碰到一些项目的peoject和你本地的maven不兼容,它会帮你下载合适的maven版本,然后运行

#### 产生web的项目目录命令
```
mvn archetype:generate -DgroupId=com.netease.restaurant -DartifactId=Restaurant -Dpackage=com.netease -Dversion=1.0.0-SNAPSHOT -DarchetypeArtifactId=maven-archetype-webapp

```

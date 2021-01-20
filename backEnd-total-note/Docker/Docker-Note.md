# Docker

## docker简介
容器化：
云平台  k8s   kubernate  docker 开发 需要Go语言
docker  Go 语言编写  Swarm/Compose/Machine/mesos/k8s/

* 解决的问题背景：环境和配置不同，war包可能会出现问题，经过不同版本的迭代，不同版本环境的兼容。

* docker给出标准的解决方案: 代码/配置/系统/数据  统一打包，使软件带环境安装，把原始环境一模一样的复制过来，消除在开发及其上能够正常工作而其他环境不能正常工作的过程。
透过镜像将作业新系统核心除外，运作应用程序所需要的系统环境，由下而上进行打包，达到应用程序跨平台的无缝接轨运作。

* docker是基于GO语言实现的云开源项目。
build ship and run any app anywhere  一次安装，到处运行
只需要一次配置好环境，到别的机器上就能一键部署运行
解决了运行环境和配置问题软件容器，方便做持续继承并有助于整体发布的容器虚拟化技术。
* 虚拟机：带环境安装的一种解决方案。模拟整套操作系统，软件+硬件。虚拟出一套硬件之后，在其上运行一个完整的操作系统，  缺点：资源占用多、冗余步骤多、启动时间长
Linux容器：LXC linux  container
docker：缩小版小型linux系统
开发/运维：DevOps：一次构建，随处运行
服务扩容

* 三大要素：镜像(image)、容器(container)、仓库(repo)
* docker hub centrOS 6.5以上版本 Docker镜像（image）就是一个只读的模板，镜像可以用来创建docker容器，一个镜像可以创建多个容器
镜像 ->  类  对比   容器 -> 对象
docker利用容器独立运行的一个或者一组应用。可以把容器看做是一个简易版的linux环境和运行在其中的应用程序。仓库是集中存放镜像的场所。
国内的仓库：阿里云、网易云

## 安装docker
基于ubuntu18.04 进行安装

		卸载旧版本
		apt-get remove docker docker-engine docker.io containerd runc
		使用 APT 安装
		# 更新数据源
		apt-get update
		# 安装所需依赖
		apt-get -y install apt-transport-https ca-certificates curl software-properties-common
		# 安装 GPG 证书
		curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
		# 新增数据源
		add-apt-repository "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
		# 更新并安装 Docker CE
		apt-get update && apt-get install -y docker-ce
		验证安装是否成功
		docker version
		# 输出如下
		Client:
		 Version:           18.09.6
		 API version:       1.39
		 Go version:        go1.10.8
		 Git commit:        481bc77
		 Built:             Sat May  4 02:35:57 2019
		 OS/Arch:           linux/amd64
		 Experimental:      false
		Server: Docker Engine - Community
		 Engine:
		  Version:          18.09.6
		  API version:      1.39 (minimum version 1.12)
		  Go version:       go1.10.8
		  Git commit:       481bc77
		  Built:            Sat May  4 01:59:36 2019
		  OS/Arch:          linux/amd64
		  Experimental:     false



		配置阿里云数据源
		tee /etc/docker/daemon.json <<-'EOF'
		{
		  "registry-mirrors": ["https://os5ll4jp.mirror.aliyuncs.com"]
		}
		EOF
		# 重启 Docker
		systemctl daemon-reload
		systemctl restart docker


安装 docker-Compose
curl -L https://get.daocloud.io/docker/compose/releases/download/1.24.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose






## docker实战
#### docker镜像
```$xslt
删除images   docker rmi <image id>
要删除全部image   docker rmi $(docker images -q)
docker pull imageName (最新版本)
安装指定版本的镜像： docker pull zookeeper:3.4.13

```


#### docker容器
* docker ps               // 查看所有正在运行容器
* docker stop containerId // containerId 是容器的ID
* docker ps -a            // 查看所有容器
* docker ps -a -q         // 查看所有容器ID
* docker stop $(docker ps -a -q)   // stop停止所有容器
* docker rm $(docker ps -a -q)   // remove删除所有容器
* docker exec -it c22044a00d3e /bin/bash  //进入到容器内进行操作


docker pull centos
docker images

容器相关的命令：

docker run [options] IMAGE [COMMAND] [ARG...]

启动交互式容器 ：docker run -it centos --name
docker run -it ID

列出所有正在运行的容器
docker ps
docker ps -a
docker ps -l  上一次运行的容器
docker ps -q  只显示容器号




退出容器：
exit  容器停止并退出
ctrl + p + q  容器不停止并退出


docker start containerID  启动容器
docker restart containerID  重启容器

docker stop containerID  停止容器（慢慢的）
docker kill containerID  强制关闭容器
docker rm containerID 删除已经停止的容器
docker rmi  删除镜像
docker rm -f containerID  强制删除

启动容器，后台运行
docker run -d containerName
docker后台进行，必须要有一个前台应用

docker logs -f -t --tail  containerID
-t  时间戳
-f  追加
--tail  后面的


docker run -d centos /bin/sh -c "while true; do echo hello zzyy; sleep 2;done"

查看容器内运行的进程
docker top containerID
查看容器内部细节
docker inspect containerID


docker run -it centos

docker run -it centos /bin/bash
docker attach containerID  重进入容器
docker exec -it containerID ls -l /tmp  执行容器的一个命令

docker exec -it 351b7c0a9c3e /bin/bash


从容器内拷贝文件到主机内：
docker cp containerID:容器内的目的路径  本机的路径

====================   docker 镜像
unionFS （联合文件系统）
轻量级的、可执行的独立软件包。
分层结构可以做到共享资源，相同的镜像只需要加载一份

docker镜像都是只读的

docker pull mongo

docker commit 提交容器，使之成为一个新的镜像
docker commit -m="提交的描述信息"  -a="作者" containerID  目标镜像名

docker pull tomcat
docker image tomcat
docker run -it -p 8888[docker对外暴露的接口（主机端口d）]:8080[docker容器里面的接口]

docker run -it -p 8888:8080 tomcat
docker run -it -P tomcat   P随机分配端口
docker ps 查看程序的镜像端口

查询： docker search tomcat


提交一个修改的新镜像
docker commit -a="zhq" -m="tomcatZHQ" containerID atguigu/tomcat:1.2

docker images
docker run -it -p 7777:8080 atguigu/tomcat:1.2

P17集需要操作实践

启动守护容器
docker run -d -p 6666:8080 tomcat


====================   docker 容器数据卷
将docker容器产生的数据持久化
容器之前希望共享数据
数据卷：类似于redis中的rdb文件
宿主机和容器之间的数据共享

容器内添加数据卷：
  （1）直接命令参加
  （2）cokerFile添加

docker run -it -v /宿主机的绝对路径目录:/容器内目录  镜像名
docker run -it -v /宿主机的绝对路径目录:/容器内目录:ro  镜像名  容器内目录只读，可以进行权限管理

容器与宿主机之间共享数据
docker run -it -v /root/zhq/myDataVolume:/dataVolumeContainer  centos

docker start containerID
dokcer attach containerID


====================   dockerFile 添加容器数据卷
类比记忆
javaEE  hello.java ---------> hello.class
Docker  images ------------> DockerFile

touch dockerFile
vi

```
# volume test
FROM centos
VOLUME ["/dataVolumeContainer1","/dataVolumeContainer2"]
CMD echo "finished, ----- success1"
CMD /bin/bash
```

上述dockerFile的含义与下面语句类似
docker run -it -v /host1:/dataVolumeContainer1 -v /host2:/dataVolumeContainer2 centos /bin/bash

build之后生成新的镜像
docker build -f /root/zhq/DockerFile -t zhq/centos .
宿主机对应的数据目录产生通过 docker inspect containerID 进行查看


容器间传递共享（--volumes-from）
具体操作步骤：
（1）先启动容器  dc01
docker images zhq/centos
docker run -it --name dc01 zhq/centos

(2) dc02 dc03 继承于dc01
docker run -it --name dc02 --volumes-from dc01 zhq/centos
此时dc01和dc02之间达到了数据共享

docker rm -f dc01
容器之间配置信息的传递，数据卷的声明周期一直持续到没有容器使用它为止


====================   dockerFile 文件解析
1、手动编写一个dockerfile文件，需要符合file的规范
2、docker build 命令执行，获得一个自定义的镜像
3、run
dockerFile 是用来构建docker镜像的构建文件，是由一系列明亮和参数构成的脚本

centos 的 dockfile 文件
FROM scratch
MAINTAINER
ADD
CMD

dockerFile 基础知识
命令大写，且后面后跟一个参数
指令从上向下顺序执行，
每条指令都会创建一个新的镜像层，并对镜像及进行提交

关键字解析（保留字指令）：
FROM  基础镜像
MAINTAINER 作者姓名及邮箱地址
RUN  容器构建时需要运行的命令
EXPOSE  当前容器对外暴露的端口
WORKDIR  创建容器之后，终端默认登录进来的工作目录
ENV  用来在构建镜像过程中设置环境变量
ADD  将宿主机目录下的文件拷贝进镜像且ADD命令会自动处理URL和解压缩tar压缩包
COPY  拷贝文件和目录到镜像中 COPY src dest
VOLUME  容器数据卷，用于数据保存和持久化操作
CMD  指定容器启动时要运行的命令，只有最后一行生效
ENTRYPOINT  与CMD类似
ONBUILD 继承时，父镜像在被子继承之后父镜像的onobuild被触发，类似于钩子函数


====================   自定义镜像 mycentos
docker rm -f $(docker ps -q)  将所有的容器删除
实现功能：
登录后的默认路径
vim编辑器
查看网络配置的ifconfig支持

exmaple:
```
FROM centos
ENV mypath /tmp
WORKDIR $mypath
RUN yum -y install vim
RUN yum -y install net-tools
EXPOSE 80

CMD echo $mypath
CMD echo "success--------------ok"
CMD /bin/bash
```

docker build -f /root/zhq/dockerfile2 -t mycentos:1.3 .

docker history imageID 列出镜像的变更历史
顺着加载，倒着执行

====================   CMD 与 ENTRYPOINT 的区别
CMD 会被 docker run 之后的参数替换

级联建文件夹
mkdir -p /zhq/mydockerfile/tomcat9
自己定义一个tomcat容器，然后将web工程部署到tomcat里面  P28+p29


docker run 之后的参数添加到 ENTRYPOINT 之后

curl -i www.baidu.com  显示访问的头信息



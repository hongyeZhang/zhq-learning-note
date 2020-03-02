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



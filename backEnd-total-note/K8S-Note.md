
# Kubernetes


## 历史

infrastructure as a service IAAS
platform as a service PAAS
software as a service SAAS

* 资源管理器
    * MESOS  资源管理器 分布式的资源管理框架  已经过时
    * docker swarm  

borg 系统
GO语言开发 K8s
* 特点:
    * 轻量级：消耗的资源少
    * 开源
    * 弹性伸缩
    * 负载均衡 ： IPVS 

### 知识图谱

* 资源、资源清单的语法、编写Pod   掌握Pod的生命周期
* Pod ： 掌握各种控制器的特点以及使用方式
* service：服务发现  掌握SVC原理极其构建方式

* 服务分类：
    * 有状态服务： DBMS
    * 无状态服务： LVS APACHE

* 存储： 掌握多种存储类型的特点，能够在不同环境中选择合适的存储方案，有自己的见解
* 调度器：能够根据要求把 Pod 定义到想要的节点运行
* 安全： 集群的认证 鉴权  访问控制原理及其流程
* HELM： linux  yum的包管理工具 HPA  掌握原理、模板自定义
* kubeadm 源码修改  修改证书可用期限
* kubernetes 高可用构建

* CICD 持续集成  持续部署

* 资料共享

### 组件说明
* borg 的架构
    * borgMaster 请求、分发
    * borglet 
    * Paxos
* k8s 架构
    * kubctl 
    * scheduler
    * replication controller
    * etcd 分布式的键值存储服务 v2  v3
* ETCD结构 
    * 理解为存储
* Raft
* node
    * kubelet
    * container
    * docker
* api server 
    * 所有组件的访问入口
* ControllerManager 维持副本期望数目
* Schefuler 负责介绍任务，选择合适的节点进行分配任务
* ETCD ： 键值对数据库，存储K8S集群的所有重要信息
* kubelet： 直接跟容器引擎交互实现容器的生命周期管理
* kube-proxy  负责写入规则
* CoreDNS  可以为集群中的SVC创建一个域名IP的对应关系解析
* DashBoard 给K8S集群提供一个B/S结构访问体系
* ingress 实现七层代理
* fedetation 可以跨集群中心的同意管理功能
* prometheus  监控
* elk  


### 概念
* pod
    * 自主式 pod
    * 控制器管理的 pod
    * pause 
    * ReplicationController ReplicaSet deployment
    * rolling-update 滚动更新  回滚
* HPA
* StatefullSet
* DaemonSet
* job  CronJob
* 服务发现
    * round robin
* squid
* pod 与 pod 的通信
* overlay network  覆盖网络
* flannel 
    * flannel id
* etcd 与 flannel id 
* pod 至 service 的网络


### 集群安装
kubeadm
* Harbor 

软路由 koolshare

* centos 设置主机名
    * hostnamectl set-hostname k8s-master01
    * vi /etc/hosts

* v 1.15.1 


* kubernetes单机安装
    * https://blog.csdn.net/wangtonglin2009/article/details/79024820
* https://www.zhihu.com/search?type=content&q=kubernetes%E5%8D%95%E6%9C%BA%E5%AE%89%E8%A3%85



yum -y install lrzsz

### 资源清单
* k8s 中的资源
    * 名称空间级别： kubeadm k8s 
    * 集群级别
    * 元数据型  HPA 
* yaml文件
    


    




















    







    










    
    
    














    
    
    








































    




    
























































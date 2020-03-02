
### 单机版
    (1) tar -xzvf ***.tar.gz
    (2) cp zoo_sample.cfg zoo.cfg（默认的配置文件）
    (3) 修改配置文件
    dataDir=/usr/local/zookeeper/single/data
    dataLogDir=/usr/local/zookeeper/single/log
    (4) 启动验证 ./zkServer.sh start
    netstat -ant | grep 2181

### 伪分布式
配置 zoo1.cfg
```
# Zookeeper数据存放目录
dataDir=/usr/local/zookeeper/distribute/server1/data

# 当前服务器对外服务端口
clientPort=2181
# Zookeeper 日志文件存放目录
dataLogDir=/usr/local/zookeeper/distribute/server1/log

# 服务器集群信息
server.1=192.168.41.129:2881:3881
server.2=192.168.41.129:2882:3882
server.3=192.168.41.129:2883:3883

2881:服务器通信端口
3881:选举端口

```

配置 zoo2.cfg
```
# Zookeeper数据存放目录
dataDir=/usr/local/zookeeper/distribute/server2/data

# 当前服务器对外服务端口
clientPort=2182
# Zookeeper 日志文件存放目录
dataLogDir=/usr/local/zookeeper/distribute/server2/log

# 服务器集群信息
server.1=192.168.41.129:2881:3881
server.2=192.168.41.129:2882:3882
server.3=192.168.41.129:2883:3883
```

配置 zoo3.cfg
```
# Zookeeper数据存放目录
dataDir=/usr/local/zookeeper/distribute/server3/data

# 当前服务器对外服务端口
clientPort=2183
# Zookeeper 日志文件存放目录
dataLogDir=/usr/local/zookeeper/distribute/server3/log

# 服务器集群信息
server.1=192.168.41.129:2881:3881
server.2=192.168.41.129:2882:3882
server.3=192.168.41.129:2883:3883
```

data  文件夹下
echo 1 > myid
echo 2 > myid
echo 3 > myid

启动 zookeeper
./zkServer.sh start ../conf/zoo1.cfg
./zkServer.sh start ../conf/zoo2.cfg
./zkServer.sh start ../conf/zoo3.cfg

查看状态
./zkServer.sh status ../conf/zoo1.cfg
./zkServer.sh status ../conf/zoo2.cfg
./zkServer.sh status ../conf/zoo3.cfg

停止
./zkServer.sh stop ../conf/zoo1.cfg
./zkServer.sh stop ../conf/zoo2.cfg
./zkServer.sh stop ../conf/zoo3.cfg

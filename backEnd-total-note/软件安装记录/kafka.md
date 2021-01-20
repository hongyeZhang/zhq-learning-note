

### 单机版
(1) tar -xzvf ***.tar.gz
（2）启动zookeeper,可以是kafka内置的，也可以是自己安装的
//这是前台启动，启动以后，当前就无法进行其他操作（不推荐）
./zookeeper-server-start.sh ../config/zookeeper.properties

//后台启动（推荐）
./zookeeper-server-start.sh ../config/zookeeper.properties 1>/dev/null 2>&1 &
（3）修改kafka配置文件
config/server.properties:
	broker.id=0
	listeners=PLAINTEXT://192.168.41.129:9092
	log.dirs=kafka-logs
	zookeeper.connect=localhost:2181
（4）
//后台启动kafka
./kafka-server-start.sh ../config/server.properties 1>/dev/null 2>&1 &

（5）验证
进程+端口号  9092


### 集群版




### 伪集群版
cp server.properties server1.properties
cp server.properties server2.properties
cp server.properties server3.properties

server.properties
broker.id=0
port=9092
listeners=PLAINTEXT://192.168.41.129:9092
log.dirs=/usr/local/kafka/kafka-log/broker-0

server1.properties
broker.id=1
port=9093
listeners=PLAINTEXT://192.168.41.129:9093
log.dirs=/usr/local/kafka/kafka-log/broker-1

server2.properties
broker.id=2
port=9094
listeners=PLAINTEXT://192.168.41.129:9094
log.dirs=/usr/local/kafka/kafka-log/broker-2


启动方式：
./kafka-server-start.sh ../config/server.properties 1>/dev/null 2>&1 &
./kafka-server-start.sh ../config/server1.properties 1>/dev/null 2>&1 &
./kafka-server-start.sh ../config/server2.properties 1>/dev/null 2>&1 &


./kafka-server-start.sh -daemon ../config/server.properties
./kafka-server-start.sh -daemon ../config/server1.properties
./kafka-server-start.sh -daemon ../config/server2.properties

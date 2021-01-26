
## ubuntu16 安装配置 hadoop
* https://blog.csdn.net/hhy1107786871/article/details/85221665

```shell script
vi /etc/profile
export HADOOP_HOME=/Hadoop/hadoop-3.1.4
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
source /etc/profile

vi /etc/hosts
192.168.41.129 master

export JAVA_HOME=/usr/local/java/jdk1.8.0_152

# 启动
start-all.sh


```







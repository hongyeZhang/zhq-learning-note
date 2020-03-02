

### 创建目录

#### 在/usr/目录下创建java目录，
mkdir /usr/local/java
cd /usr/local/java

把下载的文件 jdk-8u152-linux-x64.tar.gz 放在/usr/local/java/目录下。

#### 解压 JDK
tar -zxvf jdk-8u152-linux-x64.tar.gz

#### 设置环境变量
修改 vi /etc/profile
在 profile 文件中添加如下内容并保存：

set java environment
JAVA_HOME=/usr/local/java/jdk1.8.0_152
JRE_HOME=/usr/local/java/jdk1.8.0_152/jre
CLASS_PATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib
PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
export JAVA_HOME JRE_HOME CLASS_PATH PATH


注意：其中 JAVA_HOME， JRE_HOME 请根据自己的实际安装路径及 JDK 版本配置。

#### 让修改生效：
source /etc/profile

#### 测试
java -version

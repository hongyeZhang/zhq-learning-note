
* 锁屏  ctrl + shift + power



* 查看环境变量 env
* echo + 环境变量名


* 修改环境变量
```shell script


#查看环境变量
cat ~/.bash_profile

#GRADLE
GRADLE_HOME=/Users/ZHQ/Desktop/software/gradle/gradle-6.5
GRADLE_USER_HOME=/Users/ZHQ/Desktop/software/gradle/localRepo
PATH=$PATH:$GRADLE_HOME/bin
export GRADLE_HOME GRADLE_USER_HOME PATH


#MAVEN
exprot M2_HOME=/Users/ZHQ/Desktop/software/maven/apache-maven-3.6.3
export PATH=$PATH:$M2_HOME/bin

#修改的环境变量立即生效
source ~/.bash_profile

```

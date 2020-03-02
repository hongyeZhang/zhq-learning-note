### 查看主机信息

#### 查看CPU使用率
top 查看CPU访问率


#### 查看端口的占用情况
lsof -i:端口号 用于查看某一端口的占用情况，比如查看8000端口使用情况，lsof -i:8000

netstat -tunlp |grep 端口号，用于查看指定的端口号的进程情况，如查看8000端口的情况，netstat -tunlp |grep 8000

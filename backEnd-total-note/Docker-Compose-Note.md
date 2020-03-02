
# docker-compose 学习笔记



### 命令行使用

```$xslt
如果文件名就叫做docker-compose.yml则可以不适用-f选项指定文件路劲，up选项启动容器，-d选项以守护模式运行
docker-compose -f docker-compose-name.yml up -d

如果要批量停止容器并清除容器，可以使用down命令
docker-compose -f docker-compose.yml down



```


#### docker compose
以tomcat为例

启动一个tomcat实例
mkdir -r /user/local/tomcat
vi docker-compose.yml

version: '3.1'  # 指定 compose 文件的版本
services:
	tomcat:
		restart: always
		image: tomcat
		container_name: tomcat
		ports:
		  - 8080:8080
		  - 3306:3306 （- 表示数字形式的配置）


守护态启动运行  docker-compose up -d
yml 配置语言，不能使用制表符进行缩进，必须使用空格进行缩进，缩进几个格不重要，只要同样级别的配置对齐即可。

数据卷：容器通过数据卷将数据写到磁盘里面
交互式进入
docker exec -it tomcat /bin/bash
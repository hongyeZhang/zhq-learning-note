
# RabbitMQ


### 常用命令行

```
rabbitmq-server -detached   #rabbitmq分别启动节点和应用  应用关闭rabbitmqctl stop_app 应用启动 rabbitmqctl start_app
netstat -lnp |grep beam  #查看端口
rabbitmqctl stop    #应用和节点都将被关闭
rabbitmqctl start_app  #应用启动
rabbitmqctl stop_app  #应用关闭

用户管理包括增加用户，删除用户，查看用户列表，修改用户密码。
(1) 新增一个用户
rabbitmqctl  add_user  Username  Password
(2) 删除一个用户
rabbitmqctl  delete_user  Username
(3) 修改用户的密码
rabbitmqctl  change_password  Username  Newpassword
(4) 查看当前用户列表
rabbitmqctl  list_users

例：
添加rabbitmq控制台管理员用户
rabbitmqctl add_user admin admin  #添加用户，前一个admin是用户名，后一个admin是密码
rabbitmqctl set_user_tags admin administrator  #admin设置为管理员


rabbitmqctl delete_vhost /
rabbitmqctl add_vhost /
rabbitmqctl list_vhosts
rabbitmqctl set_permissions -p / guest '.*' '.*' '.*' ##设置用户权限
rabbitmqctl list_permissions -p / ##列出虚拟主机上的所有权限
rabbitmqctl list_user_permissions guest ##列出用户权限


```

























###
4369 -- erlang发现口
5672 --client端通信口
15672 -- 管理界面ui端口
25672 -- server间内部通信口

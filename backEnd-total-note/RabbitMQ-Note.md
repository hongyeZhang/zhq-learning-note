## 简介
消息队列解决什么问题？

* 日志收集（统计PV） : 前端发送埋点数据->文件->ELK（日志收集）->消息中间件->流计算（实时统计，或者归档，离线计算）->
* 应用解耦：
* 异步调用：
* 流量削峰： 流量 -> MQ -> 秒杀业务

##
一般不用超级管理员账号开发
添加用户  user_zhq:123456
virtual host: 相当于数据库，一般以/开头  添加一个 /vhost_zhq
virtual host 添加之后需要对用户进行授权。

生产者 -> 消息队列 -> 消费者

* 简单队列：耦合性高，生产者一一对应消费者，队列名需要一致
* 工作队列（work queue）:一个生产者对多个消费者，
  - 轮询分发：平均分配给消费者
  - 公平分发：必须关闭消费者的自动应答，手动给队列发送处理回执



* 消息应答:
  - autoAck: true  自动确认模式。rabbitmq将消息发送给消费者之后，就会从内存中删除；如果消费者挂掉，则消息会丢失
  - autoAck:false  手动模式。rabbitmq支持消息应答，消费者发送消息处理完成的回执。如果一个消费者挂掉，就会将消息发送给其他的消费者。
* 允许消息持久化，但不允许使用不同的参数修改已经定义的队列。 boolean durable 是否持久化的标志， 可以从控制台中直接删除，或者声明新的队列。
* 发布订阅模式（publish/subscribe）
  - 一个生产者，多个消费者，每个消费者都监听一个队列
  - 生产者没有将消息直接发送给队列，而是发送个交换机(exchange)，每个队列都绑定到交换机上
  - 生产者发送的消息经过交换机到达队列，就能实现一个消息被多个消费者消费
  - 交换机如果不绑定队列，消息就会丢失，因为交换机没有存储消息的能力，只有队列可以存储消息

* 交换机
  - 接收生产者的消息，向队列推送消息
  - 匿名转发：""  fanout:不处理路由键

* 路由模式
* 主题模式(topic)

* rabbitmq的消息确认机制
  - 通过持久化数据解决rabbitmq的服务器异常

* AMQP的事务机制：
txSelect 开启事务
txCommit 提交事务
tcRollback 回滚事务




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

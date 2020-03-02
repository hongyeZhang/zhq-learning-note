=====
RDBMS  关系型数据库，里面全都是表
NoSQL  非关系型数据库
文档数据库 MongoDB


里面存储的数据模型是基于文档的，类似于json的形式，BSON
27017  端口

在启动的命令行中可以设定数据的存储的默认地址和服务器监听的端口
端口号自己制定时，最好是四位数及以上，最大不要超过65535

数据库：
    服务器：mongod
    客户端：mongo
三个概念：数据库->集合->文档

基本指令
显示当前数据库：show databases
进入数据库： use test (如果当前没有对应的数据库，则自动创建)
当前在那个数据库 db
show collecitons  查看数据库中有几个集合

数据库的CURD操作：
（1）向数据库中插入文档：
    db.<collectionName>.insert(doc)  向集合中插入一个或者多个文档
        db.stus.insert({"name":"zhq", age:18, gender:"male"})
    ObjectId() 可以自动生成一个唯一的_id  确保数据的唯一性，但是也可以自己指定，但也需要确保唯一性

    db.colleciton.insertOne() 插入一个文档
    db.colleciton.insertMany() 插入多个文档






（2）查询
    db.<collectionName>.find()

mangodb manager 数据库管理界面

数据库的CURD操作

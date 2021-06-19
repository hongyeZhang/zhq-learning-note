# seata 学习笔记

## 参考学习连接
* https://seata.io/zh-cn/docs/dev/mode/at-mode.html
* https://www.iocoder.cn/categories/Seata/


## 四种事务模式
###  Seata AT 模式
AT 模式：参见《Seata AT 模式》文档

### TCC 模式：参见《Seata TCC 模式》文档

### Saga 模式：参见《SEATA Saga 模式》文档

### XA 模式：正在开发中...



## 三种角色
* TC (Transaction Coordinator) - 事务协调者：维护全局和分支事务的状态，驱动全局事务提交或回滚。
* TM (Transaction Manager) - 事务管理器：定义全局事务的范围，开始全局事务、提交或回滚全局事务。
* RM ( Resource Manager ) - 资源管理器：管理分支事务处理的资源( Resource )，与 TC 交谈以注册分支事务和报告分支事务的状态，并驱动分支事务提交或回滚。






















# Elasticsearch 学习笔记

## chapter1 概述

默认不允许root用户运行
./elasticsearch -Des.insecure.allow.root=true

vim /etc/sysctl.conf
 chown -R zhq:zhq elasticsearch-5.6.16
 chown -R zhq:zhq elasticsearch-6.8.6
 
```shell script
#后台启动
./elasticsearch -d  

#验证： 
curl -XGET http://localhost:9200/_cat/health?v

#安装设置
#临时设置，当Linux重新启动会恢复到设置之前的值。
sysctl -w vm.max_map_count=262144

# 查看结果：
sysctl -a|grep vm.max_map_count
# 显示： vm.max_map_count = 262144

#永久设置 在 /etc/sysctl.conf文件最后添加一行
# vm.max_map_count=262144

```

## chapter2 Rest API

### 索引操作
* 索引命令规约： rest命令/索引库/类型/id

#### 创建
* 一般来说，分片数量等于机器的节点，但是不能过度分片，评估机器的单点处理能力
* 经验公式  节点数量 = 分片数量 * （副本数量+1）

```shell script
# 查看所有的索引目录
curl -XGET http://localhost:9200/_cat/indices
curl -XGET http://localhost:9200/_cat/indices?v
# 创建facebook的索引  pretty方便查看结果
curl -XPUT http://localhost:9200/facebook?pretty 
# 查看创建的索引
curl -XGET http://localhost:9200/facebook?pretty

# 创建指定参数（分片和副本数）的索引
curl -XPUT -H "Content-Type: application/json" http://localhost:9200/facebook01?pretty -d '
{
    "settings": {
      "index":{
        "number_of_shards": 3,
        "number_of_replicas": 2
      }
    }
}'

```

#### 查询
```shell script
# 查看索引设置
curl -XGET http://localhost:9200/facebook01/_settings?pretty
curl -XGET http://localhost:9200/facebook01/_mapping?pretty
# 支持通配符查询
curl -XGET http://localhost:9200/face*?pretty
#所有的索引
curl -XGET http://localhost:9200/_all?pretty

#测试失败
curl -XGET http://localhost:9200/facebook01/_settings,_mapping?pretty

```

#### 判断是否存在

```shell script
#判断是否存在 测试失败
curl -X HEADER http://localhost:9200/facebook01

```

#### 删除

```shell script
#索引删除
curl -XDELETE http://localhost:9200/facebook01?pretty
curl -XGET http://localhost:9200/_cat/indices?v
```


#### 打开和关闭
```shell script
#索引关闭之后里面的数据查不到
curl -X POST http://localhost:9200/facebook01/_close?pretty

#打开索引
curl -X POST http://localhost:9200/facebook01/_open?pretty

#当索引关闭时 此操作会失效
curl -XPUT -H "Content-Type: application/json" http://localhost:9200/facebook01/external/1?pretty -d '
{
    "name": "Natsu"
}'

curl -XGET http://localhost:9200/facebook01?pretty
curl -XGET http://localhost:9200/facebook01/external/1?pretty
```



#### 收缩
* 收缩API使您可以使用较少的分片将现有索引收缩为新索引。缩小的数量必须为原数量的因子（即原分片数量是新分片倍数），例如8个分片可以缩小到4、2、1个分片。
    如果原分片数量为素数则只能缩小到一个分片。在缩小开始时，每个收缩的复制都必须在同一节点（node）存在。
* 索引收缩的必要条件
    - 目标索引存在
    - 原索引主分片数量比目标索引多
    - 原索引主分片数量是目标索引倍数
    - 索引中的所有文档在目标索引将会被缩小到一个分片的数量不会超过 2,147,483,519 ，因为这是一个分片的承受的最大文档数量。
    - 处理收缩过程的节点必须具有足够的可用磁盘空间，以容纳现有索引的第二个副本

```shell script
curl -XPUT http://localhost:9200/customer?pretty
curl -XPUT -H "Content-Type: application/json" http://localhost:9200/customer?pretty -d '
{
    "settings": {
      "index":{
        "number_of_shards": 5,
        "number_of_replicas": 1
      }
    }
}'
curl -XGET http://localhost:9200/_cat/indices?v

# 索引收缩，收缩到新的索引上，收缩的数量必须是原来数量的因子
# 目标索引必须存在，收缩的节点必须有足够的空间，容纳新的副本

# step1: 原索引为 read-only
curl -XPUT -H "Content-Type: application/json" http://localhost:9200/customer/_settings -d '{
    "settings": {
        "index.blocks.write": true
    }
}'

# step2: 然后开始收缩索引
curl -XPOST -H "Content-Type: application/json" http://localhost:9200/customer/_shrink/customer01 -d '
{
    "settings": {
        "index.number_of_shards": 1,
        "index.number_of_replicas": 1,
        "index.codec": "best_compression"
    }
}'

```

#### 滚动
* 当现有索引被认为太大或太旧时，滚动索引API会将别名滚动到新的索引。
```shell script
# 创建索引 logs-0000001 别名为 apache_logs.
# 如果 apache_logs 指向的索引是在7天以前创建的，或者包含1000个以上的文档
# 则创建 logs-000002索引，并更新apache_l ogs别名指向 logs-000002
# 使用别名创建索引
curl -XPUT -H "Content-Type: application/json" localhost:9200/logs-000001 -d '
{
    "aliases": {
        "apache_logs": {}
    }
}'

# 创建滚动索引（按照时间和文档数量）
curl -XPOST -H "Content-Type: application/json" localhost:9200/apache_logs/_rollover -d '
{
    "conditions": {
        "max_age": "7d",
        "max_docs": 1000
    }
}'

history | grep external
```


### 文档操作
* 每个数据都会有版本，类似于乐观上锁的概念，小于某一个版本就会不让进行更新

```shell script
## 添加
curl -XPUT http://localhost:9200/customer02?pretty 
curl -XPOST -H "Content-Type: application/json" http://localhost:9200/customer02/external/1?pretty -d '{"doc": { "name": "Natsu", "age": 20}}' 
curl -XGET http://localhost:9200/customer02/external/1?pretty

## 删除
curl -XDELETE http://localhost:9200/customer02/external/1?pretty
curl -XGET http://localhost:9200/customer02/external/1?pretty
curl -XGET http://localhost:9200/_cat/indices?v

## 更新(doc 或者 script 更新其中之一)
curl -XPOST -H "Content-Type: application/json" http://localhost:9200/customer02/external/3?pretty -d '{"doc": { "name": "Natsu"}}'
curl -XGET http://localhost:9200/customer02/external/3?pretty
curl -XPOST -H "Content-Type: application/json" http://localhost:9200/customer02/external/3/_update?pretty -d '{"doc": { "name": "Natsu", "age": 20}}'
# 感觉结果跟预想的不一致(没有在原来的位置进行更新)
curl -XGET http://localhost:9200/customer02/external/3?pretty
# 可以使用Rest命令执行更新。如将年龄增加5：
curl -XPOST -H "Content-Type: application/json" http://localhost:9200/customer02/external/3/_update?pretty -d '{ "script": "ctx._source.age += 5" }'






#占用的磁盘用量
curl -XGET localhost:9200/_cat/allocation?v
curl -XGET localhost:9200/_cat/master?v


curl -XPOST -H "Content-Type: application/json"  http://localhost:9200/zhq_clq/external/1?pretty
 -d '{"doc": { "name": "Natsu", "age": 20}}'

```

### 操作例子


```shell script

# 创建一个索引
curl -XPUT localhost:9200/zhq_index1?pretty

# 索引一篇文档
curl -XPUT -H "Content-Type: application/json" localhost:9200/get-together/group/1?pretty -d '{"name":"Elasticsearch Denver", "origanizer":"Lee"}'
curl -XGET localhost:9200/get-together/_mapping?pretty  # 索引内所有类型的映射
curl -XGET localhost:9200/get-together/_mapping/group?pretty  # 索引具体类型(group)的映射


curl "localhost:9200/get-together/group/_search?q=elasticsearch&fields=name,location&size=1&pretty"

curl "localhost:9200/get-together/group/_search?q=elasticsearch&pretty"


curl -XPOST -H "Content-Type: application/json" 'localhost:9200/get-together/group/_search?pretty
' -d '{"query":{"query_string":{"query":"elasticsearch"}}}'

# 通过ID查询文档
curl 'localhost:9200/get-together/group/1?pretty'


curl 'localhost:9200/_cat/shards?v'


curl 'localhost:9200/get-together/group/_mapping?pretty'\

## 映射相关
curl -XPUT -H "Content-Type: application/json" 'localhost:9200/get-together/group/100' -d '{"name":"last night with elasticsearch", "date":"2013-10-25T19:00"}'

curl 'localhost:9200/get-together/_mapping/group?pretty'

# 创建映射
curl -XPUT -H "Content-Type: application/json" 'localhost:9200/get-together/_mapping/group' -d '{"group":{"properties":{"zhq_host":{"type":"text"}}}}'




curl -XPUT 'localhost:9200/zhq_together?pretty'
curl 'localhost:9200/_cat/indices?pretty'


curl -XPUT -H "Content-Type: application/json" 'localhost:9200/zhq_together/new_events/1?pretty' -d '{"name":"Late night with es ", "date":"2020-02-27"}'
curl -XPOST -H "Content-Type: application/json" 'localhost:9200/zhq_together/new_events/_search?pretty' -d '{"query":{"query_string":{"query":"late"}}}'


curl -XPUT -H "Content-Type: application/json" 'localhost:9200/zhq_blog/posts/1?pretty' -d '{"tags":["first", "initial"]}' 


curl -XPUT -H "Content-Type: application/json" 'localhost:9200/zhq_get/manual_id/1st?pretty' -d '{"name":"elasticsearch denver"}' 



#索引更新
curl 'localhost:9200/get-together/group/2?pretty'
curl -XPOST -H "Content-Type: application/json" 'localhost:9200/get-together/group/2/_update' -d '{"doc":{"organizer":"Roy"}}'

#通过一个文档来更新原来的索引
curl -XPUT -H "Content-Type: application/json" 'localhost:9200/online-shop/shirts/1?version=1' -d '{"caption":"zhq learning elasticsearch", "price":5}'


curl -XDELETE 'localhost:9200/online-shop/shirts/1?pretty'


#分页搜索
curl 'localhost:9200/get-together/_search?from=1&size=3&pretty'

curl 'localhost:9200/get-together/_search?sort=date:asc&pretty'

# 只搜索文档中的某几个字段
curl 'localhost:9200/get-together/_search?sort=date:asc&_source=name,description&pretty'

# 只在name中查找包含指定字段的数据
curl 'localhost:9200/get-together/_search?sort=date:asc&q=name:elasticsearch&pretty'


#基于请求主体的搜索
curl -XPOST -H "Content-Type: application/json" 'localhost:9200/get-together/_search?pretty' -d '{"query":{"match_all":{}}, "from":1, "size":3}'

curl -XPOST -H "Content-Type: application/json" 'localhost:9200/get-together/_search?pretty' -d '{"query":{"match_all":{}}, "_source":["name", "description"]}'

curl -XPOST -H "Content-Type: application/json" 'localhost:9200/get-together/_search?pretty' -d '{"query":{"match_all":{}}, "_source":{"include":["name", "description"], "exclude":["created_on"]}}'

curl -XPOST -H "Content-Type: application/json" 'localhost:9200/get-together/_search?pretty' -d '{"query":{"match_all":{}}, "sort":[{"created_on":"asc"},"_score"]}'


curl -XPOST -H "Content-Type: application/json" 'localhost:9200/get-together/_search?pretty' -d '{"query":{"match":{"name":"Elasticsearch"}}}'


curl -XPOST -H "Content-Type: application/json" 'localhost:9200/get-together/_search?pretty' -d '{"query":{"term":{"tags":"jvm"}}}'

```



## 

* 基于URL的搜索请求
* 基于主体的搜索请求

## 版本采坑（真TM多）

* 过滤查询已被弃用，并在ES 5.0中删除
* 6.0的版本不允许一个index下面有多个type，并且官方说是在接下来的7.0版本中会删掉type
* Elasticsearch从5.X就引入了text和keyword，其中keyword适用于不分词字段，搜索时只能完全匹配，这时string还保留着。
  到了6.X就彻底移除string了。
  另外，"index"的值只能是boolean变量了。
* 5.x之后，Elasticsearch对排序、聚合所依据的字段用单独的数据结构(fielddata)缓存到内存里了，但是在text字段上默认是禁用的，如果有需要单独开启，这样做的目的是为了节省内存空间
* 过滤查询已被弃用，并在ES 5.0中删除。
  解决： 使用bool / must / filter查询




## 映射







## 插件
X-Pack
Header






# ElasticSearch 云析学院
## 学习版本：5.6版本
## 实践版本：7.2版本

* 作用领域
    - 日志、电商、blog
    - 分布式调用链路追踪
    - 降价提醒、业务智能分析
* 基本概念
    - 集群
    - 节点    
    - ZenDiscovery 自动发现 命名服务
    - 分片 shared
    - 副本 replicas
    - types 
    - mappings
    - query DSL
    - 近实时搜索
    - 持久化更新
* 磁头
    - 悬浮
    - 冲停

### 
refresh
flush
fsync

默认分区策略：  5个分片  一个副本


## 第二节 Rest API
* 学习版本：5.6.16
* 实践版本：5.6.16


* 颜色状态
    * yellow 所有分片正常分布，但是副本缺失 
    * red 
    * green






### 文档
### 映射
### 集群
### 状态查询




```shell script
curl -X GET http://localhost:9200/_cat/health?help
curl -X GET http://localhost:9200/_cat/health?v
curl -X GET http://localhost:9200/_cat/health?format=yaml

```

## 第三节

## 第四节

## 第五节
















 






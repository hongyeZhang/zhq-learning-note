# 《Elasticsearch 实战》

## chapter1

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


### 索引操作
```shell script

curl -XGET http://localhost:9200/_cat/indices

# 创建facebook的索引  pretty 方便查看结果的
curl -XPUT http://localhost:9200/facebook?pretty   

curl -XGET http://localhost:9200/facebook?pretty
curl -XGET http://localhost:9200/facebook/_settings

curl -XGET http://localhost:9200/facebook01/_settings,_mapping?pretty

#判断是否存在
curl -XHEADER http://localhost:9200/facebook


#索引下线
curl -XPOST http://localhost:9200/facebook/_close
curl -XPOST http://localhost:9200/facebook/_open

curl -XPUT http://localhost:9200/facebook/external/1?pretty -d '{ "name": "Natsu"}'


#索引删除
curl -XDELETE http://localhost:9200/facebook?pretty

curl -XGET http://localhost:9200/_cat/indices?v

# 索引收缩
curl -XPUT http://localhost:9200/customer?pretty
$ curl -XPOST http://localhost:9200/customer/_shrink/customer01 -d '
{
"settings": {
"index.number_of_shards": 1,
"index.number_of_replicas": 1,
"index.codec": "best_compression"
}
}'


# 先设置原索引为read-only
curl -XPUT http://localhost:9200/customer/_settings -d '{
    "settings": {
        "index.blocks.write": true
    }
}'

# 然后开始收缩索引
$ curl -XPOST http://localhost:9200/customer/_shrink/customer01 -d '
{
    "settings": {
        "index.number_of_shards": 1,
        "index.number_of_replicas": 1,
        "index.codec": "best_compression"
    }
}'









```



当现有索引被认为太大或太旧时，滚动索引API会将别名滚动到新的索引。
```shell script
# 创建索引 logs-0000001 别名为 apache_logs.
# 如果 apache_logs 指向的索引是在7天以前创建的，或者包含1000个以上的文档
# 则创建 logs-000002索引，并更新apache_logs别名指向logs-000002
curl -XPUT localhost:9200/logs-000001 -d '
{
    "aliases": {
        "apache_logs": {}
    }
}'

# 创建滚动索引（按照时间和文档数量）
curl -XPOST localhost:9200/apache_logs/_rollover -d '
{
    "conditions": {
        "max_age": "7d",
        "max_docs": 1000
    }
}'

```



```shell script

#文档操作
curl -XPUT -H "Content-Type: application/json" http://localhost:9200/facebook/external/1?pretty -d '
{
    "name": "Natsu"
}'

curl -XGET http://localhost:9200/customer/external/1?pretty

#删除
$ curl -XDELETE http://localhost:9200/customer/external/1?pretty


$ curl -XPOST -H "Content-Type: application/json" http://localhost:9200/customer/external/2/_update?pretty -d '{"doc": { "name
": "Natsu", "age": 20}}'

#  可以使用Rest命令执行更新。如将年龄增加5：
$ curl -XPOST http://localhost:9200/customer/external/2/_update?pretty -d '{ "script": "ctx._source.age += 5" }'



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
## 5.6版本

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

### 版本：5.6.16
refresh
flush
fsync

默认分区策略：  5个分片  一个副本









 






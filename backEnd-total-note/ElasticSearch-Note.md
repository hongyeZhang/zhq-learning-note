# Elasticsearch 学习笔记


## 学习参考资料
* 系统学习ElasticSearch
    * https://zhuanlan.zhihu.com/p/135939591




## 前言
* word学习笔记见文件夹
* 学习版本：5.6版本
* 实践版本：7.2版本





## chapter1 概述

* 安装及启动
    * 默认不允许root用户运行  
    * ./elasticsearch -Des.insecure.allow.root=true
    * vim /etc/sysctl.conf
    * chown -R zhq:zhq elasticsearch-5.6.16
    * chown -R zhq:zhq elasticsearch-6.8.6
 
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

```shell script
curl -X GET http://localhost:9200/_cat/health?help
curl -X GET http://localhost:9200/_cat/health?v
curl -X GET http://localhost:9200/_cat/health?format=yaml

```

* 作用领域
    - 日志、电商、blog
    - 分布式调用链路追踪
    - 降价提醒、业务智能分析
    - 反向搜索
       * 价格监控
       * 新闻警报
       * 股票警告
       * 日志监控
       * 天气预报
       * 库存警报
* 基本概念
    - 集群
    - 节点    
    - ZenDiscovery 自动发现 命名服务  自动将节点加到集群中
    - 分片 shared
    - 副本 replicas  有的公司（linkedin）不用副本，因为影响性能，用在数据不重要的情况下。
    - types 类似于table
    - mappings  类似于 schema
    - query DSL
    - 近实时搜索  内存缓存 -> 文件系统缓存 -> 硬盘磁盘, 认为写到文件系统缓存中，就可以搜索出来了
    - 持久化更新  translog 通过提交日志，进行持久化更新
* 磁头
    - 悬浮
    - 冲停


## chapter2 Rest API

* 颜色状态
    * yellow 所有分片正常分布，但是副本缺失 
    * red 
    * green

### 索引操作
* 索引默认是json格式  但是可以人为指定 yml 格式
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
* 不允许修改分片（分片一旦确定下来，就不能修改），可以修改副本

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

#### 状态查询

```shell script
curl -X GET localhost:9200/_cat/allocation?pretty
curl -X GET localhost:9200/_cat/allocation?help
curl -X GET localhost:9200/_cat/shards?pretty
curl -X GET localhost:9200/_cat/shards/customer?pretty
# 查询段信息
curl -X GET localhost:9200/_cat/segments?pretty
# 查询群集的文档数
curl -X GET localhost:9200/_cat/count?v
#线程池状态查询
curl -X GET localhost:9200/_cat/thread_pool?v
```

## chapter3 mapping
* mapping ~= schema  元数据定义
* 在创建数据时，可以通过mapping指定数据类型。同样也可以不指定，通过es的自动推断实现

### 映射

* text 可以被全文搜索。字段内容会被分析，再生成倒排索引。不能够排序，很少用于聚合。
* keyword  keyword类型适用于索引结构化的字段，比如email地址、主机名、状态码和标签。如果字段需要进行过滤、排序、聚合，
    则需要keyword字段类型。keyword类型的字段只能通过精确值搜索到。
* object  使用JSON天然的格式来自动推断Object。
* array  ES没有专用的数组类型，默认情况下任何字段都可以包含一个或者多个值，但是一个数组中的值要是同一种类型。
* binary  binary类型默认不存储也不可以被搜索，接受base64编码的字符串。
* ip  ip类型的字段用于存储IPV4或者IPV6的地址。
* range  range类型支持： integer_range, float_range, long_range, double_range, date_range, ip_range
* nested  nested嵌套类型是object中的一个特例，可以让array类型的Object独立索引和查询。
* token_count  token_count字段是一个数值字段，但是它接受的是字符串。会对接受的字符串进行分析，然后索引字符串的词数。
* geo_point  geo_point 类型的字段接受纬度-经度对，可以使用： 
	* 找出落在指定矩形框、多边形、圆形中的坐标点
	* 以地理位置 或距中心点的距离汇总文档
	* 按距离打分
	* 按距离排序
* date  elasticsearch中没有date类型，通过折中的方式来处理








```shell script

curl -X PUT localhost:9200/customer01?pretty
curl -X GET localhost:9200/_cat/indices/customer01?v
curl -X GET localhost:9200/customer01?pretty

curl -X GET localhost:9200/_cat/indices?v
curl -X DELETE localhost:9200/custo*?pretty
curl -XPOST -H "Content-Type: application/json" http://localhost:9200/customer01/external/1?pretty -d '{"name": "Natsu", "age": 20}'

#查看数据的信息
curl -X GET localhost:9200/customer01/external/1?pretty
#查看索引的信息
curl -X GET localhost:9200/customer01?pretty
# elasticsearch-7 上执行失败，elasticsearch-7 默认不支持指定索引类型
curl -XPUT -H "Content-Type: application/json" localhost:9200/customer02 -d '
{
    "mappings": {
        "my_type": {
            "properties": {
                 "name": {
                     "type": "text"
                 }
            }
        }
    }
}'


# 创建birth为date型的索引
$ curl -XPUT localhost:9200/customer04 -d '
{
    "mappings": {
        "my_type": {
            "properties": {
                 "birth": {
                     "type": "date"
                 }
            }
        }
    }
}'

# 以字符串date型插入第一个文档
$ curl -XPUT localhost:9200/customer04/my_type/1 -d
  '{ "birth": "2019-11-18" }'

# 以long型时间插入第二个文档
$ curl -XPUT localhost:9200/customer04/my_type/2 -d
  '{ "birth": 1574006400 }'

# 以字符串date型插入第一个文档三
$ curl -XPUT localhost:9200/customer04/my_type/3 -d
  '{ "birth": "2018-11-18T21:04:33Z" }'

# 对birth字段进行排序
$ curl -XGET localhost:9200/customer04/my_type/_search -d
  '{ "sort": { "birth": "asc" } }'


#object 对象
curl -X PUT -H "Content-Type: application/json" localhost:9200/customer05/my_type/1 -d '
{
    "provinvce": "beijing",
    "programmer": {
        "name": "Natus",
        "age":  25
    }
}'


# nested 映射类型创建
$ curl -XPUT localhost:9200/customer09 -d '
{
    "mappings": {
        "my_type": {
            "properties": {
                 "user": {
                     "type": "nested"
                 }
            }
        }
    }
}'

$ curl -XPUT localhost:9200/customer09/my_type/1 -d '
{
    "user": [
      { "name": "abcd", "age":  23},
      { "name": "def",  "age":  25},
      { "name": "aim",  "age":  27}
   ]
}'

#geo 测试实例
curl -XPUT localhost:9200/customer11 -d '
{
    "mappings": {
        "my_type": {
            "properties": {
                 "location":{
				     "type": "geo_point"
				 }
            }
        }
    }
}'

# 插入Geo坐标数据
curl -XGET localhost:9200/customer11/my_type/1 -d '
{
    "location":{
	   "lat": 41.12,
	   "lon": -71.34
	}
}'





```




## Chapter3 映射参数和别名

### mapping
* analyzer  指定分析器，对索引和查询都有效
* normalizer  用于解析前过滤工作，比如：把所有字符转化为小写
* coerce  coerce属性用于清除脏数据，coerce的默认值是true。整型数字5有可能会被写成字符串"5"或者浮点数5.0。coerce属性可以用来清除脏数据：
    * 字符串会被强制转换为整数
    * 浮点数被强制转换为整数
* copy_to  copy_to属性用于配置自定义的_all字段（多个字段合并成一个超级字段）。比如，first_name和last_name可以合并为full_name字段。
* doc_values  doc_values是为了加快排序、聚合操作，在建立倒排索引的时候，额外增加一个列式存储映射，是一个空间换时间的做法。默认是开启的，
    对于确定不需要聚合或者排序的字段可以关闭。
* dynamic  dynamic属性用于检测新字段，有三个选项：
    * true：新发现的字段自动添加到映射中
    * false：新发现的字段被忽略，必须显式添加字段
    * strict：如果检测到新字段，抛出异常并拒绝添加文档。
* enabled ES默认会索引所有的字段。但是enabled为false的字段，ES会跳过字段的内容，不可以被搜索，可以从_source字段中获取内容。
* fielddata
    * 多数字段在索引时生成doc_values，但是text字段不支持doc_values。
    取而代之，text字段在查询时会生成一个fielddata的数据结构，fielddata在字段首次被聚合、排序、或者使用脚本的时候生成。
    ES通过读取磁盘上的倒排记录表重新生成文档词项关系，最后在Java堆内存中排序。
    text字段的fielddata属性默认是关闭的，开启fielddata非常消耗内存。在你开启text字段以前，想清楚为什么要在text类型的字段上做聚合、排序操作。
        大多数情况下这么做是没有意义的。
* format  format属性主要用于格式化日期
* ignore_above  ignore_above用于指定字段索引和存储的长度最大值，超过最大值的会被忽略
* ignore_malformed  ignore_malformed可以忽略不规则数据。给一个字段索引不合适的数据类型发生异常，导致整个文档索引失败。如果ignore_malformed
    参数设为true，异常会被忽略，出异常的字段不会被索引，其它字段正常索引。
* fields  出于多领域应用的目的，以不同的方式对同一字段建立索引通常很有用。例如，一个string 字段可以映射为text用于全文搜索的字段，
    也可以映射为keyword用于排序或聚合的字段。
* properties  Object类型或者nested类型，因为有层级嵌套，所以我们可以通过properties来指定这种层级嵌套关系。
* store  默认情况下，字段被索引也可以搜索，但是不存储，因为_source字段里面保存了一份原始文档。在某些情况下，比如一个文档里面
    有title、date和超大的content字段，如果只想获取title和date。

```shell script

# elasticsearch-7 测试失败
curl -XPUT -H "Content-Type: application/json" localhost:9200/customer0001 -d '{
    "mappings": {
	    "my_type": {
		    "properties": {
			    "content": {
				    "type": "text",
					"analyzer": "standard",
					"search_analyzer": "standard"
				}
			}
		}
	}
}'


$ curl -XPUT localhost:9200/customer0002 -d '{
    "settings": {
	    "analysis": {
		    "normalizer": {
			    "normalizer01": {
				     "type": "custom",
					 "char_filter": [],
					 "filter": ["lowercase", "asciifolding"]
				}
			}
		}
	},
    "mappings": {
	    "my_type": {
		    "properties": {
			    "name": {
				    "type": "keyword",
					"normalizer": "normalizer01"
				}
			}
		}
	}
}'

$ curl -XPUT localhost:9200/customer0002/my_type/1 -d '{"name":"NAA"}'
$ curl -XPUT localhost:9200/customer0002/my_type/2 -d '{"name":"naa"}'
$ curl -XPUT localhost:9200/customer0002/my_type/3 -d '{"name":"NaA"}'
$ curl -XGET localhost:9200/customer0002/my_type/_search -d '
{
   "query": {
       "match": {
           "name": "nAa"
       }
   }
}
'


```


### 动态Mapping
ES中有一个非常重要的特性——动态映射，即索引文档前不需要创建索引、类型等信息，在索引的同时会自动完成索引、类型、映射的创建。
映射就是描述字段的类型、如何进行分析、如何进行索引等内容。 
ES在文档中碰到一个以前没见过的字段时，它会利用动态映射来决定该字段的类型，并自动地对该字段添加映射。这个可以通过dynamic属性去控制，
dynamic属性为false会忽略新增的字段、dynamic属性为strict会抛出异常。如果dynamic为true的话，es会自动根据字段的值推测出来类型进而确定mapping。

#### 动态模板
通过 dynamic_templates，可以拥有对新字段的动态映射规则拥有完全的控制。可以设置根据字段名称或者类型来使用一个不同的映射规则。
每个模板都有一个名字，可以用来描述这个模板做了什么。同时它有一个 mapping 用来指定具体的映射信息，和至少一个参数（比如 match）用来规定对于什么字段需要使用该模板。
模板的匹配是有顺序的 - 第一个匹配的模板会被使用。
```shell script
curl -XPUT localhost:9200/customer0014 -d '{
    "mappings": {
	    "my_type": {
		    "dynamic_templates": [{
			    "long_to_string": {
                    # 适配的类型
					"match_mapping_type": "string",
                    
                    # 匹配的字段
					"match": "age_*",
                    
                    # 不进行匹配处理的字段
					"unmatch": "*_age",

                    # 最终匹配会转成long类型
					"mapping": {
						"type": "long"
					}
				}
			}]
		}
	}
}'

```



### 别名
#### 什么是索引别名？
它是一个或多个索引的一个附加名称，允许使用这个名称来查询索引。一个别名可以对应多个索引。反之亦然，一个索引可以是多个别名的一部分。
但不能使用对应多个索引的别名来进行索引或实时GET操作。如果你这样做，Elasticsearch将抛出一个异常（但可以使用对应单个索引的别名来进行索引操作），
因为Elasticsearch不知道应该把索引建立到哪个索引上，或从哪个索引获取文档。

* 使用别名的好处
    *提高检索效率
    *简化代码控制
    *控制冷热数据 

* 索引别名是个很有使用价值的功能，多了别名这一层封装，可以方便的控制数据访问范围、切换索引、重建索引等，好处就是后端应用不会感知。
* 索别名就像一个快捷方式或软连接，可以指向一个或多个索引，也可以给任何一个需要索引名的API来使用。别名带给我们极大的灵活性，允许我们做下面这些：
	* 在运行的集群中可以无缝的从一个索引切换到另一个索引
	* 给多个索引分组
	* 给索引的一个子集创建视图
* 有两种方式管理别名： 
	* _alias 用于单个操作
	* _aliases 用于执行多个原子级操作。

```shell script
#建立别名之前需要先建立索引
curl -XPUT http://localhost:9200/customer0016?pretty
curl -XGET http://localhost:9200/_cat/indices?v
curl -XGET http://localhost:9200/customer0016?pretty
#创建别名
curl -XPUT http://localhost:9200/customer0016/_alias/my_index?pretty
#查看别名
curl -XGET http://localhost:9200/_cat/aliases?v

# 别名不仅仅可以关联一个索引，它能聚合多个索引
$ curl -XPOST localhost:9200/_aliases?pretty -d '
{
    "actions": [{
        "add": {
            "index": "customer001",
            "alias": "alias003"
        }
    },
    {
        "add": {
            "index": "customer002",
            "alias": "alias003"
        }
    }]
}'

# 查看别名
curl -XGET localhost:9200/alias003?pretty

#查看拥有此别名的所有的索引
curl -XGET http://localhost:9200/*/_alias/my_index?pretty
curl -XGET http://localhost:9200/_all/_alias/my_index?pretty

```


### 别名实际运用
* 过滤
    * 带过滤器的别名提供了一个十分简单的方式来创建同一个index下的不同的“展示”。过滤器能够使用Query DSL来定义并且被应用到所有的搜索，计数，通过查询删除和其它类似的行为
```shell script
curl -XPUT localhost:9200/customer0021 -d '{
    "mappings": {
	    "user": {
		    "properties": {
			    "name": {
					"type": "string",
					"index": "not_analyzed"
				}
			}
		}
	}
}'

$ curl -XPOST localhost:9200/_aliases -d '
{
  "actions": [
    {
      "add": {
        "index": "customer0021",
        "alias": "filter_alias001",
        "filter": { "term" : { "name" : "Michael" } }
      }
    },
    {
      "add": {
        "index": "customer0021",
        "alias": "filter_alias002",
        "filter": { "term" : { "name" : "Jackson" } }
      }
    },
    {
      "add": {
        "index": "customer0021",
        "alias": "filter_alias003"
      }
    }
  ]
}'
```  

* 指定路由
    * ES默认所有分片查询然后汇总结果。

```shell script
curl -XPUT localhost:9200/customer001?pretty
curl -XPOST -H "Content-Type: application/json" localhost:9200/_aliases?pretty -d '{
    "actions": [
    {
      "add": {
        "index": "customer001",
        "alias": "alias001",
        "index_routing": "2","search_routing": "1,2"
      }
    },
    {
      "add": {
        "index": "customer001",
        "alias": "alias002",
        "index_routing": "1","search_routing": "2,3"
      }
    }
  ]
}'

#测试指定路由之后，每个查询的结果是否包含给定的数据
# 插入数据
curl -XPUT -H "Content-Type: application/json" localhost:9200/alias001/user/1?pretty -d '{ "name": "Johnson" }'
curl -XPUT -H "Content-Type: application/json" localhost:9200/alias001/user/2?pretty -d '{ "name": "Micheal" }'
curl -XPUT -H "Content-Type: application/json" localhost:9200/alias002/user/3?pretty -d '{ "name": "Jackson" }'
# 查询数据
curl -XGET http://localhost:9200/alias001/_search?pretty
curl -XGET http://localhost:9200/alias002/_search?pretty
```


* 零停机迁移索引

```shell script
 # 创建索引
curl -XPUT -H "Content-Type: application/json" localhost:9200/customer002?pretty

# 给索引customer002添加文档数据
curl -XPUT -H "Content-Type: application/json" localhost:9200/customer002/user/1?pretty -d '{ "name": "Johnson" }'

# 为索引创建别名
curl -XPUT localhost:9200/customer002/_alias/my_index?pretty
curl -XGET localhost:9200/my_index?pretty
curl -XGET localhost:9200/customer002?pretty

# 创建索引customer003
curl -XPUT localhost:9200/customer003?pretty

# 重建索引
curl -XPOST -H "Content-Type: application/json" localhost:9200/_reindex?pretty -d '{
    "source": { "index": "customer002" },"dest":   { "index": "customer003" }}'

curl -XGET localhost:9200/customer003?pretty
# 从别名中移除customer002索引，添加customer003索引
curl -XPOST -H "Content-Type: application/json" localhost:9200/_aliases?pretty -d '{
    "actions": [
       { "remove": { "index": "customer002", "alias": "my_index" } },
       { "add":    { "index": "customer003", "alias": "my_index" } }
  ]
}'	
```

### 集群
* 集群健康状态(/_cluster/health)
* 集群状态(/_cluster/state)
* 集群的统计信息(/_cluster/stats)
* 节点的状态(_nodes/state)
* 节点的统计信息(_nodes/stats)




## chapter5 Elasticsearch DSL
### 全文搜索
全文查询，用于对分词的字段进行搜索。会用查询字段的分词器对查询的文本进行分词生成查询。可用于短语查询、模糊查询、前缀查询、临近查询等查询场景。

* match
    * 全文查询的标准查询，它可以对一个字段进行模糊、短语查询。 match queries 接收 text/numerics/dates, 对它们进行分词分析, 再组织成一个boolean查询。match查询可通过operator 指定bool组合操作（or、and 默认是 or ）， 还可以通过minimum_should_match指定至少需多少个字句需满足，还可使用ananlyzer指定查询用的特殊分析器。


```shell script

curl -XGET http://localhost:9200/shakespeare?pretty

curl -XGET -H "Content-Type: application/json" localhost:9200/shakespeare/_search?pretty -d '
{
    "query": {"match": {"text_entry": "men flight"}}
}'

curl -XGET localhost:9200/shakespeare/_search?pretty -d '
{
    "query": {
	    "match": {
		    "text_entry": {
                        "query": "perjury unjust flight",
                        "minimum_should_match": 1
                    }
		}
	}
}'


```


* match_phrase
    * match_phrase 查询用来对一个字段进行短语查询，可以指定 analyzer、slop跨度。

* match_phrase_prefix
* multi_match
    * multi_match在 match的基础上支持对多个字段进行文本查询。
```shell script
#在两个fields中进行寻找，是或的关系
curl -XGET -H "Content-Type: application/json" localhost:9200/shakespeare/_search?pretty -d '
{
    "query": {"multi_match": {"query": "dream flight","fields": ["text_entry", "play_name"]}}
}'



```
* query_string
    * 使用查询语法（Lucene）写成一个查询字符串进行查询。通过查询解析器然后进行查询生成对应的结果
    * field
    * 通配符
        * 通配符搜索可以使用？替换单个字符，或者使用*号替换零个或者多个多个字符：
    * 正则表达式
        * 可以使用正则表达式嵌入到查询的字符串中：
    * 模糊
        * 使用模糊运算符搜索与我们的搜索字词类似但不完全相同的字词：
    * 邻近
        * 与模糊查询可以为单词中的字符指定最大编辑距离的方式相同，邻近搜索允许我们指定短语中单词的最大编辑距离： 
    * 范围
        * 为日期、数字或者字符串指定查询范围。[min TO max]代表指定包含范围，{min TO max}代表指定排它范围。
    * 布尔
        * 默认情况下，只要一个词匹配，其他词都是可选的。搜索dream flight men将查找包含一个或多个dream，或flight，或 men任何文档。但如果我们想强制要求所有的术语，则可以通过布尔查询，来进行更多的控制：
    * 分组
        * 

```shell script
curl -XGET -H "Content-Type: application/json" localhost:9200/shakespeare/_search?pretty -d'
{
    "query": {"query_string": {"default_field": "play_name","query": "take OR flight OR dream"}}
}'



```



* simple_query_string
    * simple_query_string 同 query_string 查询一样用lucene查询语法写查询串，和query_string不同的地方是：
        * 具有更小的语法集；
        * 查询串有错误，会忽略错误的部分，不抛出错误。



### 词项搜索
### Term Query

```shell script
curl -XGET -H "Content-Type: application/json" localhost:9200/shakespeare/_search?pretty -d'
{
    "query": {"terms": { "play_name": ["night", "dream"] }}
}'



```





### Terms Query

```shell script
curl -XGET -H "Content-Type: application/json" localhost:9200/shakespeare/_search?pretty -d'
{
    "query": {"terms": { "play_name": ["night", "dream"] }}
}'

# 可以通过类似SQL子查询的方式进行搜索
# SQL助记：select * from shakespeare where text_entry in(select play_name from shakespeare where id = .....)
curl -XGET -H "Content-Type: application/json" localhost:9200/shakespeare/_search?pretty -d'
{
    "query": {"terms": {"text_entry": {"index": "shakespeare","type": "_doc","id": "105112","path": "play_name"}}}
}'
```

### Range Query

```shell script
curl -XGET -H "Content-Type: application/json" localhost:9200/shakespeare/_search?pretty -d'
{
    "query": {"range": {"speech_number": {"gte": 3,"lte": 5,"boost": 2.0}}}
}'
```

### Prefix Query
```shell script
curl -XGET -H "Content-Type: application/json" localhost:9200/shakespeare/_search?pretty -d'
{
    "query": {"wildcard": { "play_name": "t*th" }}
}'
```

### Regexp Query

### Fuzzy Query

### Ids Query


### 复合查询
* 定值打分  将查询匹配的文档的评分设为一个常值。
    * Query context 查询上下文
        * 用在查询上下文中的字句查询的结果是：“这个文档有多匹配这个查询”。除了决定文档是否匹配，字句匹配的文档还会计算评分，来评定文档有多匹配，会参与相关性评分。查询上下文由 query 元素表示。
    * Filter context 过滤上下文
        * 过滤上下文由 filter 元素或 bool 中的 must not 表示。用在过滤上下文中的字句查询的结果是：“这个文档是否匹配这个查询”，不参与相关性评分。

```shell script
curl -XGET -H "Content-Type: application/json" localhost:9200/shakespeare/_search?pretty -d'
{
    "query": {"constant_score": {"filter": {"term": { "play_name": "night" }},"boost": 1.5}}
}'



```

## 布尔查询
Bool 查询用bool操作来组合多个查询字句为一个查询。
```shell script
curl -XGET -H "Content-Type: application/json" localhost:9200/shakespeare/_search?pretty -d'
{
    "query": {
        "bool": {
            "must": {
               "term": { "text_entry": "dream" }
            },
            "must_not": {
               "term": { "play_name": "night" }
            },
            "should": [
                { "term": { "text_entry": "flight" } },
                { "term": { "text_entry": "the" } }
            ]
        }
    }
}'

```




### 函数打分
* weight  设置一个数值作为权重，文档的分数会乘以这个权重
* random_score  得到 0 到 1 随机分数。
* field_value_factor
    * 将某个字段的值进行计算得出分数。该方式有2个重要的参数：factor和modifier。其中，factor属性对字段值进行预处理，modifier对字段再次进行处理。
    * 计算公式：_score = modifier( field*factor )
* 衰减函数  以某个字段值为标准，离标准值越近的分值越高。
    * origin(原点，期望值)
    * offset(偏移值)
    * scale(衰减范围)
    * decay(衰减值)
* script_score  通过自定义脚本计算分值。



```shell script

curl -XGET -H "Content-Type: application/json" localhost:9200/shakespeare/_search?pretty -d'
{
  "query": {
    "function_score": {
      "query": {
        "match_all": {}
      },
      "boost": "5",
      "functions": [
        {
          "filter": {
            "match": {
              "text_entry": "dream"
            }
          },
          "weight": 33
        }
      ],
      "score_mode": "max",
      "boost_mode": "multiply"
    }
  }
}'











```

### Boosting Query
用于给定查询匹配的结果有效降级（降低的相关度，将它们的排序更靠后）。与布尔查询中的“ NOT”子句不同的是，它仍会返回包含词的文档，但会降低其总体得分。


### 关联查询
* join 一般不建议使用，谨慎使用

* 路由  
    * 索引路由(index)
    * 搜索路由(search)


### 特定查询
* MLT Query (mor like this)  查询与给定文档相似的文档
查询与给定文档“相似”的文档。如：查询所有商品中“标题”和“描述”字段中都包含类似于“xxxx”的文字，并将Term的数量限制为5个：
```shell script
curl -XGET -H "Content-Type: application/json" localhost:9200/shakespeare/_search?pretty -d'
{
  "query": {
    "more_like_this": {
      "like": "as well as",
      "fields": [
        "play_name",
        "text_entry"
      ],
      "min_term_freq": 1,
      "max_query_terms": 5
    }
  }
}'

curl -XGET -H "Content-Type: application/json" localhost:9200/shakespeare/_search?pretty -d'
{
  "query": {
    "more_like_this": {
      "fields": [
        "play_name",
        "text_entry"
      ],
      "like": [
        {
          "_index": "blog",
          "_type": "doc",
          "_id": 1
        },
        {
          "_index": "abcd",
          "_type": "doc",
          "_id": 2
        },
        "English and French"
      ],
      "min_term_freq": 1,
      "max_query_terms": 5
    }
  }
}'
```


MLT的工作原理：假如想查找与给定输入文档相似的所有文档，那么可以肯定的是：输入文档本身应该是该类型查询的最佳匹配。根据Lucene评分公式，输入文档中tf-idf最高的术语可以很好地代表该文档。MLT查询所做的是仅从输入文档中提取文本，然后选择tf-idf最高的前K个词构成查询。
要使用MLT，涉及的字段必须建立索引，并且其类型为text或keyword。另外，当对文档使用like时，必须启用_source，或必须为stored，或存储term_vector。
为了加快查询速度，可以在索引时指定term_vector是否存储


* Script Query
* 该查询允许脚本充当过滤器，通常是在过滤上下文中使用：
    * query context 有打分
    * filter context 无打分，被缓存
```shell script
curl -XGET -H "Content-Type: application/json" localhost:9200/shakespeare/_search?pretty -d'
{
  "query": {
    "bool": {
      "filter": {
        "script": {
          "script": {
            "lang": "painless",
            "source": "doc.line_id.value > 1"
          }
        }
      }
    }
  }
}'


# 为了加快执行速度，脚本会被编译和缓存。
# 如果使用相同的脚本，只是参数不同，那么最好的方式是将参数传递给脚本。
curl -XGET -H "Content-Type: application/json" localhost:9200/shakespeare/_search?pretty -d'
{
   "query": {
      "bool": {
         "filter": {
            "script": {
               "script": {
                   "lang": "painless",
                   "source": "doc.line_id.value > params.value",
                   "params": {
                      "value": 80
                   }
               }
            }
         }
      }
   }
}'

```




* Template Query(6.X版本之上就不存在了)

## chapter8 Elasticsearch 脚本
### elasticsearch 表达式
* 使用脚本，可以在Elasticsearch中评估自定义表达式。例如，可以使用脚本来返回“脚本字段”作为搜索请求的一部分，或者评估查询的自定义分数。“painless
”为默认的脚本语言。painless、expression为Elasticsearch内置支持。
在Elasticsearch API中使用脚本都遵循相同的格式：
* 5.x版本支持groovy、javascript、python、java等语言，javasript、python需要安装模块支持。
* 6.x版本增加了mustach内置支持，取消groovy、javascript、python支持，java需要自己写插件进行支持。


```shell script
"script": {
    # 指定脚本表达式的语言
    "lang": "painless|expression|groovy|javascript|mustach|python|java",
    # 加载脚本的方式：source源码，id已经存在的脚本，file存储在文件中的脚本
    "source" | "id" | "file": ".....",
    "params": { ..... }
}

curl -XGET -H "Content-Type: application/json" localhost:9200/shakespeare/_search?pretty -d'
{
  "script_fields": {
    "my_field": {
      "script": {
        "lang": "painless",
        "source": "doc.line_id.value * params.value",
        "params": {
          "value": 2
        }
      }
    }
  }
}'

```
* painless和expression是默认内置的脚本表达式。painless是默认的脚本语言。
* 使用_scripts RestAPI将脚本存储在集群中或者使用已经存储在集群中的脚本。
* 默认情况下，所有脚本都是被缓存的，因此仅在更新时才需要重新编译它们，它没有过期时间。script.cache.expire
* 默认情况下，脚本没有超时期限，但是可以使用 script.cache.expire 设置更改此行为
* 默认情况下，脚本缓存大小为100M。可以使用 script.cache.max_size 设置配置此缓存的大小。

* 存在文件中的脚本
    * 6.x上该功能已经取消
    * 为了提高安全性，非沙盒语言只能在群集的每个节点上存储的脚本文件中指定，脚本目录的默认位置：$ES_HOME/config/scripts
* 节点启动的时候会自动编译，加载到缓存中。默认60s自动编译一次，可以通过 resource.reload.interval 设置默认自动加载时间。

```shell script
#创建脚本
curl -XPOST -H "Content-Type: application/json" localhost:9200/_scripts/my_score?pretty -d'
{
  "script": {
    "lang": "painless",
    "source": "doc.line_id.value * params.value"
  }
}'
#查看脚本
curl -XGET localhost:9200/_scripts/my_score?pretty

#根据脚本查询
curl -XGET -H "Content-Type: application/json" localhost:9200/shakespeare/_search?pretty -d'
{
  "script_fields": {
    "my_field": {
      "script": {
        "id": "my_score",
        "params": {
          "value": 2
        }
      }
    }
  }
}'

```

* 脚本引擎
    * ScriptEngine是用于实现脚本语言的后端。它也可以用于编写需要使用脚本内部高级功能的脚本。例如，一个脚本希望在评分时使用词频。需要实现ScriptEngine
    ，同时应实现ScriptPlugin接口并覆盖getScriptEngine方法。

* Lucene表达式把javascript编译成字节码。主要使用目的：高性能自定义排名和排序而设计。
* Lucene表达式支持Javascript语法的子集，是使用基于JavaScript的语法指定的表达式。可以使用以下方式构造表达式：
    * 整数，浮点数，十六进制和八进制文本
    * 算术运算符：+ - * / %   | & ^ ~ << >> >>>
    * 布尔和三元运算符：       && || ! ?:
    * 比较运算符:                    < <= == >= >
    * 常用数学函数：              abs ceil exp floor ln log10 logn max min sqrt pow
    * 三角函数库：                  acosh acos asinh asin atanh atan atan2 cosh cos sinh sin tanh tan
    * 距离函数：                     haversin
    * 其他功能：                     min  max



### lucene 表达式
### Painless 表达式



## chapter9 Elasticsearch 插件
### X-Pack 插件
安全
审计
监控 ==> 收集 ==> kibana
告警 ==> email

X-Pack是一个Elastic Stack(ELK)扩展
安装要找到与ES对应的版本，但是7.0之后，默认会安装X-Pack

配置文件写在 elasticsearch.yml中


账户和密码
elastic/changeme
kibana/changeme
logstash-system/changeme

* 开启xpack和设置用户名密码
```shell script
# 修改config目录下面的elasticsearch.yml文件，添加如下代码到文件末，开启x-pack验证，并重启 elasticsearch服务
xpack.security.enabled: true
xpack.security.transport.ssl.enabled: true

#设置用户名和密码的命令，这里需要为多个用户分别设置密码，全部都是 123456
bin/elasticsearch-setup-passwords interactive
需要设置密码的账户
[apm_system]
[kibana]
[logstash_system]
[beats_system]
[remote_monitoring_user]
[elastic]


开启安全认证之后的查询方式
curl -XGET -u elastic:123456 localhost:9200/_cat/indices?pretty
curl -XGET -u elastic:123456 localhost:9200/.security-7?pretty



```
* 安全设置
    * 字段(field)级别的安全和文档(document)级别的安全
    * 各种参数设置
* 监控设置
    * 定义怎样搜集数据 
* 审核设置
    * 
* 告警设置
    * 注意必须打开监控

* 本地导出器
* HTTP导出器

#### 使用插件
* 用户管理
* 角色管理
* 权限管理
* 字段和文档级安全

```shell script
#查看证书
curl -XGET -u elastic:123456 localhost:9200/_xpack/license?pretty
curl -XGET -u elastic:123456 localhost:9200/_xpack?


#查看所有的用户信息
curl -XGET -u elastic:123456 localhost:9200/_xpack/security/user?pretty

#修改用户密码

#新增用户
curl -XPOST -H "Content-Type:application/json" -u elastic:123456 localhost:9200/_xpack/security/user/zhq -d'
{
  "password": "123456",
  "roles": [
    "admin",
    "other_role1"
  ],
  "full_name": "hanghuanqiang",
  "email": "zhq@test.com"
}'
 
# 查看用户 
$ curl -XGET -u elastic:abcd_123 localhost:9200/_xpack/security/user?pretty

# 禁用用户
$ curl -XPOST -u elastic:abcd_123 localhost:9200/_xpack/security/user/yunxi/_disabled

# 启用用户
$ curl -XPOST -u elastic:abcd_123 localhost:9200/_xpack/security/user/yunxi/_enabled

# 删除用户
$ curl -XDELETE -u elastic:abcd_123 localhost:9200/_xpack/security/user/yunxi
```


* 角色管理
```shell script
# 查看所有的角色
curl -XGET -u elastic:123456 localhost:9200/_xpack/security/role?pretty

# 创建角色，进行文档级别控制（但是basic版本的xpack不支持到文档级别的控制）
curl -XPOST -H "Content-Type:application/json" -u elastic:123456 localhost:9200/_xpack/security/role/my_role -d'
{
  "cluster": [
    "all"
  ],
  "indices": [
    {
      "names": [
        "news",
        "blog"
      ],
      "privileges": [
        "all"
      ],
      "field_security": {
        "grant": [
          "title",
          "body"
        ]
      },
      "query": "{\"match\": {\"title\": \"foo\"} }"
    }
  ],
  "run_as": [
    "other_user"
  ],
  "metadata": {
    "version": 1
  }
}'


```

* 权限管理
    * has_privileges可以确定登录的用户具有的特权列表。所有用户都可以使用此API，但只能查看自己的特权。


```shell script

curl -XPOST -H "Content-Type:application/json" -u elastic:123456 localhost:9200/_xpack/security/role_mapping/administrator -d '
{
  "roles": [
    "user",
    "admin"
  ],
  "enabled": true,
  "rules": {
    "field": {
      "username": [
        "admin01",
        "admin02"
      ]
    }
  }
}'

curl -XGET -u elastic:123456 localhost:9200/_xpack/security/role_mapping/administrator?pretty

curl -XGET -u elastic:123456 localhost:9200/_xpack/security/role_mapping?pretty


```



### Elastic SQL
* Elasticsearch SQL是一个X-Pack组件，它允许针对Elasticsearch实时执行类似SQL的查询。无论使用REST接口，命令行还是JDBC，任何客户端都可以使用SQ
搜索或聚合数据。可以将Elasticsearch SQL看作是一种翻译器，它可以将SQL解释成Elasticsearch可以理解的查询语言，并利用Elasticsearch完成大规模读取和处理数据。


```shell script
curl -XPOST -H "Content-Type:application/json" -u elastic:123456 localhost:9200/_sql?pretty -d'{"query":"select * from shakespeare"}'
```

 



## chapter10 聚合
### 基本概念
* 桶
    * 简单来说就是满足特定条件的文档的集合。当聚合开始被执行，每个文档里面的值通过计算来决定符合哪个桶的条件。如果匹配到，文档将放入相应的桶并接着进行聚合操作。
* 指标
    * 桶能让我们划分文档到有意义的集合，但是最终我们需要的是对这些桶内的文档进行一些指标的计算。分桶是一种达到目的的手段：它提供了一种给文档分组的方法来让我们可以计算感兴趣的指标。
      大多数 指标 是简单的数学运算（例如最小值、平均值、最大值，还有汇总），这些是通过文档的值来计算。在实践中，指标能让你计算像平均薪资、最高出售价格、95%的查询延迟这样的数据。
* 聚合  单指标聚合、多指标聚合
    * 分桶聚合（Bucketing）
    * 指标聚合（Metric）
    * 矩阵聚合（Matrix）
    * 管道聚合（Pipeline）


* 指标聚合 该聚合是根据要聚合的文档提取出来字段值来进行指标计算。
    * 平均值（avg）

```shell script
#导入 account的数据
curl -H "Content-Type: application/json" -XPOST -u elastic:123456 localhost:9200/people/bank/_bulk?pretty --data-binary @accounts.json

#平均值聚合(avg)
curl  -XPOST -u elastic:123456 -H "Content-Type: application/json" "localhost:9200/people/_search?pretty&size=0" -d'
{
  "aggs": {
    "avg_agg": {
      "avg": {
        "field": "balance"
      }
    }
  }
}'
# 由脚本生成指标
curl -H "Content-Type: application/json" -XPOST -u elastic:123456 "localhost:9200/people/_search?pretty&size=0" -d'
{
  "aggs": {
    "avg_agg": {
      "avg": {
        "script": {
          "source": "doc.balance.value"
        }
      }
    }
  }
}'


# 求和聚合
curl  -XPOST -u elastic:123456 -H "Content-Type: application/json" "localhost:9200/people/_search?pretty&size=0" -d'
{
  "aggs": {
    "sum_agg": {
      "sum": {
        "field": "balance"
      }
    }
  }
}'

# 最大值聚合
curl  -XPOST -u elastic:123456 -H "Content-Type: application/json" "localhost:9200/people/_search?pretty&size=0" -d'
{
  "aggs": {
    "max_agg": {
      "max": {
        "field": "balance"
      }
    }
  }
}'
#最小值聚合
curl  -XPOST -u elastic:123456 -H "Content-Type: application/json" "localhost:9200/people/_search?pretty&size=0" -d'
{
  "aggs": {
    "min_agg": {
      "min": {
        "field": "balance"
      }
    }
  }
}'


#地理边界（geo_bounds）  用于计算包含一个字段geo_point值的边界框
curl -XPOST "localhost:9200/restaurants/_search?pretty&size=0" -d'
{
   "query": {
      "match": { "name": "restaurant" }
   },
   "aggs": {
      "geo_restaurant" : {
         "geo_bounds" : {
             "field": "location"
         }
      }
   }
}'

#地理中心
curl -XPOST "localhost:9200/restaurants/_search?pretty&size=0" -d'
{
   "aggs": {
      "geo_restaurant" : {
         "geo_centroid" : {
            "field": "location"
         }
      }
   }
}'

#百分比聚合 percentiles
#多指标聚合，该聚合针对从聚合文档中提取的数值计算一个或多个百分位数。假设日志数据包含接口响应时间，对管理员来说平均和中位数加载时间并无太大用处，最大值可能更有用。
#可以指定算法
curl -XPOST -u elastic:123456 -H "Content-Type: application/json" "localhost:9200/people/_search?pretty&size=0" -d'
{
  "aggs": {
    "age_outlier": {
      "percentiles": {
        "field": "age"
      }
    }
  }
}'

# 指定某个百分比范围
curl -XPOST -u elastic:123456 -H "Content-Type: application/json" "localhost:9200/people/_search?pretty&size=0" -d'
{
  "aggs": {
    "age_outlier": {
      "percentiles": {
        "field": "age",
        "percents": [
          90,
          95,
          99
        ]
      }
    }
  }
}'

#百分比等级（percentile_ranks）
#多指标聚合，该聚合根据从聚合文档中提取的数值计算出一个或多个百分数等级。
curl -XPOST -u elastic:123456 -H "Content-Type: application/json" -XPOST "localhost:9200/people/_search?pretty&size=0" -d'
{
  "aggs": {
    "age_outlier": {
      "percentile_ranks": {
        "field": "balance",
        "values": [
          25000,
          50000
        ]
      }
    }
  }
}'

#基数聚合 cardinality





```
* 基数聚合
    * 单值指标聚合，用于计算不同值的近似计数。它提供一个字段的基数，即该字段的 distinct 或者 unique 值的数目。可以以如下SQL来帮助理解该聚合：
* 每天访问网站的独立IP有多少 bitmap(位图算法)  
    * hyperLogLog
 
```shell script
curl -XPOST -u elastic:123456 -H "Content-Type: application/json" "localhost:9200/people/_search?pretty&size=0" -d'
{
  "aggs": {
    "name_count": {
      "cardinality": {
        "field": "firstname.keyword"
      }
    }
  }
}'
```

* Top聚合 

```shell script
curl -XPOST -u elastic:123456 -H "Content-Type: application/json" "localhost:9200/people/_search?size=0&pretty=true" -d'
{
  "aggs": {
    "top_tags": {
      "terms": {
        "field": "lastname.keyword",
        "size": 6
      },
      "aggs": {
        "top_balance_hits": {
          "top_hits": {
            "sort": [
              {
                "balance": {
                  "order": "desc"
                }
              }
            ],
            "_source": {
              "includes": [
                "firstname",
                "lastname",
                "age",
                "balance"
              ]
            },
            "size": 1
          }
        }
      }
    }
  }
}'
```

#### 分桶聚合
桶聚合不像指标聚合那样计算字段的值，而是创建文档存储桶。每个桶都与一个标准/查询（取决于聚合类型）相关联，该标准/查询确定文档是否“落入”其中，存储桶有效地定义了文档集。除了存储桶本身之外，桶聚合还计算并返回“落入”每个存储桶的文档数量。

* 过滤聚合
```shell script
curl -XPOST -u elastic:123456 -H "Content-Type: application/json" "localhost:9200/people/_search?size=0&pretty=true" -d'
{
  "aggs": {
    "gender_filter": {
      "filter": {
        "term": {
          "gender.keyword": "M"
        }
      },
      "aggs": {
        "balance_price": {
          "avg": {
            "field": "balance"
          }
        }
      }
    }
  }
}'





```

* 多过滤聚合（filters）
定义一个多桶聚合，其中每个桶都与一个过滤器相关联。每个存储桶将收集与其关联的过滤器匹配的所有文档。

```shell script

curl -XPOST -u elastic:123456 -H "Content-Type: application/json" "localhost:9200/people/_search?size=0&pretty=true" -d'
{
  "aggs": {
    "bank_filter": {
      "filters": {
        "filters": {
          "state": {
            "match": {
              "state.keyword": "AZ"
            }
          },
          "name": {
            "match": {
              "lastname.keyword": "Hess"
            }
          }
        }
      }
    }
  }
}'

curl -XPOST -u elastic:123456 -H "Content-Type: application/json" "localhost:9200/people/_search?size=0&pretty=true" -d'
{
  "aggs": {
    "bank_filter": {
      "filters": {
        "other_bucket": true,
        "filters": {
          "state": {
            "match": {
              "state.keyword": "AZ"
            }
          },
          "name": {
            "match": {
              "lastname.keyword": "Hess"
            }
          }
        }
      }
    }
  }
}'


```
 
* 范围聚合
```shell script
# 范围聚合
curl -XPOST -u elastic:123456 -H "Content-Type: application/json" "localhost:9200/people/_search?size=0&pretty" -d'
{
  "aggs": {
    "age_range": {
      "range": {
        "field": "age",
        "ranges": [
          {
            "to": 30
          },
          {
            "from": 20,
            "to": 25
          },
          {
            "from": 40
          }
        ]
      }
    }
  }
}'

# 在桶内再进行操作
curl -XPOST -u elastic:123456 -H "Content-Type: application/json" "localhost:9200/people/_search?size=0&pretty" -d'
{
  "aggs": {
    "age_range": {
      "range": {
        "field": "age",
        "ranges": [
          {
            "to": 30
          },
          {
            "from": 20,
            "to": 25
          },
          {
            "from": 40
          }
        ]
      },
      "aggs": {
        "balance_max": {
          "max": {
            "field": "balance"
          }
        }
      }
    }
  }
}'


```
* 日期范围聚合



```shell script
curl -XPOST localhost:9200/logstash-*/_search?size=0 -d'
{
   "aggs": {
      "age_range": {
         "date_range": {
            "field": "utc_time",
            "format": "yyyy-MM",
            "ranges": [
               { "to": "now+10M" },
               { "from": "now-10M" }
            ]
         }
      }
   }
}'

```

* 日期直方图聚合
直方图的多桶聚合，但只能应用于日期值。可以通过日期/时间表达式指定间隔。
```shell script
curl -XPOST "localhost:9200/logstash-*/_search?size=0&pretty" -d'
{
   "aggs": {
      "utc_time_agg": {
         "date_histogram" : {
            "field": "utc_time",
            "interval": "day",
            "format": "yyyy-MM-dd",
            "offset": "+6h"
         }
      }
   }
}'

```

● interval
时间间隔。可用表达式：year, quarter, month, week, day, hour, minute, second
● key
在Elasticsearch内部，日期表示为64位数字，表示自从该纪元以来以毫秒为单位的时间戳。这个时间戳作为桶的Key返回。key_as_string是使用format参数对时间戳进行格式化后的文本。
● offset
offset参数用于按指定的正（+）或负偏移（-）更改每个存储区的起始值，例如1h表示一个小时，或1d表示一天。


* 地理距离聚合(geo_distance)
    * 适用于geo_point
    字段的多桶聚合，在概念上与范围聚合非常相似。用户可以定义一个原点和一组距离范围。聚合会评估每个文档值到原点的距离，并根据范围来确定它所属的桶（如果文档和原点之间的距离在存储桶的距离范围内，则文档属于存储桶）。
    * 默认情况下，距离单位为m（米），但也可以设置为：mi（英里），in（英寸），yd（码），km（公里），cm（厘米），mm（毫米）。

* 该聚合有两种距离计算模式：弧（arc，默认）和平面（plane）。弧计算是最准确的。平面最快但最不准确。当搜索跨越较小的地理区域（约5
公里）时，请考虑使用平面。如果在非常大的区域内进行搜索（例如跨大陆搜索），平面将返回较高的误差范围。

```shell script
curl -XPOST "localhost:9200/restaurants/_search?size=0&pretty" -d'
{
   "aggs": {
      "geo_range": {
         "geo_distance": {
            "field": "location",
            "origin": "52.3760, 4.894",
            "ranges": [
               { "to": 100000 },
               { "from": 100000, "to": 300000 },
               { "from": 300000 }
            ]
         }
      }
   }
}'

curl -XPOST "localhost:9200/restaurants/_search?size=0&pretty" -d'
{
   "aggs": {
      "geo_range": {
         "geo_distance": {
            "field": "location",
            "origin": "52.3760, 4.894",
            "unit": "km",
            "ranges": [
               { "to": 100000 },
               { "from": 100000, "to": 300000 },
               { "from": 300000 }
            ]
         }
      }
   }
}'

# tyoe = plane
curl -XPOST "localhost:9200/restaurants/_search?size=0&pretty" -d'
{
   "aggs": {
      "geo_range": {
         "geo_distance": {
            "field": "location",
            "origin": "52.3760, 4.894",
            "unit": "km",
            "distance_type": "plane",
            "ranges": [
               { "to": 100000 },
               { "from": 100000, "to": 300000 },
               { "from": 300000 }
            ]
         }
      }
   }
}'


```

* 地理网格聚合(geohash_grid)
地理网格聚合(geohash_grid)
适用于geo_point字段的多桶聚合。将地理坐标点分组到以网格为单元的桶中。每个单元格都使用可定义精度的geohash进行标记，聚合中使用的地理哈希可以在1到12之间选择精度（长度为12的最高精度geohash仅覆盖不到一平方米的区域，因此就RAM和结果大小而言，高精度geohash可能会更加昂贵）
● 高精度：高精度地理哈希具有较长的字符串，每个单元仅覆盖较小区域。
● 低精度：低精度地理哈希具有较短的字符串，每个单元都覆盖大面积的区域
```shell script
curl -XPOST "localhost:9200/restaurants/_search?size=0&pretty" -d'
{
   "aggs": {
      "zoom_filter": {
         "filter" : {
            "geo_bounding_box": {
               "location": {
                  "top_left": "52.4, 4.9",
                  "bottom_right": "52.3, 5.0"
               }
            }
         },
         "aggs": {
            "zoom_agg": {
               "geohash_grid": {
                  "field": "location",
                  "precision": 8
               }
            }
         }
      }
   }
}'




```

* 词项聚合（terms）


* 排序
可以通过设置Order参数来设置桶的顺序。默认情况下，桶会按照doc_count降序排列。不建议按_count升序或按子聚合排序，因为这会增加文档计数上的错误。
```shell script
curl -XPOST -u elastic:123456 -H "Content-Type: application/json" "localhost:9200/people/_search?size=0&pretty" -d'
{
  "aggs": {
    "name_agg": {
      "terms": {
        "field": "firstname.keyword",
        "order": {
          "_term": "desc"
        }
      },
      "aggs": {
        "max_balance": {
          "max": {
            "field": "balance"
          }
        }
      }
    }
  }
}'

```
* 过滤
对桶进行过滤。可以设置include和exclude参数来完成，参数接受正则表达式或精确值数组。此外，include子句还可以使用分区表达式。
```shell script
# 使用include和exclude进行过滤
curl -XPOST -u elastic:123456 -H "Content-Type: application/json" "localhost:9200/people/_search?size=0&pretty" -d'
{
  "aggs": {
    "name_agg": {
      "terms": {
        "field": "address.keyword",
        "include": ".*Gatling.*",
        "exclude": ".*Street"
      }
    }
  }
}'

# 精确过滤
curl -XPOST -u elastic:123456 -H "Content-Type: application/json" "localhost:9200/people/_search?size=0&pretty" -d'
{
  "aggs": {
    "name_agg": {
      "terms": {
        "field": "address.keyword",
        "include": [
          "105 Onderdonk Avenue",
          "Street"
        ]
      }
    }
  }
}'


# 分区过滤
curl -XPOST -u elastic:123456 -H "Content-Type: application/json" "localhost:9200/people/_search?size=0&pretty" -d'
{
  "aggs": {
    "name_agg": {
      "terms": {
        "field": "account_number",
        "include": {
          "partition": 0,
          "num_partitions": 20
        },
        "size": 20,
        "order": {
          "max_balance": "desc"
        }
      },
      "aggs": {
        "max_balance": {
          "max": {
            "field": "balance"
          }
        }
      }
    }
  }
}'

```

* 搜集模式
对于具有许多唯一术语和少量所需结果的字段，将子聚合的计算延迟到最上层父级aggs被聚合之前，可能会更有效。通常，聚合树的所有分支都以深度优先的方式进行扩展，然后才进行修剪。在某些情况下，这可能非常浪费，并且会遇到内存限制。如：在电影数据库中查询10个最受欢迎的演员及其5个最常见的联合主演：
```shell script
curl -XPOST -u elastic:123456 -H "Content-Type: application/json" "localhost:9200/people/_search?size=0&pretty" -d'
{
  "aggs": {
    "name_agg": {
      "terms": {
        "field": "firstname.keyword",
        "size": 10,
        "collect_mode": "breadth_first"
      },
      "aggs": {
        "tops": {
          "terms": {
            "field": "firstname.keyword",
            "size": 5
          }
        }
      }
    }
  }
}'
```
    
























### 基本概念



## 插件安装
第一种：命令行

    bin/elasticsearch-plugin install [plugin_name] elasticsearch-head
    # bin/elasticsearch-plugin install analysis-smartcn  安装中文分词器

第二种：url安装

    bin/elasticsearch-plugin install [url]
    #bin/elasticsearch-plugin install https://artifacts.elastic.co/downloads/elasticsearch-plugins/analysis-smartcn/analysis-smartcn-6.4.0.zip

第三种：离线安装
    
    #https://artifacts.elastic.co/downloads/elasticsearch-plugins/analysis-smartcn/analysis-smartcn-6.4.0.zip
    #点击下载analysis-smartcn离线包
    #将离线包解压到ElasticSearch 安装目录下的 plugins 目录下
    #重启es。新装插件必须要重启es


```
bin/elasticsearch-plugin install [plugin_name]
/bin/elasticsearch-plugin list
/bin/elasticsearch-plugin remove [pluginname]
```




## 可视化
ElasticSearch的可视化工具有很多，比如elasticsearch-head、Dejavu、ElasticHD等。

查看es可视化工具建议用kibana或者cerebro









## 版本采坑记录

* 过滤查询已被弃用，并在ES 5.0中删除
* 6.0的版本不允许一个index下面有多个type，并且官方说是在接下来的7.0版本中会删掉type
* Elasticsearch从5.X就引入了text和keyword，其中keyword适用于不分词字段，搜索时只能完全匹配，这时string还保留着。
  到了6.X就彻底移除string了。
  另外，"index"的值只能是boolean变量了。
* 5.x之后，Elasticsearch对排序、聚合所依据的字段用单独的数据结构(fielddata)缓存到内存里了，但是在text字段上默认是禁用的，如果有需要单独开启，这样做的目的是为了节省内存空间
* 过滤查询已被弃用，并在ES 5.0中删除。
  解决： 使用bool / must / filter查询
* elasticsearch7 默认不在支持指定索引类型，默认索引类型是_doc

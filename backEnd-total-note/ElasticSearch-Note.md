# Elasticsearch 学习笔记

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


## chapter2 Rest API

* 颜色状态
    * yellow 所有分片正常分布，但是副本缺失 
    * red 
    * green

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






















====================================================================================================





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



## 插件
X-Pack
Header



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


# kibana学习笔记
* javascript 开发的，所以需要 node.js

## 安装
* reference
    * https://juejin.im/post/5d790892e51d4561e721df89
    

* 版本要与 elasticSearch 一致
* 启动命令
```shell script
curl -XGET 192.168.41.129:9200/.kibana?pretty
192.168.41.129:5601

```


* 更改目录权限
```shell script
# 更改 kibana 目录的权限，否则会报错
chown -R zhq:zhq kibana
```
* 验证
    * ip:5601
    * ip:5601/status  查看kibana的状态

## 使用
* 搜索时使用 lucene 的 query string 表达式
* fusion chart
* eschart


## 操作命令
```shell script
GET /_cat/indices

#删除
DELETE /facebook
PUT /zhq
GET /zhq
PUT /lib/
{
    "settings":{
        "index":{
            "number_of_shards":3,
            "number_of_replicas":0
        }
    }
}

#查看索引的配置  
GET /lib/_settings
#查看所有索引的配置
GET _all/_settings

#通配符查询
GET /f*

#查看所有的索引
GET /_all

#关闭索引
POST /user/_close
#打开索引
POST /user/_open

```

* 不需要指定type了，而是用/{index}/_doc/{id}的方式创建（/{index}/_doc的话，就自动生成id）
* 创建文档的适合id可以省略不写，系统会自动添加

```shell script
PUT /user/
{
  "settings": {
    "number_of_shards": 3,
    "number_of_replicas": 0
  }
}

GET /user/_settings
PUT /user/_doc/1
{
  "first_name": "f",
  "last_name": "hell",
  "age": 23,
  "about": "在校大学生，目前正在学习ElasticSearch",
  "interests":["Music", "Movies"] 
}

PUT /user/_doc/2
{
  "first_name": "2f",
  "last_name": "2hell",
  "age": 22,
  "about": "2在校大学生，目前正在学习ElasticSearch",
  "interests":["Music", "Movies"] 
}

#自动产生id的命令，要通过PSOT方法实现
#如果添加文档时没有指定id，那么这个id会由es自动生成，那么我们要使用POST方式添加文档
POST /user/_doc
{
  "first_name": "31f",
  "last_name": "3hell",
  "age": 32,
  "about": "3在校大学生，目前正在学习ElasticSearch",
  "interests":["Music", "Movies"] 
}


#根据id查询
GET /user/_doc/1
#查询部分字段
GET /user/_doc/1?_source=age,about
#修改文档 通过 put修改的文档，会覆盖文档所有字段的值
PUT /user/_doc/1
{
  "first_name": "f",
  "last_name": "hello",
  "age": 23,
  "about": "在校大学生，目前正在学习ElasticSearch，并且我非常喜欢它",
  "interests":["Music", "Movies"] 
}

#修改指定字段的值
POST /user/_update/1
{
  "doc":{
    "age": 25
  }
}

#删除文档
DELETE /user/_doc/1

```

* POST 与 PUT 方法的区别
    * PUT是幂等方法，而POST并不是。
    * PUT用于更新操作，POST用于新增操作比较合适。
    * PUT，DELETE操作是幂等的，所谓幂等就是指不管进行多少次操作，结果都一样。比如，我用PUT修改一篇文章，然后在做同样的操作，每次操作后的结果并没有不同，DELETE也是一样。
    * POST操作不是幂等，比如常见的POST重复加载问题：当我们多次发出同样的POST请求后，其结果是创建出了若干的资源。


### 滚动
* 日志文件进行滚动

### 映射
```shell script
PUT /customer01

PUT /customer01/_doc/1
{
  "name": "Natsu", 
  "age": 20
}

PUT /customer02
{
    "mappings": {
		"properties": {
			 "name": {
				 "type": "text"
			 }
		}
    }
}

PUT /customer03
{
    "mappings": {
		"properties": {
			 "birth": {
				 "type": "date"
			 }
		}
    }
}

PUT /customer03/_doc/1
{ "birth": "2019-11-18" }

PUT /customer03/_doc/2
{ "birth": "2019-11-18" }

PUT /customer03/_doc/3
{ "birth": "2019-11-18T21:04:33Z" }

# 根据日期升序排序 
GET /customer03/_search
{ "sort": { "birth": "asc" } }

PUT /customer04/_doc/1
{
    "provinvce": "beijing",
    "programmer": {
    "name": "Natus",
    "age":  25
    }
}

PUT /customer08
{
	"mappings": {
		"properties": {
			"nums": {
			"type": "integer_range"
			},
			"birth":{
			"type": "date_range",
			"format": "yyyy-MM-dd HH:mm:ss||yyyy-MM-dd||epoch_millis"
			}
		}
	}
}

PUT /customer08/_doc/1
{
	"nums": {
		"gte": 20,
		"lte": 35
	},
	"birth": {
		"gte": "1970-01-01",
		"lte": "2020-11-18"
	}
}
```

* mapping 信息，自动推断数据类型
```shell script
{
  "customer01" : {
    "aliases" : {},
    "mappings" : {
      "properties" : {
        "age" : {
          "type" : "long"
        },
        "name" : {
          "type" : "text",
          "fields" : {
            "keyword" : {
              "type" : "keyword",
              "ignore_above" : 256
            }
          }
        }
      }
    },
    "settings" : {
      "index" : {
        "creation_date" : "1595670207321",
        "number_of_shards" : "1",
        "number_of_replicas" : "1",
        "uuid" : "F3B1JvhTR_OsrhrtT-mJlA",
        "version" : {
          "created" : "7020099"
        },
        "provided_name" : "customer01"
      }
    }
  }
}

# token_count的使用
PUT /customer10
{
  "mappings": {
    "properties": {
      "name": {
        "type": "text",
        "fields": {
          "length": {
            "type": "token_count",
            "analyzer": "standard"
          }
        }
      }
    }
  }
}

PUT /customer10/_doc/1
{ "name":"James Scolor" }

#查询名字只有两个词的文档
GET /customer10/_search
{
	"query":{
		"term":{
			"name.length":2
		}
	}
}

PUT /customer0001
{
  "mappings": {
    "properties": {
      "content": {
        "type": "text",
        "analyzer": "standard",
        "search_analyzer": "standard"
      }
    }
  }
}

#设置清除脏数据
PUT /customer0003
{
  "mappings": {
    "properties": {
      "age": {
        "type": "integer"
      },
      "salary": {
        "type": "integer",
        "coerce": false
      }
    }
  }
}

#可以自动做类型转换
PUT /customer0003/_doc/2
{
"age":"10"
}

#如下语句会报错
PUT /customer0003/_doc/3
{
"salary":"10"
}

#copyto的使用，组成一个大的字符串
{
  "mappings": {
    "properties": {
      "first_name": {
        "type": "text",
        "copy_to": "full_name"
      },
      "last_name": {
        "type": "text",
        "copy_to": "full_name"
      },
      "full_name": {
        "type": "text"
      }
    }
  }
}

#字段排序和聚合的设置
{
  "mappings": {
    "properties": {
      "province_code": {
        "type": "keyword"
      },
      "order_id": {
        "type": "text",
//        不会进行排序和聚合
        "doc_values": false
      }
    }
  }
}

#dynamic 参数的设置
#dynamic属性用于检测新字段，有三个选项：
#true：新发现的字段自动添加到映射中
#false：新发现的字段被忽略，必须显式添加字段
#strict：如果检测到新字段，抛出异常并拒绝添加文档。

{
  "mappings": {
    "dynamic": false,
    "properties": {
      "province_code": {
        "type": "keyword"
      },
      "location_code": {
        "dynamic": true,
        "properties": {}
      }
    }
  }
}

#设置为enabled，则ES不会对该字段进行索引
{
  "mappings": {
    "properties": {
      "province_code": {
        "type": "keyword"
      },
      "location_code": {
        "enabled": false
      }
    }
  }
}

# format属性主要用于格式化日期
{
  "mappings": {
    "properties": {
      "order_date": {
        "type": "date",
        "format": "yyyy-MM-dd"
      }
    }
  }
}

#ignore_above用于指定字段索引和存储的长度最大值，超过最大值的会被忽略：
{
  "mappings": {
    "properties": {
      "message": {
        "type": "keyword",
        "ignore_above": "15"
      }
    }
  }
}

#ignore_malformed可以忽略不规则数据。给一个字段索引不合适的数据类型发生异常，导致整个文档索引失败。
#如果ignore_malformed参数设为true，异常会被忽略，出异常的字段不会被索引，其它字段正常索引。
{
  "mappings": {
    "properties": {
      "age": {
        "type": "integer",
        "ignore_malformed": true
      },
      "salary": {
        "type": "integer"
      }
    }
  }
}





# properties
# Object类型或者nested类型，因为有层级嵌套，所以我们可以通过properties来指定这种层级嵌套关系
{
  "mappings": {
    "properties": {
      "teacher": {
        "properties": {
          "name": {
            "type": "text"
          },
          "salary": {
            "type": "integer"
          },
          "age": {
            "type": "integer"
          }
        }
      },
      "student": {
        "properties": {
          "name": {
            "type": "text"
          },
          "number": {
            "type": "text"
          },
          "class": {
            "type": "integer"
          }
        }
      }
    }
  }
}

# 默认情况下，字段被索引也可以搜索，但是不存储，因为_source字段里面保存了一份原始文档。在某些情况下，比如一个文档里面有title、
# date和超大的content字段，如果只想获取title和date：
{
  "mappings": {
    "properties": {
      "author": {
        "type": "text",
        "store": true
      },
      "title": {
        "type": "text",
        "store": true
      },
      "content": {
        "type": "text"
      }
    }
  }
}


##############################################     动态模板      #############################################
#通过 dynamic_templates，可以拥有对新字段的动态映射规则拥有完全的控制。可以设置根据字段名称或者类型来使用一个不同的映射规则。
#每个模板都有一个名字，可以用来描述这个模板做了什么。同时它有一个 mapping 用来指定具体的映射信息，和至少一个参数（比如 match）
#用来规定对于什么字段需要使用该模板。
PUT /customer0014
{
  "mappings": {
    "dynamic_templates": [
      {
        "long_to_string": {
        "match_mapping_type": "string",
        "match": "age_*",
        "unmatch": "*_age",
        "mapping": {
          "type": "long"
        }
      }
    }]
  }
}

PUT /customer0014/_doc/1
{
  "age_1":"5",
  "1_age":"OOXX"
}
```



### 别名
```shell script

#查看别名
GET  /_cat/aliases

PUT /customer00016
#创建别名
PUT /customer00016/_alias/my_index

PUT /customer00017
POST /_aliases
{
  "actions": [
    {
      "add": {
        "index": "customer0017",
        "alias": "my_index"
      }
    }
  ]
}

#根据别名查跟那些索引关联起来了
# 查看别名指向了哪一个索引
GET /*/_alias/my_index
PUT /customer0021
{
  "mappings": {
    "properties": {
      "name": {
        "type": "text",
        "index": false
      }
    }
  }
}
#插入相关的文档
PUT /customer0021/_doc/3
{
"name":"jackson"
}

#查询所有的相关文档
GET /customer0021/_search



```

### Match
```shell script
GET /shakespeare/_search
{
	"query": {
	  "match": {
        // 默认是 or 操作符
		"text_entry": "men flight"
	  }
	}
}

GET /shakespeare/_search
{
	"query": {
	  "match": {
        // 精确短语匹配
		"text_entry": "take the flight"
	  }
	}
}

GET /shakespeare/_search
{
  "query": {
    "match": {
      "text_entry": {
        "query": "men flight",
        // 指定  and 操作符
        "operator": "and"
      }
    }
  }
}


GET /shakespeare/_search
{
  "query": {
    "match": {
      "text_entry": {
        "query": "in the highst degree",
        // 至少需要匹配 4 个query 中的关键字
        "minimum_should_match": 4
      }
    }
  }
}


GET /shakespeare/_search
{
  "query": {
    "match_phrase": {
      "text_entry": {
        "query": "in the highst degree",
        "slop": 2
      }
    }
  }
}


GET /shakespeare/_search
{
  "query": {
    "match_phrase_prefix": {
      "text_entry": "table of her"
    }
  }
}

GET /shakespeare/_search
{
  "query": {
    "match_phrase_prefix": {
      "text_entry": {
        "query": "in the",
        "max_expansions": 10
      }
    }
  }
}

GET /shakespeare/_search
{
  "query": {
    "multi_match": {
      // query 和 filed 之间是 或 的关系
      "query": "dream flight",
      "fields": ["text_entry", "play_name"]
    }
  }
}
```

## Query String
* 官网导入测试数据
    * https://blog.csdn.net/u012224510/article/details/86571305
* Domain Specific Languague。ES基于DSL+Json来进行查询。

### Field
```shell script
GET user/_search
{
    "query": {
        "match_all": {}
    }
}

GET /shakespeare/_search
{
    "query": {
       "query_string": {
          "default_field": "text_entry",
          "query": "take AND flight OR dream"
       }
    }
}

GET /shakespeare/_search
{
    "query": {
       "query_string": {
          "default_field": "text_entry",
          "query": "dr?am fli*"
       }
    }
}
```

### 通配符
* 通配符搜索可以使用？替换单个字符，或者使用*号替换零个或者多个多个字符：
```shell script
GET /shakespeare/_search
{
    "query": {
       "query_string": {
          "default_field": "text_entry",
          "query": "/take? fl[i|a]ght/"
       }
    }
}

# 查多个字段
GET /shakespeare/_search
{
    "query": {
       "query_string": {
          "fields": ["text_entry", "play*"],
          "query": "take AND flight OR dream"
       }
    }
}

```

### 模糊
* 使用模糊运算符搜索与我们的搜索字词类似但不完全相同的字词：
```properties
micheal~
```

### 邻近
* 与模糊查询可以为单词中的字符指定最大编辑距离的方式相同，邻近搜索允许我们指定短语中单词的最大编辑距离：
```properties
"dream flight"~3
```

### 范围
* 为日期、数字或者字符串指定查询范围。[min TO max]代表指定包含范围，{min TO max}代表指定排它范围。
```shell script
# 指定时间范围
date:[2018-11-26 TO 2019-11-25]
# 指定数值范围
num:[1 TO 5]
# 指定字符范围
city: [SH TO TJ]
# 指定上边界和下边界
date:{* TO 2019-11-25]
date:[2018-11-26 TO *}
age:>10
age:(>=10 AND <20)
```

### 权重
* 可以使用boost 运算符^使一个术语比另一个术语更相关。 默认 boost 值为1，但可以是任何正浮点数：
```shell script
# 如果我们想要找到关于flight的所有文档，但我们对dream flight特别感兴趣：
dream^2 flight
# 对短语进行权重设置
"Michael Jackson"^2
# 对群组进行权重设置
(Michael Jackson)^2
```

### 布尔
* 默认情况下，只要一个词匹配，其他词都是可选的。搜索dream flight men将查找包含一个或多个dream，或flight，或 men任何文档。
但如果我们想强制要求所有的术语，则可以通过布尔查询，来进行更多的控制
```shell script
# dream和flight是可选的
# mother必须出现
# men一定不能存在
dream flight +mother -men
# 布尔运算符 AND， OR 以及 NOT（也写作&&， || 和!）
((dream AND flight) OR (men AND mother) OR their) AND not advantage

# 这个查询也没有生效
GET /shakespeare/_search
{
	"query": {
	  "match": {
		"text_entry": "dream +flight"
	  }
	}
}


```

### 分组
* 可以将多个术语或子句用括号组合在一起，以形成子查询： 
```shell script
(dream AND flight) OR men
```



## Simple_Query_String
* simple_query_string 同 query_string 查询一样用lucene查询语法写查询串，和query_string不同的地方是：
    * 具有更小的语法集；
    * 查询串有错误，会忽略错误的部分，不抛出错误。

```shell script
GET /shakespeare/_search
{
    "query": {
       "simple_query_string": {
          "fields": ["text_entry", "play*"],
          "query": "take +(the|thy) -flight dream",
          "default_operator": "and"
       }
    }
}

```



## 词项搜索
### Term Query
```shell script
GET /shakespeare/_search
{
    "query": {
        "term": { "play_name": "Henry IV" }
    }
}
```

### Terms Query
```shell script
GET /shakespeare/_search
{
    "query": {
        "terms": { "play_name": ["Henry IV", "dream"] }
    }
}

GET /shakespeare/_search
{
    "query": {
        "terms": {
           "text_entry": {
               "index": "shakespeare",
               "id": "102908",
               "path": "play_name"
           }
       }
    }
}
```

### Range Query
```shell script
GET /shakespeare/_search
{
    "query": {
        "range": {
           "speech_number": {
               "gte": 3,
               "lte": 5,
               "boost": 2.0  // 设置打分
           }
        }
    }
}

# 举例使用，实际不能操作
GET /shakespeare/_search
{
    "query": {
        "range": {
           "order_date": {
               "gte": "now-1d/d",
               "lte": "now/d"
           }
        }
    }
}
# 举例使用，实际不能操作
GET /shakespeare/_search
{
    "query": {
        "range": {
           "birth_date": {
               "gte": "1995-10-31",
               "lte": "2018-10",
               "format": "yyyy-MM-dd||yyyy-MM||epoch_millis"
           }
        }
    }
}
```

### Prefix Query
```shell script
GET /shakespeare/_search
{
    "query": {
       "prefix": { "play_name": "Hen" }
    }
}
```

### Wildcard Query
```shell script
GET /shakespeare/_search
{
    "query": {
       "wildcard": { "play_name": "Hen*" }
    }
}
```

### Regexp Query
```shell script
GET /shakespeare/_search
{
    "query": {
       "regexp": { "text_entry": "t.*er" }
    }
}
```

### Fuzzy Query
* 模糊
    * 使用模糊运算符搜索与我们的搜索字词类似但不完全相同的字词：

```shell script
GET /shakespeare/_search
{
    "query": {
        "fuzzy":{
          "text_entry":{
            "value": "her",
            "fuzziness": 2,
            "max_expansions": 100
          }     
        }
    }
}
```

### Ids Query
```shell script
GET /shakespeare/_search
{
    "query": {
        "ids":{
          "values": [53210,43187]
        }     
    }
}
```


## 复合查询

### 定值打分
* 将查询匹配的文档的评分设为一个常值。 
* query context 查询上下文
    * 用在查询上下文中的字句查询的结果是：“这个文档有多匹配这个查询”。除了决定文档是否匹配，字句匹配的文档还会计算评分，来评定文档有多匹配，会参与相关性评分。查询上下文由 query 元素表示。
* Filter context 过滤上下文
    * 过滤上下文由 filter 元素或 bool 中的 must not 表示。用在过滤上下文中的字句查询的结果是：“这个文档是否匹配这个查询”，不参与相关性评分

* 补充
```shell script
GET /shakespeare/_search
{
    "query": {
        "constant_score": {
            "filter": {
                "term": { "play_name": "Henry IV" }
            },
            "boost": 1.5
        }
    }
}
```

### 布尔查询
Bool 查询用bool操作来组合多个查询字句为一个查询。
```shell script
GET /shakespeare/_search
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
}
```

### 函数打分
* weight
```shell script
GET /shakespeare/_search
{
    "query": {
        "function_score": {
  	      "query": { "match_all": {} },
  	      "boost": "5",
  	      "functions": [{
  	         "filter": { "match": {"text_entry": "dream"} },
  		    "weight": 33
  	      }],
  	      "score_mode": "max",
  	      "boost_mode": "multiply"
	   }
    }
}
```

* random score
```shell script
GET /shakespeare/_search
{
    "query": {
        "function_score": {
	   "query": { "match_all": {} },
	      "boost": "5",
	      "functions": [{
	        "filter": {
            "match": {"text_entry": "dream"} },
		    "weight": 33
		 },
         {
		 "filter": {
            "match": {"text_entry": "flight"} },
		    "random_score": {},
		    "weight": 3
         }
          ],
	      "score_mode": "min",
	      "boost_mode": "multiply"
        }
    }
}
```

* filed value factor
```shell script
GET /shakespeare/_search
{
    "query": {
        "function_score": {
            "field_value_factor": {
                "field": "speech_number",
                "factor": 1.2,
                "modifier": "sqrt",
                "missing": 1
            }
        }
    }
}

```

* 衰减函数
    * 以某个字段值为标准，离标准值越近的分值越高
```shell script
# 仅供示例，不能运行
GET /shakespeare/_search
{
    "query": {
       "function_score": {
          "gauss": {
              "date": {
                "origin": "2019-11-25",
                "offset": "5d",
                "scale": "10d",
                "decay": 0.5
              }
          }
      }
   }
}
```
* script score
```shell script
GET /shakespeare/_search
{
  "query": {
    "function_score": {
      "query": {
        "match": {
          "text_entry": "flight dream"
        }
      },
      "script_score": {
        "script": {
          "source": "Math.log(1+doc.line_id.value)"
        }
      }
    }
  }
}
```

* boosting query
    * 用于给定查询匹配的结果有效降级（降低的相关度，将它们的排序更靠后）。与布尔查询中的“ NOT”子句不同的是，它仍会返回包含词的文档，但会降低其总体得分。
    * Boosting查询接受一个positive子查询和一个negative子查询。只有匹配了positive查询的文档才会被包含到结果集中，但是同时匹配了negative查询的文档会被降低其相关度，通过将文档原本的_score和negative_boost参数进行相乘来得到新的_score。
    * 因此，negative_boost参数必须小于1.0。在上面的例子中，任何包含了指定负面词条的文档的\_score都会是其原本_score的0.3


```shell script
GET /shakespeare/_search
{
  "query": {
    "boosting": {
      "positive": {
        "match": {
          "text_entry": "flight"
        }
      },
      "negative": {
        "match": {
          "text_entry": "dream"
        }
      },
      "negative_boost": 0.3
    }
  }
}
```

## 关联查询
* join 不建议使用，谨慎使用
* 各种join相关的示例没有进行查询





## elasticsearch 脚本

```shell script
GET /shakespeare/_search
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
}

# 创建脚本
POST /_scripts/my_score
{
  "script": {
    "lang": "painless",
    "source": "doc.line_id.value * params.value"
  }
}
# 查看脚本
GET /_scripts/my_score

```





### es特定查询


## es 聚合查询




### 指标聚合
```shell script+

POST /bank/_search?size=0
{
  "aggs": {
    "avg_agg": {
      "avg": {
        "field": "balance"
      }
    }
  }
}
```



























 





















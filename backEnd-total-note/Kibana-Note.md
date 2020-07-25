
# kibana学习笔记

* javascript 开发的，所以需要 node.js
* 



## 安装
* reference
    * https://juejin.im/post/5d790892e51d4561e721df89
    

* 版本要与 elasticSearch 一致
* 启动命令
```shell script
curl -XGET 192.168.41.129:9200/.kibana?pretty
192.168.41.129:5601

```




更改目录权限
```shell script
# 更改 kibana 目录的权限，否则会报错
chown -R zhq:zhq kibana


```

* 验证
    * ip:5601
    * ip:5601/status  查看kibana的状态






## 使用
搜索时使用 lucene 的 query string 表达式

fusion chart
eschart


## 操作命令
```shell script
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
    "aliases" : { },
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
```

### 查询相关的操作
```shell script
GET user/_search
{
    "query": {
        "match_all": {}
    }
}

```







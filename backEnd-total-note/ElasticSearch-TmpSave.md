

$ curl -XGET localhost:9200/shakespeare/_search?pretty -d'
{
    "query": {
        "constant_score": {
            "filter": {
                "term": { "play_name": "night" }
            },
            "boost": 1.5
        }
    }
}'



$ curl -XGET localhost:9200/shakespeare/_search?pretty -d'
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


# 使用Bool查询
$ curl -XGET localhost:9200/shakespeare/_search?pretty -d'
{
    "query": {
        "bool": {
            "must": {
               "term": { "text_entry": "dream" }
            },
            "must_not": {
               "range": {
                   "speech_number": {
                       "gte": 30,
                       "lte": 50
                   }
               }
            },
            "should": [
                { "term": { "text_entry": "flight" } },
                { "term": { "text_entry": "the" } }
            ]
        }
}



$ curl -XGET localhost:9200/shakespeare/_search?pretty -d'
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
}'


curl -XGET localhost:9200/shakespeare/_search?pretty -d'
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
}'


curl -XGET localhost:9200/shakespeare/_search?pretty -d'
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
}'



curl -XGET localhost:9200/blog/_search?pretty -d'
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
}'


curl -XGET localhost:9200/shakespeare/_search?pretty -d'
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
}'


curl -XGET localhost:9200/shakespeare/_search?pretty -d'
{
   "query": {
      "function_score": {
         "query": {
	    "match": { "text_entry": "flight dream" }
	 },
	 "script_score": {
	    "script": {
	       "source": "Math.log(params.key+doc.line_id.value)"
	    }
         }
      }
   }
}'



curl -XGET localhost:9200/shakespeare/_search?pretty -d'
{
    "query": {
        "boosting": {
			"positive": {
			   "match": { "text_entry": "flight" }
			},
			"negative": {
			   "match": {
			      "text_entry": "dream"
			   }
			},
			"negative_boost": 0.3
		}
	}
}'



$ curl -XPUT localhost:9200/blog -d'
{
   "settings": {
      "mapping.single_type": true
   },
   "mappings":{
      "doc": {
         "properties": {
	    "join_field": {
	       "type": "join",
	       "relations": {
                  # 指定关系名号“父：子”
		  "article": "comment"
	       }
	    }
	 }
      }
   }
}'



# 方式一：指定关系名的添加方式
curl -XPUT localhost:9200/blog/doc/1 -d'
{
   "text": "one blog",
   "join_field": "article"
}'

curl -XPUT localhost:9200/blog/doc/2 -d'
{
   "text": "two blog",
   "join_field": "article"
}'

# 方式二：讲关系名封装在对象中
curl -XPUT localhost:9200/blog/doc/1 -d'
{
   "text": "one blog",
   "join_field": {
      "name": "article"
   }
}'

curl -XPUT localhost:9200/blog/doc/2 -d'
{
   "text": "two blog",
   "join_field": {
      "name": "article"
   }
}'



curl -XPUT localhost:9200/blog/doc/3?routing=1 -d'
{
   "text": "one comment",
   "clicked": 10,
   "join_field": {
      "name": "comment",
      "parent": 1
   }
}'

curl -XPUT localhost:9200/blog/doc/4?routing=1 -d'
{
   "text": "two comment",
   "clicked": 20,
   "join_field": {
      "name": "comment",
      "parent": 1
   }
}'


curl -XGET localhost:9200/blog/_search?pretty -d'
{
   "query": {
      "parent_id": {
	     "type": "comment",
		 "id": 1
	  }
   }
}'


curl -XGET localhost:9200/blog/_search?pretty -d'
{
   "query": {
      "has_child": {
         "type": "comment",
	 "query": {
	    "term" : { "text": "one" }
	 }
      }
   }
}'



curl -XGET localhost:9200/blog/_search?pretty -d'
{
   "query": {
      "has_child": {
         "type": "comment",
	    "score_mode": "sum",
	    "query": {
	       "term" : { "text": "one" }
	    }
      }
   }
}'

# 指定子文档的匹配数量
curl -XGET localhost:9200/blog/_search?pretty -d'
{
   "query": {
      "has_child": {
         "type": "comment",
	 "score_mode": "sum",
         "min_children": 2,
         "max_children": 15,
	 "query": {
	    "term" : { "text": "one" }
	 }
      }
   }
}'

# 父文档无法通过常规排序选项对子文档中的字段进行排序。
# 如果需要按子文档中的字段对父文档进行排序，则可以使用function_score查询
# 然后仅按_score进行排序
# 如：按子文档的clicked点击量对文章进行排序
curl -XGET localhost:9200/blog/_search?pretty -d'
{
   "query": {
      "has_child": {
         "type": "comment",
	 "score_mode": "max",
	 "query": {
	    "function_score" : {
	       "script_score": {
	          "script": "_score * doc.clicked.value"
	       }
            }
         }
      }
   }
}'


curl -XGET localhost:9200/blog/_search?pretty -d'
{
   "query": {
      "has_parent": {
      "parent_type": "article",
	 "query": {
	    "term" : {
	       "text": "one"
 	    }
         }
      }
   }
}'


curl -XGET localhost:9200/blog/_search?pretty -d'
{
   "query": {
      "has_parent": {
      "parent_type": "article",
      "score": false,
      "query": {
	 "term" : {
	       "text": "one"
 	    }
         }
      }
   }
}'

curl -XGET localhost:9200/shakespeare/_search?pretty -d'
{
   "query": {
      "more_like_this": {
         "like": "as well as",
         "fields": ["play_name", "text_entry"],
         "min_term_freq": 1,
         "max_query_terms": 5
      }
   }
}'


curl -XGET localhost:9200/shakespeare/_search?pretty -d'
{
   "query": {
      "more_like_this": {
         "fields": ["play_name", "text_entry"],
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


$ curl -XGET localhost:9200/shakespeare/_search?pretty -d'
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
$ curl -XGET localhost:9200/shakespeare/_search?pretty -d'
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












































curl -XGET -H "Content-Type: application/json" localhost:9200/shakespeare/_search?pretty -d'
{
    "query": {"terms": { "play_name": ["night", "dream"] }}
}'

curl -XGET -H "Content-Type: application/json" localhost:9200/shakespeare/_search?pretty -d'
{
    "query": {"range": {"speech_number": {"gte": 3,"lte": 5,"boost": 2.0}}}
}'





curl -XGET -H "Content-Type: application/json" localhost:9200/shakespeare/_search?pretty -d'
{
    "query": {"wildcard": { "play_name": "t*th" }}
}'



curl -XGET -H "Content-Type: application/json" localhost:9200/shakespeare/_search?pretty -d'
{
    "query": {"constant_score": {"filter": {"term": { "play_name": "night" }},"boost": 1.5}}
}'

curl -XGET localhost:9200/shakespeare/_search?pretty




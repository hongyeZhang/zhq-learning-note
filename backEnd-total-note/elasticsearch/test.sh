



curl -XGET -H "Content-Type: application/json" localhost:9200/shakespeare/_search?pretty -d'
{
    "query": {"constant_score": {"filter": {"term": { "play_name": "night" }},"boost": 1.5}}
}'

curl -XGET localhost:9200/shakespeare/_search?pretty

curl -XGET localhost:9200/_scripts/my_score?pretty


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

























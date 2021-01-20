

curl -XPOST -u elastic:123456 -H "Content-Type: application/json" "localhost:9200/people/_search?size=0&pretty=true" -d'
{
  "aggs": {
    "gender_filter": {
      "filter": {
        "term": {
          "gender.keyword": "F"
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






































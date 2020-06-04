



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


curl -XGET localhost:9200/_cat/indices?pretty

curl -XGET -u elastic:123456 localhost:9200/_cat/indices?pretty

curl -XGET -u elastic:123456 localhost:9200/_cat


curl -XGET -u elastic:123456 localhost:9200/.security-7?pretty


curl -H "Content-Type:application/json" -XPOST -u elastic localhost:9200/_xpack/security/user/elastic/_password -d '{ "password" : "123456" }'



curl -XGET -u elastic:123456 localhost:9200/_xpack/license?pretty
curl -XGET -u elastic:123456 localhost:9200/_xpack?pretty

curl -XGET -u elastic:123456 localhost:9200/_xpack/security/user?pretty

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

 curl -XGET -u elastic:123456 localhost:9200/_xpack/security/role?pretty





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




























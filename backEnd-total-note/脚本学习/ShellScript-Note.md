


# 脚本基础与操作实践


## 基础知识
### 命令替换
* $()与``(反引号)都是用来做命令替换(command substitution)
* ``基本上可在全部的unix shell中使用，若写成shell script移植性比较高。而$()并不是每一种shell都能使用。
* $var与${var}作用相同。但是用${ }会比较精确的界定变量名称的范围



## 快速过滤出来包含某些内容的行
```shell
#!/bin/bash
cat your_file_name | grep "you_need_filter_content" > result_file
```

## 如何批量删除redis中指定key数据（以set数据类型为例）？（shell）
```shell
#!/bin/bash

cat wait_deleted_redis_keys | while read member_key
do
  `redis-cli -h your_redis_host -p your_redis_password srem your_redis_set_key $member_key`
  echo "success:["$member_key"]" >> result_deleted_redis_keys.log
done
echo ">>>>>>>>>>>>>>DONE<<<<<<<<<<<<<" >> result_deleted_redis_keys.log
```






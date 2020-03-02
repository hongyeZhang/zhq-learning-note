CREATE TABLE `user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;

对于mysql中的AUTO_INCREMENT字段，可以在插入的时候赋值，也可以不赋值，该值会在上一条记录的基础上自增


INSERT IGNORE 与INSERT INTO的区别就是INSERT IGNORE会忽略数据库中已经存在 的数据，如果数据库没有数据，
就插入新的数据，如果有数据的话就跳过这条数据。这样就可以保留数据库中已经存在数据，达到在间隙中插入数据的目的。



  <insert id="insertOrUpdateBatch" parameterType="com.cmbchina.cms.dao.service.mybatis.po.page.ResourceLabel">
    insert into t_resource_label (ID, CHNL_ID, RESAUDIT_ID,
    RESOURCE_ID, MODULE_TYPE, LABEL_TYPE,
    LABEL_KEY, LABEL_VALUE, SUBMIT_TIME,
    UPDATE_TIME, DEL_FLAG)
    values
    <foreach collection ="list" item="item" index= "index" separator =",">
      (#{item.id,jdbcType=BIGINT}, #{item.chnlId,jdbcType=CHAR}, #{item.resauditId,jdbcType=BIGINT},
      #{item.resourceId,jdbcType=BIGINT}, #{item.moduleType,jdbcType=CHAR}, #{item.labelType,jdbcType=CHAR},
      #{item.labelKey,jdbcType=VARCHAR}, #{item.labelValue,jdbcType=VARCHAR}, #{item.submitTime,jdbcType=TIMESTAMP},
      #{item.updateTime,jdbcType=TIMESTAMP}, #{item.delFlag,jdbcType=CHAR})
    </foreach>
    ON DUPLICATE KEY
    UPDATE
    LABEL_VALUE = VALUES(LABEL_VALUE)
    , UPDATE_TIME = VALUES(UPDATE_TIME);
  </insert>

ON DUPLICATE KEY UPDATE
如果存在值，则插入，否则更新值

在MySQL中，还有一种方式可以删除表中的所有记录，需要使用TRUNCATE关键字。
TRUNCATE [TABLE] 表名

TRUNCATE语句和DELETE语句的区别

1、delete语句，是DML语句，truncate语句通常被认为是DDL语句。

2、delete语句，后面可以跟where子句，通常指定where子句中的条件表达式，只删除满足条件的部分记录，而truncate语句，只能用于删除表中的所有记录。

3、truncate语句，删除表中的数据后，向表中添加记录时，自动增加字段的默认初始值重新从1开始，而使用delete语句，删除表中所有记录后，向表中添加记录时，自动增加字段的值，为删除时该字段的最大值加1，也就是在原来的基础上递增。

4、delete语句，每删除一条记录，都会在日志中记录，而使用truncate语句，不会在日志中记录删除的内容，因此，truncate语句的执行效率比delete语句高。
---------------------
作者：Heart-Forever
来源：CSDN
原文：https://blog.csdn.net/nangeali/article/details/73620044
版权声明：本文为博主原创文章，转载请附上博文链接！



### mysql函数
DATE_SUB() 函数从日期减去指定的时间间隔。

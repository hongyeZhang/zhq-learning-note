
```sql



```
## mybatis缓存
Eh Cache 是一个纯牌的Java 进程内的缓存框架，具有快速、精干等特点

======================    MyBatis 学习知识点  ============================
resultMap 中一对一关系与一对多关系的配置
<resultMap id="getStudentInfoResultMap" type="EStudent">
    <id property="id" column="a_id"/>
    <result property="name" column="a_name"/>
    <!-- 一对一关系 -->
    <association property="myClass" javaType="EClass">
      <id property="id" column="b_id"/>
      <result property="name" column="b_name"/>
    </association>
    <!-- 一对多关系 -->
    <collection property="teachers" ofType="ETeacher">
      <id property="id" column="c_id"/>
      <result property="name" column="c_name"/>
      <result property="classId" column="c_classId"/>
    </collection>
</resultMap>


mybatis generator
mybatis plus
tk

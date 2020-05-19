
## 仅仅更改某一个类的日志打印级别 : 通过在命令行添加该类的参数
java -jar ./target/spring-boot-in-aciton-0.0.1-SNAPSHOT.jar --logging.level.com.learning.zhq.springbootinaciton.controller.HelloConroller=DEBUG

## springboot指定端口号启动
java -jar xxx.jar --server.port=8080
java -jar ./stream-hello/target/stream-hello-0.0.1-SNAPSHOT.jar --server.port=13000
java -jar ./stream-hello/target/stream-hello-0.0.1-SNAPSHOT.jar --server.port=13001

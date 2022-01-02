
* 编译期的Null-safety检查
@NonNull可以标注在方法、字段、参数之上，表示对应的值不可以为空
@Nullable注解可以标注在方法、字段、参数之上，表示对应的值可以为空
 以上两个注解在程序运行的过程中不会起任何作用，只会在IDE、编译器、FindBugs检查、生成文档的时候有做提示




## @Scheduled注解备忘录
* @Scheduled注解于方法上，与@EnableScheduling搭配使用
* 使用@Scheduled定义了多个Task，默认情况下是单个线程去执行。任务之间会相会影响。 比如定义了两个定时任务，必须要等第一个执行结束后才会执行第二个
* 多任务并发，可以使用@EnableAsync注解开启异步多线程执行。 然后在需要多线程执行的@Scheduled Task任务上注解@Async

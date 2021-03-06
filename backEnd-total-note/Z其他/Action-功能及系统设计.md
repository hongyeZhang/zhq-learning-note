
## 交易重复提交（防重设计）
前端 + 后端
* 前端： javaScript前端按钮置灰，禁止重复点击按钮
* 后端：先请求服务器，获得一个token，真正进行交易时，带着token请求后端服务，如果交易成功，则将token清除，
  避免重复交易。

#### 前端
用户在网页端或APP端（统称为客户端）上购买一个商品，通常都是以触发按钮的行为提交该请求，如果客户端没有做请求提交控制，
那么由于网络原因或者系统繁忙等原因（这是非常常见的场景），没有在用户期望的时间之内响应，那么用户就会再次点击，
那么这个请求又会发往服务端，那么服务端又会再次对这个请求进行处理。
客户端稍微优化一下，当用户的请求提交以后，将订单提交的请求按钮置为不可用的状态，待请求成功响应后跳转到下一步处理逻辑，或者是提单请求超时后再将订单提交按钮置为可用，提示用户上一次的提交可能已经失败，并允许用户再次提交。

#### 后端
1、数据库的乐观锁；(涉及到数据库操作，一般不会使用，尽量不要将此逻辑放到数据层)
2、防重表；(涉及到数据库操作，一般不会使用，尽量不要将此逻辑放到数据层)
3、token令牌；
4、分布式锁；
5、异步处理支付；

##### Token令牌 + 分布式锁的方式
    1、服务端根据交易前请求生成对应的Token，保存于服务端的Token库中，通常是缓存集群中，并将生成好的Token库下发给客户端；
    2、客户端在每次请求的时候，都带上对应的Token；
    3、服务端获取该Token对应的锁，如果获取成功，则继续下面的步骤；
    4、判断是否该Token是否合法，如果合法则继续下一步；
    5、处理真实的业务逻辑；
    6、业务处理成功后，从缓存中删除该Token；
    7、删除获取的分布式锁；

##### 异步处理
异步处理，通常的做法是将认为需要消费的交易，提交到消息队列中，并注册监听事件，待交易被处理完后，再由处理交易的应用回调注册的监听事件反馈处理的结果。交易处理的调度应用，需要负责对交易的处理符合幂等性的原则，将重复请求的交易请求做去重处理。






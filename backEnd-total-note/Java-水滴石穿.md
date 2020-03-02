#### clone
（1）要想实现深度克隆，要实现object中的clone方法。

#### hash
解决冲突的方法：（1）开放寻址法  （2）再哈希  （3）链地址法
因此有人会说，可以直接根据hashcode值判断两个对象是否相等吗？肯定是不可以的，因为不同的对象可能会生成相同的hashcode值。虽然不能根据hashcode值判断两个对象是否相等，但是可以直接根据hashcode值判断两个对象不等，如果两个对象的hashcode值不等，则必定是两个不同的对象。如果要判断两个对象是否真正相等，必须通过equals方法。
　　也就是说对于两个对象，如果调用equals方法得到的结果为true，则两个对象的hashcode值必定相等；
　　如果equals方法得到的结果为false，则两个对象的hashcode值不一定不同；
　　如果两个对象的hashcode值不等，则equals方法得到的结果必定为false；
　　如果两个对象的hashcode值相等，则equals方法得到的结果未知。

在重写equals方法的同时，必须重写hashCode方法

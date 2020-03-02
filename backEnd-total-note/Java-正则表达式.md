
### Matcher.matcher()与Matcher.find()的区别

当正则完全匹配字符串，从头到尾正好匹配上字符串，matches()方法是true，find()方法为false
当正则只能匹配字符串中的部分内容，matches()方法是fasle ,find()方法是true


find()方法是部分匹配，是查找输入串中与模式匹配的子串，如果该匹配的串有组还可以使用group()函数。

matches()是全部匹配，是将整个输入串与模式匹配，如果要验证一个输入的数据是否为数字类型或其他类型，一般要用matches()。
group是针对（）来说的，group（0）就是指的整个串，group（1） 指的是第一个括号里的东西，group（2）指的第二个括号里的东西。



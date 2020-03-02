（1） 定义字符串，单引号和双引号都可以

在JavaScript中，有5种基本数据类型和1种复杂数据类型，基本数据类型有：Undefined, Null, Boolean, Number和String；
复杂数据类型是Object，Object中还细分了很多具体的类型，比如：Array, Function, Date等等。

var num = 123;
var str = 'abcdef';
var bool = true;
var arr = [1, 2, 3, 4];
var json = {name:'wenzi', age:25};
var func = function(){ console.log('this is function'); }
var und = undefined;
var nul = null;
var date = new Date();
var reg = /^[a-zA-Z]{5,20}$/;
var error= new Error();

console.log(
    typeof num,
    typeof str,
    typeof bool,
    typeof arr,
    typeof json,
    typeof func,
    typeof und,
    typeof nul,
    typeof date,
    typeof reg,
    typeof error
);
// number string boolean object object function undefined object object object object



======================================    var 与 let 的区别    ==================

（1）作用范围不同： let添加了块级作用域
let作用于代码块（即{}）中；
var作用于函数中；

（2）声明提升区别：
let声明的变量不会提升；
var声明的变量会提升到作用域的头部；

（3）重复声明区别：
let不允许在相同作用域内重复声明；
var可以在相同作用域内重复声明

（4）let的暂时性死区
ES6规定如果块内存在let命令，那么这个块就会成为一个封闭的作用域，并要求let变量先声明才能使用，如果在声明之前就开始使用，它并不会引用外部的变量。

（5） let不会成为全局对象的属性
我们在全局范围内使用var声明一个变量时，这个变量会自动成为全局对象的属性(在浏览器和Node.js环境下，
这个全局对象分别是window和global)，但let是独立存在的变量，不会成为全局对象的属性：

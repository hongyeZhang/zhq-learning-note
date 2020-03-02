

win中的cmd命令行基础知识
dir
md 创建文件夹
rd 删除文件夹

node.js 是一个能够在服务端运行javascript的开放源代码、跨平台的javascript运行环境
node  单线程的
版本：奇数版为开发版，偶数版为稳定版

cms：内容管理  Content management system

ECMAScript标准的缺陷
没有模块系统（ES6有）、标准库较少、没有标准接口、缺乏类似于maven的管理系统

commonJS 规范
在node中，一个js文件就是一个模块
每一个js文件中的js代码都是独立运行在一个函数中
而不是全局作用域，一个模块中的变量和函数在其他模块中无法访问。
可以通过exports 向外部暴露方法和变量

引入模块：
require("/modulePath")

exports.x = "x";
exports.y = "y";
exports.func = function () {
};
将模块中的变量导出

使用require引入外部模块时，使用的是模块标识，可通过模块标识来找到指定的模块
模块分类：
      核心模块：标识就是模块的名字
          let fs = require("fs");
      用户模块：
          let math = require("./math");

node中的全局变量 global 和网页中的 window 类似
console.log(global)
在全局中创建的属性和方法都会作为global中的属性和方法进行保存

函数中定义全局变量的方法：
    a = 100;
    console.log(global.a);
console.log(arguments); 证明node中单个模块确实运行在函数里
console.log(arguments.callee);

打出调用的函数体：console.log(arguments.callee + "");

node在执行模块中的代码时，会首先在代码中添加如下代码：
进行一个函数的封装
function (exports, require, module, __filename, __dirname){

}
在函数执行时，node中传进来五个实参，
    exports：用来将变量或函数暴露到外部
    require：函数，用来引入外部的模块


=========  exports 和 module.exports的区别
exports 只能通过 点 的形式向外部暴露变量
module.exports 可以通过点 也可以通过对象来向外暴露

// exports.name = "孙悟空";
// exports.age = 18;
// exports.sayName = function () {
//     console.log("我是孙悟空");
// };

module.exports = {
    name: "name"
    , age: "18"
};

包规范：包结构和包描述文件
package.json  包的描述文件

NPM(node package manager)
第三方模块的发布、安装和依赖

npm -v
npm version
npm search 包名
npm init 初始化，产生一个json文件

npm install packageName   安装包
npm install packageName -g  全局安装包（全局安装的包，一般都是一些工具）
npm remove packageName  删除包
npm remove packageName --save 删除的同时，删除对应的依赖关系
npm install packageName --save  安装包并添加到依赖中
npm insall  下载当前项目所依赖的包，自动将所依赖的包进行安装


npm 添加国内的镜像服务器，基本与官方同步

cnpm 连接淘宝的服务器，二者的用法是一致的，只不过数据源不同
npm  连接美国的服务器

require("moduleName") 来寻找引用的包时，现在本目录的 node_module中寻找，如果找不到，则逐层向上
寻找，直到磁盘的根目录，找不到，则报错


==========  node基础    buffer缓冲区
buffer缓冲区，结构与数组很像，操作方法也和数组很像
数组中不能存储二进制文件，buffer中专门用来存储二进制文件

buffer中存储的是二进制数据，但是显示的时候采用16进制的形式显示
字节是数据传输时的最小单位，1 byte = 8 bit
buffer中的一个元素，占用内存中的一个字节
一个汉字占用三个字节

let buf2 = new Buffer(10);
console.log(buf2.length);

buffer的大小一旦确定，则不能修改，实际上是对底层内存的直接操作
只要是在页面或者控制台输出，一定是十进制

以16进制输出buffer中的内容
let buf3 = Buffer.alloc(10);
buf3[0] = 0xaa;
console.log(buf3[0].toString(16));


==========  node基础    文件系统
通过node操作系统中的文件
let fs = require("fs");
console.log(fs);

fs模块中的所有方法都分为同步和异步两种，异步不堵塞，通过回掉函数将结果返回。
文件的写入以后的教材均没有学习，等以后需要再学
https://www.bilibili.com/video/av46238305/?p=14

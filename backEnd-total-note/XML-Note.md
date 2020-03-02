XML 指可扩展标记语言  XML 被设计用来传输和存储数据。



XML 指可扩展标记语言（EXtensible Markup Language）
XML 是一种标记语言，很类似 HTML
XML 的设计宗旨是传输数据，而非显示数据
XML 标签没有被预定义。您需要自行定义标签。
XML 被设计为具有自我描述性。
XML 是 W3C 的推荐标准

XML 不是 HTML 的替代。
XML 和 HTML 为不同的目的而设计：
XML 被设计为传输和存储数据，其焦点是数据的内容。
HTML 被设计用来显示数据，其焦点是数据的外观。
HTML 旨在显示信息，而 XML 旨在传输信息。

XML 仅仅是纯文本
XML 没什么特别的。它仅仅是纯文本而已。有能力处理纯文本的软件都可以处理 XML。
不过，能够读懂 XML 的应用程序可以有针对性地处理 XML 的标签。标签的功能性意义依赖于应用程序的特性

XML 不会替代 HTML，理解这一点很重要。在大多数 web 应用程序中，XML 用于传输数据，而 HTML 用于格式化并显示数据。
对 XML 最好的描述是：XML 是独立于软件和硬件的信息传输工具。

XML 文档必须包含根元素。该元素是所有其他元素的父元素。
XML 文档中的元素形成了一棵文档树。这棵树从根部开始，并扩展到树的最底端。
所有元素均可拥有子元素：
<root>
  <child>
    <subchild>.....</subchild>
  </child>
</root>
具体事例
<bookstore>
<book category="COOKING">
  <title lang="en">Everyday Italian</title>
  <author>Giada De Laurentiis</author>
  <year>2005</year>
  <price>30.00</price>
</book>
<book category="CHILDREN">
  <title lang="en">Harry Potter</title>
  <author>J K. Rowling</author>
  <year>2005</year>
  <price>29.99</price>
</book>
<book category="WEB">
  <title lang="en">Learning XML</title>
  <author>Erik T. Ray</author>
  <year>2003</year>
  <price>39.95</price>
</book>
</bookstore>


XML 标签对大小写敏感。 XML 元素使用 XML 标签进行定义。
XML 标签对大小写敏感。在 XML 中，标签 <Letter> 与标签 <letter> 是不同的。
必须使用相同的大小写来编写打开标签和关闭标签：

XML 文档必须有根元素
XML 文档必须有一个元素是所有其他元素的父元素。该元素称为根元素。
XML 的属性值须加引号

实体引用
在 XML 中，一些字符拥有特殊的意义。
如果你把字符 "<" 放在 XML 元素中，会发生错误，这是因为解析器会把它当作新元素的开始。
这样会产生 XML 错误：
<message>if salary < 1000 then</message>
为了避免这个错误，请用实体引用来代替 "<" 字符：
<message>if salary &lt; 1000 then</message>
在 XML 中，有 5 个预定义的实体引用：
&lt; 	< 	小于
&gt; 	> 	大于
&amp; 	& 	和号
&apos; 	' 	单引号
&quot; 	" 	引号


什么是 XML 元素？
XML 元素指的是从（且包括）开始标签直到（且包括）结束标签的部分。

最佳命名习惯
使名称具有描述性。使用下划线的名称也很不错。
名称应当比较简短，比如：<book_title>，而不是：<the_title_of_the_book>。
避免 "-" 字符。如果您按照这样的方式进行命名："first-name"，一些软件会认为你需要提取第一个单词。
避免 "." 字符。如果您按照这样的方式进行命名："first.name"，一些软件会认为 "name" 是对象 "first" 的属性。
避免 ":" 字符。冒号会被转换为命名空间来使用（稍后介绍）。
XML 文档经常有一个对应的数据库，其中的字段会对应 XML 文档中的元素。有一个实用的经验，即使用数据库的名称规则来命名 XML 文档中的元素

XML 属性必须加引号  属性值必须被引号包围，不过单引号和双引号均可使用。比如一个人的性别，person 标签可以这样写：
<person sex="female"> 或者这样也可以： <person sex='female'>

拥有正确语法的 XML 被称为“形式良好”的 XML。
通过 DTD 验证的 XML 是“合法”的 XML。

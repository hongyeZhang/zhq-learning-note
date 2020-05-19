===========================  chapter1 自然语言处理基础  ============

用户自定义词典
1、jieba.load_userdict(file_name) 加载用户的自定义词典
2、add_word()  del_word() 动态修改词典
3、suggest_freq() 调节单个词的词频


==============  关键词提取
基于TF-IDF算法的关键词提取
jieba.analyse.extract_tags(sentence, topK)
IDF 逆向文件频率

基于TextRank算法的关键词提取
jieba.analyse.


==============  词性标注
jieba.posseg.POSTTokenizer()
https://www.bilibili.com/video/av52778253?from=search&seid=18240937029838571512

import jieba.posseg as pesg
这个可以直接分词之后再做词性标注

spacy 库

并行分词
python multiprocessing()

NLTK原本针对英文进行处理，不适合中文

Tokenize: 返回词语在原文的起止位置
chineseAnalyzer for Whoosh 搜索引擎





===========================  chapter2 从语言模型到朴素贝叶斯  ============
朴素贝叶斯


==================  JOIN 用法测试

    CREATE TABLE t_blog(
        id INT PRIMARY KEY AUTO_INCREMENT,
        title VARCHAR(50),
        typeId INT
    );

insert into t_blog(id, title, typeId)
values
(1, 'aaa', 1),
(2, 'bbb', 2),
(3, 'ccc', 3),
(4, 'ddd', 4),
(5, 'eee', 4),
(6, 'fff', 3),
(7, 'ggg', 2),
(8, 'hhh', NULL),
(9, 'iii', NULL),
(10, 'jjj', NULL);


CREATE TABLE t_type(
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(20)
);
insert into t_type
values
(1, 'c++'),
(2, 'c'),
(3, 'java'),
(4, 'c#'),
(5, 'javascript');

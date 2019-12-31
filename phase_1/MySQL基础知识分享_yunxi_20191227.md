# 一.MySQL的基础知识
![image](https://img.maihaoche.com/mhc-ui/1576129701270_157612970100057265.png)
### 1.数据库链接操作

```
/*连接mysql*/
mysql -h 地址 -P 端口 -u 用户名 -p 密码
例如: mysql -h 127.0.0.1 -P 3306 -u root -p ****

/*退出mysql*/
exit;
```
### 2.数据库操作

```
#数据库操作
/*关键字:create 创建数据库(增)*/
create database 数据库名 [数据库选项];
例如: create database test default charset utf8 collate utf8_bin;
/*数据库选项:字符集和校对规则*/
字符集:一般默认utf8;
校对规则常见: ⑴ci结尾的:不分区大小写 ⑵cs结尾的:区分大小写 ⑶bin结尾的：二进制编码进行比较

/*关键字:show 查看当前有哪些数据库(查)*/
show databases;

/*查看数据库的创建语句*/
show create database 数据库名;

/*关键字:alter 修改数据库的选项信息(改)*/
alter database 数据库名 [新的数据库选项];
例如: alter database test default charset gbk;

/*关键字:drop  删除数据库(删)*/
drop database 数据库名;

/*关键字:use 进入指定的数据库*/
use 数据库名;
```
### 3.表操作
#### 3.1 建表三大范式

##### 1．第一范式(确保每列保持原子性)
>第一范式是最基本的范式。如果数据库表中的所有字段值都是不可分解的原子值，就说明该数据库表满足了第一范式。
##### 2．第二范式(确保表中的每列都和主键相关)
>第二范式在第一范式的基础之上更进一层。第二范式需要确保数据库表中的每一列都和主键相关，而不能只与主键的某一部分相关（主要针对联合主键而言）。也就是说在一个数据库表中，一个表中只能保存一种数据，不可以把多种数据保存在同一张数据库表中。
##### 3．第三范式(确保每列都和主键列直接相关,而不是间接相关)
>第三范式需要确保数据表中的每一列数据都和主键直接相关，而不能间接相关。

#### 3.2 数据库一对一、一对多、多对多关系

##### 1. 一对一关系
> 一对一关系是最好理解的一种关系，在数据库建表的时候可以将人表的主键放置与身份证表里面，也可以将身份证表的主键放置于人表里面

![image](https://img.maihaoche.com/mhc-ui/rc-upload-1577754987679-2_WechatIMG856.png)
##### 2. 一对多关系
> 班级是1端，学生是多端，结合面向对象的思想，1端是父亲，多端是儿子，所以多端具有1端的属性，也就是说多端里面应该放置1端的主键，那么学生表里面应该放置班级表里面的主键
![image](https://img.maihaoche.com/mhc-ui/1576215405089_157621540500046644.png)

##### 3. 多对多关系
> 对于多对多关系，需要转换成1对多关系，那么就需要一张中间表来转换，这张中间表里面需要存放学生表里面的主键和课程表里面的主键，此时学生与中间表示1对多关系，课程与中间表是1对多关系，学生与课程是多对多关系
![image](https://img.maihaoche.com/mhc-ui/1576215518630_157621551800070383.png)

>总结：最重要的关系就是1对多关系，根据面向对象思想在建表的时候将1端主键置于多端即可。

```
#表的操作
/*关键字:create 创建数据表(增)*/
create table 表名(
字段1  字段1类型 [字段选项],
字段2  字段2类型 [字段选项],
字段n  字段n类型 [字段选项]
)表选项信息;

例如: create table test(
  id int(10) unsigned not null auto_increment comment 'id',
  content varchar(100) not null default '' comment '内容',
  time int(10) not null default 0 comment '时间',
  primary key (id)
)engine=InnoDB default charset=utf8 comment='测试表';

语法解析(下文MySQL列属性单独解析):
如果不想字段为NULL可以设置字段的属性为NOT NUL,在操作数据库时如果输入该字段的数据为NULL,就会报错.
AUTO_INCREMENT定义列为自增的属性,一般用于主键,数值会自动加1.
PRIMARY KEY关键字用于定义列为主键.可以使用多列来定义主键,列间以逗号分隔.
ENGINE 设置存储引擎,CHARSET 设置编码, comment 备注信息.


/*关键字:show 查询当前数据库下有哪些数据表(查)*/
show tables;

/*关键字:like 模糊查询*/
通配符：_可以代表任意的单个字符，%可以代表任意的字符
show tables like '模糊查询表名%';

/*查看表的创建语句*/
show create table 表名;

/*查看表的结构*/
desc 表名;

/*关键字:drop  删除数据表(删)*/
drop table [if exists] 表名
例如: drop table if exists test;

/*关键字:delete，truncate  删除表中的数据*/
delete from 表名
truncate table 表名
例如: truncate table if exists test;

/*关键字:alter 修改表名(改)*/
alter table 旧表名 rename to 新表名;

/*修改列定义*/
/*关键字:add 增加一列*/
alter table 表名 add 新列名 字段类型 [字段选项];
例如: alter table test add name char(10) not null default '' comment '名字';

/*关键字:drop 删除一列*/
alter table 表名 drop 字段名;
例如: alter table test drop content;

/*关键字:modify 修改字段类型*/
alter table 表名 modify 字段名 新的字段类型 [新的字段选项];
例如: alter table test modify name varchar(100) not null default 'admin' comment '修改后名字';
```
##### 4. 注意尽量不使用外键
> 性能问题（查询控制权限）<br>并发问题(死锁)<br>扩展性问题(迁移，分表分库外键无法生效)<br>技术问题(数据库开销变大)

### 4.数据操作

```
#数据操作
/*关键字:insert 插入数据(增)*/
insert into 表名(字段列表) values (值列表);
例如: create table user(
  id int(10) unsigned not null auto_increment comment 'id',
  name char(10) not null default '' comment '名字',
  age int(3) not null default 0 comment '年龄',
  primary key (id)
)engine=InnoDB default charset=utf8 comment='用户表';

/*外键，一个特殊的索引，只能是指定内容*/
create table color(
    nid int not null primary key,
    name char(16) not null
)

create table fruit(
    nid int not null primary key,
    smt char(32) null ,
    color_id int not null,
    constraint fk_cc foreign key (color_id) references color(nid)
)

```
#### 4.1 增

```
insert into 表 (列名,列名...) values (值,值,值...)
insert into 表 (列名,列名...) values (值,值,值...),(值,值,值...)
insert into 表 (列名,列名...) select (列名,列名...) from 表
```
#### 4.2 删

```
delete from 表
delete from 表 where id＝1 and name＝'alex'
```
#### 4.3 改

```
update 表名 set 字段1=新值1,字段n=新值n [修改条件]
例如：update 表 set name ＝ 'alex' where id>1
```
#### 4.4 查
##### 4.4.1 普通查询

```
select * from 表
select nid,name,gender as gg from 表
```

```
a、条件
    select * from 表 where id > 1 and name != 'alex' and num = 12;
 
    select * from 表 where id between 5 and 16;
 
    select * from 表 where id in (11,22,33)
    select * from 表 where id not in (11,22,33)
    select * from 表 where id in (select nid from 表)
b、限制
    select * from 表 limit 5;            - 前5行
    select * from 表 limit 4,5;          - 从第4行开始的5行
    
 oracle 的分页：
 SELECT *

  FROM (SELECT a.*, ROWNUM rn

          FROM (SELECT *

                  FROM table_name) a

         WHERE ROWNUM <= 40)

 WHERE rn >= 21
 
 sql sever的分页
 。。。

更多选项查询
```
##### 4.4.2、数据排序(查询)

```
select * from 表 order by 列 asc              - 根据 “列” 从小到大排列
select * from 表 order by 列 desc             - 根据 “列” 从大到小排列
select * from 表 order by 列1 desc,列2 asc    - 根据 “列1” 从大到小排列，如果相同则按列2从小到大排序
```
##### 4.4.3、模糊查询

```
select * from 表 where name like 'ale%'  - ale开头的所有（多个字符串）
select * from 表 where name like 'ale_'  - ale开头的所有（一个字符）
```
##### 4.4.4、聚合函数
>聚合函数的特点<br>
　　1.每个组函数接收一个参数（字段名或者表达式） 统计结果中默认忽略字段为NULL的记录<br>
　　2.要想列值为NULL的行也参与组函数的计算，必须使用IFNULL函数对NULL值做转换。<br>
　　3.不允许出现嵌套 比如sum(max(xx))<br>
　　
　　
###### 1.聚合函数 count ()，求数据表的行数

```
select count(*/字段名) from 数据表）——不建议conunt（*），建议用count（0）
```
###### 2.聚合函数 max()，求某列的最大数值

```
select max(字段名）from 数据表
```
###### 3.聚合函数min(),求某列的最小值

```
select min(字段名） from 数据表
```
###### 4.聚合函数sum(),对数据表的某列进行求和操作

```
select sum(字段名) from 数据表
```
###### 5.聚合函数avg()，对数据表的某列进行求平均值操作

```
select avg(字段名） from 数据表
```
###### 6.聚合函数和分组一起使用

```
select count(*), group_concat(age) from students group by age;

1、功能：将group by产生的同一个分组中的值连接起来，返回一个字符串结果。
2、语法：group_concat([distinct] 要连接的字段 [order by 排序字段 asc/desc ] [separator '分隔符'])
```
###### 7.数学函数

```
SELECT ABS(-8);  /*绝对值*/

SELECT CEILING(9.4);  /*向上取整*/

SELECT FLOOR(9.4);  /*向下取整*/

SELECT RAND();  /*随机数,返回一个0-1之间的随机数*/

SELECT SIGN(0); /*符号函数: 负数返回-1,正数返回1,0返回0*/
```
###### 8.字符串函数

```
SELECT CHAR_LENGTH(''); /*返回字符串包含的字符数*/

SELECT CONCAT('','','');  /*合并字符串,参数可以有多个*/

SELECT INSERT('',1,2,'');  /*替换字符串,从某个位置开始替换某个长度*/

SELECT LOWER(''); /*小写*/

SELECT UPPER(''); /*大写*/

SELECT LEFT('hello,world',5);  /*从左边截取*/

SELECT RIGHT('hello,world',5);  /*从右边截取*/

SELECT REPLACE('','','');  /*替换字符串*/

SELECT SUBSTR('',4,6); /*截取字符串,开始和长度*/

SELECT REVERSE(''); /*反转*/
```
###### 9.日期和时间函数

```
SELECT CURRENT_DATE();   /*获取当前日期*/
SELECT CURDATE();   /*获取当前日期*/

SELECT NOW();   /*获取当前日期和时间*/
SELECT LOCALTIME();   /*获取当前日期和时间*/
SELECT SYSDATE();   /*获取当前日期和时间*/

/*获取年月日,时分秒*/
SELECT YEAR(NOW());
SELECT MONTH(NOW());
SELECT DAY(NOW());
SELECT HOUR(NOW());
SELECT MINUTE(NOW());
SELECT SECOND(NOW());
```
#### 4.5、分组查询

```
分组
    select num from 表 group by num
    select num,nid from 表 group by num,nid
    select num,nid from 表  where nid > 10 group by num,nid order nid desc
    select num,nid,count(*),sum(score),max(score),min(score) from 表 group by num,nid
 
    select num from 表 group by num having max(id) > 10
 
    特别的：group by 必须在where之后，order by之前
```
#### 4.6、多表查询

```
a、连表
    无对应关系则不显示
    select A.num, A.name, B.name
    from A,B
    Where A.nid = B.nid
 
    无对应关系则不显示
    select A.num, A.name, B.name
    from A inner join B
    on A.nid = B.nid
 
    A表所有显示，如果B中无对应关系，则值为null
    select A.num, A.name, B.name
    from A left join B
    on A.nid = B.nid
 
    B表所有显示，如果B中无对应关系，则值为null
    select A.num, A.name, B.name
    from A right join B
    on A.nid = B.nid
b、组合
    组合，自动处理重合
    select nickname
    from A
    union
    select name
    from B
 
    组合，不处理重合
    select nickname
    from A
    union all
    select name
    from B
```



### 5.MySQL数据类型

```
#MySQL数据类型
/*MySQL三大数据类型:数值型、字符串型和日期时间型*/
```
![image](https://img.maihaoche.com/mhc-ui/1576127211662_157612721100038216.png)

```
/*数值型*/
```

![image](https://img.maihaoche.com/mhc-ui/1576127497246_157612749700023883.png)

```
/*字符串型*/
```
![image](https://img.maihaoche.com/mhc-ui/1576127647509_157612764700031783.png)

```
/*日期时间型*/
```
![image](https://img.maihaoche.com/mhc-ui/1576127715604_157612771500094958.png)

![image](https://www.sudo.ren/attachment/20190731/d19865a651e04e328e7daf749e2ecac8.jpg)


 - |关系型数据库 | 非关系型数据库（NoSql--->not only sql）
---|---|---
应用 | mariaDB, MySQL, Oracle, SQL Server 等 | mongoDB (文档型数据库), redis (键值型数据库), 列存储数据库  (HBase), Neo4j 等 |11
优点 | 1.易于维护：都是使用表结构，格式一致<br> 2.使用方便：SQL语言通用，可用于复杂查询；<br>3.复杂操作：支持SQL，可用于一个表以及多个表之间非常复杂的查询。 |1.格式灵活：存储数据的格式可以是key,value形式、文档形式、图片形式等等，文档形式、图片形式等等，使用灵活，应用场景广泛，而关系型数据库则只支持基础类型。<br>2.速度快：nosql可以使用硬盘或者随机存储器作为载体，而关系型数据库只能使用硬盘；<br>3.高扩展性 <br>4.成本低：nosql数据库部署简单，基本都是开源软件。。<br>5.支持分布式集群，负载均衡，性能高 |
缺点 | 1.每次操作都要进行sql语句的解析,消耗较大<br>2.读写性能比较差，尤其是海量数据的高效率读写；<br>3.固定的表结构，灵活度稍欠；(一致性)<br>4.高并发读写需求，传统关系型数据库来说，硬盘I/O是一个很大的瓶颈| 1.技术起步晚，维护工具以及技术资料有限<br>2.不支持 sql 工业标准<br>3.没有join等复杂的连接操作<br> 4.事务处理能力弱<br>5.没有完整性约束，对于复杂业务场景支持较差|
应用场景 || 1.为有数据更新的表做索引或表结构变更<br>2.字段不固定时的应用<br> 3.对简单查询需要快速返回结果的处理 |

---
首先一般非关系型数据库是基于CAP模型，而传统的关系型数据库是基于ACID模型的



# 一、redis基础
### 1、基础
\ | 优点 | 对比 
---|---|---|
redis | 1、开源的，使用C编写，基于内存且支持持久化<br>2、高性能的Key-Value的NoSQL数据库<br>3、支持数据类型丰富，字符串strings，散列hashes，列表lists，集合sets，有序集合sorted sets 等<br>4、支持多种编程语言（C C++ Python Java PHP ... ）| 1、MySQL : 关系型数据库，表格，基于磁盘，慢<br>2、MongoDB：键值对文档型数据库，值为JSON文档，基于磁盘，慢，存储数据类型单一

### 2、应用
\ | 应用场景 | 附加功能 
---|---|---|
redis | 1、使用Redis来缓存一些经常被用到、或者需要耗费大量资源的内容，通过这些内容放到redis里面，程序可以快速读取这些内容<br>2、一个网站，如果某个页面经常会被访问到，或者创建页面时消耗的资源比较多，比如需要多次访问数据库、生成时间比较长等，我们可以使用redis将这个页面缓存起来，减轻网站负担，降低网站的延迟，比如说网站首页等<br>　3、比如新浪微博<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# 新浪微博，基于TB级的内存数据库<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# 内容 ：存储在MySQL数据库<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# 关系 ：存储在redis数据库<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# 数字 ：粉丝数量，关注数量，存储在redis数据库<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# 消息队列<br> | 1、持久化 ：将内存中数据保存到磁盘中，保证数据安全，方便进行数据备份和恢复<br>2、发布与订阅功能 ：将消息同时分发给多个客户端，用于构建广播系统<br>3、过期键功能 ：为键设置一个过期时间，让它在指定时间内自动删除 <节省内存空间><br>           # 音乐播放器，日播放排名，过期自动删除<br>4、事务功能 ：原子的执行多个操作<br>5、主从复制<br>6、Sentinel哨兵 
### 3、Redis的诞生是为了解决什么问题？？

```
# 解决硬盘IO带来的性能瓶颈，同时也一定程度解决服务器的负载问题
```
### 4、默认端口号

```
redis 的默认端口是 6379
```
### 5、安装
- [官网下载](https://redis.io/download)，下载 stable 版本，稳定版本。
- 解压：tar zxvf redis-5.0.7.tar.gz
- 移动到：sudo mv redis-5.0.7 /usr/local/
- 切换到：cd /usr/local/redis-5.0.7/
- 编译测试： sudo make test
- 编译安装： sudo make install

### 6、启动与停止
**redis-server** 和 **redis-cli** 位于 redis-5.0.7/src 目录下
* 启动方式一：直接启动 Redis： redis-server ，成功后会看到下图：
![image](http://note.youdao.com/yws/res/539/A9D348CC288E4D0187F6C95CFB4E116B)
* 启动方式二：启动 Redis 并加载配置文件： **redis-server /etc/redis.conf**
* 打开redis客户端 **redis-cli**；如果有密码，可使用 auth yourpassword 做简单的密码登录
* 关闭方式一：在客户端执行 **SHUTDOWN** 可关闭 redis 服务（如果关闭不了就加一个参数，执行 **SHUTDOWN NOSAVE** 可关闭 redis 服务）
* 关闭方式二：如果用了zsh，可以执行 **kill redis** 并按 **tab**，结束 redis 进程，也可在活动监视器里结束掉进程。

### 7、配置
配置后台启动和增加一个连接密码，[配置文档](https://www.runoob.com/redis/redis-conf.html)
- 拷贝 redis-5.0.7/redis.conf 到 /etc 目录
- 修改 redis.conf 配置文件
  1. requirepass yourpassword 添加密码，在第500行；
  1. daemonize yes，设置后台启动，在第136行；
 
### 8、图形客户端下载
> 安装mac客户端 ： redis-desktop-manager
[官网下载地址](https://redisdesktop.com/)（收费）[github 下载地址](https://github.com/uglide/RedisDesktopManager/releases)（免费）[破解版及其使用方法](http://www.pc6.com/mac/486661.html/)（免费）
![image](http://note.youdao.com/yws/res/588/D84E4EAF91EC481A829C6790A64527A0)
### 9、客户端常用命令

命令 | 用途
---|---
set key value | 设置 key 的值
get key | 获取 key 的值
exists key | 查看此 key 是否存在
keys * | 查看所有的 key
flushall | 消除所有的 key

示例：
![image](http://note.youdao.com/yws/res/600/B24344078A8E4A39B8D4EC25AAE4689F)
# 二、nodejs+redis基础
### 1、安装
> **npm install redis --save**              --安装redis
### 2、连接
#### 1、获取redis的client

```
var redis = require('redis');
var client = redis.createClient('6379', '127.0.0.1');
```
#### 2、错误捕捉
```
client.on("error", function (err) {
    console.log("Error " + err);
});
```
#### 3、连接

```
client.on('connect', function () {
  
})
```



### 3、相关配置

```
client.auth("password") //设置密码（若没有密码则不写）
client.set('hello','This is a value');
client.expire('hello',10) //设置过期时间

client.exists('key') //判断键是否存在
client.del('key1') //通过key删除
client.get('hello'); //通过key获取
```
### 4、相关函数
##### 1、stirng

```
// 通过key删除值
client.del('key',function (err,data) {
    console.log(data)
})
// set 语法
client.set('name', 'long', function (err, data) {
    console.log(data)
})
// get 语法
client.get('name', function (err, data) {
    console.log(data)
})
// 将值value追加到给定键当前存储值的末尾(返回字符串长度) append('key', 'new-value')
client.append('name',5,function (err,data) {
    console.log(data)
})
// 获取指定键的index范围内的所有字符组成的子串
client.getrange('name',0,2,function (err,data) {
    console.log(data)
})
// 将指定键值从指定偏移量开始的子串设为指定值 setrange('key', 'offset', 'new-string')
client.setrange('name',0,'1112',function (err,data) {
    console.log(data)
})
```

##### 2、list

```
// 将给定值推入列表的右端 当前列表长度   ---rpush('key', 'value1' [,'value2']) (支持数组赋值)
client.lpush('class',1,function (err,data) {
    console.log(data)
})
// 获取列表在给定范围上的所有值
client.lrange('class',0,-1,function (err,data) {
    console.log(data)
})
// 从列表左端弹出一个值，并返回被弹出的值
client.lpop('class',function (err,data) {
    console.log(data)
})
// 从列表右端弹出一个值，并返回被弹出的值
client.rpop('class',function (err,data) {
    console.log(data)
})
```
##### 3、set

```
// sadd 将给定元素添加到集合 插入元素数量 sadd('key', 'value1'[, 'value2', ...]) (不支持数组赋值)(元素不允许重复)
client.sadd('class','12121',function (err,data) {
    console.log(data)
})
// 返回集合中包含的所有元素 array(无序) smembers('key')
client.smembers('class',function (err,data) {
    console.log(data)
})
// 检查给定的元素是否存在于集合中 sismenber('key')
client.sismenber('class','1',function (err,data) {
    console.log(data)
})
// srem 如果给定的元素在集合中，则移除此元素 srem('key', 'value')
client.srem('class','1',function (err,data) {
    console.log(data) // 1/0
})
// 返回集合包含的元素的数量 sacd('key')
client.sacd('class','1',function (err,data) {
    console.log(data) // 0/1
})
// 随机地移除集合中的一个元素，并返回此元素 spop('key')
client.spop('class',function (err,data) {
    console.log(data) // 0/1
})
// 返回那些存在于第一个集合，但不存在于其他集合的元素(差集) sdiff('key1', 'key2'[, 'key3', ...])
client.sdiff('class','name',function (err,data) {
    console.log(data)
})
// 返回那些同事存在于所有集合中的元素(交集) sinter('key1', 'key2'[, 'key3', ...])
client.sinter('class','name',function (err,data) {
    console.log(data)
})
// 返回那些至少存在于一个集合中的元素(并集) sunion('key1', 'key2'[, 'key3', ...])
client.sunion('class','name',function (err,data) {
    console.log(data)
})
```
##### 4、hash

```
// 在散列里面关联起给定的键值对 1(新增)/0(更新) hset('hash-key', 'sub-key', 'value') (不支持数组、字符串)
client.hset('class','name','1111',function (err,data) {
    console.log(data)
})
// 获取指定散列键的值 hget('hash-key', 'sub-key')
client.hget('class','name',function (err,data) {
    console.log(data)
})
// 获取散列包含的键值对 json hgetall('hash-key')
client.hgetall('class',function (err,data) {
    console.log(data)
})
// 如果给定键存在于散列里面，则移除这个键 hdel('hash-key', 'sub-key')
client.hdel('class',function (err,data) {
    console.log(data) // 0/1
})
// 为散列里面的一个或多个键设置值 OK hmset('hash-key', obj)
client.hmset('class','111',function (err,data) {
    console.log(data) // 0/1
})
// 从散列里面获取一个或多个键的值 array hmget('hash-key', array)
client.hmget('class','111',function (err,data) {
    console.log(data) //
})
// 获取散列包含的所有键 array hkeys('hash-key')
client.hkeys('class',function (err,data) {
    console.log(data) //
})
// 获取散列包含的所有键 array hvals('hash-key')
client.hvals('class',function (err,data) {
    console.log(data) //
})
```
##### 5、zset

```
// 将一个带有给定分支的成员添加到有序集合中 zadd('zset-key', score, 'key') (score为int)
client.zadd('class',1,'name',function (err,data) {
    console.log(data) 
})
// 根据元素在有序排列中的位置，从中取出元素
client.zrange('nameq',0,1,function (err,data) {
    console.log(data) 
})
// 获取有序集合在给定分值范围内的所有元素
// 区间的取值使用闭区间 (小于等于或大于等于)，你也可以通过给参数前增加 ( 符号来使用可选的开区间 (小于或大于)。
client.zrangebyscore('nameq',0,1,function (err,data) {
    console.log(data)
})
// 如果给定成员存在于有序集合，则移除
client.zrem('nameq','111',function (err,data) {
    console.log(data)
})
// 获取一个有序集合中的成员数量 有序集的元素个数 zcard('key')
client.zcard('nameq','111',function (err,data) {
    console.log(data)
})
```
以上就是redis+nodejs的一些基础知识，感谢大家的阅读！！！


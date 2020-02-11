## 一、图床简介
> 图床一般是指储存图片的服务器。写 markdown 文档的时候，往往因为本地图片没有链接导致很麻烦，我搭建图床就是为了解决这个问题。

#### url简单了解
示例：http://www.aspxfans.com:8080/news/index.asp?boardID=5&ID=24618&page=1#r_70732423
https://raw.githubusercontent.com/jianhunxia/imgBed/master/imgs/WechatIMG47.jpeg

一个完整的URL包括：
- 协议部分
- 域名部分
- 端口部分
- 虚拟目录部分
- 文件名部分
- 参数部分
- 锚部分

```
1.协议部分：该URL的协议部分为“http”，这代表网页使用的是HTTP协议。在Internet中可以使用多种协议，如HTTP，FTP等等本例中使用的是HTTP协议。在”HTTP”后面的“//”为分隔符

2.域名部分：该URL的域名部分为“www.aspxfans.com”。一个URL中，也可以使用IP地址作为域名使用

3.端口部分：跟在域名后面的是端口，域名和端口之间使用“:”作为分隔符。端口不是一个URL必须的部分，如果省略端口部分，将采用默认端口

4.虚拟目录部分：从域名后的第一个“/”开始到最后一个“/”为止，是虚拟目录部分。虚拟目录也不是一个URL必须的部分。本例中的虚拟目录是“/news/”

5.文件名部分：从域名后的最后一个“/”开始到“？”为止，是文件名部分，如果没有“?”,则是从域名后的最后一个“/”开始到“#”为止，是文件部分，如果没有“？”和“#”，那么从域名后的最后一个“/”开始到结束，都是文件名部分。本例中的文件名是“index.asp”。文件名部分也不是一个URL必须的部分，如果省略该部分，则使用默认的文件名

6.参数部分：从“？”开始到“#”为止之间的部分为参数部分，又称搜索部分、查询部分。本例中的参数部分为 “boardID=5&ID=24618&page=1” 。参数可以允许有多个参数，参数与参数之间用“&”作为分隔符。

7.锚部分：HTTP请求不包括锚部分，从“#”开始到最后，都是锚部分。本例中的锚部分是“r_70732423“。锚部分也不是一个URL必须的部分。
锚点作用：打开用户页面时滚动到该锚点位置。如：一个 html 页面中有一段代码，该 url 的 hash 为r_70732423
```


## 二、搭建个人图床的几种方式
- [阿里 OSS + PicGo](https://www.cnblogs.com/demojie/p/11600991.html#commentform)
- [Github + PicGo](https://www.jianshu.com/p/9d91355e8418)
- [七牛云 + PicGo](https://www.cnblogs.com/Dozeer/p/10965508.html)
- 利用gulp写脚本上传七牛
- 利用服务器自己实现图片上传

#### 1、PicGo 简介
> PicGo 是一款优秀的开源的图床工具，就是自动把本地图片上传到服务器并返回链接的工具。它是用 Electron-vue 开发的软件，支持微博，七牛云，腾讯云 COS，又拍云，GitHub，阿里云 OSS，SM.MS，imgur 等8种常用图床，功能强大，简单易用。

[PicGo下载地址](https://github.com/Molunerfinn/PicGo/releases)

#### 2、Github + PicGo 搭建图床
[参考教程](https://www.jianshu.com/p/9d91355e8418)

这个很简单，缺点是图片存储在 github 的服务器上，访问可能会比较慢。

#### 3、阿里云 OSS + PicGo 搭建图床
[参考教程](https://www.cnblogs.com/demojie/p/11600991.html#commentform)

有几点需要注意：
- 要添加自定义域名的话，要用没有使用的域名，可以自定义一个二级域名
- 添加完 PicGo 的阿里 OSS 配置后，要设为默认图床

#### 4、七牛云 + PicGo搭建图床
[参考教程](https://www.cnblogs.com/Dozeer/p/10965508.html)

![域名解析](http://pic.jianhunxia.com/imgs/WechatIMG19.png)

![七牛配置](http://pic.jianhunxia.com/imgs/20191125133543.png)

这个也是我现在使用的方式，有几点需要注意：
- 七牛的测试域名有效期为30天，最好购买一个域名
- 在域名解析里添加上你的存储空间对应的空间域名
- 在你的七牛存储空间里添加绑定域名
- 上传同名图片会覆盖，链接上加参数可以看到新图片

#### 5、七牛云 + gulp 脚本上传

```
1、安装上传所需依赖
$ yarn add gulp gulp-qiniu 

2、配置脚本命令
在package.json的scripts添加如下命令
"upload": "gulp qiniu"

3、在项目根目录配置gulpfile.js
var gulp = require("gulp");
var path = require("path");
var qiniu = require("gulp-qiniu");

// file upload tasks
var imageSrc = path.resolve(__dirname, "src/assets/img/*.*");

gulp.task("qiniu", function (done) {
  gulp.src(imageSrc).pipe(qiniu({
    accessKey: "你七牛云上的accessKey",
    secretKey: "你七牛云上的secretKey",
    bucket: "你七牛云上的存储空间名字",
    private: false
  }, {
      dir: '自定义一个存储路径，例 img/',
      version: false
    })).on('finish', done);
});

// combine tasks
gulp.task('upload', gulp.series(['qiniu'], function (done) {
  done();
}))

module.exports = gulp;

4、通过脚本上传 gulpfile.js 中配置的目录下的所有图片
$ yarn upload

```
有几点需要注意：
- 同样需要做好域名和解析
- 默认会跳过已经上传过的图片，同名但修改过的图片会覆盖
- 配置的域名+配置的存储路径+图片名即可访问


## 三、上传文件到七牛云
[命令行工具 qshell](https://developer.qiniu.com/kodo/tools/1302/qshell)、 [使用 qshell 同步目录](https://developer.qiniu.com/kodo/kb/1685/using-qshell-synchronize-directories)、[qshell github 文档](https://github.com/qiniu/qshell/blob/master/docs/qupload.md)
#### 1、qshell上传文件

```
1、下载 qshell 命令行工具文件

2、重命名为 qshell ,随便在用户根目录下创建个目录qshell,把文件拷贝到该目录
$ cd ~
$ mkdir qshell && cp /Users/user/Downloads/qshell ~/qshell

3、将shell路径加入到环境变量文件
$ open ~/.bash_profile
  添加一行：export PATH=$PATH:/Users/user/qshell
$ source ~/.bash_profile
$ qshell --version          // 查看是否配置成功

4、添加你的七牛云账户
$ qshell account <Your AccessKey> <Your SecretKey>

5、添加上传配置文件
$ cd ~/qshell
$ touch upload.conf
添加以下配置：
{
    "src_dir" : "/Users/user/Desktop/resource/static",  // 你要上传的文件所在目录
    "ignore_dir" : true,  // 忽略相对路径，防止重复上传
    "bucket" : "jianhao-static"   // 你的七牛云存储空间名
}

6、上传文件
$ qshell qupload upload.conf
上传成功可以在你的七牛云的存储空间-内容管理下看到你上传的文件
```


## 四、常见问题
#### 1、PicGo 剪贴板上传图片报错

报错信息：
```
picgo v2.1.2
报错：请检查上传配置
错误日志：Error creating a JP2 color space from ICC profile. Falling back to sRGB
```
在 [picgo 项目的 issue  ](https://github.com/Molunerfinn/PicGo/issues/199)找到暂时解决方案：

```
系统偏好设置-显示器-颜色-普通 RGB
```
ps: 在下个版本作者会修复这个 bug


未完待续。。。

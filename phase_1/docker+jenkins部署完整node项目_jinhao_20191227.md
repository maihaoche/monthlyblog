> 本文章是在下在部署个人博客时所学习到的docker相关知识和踩到的坑，在此记录整理总结。

## 一、Docker简介

> 虚拟机（virtual machine）就是带环境安装的一种解决方案，它可以在一种操作系统里面运行另一种操作系统。Docker是在linux服务器上运行的轻量级容器引擎，相较于传统的虚拟机，docker最大的特点就是容器本身耗费的额外资源极少。

#### 1、Docker 的主要用途：

- 提供一次性的环境。比如，本地测试他人的软件、持续集成的时候提供单元测试和构建的环境。
- 提供弹性的云服务。因为 Docker 容器可以随开随关，很适合动态扩容和缩容。
- 组建微服务架构。通过多个容器，一台机器可以跑多个服务，因此在本机就可以模拟出微服务架构。

#### 2、Docker和虚拟机对比：
特性 | Docker | 虚拟机
---|--- | ---
启动速 | 秒级 | 分钟级
交付/部署 | 开发、测试、生产环境一致 | 无成熟体系
性能 | 近似物理机级 | 性能损耗大
体量 | 极小（MB） | 较大（GB）
迁移/扩展 | 跨平台，可复制 | 较为复杂
系统支持量 | 单机支持上千个 | 一般几十个
#### 3、docker基本概念
![docker架构图](http://pic.jianhunxia.com/imgs/docker架构图191224.png)

- 镜像（Image）
- 容器（Container）
- 仓库（Repository）
- 宿主机（Host）：运行docker的服务器
```
镜像：Docker 把应用程序及其依赖，打包在 image 文件里面。可以简单的类比为电脑装系统用的系统盘，包括操作系统，以及必要的软件。例如，一个镜像可以包含一个完整的 centos 操作系统环境，并安装了 Nginx 和 Tomcat 服务器。注意的是，镜像是只读的。这一点也很好理解，就像我们刻录的系统盘其实也是可读的。我们可以使用 docker images 来查看本地镜像列表。

容器：可以简单理解为提供了系统硬件环境，它是真正跑项目程序、消耗机器资源、提供服务的东西。例如，我们可以暂时把容器看作一个 Linux 的电脑，它可以直接运行。那么，容器是基于镜像启动的，并且每个容器都是相互隔离的。注意的是，容器在启动的时候基于镜像创建一层可写层作为最上层。我们可以使用 docker ps -a 查看本地运行过的容器。

仓库：用于存放镜像。这一点，和 Git 非常类似。我们可以从中心仓库下载镜像，也可以从自建仓库下载。同时，我们可以把制作好的镜像 commit 到本地，然后 push 到远程仓库。仓库分为公开仓库和私有仓库，最大的公开仓库是官方仓库 Dock Hub，国内的公开仓库也有很多选择，例如阿里云等。
```

#### 借鉴资料：
- [docker入门教程（重要）](http://www.ruanyifeng.com/blog/2018/02/docker-tutorial.html)
- [docker从入门到实践（重要）](https://yeasy.gitbooks.io/docker_practice/content/)
- [docker hub官网](https://hub.docker.com/)
- [前端学Docker](https://mp.weixin.qq.com/s/p7kZamSckTdvgJVYNA1PXg)
- [Docker安装和简单使用](https://www.jianshu.com/p/d95c52d5ec3f)
- [Docker 搭建你的第一个 Node 项目到服务器](https://mp.weixin.qq.com/s/bNvcsRFi8-2N1dQv2YbpbA)

## 二、docker相关的开发流程
![docker部署流程图](http://pic.jianhunxia.com/imgs/docker流程191225.jpg)

通过上面的图可以看到项目开发的基本流程，我们按照上面流程来发布一个项目，以我的博客项目(h5项目+node服务项目)为例。

首先准备一个可用的h5项目和node项目（可以通过node app.js来运行该项目），现在我们已经将其上传到了github上。

接下来我们就要去服务器上安装docker，通过docker启动一个jenkins服务，jenkins通过git拉取代码，然后通过shell脚本来执行docker命令，制作镜像，然后启动node项目的服务。

## 三、docker安装 [参考](https://www.runoob.com/docker/centos-docker-install.html)

### 1、安装docker

```
1、安装一些必要的系统工具
$ sudo yum install -y yum-utils device-mapper-persistent-data lvm2

2、添加 docker 的 yum 镜像源，这里以阿里云为例
$ sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

3、更新 yum 缓存：
$ sudo yum makecache fast

4、安装 Docker-ce：
$ sudo yum -y install docker-ce

5、启动 Docker 后台服务
sudo systemctl start docker

6、配置镜像加速器 
加速地址获取:https://cr.console.aliyun.com/cn-hangzhou/instances/mirrors?accounttraceid=29a4aadf7b7a4b2c89236b3e7b2f67efgbzb

$ sudo mkdir -p /etc/docker
$ sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://tdcq9qtx.mirror.aliyuncs.com"]
}
EOF
$ sudo systemctl daemon-reload    // 重启守护进程
$ sudo systemctl restart docker   // 重启docker

7、docker_hub登陆
$ docker login              // 输入你的docker_hub地址

```

### 2、卸载docker
```
1、查询安装过的docker相关的包
yum list installed | grep docker
containerd.io.x86_64                 1.2.6-3.3.el7                     @docker-ce-stable
docker-ce.x86_64                     3:19.03.1-3.el7                   @docker-ce-stable
docker-ce-cli.x86_64                 1:19.03.1-3.el7                   @docker-ce-stable

2、删除安装的软件包和一些相关文件
$ sudo yum remove docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-selinux \
    docker-engine-selinux \
    docker-engine
$ rm -rf /etc/systemd/system/docker.service.d
$ rm -rf /var/lib/docker
$ rm -rf /var/run/docker

再查询安装过的包，没有信息表示卸载干净了
```

### 3、docker常用命令
```
service docker start                             // 开启docker服务
systemctl start docker                           // 启动 docker 后台服务
systemctl daemon-reload                          // 重启docker守护进程
systemctl restart docker                         // 重启docker服务
docker pull jenkins/jenkins                      // docker拉取镜像
docker images                                    // 查看镜像列表
docker ps -a                                     // 查看容器,不加-a查看正在运行的，加上-a查看所有容器
docker rm 容器id                                  // 删除容器
docker rmi 镜像id                                 // 删除镜像
docker rmi REPOSITORY/TAR                        // 删除镜像 例：docker rmi button-api/v2                        
docker stop 容器ID/容器别名                        // 关闭一个已启动容器 
docker start 容器ID/容器别名                       // 启动一个关闭的容器 
docker inspect 容器ID/容器别名                     // 查看一个容器的详情 
docker exec -it 容器ID/容器别名 /bin/bash          // 进入容器内部
docker build --rm --no-cache=true  -t jianghu-server .  // 生成镜像
docker run -d  --restart always --name jianghu-server -p 3006:3006 -v /var/jenkins_home/workspace/jianghu-server:/home/project jianghu-server  // 运行容器
```

## 四、docker安装jenkins

参考：[Docker版本Jenkins的使用、](https://www.jianshu.com/p/0391e225e4a6)  [使用docker+jenkins自动构建](https://segmentfault.com/a/1190000012921606)、[Docker 容器启动时端口映射失败](https://cao0507.github.io/2018/12/05/docker%E5%AE%B9%E5%99%A8%E5%90%AF%E5%8A%A8%E6%97%B6%E7%AB%AF%E5%8F%A3%E6%98%A0%E5%B0%84%E5%A4%B1%E8%B4%A5/)、[Docker in Docker](https://www.jianshu.com/p/43ffba076bc9)

### 1、下载jenkins镜像
从docker_hub官网找jenkins的镜像源，然后找到下载源的命令如下

```
$ docker pull jenkins/jenkins
```

### 2、启动jenkins容器

```
新建/home/jenkins_home并设置文件权限
$ mkdir /var/jenkins_home
$ sudo chown 777 /var/jenkins_home

启动jenkins容器
$ docker run -d -p 8080:8080 -p 50000:50000 -v /var/jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock -v /usr/bin/docker:/usr/bin/docker -v /etc/localtime:/etc/localtime --name jenkins docker.io/jenkins/jenkins
-d                                后台运行镜像
-p 8080:8080                      将镜像的8080端口映射到服务器的8080端口(服务器端口：镜像端口)
-p 50000:50000                    基于 JNLP 的 Jenkins 代理通过 TCP 端口 50000 与 Jenkins master 进行通信,所以也要映射
-v /var/jenkins_home:/var/jenkins_home                /var/jenkins_home目录为jenkins工作目录，我们将硬盘上的一个目录挂载到这个位置，方便后续更新镜像后继续使用原来的工作目录。
-v /var/run/docker.sock:/var/run/docker.sock          jenkins容器内也需要docker来执行任务，所以这里将docker命令也映射到容器里
-v /usr/bin/docker:/usr/bin/docker                    将docker命令映射到容器内
-v /etc/localtime:/etc/localtime  让容器使用和服务器同样的时间设置。
--name myjenkins                  给容器起一个别名
docker.io/jenkins/jenkins         使用刚下载的镜像安装

可能出现的错误：
1、"docker run" requires at least 1 argument.
原因:命令少了参数，即命令最后需要加jenkins安装来源:docker.io/jenkins/jenkins

2、Error response from daemon: driver failed programming external connectivity on endpoint jenkins (db9d8092ddb37d4243647cad8c63555e090b9
161d1f3c90db8d8c43281e9c86e):  (iptables failed: iptables --wait -t nat -A DOCKER -p tcp -d 0/0 --dport 8081 -j DNAT --to-destination 
172.17.0.2:8080 ! -i docker0:iptables: No chain/target/match by that name.
原因：端口映射失败，重启下docker

$ sudo systemctl restart docker

https://cao0507.github.io/2018/12/05/docker%E5%AE%B9%E5%99%A8%E5%90%AF%E5%8A%A8%E6%97%B6%E7%AB%AF%E5%8F%A3%E6%98%A0%E5%B0%84%E5%A4%B1%E8%B4%A5/

3、docker: command not found
jenkins容器内并没有docker命令，所以通过挂在docker命令目录来使容器内部可以找到docker命令，通过挂载docker.sock来让宿主机的docker执行相关命令
```

### 3、jenkins基础配置

##### 1、初始化jenkins
打开http://120.XXXX:8081/ 看到让你输入jenkins初始登陆密码，通过如下命令获取
```
$ docker exec jenkins tail /var/jenkins_home/secrets/initialAdminPassword
  76f4ac68586b4e14bb0f7f9c43912e92
```
然后复制密码去登陆，然后安装推荐的插件，安装好后设置jenkins登陆账号密码

##### 2、配置jenkins SSH 
这里的SSH是为容器配置的，可以让jenkins从github网站拉取代码

```
1、进入容器jenkins的内部
docker exec -it jenkins /bin/bash

2、生成ssh的密钥文件
ssh-keygen -t rsa -C "jianhunxia@163.com"，连续按三次回车就好

3、将 /var/jenkins_home/.ssh/id_rsa.pub的内容到 宿主机 的.ssh/authorized_keys文件中，或者通过下面的命令完成
手动复制：
exit && cd ~                        // 退出容器
mkdir .ssh && cd .ssh              // 创建并进入要发布的服务器的～/.ssh目录中

复制 /var/jenkins_home/.ssh/id_rsa.pub的内容到authorized_keys文件中，没有就先创建authorized_keys
方法1:echo "`tail /var/jenkins_home/.ssh/id_rsa.pub`" >> authorized_keys
方法2:cat /var/jenkins_home/.ssh/id_rsa.pub >> authorized_keys

或者命令完成(未成功)：https://www.jianshu.com/p/e34674f34242
ssh-copy-id -i ~/.ssh/id_rsa.pub <username>@<host>

4、重启SSH服务
systemctl restart sshd.service

5、将公钥配置到你的github/gitlab的SSH setting中
```

##### 3、配置jenkins 的Publish over SSH 
1、安装Publish Over SSH插件

首页 -> 点击系统管理 -> 管理插件 ->可选插件 -> 过滤：ssh -> 选择Publish Over SSH插件，点击直接安装。

如果安装失败，就去[插件下载地址](http://updates.jenkins-ci.org/download/plugins/publish-over-ssh/)，然后去插件管理-高级-上传插件即可

2、配置SSH

系统管理 -> 系统设置 -> 下拉，找到Publish over SSH

这里就是项目打包编译好后发送到哪个服务器的哪个目录
![image](http://pic.jianhunxia.com/imgs/jenkins_ssh191225.png)
点击下测试，如果成功了就保存，错误一般是密码不对

##### 4、配置node插件
因为我们的node项目需要node编译打包，所以安装下node插件
系统配置-插件管理-可选插件，搜索nodejs，直接安装
![image](http://pic.jianhunxia.com/imgs/jenkins_node191225.png)

然后去系统配置-全局工具管理-nodejs，配置几个你要用到的node版本

## 五、jenkins发布web项目
这里web项目用到了nginx来访问web项目，所以先去安装下nginx。

### 1、docker安装nginx
##### 1、下载镜像
```
docker pull nginx
```
##### 2、启动nginx容器
```
$ docker run -d -p 80:80 --name nginx  nginx
这时访问你的服务器公网ip即可看到nginx欢迎页面
```
##### 3、挂载配置文件
因为第二步运行的Nginx的配置文件是在容器内部的，不方便修改，所以我们可以先把容器内的配置文件复制到宿主机

```
创建nginx工作目录
$ mkdir -p nginx/conf nginx/www nginx/logs

拷贝配置文件到工作目录
$ docker cp -a nginx:/etc/nginx/nginx.conf ~/nginx/conf
```
##### 4、重启nginx容器

```
首先停止之前的容器并删除
docker stop nginx
docker rm nginx

重新启动容器并挂载工作目录
docker run -d --restart always -p 80:80 -v ~/nginx/www:/usr/share/nginx/html -v ~/nginx/conf/nginx.conf:/etc/nginx/nginx.conf -v ~/nginx/logs:/var/log/nginx --name nginx nginx

--restart always                                  // 表示docker重启时会自动重启该容器
-v ~/nginx/www:/usr/share/nginx/html              // 映射容器默认静态页面路径
-v ~/nginx/conf/nginx.conf:/etc/nginx/nginx.conf  // 映射容器配置文件
-v ~/nginx/logs:/var/log/nginx                    // 映射容器日志目录
```
再去访问你的服务器ip发现403,是因为www目录无内容，去新建一个index.html看下

```
$ cd ~/nginx/www
$ touch index.html
inde.html里内容如下：

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <title>Document</title>
</head>
<body>
  <h1>海上生明月，天涯共此时。</h1>
</body>
</html>
发现再去访问就能看到这个页面了
```

### 2、新建一个web项目部署任务 [参考](https://blog.csdn.net/qq_21767263/article/details/85930963)
##### 1、新建任务-填写任务名称-构建一个自由风格的软件项目

##### 2、源码管理
前边第四步已经配置过SSH，这里可以使用SSH协议的git项目地址

![image](http://pic.jianhunxia.com/imgs/jenkins_git191225.png)
出现上图报错，检查jenkins容器内是否安装了git或者版本是否过低，进入到jenkins容器内，查看git版本

```
[root@iZgm2xqy8dx52vZ ~]# docker exec -it jenkins /bin/bash
jenkins@8f133f801f50:/$   git --version     // jenkins@8f133f801f50:/$代表在jenkins容器内
v2.11.0
```

如果没有安装，去系统配置-全局工具配置-git，勾选自动安装试试，另外可以[参考](https://blog.csdn.net/wangfei0904306/article/details/56011877)
![image](http://pic.jianhunxia.com/imgs/jenkins_gitsetting191225.png)

如果git版本过低，可以试试下面[jenkins中安装/卸载/重装git](#jenkins_git)的操作。

如果容器的git没问题，ssh也配置过，还是报错的话，就把项目git地址换成https的，没有问题就再切回ssh协议的。
如果还有问题！！！

![image](http://pic.jianhunxia.com/imgs/meme太难了.jpeg)
![image](http://pic.jianhunxia.com/imgs/meme自闭.jpeg)

作为全联盟最快乐的男人，我剑豪绝不会就此放弃，在Credentials中添加下私钥，点击添加
![image](http://pic.jianhunxia.com/imgs/jenkins_秘钥191226.png)

然后发现，呦吼，终于可以了！

##### 3、构建环境
选择你配置的node插件
![image](http://pic.jianhunxia.com/imgs/jenkins_buildenvironment191225.png)

##### 4、构建
web项目，删除依赖-重新安装依赖-打包编译-压缩
![image](http://pic.jianhunxia.com/imgs/jenkins_build191225.png)

##### 5、构建后操作
打包编译后发送到要部署的服务上，最终的传输路径为SSH服务器的Remote directory+这里的Remote directory，比如我前边配置的是根目录/，这里是/home/umiPc, 所以
最终发送的路径为：要部署的SSH服务器的/home/umiPc，可以去该服务器的目录中查看一下。
![image](http://pic.jianhunxia.com/imgs/jenkins_afterBuild191225.png)

##### 6、执行构建操作
点击立即构建，等一会，不出意外的话，项目构建成功。 构建细节我们可以观察本次构建的控制台输出( Console Output) 来观察项目的执行过程。
这里构建可能失败，这里记录几种常见错误：

```
1、文件权限不足，解决方法如下：
chmod -R 777 /var/jenkins_home/workspace

2、node版本不合适，切换其他版本
```

![image](http://pic.jianhunxia.com/imgs/jenkins_error_nodeversion191225.png)
![image](http://pic.jianhunxia.com/imgs/jenkins_nodeversion191225.png)

```
3、构建失败，拉取项目超时

ERROR: Timeout after 10 minutes
ERROR: Error cloning remote repo 'origin'

可以去如下设置超时时间和拉取代码配置
```
![image](http://pic.jianhunxia.com/imgs/20191207235548.png)

##### 7、修改nginx配置代理项目

```
$ cd ~/nginx/conf
$ vim nginx.conf

nginx.conf改为如下内容：
user  root;
worker_processes  4;

events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    sendfile        on;

    keepalive_timeout  65;

    server {
        listen      80;
        server_name  localhost;

        location / {
          root /usr/share/nginx/html/umiMobile; 
          index  index.html index.htm;
          try_files $uri $uri/ /index.html;
        }

        location ^~ /static/ {
            root html;
        }

        # 代理服务端接口
        location /api/ {
            proxy_pass http://172.16.187.16:3006/;# 代理接口地址
        }
    }
}

root /usr/share/nginx/html/umiMobile为容器中存放你在jenkins静态页面的路径
```

更改了nginx.conf,要重启nginx服务才生效
```
docker restart nginx                              // 重启nginx服务
```

如果不出意外，重新访问ip，你就能看到自己项目页面了，嘎嘎～

![image](http://pic.jianhunxia.com/imgs/memebiu.jpeg)

tips: 发现容器启动不正常，除了百度谷歌以外，更要去~/nginx/logs目录下看错误日志，你会发现有惊喜的。


### <span id="jenkins_git">3、jenkins中的git安装</span>
切记：以下操作在jenkins容器内操作！！！

##### 1、查看 Git 信息
首先进入容器查看是否安装了git

```
进入jenkins容器
$ docker exec -it jenkins /bin/bash

查看git版本
$ git --version
it version 1.7.1

查看 yum 源仓库的 Git 信息
$ yum info git
    Loaded plugins: fastestmirror
    Loading mirror speeds from cached hostfile
    Installed Packages
    Name        : git
    Arch        : x86_64
    Version     : 1.8.3.1
    Release     : 20.el7
    Size        : 22 M
    Repo        : installed
    From repo   : updates
    Summary     : Fast Version Control System
    URL         : http://git-scm.com/
    License     : GPLv2
    Description : Git is a fast, scalable, distributed revision control system with an
```

yum上的git最高就到1.8了，所以需要从拉取git文件自行编译安装

##### 2、安装依赖库

```
$ cd /usr/src   // 切换到包文件存放目录
$ yum install curl-devel expat-devel gettext-devel openssl-devel zlib-devel
$ yum install  gcc perl-ExtUtils-MakeMaker
```


##### 3、卸载低版本git,在此时再卸载是因为安装依赖的时候默认把git安装了！！！

```
# yum remove git
```

##### 4、下载高版本git [下载地址查看](https://mirrors.edge.kernel.org/pub/software/scm/git/)

```
$ wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.11.0.tar.gz
$ tar -zxvf git-2.11.0.tar.gz // 解压
$ cd git-2.11.0
```

##### 5、编译并安装

```
# make prefix=/usr/local/git all
# make prefix=/usr/local/git install
```

##### 6、把git的Path添加到环境变量

```
# echo "export PATH=$PATH:/usr/local/git/bin" >> /etc/bashrc
# source /etc/bashrc            // 使环境配置文件生效
# git --version                 // 查看是否安装成功
```

ps：容器内的git和宿主机的git不是同一个，一定要牢记容器和宿主机是隔离的。



## 六、通过jenkins+docker部署node项目
这里我们要为node项目制作一个镜像，然后通过这个镜像来启动node服务。
制作镜像有多种方式，这里我们使用Dokerfile的方式来制作。

### 1、添加docker镜像文件
在你准备好的node项目里根目录，新建一个叫Dockerfile的文件，内容如下:

```
FROM node:12.13

# 指定工作目录或者称当前目录，如果目录不存在，会自动建立，以后的命令就
WORKDIR /usr/src/app

# 复制上下文的文件到容器工作目录, 和下面分开复制是为了镜像分层保证依赖文件没改变时无需重新安装依赖
COPY package*.json ./

# 安装项目依赖
RUN npm install --registry=https://registry.npm.taobao.org

# 将上下文里到项目文件拷贝到工作目录
COPY . ./
# 暴露容器的3006端口
EXPOSE 3006

# 启动node服务
CMD [ "node", "app.js" ]
```
文件里的内容就是通过该镜像启动node服务时需要做的事，文件的语法参考上面的 [docker从入门到实践](https://yeasy.gitbooks.io/docker_practice/content/)
再添加一个叫.dockerignore的文件，内容如下：

```
node_modules
.eslintignore
.eslintrc.js
jest.config.js
README.md
```
这个文件的作用类似于.gitignore,拷贝项目文件到容器时，忽略哪些文件。

### 2、在jenkins上添加一个node的任务
### 1、创建流程 
同上面建立web项目任务一样操作，添加项目git地址

构建环境选择：Send files or execute commands over SSH after the build runs， 然后配置如下：

![image](http://pic.jianhunxia.com/imgs/20191225235454.png)

Exec command部分内容如下：
```
# 切换到源码目录,对应在jenkins-home的workspace下面
cd /var/jenkins_home/workspace/jianghu-server
pwd

# 设置tag
# image_version=`date +%Y%m%d%H%M`;
# echo $image_version;

# 停止之前的docker container
docker stop jianghu-server;

# 删除这个container
docker rm jianghu-server;

# 删除这个container
docker rmi jianghu-server:latest;

# build镜像
docker build --rm --no-cache=true  -t jianghu-server .;
docker images;

# 把刚刚build出来的镜像跑起来
docker run -d  --restart always --name jianghu-server -p 3006:3006 -v /var/jenkins_home/workspace/jianghu-server:/home/project jianghu-server:latest;
docker logs jianghu-server;
```
这里的命令就是去根据node项目Dockerfile文件去制作镜像，然后使用该镜像启动容器，运行该node服务。应用保存，点击立即构建，如果一切顺利会发现该服务已经能够访问。

如果不顺利就看看是否是下面的问题
#### 2、常见问题

```
1、任务执行失败
去该任务记录的控制台输出里查看具体原因，一般就是容器内无docker命令、权限不够之类的，检查上面安装jenkins的步骤是否有遗漏，停止jenkins容器，删除jenkisn容器，重新启动jenkins容器即可。

2、任务执行成功，访问不到该node服务
有可能是你服务器的该node端口或者防火墙端口未开放。服务器上该端口未开放就去该服务器实例的网络和安全组中去开放，防火墙端口可通过如下命令查看。

centOs7.0开始使用firewall作为防火墙，而不是iptables，开放端口的方式也不一样了。
firewall-cmd --state                                // 查看防火墙状态，running表示开启了
systemctl start firewalld.service                   // 开启防火墙
systemctl stop firewalld.service                    // 开启防火墙
systemctl restart firewalld.service                 // 重启防火墙
firewall-cmd --reload                               // 重新载入配置
firewall-cmd --query-port=8080/tcp                  // 查看端口是否开放
firewall-cmd --zone=public --list-ports             // 查看所有开放的端口列表
firewall-cmd --zone=public --add-port=8080/tcp --permanent      // 永久开启端口，要重启防火墙才生效
    zone=public：表示作用域为公共的；
    add-port=8080/tcp：添加tcp协议的端口8080；
    permanent：永久生效，如果没有此参数，则只能维持当前服务生命周期内，重新启动后失效；
firewall-cmd --permanent --remove-port=666/tcp                  // 关闭端口
```
一切搞定之后查看服务已经愉快滴运行了~~~


## 七、安装Mysql
我的node服务中连接了mysql数据库，所以最后我要把mysql也安装一下
### 1、下载镜像
去docker.hub搜索mysql的镜像，并下载

```
$ docker pull mysql               // 下载最新的镜像
$ docker images -a                // 查看所有镜像
$ docker images |grep mysql       // 查看mysql镜像
$ mysql --help | grep Distrib     // 查看mysql版本
```

### 2、启动mysql的容器

```

docker run --name mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 -d mysql

-p 3306:3306：将容器的3306端口映射到主机的3306端口
-v $PWD/conf/my.cnf:/etc/mysql/my.cnf：将主机当前目录下的conf/my.cnf挂载到容器的/etc/mysql/my.cnf
-v $PWD/logs:/logs：将主机当前目录下的logs目录挂载到容器的/logs
-v $PWD/data:/mysql_data：将主机当前目录下的data目录挂载到容器的/mysql_data
-e MYSQL_ROOT_PASSWORD=123456：初始化root用户的密码

$ docker ps
查看mysql容器是否运行
```

### 3、登陆mysql并创建远程连接 [参考](https://blog.csdn.net/call_me_back/article/details/98891291)

```
$ docker exec -it mysql bash   // 进入容器

$ mysql -u root -p             // 登陆输入上面的密码

$ CREATE USER 'jianhao'@'%' IDENTIFIED WITH mysql_native_password BY '123456';
进入到mysql容器内部才能执行命令设置远程登陆账号密码

$ GRANT ALL PRIVILEGES ON *.* TO 'jianhao'@'%';  // 开启远程访问权限

$ flush privileges;    // 刷新权限

```
然后用Navicat连接查看下，搞定！！！然后node项目中就可以通过ip:3306愉快滴来连接数据库了。

![告辞](http://pic.jianhunxia.com/imgs/meme告辞.jpeg)

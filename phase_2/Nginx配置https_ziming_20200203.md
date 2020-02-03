## 安装 nginx

有可能你当前已经通过 `apt-get` `yum` 等命令安装了，但是可能不支持 https http2 ipv6 等功能。



### 查看当前版本配置

我们可以通过 `nginx -V` 命令来查看版本以及支持的配置。

![](http://file.wangsijie.top/blog/20200203093550.png)



下面这以 ubuntu 为例，卸载安装 nginx

### 卸载

```powershell
# 移除 nginx
$ apt-get --purge remove nginx

# 查询 nginx 依赖的包，会列出来
$ dpkg --get-selections|grep nginx

# 移除上面列出的包，例如 nginx-common
$ apt-get --purge remove nginx-common

# 也可以执行 autoremove ，会自动删除不需要的包
$ apt-get autoremove

# 查询 nginx 相关的文件，删掉就可以了
$ sudo find / -name nginx*

```

### 安装

安装依赖库

```powershell
# gcc g++
apt-get install build-essential
apt-get install libtool

# pcre
sudo apt-get install libpcre3 libpcre3-dev

# zlib
apt-get install zlib1g-dev

# ssl
apt-get install openssl
apt-get install libssl-dev
```



安装 nginx

到 [nginx download](https://nginx.org/en/download.html) 上找到最新的nginx 版本

```powershell
# 下载
$ wget https://nginx.org/download/nginx-1.17.8.tar.gz
# 解压
$ tar -zxvf nginx-1.17.8.tar.gz
# 进入目录
$ cd nginx-1.17.8
# 配置，这里可能会报错，缺少啥就去安装啥
$ ./configure --prefix=/usr/local/nginx \
--with-http_gzip_static_module \
--with-http_v2_module \
--with-pcre \
--with-http_ssl_module

# 编译，这里可能会报错，缺少啥就去安装啥
$ make

# 安装
$ make install

# 通过软连接，这样就可以直接使用 nginx 执行
$ sudo ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx
```



## SSL 证书

SSL 证书通常需要购买，也有免费的，通过第三方 SSL 证书机构颁发。你也可以在云服务商上购买，但是一般免费的 ssl 证书只能支持单个域名。

这里推荐 [Let’s Encrypt](https://letsencrypt.org/zh-cn/) 机构，然后使用 [acme.sh](https://github.com/acmesh-official/acme.sh) 从 letsencrypt 生成免费的证书，且可以生成泛域名证书。

参考 [acme.sh 中文 wiki](https://github.com/acmesh-official/acme.sh/wiki/说明) 、[使用 acme.sh 部署 Let's Encrypt 通过阿里云 DNS 验证方式实现泛域名 HTTPS](https://f-e-d.club/topic/use-acme-sh-deployment-let-s-encrypt-by-ali-cloud-dns-generic-domain-https-authentication.article)

上面的两篇文章讲的很详细了，不再赘述。



PS：

- 建议使用 DNS 验证
- `--dns dns_ali`  是根据不同服务商来的，`dns_ali` 就是指阿里云。其他服务商的参考 [How to use DNS API](https://github.com/acmesh-official/acme.sh/wiki/dnsapi) 。
- 证书生成后，默认在 `~/.acme.sh/` 目录下，这里的文件是内部使用的，需要使用 `--installcert` 命令指定到目标位置



这里将证书放到了 nginx 的 conf 目录下。`.../conf/ssl/...`



## 配置 http

### http 基础配置

http 的配置很简单，配置如下，我们先让网站可以访问起来。

```nginx
server {
    listen  80;
    server_name     wangsijie.top www.wangsijie.top;

    location / {
        root /var/www/main;
        index index.html;
    }
}
```

使用 `http:// `访问，就会如下显示

![](http://file.wangsijie.top/blog/20200202134046.png)

## 配置 https

### Https 基础配置

```nginx
server {
    listen                  443 ssl;
    server_name             wangsijie.top www.wangsijie.top;
    # 证书文件，这里使用了 fullchain.cer 通过 acme.sh 生成的泛域名证书
    ssl_certificate         ssl/fullchain.cer;
    # 私钥文件
    ssl_certificate_key     ssl/wangsijie.top.key;
    
    location / {
        root /var/www/main;
        index index.html;
	}
}
```



重启后，以 `https://` 开头访问你的网站，就会发现



![](http://file.wangsijie.top/blog/20200202135322.png)



![](http://file.wangsijie.top/blog/20200202135347.png)

### 修改 http 配置

但是用 `http://` 访问，仍旧显示连接不安全，我们需要修改配置，当访问 http 时会重定向到 https 如下

```nginx
server {
    listen  80;
    server_name     wangsijie.top www.wangsijie.top;

    return  301 https://$server_name$request_uri;
}
```

这时再用 `http://` 访问，就会重定向到 `https://`

PS: 

网上也有许多使用 `rewrite` 来重定向，但是 `return` 指令简单高效，建议尽量使用 `return`



### 完整配置

```nginx
server {
    listen  80;
    server_name     wangsijie.top www.wangsijie.top;

    return  301 https://$server_name$request_uri;
}
server {
    listen                  443 ssl;
    server_name             wangsijie.top www.wangsijie.top;
    ssl_certificate         ssl/fullchain.cer;
    ssl_certificate_key     ssl/wangsijie.top.key;
    
    location / {
        root /var/www/main;
        index index.html;
	}
}
```

### 混合配置

```nginx
server {
    listen  				80;
    listen                  443 ssl;
    server_name             wangsijie.top www.wangsijie.top;
    ssl_certificate         ssl/fullchain.cer;
    ssl_certificate_key     ssl/wangsijie.top.key;
    
    location / {
        root /var/www/main;
        index index.html;
	}
}
```



## https 安全

### 加密套件

https 默认采用 SHA-1 算法，非常脆弱。我们可以使用 [迪菲-赫尔曼密钥交换]([https://zh.wikipedia.org/wiki/%E8%BF%AA%E8%8F%B2-%E8%B5%AB%E7%88%BE%E6%9B%BC%E5%AF%86%E9%91%B0%E4%BA%A4%E6%8F%9B](https://zh.wikipedia.org/wiki/迪菲-赫爾曼密鑰交換))。

我们在 `/conf/ssl` 目录下生成 `dhparam.pem` 文件

```powershell
openssl dhparam -out dhparam.pem 2048
```

下面的指令 `ssl_protocols` 和 `ssl_ciphers` 是用来限制连接只包含 SSL/TLS 的加強版本和算法。

```nginx
# 优先采取服务器算法
ssl_prefer_server_ciphers on;
# 使用 DH 文件
ssl_dhparam 			ssl/dhparam.pem;
# 协议版本
ssl_protocols           TLSv1 TLSv1.1 TLSv1.2;
# 定义算法
ssl_ciphers			EECDH+CHACHA20:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;
```



### 安全的响应头

```nginx
# 启用 HSTS 。允许 https 网站要求浏览器总是通过 https 来访问
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains;preload" always;
# 减少点击劫持
add_header X-Frame-Options DENY;
# 禁止服务器自动解析资源类型
add_header X-Content-Type-Options nosniff;
# 防XSS攻擊
add_header X-Xss-Protection 1;
```

## 服务器优化

```nginx
# 配置共享会话缓存大小
ssl_session_cache   shared:SSL:10m;
# 配置会话超时时间
ssl_session_timeout 10m;
```

## http2 配置

http2 配置很简单，只要后面增加 http2。

下面 `[::]:` 表示 ipv6 的配置，不需要可以不加那一行

```nginx
listen  80;
listen  [::]:80;
listen	443 ssl http2;
listen	[::]:443 ssl http2;
```



重新 nginx 后，你可以在这个网站上 https://tools.keycdn.com/http2-test 测试http2有没有配置成功。

![](http://file.wangsijie.top/blog/20200202223844.png)



## 最后

### 完整配置

```nginx
server {
    listen                  80;
    listen                  [::]:80;
    listen                  443 ssl http2;
    listen                  [::]:443 ssl http2;
    server_name             wangsijie.top www.wangsijie.top;
    
    ssl_certificate         ssl/fullchain.cer;
    ssl_certificate_key     ssl/wangsijie.top.key;

    ssl_session_cache       shared:SSL:10m;
    ssl_session_timeout     10m;

    ssl_prefer_server_ciphers on;
    ssl_dhparam 			ssl/dhparam.pem;
    ssl_protocols           TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers     EECDH+CHACHA20:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;

    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-Xss-Protection 1;

    location / {
            root /var/www/main;
            index index.html;
    }
}
```



### 配置文件优化 

为了让更多的二级域名支持上面的功能，每个 server 都这么写太过于繁琐。

可以将 listen 443 、ssl、add_header 相关的单独写在一个文件上，然后使用 `inculde` 指令。



如下：其他的配置都放在了` conf.d/https-base.conf `中

```nginx
server {
    listen                  8099;
    listen                  [::]:8099;
    server_name             test.wangsijie.top;

    include                 conf.d/https-base.conf;

    location / {
            root /var/www/test;
            index index.html;
    }
}
```





以上就完成了 https 的配置，愉快的访问你的网站吧。



## 参考链接

[Nginx 中文文档](https://www.kancloud.cn/wizardforcel/nginx-doc/92353)
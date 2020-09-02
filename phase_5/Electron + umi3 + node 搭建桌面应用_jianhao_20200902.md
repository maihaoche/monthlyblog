## 一、Electron 简介
> Electron（原名为Atom Shell）是 GitHub 开发的一个开源框架。 它允许使用 Node.js 和 Chromium 完成桌面 GUI 应用程序的开发。

### 1、Electron 是什么？
![electron 简介](http://pic.jianhunxia.com/imgs/electronIntroduction20200819090751.png)

Electron 相当于结合了以上三者的能力，可以让你用 web 开发的方式去开发桌面应用，并且通过 node 的npm包提高开发效率，利用 native 的 api 来调动原生能力。

### 2、Electron 能做哪些应用
![electron apps](http://pic.jianhunxia.com/imgs/electronApps20200821094159.png)

Electron 涉及的应用众多，目前最多的是效率应用和开发者工具。<br />
如果有些业务需要同时迭代 web 和桌面端，那么基于 electron 就可以复用大量代码，提高开发效率。

### 3、学习 electron 的好处

#### 开发一些实用工具
electron 开发一些小工具可谓是方便快捷，我们组内小伙伴薯片曾经写过一个可以获取各个测试环境的用户 sessionId 的小工具，让开发测试体验无比顺畅，不需要再去查库了。

#### 提高技术深度广度
学习 electron 的过程中，可以让我们从 web 端扩展到桌面端，并且对于浏览器渲染、系统能力调用都有一个更深的理解。

### 4、electron 与常见的桌面端开发技术对比
![electron与其他技术对比](http://pic.jianhunxia.com/imgs/electronCompare20200823123245.png)

electron的优点有支持跨平台、使用web技术开发、社区很活跃、有多个成功的大型应用案例，缺点是打包体积较大（包含chromium）、性能一般（较原生）。

## 二、Electron 项目简单了解

开发 electron 需要一些简单的环境配置，这里简单看下。<br/>

1. 首先你需要一个好用的编辑器，这里推荐 VScode、Atom，因为它们用 electron 开发的非常流行的编辑器，对 electron 的支持也非常好。
2. 其次要安装好 nodejs 和 npm，建议使用 [nvm](https://www.cnblogs.com/kaiye/p/4937191.html) 来管理 node 版本，方便快捷实用。当然，如果你喜欢用 [yarn](https://yarn.bootcss.com/docs/getting-started/) 来代替 npm 的话会更好。

接下来了解下 electron 中的两种主要进程，主进程和渲染进程。<br/>
![electron 进程](http://pic.jianhunxia.com/imgs/electronPrecess20200823205752.png)
Electron 运行 package.json 的 main 脚本的进程被称为主进程。 在主进程中运行的脚本通过创建web页面来展示用户界面，一个 Electron 应用总是有且只有一个主进程。

由于 Electron 使用了 Chromium 来展示 web 页面，所以 Chromium 的多进程架构也被使用到。 每个 Electron 中的 web 页面运行在它的叫渲染进程的进程中。

终于要开始搭建一个最简单的 electron 应用了，Let's begin！

1. 安装 electron 并初始化项目

```
yarn init                   // 初始化 package.json
yarn add electron           // 安装 electron

```

2. 添加 web 页面 index.html

```
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title>Hello World!</title>
    <meta http-equiv="Content-Security-Policy" content="script-src 'self' 'unsafe-inline';" />
  </head>
  <body>
    <h1>Hello World! I am jianhao</h1>
  </body>
</html>

```
3. 添加主进程 main.js

```
const { app, BrowserWindow } = require('electron') // 从electron 中引入主模块和窗口模块

// 创建浏览器窗口
function createWindow () {   
  const win = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      nodeIntegration: true
    }
  })

  // 并且为你的应用加载index.html
  win.loadFile('index.html')
}

app.whenReady().then(createWindow)

```
4. 使用主进程作为入口，并用 electron 命令启动项目

```
// 在 package.json 中添加
"main": "main.js",
"scripts": {
    "start": "electron ." 
}

```
![electron app](http://pic.jianhunxia.com/imgs/electronFirstApp20200823220750.png)

然后你就会看到一个最简单的 electron 应用了，一切都很丝滑顺畅, 不是么<br/>
先去听听音乐然后睡觉，🎧 明天继续✨✨✨！
10:23 PM 


## 三、Electron + Umi3 搭建桌面应用
重头戏来了，我们将会搭建一个基础的 electron 应用，因为最近用 Umi 比较多，所以直接 Umi 配合 electron 构建，也可以使用其他脚手架搭建，比如 [electron-vue](https://simulatedgreg.gitbooks.io/electron-vue/content/cn/)

首先我们参考 [Umi 文档](https://umijs.org/zh-CN/docs)、[Umi3 搭建项目](https://juejin.im/post/6854573221782487047) 来搭建一个项目，
[参考demo](https://github.com/jianhao/umi-mobile)，大致目录如下：

    ├── dist/                           // 默认的 build 输出目录
    ├── mock/                           // mock 文件所在目录
    └── config/
        ├── config.js                   // umi 配置，同 .umirc.js，二选一
        ├── routers.js                  // 路由配置
    └── src/
        ├── layouts/index.js            // 全局布局
        ├── assets                      // 静态资源
        ├── components                  // 公共组件
        ├── models                      // 全局 models
        ├── services                    // services
        ├── styles                      // 样式文件
        ├── utils                       // 工具文件
        └── pages/                      // 页面目录
        ├── global.less                 // 自动引入的全局样式
        ├── app.js                      // 运行时配置文件
    ├── .umirc.js                       // umi 配置，同 config/config.js，二选一
    ├── .editorconfig                   // 维护代码风格的配置文件
    ├── .eslintignore                   // eslint 忽略文件
    ├── .eslintrc.js                    // eslint 配置文件
    ├── .gitignore                      // git 要忽略的文件
    ├── .prettierignore                 // Prettier 要忽略的文件
    ├── .prettierrc.js                  // Prettier 代码格式化配置文件 
    ├── .stylelintrc.js                 // css 代码审查的配置文件
    ├── jsconfig.jso                    // js 配置文件
    ├── package.json                    // npm 依赖记录文件
    └── yarn.lock                       // yarn 版本锁定文件

接下来我们将其改造成 electron 项目。<br/>

### 1、改造项目结构
src目录下新建 render 和 main 目录，然后将原来 src 文件夹中的文件和目录全部移动到 render 目录中，再将 config 目录和 .umirc 文件也放进去，方便管理。

需要修改下下项目根目录，不然项目无法启动：

```
yarn add cross-env   // 跨平台设置和使用环境变量的脚本包
"start": "cross-env APP_ROOT=src/render umi dev" // 修改 start 命令, 将 app 根目录改为 src/render
```

### 2、electron 本地启动
首先安装需要用到的依赖

```
yarn add concurrently  // 并发运行多个命令的包
yarn add wait-on  // 等待文件、端口、资源可用再执行命令的包
yarn add wait-on // electron 本尊
```
然后修改 start 命令，等待本地服务起来再通过 electron 启动应用

```
"start": "concurrently \"npm run start:web\" \"wait-on http://localhost:9527 && electron .\"",
"start:web": "cross-env NODE_ENV=development APP_ROOT=src/render PORT=9527 umi dev",
```
添加一个主进程文件 src/main/main.js, 内容如下：

```
// eslint-disable-next-line import/no-extraneous-dependencies
const { app, BrowserWindow} = require('electron')
const isDev = process.env.NODE_ENV === 'development'

function createWindow () {
  let mainWindow = new BrowserWindow({ // 实例化一个窗口
    width: 1200,
    height: 900,
    webPreferences: {
      contextIsolation: false,
      nodeIntegration: true, // node 集成，可以使用 require 和 process 这样的node APIs 去访问低层系统资源
    }
  })
  process.env.ELECTRON_DISABLE_SECURITY_WARNINGS = 'true' // 禁用控制台

  if (!isDev) {
    mainWindow.loadURL('http://localhost:9527/')
    mainWindow.webContents.openDevTools()
  }
  mainWindow.on('closed', () => {
    mainWindow = null
  })
}
app.on('ready', createWindow) // 应用初始化后打开窗口
app.on('quit', () => { })

```
在 package.json 中将主进程文件配置为项目入口

```
"main": "./src/main/main.js",
```
然后启动项目

```
yarn start
```
哇哦，umi + electron 本地开发结合成功了！值得吃几块 🍉🍉🍉

### 3、electron 打包编译
开发好了我们的小工具，这时候就要打包给其他同学使用了。目前流行的打包方案有 [electron-forge](https://github.com/electron-userland/electron-forge)、[electron-packager](https://github.com/electron/electron-packager)、[electron-builder](https://github.com/electron-userland/electron-builder)。

本来我用的 electron-forge 搭建了一个项目，目前是v6版本很不稳定，后来我再次搭建死活整不出来，遂弃坑。目前推荐 electron-builder，star 9.5k，社区比较活跃，我用了下感觉还是非常丝滑的。

开整！！！

安装 electron-builder 到开发依赖

```
yarn add electron-builder
```

package.json 中添加项目信息、打包命令、打包配置

```
  "name": "thresh",
  "private": true,
  "version": "0.1.0",
  "productName": "Thresh",
  "description": "结合 umi3 + electron + node 构建桌面应用的一个demo",
  "scripts": {
    "build": "electron-builder build -m", // -m mac -w windows -l linux
  },
  "build": {
    "productName": "electron-demos",
    "files": [
      "src/main/",  // 主进程文件
    ],
    "dmg": {
      "contents": [
        {
          "x": 110,
          "y": 150
        },
        {
          "x": 240,
          "y": 150,
          "type": "link",
          "path": "/Applications"
        }
      ]
    },
    "win": {
      "target": [
        {
          "target": "nsis",
          "arch": [
            "x64"
          ]
        }
      ]
    },
    "directories": {
      "output": "release" // 打包文件输出目录
    }
  },
```
主进程文件添加配置

```
// eslint-disable-next-line import/no-extraneous-dependencies
const { app, BrowserWindow} = require('electron')
+ const path = require('path')
+ const url = require('url')

const isDev = process.env.NODE_ENV === 'development'

function createWindow () {
  let mainWindow = new BrowserWindow({ // 实例化一个窗口
    width: 1200,
    height: 900,
    webPreferences: {
      contextIsolation: false,
      nodeIntegration: true, // node 集成，可以使用 require 和 process 这样的node APIs 去访问低层系统资源
    }
  })
  process.env.ELECTRON_DISABLE_SECURITY_WARNINGS = 'true' // 禁用控制台

  if (isDev) {
    mainWindow.loadURL('http://localhost:9527/')
    mainWindow.webContents.openDevTools()
  } else{
+    mainWindow.loadURL(
+      url.format({
+        pathname: path.join(__dirname, './index.html'), // 要渲染的静态页面
+        protocol: 'file:',
+        slashes: true,
+      }),
+    )
+    mainWindow.webContents.openDevTools()
  }
  mainWindow.on('closed', () => {
    mainWindow = null
  })
}
app.on('ready', createWindow) // 应用初始化后打开窗口
app.on('quit', () => { })
```
然后添加一个静态页面 src/main/index.html, 内容如下：

```
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1, maximum-scale=1, minimum-scale=1, user-scalable=no"
    />
    <script>
      window.routerBase = "/";
    </script>
    <script>
      //! umi version: 3.2.10
    </script>
  </head>
  <body>
    <div id="root" style="margin: 100px auto;color: skyblue;font-size: 40px;text-align: center;">
      我是一个没有感情的静态页面
    </div>
  </body>
</html>
```
项目打包

```
yarn build
```
然后根目录 release/mac/ 中就是打包好的项目，双击打开即可
![打包 demo](http://pic.jianhunxia.com/imgs/electron-builder-demo20200901165840.png)

这里说明 electron-builder 打包编译 electron 是没有问题的，接下来我们要将 umi 编译的资源也打包进去并渲染出来。

### 4、启动 node 服务访问资源
首先我们要知道，umi3 编译出来的都是单页面应用的资源，不能通过浏览器直接访问路由页面，所以我们要通过 nginx 或者 node 来访问该资源。

修改 umi3 配置，我这里用的是 config.js 
```
  outputPath: '../dist',
  <!--针对 electron 编译，参考：https://webpack.js.org/configuration/target/#string -->
  chainWebpack: (config) => { config.target('electron-renderer') },  
```
添加 src/server/index.js , 内容如下：

```
const compression = require('compression') // gzip压缩的中间件，尽可能先加载这个
const express = require('express')
const http = require('http')
const history = require('connect-history-api-fallback') // 当路由模式为history的时候，后端会直接请求地址栏中的文件，这样就会出现找不到的情况，需要这个中间件处理路由
const { createProxyMiddleware } = require('http-proxy-middleware') // 代理本地请求，实现跨域
const path = require('path')

const port = 3009
const app = express()
const httpServer = http.createServer(app)
const proxyTable = { // 代理到不同服务器不同端口的请求
  'api-1': 'https://XXX.com/api',
  'api-2': 'https://XXX.net/api',
}

const creatServer = () => {
  app.use(compression()) // 服务器端gzip文件压缩

  // 去设置不同的代理
  Object.keys(proxyTable).map((key) => {
    const pathRewrite = {}
    pathRewrite[`^/${key}`] = ''
    app.use(`/${key}`, createProxyMiddleware({ // proxy反向代理
      target: proxyTable[key],
      changeOrigin: true,
      pathRewrite
    }))
  })
  // 处理单页面 history 路由，当请求满足以下条件的时候，该库会把请求地址转到默认（默认情况为index.html）
  app.use(history({ 
    index: './index.html'
  }))
  // express.static: 内置中间件函数,指定资产的目录
  app.use(express.static(path.join(__dirname, '../dist'))) 
  // 监听启动的服务
  httpServer.listen(port, (err) => {
    if (err) {
      console.log(err)
      return
    }
    console.log(`%c your server is running at http://localhost:${port}\n`, 'color: skyblue')
  })
}

module.exports = { creatServer }
```
上面已经加了注释，主要作用就是基于express 启动一个 node 服务，用来代理接口和访问静态资源，然后我们去主进程中去启动该服务。

```js
<!--src/main/main.js-->
const { creatServer } = require('../server/index')
if (isDev) {
    mainWindow.loadURL('http://localhost:9527/')
    mainWindow.webContents.openDevTools()
} else {
    creatServer()
    mainWindow.loadURL('http://localhost:3009/')
    mainWindow.webContents.openDevTools()
}
```

然后安装下用到的依赖

```
yarn add compression express connect-history-api-fallback http-proxy-middleware
```
最后去修改下 package.json 的配置和启动命令

```
<!--打包命令-->
"scripts": {
    "build": "npm run build:web && electron-builder build -m",
    "build:web": "cross-env NODE_ENV=production APP_ROOT=src/render umi build",
}
<!--要打包的资源，一定不要忘记添加！！！-->
"build": {
    "productName": "Thresh",
    "files": [
      "src/dist/",
      "src/main/",
      "src/render/",
      "src/server/"
    ],
    ...
}
```
至此，基本配置已经完善，我们来打包编译下我们的应用
```
yarn build
```
打包成功后打开我们的应用！
![image](http://pic.jianhunxia.com/imgs/electron-builder-demo220200902095617.png)

终于搞完了！！！我边搭建边写这篇教程，中间数次卡住，事实证明，这样搞完全没有问题。

得到的经验就是如果被某个问题困扰许久，不如停下来打打游戏，喝杯啤酒，好好睡一觉，问题会在第二天清晨迎刃而解 ✨✨✨    




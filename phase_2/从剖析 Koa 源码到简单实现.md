# 一、什么是 Koa

Koa 是一个基于 node 实现的 http 中间件框架，它是由 express 框架的原班人马打造的。

那为啥 Koa 更受欢迎（至少我更喜欢 Koa），相比 express 它更加优雅、简洁，而且表达力强、自由度高。

# 二、Koa 体验

## node 实现基础 http 服务器
  ```javascript
    const http = require('http');
    
    const server = http.createServer((req, res) => {
      // 当我们需要对 req 进行处理时就需要在这边做很多处理，且无法实现模块化
      res.writeHead(200);
      res.end('hi jinguo');
    });
    
    server.listen(3000, () => {
      console.log('监听端口3000');
    });
  ```
## koa 实现基础 http 服务器
  ```javascript
    const koa = require('koa');
    cosnt app = new koa();
    
    // 模块化/简化
    app.use(ctx => {
      ctx.body = 'hi jinguo';
    })
    
    app.listen(3000);
  ```
> koa 的目标是用更简单化、流程化、模块化的方式实现回调部分
  ```javascript
    app.use(async (ctx, next) => {
      ctx.state = 'hi jinguo';
      await next();
    });
    
    app.use(ctx => {
      ctx.body = ctx.state;
    });
  ```
# 三、Koa 源码剖析

## 源码目录结构
  ```
    lib
    ├── application.js // koa 入口文件
    ├── context.js // koa 的应用上下文 ctx
    ├── request.js // 封装了处理 http 请求
    └── response.js // 封装了处理 http 响应
  ```
### application.js
  ```javascript
    // 继承了events，这样就会赋予事件监听和事件触发的能力
    module.exports = class Application extends Emitter {
      constructor(options) {
        super();
        this.middleware = []; // 该数组存放所有通过use函数的引入的中间件函数
        // 创建对应的context、request、response。
        this.context = Object.create(context);
        this.request = Object.create(request);
        this.response = Object.create(response);
      }
    
      // 对 http.createServer 进行了一个封装
      listen(...args) {
        debug('listen');
        // 重点是这个函数中传入的 callback，包含了中间件的合并，上下文的处理，对res的特殊处理。
        const server = http.createServer(this.callback());
        return server.listen(...args);
      }
    
      // use 是注册中间件，将多个中间件放入一个缓存队列中
      use(fn) {
        this.middleware.push(fn);
        return this;
      }
    	
      // 返回一个类似 (req, res) => {} 的函数
      callback() {
        // 将所有传入 use 的中间件函数通过 koa-compose 组合一下,compose 在下文自己实现 koa 时会有讲解
        const fn = compose(this.middleware);
    
        if (!this.listenerCount('error')) this.on('error', this.onerror);

        const handleRequest = (req, res) => {
          // 根据 req 和 res 封装中间件所需要的 ctx。
          const ctx = this.createContext(req, res);
          return this.handleRequest(ctx, fn);
        };
    
        return handleRequest;
      }
    
      // 封装出强大的 ctx
      createContext(req, res) {
        // 创建了3个简单的对象，并且将他们的原型指定为我们 app 中对应的对象。然后将原生的req 和 res 赋值给相应的属性
        const context = Object.create(this.context);
        const request = context.request = Object.create(this.request);
        const response = context.response = Object.create(this.response);
        context.app = request.app = response.app = this;
        context.req = request.req = response.req = req;
        context.res = request.res = response.res = res;
        request.ctx = response.ctx = context;
        request.response = response;
        response.request = request;
        return context;
      }
    
      handleRequest(ctx, fnMiddleware) {
        const res = ctx.res;
        res.statusCode = 404;
    
        // 调用 context.js 的 onerror 函数
        const onerror = err => ctx.onerror(err);
    
        // 处理响应内容
        const handleResponse = () => respond(ctx);
    
        // 确保一个流在关闭、完成和报错时都会执行响应的回调函数
        onFinished(res, onerror);
    
        // 中间件执行、统一错误处理机制的关键
        return fnMiddleware(ctx).then(handleResponse).catch(onerror);
      }
    }
  ```
> application.js 主要做了以下 4 件事

  1. 启动框架
  2. 实现洋葱模型中间件机制
  3. 封装高内聚的 context
  4. 实现异步函数的统一错误处理机制

## context.js
  ```javascript
    const proto = module.exports = {
      onerror(err) {
        // 触发 application 实例的 error 事件
        this.app.emit('error', err, this);
      }
    }
    
    // 下面 2 个 delegate 的作用是让 context 对象代理 request 和 response 的部分属性和方法
    delegate(proto, 'response')
      .method('attachment')
      .method('redirect')
      .method('remove')
      ...
    
    delegate(proto, 'request')
      .method('acceptsLanguages')
      .method('acceptsEncodings')
      .method('acceptsCharsets')
      ...
  ```
> context.js 主要做了以下 2 件事

  1. 错误事件处理
  2. 代理 response 对象和 request 对象的部分属性和方法

## request.js
  ```javascript
    module.exports = {
      // request 对象会基于 req 封装很多便利的属性和方法
      get header() {
        return this.req.headers;
      },
    
      set header(val) {
        this.req.headers = val;
      },
    
      get url() {
        return this.req.url;
      },
    
      set url(val) {
        this.req.url = val;
      },
      // 省略了大量类似的工具属性和方法
      ...
    };
  ```
> 访问 ctx.request.xxx 时，实际是在访问 request 对象上的 setter 和 getter

## response.js
  ```javascript
    module.exports = {
      get header() {
        const { res } = this;
        return typeof res.getHeaders === 'function'
          ? res.getHeaders()
          : res._headers || {}; // Node < 7.7
      },
      get body() {
        return this._body;
      },
    
      set body(val) {
        this._body = val;
      },
      // 省略了大量类似的工具属性和方法
      ...
    }
  ```
> response 对象与 request 对象类似

# 四、简单实现 Koa
  ```javascript
    // JKoa.js
    const http = require("http");
    const request = require("./request");
    const response = require("./response");
    
    class JKoa {
      constructor() {
        this.middlewares = [];
      }
    	
      listen(...args) {
        const server = http.createServer(async (req, res) => {
          // 创建上下文对象
          const ctx = this.createContext(req, res);
          // 将 middlewares 组合,compose 函数在下面实现
          const fn = this.compose(this.middlewares);
          await fn(ctx)
          // 给用户返回数据
          res.end(ctx.body);
        });
        server.listen(...args);
      }
      
      use(middlewares) {
        this.middlewares.push(middlewares);
      }
    
      createContext(req, res) {
        const ctx = Object.create(context);
        ctx.request = Object.create(request);
        ctx.response = Object.create(response);
        ctx.req = ctx.request.req = req;
        ctx.res = ctx.response.res = res;
      }
    }
    
    module.exports = JKoa;
  ```
## context

koa 为了能够简化 API， 引入上下文 context 概念，将原始请求对象 req 和 相应对象 res 封装并挂载到 context 上，并且在 context 上设置 getter 和 setter，从而简化操作。
  ```javascript
    // context.js
    module.exports = {
      get url() {
        retrun this.request.url;
      },
      get body() {
        return this.response.body;
      },
      set body(val) {
        this.response.body = val;
      }
    }
    
    // request.js
    module.exports = {
      get url() {
        return this.req.url;
      }
    }
    
    // response.js
    module.exports = {
      get body() {
        return this._body;
      },
      set body(val) {
        this._body = val;
      }
    }
  ```
## 中间件

> 我们先通过下面的例子了解一下函数组合的概念
  ```javascript
    function add(x, y) {
      return x + y;
    }
    
    function square(z) {
      return z * z
    }
    
    // 普通方式
    const result = square(add(1, 2));
    
    // 函数组合方式
    function compose(middlewares) {
      return middlewares.reduce((prev, next) => (...args) => next(prev(...args)));
    }
    
    const middlewares = [add, square];
    const resultFn = compose(middlewares);
    const result = resultFn(1, 2);
  ```
> 上面的例子组合函数是同步的，挨个遍历执行就可以，如果是异步的函数，我们要支持 async + await 的中间件
  ```javascript
    function compose(middlewares) {
      return function(ctx) {
        // 执行第 0 个
        return dispatch(0);
        function dispatch(i) {
          let fn = middlewares[i];
          if (!fn) {
            return Promise.resolve();
          }
          return Promise.resolve(
            fn(ctx, function next() {
              // promise 完成后再执行下一个
              return dispatch(i + 1);
            })
          );
        }
      }
    }
  ```
> Koa 中间件机制就是函数组合的概念，将一组需要顺序执行的函数复合为一个函数，外层函数的参数实际是内层函数的返回值。洋葱圈模型可以形象表示这种机制，是 Koa 源码中的精髓和难点。

# 五、总结

Koa 就是基于 node 原生 req 和 res 为 request 和 response 对象赋能，并基于它们封装成一个 context 对象，还有一点很重要的就是基于 async/await 的中间件洋葱模型机制。

希望看完我的文章对你们有所收获，感谢阅读我的文章！
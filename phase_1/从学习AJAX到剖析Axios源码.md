AJAX 可以说是一个非常熟悉非常基础的词，如果有人问你懂不懂 AJAX，相信你必定胸有成竹。

行吧，希望你能多骄傲一会，咱先简单介绍一下 AJAX。

AJAX 的全称是 Asynchronous JavaScript and XML，概括的说就是用 JavaScript 执行异步网络请求。

我们知道 web 运作原理是一次 HTTP 请求对应一个页面，那么问题来了，AJAX 是怎么做到一次HTTP 请求还留在了当前页面。

![](http://img.janggwa.cn/sikaoyixia.jpg)

其实 AJAX 就是用 JavaScript 去发送这个请求，接收到数据后再用 JavaScript 去更新页面，所以AJAX 能够做到 HTTP 请求还停留在当前页面。

简单介绍完 AJAX 我们用 JavaScript 实现一下 ，但需要注意 AJAX 请求是异步执行的。
```javascript
  function success(text) {
    // 对于请求返回数据进行处理
  }
  
  function fail(code) {
    // 根据失败原因进行处理
  }
  
  const request = new XMLHttpRequest();
  request.onreadystatechange = function() {
    if (request.readyState === 4) { // 请求完成
      if (request.status === 200) { // 成功
        return success(request.responseText);
      } else {  // 失败
        return fail(request.status);
      }
    } else {
      // HTTP 请求中。。。
    }
  }
  
  // get请求
  request.open('GET', '/api/xxx?name=jinguo&age=18');
  request.send();
  
  // post请求
  request.open('POST', '/api/xxx');
  request.setRequestHeader('content-type', 'application/x-www-form-urlencoded');
  request.send('name=jinguo&age=18');
```
简单了解完 AJAX，也简单实现了以后，你是否还一如既往的胸有成竹。

如果是的，别急，请你告诉我 GET 请求和 POST 请求的区别是什么？

![](http://img.janggwa.cn/zhetitaijiandanle.jpg)

- GET 在浏览器回退时是无害的，而 POST 会再次提交请求。
- GET 产生的 URL 地址可以被 Bookmark，而 POST 不可以。
- GET 请求会被浏览器主动 cache，而 POST 不会，除非手动设置。
- GET 请求只能进行 url 编码，而 POST 支持多种编码方式。
- GET 请求参数会被完整保留在浏览器历史记录里，而 POST 中的参数不会被保留。
- GET 请求在 URL 中传送的参数是有长度限制的，而 POST 没有。
- 对参数的数据类型，GET 只接受 ASCII 字符，而 POST 没有限制。
- GET 比 POST 更不安全，因为参数直接暴露在 URL 上，所以不能用来传递敏感信息。
- GET 参数通过 URL 传递，POST 放在 Request body 中。

（本标准答案参考自w3schools）

很遗憾，如果你告诉我这些，那可能你还理解的不够透彻。其实这两个请求方式本质上并没有什么区别，它们底层都是 TCP/IP，也就是说你也可以给 GET 请求去添加上 request body，也可以给 POST 请求带上 url 参数。

那么真正的区别是什么呢?

GET 请求产生一个 TCP 数据包，而 POST 请求会产生两个TCP数据包。换句话说就是 GET 请求会把header 和 data 一并发送出去，服务器响应200；POST 请求会先发送 header，服务器响应100，浏览器再发送 data，服务器响应200

还有一点就是 GET 请求虽然可以携带 request body，但是有些服务器可能会直接忽略 request body 的内容。

说到这里，如果你还是一如既往的胸有成竹，那只能说在下佩服。

![](http://img.janggwa.cn/zaixiapeifu.jpg)
================================================================================================
好了，简单学习了 AJAX 后，我们正经剖析一下项目中经常用到的 Axios 源码。
![](http://img.janggwa.cn/zhengjing.gif)
先看一下 Axios 源码目录结构
```
  lib
  ├── adapters // 请求的适配器
      ├── http.js // node端http适配器
      ├── xhr.js // 浏览器端xhr适配器
  ├── cancel // 定义了取消请求的一些方法
  ├── core // 核心文件
      ├── Axios.js // Axios类
      ├── buildFullPath.js // 将baseURL与请求的URL组合创建新的URL
      ├── createError.js // 生成指定的error
      ├── dispatchRequest.js // 用于发起请求
      ├── enhanceError.js // 指定error对象的toJSON方法
      ├── InterceptorManager.js // 拦截器类
      ├── mergeConfig.js // 合并配置项
      ├── settle.js // 根据请求方式处理promise
      ├── transformData.js // 对请求或相应数据进行格式化
  ├── helpers // 一些辅助功能
  ├── axios.js // 对外暴露的axios
  ├── defaults.js // axios默认配置
  └── utils // 一些工具方法
```
我们直接干到 Axios 项目的入口文件 ，先省略一些 axios 的其它方法
```javascript
  // lib/axios.js
  function createInstance(defaultConfig) {
    // 创建一个 Axios 实例
    var context = new Axios(defaultConfig);
  
    // 这边就是执行一个 bind 函数，改变 this 指向。
    // 也就是说我们调用 instance(url, option) 时，就是调用了 Axios.prototype.reques 方法，this 指向是 context。
    var instance = bind(Axios.prototype.request, context);
  
    // 这边就是把 Axios.prototype 的属性拷贝到 instance,如果这些属性值是方法的话，会进行 bind 操作，this 指向是 context。
    // 也就是说 instance 上就有了 get、post等方法。
    utils.extend(instance, Axios.prototype, context);
  
    // 这边就是把 context 的属性拷贝到 instance。
    // 也就是说 instance 上有了 defaults 和 interceptors 属性。
    utils.extend(instance, context);
  
    return instance;
  }
  
  // 传入默认配置参数，生成一个 Axios 实例
  var axios = createInstance(defaults);
  
  // 导出 Axios 实例对象
  module.exports = axios;
```
可以看到这个文件非常简单，只是去创建了 Axios 实例，然后进行导出。

创建 Axios 实例的时候多次出现了 Axios.prototype,这里面究竟干了啥，咱去 core 文件夹下的 Axios.js 看看。
```javascript
  // lib/core/Axios.js
  function Axios(instanceConfig) {
    // Axios 配置
    this.defaults = instanceConfig;
    this.interceptors = {
      request: new InterceptorManager(), // 请求拦截器
      response: new InterceptorManager() // 响应拦截器
    };
  }
  
  // 核心请求方法，拎出去单独分析，先折叠起来
  Axios.prototype.request = function request(config) {...
  };
  
  // 不发送请求的前提下根据传入的配置返回一个 url
  Axios.prototype.getUri = function getUri(config) {
    config = mergeConfig(this.defaults, config);
    return buildURL(config.url, config.params, config.paramsSerializer).replace(/^\?/, '');
  };
  
  // 在 Axios.prototype 上添加各种请求方法
  utils.forEach(['delete', 'get', 'head', 'options'], function forEachMethodNoData(method) {
    Axios.prototype[method] = function(url, config) {
      return this.request(utils.merge(config || {}, {
        method: method,
        url: url
      }));
    };
  });
  
  utils.forEach(['post', 'put', 'patch'], function forEachMethodWithData(method) {
    Axios.prototype[method] = function(url, data, config) {
      return this.request(utils.merge(config || {}, {
        method: method,
        url: url,
        data: data
      }));
    };
  });
  
  module.exports = Axios;
```
这边了解完 Axios.prototype 上有哪些方法后，可以发现核心是调用到了 Axios.prototype.request 方法。
```javascript
  // lib/core/Axios.js
  Axios.prototype.request = function request(config) {
    // 如果 config 是字符串，把config作为 url，第二个参数作为 config
    // 场景就是 axios(url, options)
    if (typeof config === 'string') {
      config = arguments[1] || {};
      config.url = arguments[0];
    } else {
      config = config || {};
    }
  
    // 合并配置
    config = mergeConfig(this.defaults, config);
  
    // 指定了请求方式，就把 config.method 设为指定的请求方式，否则为 get
    if (config.method) {
      config.method = config.method.toLowerCase();
    } else if (this.defaults.method) {
      config.method = this.defaults.method.toLowerCase();
    } else {
      config.method = 'get';
    }
  
    // 初始化 chain 数组，添加 undefined 是为了对应上 Promise 的 onFulfilledFn 和 onRejectedFn。
    var chain = [dispatchRequest, undefined];
  
    // promise 是一个已经 resolve 的 Promise 对象
    var promise = Promise.resolve(config);
  
    // 遍历所有的请求拦截器，添加到 chain 数组最前面
    // 这边用的 unshift 添加，所以会导致先添加的后执行
    this.interceptors.request.forEach(function unshiftRequestInterceptors(interceptor) {
      chain.unshift(interceptor.fulfilled, interceptor.rejected);
    });
  
    // 遍历所有的响应拦截器，添加到 chain 数组最前面
    // 这边用的 push 添加，所以会导致先添加的先执行
    this.interceptors.response.forEach(function pushResponseInterceptors(interceptor) {
      chain.push(interceptor.fulfilled, interceptor.rejected);
    });
  
    // 循环 chain 数组，先循环执行请求拦截器方法，然后执行 dispatchRequest,最后循环执行响应拦截器方法
    while (chain.length) {
      promise = promise.then(chain.shift(), chain.shift());
    }
  
    return promise;
  };
```
我们发现 Axios.prototype.request 很巧妙的用到了请求拦截器和响应拦截器，我们去看看拦截器类干了什么
```javascript
  // lib/core/InterceptorManager.js
  function InterceptorManager() {
    this.handlers = [];
  }
  
  // 添加拦截器方法
  InterceptorManager.prototype.use = function use(fulfilled, rejected) {
    this.handlers.push({
      fulfilled: fulfilled,
      rejected: rejected
    });
    return this.handlers.length - 1;
  };
  
  // 注销指定的拦截器
  InterceptorManager.prototype.eject = function eject(id) {
    if (this.handlers[id]) {
      this.handlers[id] = null;
    }
  };
  
  // 遍历 handlers，并将 handlers 里的每一项作为参数传给fn执行
  InterceptorManager.prototype.forEach = function forEach(fn) {
    utils.forEach(this.handlers, function forEachHandler(h) {
      if (h !== null) {
        fn(h);
      }
    });
  };
  
  module.exports = InterceptorManager;
```
拦截器类就是在其原型上添加了一些方法去处理拦截器，那如果我们没有设置拦截器的话，可以看到执行的直接就是 dispatchRequest，这里也就是实际调用请求的地方。
```javascript
  // lib/core/dispatchRequest.js
  module.exports = function dispatchRequest(config) {
    // 判断请求是否被取消
    throwIfCancellationRequested(config);
  
    // 确保 headers 存在
    config.headers = config.headers || {};
  
    // 对 data 进行数据格式化
    // 比如对 Object 序列化，并添加 'application/json;charset=utf-8'到 Content-Type 等等
    // 具体可以看 defaults 的 transformRequest
    config.data = transformData(
      config.data,
      config.headers,
      config.transformRequest
    );
  
    // 合并不同配置的 headers
    config.headers = utils.merge(
      config.headers.common || {},
      config.headers[config.method] || {},
      config.headers || {}
    );
  
    // 删除 headers 中的无用属性
    utils.forEach(
      ['delete', 'get', 'head', 'post', 'put', 'patch', 'common'],
      function cleanHeaderConfig(method) {
        delete config.headers[method];
      }
    );
  
    // 使用传入的适配器，否则用默认的 xhr 或 http 适配器
    var adapter = config.adapter || defaults.adapter;
  
    // 使用相应的适配器发起请求
    return adapter(config).then(function onAdapterResolution(response) {...
    }, function onAdapterRejection(reason) {...
    });
  };
```
dispatchRequest 文件中可以看到最后调用了 adapter 方法，这边的 adapter 我们就看浏览器端的 xhr 适配器
```javascript
  // lib/adapters/xhr.js
  module.exports = function xhrAdapter(config) {
    // 返回一个 Prmise 对象
    return new Promise(function dispatchXhrRequest(resolve, reject) {
      var requestData = config.data;
      var requestHeaders = config.headers;
  
      // 如果是 FormData 对象，删除 header 的 Content-type,让浏览器自动添加
      if (utils.isFormData(requestData)) {
        delete requestHeaders['Content-Type'];
      }
  
      // 创建 xhr 对象
      var request = new XMLHttpRequest();
  
      // 设置请求头中的 Authorization 字段
      if (config.auth) {
        var username = config.auth.username || '';
        var password = config.auth.password || '';
        requestHeaders.Authorization = 'Basic ' + btoa(username + ':' + password);
      }
  
      // 初始化请求
      var fullPath = buildFullPath(config.baseURL, config.url);
      request.open(config.method.toUpperCase(), buildURL(fullPath, config.params, config.paramsSerializer), true);
  
      // 设置过期时间
      request.timeout = config.timeout;
  
      // 监听 readystate 状态变更
      request.onreadystatechange = function handleLoad() {
        // 请求没有成功
        if (!request || request.readyState !== 4) {
          return;
        }
  
        // 因为 file 协议的 status 为0也是成功，所以要增加判断
        if (request.status === 0 && !(request.responseURL && request.responseURL.indexOf('file:') === 0)) {
          return;
        }
  
        // getAllResponseHeaders 方法会返回所有的响应头
        var responseHeaders = 'getAllResponseHeaders' in request ? parseHeaders(request.getAllResponseHeaders()) : null;
        var responseData = !config.responseType || config.responseType === 'text' ? request.responseText : request.response;
        var response = {
          data: responseData,
          status: request.status,
          statusText: request.statusText,
          headers: responseHeaders,
          config: config,
          request: request
        };
  
        // 根据状态值校验 status >= 200 && status < 300
        settle(resolve, reject, response);
  
        // 清除请求
        request = null;
      };
  
      // 请求中断时触发
      request.onabort = function handleAbort() {
        if (!request) {
          return;
        }
        reject(createError('Request aborted', config, 'ECONNABORTED', request));
        request = null;
      };
  
      // 请求失败时触发
      request.onerror = function handleError() {
        reject(createError('Network Error', config, null, request));
        request = null;
      };
  
      // 请求超时时触发
      request.ontimeout = function handleTimeout() {
        var timeoutErrorMessage = 'timeout of ' + config.timeout + 'ms exceeded';
        if (config.timeoutErrorMessage) {
          timeoutErrorMessage = config.timeoutErrorMessage;
        }
        reject(createError(timeoutErrorMessage, config, 'ECONNABORTED',
          request));
        request = null;
      };
  
      // 添加 XSRF-Token 到请求头中，用来防御 CSRF 攻击
      // 具体原理就是服务端生成一个 XSRF-TOKEN，并保存到浏览器的 cookie 中，在每次请求中将其设置到 request header 中
      // 服务器会比较 cookie 中的 XSRF-TOKEN 与 header 中 XSRF-TOKEN 是否一致
      // 根据同源策略，非同源的网站无法读取修改本源的网站cookie，避免了伪造cookie
      if (utils.isStandardBrowserEnv()) {
        var cookies = require('./../helpers/cookies');
  
        var xsrfValue = (config.withCredentials || isURLSameOrigin(fullPath)) && config.xsrfCookieName ?
          cookies.read(config.xsrfCookieName) :
          undefined;
        
        if (xsrfValue) {
          requestHeaders[config.xsrfHeaderName] = xsrfValue;
        }
      }
  
      // 将 config 中配置的 requestHeaders，循环设置到请求头上
      if ('setRequestHeader' in request) {
        utils.forEach(requestHeaders, function setRequestHeader(val, key) {
          if (typeof requestData === 'undefined' && key.toLowerCase() === 'content-type') {
            delete requestHeaders[key];
          } else {
            request.setRequestHeader(key, val);
          }
        });
      }
  
      // 设置 withCredentials 属性，是否允许 cookie 进行跨域请求
      if (config.withCredentials) {
        request.withCredentials = true;
      }
  
      // 设置 responseType 属性
      if (config.responseType) {
        try {
          request.responseType = config.responseType;
        } catch (e) {
          if (config.responseType !== 'json') {
            throw e;
          }
        }
      }
  
      // 下载进度
      if (typeof config.onDownloadProgress === 'function') {
        request.addEventListener('progress', config.onDownloadProgress);
      }
  
      // 上传进度
      if (typeof config.onUploadProgress === 'function' && request.upload) {
        request.upload.addEventListener('progress', config.onUploadProgress);
      }
  
      // 取消发送请求
      if (config.cancelToken) {
        config.cancelToken.promise.then(function onCanceled(cancel) {
          if (!request) {
            return;
          }
          request.abort();
          reject(cancel);
          request = null;
        });
      }
  
      if (requestData === undefined) {
        requestData = null;
      }
  
      // 发送请求
      request.send(requestData);
    });
  };
```
看完适配器后，整个 axios 发起请求的流程，相信你心中应该已经有了整体了解。最后，我们再看看取消发起请求
```javascript
  // lib/cancel/CancelToken.js
  function CancelToken(executor) {
    if (typeof executor !== 'function') {
      throw new TypeError('executor must be a function.');
    }
  
    var resolvePromise;
    // 创建一个 Promise，调用 cancel 函数之前一直处于 pending 状态
    this.promise = new Promise(function promiseExecutor(resolve) {
      resolvePromise = resolve;
    });
  
    var token = this;
    executor(function cancel(message) {
      if (token.reason) {
        return;
      }
      
      // 创建取消请求的信息
      token.reason = new Cancel(message);
      resolvePromise(token.reason);
    });
  }
  
  // 判断请求是否已经被取消
  CancelToken.prototype.throwIfRequested = function throwIfRequested() {
    if (this.reason) {
      throw this.reason;
    }
  };
  
  CancelToken.source = function source() {
    var cancel;
    var token = new CancelToken(function executor(c) {
      cancel = c;
    });
    return {
      token: token,
      cancel: cancel
    };
  };
  
  module.exports = CancelToken;
```
当然这个取消发起请求需要配合上 adapter 的 request.abort 方法

到了这里，我们已经把 Axios 源码整体剖析了一遍，再简单梳理一下，当使用 axios 发起一个请求，我们其实调用了Axios.prototype.request 方法，这个方法的核心是调用了 dispatchRequest，而 dispatchRequest 的核心是调用了 adapter，浏览器端默认是 xhrAdapter，node端默认是 httpAdapter，执行完后会返回一个 Promise。

从 AJAX 学习到探索 Axios 源码的过程还是有非常多的乐趣和成长的，希望你们也有所收获，感谢阅读我的文章！

![](http://img.janggwa.cn/xiexie.gif)
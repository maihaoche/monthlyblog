## 前言

浅谈 webpck 之前，先思考一个问题，为什么需要构建工具？

假设如果没有构建工具会有什么影响？第一，线上的代码是可以直接被观赏的，也就相当于你没有穿衣服，直接暴露了身体器官，别人一看就知道你是 GG 还是 MM。第二，在编写当今社会比较流行的React 和 Vue 框架时，浏览器大哥并无法识别你编写的 jsx 和 一些指令。第三，当你在追求时髦的道路中编写 es 新特性及 css 预处理器时，一些低版本的浏览器大哥深居田园，悠然自得，并不支持你这些城市烟火。

根据自然发展，构建工具油然而生，它可以转换 ES6、JSX、CSS 预处理器，也可以压缩混淆，资源压缩等等。

## 简介

webpack 是一个用于 web 项目的模块打包工具。webpack 可以将前端各种资源统一打包为相应的资源文件。本文会简单描述 webpack 的基本概念，并对 webpack 的源码进行原理分析并简单实现一个简版 webpack。

## 基本概念

### Entry

Entry 用来指定 webpack 的打包入口，根据入口文件的依赖形成依赖树，打包成相应的文件。

Entry 用法一般有两种形式，单入口形式和多入口形式。

单入口形式 entry 是一个字符串，`entry:  './index.js'`。

多入口形式 entry 是一个对象，`entry: { app: './src/app.js', index: './src/index.js' }`。

### Output

Output 用来告诉 webpack 如何将编译后的文件输出到磁盘。

Output 用法可以根据 Entry 单入口形式和多入口形式进行不同配置。

单入口形式可以将 output 配置成写死的 filename，`output: { filename: 'boundle.js', path: __dirname + '/dist'}`。

多入口形式可以将 output 配置通过占位符确保文件名称唯一，`output: { filename: '[name].js', path: __dirname + '/dist'}`。

### Loaders

webpack 原生只支持 JS 和 JSON 两种文件类型，通过 Loaders 去支持其它文件类型并且把他们转化成有效的模块。

以下是常见的 Loaders

| 名称 | 描述 |
| ---- | ---- |
| babel-loader | 转换 ES6、ES7 等 JS 新特性语法 |
| css-loader | 支持 css 文件的加载和解析 |
| less-loader | 将 less 文件转换成 css |
| ts-loader | 将 TS 转换成 JS |
| file-loader | 进行图片、字体等的打包 |
| thread-loader | 多进程打包 JS 和 CSS |

Loaders 的用法，`module: { rules: [{test: /\.js$/, use: 'babel-loader'}]}`，test 指定匹配规则，use指定 loader 使用的名称

如果配置多个 loader 时，`module: { rules: [{test: /\.less/, use: ['style-loader', 'css-loader', 'less-loader']}]}`，loader 的执行顺序时从右往左，右边的执行结果作为参数传到左边。less-loader 把 less 转化成 css，传给 css-loader，css-loader 将 css 文件转换成 commonjs 对象传给 style-loader，style-loader 将样式通过<style>标签插入到 head 中。

### Plugins

插件用于 bundle 文件的优化，资源管理和环境变量注入，任何 loaders 无法处理的事情可以通过 plugins 完成，作用于整个构建过程。

以下是常见的 Plugins

| 名称 | 描述 |
| ---- | ---- |
| CommonsChunkPlugin | 将 chunks 相同的模块代码提取成公共 js |
| CleanWebpackPlugin | 清理构建目录 |
| CopyWebpackPlugin | 将文件或者文件夹拷贝到构建的输出目录 |
| HtmlWebpackPlugin | 创建 html 文件去承载输出的 bundle |
| UglifyjsWebpackPlugin | 压缩 JS |

Plugins 的用法，`plugins: [new HtmlWebpackPlugin({ template: './src/index.html' })]`。

### Mode

Mode 用来指定当前的构建环境是：production、development 还是 none。

设置 mode 可以使用 webpack 内置的函数，默认值为 production。

以下是 mode 内置函数
| 名称 | 描述 |
| ---- | ---- |
| development | 设置 process.env.NODE_ENV 的值为 development 开启 NamedChunksPlugin 和 NamedModulesPlugin |
| production | 设置 process.env.NODE_ENV 的值为 production
开启 FlagDependencyUsagePlugin，FlagIncludedChunksPlugin，ModuleConcatenationPlugin，
NoEmitOnErrorsPlugin，OccurrenceOrderPlugin，SideEffectsFlagPlugin，TeserPlugin |
| none | 不开启任何优化选项 |

## 原理分析

### Tapable

webpack 核心对象 Compiler 和 Compilation 都继承 Tapable，也就是说 webpack 的整个骨架是基于 Tapable 的。

Tapable 是一个类似于 Node.js 的 EventEmitter 的库，主要是控制勾子函数的发布与订阅，控制着 webpack 的插件系统。

用一个例子简单展示一下 Tapable 的使用
```javascript
  const { SyncHook } = require('tapable');
  
  const hook = new SyncHook(["arg1", "arg2", "arg3"]);
  // 绑定事件到 webpack 事件流
  hook.tap('hook', (arg1, arg2, arg3) => console.log(arg1, arg2, arg3)) // 1, 2, 3
  // 执行绑定的事件
  hook.call(1, 2, 3);
```
### 编译流程

1. 初始化 option，会通过 webpackOptionsApply.js 将所有配置转换成 webpack 内部插件
2. run，开始编译，生成 NormalModuleFactory 实例和 ContextModuleFactory 实例。
3. make，从 entry 开始递归分析依赖，对每个依赖模块进行 build
4. before-resolve 对模块位置进行解析
5. build-module 开始构建某个模块
6. normal-module-loader 将 loader 加载完成的 module 进行编译，生成 AST 树
7. program 遍历 AST，当遇到 require 等一些调用表达式时，收集依赖
8. seal 所有依赖 build 完成，开始优化
9. emit 输出到 dist 目录

## 简单实现

### 准备阶段

在入口文件初始化 Compiler 实例，传入配置文件的 options，执行 run，开始编译。
```javascript
  const Compiler = require('./compiler');
  const options = require('../simplepack.config');
  
  new Compiler(options).run();
```
### 模块构建

创建一个 parser.js，主要功能用于解析成 AST，将 es6 转换成 es5，然后再将 AST 转换成代码，还有一个功能就是分析依赖，获取依赖。
```javascript
  const fs = require('fs');
  const babylon = require('babylon');
  const traverse = require('babel-traverse').default;
  const { transformFromAst } = require('babel-core')
  
  module.exports = {
    // 获取 AST 树
    getAST: (path) => {
      const source = fs.readFileSync(path, 'utf-8');
      return babylon.parse(source, {
        sourceType: 'module'
      });
    },
    // 获取依赖
    getDependencieds: (ast) => {
      const dependencies = [];
      traverse(ast, {
        ImportDeclaration: ({ node }) => {
          dependencies.push(node.source.value);
        }
      })
      return dependencies;
    },
    // 通过 AST 转换成源码
    trasform: (ast) => {
      const { code } = transformFromAst(ast, null, {
        presets: ['env']
      })
      return code;
    }
  }
```
创建一个 compiler.js，增加 run 和 buildModule 方法
```javascript
  const path = require('path');
  const fs = require('fs');
  const { getAST, getDependencieds, trasform } = require('./parser');
  
  module.exports = class Compiler {
    constructor(options) {
      const { entry, output } = options;
      this.entry = entry;
      this.output = output;
      this.modules = [];
    }

    run() {
      // 获取 entry 编译模块
      const entryModule = this.buildModule(this.entry, true);
      this.modules.push(entryModule);
  
      // 遍历依赖的模块
      this.modules.map((_module) => {
        _module.dependencies.map((dependency) => {
          this.modules.push(this.buildModule(dependency));
        })
      })
    }
  
    // 编译模块获取源码和依赖
    buildModule(filename, isEntry) {
      let ast;
      // 如果是入口 entry 文件，传入的是全路径
      if (isEntry) {
        ast = getAST(filename);
      } else {
        // 拼接绝对路径
        const absolutePath = path.join(process.cwd(), './src', filename)
        ast = getAST(absolutePath);
      }
  
      return {
        filename,
        dependencies: getDependencieds(ast),
        source: trasform(ast)
      }
    }
  }
```
### 文件生成

最后我们在 compiler.js 增加 emitFiles 方法
```javascript
  // 生成文件
  emitFiles() {
    const outputPath = path.join(this.output.path, this.output.filename);
  
    let modules = '';
    // key、value 形式整装 modules
    this.modules.map((_module) => {
      modules += `'${ _module.filename}': function (require, module, exports) { ${ _module.source} },`
    })
  
    const bundle = `(function(modules){
      function require(filename) {
        var fn = modules[filename];
        var module = { exports: {}};
        fn(require, module, module.exports);
  
        return module.exports;
      }
  
      require('${ this.entry }');
    })({${ modules }})`;
    fs.writeFileSync(outputPath, bundle, 'utf-8');
  }
```
### 完整代码
[https://github.com/jinguo/SimpleWebpack](https://github.com/jinguo/SimpleWebpack)
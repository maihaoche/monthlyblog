最近在思考这样一个问题，当项目依赖了多个不同版本的包，打包结果和 node_modules 依赖结构会有什么不一样？会不会高版本的覆盖低版本的方法呢？如果覆盖了就可能导致程序 bug 。



为了尝试多版本依赖问题，我写了两个包来测试，已经放在了 npm 上。分别是 [@flypkg/main](https://www.npmjs.com/package/@flypkg/main) [@flypkg/suba](https://www.npmjs.com/package/@flypkg/suba)

仓库地址是 https://github.com/simonwong/flypkg



## 验证思路

验证思路是这样的

`suba` 包暴露了一个 `runSubA` 方法，会打印出自己当前版本。

```javascript
export function runSubA () {
  logMessage('subA', pkg.version, '在 subA 中执行')
}
```



`main` 包依赖与自己相同版本的 `suba` 并暴露一个 `init` 放执行 `runSubA`。

```javascript
export function init () {
  logMessage('main', pkg.version, '在 main 中执行')
  runSubA()
}
```



然后在项目中依赖不同版本的 @flypkg/main 和 @flypkg/suba ，并同时执行 `init`  和 `runSubA` 方法

```javascript
import { init } from '@flypkg/main'
import { runSubA } from '@flypkg/suba'

init()
runSubA()
```



![](http://file.wangsijie.top/blog/20200510214555.png)



可能不同版本的 yarn 和 npm 会有不同的结果，这里的测试版本为 `yarn@1.22.0` `npm@6.14.4`

## 尝试 

### 第一次尝试



我们的 package.json 的版本是这样的。注意：这里的 suba 版本没有加 `^`  

```json
"dependencies": {
    "@flypkg/main": "^0.0.2",
    "@flypkg/suba": "0.0.1",
},
```

执行 `yarn list` 是这样的

```
├─ @flypkg/main@0.0.2
│  ├─ @flypkg/suba@^0.0.2
│  └─ @flypkg/suba@0.0.2
├─ @flypkg/suba@0.0.1
```



输出结果如下

![](http://file.wangsijie.top/blog/20200510220431.png)



看了下 webpack 的打包结果，存在两个 `runSubA` 方法，在各自的执行代码块中，对应 0.0.1 和 0.0.2 版本。



### 第二次尝试

考虑到是否因为 `^` 符号影响，我在 suba 包前面加了 `^` 符号。 `^` 的加入，可以使 install 的时候安装到 `0.x.x` 的最新版本。

然而实际的依赖树和执行结果同上。



### 第三次尝试

修改 package.json 如下

```json
"dependencies": {
    "@flypkg/main": "^0.0.2",
    "@flypkg/suba": "^0.0.3"
 },
```



`yarn list` 结果如下

```
├─ @flypkg/main@0.0.2
│  ├─ @flypkg/suba@^0.0.2
│  └─ @flypkg/suba@0.0.2
├─ @flypkg/suba@0.0.3
```



执行结果如下

![](http://file.wangsijie.top/blog/20200510223557.png)

依旧是执行不同的依赖版本的方法。



## 总结

嗯～～～对结果表示心满意足。这样就避免了一开始我所担心的问题。我们可以继续放心的在项目中使用新的依赖了。\(≧▽≦)/



等等，我们是不是忽略了什么问题。



### 问题一

由于存在各种版本的方法，我们最终打包的体积也变的更大了！是的，我们只能眼睁着包的体积变大。

有什么优化手段呢？

就是尽可能的使用 ES Module 规范和支持 tree shaking 的包，就是在包的 package.json 中，写着这样的一行代码 `"sideEffects": false` 。

它来告诉 `webpack` ，如果我这个包有些方法没有被使用，那么你可以尽情的抖掉（不打包）。避免代码冗余。



### 问题二

如果 `main@0.0.3` 依赖的 `suba@0.0.3` 存在着 bug ，我们该怎么解决呢。

使用 `resolutions` 强行锁版本。yarn 支持，npm 需要使用 `npm-froce-resolution` 这个库来实现。

```package.json
/* package.json */
{
	"resolutions": {
		"@flypkg/suba": "0.0.2"
	}
}
```



相关阅读 [node_modules 困境](https://zhuanlan.zhihu.com/p/137535779)



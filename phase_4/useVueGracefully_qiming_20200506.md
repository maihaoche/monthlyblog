# Vue 项目优化技巧



## 一. Vue 批量注册全局组件

### 1.在全局组件 `components` 文件夹下新增 `global.js` 文件 该文件为全局组件配置文件，文件内容如下：

```javascript
important Vue from 'vue'
		
function changeStr (str) {
    //charAt  去字符的第一个自检 abc => Abc
    return str.charAt(0).toUpperCase() + str.slice(1)
}
		
//require.context(a,b,c)  a => 目录  b => 是否有子目录  c => 匹配文件的正则
const requireComponent = require.context('.', false, /\.vue$/)
requireComponent.keys().forEach(fillName => {
	//第i个
	const config = requireComponent(fillName)
	const componentName = changeStr(
	    fillName.replace(/^\.\//,'').replace(/\.\w+$/,'')
	)
	Vue.component(componentName, config.default || config)
})
```

创建该文件之后，就可以直接在 `components` 文件内编写全局组件，由于 `require.context( )  `中的第二个参数填写的是 `false`，所以所有组件都需要以 `.vue` 文件的形式直接存放在 `components` 文件下



### 2.在`main.js`全局引入该`global.js`

注意：注册全局组件会带来性能的损耗，所以需要清除该方法的使用场景，只有在组件频繁使用的情况下适 合使用，比如一些表格、弹框、提示框、输入框等组件



## 二. Vue 主路由优化

**主要原理：使用 `webpack` 的 `require.context()` API**

**假设 demo 中有两个模块，home 和 login**



### 1.**在项目 `router` 文件夹下面新增 `home.router.js` 和 `login.router.js` 进行分区**

大致内容：

```javascript
export default {  
  path: '/home',  
  redirect: '/home',  
  component: () => import('@/views/layout'),  
  meta: {    //路由的排序会根据该权限码的大小进行升序排序
    role: [10000],    
    title: '首页'  
	},  
  children: [
    {
      path: '',
      name: 'home',
      component: () => import('@/views/home/index'),
      meta: {
        title: '平台首页',
        icon: 'iconfont icon-shouye',
        role: [11000],
      },
		},
  ],
}
```

### 2.在 `router` 文件夹的主路由文件夹中批量引入分区路由

大致内容：

```javascript
import Vue from 'vue'
import Router from 'vue-router'
Vue.use(Router)
let routerList = []
function importAll (r) {
  r.keys().forEach(   //r(key).default 是因为分区路由导出时采用 export default 
   (key) => routerList.push(r(key).default)
  )
}
importAll(require.context('.', false, /\.router\.js/))
// 按照权限码排序routerList = routerList.sort((a, b) => { return a.meta.role[0] - b.meta.role[0] })export const asyncRoutes = [...routerList]export default new Router({  mode: 'history',  base: '',  routes: asyncRoutes})

```

**总结：该方法的好处在于，降低大型项目的路由复杂度，对路由进行分区管理，便于维护和迭代。**

**以上路由虽然添加了权限码，但是并没有做静态路由和动态路由的区分，如果项目需要进行权限判断时，只需要对分区路由文件进行区分，比如静态路由分区文件以  `.crouter.js` 结尾，动态路由分区文件以 `.arouter.js` 结尾，在主路由中引入分区路由文件时，分两次执行 `importAll()` 方法，只需要修改两次执行时的正则就可以分别导入两种路由。**



**在需要频繁 `import` 的情况下，可以尝试合理使用该方法！**



## 三. Vue-Cli 3 引入 SCSS 全局变量

### 1.首先创建一个全局变量文件 `global.scss`

```scss
$theme-color: #efefef;
```

### 2.配置 `vue.config.js`

```javascript
module.exports = {
  // ...
  css: {
    loaderOptions: {
      sass: {
        data: `@import "@/styles/global.scss";`
      }
    }
  }
}
```

现在就可以在任意地方使用`global.scss`中定义的变量了，这么做的目的主要是为了一些主题样式的全局配置，例如主体背景颜色、全局默认字体大小、颜色等等。



## 四. vue-cli2 打包开启 `gzip` 压缩

### 1.安装打包插件：`compression-webpack-plugin`

这里使用 `npm` 安装：`npm install --save-dev compression-webpack-plugin@1.1.12`

**因为vue-cli2使用的是webpack3.0+，但是最新版的compression-webpack-plugin需要 webpack4.0+才能支持，所以这边安装插件的时候，需要指定一个低版本号，防止兼容问题发生。**



### 2.安装好之后，修改 `config` 文件夹下的 `index.js` 配置文件

![img](https://user-gold-cdn.xitu.io/2020/3/3/1709e611a2b1b6b2?w=500&h=111&f=png&s=6703)

将 `productionGzip: false` 改为 `true`

### 3. 添加`css`文件压缩配置

不进行这一步的情况下，已经可以正常打包，并且将大文件压缩成 `gz` 文件，但是因为`vue-cli`自带的`webpack.prod.config`配置没有对`css`文件进行匹配，所以如果需要`css`文件进行压缩的话，就要修改`build`文件夹下的正则匹配。

![img](https://user-gold-cdn.xitu.io/2020/3/3/1709e685b7824a63?w=624&h=264&f=png&s=14110)

​																				修改为

![img](https://user-gold-cdn.xitu.io/2020/3/3/1709e68d7b8c971f?w=438&h=218&f=png&s=10183)

### 4.运行 `npm run build` 进行打包

![img](https://user-gold-cdn.xitu.io/2020/3/3/1709e69d68d2baed?w=731&h=650&f=png&s=48158)

会将大小大于 10kb 的文件进行压缩，生成 `gz` 结尾的静态文件



### 5.最后一步，上传到服务器之后，`nginx` 需要进行配置，配置文件如下

![img](https://user-gold-cdn.xitu.io/2020/3/3/1709e827b3be7822?w=1498&h=302&f=png&s=81270)

接下来就可以愉快地访问啦！



## 五. vue-cli3 打包开启 `gzip` 压缩

### 1.安装打包插件：`compression-webpack-plugin`

这里使用 `npm` 安装：`npm install --save-dev compression-webpack-plugin`



### 2.修改 `vue.config.js` 配置

![img](https://user-gold-cdn.xitu.io/2020/3/3/1709f68f7d00f265?w=891&h=839&f=png&s=76241)



### 3.运行 `npm run build` 进行打包

![img](https://user-gold-cdn.xitu.io/2020/3/3/1709f6e3ae1e536c?w=366&h=547&f=png&s=27092)

打包完之后可以看到，打包文件生成了 `gz` 结尾的压缩文件

### 4.同上修改 `nginx` 服务器配置，就可以愉快地访问啦～


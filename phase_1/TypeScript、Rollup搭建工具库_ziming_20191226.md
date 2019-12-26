# TypeScript、Rollup 搭建工具库

![](http://file.wangsijie.top/blog/20191226183850.png)



## 前景提要

公司内总是有许多通用的工具方法、业务功能，我们可以搭建一个工具库来给各个项目使用。

要实现的需求：

- 支持编辑器的快速补全和提示
- 自动化构建
- 支持自动生成 changlog
- 代码通过 lint 和测试后才能提交、发布



### 涉及的库

- eslint + @typescript-eslint/parser
- rollup
- jest
- @microsoft/api-extractor
- gulp

## 初始化项目

新建一个项目目录如 `fly-helper` , 并 `npm init` 初始化项目。

### 安装 [TypeScript](https://www.tslang.cn/docs/home.html)

```shell
yarn add -D typescript
```



创建 `src` 目录，入口文件，以及 ts 的配置文件

```
fly-helper
 |
 |- src
 	 |- index.ts
 |- tsconfig.json
```



###  配置 tsconfig.json

```json
# tsconfig.json
{
  "compilerOptions": {
    /* 基础配置 */
    "target": "esnext",
    "lib": [
      "dom",
      "esnext"
    ],
    "removeComments": false,
    "declaration": true,
    "sourceMap": true,

    /* 强类型检查配置 */
    "strict": true,
    "noImplicitAny": false,

    /* 模块分析配置 */
    "baseUrl": ".",
    "outDir": "./lib",
    "esModuleInterop": true,
    "moduleResolution": "node",
    "resolveJsonModule": true
  },
  "include": [
    "src"
  ]
}
```



### 参考 commit

 [1892d4](https://github.com/simonwong/fly-helper/commit/1892d46aa6131806f720581737af60ea0c2fd4c2)

Ps：commit 中还增加了 .editorconfig  ，来约束同学们的代码格式

## 配置 eslint

TypeScirpt 已经全面采用 ESLint 作为代码检查 [The future of TypeScript on ESLint](https://eslint.org/blog/2019/01/future-typescript-eslint)

并且提供了 TypeScript 文件的解析器 [@typescript-eslint/parser](https://github.com/typescript-eslint/typescript-eslint/tree/master/packages/parser) 和配置选项 [@typescript-eslint/eslint-plugin](https://github.com/typescript-eslint/typescript-eslint/tree/master/packages/eslint-plugin)

### 安装

```shell
yarn add -D eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin 
```



### 目录结构

```
fly-helper
 |- .eslintignore
 |- .eslintrc.js
 |- tsconfig.eslint.json
```



### Ps

tsconfig.eslint.json 我们根目录中增加了一个 tsconfig 文件，它将用于 `eslintrc.parserOptions.project` ，由于该配置要求 incude 每个 ts、js 文件。而我们仅需要打包 src 目录下的代码，所以增加了该配置文件。



如果 `eslintrc.parserOptions.project` 配置为 tsconfig.json 。src 文件以外的 ts、js 文件都会报错。

```
Parsing error: "parserOptions.project" has been set for @typescript-eslint/parser.
The file does not match your project config: config.ts.
The file must be included in at least one of the projects provided.eslint
```

虽然可以配置 `eslintrc.parserOptions.createDefaultProgram` 但会造成巨大的性能损耗。

[issus: Parsing error: "parserOptions.project"...](https://github.com/typescript-eslint/typescript-eslint/issues/967)



### 配置 tsconfig.eslint.json

```json
# tsconfig.eslint.json
{
  "compilerOptions": {
    "baseUrl": ".",
    "resolveJsonModule": true,
  },
  "include": [
    "**/*.ts",
    "**/*.js"
  ]
}
```



### 配置 .eslintrc.js

```javascript
// .eslintrc.js
const eslintrc = {
    parser: '@typescript-eslint/parser', // 使用 ts 解析器
    extends: [
        'eslint:recommended', // eslint 推荐规则
        'plugin:@typescript-eslint/recommended', // ts 推荐规则
    ],
    plugins: [
        '@typescript-eslint',
    ],
    env: {
        browser: true,
        node: true,
        es6: true,
    },
    parserOptions: {
        project: './tsconfig.eslint.json',
        ecmaVersion: 2019,
        sourceType: 'module',
        ecmaFeatures: {
          experimentalObjectRestSpread: true
        }
    },
    rules: {}, // 自定义
}

module.exports = eslintrc
```



### 参考 commit

[36f63d](https://github.com/simonwong/fly-helper/commit/36f63d7ae4140ed32388b5111d0f537909e7c81d)

## 配置 rollup

vue、react 等许多流行库都在使用 Rollup.js ，就不多介绍，直接看 [官网](https://www.rollupjs.com/) 吧



### 安装

安装 rollup 以及要用到的插件

```shell
yarn add -D rollup rollup-plugin-babel rollup-plugin-commonjs rollup-plugin-eslint rollup-plugin-node-resolve rollup-plugin-typescript2
```

安装 babel 相关的库

```shell
yarn add -D @babel/preset-env
```



### 目录结构

```
fly-helper
 |
 |- typings
 	 |- index.d.ts
 |- .babelrc
 |- rollup.config.ts
```



### 配置 .babelrc

```json
# .babelrc
{
  "presets": [
    [
      "@babel/preset-env",
      {
        # Babel 会在 Rollup 有机会做处理之前，将我们的模块转成 CommonJS，导致 Rollup 的一些处理失败
        "modules": false
      }
    ]
  ]
}
```



### 配置 rollup.config.ts

```typescript
import path from 'path'
import { RollupOptions } from 'rollup'
import rollupTypescript from 'rollup-plugin-typescript2'
import babel from 'rollup-plugin-babel'
import resolve from 'rollup-plugin-node-resolve'
import commonjs from 'rollup-plugin-commonjs'
import { eslint } from 'rollup-plugin-eslint'
import { DEFAULT_EXTENSIONS } from '@babel/core'

import pkg from './package.json'

const paths = {
  input: path.join(__dirname, '/src/index.ts'),
  output: path.join(__dirname, '/lib'),
}

// rollup 配置项
const rollupConfig: RollupOptions = {
  input: paths.input,
  output: [
    // 输出 commonjs 规范的代码
    {
      file: path.join(paths.output, 'index.js'),
      format: 'cjs',
      name: pkg.name,
    },
    // 输出 es 规范的代码
    {
      file: path.join(paths.output, 'index.esm.js'),
      format: 'es',
      name: pkg.name,
    },
  ],
  // external: ['lodash'], // 指出应将哪些模块视为外部模块，如 Peer dependencies 中的依赖
  // plugins 需要注意引用顺序
  plugins: [
    // 验证导入的文件
    eslint({
      throwOnError: true, // lint 结果有错误将会抛出异常
      throwOnWarning: true,
      include: ['src/**/*.ts'],
      exclude: ['node_modules/**', 'lib/**', '*.js'],
    }),

    // 使得 rollup 支持 commonjs 规范，识别 commonjs 规范的依赖
    commonjs(),

    // 配合 commnjs 解析第三方模块
    resolve({
      // 将自定义选项传递给解析插件
      customResolveOptions: {
        moduleDirectory: 'node_modules',
      },
    }),
    rollupTypescript(),
    babel({
      runtimeHelpers: true,
      // 只转换源代码，不运行外部依赖
      exclude: 'node_modules/**',
      // babel 默认不支持 ts 需要手动添加
      extensions: [
        ...DEFAULT_EXTENSIONS,
        '.ts',
      ],
    }),
  ],
}

export default rollupConfig
```



一些注意事项：

- plugins 必须有顺序的使用
- external 来设置三方库为外部模块，否则也会被打包进去，变得非常大哦



### 配置声明文件

```typescript
declare module 'rollup-plugin-babel'
declare module 'rollup-plugin-eslint'
```

由于部分插件还没有 @types 库，所以我们手动添加声明文件



### 试一下

我们在 index.ts 文件下，随意加入一个方法

```typescript
export default function myFirstFunc (str: string) {
  return `hello ${str}`
}
```

由于使用了 `RollupOptions` 接口，直接执行会报错。我们要注释掉第2行`import { RollupOptions } from 'rollup'`，和第17行 `const rollupConfig` 后面的 `: RollupOptions`。

然后执行 `npx rollup --c rollup.config.ts`

就生成了 index.js 和 index.esm.js 文件。分别对应着 commonjs 规范和 es 规范的文件。rollup 可是大力推行 es 规范啊，然后我们很多三方库都仍旧使用 commonjs 规范，为了兼容，我们两种规范都生成。



由于使用了 ts ，可以很方便的实现快速补全的需求，按照上面的例子，项目中使用这个包后，vscode 上输入就会有如下效果

![](http://file.wangsijie.top/blog/20191226114541.png)



### 参考 commit

[0aab81](https://github.com/simonwong/fly-helper/commit/0aab814f129de73ef12b1652c43e04139000a2db)

## 配置 jest

工具库当然要写测试啦，快开始吧

### 安装

```shell
yarn add -D @types/jest eslint-plugin-jest jest ts-jest
```

### 目录结构

```
fly-helper
 |- test
 	|- index.test.ts
 |- jest.config.js
```



### 配置 jest.config.js

```javascript
// jest.config.js
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
}
```



### 动手写个 test 吧

```typescript
// index.test.ts

import assert from 'assert'
import myFirstFunc from '../src'

describe('validate:', () => {
  /**
   * myFirstFunc
   */
  describe('myFirstFunc', () => {
    test(' return hello rollup ', () => {
      assert.strictEqual(myFirstFunc('rollup'), 'hello rollup')
    })
  })
})
```



### 再配置 eslint

```javascript
const eslintrc = {
  // ...
  extends: [
    // ...
    'plugin:jest/recommended',
  ],
  plugins: [
    // ...
    'jest',
  ],
  // ...
}
```



### 增加 package.json scripts

```
"test": "jest --coverage --verbose -u"
```

- coverage  输出测试覆盖率
- verbose 层次显示测试套件中每个测试的结果，会看着更加直观啦

### 试一下

```
yarn test
```

是不是成功了呢

![](http://file.wangsijie.top/blog/20191226154137.png)



### 参考 commit

[9bbe5b](https://github.com/simonwong/fly-helper/commit/9bbe5b1585ab709b8e0c1ad0ff8243b7c43b7bd7)



## 配置 @microsoft/api-extractor

当我们 src 下有多个文件时，打包后会生成多个声明文件。

使用 @microsoft/api-extractor 这个库是为了把所有的 .d.ts 合成一个，并且，还是可以根据写的注释自动生成文档。

### 安装

```shell
yarn add -D @microsoft/api-extractor
```



### 配置 api-extractor.json

```json
# api-extractor.json
{
  "$schema": "https://developer.microsoft.com/json-schemas/api-extractor/v7/api-extractor.schema.json",
  "mainEntryPointFilePath": "./lib/index.d.ts",
  "bundledPackages": [ ],
  "dtsRollup": {
    "enabled": true,
    "untrimmedFilePath": "./lib/index.d.ts"
  }
}
```



### 增加 package.json scripts

```
"api": "api-extractor run",
```



### 尝试一下

你可以尝试多写几个方法，打包后会发现有多个 .d.ts 文件，然后执行 `yarn api`

加入[ts doc](https://github.com/microsoft/tsdoc) 风格注释

```typescript
/**
 * 返回 hello 开头的字符串
 * @param str - input string
 * @returns 'hello xxx'
 * @example
 * ```ts
 * myFirstFunc('ts') => 'hello ts'
 * ```
 *
 * @beta
 * @author ziming
 */
```

在使用的该方法的时候就会有提示啦

这里我已经增加了两个方法，请看 下面的 commit

执行后，会发现 声明都合在 index.d.ts 上啦。然后要把多余的给删除掉，后面改成自动删除它😕



😤还有一个 temp 文件夹，咱们配置一下 gitignore 不然它提交。tsdoc-metadata.json 可以暂时不管它，可以删除掉。

后面配置 package.json 的 typing 会自动更改存放位置

### 参考 commit

 [4e4b3d](https://github.com/simonwong/fly-helper/commit/4e4b3df2febf9f32f17e4bb06c3d734508e10b2c)



之后使用方法就有这样的提示，是不是会用的很方便嘞😉

![](http://file.wangsijie.top/blog/20191226164824.png)



## gulp 自动化构建

### 安装

```shell
yarn add -D gulp @types/gulp fs-extra @types/fs-extra @types/node ts-node chalk
```



### 配置 package.json

```json
  "main": "lib/index.js",
  "module": "lib/index.esm.js",
  "typings": "lib/index.d.js",

  "scripts": {
      # ...
      "build": "gulp build",
  }
```



### 配置 gulpfile

我们思考一下构建流程🤔

1. 删除 lib 文件
2. 呼叫 Rollup 打包
3. api-extractor 生成统一的声明文件，然后 删除多余的声明文件
4. 完成



我们一步一步来

```typescript
// 删除 lib 文件
const clearLibFile: TaskFunc = async (cb) => {
  fse.removeSync(paths.lib)
  log.progress('Deleted lib file')
  cb()
}
```



```typescript
// rollup 打包
const buildByRollup: TaskFunc = async (cb) => {
  const inputOptions = {
    input: rollupConfig.input,
    external: rollupConfig.external,
    plugins: rollupConfig.plugins,
  }
  const outOptions = rollupConfig.output
  const bundle = await rollup(inputOptions)

  // 写入需要遍历输出配置
  if (Array.isArray(outOptions)) {
    outOptions.forEach(async (outOption) => {
      await bundle.write(outOption)
    })
    cb()
    log.progress('Rollup built successfully')
  }
}
```



```typescript
// api-extractor 整理 .d.ts 文件
const apiExtractorGenerate: TaskFunc = async (cb) => {
  const apiExtractorJsonPath: string = path.join(__dirname, './api-extractor.json')
  // 加载并解析 api-extractor.json 文件
  const extractorConfig: ExtractorConfig = await ExtractorConfig.loadFileAndPrepare(apiExtractorJsonPath)
  // 判断是否存在 index.d.ts 文件，这里必须异步先访问一边，不然后面找不到会报错
  const isExist: boolean = await fse.pathExists(extractorConfig.mainEntryPointFilePath)

  if (!isExist) {
    log.error('API Extractor not find index.d.ts')
    return
  }

  // 调用 API
  const extractorResult: ExtractorResult = await Extractor.invoke(extractorConfig, {
    localBuild: true,
    // 在输出中显示信息
    showVerboseMessages: true,
  })

  if (extractorResult.succeeded) {
    // 删除多余的 .d.ts 文件
    const libFiles: string[] = await fse.readdir(paths.lib)
    libFiles.forEach(async file => {
      if (file.endsWith('.d.ts') && !file.includes('index')) {
        await fse.remove(path.join(paths.lib, file))
      }
    })
    log.progress('API Extractor completed successfully')
    cb()
  } else {
    log.error(`API Extractor completed with ${extractorResult.errorCount} errors`
      + ` and ${extractorResult.warningCount} warnings`)
  }
}
```



```typescript
// 完成
const complete: TaskFunc = (cb) => {
  log.progress('---- end ----')
  cb()
}
```



然后用一个 build 方法，将他们按顺序合起来

```typescript
export const build = series(clearLibFile, buildByRollup, apiExtractorGenerate, complete)
```



### 尝试一下

```shell
yarn build
```

溜去 lib 文件下瞅瞅🧐，美滋滋。🥳



### 参考 commit

[a5370c](https://github.com/simonwong/fly-helper/commit/a5370cb0c1e334d271439916648bc98586b16f05)



## changelog 自动生成

### 安装

```shell
yarn add -D conventional-changelog-cli
```



### 配置 gulpfile

```typescript
// gulpfile
import conventionalChangelog from 'conventional-changelog'

// 自定义生成 changelog
export const changelog: TaskFunc = async (cb) => {
  const changelogPath: string = path.join(paths.root, 'CHANGELOG.md')
  // 对命令 conventional-changelog -p angular -i CHANGELOG.md -w -r 0
  const changelogPipe = await conventionalChangelog({
    preset: 'angular',
    releaseCount: 0,
  })
  changelogPipe.setEncoding('utf8')

  const resultArray = ['# 工具库更新日志\n\n']
  changelogPipe.on('data', (chunk) => {
    // 原来的 commits 路径是进入提交列表
    chunk = chunk.replace(/\/commits\//g, '/commit/')
    resultArray.push(chunk)
  })
  changelogPipe.on('end', async () => {
    await fse.createWriteStream(changelogPath).write(resultArray.join(''))
    cb()
  })
}

```

惊喜的发现 conventional-changelog 木得 @types 库，继续手动添加

```typescript
// typings/index.d.ts

declare module 'conventional-changelog'
```



### 参考 commit

[1f31ab](https://github.com/simonwong/fly-helper/commit/1f31ab05ad81e5f726a4b3ee7b73a0c6bf3e8566)

### Ps

使用该工具需要注意一下

- 非常注意 commit 格式，格式采用 [angular commit 规范](https://github.com/angular/angular/blob/master/CONTRIBUTING.md)，会识别 feat 和 fix 开头的 commit ，然后自动生成
- 每次更改需要先升级 version 再去生成。。后面会有例子



## 优化开发流程

### 安装

```shell
yarn add -D husky lint-staged
```



### package.json

话不多说，看代码

```json
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged & jest -u"
    }
  },
  "lint-staged": {
    "*.{.ts,.js}": [
      "eslint",
      "git add"
    ]
  }
```



之后提交代码都会先 lint 验证，再 jest 测试通过，才可以提交。避免误操作。



## 优化发布流程

### package.json

```json
"files": [
    "lib",
    "LICENSE",
    "CHANGELOG.md",
    "README.md"
],
# 使得支持 tree shaking
"sideEffects": "false",
"script": {
    # ...
    "changelog": "gulp changelog",
    "prepublishOnly": "yarn lint & yarn test & yarn changelog & yarn build"
}
```

prepublishOnly 可以在 publish 的时候，先 lint 验证， 再 jest 测试 ， 再 生成 changlog ，最后 打包，最后 发布。

至此，我们已经实现了全部需求。



### 参考 commit

[7f343f](https://github.com/simonwong/fly-helper/commit/7f343fda98ce31bf055184ac60932def8cf81367)

## changelog 例子

- 我们假装现在开始写第一个方法。我删除了上面的例子，增加了一个 calculate.ts

    请看 commit

- 然后我们提交这次更改，commit 内容为 `feat: 新增 calculateOneAddOne 计算 1 + 1 方法`

- 执行 npm version major 升级主版本号 1.0.0。

     [更多升级版本的操作](https://simonwong.github.io/advanced/npm.html#version)

    版本规范参考 [语义化版本 2.0.0](https://semver.org/lang/zh-CN/)

- `yarn changelog` 看看你的 changelog.md 就自动生成了



完整内容 [fly-helper/release/1.0.0](https://github.com/simonwong/fly-helper/tree/release/1.0.0)



## 参考

[TypeScript 入门教程](https://ts.xcatliu.com/)

[TypeSearch](https://microsoft.github.io/TypeSearch/)

[The future of TypeScript on ESLint](https://eslint.org/blog/2019/01/future-typescript-eslint)

[Rollup.js 中文网](https://www.rollupjs.com/)

[rollup - pkg.module](https://github.com/rollup/rollup/wiki/pkg.module)

[jest 中文文档](https://jestjs.io/docs/zh-Hans/getting-started)

[api-extractor](https://api-extractor.com/)

[tsdoc](https://github.com/microsoft/tsdoc)

[gulp](https://www.gulpjs.com.cn/docs/getting-started/quick-start/)

[Commit message 和 Change log 编写指南](https://www.ruanyifeng.com/blog/2016/01/commit_message_change_log.html)
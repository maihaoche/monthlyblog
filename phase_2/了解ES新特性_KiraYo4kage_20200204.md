# 了解ES新特性

JS的发展日新月异， TC39 每年都会更新 ECMA 规范标准，本文会带大家一起来看一些 ES 的新特性。

首先介绍下 ES 的历史背景， ECMAScript 实际上是一种脚本在语法和语义上的标准。实际上 JavaScript 是由 ECMAScript ， DOM 和 BOM 三者组成的。而 ECMA 的第39号技术专家委员会（ Technical Committee 39，简称 TC39 ）负责制订 ECMAScript 标准，成员包括Microsoft、Mozilla、Google 等大公司。

说起来你可能不信，如今 ES 已经发展到了 ES2020 ,按照我们习惯的说法也就是 ES11 了！你是否还沉浸在学习 ES6 的语法呢 :)

一般来说新语法、特性的诞生会经历几个阶段，也就是我们经常看到的 stage-0 到 stage-4 。<a href="https://github.com/tc39/proposals/blob/master/finished-proposals.md" target="__blank">这个仓库</a> 可以看到已经处于 finish 状态的草案。或者你可以在<a href="https://prop-tc39.now.sh/" target="__blank">这个网站</a>查看所有草案。

---

## Array.prototype.{flat,flatMap}

数组平铺也是一道比较经典的面试题了，如今在 js 中有了直接的 API 来解决这个问题。

flat() 方法会按照一个可指定的深度递归遍历数组，并将所有元素与遍历到的子数组中的元素合并为一个新数组返回。

它只接受一个入参 depth 代表需要提取数组的深度，默认值为1。如果我们不知道数组的深度但是想要完全平铺的话可以传入 Infinity 代表展开任意深度。

```js
let arr = [1, [2, [3]]]

arr.flat(); //  [1, 2, Array(1)]
arr.flat(2); // [1, 2, 3]
arr.flat(Infinity); // [1, 2, 3]
```

flatMap() 方法首先使用映射函数映射每个元素，然后将结果压缩成一个新数组。它与 map 连着深度值为1的 flat 几乎相同，但 flatMap 通常在合并成一种方法的效率稍微高一些。

```js
let arr = ["it's Sunny in", "", "California"];

arr.map(x => x.split(" "));
// [["it's","Sunny","in"],[""],["California"]]

arr.flatMap(x => x.split(" "));
// ["it's","Sunny","in", "", "California"]
```

arr.flatMap(callback) 约等于 arr.map(callback).flat() 。控制 callback 的返回值为 [] 或 [param1, param2, ...restParams] 可以删减或添加数组的项目。

## String.prototype.{trimStart,trimEnd}

trimStart() 方法从字符串的开头删除空格。trimLeft()是此方法的别名。

trimEnd() 方法从一个字符串的末端移除空白字符。trimRight() 是这个方法的别名。

```js
'  Hello World!  '.trim(); // "Hello World!"
'  Hello World!  '.trimStart(); // "Hello World!  "
'  Hello World!  '.trimEnd(); // "  Hello World!"
```

## Object.fromEntries

Object.fromEntries() 与 ES6 中的 Object.entries 方法相对应，把键值对列表转换为一个对象。

```js
Object.entries({ a: 'a', b: 'b' }); // [["a", "a"], ["b", "b"]]
Object.fromEntries([['a', 'a'], ['b', 'b']]); // {a: "a", b: "b"}
```

以下示例可以起到按需过滤对象属性的效果：
```js
obj = { abc: 1, def: 2, ghij: 3 };
res = Object.fromEntries(
  Object.entries(obj)
  .filter(([ key, val ]) => key.length === 3)
  .map(([ key, val ]) => [ key, val * 2 ])
);

// res is { 'abc': 2, 'def': 4 }
```

## Symbol.prototype.description

创建 Symbol 的时候可以传入一个描述，但在以前获取描述只能将 Symbol 转化为 string 然后正则匹配出来。现在你可以通过这个 API 来获取描述。

```js
const symbol = Symbol(123);
String(symbol); // "Symbol(123)"
symbol.description; // "123"
```

## Optional catch binding

在 try catch 语法中支持了省略错误参数，在你不关心具体错误内容时可以使用。

```js
try {
  // try to do something
} catch {
  // fallback
}
```

## Optional Chaining（可选链）

在使用点运算符获取对象属性时，或者结构对象获取属性时经常会遇到对象值为 null 或是 undefined 导致程序报错无法继续执行。这一点在处理后端数据时经常遇到。往往我们需要做如下操作：

```js
const name = data && data.detail && data.detail.name;
// or
const { list } = this.props;
(list || []).map(...);
```

现在我们可以使用可选链符号 ?. 来简化代码：

```js
const name = data?.detail?.name;

const { list } = this.props;
list?.map(...)
```

可选链符号会检测它前面的引用是否是 nullish(null / undefined) 的，如果是就不会去读取后面的属性值；如果需要读取的属性值的一个函数，但是它不存在与前面的引用对象中，可选链会返回 undefined ，而不会去调用这个函数，这对于探索一个对象的内容是很有帮助的。

特别的，对于函数的调用也可以使用可选链

```js
object.method?.();
```

但是需要注意如果对象中存在同名的属性却不是函数类型的话，此处仍然会报 TypeError 异常。

**现在浏览器对于这个特性的支持还不好，在使用时需要加入 babel 插件 @babel/plugin-proposal-optional-chaining 。*

## Nullish coalescing Operator（空值合并运算符）

在做条件判断时我们经常会使用二元或三元运算，而条件往往是一个布尔值。

```js
const text = Boolean(data) ? data : '暂无数据';
```

问题来了 0 和 "" 等值也一样会被转化为 false 而无法得到我们想要的结果。所以我们需要把判断完善：

```js
// 判断条件过长，影响可读性
const text = data !== null && data !== undefined ? data : '暂无数据';

// == 和 != 运算符容易引起歧义
const text = data != null ? data : '暂无数据';
```

现在控制合并运算符可以达到上面两个表达式相同的效果了。

```js
const text = data ?? '暂无数据';
```

世界瞬间清净了，你还可以将它与可选链一起使用。

```js
const text = data?.text ?? '暂无数据';
```

**同样的，使用时需要加入 babel 插件 @babel/plugin-proposal-nullish-coalescing-operator 。*

## Promise.allSettled

过去我们常使用 Promise.all 来合并多个请求到一次异步操作中，比如：

```js
async function fetchData() {
  const list1 = fetchList1();
  const list2 = fetchList2();
  const list3 = fetchList3();
  showLoading();
  await Promise.all([
    list1,
    list2,
    list3,
  ]);
  render();
  hideLoading();
}
```

Promise.all 要求所有 promise 都处于 fulfilled 状态才能正常结束。当其中一个请求异常后就会导致页面一直处于加载状态或是全部数据加载失败状态，这不是我们期望的结果。

使用 Promise.allSettled 可以避免这种情况，只要所有 promise 都完成，即 fulfilled 或者 rejected 就可以了。在结果中我们可以根据 status 来过滤成功的数据。这样页面上就能显示出加载成功的数据，而加载失败的模块仍然可以显示为 placeholder 。

```js
async function fetchData() {
  const list1 = fetchList1();
  const list2 = fetchList2();
  const list3 = fetchList3();
  showLoading();
  const result = await Promise.allSettled([
    list1,
    list2,
    list3,
  ]);
  render(result.filter(promise => promise.status === 'fulfilled'));
  hideLoading();
}
```

## import() 

动态加载语法，在各类打包工具中已经是老生常谈的了，如今它成为了正式语法。我们可以一如既往地在项目中使用它。

```js
button.onclick = async () => {
  const { default: dynamicModule } = await import('some-path/module');
  dynamicModule.doSomething();
}
```

## String.prototype.matchAll

考虑一下正则，使用字符串的 match 方法去匹配，可以获得完成匹配和子匹配的集合。

```js
const reg = /test(\d)/;
const str1 = `test1`;
const str2 = `test1test2`;
str1.match(reg); // ["test1", "1"]
str2.match(reg); // ["test1", "1"]
```

但是有一个很明显的问题，我们只获取到了第一个匹配到的结果，后面的 `test2` 并没有匹配到。

如果尝试加上全局匹配符 /g ，确实能匹配到 `test2` ，但是子项没有被包括进去。

```js
const reg = /test(\d)/g;
const str1 = `test1`;
const str2 = `test1test2`;
str1.match(reg); // ["test1", "1"]
str2.match(reg); // ["test1", "test2"]
```

matchAll 就是为了解决这个问题

```js
const reg = /test(\d)/g;
const str1 = `test1`;
const str2 = `test1test2`;
const matches1 = str1.matchAll(reg); // RegExpStringIterator {}
const matches2 = str2.matchAll(reg); // RegExpStringIterator {}
[...matches1]; // [["test1", "1"]]
[...matches2]; // [["test1", "1"], [["test2", "2"]]]
```

可以看到获取结果是一个迭代器，将他进行扩展运算后可以的到我们想要的结果。

**值得注意的是这个结果的迭代器是不可重用的，使用一次后需要重新匹配*

## BigInt

number 类型的安全整数范围是 Number.MIN_SAFE_INTEGER 到 Number.MAX_SAFE_INTEGER ，超过这个范围的值可能会丢失精度。

```js
Number.MAX_SAFE_INTEGER + 1 === Number.MAX_SAFE_INTEGER + 2 // true
```

使用新的 BigInt 类型来避免这个问题

```js
const bigIntOne = 1n; // 字面量形式
const bigIntOne = BigInt('1'); // 函数调用形式

Number.MAX_SAFE_INTEGER; // 9007199254740991
BigInt('9007199254740992') === BigInt('9007199254740993'); // false
```

需要注意调用 BigInt 时，入参不要用数字类型，因为传入参数的时候也会对参数进行一次实例化，导致入参本身失去精度。

## globalThis

用来获取全局对象，无论当前处于什么运行环境。

相当于

```js
var getGlobal = function () { 
  if (typeof self !== 'undefined') { return self; } 
  if (typeof window !== 'undefined') { return window; } 
  if (typeof global !== 'undefined') { return global; } 
  throw new Error('unable to locate global object'); 
}; 
```

---

新特性的出现就是为了让开发者更方便、更专注地去实现逻辑，所以大家可以尝试在自己项目中将他们使用起来啦 &#x1f389; 。
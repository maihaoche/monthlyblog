# javaScript中this用法原理详解

### 1.问题背景
先来看下如下代码，你是否能一眼便看出结果，并知道里面的运行机制呢？
```
a = 1;
obj = {
    a : 2;
    f : function() {
        console.log(this.a);
    }
}

let foo = obj.f;

obj.f();  // 2
foo();    // 1
```
如上代码，虽然**obj.f**和**foo**指向的是同一个函数，但是它们的结果却是不一样的。产生这种差异的原因就是使用了**this**，很多资料上解释因为**this**指的是函数运行所在的环境，**obj.f**()运行在obj环境,所以输出2，**foo**运行在全局环境，所以输出1。这个解释没有错，那我们更深层的探讨下,运行环境是怎么样创建的？函数的运行环境到底是怎么决定的呢？


如果对于那些老练的 JavaScript 开发者来说 this 机制都是如此的令人费解，那么我们为什么还要使用this呢？我们可以观察如下展示的两段代码，思考下哪种方式更优雅


```
function identify() {
	return this.name.toUpperCase();
}

function speak() {
	var greeting = "Hello, I'm " + identify.call( this );
	console.log( greeting );
}

var me = {
	name: "Kyle"
};

var you = {
	name: "Reader"
};

identify.call( me ); // KYLE
identify.call( you ); // READER

speak.call( me ); // Hello, I'm KYLE
speak.call( you ); // Hello, I'm READER
```

```
function identify(context) {
	return context.name.toUpperCase();
}

function speak(context) {
	var greeting = "Hello, I'm " + identify( context );
	console.log( greeting );
}

identify( you ); // READER
speak( me ); // Hello, I'm KYLE
```

第一段代码片段允许 identify() 和 speak() 函数对多个 环境 对象（me 和 you）进行复用，第二段代码明确地将环境对象传递给 identify() 和 speak()。

然而，使用this 机制提供了更优雅的方式来隐含地“传递”一个对象引用，导致更加干净的API设计和更容易的复用。

你的使用模式越复杂，你就会越清晰地看到：将执行环境作为一个明确参数传递，通常比传递 this 执行环境要乱。

### 2.this是如何工作的？

误区一：this 指向函数自己

我们来看下这段代码, 我们试图追踪函数(foo)被调用了多少次

```
function foo(num) {
	console.log( "foo: " + num );

	// 追踪 `foo` 被调用了多少次
	this.count++;
}

foo.count = 0;

var i;

for (i=0; i<10; i++) {
	if (i > 5) {
		foo( i );
	}
}
// foo: 6
// foo: 7
// foo: 8
// foo: 9

// `foo` 被调用了多少次？
console.log( foo.count ); // 0 --  并没有按照期望返回调用4次……？

```

从上面的代码来看，如果this指向的是函数自己，那么应该输出4，但是结果并不是我们预想的那样输出4，这种挫败来源于对于 this（在 this.count++ 中）的含义进行了 过于字面化 的解释。

当代码执行 foo.count = 0 时，它确实向函数对象 foo 添加了一个 count 属性。但是对于函数内部的 this.count 引用，this 其实 根本就不 指向那个函数对象，因而取得的并不是我们想要的属性。

所以说this 指向函数自己是不对的，我们可以通过如下两种方式来解决这个问题：

```
function foo(num) {
	console.log( "foo: " + num );

	// 追踪 `foo` 被调用了多少次
	data.count++;
}

var data = {
	count: 0
};

var i;

for (i=0; i<10; i++) {
	if (i > 5) {
		foo( i );
	}
}
// foo: 6
// foo: 7
// foo: 8
// foo: 9

// `foo` 被调用了多少次？
console.log( data.count ); // 4

```

这种方式完全避开了this，缺乏对于 this 的含义和其工作方式上的理解 —— 反而退回到了一个他更加熟悉的机制的舒适区：词法作用域

```
function foo(num) {
	console.log( "foo: " + num );

	// 追踪 `foo` 被调用了多少次
	// 注意：由于 `foo` 的被调用方式（见下方），`this` 现在确实是 `foo`
	this.count++;
}

foo.count = 0;

var i;

for (i=0; i<10; i++) {
	if (i > 5) {
		// 使用 `call(..)`，我们可以保证 `this` 指向函数对象(`foo`)
		foo.call( foo, i );
	}
}
// foo: 6
// foo: 7
// foo: 8
// foo: 9

// `foo` 被调用了多少次？
console.log( foo.count ); // 4

```
另一种解决这个问题的方法是强迫 this 指向 foo 函数对象,与回避 this 相反，我们接受它。 我们马上将会更完整地讲解这样的技术 如何 工作，所以如果你依然有点儿糊涂，不要担心！

误区二：对 this 的含义第二常见的误解，是它不知怎的指向了函数的作用域。这是一个刁钻的问题，因为在某一种意义上它有正确的部分，而在另外一种意义上，它是严重的误导。

明确地说，this 不会以任何方式指向函数的 词法作用域。作用域好像是一个将所有可用标识符作为属性的对象，这从内部来说是对的。但是 JavasScript 代码不能访问作用域“对象”。它是 引擎 的内部实现。

考虑下面代码，它（失败的）企图跨越这个边界，用 this 来隐含地引用函数的词法作用域：

```
function foo() {
	var a = 2;
	this.bar();
}

function bar() {
	console.log( this.a );
}

foo(); //undefined

```
首先，试图通过 this.bar() 来引用 bar() 函数。它几乎可以说是 碰巧 能够工作，我们过一会儿再解释它是 如何 工作的。调用 bar() 最自然的方式是省略开头的 this.，而仅使用标识符进行词法引用。

然而，写下这段代码的开发者试图用 this 在 foo() 和 bar() 的词法作用域间建立一座桥，使得bar() 可以访问 foo()内部作用域的变量 a。这样的桥是不可能的。 你不能使用 this 引用在词法作用域中查找东西。这是不可能的。

每当你感觉自己正在试图使用 this 来进行词法作用域的查询时，提醒你自己：这里没有桥。

### 3.什么是this ?

我们已经列举了各种不正确的臆想，现在让我们把注意力转移到 this 机制是如何真正工作的。

我们早先说过，this 不是编写时绑定，而是运行时绑定。它依赖于函数调用的上下文条件。this 绑定与函数声明的位置没有任何关系，而与函数被调用的方式紧密相连。

当一个函数被调用时，会建立一个称为执行环境的活动记录。这个记录包含函数是从何处（调用栈 —— call-stack）被调用的，函数是 如何 被调用的，被传递了什么参数等信息。这个记录的属性之一，就是在函数执行期间将被使用的 this 引用。

### 4.调用点

为了理解 this 绑定，我们不得不理解调用点：函数在代码中被调用的位置（不是被声明的位置）。我们必须考察调用点来回答这个问题：这个 this 指向什么？

一般来说寻找调用点就是：“找到一个函数是在哪里被调用的”，但它不总是那么简单，比如某些特定的编码模式会使 真正的 调用点变得不那么明确。

考虑 调用栈（call-stack） （使我们到达当前执行位置而被调用的所有方法的堆栈）是十分重要的。我们关心的调用点就位于当前执行中的函数 之前 的调用。

```
function baz() {
    // 调用栈是: `baz`
    // 我们的调用点是 global scope（全局作用域）

    console.log( "baz" );
    bar(); // <-- `bar` 的调用点
}

function bar() {
    // 调用栈是: `baz` -> `bar`
    // 我们的调用点位于 `baz`

    console.log( "bar" );
    foo(); // <-- `foo` 的 call-site
}

function foo() {
    // 调用栈是: `baz` -> `bar` -> `foo`
    // 我们的调用点位于 `bar`

    console.log( "foo" );
}

baz(); // <-- `baz` 的调用点
```
在分析代码来寻找（从调用栈中）真正的调用点时要小心，因为它是影响 this 绑定的唯一因素。

注意： 你可以通过按顺序观察函数的调用链在你的大脑中建立调用栈的视图，就像我们在上面代码段中的注释那样。但是这很痛苦而且易错。另一种观察调用栈的方式是使用你的浏览器的调试工具。大多数现代的桌面浏览器都内建开发者工具，其中就包含 JS 调试器。在上面的代码段中，你可以在调试工具中为 foo() 函数的第一行设置一个断点，或者简单的在这第一行上插入一个 debugger 语句。当你运行这个网页时，调试工具将会停止在这个位置，并且向你展示一个到达这一行之前所有被调用过的函数的列表，这就是你的调用栈。所以，如果你想调查this 绑定，可以使用开发者工具取得调用栈，之后从上向下找到第二个记录，那就是你真正的调用点。

### 5.调用点适用规则

现在我们将注意力转移到调用点 如何 决定在函数执行期间 this 指向哪里。

你必须考察调用点并判定4种规则中的哪一种适用。我们将首先独立地解释一下这4种规则中的每一种，之后我们来展示一下如果有多种规则可以适用于调用点时，它们的优先顺序。

#### a.默认绑定（Default Binding）

我们要考察的第一种规则源于函数调用的最常见的情况：独立函数调用。可以认为这种 this 规则是在没有其他规则适用时的默认规则。

考虑这个代码段：

```
function foo() {
	console.log( this.a );
}

var a = 2;

foo(); // 2

```

我们看到当foo()被调用时，this.a解析为我们的全局变量a。为什么？因为在这种情况下，对此方法调用的 this 实施了 默认绑定，所以使 this 指向了全局对象。

我们怎么知道这里适用 默认绑定 ？我们考察调用点来看看 foo() 是如何被调用的。在我们的代码段中，foo() 是被一个直白的，毫无修饰的函数引用调用的。没有其他的我们将要展示的规则适用于这里，所以 默认绑定 在这里适用。

如果 strict mode 在这里生效，那么对于 默认绑定 来说全局对象是不合法的，所以 this 将被设置为 undefined。

```
function foo() {
	"use strict";

	console.log( this.a );
}

var a = 2;

foo(); // TypeError: `this` is `undefined`

```

一个微妙但是重要的细节是：即便所有的 this 绑定规则都是完全基于调用点的，但如果 foo() 的 内容 没有在 strict mode 下执行，对于 默认绑定 来说全局对象是 唯一 合法的；foo() 的调用点的 strict mode 状态与此无关。

```
function foo() {
	console.log( this.a );
}

var a = 2;

(function(){
	"use strict";

	foo(); // 2
})();

```

#### b.隐含绑定（Implicit Binding）

另一种要考虑的规则是：调用点是否有一个环境对象（context object），也称为拥有者（owning）或容器（containing）对象，虽然这些名词可能有些误导人。

考虑这段代码：

```
function foo() {
	console.log( this.a );
}

var obj = {
	a: 2,
	foo: foo
};

obj.foo(); // 2

```

首先，注意 foo() 被声明然后作为引用属性添加到 obj 上的方式。无论 foo() 是否一开始就在 obj 上被声明，还是后来作为引用添加（如上面代码所示），这个 函数 都不被 obj 所真正“拥有”或“包含”

然而，调用点 使用 obj 环境来 引用 函数，所以你 可以说 obj 对象在函数被调用的时间点上“拥有”或“包含”这个 函数引用。

不论你怎样称呼这个模式，在 foo() 被调用的位置上，它被冠以一个指向 obj 的对象引用。当一个方法引用存在一个环境对象时，隐含绑定 规则会说：是这个对象应当被用于这个函数调用的 this 绑定。

因为 obj 是 foo() 调用的 this，所以 this.a 就是 obj.a 的同义词。

只有对象属性引用链的最后一层是影响调用点的。比如：
```
function foo() {
	console.log( this.a );
}

var obj2 = {
	a: 42,
	foo: foo
};

var obj1 = {
	a: 2,
	obj2: obj2
};

obj1.obj2.foo(); // 42

```

#### c.隐含丢失（Implicitly Lost）

this 绑定最常让人沮丧的事情之一，就是当一个 隐含绑定 丢失了它的绑定，这通常意味着它会退回到 默认绑定， 根据 strict mode 的状态，其结果不是全局对象就是 undefined。

考虑这段代码：

```
function foo() {
	console.log( this.a );
}

var obj = {
	a: 2,
	foo: foo
};

var bar = obj.foo; // 函数引用！

var a = "oops, global"; // `a` 也是一个全局对象的属性

bar(); // "oops, global"

```
尽管 bar 似乎是 obj.foo 的引用，但实际上它只是另一个 foo 本身的引用而已。另外，起作用的调用点是 bar()，一个直白，毫无修饰的调用，因此 默认绑定 适用于这里。

这种情况发生的更加微妙，更常见，而且更意外的方式，是当我们考虑传递一个回调函数时：

```
function foo() {
	console.log( this.a );
}

function doFoo(fn) {
	// `fn` 只不过 `foo` 的另一个引用

	fn(); // <-- 调用点!
}

var obj = {
	a: 2,
	foo: foo
};

var a = "oops, global"; // `a` 也是一个全局对象的属性

doFoo( obj.foo ); // "oops, global"
```

参数传递仅仅是一种隐含的赋值，而且因为我们在传递一个函数，它是一个隐含的引用赋值，所以最终结果和我们前一个代码段一样。

那么如果接收你所传递回调的函数不是你的，而是语言内建的呢？没有区别，同样的结果。
```
function foo() {
	console.log( this.a );
}

var obj = {
	a: 2,
	foo: foo
};

var a = "oops, global"; // `a` 也是一个全局对象的属性

setTimeout( obj.foo, 100 ); // "oops, global"
```

把这个粗糙的，理论上的 setTimeout() 假想实现当做 JavaScript 环境内建的实现的话：

```
function setTimeout(fn,delay) {
  // （通过某种方法）等待 `delay` 毫秒
	fn(); // <-- 调用点!
}

```
正如我们刚刚看到的，我们的回调函数丢掉他们的 this 绑定是十分常见的事情。但是 this 使我们吃惊的另一种方式是，接收我们回调的函数故意改变调用的 this。那些很流行的 JavaScript 库中的事件处理器就十分喜欢强制你的回调的 this 指向触发事件的 DOM 元素。虽然有时这很有用，但其他时候这简直能气死人。不幸的是，这些工具很少给你选择。

不管哪一种意外改变 this 的方式，你都不能真正地控制你的回调函数引用将如何被执行，所以你（还）没有办法控制调用点给你一个故意的绑定。我们很快就会看到一个方法，通过 固定 this 来解决这个问题。

#### d.明确绑定（Explicit Binding）
用我们刚看到的 隐含绑定，我们不得不改变目标对象使它自身包含一个对函数的引用，而后使用这个函数引用属性来间接地（隐含地）将 this 绑定到这个对象上。

但是，如果你想强制一个函数调用使用某个特定对象作为 this 绑定，而不在这个对象上放置一个函数引用属性呢？

JavaScript 语言中的“所有”函数都有一些工具（通过他们的 [[Prototype]] —— 待会儿详述）可以用于这个任务。具体地说，函数拥有 call(..) 和 apply(..) 方法。从技术上讲，JavaScript 宿主环境有时会提供一些（说得好听点儿！）很特别的函数，它们没有这些功能。但这很少见。绝大多数被提供的函数，当然还有你将创建的所有的函数，都可以访问 call(..) 和 apply(..)。

这些工具如何工作？它们接收的第一个参数都是一个用于 this 的对象，之后使用这个指定的 this 来调用函数。因为你已经直接指明你想让 this 是什么，所以我们称这种方式为 明确绑定（explicit binding)。

考虑这段代码：
```
function foo() {
	console.log( this.a );
}

var obj = {
	a: 2
};

foo.call( obj ); // 2

```
通过 foo.call(..) 使用 明确绑定 来调用 foo，允许我们强制函数的 this 指向 obj。

如果你传递一个简单基本类型值（string，boolean，或 number 类型）作为 this 绑定，那么这个基本类型值会被包装在它的对象类型中（分别是 new String(..)，new Boolean(..)，或 new Number(..)）。这通常称为“封箱（boxing）”。

注意： 就 this 绑定的角度讲，call(..) 和 apply(..) 是完全一样的。它们确实在处理其他参数上的方式不同，但那不是我们当前关心的。

不幸的是，单独依靠 明确绑定 仍然不能为我们先前提到的问题提供解决方案，也就是函数“丢失”自己原本的 this 绑定，或者被第三方框架覆盖，等等问题。

#### e.硬绑定（Hard Binding）
但是有一个 明确绑定 的变种确实可以实现这个技巧。考虑这段代码：

```
function foo() {
	console.log( this.a );
}

var obj = {
	a: 2
};

var bar = function() {
	foo.call( obj );
};

bar(); // 2
setTimeout( bar, 100 ); // 2

// `bar` 将 `foo` 的 `this` 硬绑定到 `obj`
// 所以它不可以被覆盖
bar.call( window ); // 2

```
我们来看看这个变种是如何工作的。我们创建了一个函数 bar()，在它的内部手动调用 foo.call(obj)，由此强制 this 绑定到 obj 并调用 foo。无论你过后怎样调用函数 bar，它总是手动使用 obj 调用 foo。这种绑定即明确又坚定，所以我们称之为 硬绑定（hard binding）

用 硬绑定 将一个函数包装起来的最典型的方法，是为所有传入的参数和传出的返回值创建一个通道：
```
function foo(something) {
	console.log( this.a, something );
	return this.a + something;
}

var obj = {
	a: 2
};

var bar = function() {
	return foo.apply( obj, arguments );
};

var b = bar( 3 ); // 2 3
console.log( b ); // 5

```

另一种表达这种模式的方法是创建一个可复用的帮助函数：

```
function foo(something) {
	console.log( this.a, something );
	return this.a + something;
}

// 简单的 `bind` 帮助函数
function bind(fn, obj) {
	return function() {
		return fn.apply( obj, arguments );
	};
}

var obj = {
	a: 2
};

var bar = bind( foo, obj );

var b = bar( 3 ); // 2 3
console.log( b ); // 5

```
由于 硬绑定 是一个如此常用的模式，它已作为 ES5 的内建工具提供：Function.prototype.bind，像这样使用:

```
function foo(something) {
	console.log( this.a, something );
	return this.a + something;
}

var obj = {
	a: 2
};

var bar = foo.bind( obj );

var b = bar( 3 ); // 2 3
console.log( b ); // 5
```
bind(..) 返回一个硬编码的新函数，它使用你指定的 this 环境来调用原本的函数。

注意： 在 ES6 中，bind(..) 生成的硬绑定函数有一个名为 .name 的属性，它源自于原始的 目标函数（target function）。举例来说：bar = foo.bind(..) 应该会有一个 bar.name 属性，它的值为 "bound foo"，这个值应当会显示在调用栈轨迹的函数调用名称中。

#### f. API 调用的“环境”
确实，许多库中的函数，和许多在 JavaScript 语言以及宿主环境中的内建函数，都提供一个可选参数，通常称为“环境（context）”，这种设计作为一种替代方案来确保你的回调函数使用特定的 this 而不必非得使用 bind(..)。
举例来说：
```
function foo(el) {
	console.log( el, this.id );
}

var obj = {
	id: "awesome"
};

// 使用 `obj` 作为 `this` 来调用 `foo(..)`
[1, 2, 3].forEach( foo, obj ); // 1 awesome  2 awesome  3 awesome

```
从内部来说，几乎可以确定这种类型的函数是通过 call(..) 或 apply(..) 来使用 明确绑定 以节省你的麻烦。

#### g .new 绑定（new Binding）
第四种也是最后一种 this 绑定规则，要求我们重新思考 JavaScript 中关于函数和对象的常见误解。

在传统的面向类语言中，“构造器”是附着在类上的一种特殊方法，当使用 new 操作符来初始化一个类时，这个类的构造器就会被调用。通常看起来像这样：
```
something = new MyClass(..);

```
JavaScript 拥有 new 操作符，而且使用它的代码模式看起来和我们在面向类语言中看到的基本一样；大多数开发者猜测 JavaScript
机制在做某种相似的事情。但是，实际上 JavaScript 的机制和 new 在 JS 中的用法所暗示的面向类的功能 没有任何联系。

首先，让我们重新定义 JavaScript 的“构造器”是什么。在 JS 中，构造器 仅仅是一个函数，它们偶然地与前置的 new 操作符一起调用。它们不依附于类，它们也不初始化一个类。它们甚至不是一种特殊的函数类型。它们本质上只是一般的函数，在被使用 new 来调用时改变了行为。

例如，引用 ES5.1 的语言规范，Number(..) 函数作为一个构造器来说：

```
15.7.2 Number 构造器

当 Number 作为 new 表达式的一部分被调用时，它是一个构造器：它初始化这个新创建的对象。

```

当在函数前面被加入 new 调用时，也就是构造器调用时，下面这些事情会自动完成：

1. 一个全新的对象会凭空创建（就是被构建）
2. 这个新构建的对象会被接入原形链（[[Prototype]]-linked）
3. 这个新构建的对象被设置为函数调用的 this 绑定
4. 除非函数返回一个它自己的其他 对象，否则这个被 new 调用的函数将 自动 返回这个新构建的对象。



考虑这段代码：
```
function foo(a) {
	this.a = a;
}

var bar = new foo( 2 );
console.log( bar.a ); // 2

```

通过在前面使用 new 来调用 foo(..)，我们构建了一个新的对象并把这个新对象作为 foo(..) 调用的 this。 new 是函数调用可以绑定 this 的最后一种方式，我们称之为 new 绑定（new binding）。


如此，我们已经揭示了函数调用中的四种 this 绑定规则。你需要做的 一切 就是找到调用点然后考察哪一种规则适用于它。但是，如果调用点上有多种规则都适用呢？这些规则一定有一个优先顺序，我们下面就来展示这些规则以什么样的优先顺序实施。

很显然，默认绑定 在四种规则中优先权最低的。所以我们先把它放在一边。

隐含绑定 和 明确绑定 哪一个更优先呢？我们来测试一下：

```
function foo() {
	console.log( this.a );
}

var obj1 = {
	a: 2,
	foo: foo
};

var obj2 = {
	a: 3,
	foo: foo
};

obj1.foo(); // 2
obj2.foo(); // 3

obj1.foo.call( obj2 ); // 3
obj2.foo.call( obj1 ); // 2

```
所以, 明确绑定 的优先权要高于 隐含绑定，这意味着你应当在考察 隐含绑定 之前 首先 考察 明确绑定 是否适用。

现在，我们只需要搞清楚 new 绑定 的优先级位于何处。

好了，new 绑定 的优先级要高于 隐含绑定。那么你觉得 new 绑定 的优先级较之于 明确绑定 是高还是低呢？

注意： new 和 call/apply 不能同时使用，所以 new foo.call(obj1) 是不允许的，也就是不能直接对比测试 new 绑定 和 明确绑定。但是我们依然可以使用 硬绑定 来测试这两个规则的优先级。

在我们进入代码中探索之前，回想一下 硬绑定 物理上是如何工作的，也就是 Function.prototype.bind(..) 创建了一个新的包装函数，这个函数被硬编码为忽略它自己的 this 绑定（不管它是什么），转而手动使用我们提供的。

因此，这似乎看起来很明显，硬绑定（明确绑定的一种）的优先级要比 new 绑定 高，而且不能被 new 覆盖。

我们检验一下：

```
function foo(something) {
	this.a = something;
}

var obj1 = {};

var bar = foo.bind( obj1 );
bar( 2 );
console.log( obj1.a ); // 2

var baz = new bar( 3 );
console.log( obj1.a ); // 2
console.log( baz.a ); // 3

```
### 6. 如何判定this
现在，我们可以按照优先顺序来总结一下从函数调用的调用点来判定 this 的规则了。按照这个顺序来问问题，然后在第一个规则适用的地方停下。

1. 函数是通过 new 被调用的吗（new 绑定）？如果是，this         就是新构建的对象。
    var bar = new foo()
2. 函数是通过 call 或 apply 被调用（明确绑定），甚至是隐藏在 bind 硬绑定 之中吗？如果是，this 就是那个被明确指定的对象。

    var bar = foo.call( obj2 )

3. 函数是通过环境对象（也称为拥有者或容器对象）被调用的吗（隐含绑定）？如果是，this 就是那个环境对象。

    var bar = obj1.foo()
    
4. 否则，使用默认的 this（默认绑定）。如果在 strict mode 下，就是 undefined，否则是 global 对象。

    var bar = foo()
    












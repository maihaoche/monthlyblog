## js深复制 VS 浅复制

理解js深复制与浅复制，我们首先需要理解的概念有：堆，栈，数据类型，引用类型

### 堆与栈的特点

堆：
- 存储引用类型数据
- 按引用访问
- 存储空间动态分配
- 无序存储，可以通过引用直接获取
- 存储空间大，但是运行效率相对较低


栈: 
- 存储基础数据类型
- 按值访问
- 存储空间固定
- 由系统自动分配内存空间
- 空间小，运行效率高
- 先进后出，后进先出

### 数据类型

#### 基本类型

基本数据类型：undefined，boolean，number，string，null

基本数据类型存储在栈中，直接按值存放的，所以可以直接访问

基本数据类型的值是不可变的，动态修改了基本数据类型的值，它的原始值也是不会改变的

```
    var str = "abc";
    
    console.log(str[1]="f");    // f
    
    console.log(str);           // abc
    
```
可以看到，str的原始值并没有改变。它们只会返回一个新的字符串，原字符串的值并 不会改变。所以请记住，基本数据类型的值是不可改变的。

基本类型的比较是值的比较，只要它们的值相等就认为他们是相等的。

比较的时候最好使用严格等，因为 == 是会进行类型转换的
```
    var a = 1;
    var b = 1;
    console.log(a === b);//true
    
    
    var a = 1;
    var b = "1";
    console.log(a === b);//false, 类型不同
    
    
    var a = 1;
    var b = true;
    console.log(a == b);//true，进行了类型转换
    
```


#### 引用类型：object

引用类型（object）是存放在堆内存中的，变量实际上是一个存放在栈内存的指针，这个指针指向堆内存中的地址。每个空间大小不一样，要根据情况进行特定的分配，例如：

```
var person1 = {name:'jozo'};
var person2 = {name:'xiaom'};
var person3 = {name:'xiaoq'};

```

![image](https://img.maihaoche.com/2E895EBC-3F77-47C5-A5D0-95ABED2888D8.jpg)

引用类型等值是可以改变的
如：
```
    var a = [1,2,3];
    a[1] = 5;
    console.log(a[1]); // 5
    
```

引用类型的比较是引用的比较,所以每次我们对 js 中的引用类型进行操作的时候，都是操作其对象的引用（保存在栈内存中的指针），所以比较两个引用类型，是看其的引用是否指向同一个对象

```
    var a = [1,2,3];
    var b = [1,2,3];
    console.log(a === b); // false
    
```

虽然变量 a 和变量 b 都是表示一个内容为 1，2，3 的数组，但是其在内存中的位置不一样，也就是说变量 a 和变量 b 指向的不是同一个对象，指向的不是同一处的堆内存空间。所以他们是不相等的。

## 传值与传址

了解了基本数据类型与引用类型的区别之后，我们就应该能明白传值与传址的区别了。
在我们进行赋值操作的时候，基本数据类型的赋值（=）是在内存中新开辟一段栈内存，然后再将值赋值到新的栈中。例如：

```
var a = 10;
var b = a;

a ++ ;
console.log(a); // 11
console.log(b); // 10

```

![image](https://img.maihaoche.com/D8E8F0B8-C6FF-41AC-AD90-37FF8CF7B4E3.jpg)

所以说，基本类型的赋值的两个变量是两个独立相互不影响的变量

但是引用类型的赋值是传址。只是改变指针的指向，例如，也就是说引用类型的赋值是对象保存在栈中的地址的赋值，这样的话两个变量就指向同一个对象，因此两者之间操作互相有影响。例如
```
var a = {}; // a保存了一个空对象的实例
var b = a;  // a和b都指向了这个空对象

a.name = 'jozo';
console.log(a.name); // 'jozo'
console.log(b.name); // 'jozo'

b.age = 22;
console.log(b.age);// 22
console.log(a.age);// 22

console.log(a == b);// true

```

![image](https://img.maihaoche.com/6E31840B-70E3-484B-A902-E20CDF743846.jpg)

### 浅拷贝

有上面等知识基础后，对于理解浅拷贝就很容易了。请看如下例子,看看浅复制与直接赋值之间的区别：
```
var obj1 = {
        'name' : 'zhangsan',
        'age' :  '18',
        'language' : [1,[2,3],[4,5]],
    };

    var obj2 = obj1;


    var obj3 = shallowCopy(obj1);
    function shallowCopy(src) {
        var dst = {};
        for (var prop in src) {
            if (src.hasOwnProperty(prop)) {
                dst[prop] = src[prop];
            }
        }
        return dst;
    }

    obj2.name = "lisi";
    obj3.age = "20";

    obj2.language[1] = ["二","三"];
    obj3.language[2] = ["四","五"];

    console.log(obj1);  
    //obj1 = {
    //    'name' : 'lisi',
    //    'age' :  '18',
    //    'language' : [1,["二","三"],["四","五"]],
    //};

    console.log(obj2);
    //obj2 = {
    //    'name' : 'lisi',
    //    'age' :  '18',
    //    'language' : [1,["二","三"],["四","五"]],
    //};

    console.log(obj3);
    //obj3 = {
    //    'name' : 'zhangsan',
    //    'age' :  '20',
    //    'language' : [1,["二","三"],["四","五"]],
    //};
```

通过上面的打印，我们可以知道：改变赋值得到的对象 obj2 同时也会改变原始值 obj1，而改变浅拷贝得到的的 obj3 则不会改变原始对象 obj1。这就可以说明赋值得到的对象 obj2 只是将指针改变，其引用的仍然是同一个对象，而浅拷贝得到的的 obj3 则是重新创建了新对象。

然而，我们接下来来看一下改变引用类型会是什么情况呢，我又改变了赋值得到的对象 obj2 和浅拷贝得到的 obj3 中的 language 属性的第二个值和第三个值（language 是一个数组，也就是引用类型）。结果见输出，可以看出来，无论是修改赋值得到的对象 obj2 和浅拷贝得到的 obj3 都会改变原始数据。

根据这段代码我们就可以知道：
```
    function shallowCopy(src) {
        var dst = {};
        for (var prop in src) {
            if (src.hasOwnProperty(prop)) {
                dst[prop] = src[prop];
            }
        }
        return dst;
    }
```

浅拷贝只复制一层对象的属性，并不包括对象里面的为引用类型的数据。
所以就会出现改变浅拷贝得到的 obj3 中的引用类型时，会使原始数据得到改变。

我们可以通过一个图来展示深复制，浅复制，以及赋值之间的区别：
![image](https://img.maihaoche.com/DCCF2D44-0569-4E19-A2F2-75FF1145C4AF.jpg)

### 深复制
深拷贝是对对象以及对象的所有子对象进行拷贝，我们只需把所有属于对象的属性类型都遍历赋给另一个对象即可。看如下代码：
```
   function deepClone(obj) {
        //如果不是复杂数据类型,就直接返回一个一样的对象
        if(typeof obj !="object"){
            return obj
        }
        //如果是,就递归调用
        var newObj = {};
        for (var key in obj) {
          newObj[key] = deepClone(obj[key])
        }
        return newObj;
    }
```

这里主要使用了一个递归，如果子元素为对象类型，就继续浅拷贝。


至此是不是对浅拷贝，深拷贝有了清楚的认识呢。






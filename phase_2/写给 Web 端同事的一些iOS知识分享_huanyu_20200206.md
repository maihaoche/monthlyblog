# 写给 Web 端同事的一些iOS知识分享

这次分享主要分为两个部分：
- iOS 相关开发知识的一些介绍，以便大家以后接触到类似 RN / Flutter 工程但没有移动端同事的时候，能够有方向去搜相关信息；
- iOS 端与 web 端相互调用和调试的一些归纳。


*由于分享过程中间会穿插使用Xcode进行演示和口头讲解，文章只做了部分关键信息的罗列*

## 系统层次架构图
主要分为4个层次：`Cocoa Touch`、`Media`、`Core Service`和`Core OS`。

![iOS Foundation Layer.png](https://i.loli.net/2020/02/06/aXFL9cMK2DWxtoY.png)

- Cocoa Touch *触摸UI层*
    顾名思义，其包含的很多框架是与用户交互相关的，是开发 iOS App 的关键框架。提供了 App 的基础结构，同时也提供了诸如：触摸、推送、多任务处理、推送等系统服务。
    
    其中 `UIKit` 是最常用的，用于界面的构建。
        
- Media *媒体层*
    提供对 App 处理各种媒体文件的处理能力，诸如：音视频的编解码，图形绘制，制作动画效果等。
    
- Core Services *核心服务层*
    包含所有 App 使用的基本系统服务。即使不直接使用这些服务，系统的许多部分还是建立在它们之上。
    
    其中 `Foundation` 是最常用的，为上层框架和App开发提供基础功能，提供基本的数据类型和操作工具，诸如：集合类型处理、字符串处理、日期处理、文件处理、异常处理等。
    
- Core OS *核心操作系统层*
    包含大多数其他技术所基于的底层功能。负责内存管理、文件系统任务、网络处理和一些其他的操作系统任务，还能直接和硬件设备进行交互。通常来说，大部分开发情况不会直接使用与这一层打交道，上层框架会使用到它们。
    
> 更多可见 [iOS Technology Overview -TP40007898 7.0.3-](http://pooh.poly.asu.edu/Mobile/ClassNotes/Papers/MobilePlatforms/iOSTechnicalOverview.pdf)。

## 基本知识概览

![基本知识概览.png](https://i.loli.net/2020/02/06/8Di6Mlq4a3NOPHY.png)


### 工程文件
鉴于一般Web开发者会接触到iOS工程的情况是使用`React-Native`/`Flutter`/`Weex`初始化时自动创建的项目，所以先来看看工程文件都有些什么：

- ***.h**： 头文件，声明类、方法以及属性，相当于对外暴露可访问接口。
- ***.m**： 实现 `.h` 中声明的方法，添加私有方法、属性。
- ***.pch**： 预编译头文件，通常用于放置 `宏定义` 和 `公共头文件`

<br/>
<br/>

- ***.xib**： 可视化View布局文件，本质是使用`XML`描述的View布局文件
- ***.storyboard**： 故事板，`xib`的强化版，同样是使用`XML`描述的布局文件，但可放置、连接控制多个页面跳转逻辑
- ***.plist**： 全称`Property List`(属性列表)，可用于存储序`列化后`的对象，常用用于存储`用户配置`，轻量级的持久化方案
- ***.lproj**： 国际化包，可包含`文本`、`图片`、`xib`、`storyboard`
- ***.xcassets**： (图片)资源文件包，通常用于放置`图片资源`，后续增加了`颜色`等

<br/>
<br/>

- **Podfile**： 广泛使用的包依赖管理(`Cocoapods`)的配置文件，可类比成web项目的`package.json`
- ***Podfile.lock**： 依赖管理工具安装依赖的锁定版本，可类比成web项目的`package-lock.json`

<br/>
<br/>

- ***.xcodeproj**： Xcode 工程文件，存储工程的各种配置
- ***.xcworkspace**： Xcode 工程文件，通常是使用依赖管理工具 `Cocoapods` 执行 `pod install` 安装了依赖之后生成的（也可自己搞，是多个 `xcodeproj` 的合集）。

### 设计模式
光秃秃的直接解释也不能很好的理解，所以借着设计模式的示例工程来了解一下。

不过还是有一些需要先讲一讲便于理解
##### 类似 NS、UI、AV、CF的前缀是什么？
由于**在 OC 中没有命名空间**的概念，所以通过加前缀的方式来避免冲突，一般开发者用自己名字/公司缩写的大写字母作为前缀，Apple保留所有2个字母作为前缀的权利。
其中 NS 代表的是[NeXTSTEP](https://baike.baidu.com/item/NeXTSTEP)，是乔布斯创立的 NeXT.Inc 公司开发的系统，其原生支持Objective-C，NeXT 1997年被 Apple 被收购，成为Mac OS的基础。
其他诸如：UI -> UIKit、 AV -> AVFoundation/AVKit（Audio+Video）、CF -> CoreFoundation

##### @ 是什么？
一是关键字前带@，如：`@class`、`@interface`、`@implementation`、`@end`、`@protocol` 等等
二是作为语法糖，如字符串 `@""`、基础类型转对象类型的数字`@(1) @(YES) @(0.0)`、数组 `@[]`、字典 `@{}` 等

#### 演示
详见[示例工程](https://github.com/maihaoche/monthlyblog/tree/master/phase_2/iOSSampleSourceCode)，此段主要为分享中讲解，文章中没有体现

-------
接下来我们来说说 iOS 和 web 端开发协调相关的东西。

## WebView 与 Native交互
在 iOS 中有两种webview，`UIWebView` 和 `WKWebView`：

- UIWebView *(iOS 2.0 ~ 12.0)*
在App进程中跑，加载页面的内存是算在App占用内存中的，当app内存超过限制时，会通知app处理，若未处理整个app会被kill。
已成历史，2020年4月开始禁止新的App使用，年底禁止所有含有的App更新。
<br>

- WKWebView *(iOS 8.0 ~ )*
独立进程，当其内存占用超过系统分配给WKWebView的内存时，WKWebView会崩溃白屏并通知app进行处理，未处理app不会被kill。内存是 UIWebView 的1/3 - 1/4，启动更快。异步处理与native桥接通信的js。

<br>
当然 WKWebView 也是有很多坑点的：

- 虽然从iOS 8.0开始支持，但是有很多问题，所以一般会从9.0才开始使用。不过鉴于iOS用户更新率非常高（从目前[官方数据](https://developer.apple.com/support/app-store/)来看 50%的iPhone已经是iOS 13了， 41%的iOS12），这个基本可以忽略了。
- Cookie会出现携带不上的问题。
- 通过loadRequest发起post请求的body会被丢掉。
- 直接使用NSURLProtocol无法拦截请求。

碰上的主要是这几个，更多其他的可以参考bugly的[WKWebView 那些坑](https://mp.weixin.qq.com/s/rhYKLIbXOsUJC_n6dt9UfA?)


### URL拦截，常用Scheme
类似于 `mhc://b.maihaoche.com?type=xxx&value=xxx`

```html
<html>
    <header>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <script type="text/javascript">
            // 给Native调用执行的方法 定义好
            function showAlert(message){
                alert(message);
            }
            // 通过发起iframe的方式打开一个 url-scheme
            function loadURL(url) {
                var iFrame;
                iFrame = document.createElement("iframe");
                iFrame.setAttribute("src", url);
                iFrame.setAttribute("style", "display:none;");
                iFrame.setAttribute("height", "0px");
                iFrame.setAttribute("width", "0px");
                iFrame.setAttribute("frameborder", "0");
                document.body.appendChild(iFrame);
                // 发起请求后这个 iFrame 就没用了，所以把它从 dom 上移除掉
                iFrame.parentNode.removeChild(iFrame);
                iFrame = null;
            }
            // 点击html按钮
            function firstClick() {
                loadURL("mhc://b.maihaoche.com?type=xxx&value=xxx");
            }
        </script>
    </header>

    <body>
        <h2> scheme </h2>
        <button type="button" onclick="firstClick()">Click Me!</button>
    </body>
</html>
```

#### Universal Links
需要服务器进行配置，可参考 [iOS9 Universal Links踩坑之旅，移动应用之deeplink唤醒app](https://www.jianshu.com/p/77b530f0c67b)

### JavaScriptCore
仅UIWebView可用

- web 端实现

```html
<html>
    <header>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <script type="text/javascript">
        function secondClick() {
            // 调用native定义的方法
            nativeShare('分享的标题','分享的内容','图片地址');
        }
        </script>
    </header>

    <body>
        <h2> JSCore </h2>
        <button type="button" onclick="secondClick()">Click Me!</button>
    </body>
</html>
```

- iOS 端实现

```objc
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    // 暴露给 web 调用的原生方法 nativeShare
    context[@"nativeShare"] = ^() {
        NSArray *args = [JSContext currentArguments];
        for (JSValue *val in args) {
            NSLog(val.toString);
        }
    };
}
```

### WKWebView
- Web 端实现

```javascript
function btnClick() {
    // window.webkit.messageHandlers.方法名.postMessage(传参数);
    window.webkit.messageHandlers.nativeShare.postMessage('params');
}
```

- iOS 端实现

```objc
// 监听web方法
- (void)setupScriptHandler{
    [self.wkWebView.configuration.userContentController addScriptMessageHandler:self name:@"nativeShare"];
}

// 执行 web 调用 native
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"nativeShare"]) {
        // web传递过来的参数
        NSLog(message.body);
        
        // objc 执行 web 方法
        [self.wkWebView evaluateJavaScript:@"alert(\"分享成功\")" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            // web callback
        }];
    }
}
```

### WebViewJavascriptBridge
抹平UIWebView、WKWebView差异
[WebViewJavascriptBridge](https://github.com/marcuswestin/WebViewJavascriptBridge)


## 移动端调试 webview
单纯在pc端使用手机视图模式，有时并不能保证其在 **移动端浏览器/App** 有一致的表现，那么要怎么调试呢？
### 准备工作
需要对Mac/iOS端Safari进行简单的设置

- Mac Safari

![mac_safari_open_develop_menu.png](https://i.loli.net/2020/02/06/k3bYZFnBpm1Xciy.png)

- iOS Safari

![ios_safari_webcheck.jpeg](https://i.loli.net/2020/02/06/rVK2JiMbkPIwLze.jpg)

### 开始调试
调试分两种情况，web页是跑在 Safari 中还是 App 中的，但无论如何都需要先把手机和电脑连接起来（无线连接跟局域网复杂程度有关，有的时候连不上，在家里还行，在公司就别了）。

#### 在 Safari 中打开的 web 页
比如，在手机端Safari打开 https://www.baidu.com，会看到Mac端的Safari-开发-手机-多了如下图的选项

![safari_debug_select_iphone.png](https://i.loli.net/2020/02/06/yMapXoij9VldmPk.png)

打开后可以看到下图弹出一个常见的web检查器工具，大部分操作点我相信你们比我熟悉，在这里就提几个小技巧吧：

1. 图中红色框的工具，点击后（呈现蓝色状态的瞄准镜），可以直接在手机上点击web元素来触发选中
2. 当鼠标滑过web元素（如绿色框的代码）的时候可以看到手机端也会有对应的元素框标识
3. 选中的web元素/代码/执行后的代码，后面会有` = $* (* = 0、1、2.....)`，可以直接的控制台使用它

![safari_debug_baidu.png](https://i.loli.net/2020/02/06/aUjNvmxLQP7d8pK.png)


#### 在 App 中打开的 web 页
首先，需要确认你手机的App是通过开发的同学 **使用Xcode直接Debug Run**出来的（扫码分发下载的不支持），或者**模拟器使用拖进去的包**也可（但记得给检查一下模拟器的Safari的网页检查器是否打开）

![safari_debug_app_webview.png](https://i.loli.net/2020/02/06/fMlA2cbz6OkeL3B.png)


#### 使用web内嵌工具
web开发者也可以直接在web项目中内嵌一个开发工具，比如：

- [vConsole](https://github.com/Tencent/vConsole)

![](https://github.com/Tencent/vConsole/blob/dev/example/snapshot/log_panel.png)


- [eruda](https://github.com/liriliri/eruda)

![](https://github.com/liriliri/eruda/raw/master/doc/screenshot.jpg)


> 一些资料

[human-interface-guidelines](https://developer.apple.com/design/human-interface-guidelines/)

[WWDC-Videos](https://developer.apple.com/videos/)

[iOS Programming Tricks](https://codeingwithios.blogspot.com/2017/09/ios-layered-architecture.html)

[一份走心的JS-Native交互电子书.pdf](https://github.com/awesome-tips/iOS-Tips/blob/master/resources/%E4%B8%80%E4%BB%BD%E8%B5%B0%E5%BF%83%E7%9A%84JS-Native%E4%BA%A4%E4%BA%92%E7%94%B5%E5%AD%90%E4%B9%A6.pdf)

[Websites for iPhoneX](https://webkit.org/blog/7929/designing-websites-for-iphone-x/)

[DarkMode in Webkit](https://webkit.org/blog/8840/dark-mode-support-in-webkit/)



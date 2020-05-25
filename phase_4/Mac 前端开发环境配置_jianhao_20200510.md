# Mac 前端开发环境从零配置
> Mac 电脑由于其 MacOS 系统、触摸板、体积等一系列原因在程序员中广受欢迎，在这里就简单分享下前端工程师的 Mac 开发使用技巧。
## 一、mac 基础技巧

<a name="mdFt0"></a>
### 1. mac常用快捷键

```js
Mac 和 Windows 按键对应关系
control             ctrl
option              Alt
command             功能键，即苹果键

// 访达
Command + Shift + 3                // 截取全屏到桌面
Command + Shift + 4                // 截取所选区域到桌面
Command + Shift + N                // 新建文件夹
Command + Shift + .                // 显示/隐藏 隐藏文件
Command + Shift + G                // 调出窗口，可输入绝对路径直达文件夹
Command +  C                       // 复制文件
Command +  V                       // 粘贴文件
Command + Option + V               // 剪切文件，需要先复制文件
Command + Option + C               // 复制选中文件的路径

// 浏览器
Command + L                        // 光标直接跳至地址栏
Command + T                        // 打开一个新标签页
Command + 数字键 N                  // 切换到第 N 个标签页
Command + '+-'                     // 放大/缩小页面
Command + 左右箭头                  // 返回上一页或者下一页
Control + Tab                      // 转向下一个标签页
Control + Shift + Tab              // 转向上一个标签页

// 应用程序
Command + H                        // 隐藏非全屏的应用程序
Command + W                        // 关闭当前应用窗口
Command + Q                        // 完全退出当前应用
Command + N                        // 新建当前应用窗口
Command + ,                        // 打开当前应用的偏好设置
Command + 空格											// 打开聚焦搜索
Command + Option + esc             // 打开强制退出的窗口
Command + control + F              // 应用全屏
Command + control + 空格            // 打开表情符号选择界面

// 其他
Command + control + Q              // 锁定屏幕
option  + 空格											// 打开你安装的UTools

```
更多快捷键[参考](https://support.apple.com/zh-cn/HT201236)
<a name="x69Ks"></a>
### 2. mac自定义快捷键

1. 打开mac系统自带的 自动操作.app - 快速操作 - 选取 
2. 在左边操作搜索框选择一项，比如开启应用程序，双击，在右侧开启应用程序下拉框选择一个应用
3. Command + S 保存，并为该操作取个名字，存储
4. **系统偏好设置-键盘-快捷键-服务-通用**，这里可以你添加的快速操作，然后点击右边添加快捷键


<a name="ZV9A0"></a>
### 3. mac 手势
mac的触控板绝对是很多人选择mac的一个重要原因，通过手势和快捷键可以完全替代鼠标，并且非常丝滑，常用的[手势参考](https://support.apple.com/zh-cn/HT204895)，也可以通过应用**偏好设置-触控板**来自定义手势动作。<br />

<a name="FdPG4"></a>
### 4. 触发角
有时需要快速打开启动台、调度中心、应用程序窗口，可以使用快捷键做到，也可以设为mac的触发角动作。打开**系统偏好设置-桌面与屏幕保护程序-屏幕保护程序-触发角**，就可以设置触发角动作，比如左上角鼠标划过就打开控制台，右下角划过就锁定屏幕，非常便捷。
![触发角](http://pic.jianhunxia.com/imgs/chufajiao20200507094905.png)

<a name="jH1Iz"></a>
### 5. 迁移助理
有时候我们换了一台新mac时，需要将原来电脑上的资料、环境和软件迁移到新mac，这时[迁移助理](https://support.apple.com/zh-cn/HT204350)就派上用场了，它可以将你的所有文稿、应用、用户帐户和设置从一台电脑拷贝到另一台新 Mac 上。类似的还有[时间机器](https://support.apple.com/zh-cn/HT201250)，可以备份你的mac的文件。

<a name="OAxcM"></a>
### 6. **屏幕录制和截图**
mac 自带屏幕录制和截图工具，首先是 QuickTime player 这个软件，可以很方便地用来录制屏幕，Command + Shift + 5 打开提供截图工具，同时也可以录制屏幕。<br />
<br />如果使用 iOS 设备还可以在 usb 连接 mac 后，通过 QuickTime player  进行投屏/录制，新建影片录制 - 展开录制选项 - 选择你的 iOS 设备（需先解锁）

<a name="zT378"></a>
### 7. 钥匙串访问中的WiFi密码
有时候忘了访问过的 wifi 密码，这时候就可以通过钥匙串访问查看密码。**Command + 空格**打开聚焦搜索，搜索钥匙串访问并打开，选择**系统，**找到你想要查看的 wifi 账号，双击打开，勾选显示密码即可看到 wifi 密码。

<a name="MMS7a"></a>
### 8. 自定义Launchpad图标
MacLaunchpad里面系统默认的应用程序图标大小无法自定义，但是可以设置每行每列放几个图标，方法如下：
```js
defaults write com.apple.dock springboard-rows -int 6					// 设置每页六行
defaults write com.apple.dock springboard-columns -int 8			    // 设置每页八列
killall Dock															// 关闭dock才能生效
```

### 参考资料

- [Mac系统常用快捷键大全](https://www.jianshu.com/p/e86c35294d05)
- [如何将内容移至新 Mac](https://support.apple.com/zh-cn/HT204350)
- [使用“时间机器”备份您的 Mac](https://support.apple.com/zh-cn/HT201250)


## 二、环境与命令

### 1. shell环境
> 一个干净纯粹shell界面会让人心情非常舒畅，工作效率也会提高，所以**iTerm2 + Oh My Zsh** 闪亮登场打造舒适终端体验，这里我为大家找了两篇十分靠谱的教程：[终极shell](https://www.cnblogs.com/dhcn/p/11666845.html)、[打造舒适终端体验](https://segmentfault.com/a/1190000014992947)，只需要按部就班去设置即可，效果图如下：

![myzsh](http://pic.jianhunxia.com/imgs/myzsh20200508.png)
### 2. node环境
> 对于前端工程师，node环境必不可少，一般直接安装nodejs即可，我这里使用nvm来管理node版本，所以就介绍下nvm的安装使用。

#### 1、安装 nvm
参考这篇[博客](https://www.cnblogs.com/kaiye/p/4937191.html)，如果出现下载失败的问题，将 wifi 换成手机热点试试。


#### 2、nvm使用
```js
1. 查看下当前可用的node版本
$ nvm ls或者nvm list 

2. 选择合适的版本安装
nvm install 10.15.3          // 安装指定版本的node，会自动切换到该版本
nvm install node             // 安装最新稳定版本的node（即current版本）

3. 查看安装是否成功
$ node -v 

4. 更多nvm命令参考
nvm ls-remote                // 查看服务器上的node的所有可用版本
nvm uninstall 10.15.3        // 卸载某个版本的node
nvm use 10.15.3              // 切换到某个版本的node
nvm alias LTS 10.15.3        // 给某个版本起个别名
nvm unalias LTS              // 取消别名
```
#### 3、设置默认node版本
安装后要为shell设置一个默认node版本，不然每次打开都要use。
```js
nvm alias default 10.15.3 或者 LTS    // 因为我为10.15.3设置了别名，所以用别名和版本都可以
```


### 3. Git环境
> 作为一个搬砖的，掌握基本的搬砖工具 Git 是必要的，可以通过命令行来操作，也可以通过可视化工具操作，这里我们简单介绍下。

#### 1. 安装 GIt
可以通过[官网下载](https://git-scm.com/download/mac)安装或者通过brew来安装，通过brew安装的话命令如下：
```js
如果没有安装 homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

安装 Git
brew install git
```


#### 2. 配置基础信息和 SSH
Git是分布式版本控制系统，所以，每个机器都必须自报家门：你的名字和Email地址，加了--global即全局设置。 
```js
$ git config --global user.name "jianhao"                       // 设置用户名
$ git config --global user.email "jianXXXia@163.com"           // 设置邮箱
```
因为GitHub需要识别出你推送的提交确实是你推送的，而不是别人冒充的，而Git支持SSH协议，所以，GitHub只要知道了你的公钥，就可以确认只有你才能推送。 如果一台电脑分别往自己的 GitHub 和公司的 GitLab 推送代码的话，可以设置不同的公钥。
```js
1、先在本地生成秘钥，如果关联多个github账号就生成多个秘钥
ssh-keygen -t rsa -C "jianXXX@163.com" -f ~/.ssh/id_rsa
ssh-keygen -t rsa -C "jianXXX@163.com" -f ~/.ssh/id_rsa_my
一路回车，使用默认值，成功后在用户主目录下找到.ssh目录，里面有id_rsa和id_rsa.pub两个文件，这两个就是SSH Key的秘钥对，id_rsa是私钥，不能泄露出去，id_rsa.pub
是公钥，可以放心地告诉任何人。

open ～/.ssh             // 就会自动打开ssh所在目录

2、然后配置config文件 
touch config       // 没有config文件可以在ssh目录下执行此命令生成

// config文件配置如下：
#gitlab one 买好车
Host git.dXXX.net 				# 这里名称可以随意取，和下面那个Host的不一样就行
HostName git.XXXu.net  		    # 公司 gitlab 的域名
User git
IdentityFile ~/.ssh/id_rsa

#github two
Host github.com
HostName github.com
#Port 7999
User git
IdentityFile ~/.ssh/id_rsa_my

3、去对应的网站上配置下对应的公钥
```
#### 
#### 3. Git 命令缩写
```js
上面配置了 oh-my-zsh,所以可以使用 git 命令缩写来操作，缩写配置文件目录如下：
~/.oh-my-zsh/plugins/git/.git.plugin.zsh

基础的缩写命令如下：
alias | grep 'git'                    // 查看所有git命令别名
ga     git add                        // 添加到暂存区
gaa    git add -all                   // 添加所有改变到暂存区
gst    git status                     // 查看当前仓库状态
gss    git status --short(-s)         // 更紧凑地查看状态
gsb    git status --short --branch(-sb) // 把分支也显示出来
gcam   git commit -a -m                 // 提交所有已经跟踪的文件并输入msg
gcmam   git commit --amend -a -m        // 使用一次新的commit，替代上一次提交

gba    git branch -a                   // 查看所有分支
gbvv   git branch -vv                  // 查看本地分支和远程分支对应关系以及最后一个提交版本信息
gco    git checkout  [-切换到上一个分支]  // 切换分支
gcb    git checkout -b                 // 创建并切换到新分支
gbd/gbD    git branch -d/-D            // 删除分支/强制删除

grv    git remote -v                   // 查看所有远程仓库
gl     git pull <远程主机名> <远程分支名>:<本地分支名>       // 拉取远程分支并与本地分支合并
gp     git push <远程主机名> <远程分支名>:<本地分支名>       // 推送本地分支到远程仓库   
```

## 三、软件工具

> 以下是mac必备软件推荐，可能有些软件需要破解，这里推荐两个mac资源网站：[xclient](https://xclient.info/)、[macwk](https://www.macwk.com/)。

### 1. brew 和 brew cask
> brew是一款Mac OS平台下的软件包管理工具，拥有安装、卸载、更新、查看、搜索等很多实用的功能。brew 装的主要是 command line tool。brew cask装的大多是有gui界面的app以及[驱动](https://link.zhihu.com/?target=https%3A//github.com/caskroom/homebrew-drivers)，brew cask是brew的一个官方源。

```js
# 安装homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# 安装brew cask
brew tap caskroom/cask
```

可视化工具：Cakebrew
### 
### 2. chrome 浏览器
> chrome 浏览器是前端开发必不可少的软件，除此之外还有 Firefox 和 Safari 浏览器同样重要。

### 3. 搜狗输入法
> mac自带的输入法有时候难以满足用户的需求，这时候就需要一款适合自己的输入法了。类似的还有百度输入法、[清歌输入法](https://qingg.im/)。

### 4. VSCode
> 全宇宙最好用的编辑器，不接受辩驳，适合各种开发人员，尤其是前端，还有一些值得考虑的编辑器如 Atom、Sublime Text。

### 5. Office系列
> office办公软件也是必不可少，可选的有Microsoft office、wps、iwork 3件套。

### 6. 云笔记
> 云笔记有很多，各有优劣，这里推荐下有道云笔记和**Notion、Bear（云同步收费）。**

### 7. XMind
> 思维导图，很好的一种文档展现形式，需要自己破解，类似的更加轻巧的有MindNode （收费）、XMind zen。

### 8. CleanMyMacX
> mac的电脑管家，可以删除清理软件和各种垃圾，类似的还有App cleaner、Uninstaller。


### 9. Charles
> 好用的抓包工具，基本功能包括抓包、断点调试、请求替换、构造请求、代理功能。



### 10、SecureCRT for Mac
> SecureCRT是一款支持[SSH](https://baike.baidu.com/item/SSH)（SSH1和SSH2）的[终端仿真](https://baike.baidu.com/item/%E7%BB%88%E7%AB%AF%E4%BB%BF%E7%9C%9F/3441931)程序，k可以很方便地对linux主机进行管理。



### 11. Navicat Premium
> Navicat premium是一款数据库管理工具, 支持MySQL、SQLite、Oracle 及 PostgreSQL 资料库，类似的还有MongoDB数据库管理工具-Robo 3T、Redis数据库工具-Medis。



### 12. LICEcap
> 一款特别小巧简单的GIF录制工具，使用非常简单，[地址](https://www.cockos.com/licecap/)，类似的软件还有[gifbrewery](https://gfycat.com/gifbrewery)、[Gifox](https://gifox.io/)。

### 13. uTools
> uTools是一个极简、插件化、跨平台的现代桌面软件。通过自由选配丰富的插件，打造你得心应手的工具集合，类似的还有 [Alfred](https://www.alfredapp.com/)。

### 14.番茄钟
> 番茄钟工作法，工作记录神器


### 15.Postman
> Postman 是一款功能强大的发送 HTTP 请求的 工具 ，常用于web开发、接口测试，使用非常方便。


ps：如果安装的时候发现安装包已损坏，或者其他限制，可以打开mac的允许任何来源安装。
```bash
$ sudo spctl --master-disable
然后打开系统偏好设置-安全性与隐私-通用-允许所有源
```



## 四、其他技巧

### 1. VScode
> Vscode作为前端工程师当中最流行的编辑器，配置好开发工具能够大幅提高工作节奏流畅度和工作效率。

#### 1. 快捷键
Command + K & Command + S 打开快捷键绑定可以看到所有的快捷键，[常用快捷键参考](https://segmentfault.com/a/1190000009396435)。


#### 2. 扩展插件
这里只列举几个常用且重要的扩展插件：


```
- Settings Sync                                 同步 VSCode 配置到 github gists
- Git History                                   Git 历史查看对比
- Eslint                                        代码规范校验
- vscode-icons                                  Icon 插件
- View In Browser                               在浏览器打开文件
- One Dark Pro                                  高亮主题
- Reactjs code snippets                         React.js代码片段提示
- JavaScript (ES6) code snippets                JavaScript（ES6）代码片段提示
- HTML CSS Support                              HTML CSS 代码支持
```


更多插件根据需要自行选择添加
### 2. Chrome浏览器
> chrome浏览器作为前端开发必备浏览器，熟练掌握其快捷键和各种小技巧，再配置一些常用的扩展插件，可以让我们的开发体验显著提升，轻松搞定许多问题。

#### 1. Mac 下 chrome 快捷键
参考：[Mac 下 Chrome 快捷键大全](http://www.itdaan.com/blog/2012/08/23/60453939492c3a3337331778f0f2199f.html)


#### 2. Google账号
首先去注册一个 Google 账号，这样在浏览器上登录以后，会自动同步你对 Chrome 浏览器的配置，可以非常方便地在不同电脑同步 Chrome 浏览器配置。 Google账号注册需要 gmail 邮箱，无法科学上网的同学可以通过 QQ 邮箱或者网易邮箱大师来注册一个 gmail 邮箱。


#### 3. 扩展插件  


```
- AdBlock                           最佳广告拦截工具
- Eye Dropper                       颜色选取工具
- FeHelper                          JSON 自动格式化、手动格式化，支持排序、解码、下载...
- Google  翻译                       翻译网页
- Infinity                          新标签页主题自定义工具
- The Great Suspender               冻结暂时用不到的标签页，以便释放系统资源
- The QR Code Extension             将链接转为二维码，方便访问
- Wappalyzer                        分析当前网页用的技术
- 沙拉查词                           划词翻译工具
- Tampermonkey                      [油猴](https://sspai.com/post/40485)通过安装各类脚本对网站进行定制
- Toby for Chrome                   整理多个标签页，类似的还有 One Tab
- FeHelper                          JSON自动格式化、简易postman、时间戳转换...
```

同学们有更多技巧可以在下方留言~

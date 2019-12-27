# canvas 基础及实现贝塞尔曲线动画
在刚学习前端知识的时候，相信不少人会对 canvas 感兴趣。有的人偏向于用 canvas 实现酷炫的动画或者小游戏，有的人偏向于实现业务需求（分享页面转图片之类的），当然也有的人会有一些骚操作（将网页用 canvas 实现，传输数据加密，这样很难抓取数据）。  
也许你现在没有接触过 canvas，正好可以和我一起学习；也许你早就将 canvas 玩出了花，那更希望你能指教下。

## canvas 基础篇
### 1、canvas 样式设置
canvas 基于像素，默认设置的宽高是 300px/150px，和 img 标签表现很类似，用 CSS 设置宽高相当于改变这张图片的宽高缩放比；而用 JS 改变宽高，实际是设置 canvas 上的像素。如果 CSS 设置的宽高比和 JS 设置的宽高比不同，canvas 的图像就会变形。
```js
const cvs = document.getElementById("canvasId");
const ctx = cvs.getContext("2d");
let w = 600;
let h = 600;
cvs.width = w;
cvs.height = h; // canvas 画布实际由 600x600 的像素构成
cvs.style.width = '300px';
cvs.style.height = '300px'; // 在页面中实际显示的宽高只有 300x300
```

### 2、canvas 绘制
canvas 绘制的坐标原点（0, 0）在左上角，所有绘制的图形都依据这个坐标原点定位。  

#### canvas 基础绘制方式
canvas 绘制主要有两种方式，stroke（笔画）和 fill（填充），类似于 PS 上的“笔”和“油漆桶”。  
下面是两种绘制方式的具体使用：
+ 绘制线段，可以用线段拼成三角形、矩形等多边形。  
    ```js
    ctx.beginPath(); // 创建路径，绘制一个新的路径时，一定要 beginPath()
    ctx.moveTo(x, y); // 起始点
    ctx.lineTo(x1, y1); // 目标点
    ctx.closePath(); // 闭合路径
    ctx.stroke(); // 笔画绘制
    ctx.fill(); // 填充
    ```
    ```js
    ctx.beginPath;
    ctx.moveTo(10, 10);
    ctx.lineTo(10, 100);
    ctx.lineTo(100, 100);
    ctx.closePath(); // 会闭合上面的路径，最终形成一个三角形
    ctx.stroke();
    ```
    stroke() 和 fill() 在只有两个坐标不同点时，都是绘制一条线段；如果有 3 个或更多的坐标不同点时，stroke() 绘制的依然是线，而 fill() 会填充内容。
    示例：  
    <img src="https://jinjiting.github.io/gob/mhcmb/issue1/1.png" width="105" height="60"/>  

+ 绘制矩形。
    ```js
    // 绘制边框矩形
    ctx.strokeRect(x, y, width, height);

    // 绘制填充矩形
    ctx.fillRect(x, y, width, height);

    // x、y：起点坐标，width、height：矩形宽高
    ```
    示例：  
    <img src="https://jinjiting.github.io/gob/mhcmb/issue1/2.png" width="124" height="130"/>  
+ 绘制圆、圆弧、弧形。
    ```js
    ctx.arc(x, y, r, start, end, bol);
    // x、y 为圆心坐标，r 为半径，start 为开始弧度，end 为结束弧度，bol：true 表示逆时针，false 表示顺时针（默认）

    ctx.arcTo(x1, y1, x2, y2, r);
    // x1、y1、x2、y2，两个控制点的坐标
    ```
    ```js
    for(let i = 1; i <= 4; i++) {
      for(let j = 1; j <= 4; j++) {
        let bol = j > 2;
        let bol1 = j % 2 !== 0; 
        ctx.beginPath();
        ctx.arc(50 * i, 50 * j , 20, 0, Math.PI / 2 * i, bol);
        bol1 ? ctx.stroke() : ctx.fill();
      }
    }
    ```
    示例：  
    <img src="https://jinjiting.github.io/gob/mhcmb/issue1/3.png" width="227" height="227"/> 

+ 绘制文本。
    ```js
    ctx.strokeText(text, x, y, max);
    ctx.fillText(text, x, y, max);

    // text：绘制文本，x、y：绘制文本的左上角点坐标，max：文本最大长度（可选）
    ```
+ 绘制样式。上面的绘制样式都是基础的默认样式，我们再来看下调整样式的方法：
    - setLineDash() 和 lineDashOffset：调整线段的样式。
      ```js
      ctx.setLineDash([length1, length2]); // length1：实线长度，length2：间隔长度
      ctx.lineDashOffset = length3; // length3：起始偏移长度


      ctx.setLineDash([10, 4]);
      ctx.lineWidth = 4;
      for(let i = 1; i < 4; i++) {
        ctx.beginPath();
        ctx.lineDashOffset = -4 + i * 2;
        ctx.moveTo(50, 40 * i);
        ctx.lineTo(250, 40 * i);
        ctx.stroke();
      }
      ```
      示例：  
      <img src="https://jinjiting.github.io/gob/mhcmb/issue1/4.png" width="237" height="124"/>  

    - lineWidth：调整基础的线宽。
    - lineCap：调整线段两端的样式。
      ```js
      ctx.lineCap = type;
      /* 
       * type：butt | round | square
       * butt：两端矩形
       * round：两端圆形，以线宽的一半为半径绘制半圆
       * square：两端矩形，以线宽的一半为宽绘制矩形
       * butt 这个属性实际表现为 none，不会在线两端添加样式；round 和 square 都是在线两端添加样式
       */
      ```
    - lineJoin：调整线段之间交接处的样式。
      ```js
      ctx.lineJoin = type;
      /* 
       * type：bevel | miter | round
       * bevel：交接处是三角形，类似于折纸
       * miter：交接处是菱形
       * round：交接处是圆形
       */
      ```
      示例：
      <img src="https://jinjiting.github.io/gob/mhcmb/issue1/5.png" width="170" height="78"/>  

    - strokeStyle 和 fillStyle：调整笔画和填充样式。
      ```js
      ctx.strokeStyle = color;
      ctx.fillStyle = color;

      // color 颜色值
      ```
    - font、textAlign、textBaseline、direction：分别调整文本的字体样式、对齐、基线和方向。（和 CSS 样式一致，这里就不做更多讨论了）
    - globalAlpha：调整 canvas 的透明度。

#### canvas 其他绘制方式
canvas 除了绘制基础的图形外，还能绘制图片、视频等，因为这里暂时没有用到，所以先不做讨论。

### 3、canvas 变形
+ translate：移动 canvas 坐标原点的位置
  ```js
  ctx.translate(x, y); // 将坐标原点由 (0, 0) 移到 (x, y)
  ```
+ rotate：旋转坐标轴
  ```js
  ctx.rotate(rad); // 坐标轴顺时针转动 rad 弧度
  ```
  （rad = Math.PI / 180 * 30：顺时针旋转 30 度角）
+ scale：缩放坐标轴
  ```js
  ctx.scale(x1, y1); // 坐标轴的 x、y 轴分别缩放
  ```
+ transform：矩阵变形（这个会涉及到线性代数的知识）
  ```js
  ctx.transform(a, b, c, d, e, f);
  ```

在上面的方法中，translate() 和 scale() 会有额外的用途，下面会讲到。

### 4、canvas 合成与裁剪
在绘制多个图形时，因为绘制顺序，可能会出现我们不想要的效果。当图形重叠时，就能用合成和裁剪实现额外的效果。
+ 合成
  ```js
  globalCompositeOperation = type;

  const type = [
    'source-over',      // 默认。在目标图像上显示源图像
    'source-atop',      // 在目标图像顶部显示源图像。源图像位于目标图像之外的部分是不可见的
    'source-in',        // 在目标图像中显示源图像。只有目标图像内的源图像部分会显示，目标图像是透明的
    'source-out',       // 在目标图像之外显示源图像。只会显示目标图像之外源图像部分，目标图像是透明的
    'destination-over', // 在源图像上方显示目标图像。
    'destination-atop', // 在源图像顶部显示目标图像。源图像之外的目标图像部分不会被显示
    'destination-in',   // 在源图像中显示目标图像。只有源图像内的目标图像部分会被显示，源图像是透明的
    'destination-out',  // 在源图像外显示目标图像。只有源图像外的目标图像部分会被显示，源图像是透明的
    'lighter',          // 显示源图像 + 目标图像
    'copy',             // 显示源图像。忽略目标图像
    'xor'               // 使用异或操作对源图像与目标图像进行组合
  ];
  ```
+ 裁剪
  ```js
  ctx.beginPath();
  ctx.arc(50, 50, 40, 0, Math.PI * 2);
  ctx.clip();
  ctx.fillRect(25, 25, 80, 80);
  ```
  示例：  
  <img src="https://jinjiting.github.io/gob/mhcmb/issue1/6.png" width="171" height="145"/>  

### 5、canvas 状态
当我们绘制多种类型不同的图形时，需要设置不同的样式，我们可以通过保存当前状态来避免反复设置样式。  
canvas 将所有的状态保存在栈中，每次调用 save() 方法就会将当前状态保存。当我们要释放这个状态时，执行 restore() 方法，canvas 的状态就会回到上一个状态。  
绘画状态如下：
+ 样式设置。
  - lineWidth, lineCap, lineJoin, miterLimit
  - strokeStyle, fillStyle
  - shadowOffsetX, shadowOffsetY, shadowBlur, shadowColor
  - globalAlpha, globalCompositeOperation
+ 变形：translate、rotate、scale
+ 裁切路径：clipping path

### 6、canvas 动画
接下来，我们讲下 canvas 的动画。动画常见的操作如下：
+ 用 clearRect() 清除 canvas 之前的绘制结果。例如，想要实现一个圆形的移动动画，肯定要清除之前绘制的圆形，否则看到的效果就是一连串的圆形。
+ 保存和恢复 canvas 状态。在动画开始前，应当保存一下当前的状态，避免在动画中更改状态后，引起其他图形的改变。动画结束后，应当恢复 canvas 的状态。
+ 实现动画。常用以下 3 个方法实现：
  - requestAnimationFrame()：推荐方法，根据浏览器的刷新频率来实现动画
  - setTimeout()
  - setInterval()

### canvas 常见问题
在使用上面的 API 练习的时候，肯定有不少人发现了 stroke() 绘制的图形有点问题。接下来，让我们聊聊 canvas 里你可能会遇到的问题。
#### stroke() 绘制线条变粗
用 stroke 的方式绘制矩形时，很容易发现 strokeRect() 绘制的矩形边框比默认的 1px 要宽。因为 stroke 的线以边框中心绘制，1px 的线条会被分为 0.5px 和 0.5px，浏览器不支持 0.5px 的绘制时，1px 的线会绘制为 2px 的宽度。  
解决的方式：
1. 既然 canvas 以线中心绘制，那么将绘制的起点以线中心为起点即可（最佳方式）。
   ```js
   ctx.moveTo(0.5, 0.5);
   ctx.lineTo(200.5, 200.5);
   // 上面的方法要每次画线都要额外计算，略麻烦，下面的移动坐标原点更快捷
   ctx.translate(0.5, 0.5);
   ```
2. 缩放 canvas，通过 css 缩小 canvas 的宽高。
3. 用 stroke 绘制矩形时，可以在里面用 fillRect() 填充背景色，但是线的颜色透明度会降一半。

#### canvas 在高清屏下变模糊的问题
canvas 画布在高清屏下（一个像素由多个像素点来渲染），以原来的像素点显示就会被放大。  
出现场景：用 echarts 库在移动端使用 canvas 图表。
解决方案：获取设备像素比，使用 js 修改相应的高度和缩放高度。
```js
const dpr = window.devicePixelRatio;
const cvs = document.getElementById("id");
const ctx = cvs.getContext("2d");
const w = 100;
const h = 100;
cvs.style.width = w + 'px';
cvs.style.height = h + 'px';
cvs.width = w * dpr;
cvs.height = h * dpr;
ctx.scale(dpr, dpr);
```

#### canvas 引用图片时的跨域问题
canvas 引用外部图片时，就可能会出现跨域问题。  
出现场景：使用 html2canvas 库将带有外部图片的 html 页通过 canvas 转为图片。
解决方案：
```js
const img = new Image();
const url = '图片 url';
img.crossOrigin = "";
img.src = `${url}?time=${new Date().valueOf()}`;
```

### canvas 性能优化
canvas 做游戏或者一些复杂的效果时，需要对性能进行一些优化。下面稍微了解下，可以做到的性能优化方案。
1. 分层 canvas：分离需要经常更新的图层和不经常更新的图层。
2. 过滤视野之外的绘制。
3. 将精灵图上需要裁剪绘制的图片提前裁剪。

## 实现贝塞尔曲线动画
下面，我们先来了解下 canvas 中的贝塞尔曲线，再用基础知识来实现贝塞尔曲线动画。

### canvas 的贝塞尔曲线
贝塞尔曲线是计算机图形学中相当重要的参数曲线，在 canvas 中有二次贝塞尔曲线和三次贝塞尔曲线的实现：
```js
// 二次贝塞尔曲线 quadraticCurveTo(cx, cy, x, y); 
ctx.beginPath();
ctx.moveTo(0, 0); //起始点
ctx.quadraticCurveTo(cx, cy, x, y);// cx、cy 是控制点的坐标，x、y 是终点坐标
ctx.stroke();

// 三次贝塞尔曲线 bezierCurveTo(cx1, cy1, cx2, cy2, x, y);
ctx.beginPath();
ctx.moveTo(0, 0); //起始点
ctx.bezierCurveTo(cx1, cy1, cx2, cy2, x, y); // cx1、cy1、cx2、cy2 是控制点的坐标，x、y 是终点坐标
ctx.stroke();
```

### 贝塞尔曲线实现原理
以二次贝塞尔曲线为例：在平面上确定不在同一直线的3个点，D0、D1、D2，在 D0D1 上任取一点 D3，在 D1D2 上任取一点 D4，使得 D0D3/D0D1 = D1D4/D1D2，然后连接 D3D4，按照相同的比例，在 D3D4 确定一个点，这个点的移动轨迹就是贝塞尔曲线。（听起来很熟悉？没错，大概就是初中数学题）  
其中，D0、D2 是数据点，D1 是控制点。还不理解的同学，可以看下面这张图：  
<img src="https://jinjiting.github.io/gob/mhcmb/issue1/bezier0.png" width="278" height="278"/>  
搞清楚二阶的贝塞尔曲线，那么三阶、四阶都能理解了，无非就是在前一阶贝塞尔曲线上递增。

#### 实现贝塞尔曲线运动动画
首先，讲下我的实现思路：
1. 将 canvas 分为3层：
   + 第一层渲染初始的点和线，避免重复调用初始化函数；
   + 第二层渲染所有移动的点和线，调用 clearRect() 来清除原来的绘制的路径；
   + 第三层用来渲染贝塞尔曲线。
2. 初始点 dots 数组，比例 ratio。根据 dots 和 ratio 获取第一层运动点 moving_dots[1] 数组，第二层运动点 moving_dots[2] 在 moving_dots[1] 的基础上获取。依次类推，当移动的同级的点只剩下2个时，在这条线上确定最后的贝塞尔曲线运动点。

下面上主要源码：

```js
const dots = [{ x: 25, y: 125 }, { x: 150, y: 50 }, { x: 250, y: 250 }];
const l = dots.length;
const colors = ['red', 'gold', 'skyblue', 'lime'];
let initialTexts = [];
let ratio = 0;
let distance = 0;
let moving_dots = [];
moving_dots[0] = dots;
function getMovingDots() {
  let depth = l - 1;
  let texts = initialTexts;
  let num = l;
  if(depth == 1) {
    return paintBezier(moving_dots[0]);
  }
  for(let i = 1; i < l - 1; i++) { // 用二维数组记录点坐标
    moving_dots[i] = [];
    for(let j = 0; j < depth; j++) {
      moving_dots[i].push(getDotPosition(moving_dots[i - 1][j], moving_dots[i - 1][j + 1], ratio));//getDotPosition() 获取点坐标的函数
      paintDot(ctx, { 
        x: moving_dots[i][j].x, 
        y: moving_dots[i][j].y, 
        color: colors[l - depth], 
      });
      texts.push(`D${num}`);
      paintText(ctx, texts[num], { x: moving_dots[i][j].x, y: moving_dots[i][j].y });
      num++;
    }
    for(let j = 0, len = moving_dots[i].length; j < len - 1; j++) {
      paintLine(ctx, {
        start: moving_dots[i][j], 
        end: moving_dots[i][j + 1], 
        size: 2, 
        color: colors[l - depth],
      });
    }
    if(depth == 2) {
      paintBezier(moving_dots[i]);
    }
    depth--;
  }
}
function move() {
  if(ratio >= 1) return;
  ctx.clearRect(0, 0, w, h);
  getMovingDots();
  ratio += 0.002;
  window.requestAnimationFrame(move);
}
```

## 总结
好了，以上就是我对 canvas 基础用法的总结，以及基于 canvas 基础实现的贝塞尔曲线动画，希望大家能有所收获！（如果文中有什么错误的地方，请大家积极指正。）
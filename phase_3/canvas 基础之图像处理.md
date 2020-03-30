# canvas 基础之图像处理
前些日子，前辈推荐了一个有趣的项目 —— [Real-Time-Person-Removal](https://github.com/jasonmayes/Real-Time-Person-Removal)，这个项目使用了 TensorFlow.js(https://www.tensorflow.org/)，以及 canvas 中的图像处理实现视频中的人物消失。借此机会，复习下 canvas 基础中的图像处理。

## 基础 API
canvas 的图像处理能力通过 ImageData 对象来处理像素数据。主要的 API 如下：
+ createImageData()：创建一个空白的 ImageData 对象
+ getImageData()：获取画布像素数据，每一个像素点有 4 个值 —— rgba
+ putImageData()：将像素数据写入画布

```js
imageData = {
  width: Number,
  height: Number,
  data: Uint8ClampedArray
}
```
width 是 canvas 画布的宽或者说 x 轴的像素数量；height 是画布的高或者说 y 轴的像素数量；data 是画布的像素数据数组，总长度 w * h * 4，每 4 个值（rgba）代表一个像素。

## 对图片的处理
下面，我们通过几个例子来看下 canvas 基础的图片处理能力。  
原图效果：
<img src="https://jinjiting.github.io/gob/mhcmb/issue3/origin.jpg" alt="原图效果">

```js
const cvs = document.getElementById("canvas");
const ctx = cvs.getContext("2d");
const img = new Image();
img.src="图片 URL";
img.onload = function () {
  ctx.drawImage(img, 0, 0, w, h);
}
```

### 底片/负片效果
算法：将 255 与像素点的 rgb 的差，作为当前值。
```js
function negative(x) {
  let y = 255 - x;
  return y;
}
```
效果图：  
<img src="https://jinjiting.github.io/gob/mhcmb/issue3/negative.jpg" alt="负片效果">

```js
const imageData =  ctx.getImageData(0, 0, w, h);
const { data } = imageData;
let l = data.length;
for(let i = 0; i < l; i+=4) {
  const r = data[i];
  const g = data[i + 1];
  const b = data[i + 2];
  data[i] = negative(r);
  data[i + 1] = negative(g);
  data[i + 2] = negative(b);
}
ctx.putImageData(imageData, 0, 0);
```
### 单色效果
单色效果就是保留当前像素的 rgb 3个值中的一个，去除其他色值。
```js
for(let i = 0; i < l; i+=4) { // 去除了 r 、g 的值
  data[i] = 0;
  data[i + 1] = 0;
}
```
效果图：  
<img src="https://jinjiting.github.io/gob/mhcmb/issue3/blue.jpg" alt="单色效果">

### 灰度图
灰度图：每个像素只有一个色值的图像。0 到 255 的色值，颜色由黑变白。  
```js
for(let i = 0; i < l; i+=4) {
  const r = data[i];
  const g = data[i + 1];
  const b = data[i + 2];
  const gray = grayFn(r, g, b);
  data[i] = gray;
  data[i + 1] = gray;
  data[i + 2] = gray;
}
```

+ 算法1——平均法：
  ```js
  const gray = (r + g + b) / 3;
  ```
效果图：  
<img src="https://jinjiting.github.io/gob/mhcmb/issue3/gray1.jpg" alt="灰度效果1">

+ 算法2——人眼感知：根据人眼对红绿蓝三色的感知程度：绿 > 红 > 蓝，给定权重划分
  ```js
  const gray = r * 0.3 + g * 0.59 + b * 0.11
  ```
效果图：  
<img src="https://jinjiting.github.io/gob/mhcmb/issue3/gray2.jpg" alt="灰度效果2">

除此以外，还有：
+ 取最大值或最小值。
```js
const grayMax = Math.max(r, g, b); // 值偏大，较亮
const grayMin = Math.min(r, g, b); // 值偏小，较暗
```
+ 取单一通道，即 rgb 3个值中的一个。

### 二值图
算法：确定一个色值，比较当前的 rgb 值，大于这个值显示黑色，否则显示白色。  
```js
for(let i = 0; i < l; i+=4) {
  const r = data[i];
  const g = data[i + 1];
  const b = data[i + 2];
  const gray = gray1(r, g, b);
  const binary = gray > 126 ? 255 : 0;
  data[i] = binary;
  data[i + 1] = binary;
  data[i + 2] = binary;
}
```
效果图：  
<img src="https://jinjiting.github.io/gob/mhcmb/issue3/binary.jpg" alt="二值化">

### 高斯模糊
高斯模糊是“模糊”算法中的一种，每个像素的值都是周围相邻像素值的加权平均。原始像素的值有最大的高斯分布值（有最大的权重），相邻像素随着距离原始像素越来越远，权重也越来越小。  
一阶公式：  
<img src="https://jinjiting.github.io/gob/mhcmb/issue3/1.svg" alt="高斯模糊公式">  

（使用一阶公式是因为一阶公式的算法比较简单）

```js
const radius = 5; // 模糊半径
const weightMatrix = generateWeightMatrix(radius); // 权重矩阵
for(let y = 0; y < h; y++) {
  for(let x = 0; x < w; x++) {
    let [r, g, b] = [0, 0, 0];
    let sum = 0;
    let k = (y * w + x) * 4;
    for(let i = -radius; i <= radius; i++) {
      let x1 = x + i;
      if(x1 >= 0 && x1 < w) {
      let j = (y * w + x1) * 4;
      r += data[j] * weightMatrix[i + radius];
      g += data[j + 1] * weightMatrix[i + radius];
      b += data[j + 2] * weightMatrix[i + radius];
      sum += weightMatrix[i + radius];
      }
    }
    data[k] = r / sum;
    data[k + 1] = g / sum;
    data[k + 2] = b / sum;
  }
}
for(let x = 0; x < w; x++) {
  for(let y = 0; y < h; y++) {
    let [r, g, b] = [0, 0, 0];
    let sum = 0;
    let k = (y * w + x) * 4;
    for(let i = -radius; i <= radius; i++) {
      let y1 = y + i;
      if(y1 >= 0 && y1 < h) {
        let j = (y1 * w + x) * 4;
        r += data[j] * weightMatrix[i + radius];
        g += data[j + 1] * weightMatrix[i + radius];
        b += data[j + 2] * weightMatrix[i + radius];
        sum += weightMatrix[i + radius];
      }
    }
    data[k] = r / sum;
    data[k + 1] = g / sum;
    data[k + 2] = b / sum;
  }
}
function generateWeightMatrix(radius = 1, sigma) { // sigma 正态分布的标准偏差
  const a = 1 / (Math.sqrt(2 * Math.PI) * sigma);
  const b = - 1 / (2 * Math.pow(sigma, 2));
  let weight, weightSum = 0, weightMatrix = [];
  for (let i = -radius; i <= radius; i++){
    weight = a * Math.exp(b * Math.pow(i, 2));
    weightMatrix.push(weight);
    weightSum += weight;
  }
  return weightMatrix.map(item => item / weightSum); // 归一处理
}
```

效果图：  
<img src="https://jinjiting.github.io/gob/mhcmb/issue3/blur.jpg" alt="模糊效果">

### 其他效果
这里再简单介绍下其他的图像效果处理，因为例子简单重复，所以不再给出代码和效果图。
+ 亮度调整：将 rgb 值，分别加上一个给定值。
+ 透明化处理：改变 rgba 值中的 a 值。
+ 对比度增强：将 rgb 值分别乘以 2，然后再减去一个给定值。

## 总结
好了，上面就是一些基础的图像处理算法。

### 参考资料
[高斯模糊的算法](http://www.ruanyifeng.com/blog/2012/11/gaussian_blur.html)
[高斯模糊](https://zh.wikipedia.org/wiki/%E9%AB%98%E6%96%AF%E6%A8%A1%E7%B3%8A)
## 0. 效果

![](https://user-gold-cdn.xitu.io/2020/7/3/173134a47c00c735?w=1920&h=1290&f=jpeg&s=362315)

![](https://user-gold-cdn.xitu.io/2020/7/3/173134a6a9d70112?w=1920&h=1290&f=jpeg&s=1646478)

## 1. 实现原理

### 1.1 RGB转灰度值

首先，我们知道在OpenGL中颜色有4个通道RGBA，对于一般图片$A=1.0$。那还有3个通道需要处理，RGB。

而我们的字符画使用1个字符表示1块颜色，即我们需要将RGB三个通道进行某种处理(3个值)，让它们变为1个值，我们才能对应某1个字符。

上面所说的某种处理就是：**RGB值转换为灰度值**。

![](https://user-gold-cdn.xitu.io/2020/7/3/173142446992b2b7?w=640&h=403&f=png&s=397967)

这个部分我们可以通过shader进行转换，shader来自**GPUImageGrayscaleFilter**：

```glsl
precision highp float;
varying vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);
void main()
{
   lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
   float luminance = dot(textureColor.rgb, W);
   gl_FragColor = vec4(vec3(luminance), textureColor.a);
}
```

通过上面的处理，我们就把RGB值转换为了灰度值，或者shader中的**luminance**(亮度值)。

> 此时，RGB值均等于luminance。(后面直接使用RGB中任何一个值即可)



### 1.2 灰度值转字符

现在的灰度值范围为$[0,1.0]$，我们将其量化为15个等级。

> 等级细分可根据需求自己确定。

由低到高为$[0, 1/15, 2/15,...,1.0]$：

![](https://user-gold-cdn.xitu.io/2020/7/3/173142a29af061c8?w=300&h=20&f=png&s=4008)

> 图中文字可自行选择，保证其在图中黑白占比接近对应的等级即可。



### 1.3 灰度图尺寸转换

如果我们使用一个像素表示一个字符，肯定是看不出字符的形状的，所以一般采用多个像素点表示一个字符的形式来进行显示。所以未转换成字符的时候，用多个点表示一个灰度，就会得到下面这张马赛克风格的图。

![result_9](/Users/ycpeng/Downloads/result_9.png)

示例中，我采用了$10*10$的像素点来表示一个灰度值。$10*10$比较难画，下面我用$5*5$的像素点来解释。

![](https://user-gold-cdn.xitu.io/2020/7/3/17314375dc83a562?w=142&h=52&f=png&s=726)

如果用$5*5$的像素点来表示1个灰度值，我们需要用25个点的灰度值算一个平均，然后再用这个灰度值取填充25个像素格子。那如果我把图片的长和宽都缩小5倍，然后用灰度值来绘制，那么GPU会帮我们完成计算，而且现在我只需要1个格子。

![](https://user-gold-cdn.xitu.io/2020/7/3/173143c382639a7d?w=272&h=52&f=png&s=1120)

我们再来一个具体的例子，假设我有一张$1000*1000$的图，通过灰度shader和在0.1倍的frame buffer上进行绘制，就可以得到一个$100*100$的灰度图查询的纹理。

即，对于原始图中坐标$(x,y),x∈[0,9],y∈[0,9]$的这些像素点，只需要使用灰度图查询纹理$(0,0)$这一个像素点的灰度值即可。



#### 1.4 灰度值映射字符纹理

```glsl
varying highp vec2 textureCoordinate; // 纹理坐标
varying highp vec2 textureCoordinate2; // 纹理坐标(未用到)

uniform sampler2D inputImageTexture; //字符纹理
uniform sampler2D inputImageTexture2; // 灰度值参考纹理

uniform highp vec2 textureSize; // 原图尺寸

void main()
{
  // 像素点坐标
  highp vec2 coordinate = textureCoordinate * textureSize;

  // demo这里写死，可以根据实际情况调整
  highp float width = 10.0;
  // 计算width*width的区域的中点
  highp vec2 midCoor = min((floor(coordinate / width) * width + width * 0.5) / textureSize, 1.0);
  // 得到中点的灰度值
  lowp vec4 color = texture2D(inputImageTexture2, midCoor);
  // 一个字符的归一化纹理坐标
  coordinate = mod(coordinate, width) / width;
  // 为了节约性能，15个字符我们放在一个纹理上，需要根据灰度值进行x偏移
  coordinate.x = (floor(color.r * 14.0) + coordinate.x) / 15.0;

  gl_FragColor = texture2D(inputImageTexture, coordinate);
}
```

1. 我们根据纹理坐标和纹理的尺寸算出对应的像素点坐标。

2. 计算$width*width$的区域的中点，并得到中心点的灰度值。

   > 由于小尺寸的灰度纹理我们是分开得到的，不能保证一定满足我们上面提到的理想效果，所以采用了中心点的灰度值。

3. 我们用$width*width$的像素点表示一个字符，计算出对应字符的归一化纹理坐标。

4. 为了节约性能，由于15个字符纹理我们横向合并在一个纹理中，所以要根据灰度值进行偏移，灰度值选择对应的字符纹理。


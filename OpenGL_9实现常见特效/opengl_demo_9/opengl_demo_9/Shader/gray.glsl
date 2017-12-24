//灰度图
precision highp float;
uniform sampler2D image;
varying vec2 vTexcoord;
const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);

//灰度图像指的是每个像素只有一个采样颜色的图像。
//这类图像通常显示为从最暗黑色到最亮的白色的灰度，尽管理论上这个采样可以任何颜色的不同深浅，甚至可以是不同亮度上的不同颜色。
//灰度图像与黑白图像不同，在计算机图像领域中黑白图像只有黑白两种颜色，灰度图像在黑色与白色之间还有许多级的颜色深度。

//任何颜色都有红、绿、蓝三原色组成，假如原来某点的颜色为RGB(R，G，B)，那么，我们可以通过下面几种方法，将其转换为灰度：
//1.浮点算法：Gray=R*0.3+G*0.59+B*0.11
//2.整数方法：Gray=(R*30+G*59+B*11)/100
//3.移位方法：Gray =(R*76+G*151+B*28)>>8;
//4.平均值法：Gray=(R+G+B)/3;
//5.仅取绿色：Gray=G；
//通过上述任一种方法求得Gray后，将原来的RGB(R,G,B)中的R,G,B统一用Gray替换，形成新的颜色RGB(Gray,Gray,Gray)，用它替换原来的RGB(R,G,B)就是灰度图了。

void main()
{
    lowp vec4 textureColor = texture2D(image, vTexcoord);
//     利用向量的点乘 W  的 x，y，z 之和为1 ，相当于浮点运算
    float luminance = dot(textureColor.rgb, W);
    // RGB + alpha 
    gl_FragColor = vec4(vec3(luminance), textureColor.a);
}

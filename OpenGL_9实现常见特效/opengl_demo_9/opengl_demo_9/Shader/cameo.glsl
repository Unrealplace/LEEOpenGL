//浮雕效果
precision mediump float;
varying vec2 vTexcoord;
uniform sampler2D image;
const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);
const vec2 TexSize = vec2(100.0, 100.0);
const vec4 bkColor = vec4(0.5, 0.5, 0.5, 1.0);

//浮雕效果是指图像的前景前向凸出背景。
//实现思路：
//把图象的一个象素和左上方的象素进行求差运算，并加上一个灰度。
//这个灰度就是表示背景颜色。这里我们设置这个插值为128 (图象RGB的值是0-255)。
//同时,我们还应该把这两个颜色的差值转换为亮度信息，避免浮雕图像出现彩色像素。


void main()
{
    vec2 tex = vTexcoord;
    vec2 upLeftUV = vec2(tex.x-1.0/TexSize.x, tex.y-1.0/TexSize.y); //左上角的像素UV 坐标
    vec4 curColor = texture2D(image, vTexcoord); // 纹理像素颜色
    vec4 upLeftColor = texture2D(image, upLeftUV); // 左上角的纹理像素颜色
    vec4 delColor = curColor - upLeftColor; // 两个像素进行差值运算
    float luminance = dot(delColor.rgb, W); // 灰度运算
    gl_FragColor = vec4(vec3(luminance), 0.0) + bkColor; //整体价格灰度值
}

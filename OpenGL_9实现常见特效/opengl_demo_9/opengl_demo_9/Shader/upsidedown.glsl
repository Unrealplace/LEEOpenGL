precision mediump float;

varying vec2 vTexcoord;
uniform sampler2D image;

void main()
{
    // 将纹理图片映射到纹理坐标上对应， 下面这个功能是实现图片上下颠倒，貌似不能实现左右点反转。
    vec4 color = texture2D(image, vec2(vTexcoord.x, 1.0 - vTexcoord.y));
//     将转换的颜色赋值到片源着色器。
    gl_FragColor = color;
}

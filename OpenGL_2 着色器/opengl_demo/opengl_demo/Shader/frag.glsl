precision mediump float;

varying vec3 outColor;

void main()
{
    gl_FragColor = vec4(outColor, 2.0);
}
//着色器(Shader)是运行在GPU上的小程序。
//这些小程序为图形渲染管线的某个特定部分而运行。
//从基本意义上来说，着色器只是一种把输入转化为输出的程序。
//着色器也是一种非常独立的程序，因为它们之间不能相互通信；它们之间唯一的沟通只有通过输入和输出。


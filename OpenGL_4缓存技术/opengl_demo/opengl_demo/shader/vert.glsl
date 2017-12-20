
//创建OpenGL ES3.0相关的着色器。要想使用OpenGL ES3.0的新特性，必须要指定着色器的版本 #version 300 es 。
//如果不指定，则会按照2.0的版本处理，因此3.0的新特性比如in、out、layout等关键字会报错。
//我们通过layout(location = i)指定属性的位置，这样我们就可以不用调用glGetAttribLocation获取属性的位置了。
//至于编译、链接、创建着色器程序和以前2.0一样，所以不再特别指明。




#version 300 es

layout(location = 0) in vec3 position;
layout(location = 1) in vec3 color;

out vec3 outColor;

void main()
{
    gl_Position = vec4(position, 1.0);
    outColor = color;
}

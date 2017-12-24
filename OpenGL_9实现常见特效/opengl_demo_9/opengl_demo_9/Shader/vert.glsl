attribute vec3 position;
attribute vec2 texcoord;

//下面这个是纹理坐标，可以改变的，一般用来传入到片元着色器中进行改变
varying vec2 vTexcoord;

void main()
{
    gl_Position = vec4(position, 1.0);
    vTexcoord = texcoord;
}

precision mediump float;

uniform sampler2D image1;
uniform sampler2D image2;

varying vec2 vTexcoord;

//代数运算主要有：
//算术运算（加、 减、乘、除），逻辑运算（非、或、异或）。
//在图像处理中代数运算同样适用，但代数运算在图像处理中不仅仅是简单的数学运算，还有它的实际意义。


void main()
{
    // 加法 可以得到各种图像合成的效果，也可以用于 两张图片的衔接
        vec4 color1 = texture2D(image1, vTexcoord);
        vec4 color2 = texture2D(image2, vTexcoord);
        float alpha = 0.6;
        gl_FragColor = vec4(vec3(color1*(1.0 - alpha) + color2*alpha), 1.0);
    
    
    //非运算
//          vec4 color2 = texture2D(image2, vTexcoord);
//          gl_FragColor = vec4(vec3(1.0) - vec3(color2), 1.0);
    
    
    
    // 减法
//    显示两幅图像的差异，检测同一场景两
//    幅图像之间的变化
//    如:视频中镜头边界的检测
//    去除不需要的叠加性图案
//    图像分割:如分割运动的车辆，减法去 掉静止部分，剩余的是运动元素和噪声
//        vec4 color1 = texture2D(image1, vTexcoord);
//        vec4 color2 = texture2D(image2, vTexcoord);
//        gl_FragColor = vec4(vec3(color2 - color1), 1.0);
    
    
    // 乘法 图像的局部显示 用二值蒙板图像与原图像做乘法
//    vec4 color1 = texture2D(image1, vTexcoord);
//    vec4 color2 = texture2D(image2, vTexcoord);
//    gl_FragColor = vec4(vec3(1.5 * color1 * color2), 1.0);
    
    
    // 除法
//        vec4 color1 = texture2D(image1, vTexcoord);
//        vec4 color2 = texture2D(image2, vTexcoord);
//        gl_FragColor = vec4(vec3(color1/color2), 1.0);
    
    //
    
//    vec4 color1 = texture2D(image1, vTexcoord);
//    vec4 color2 = texture2D(image2, vTexcoord);
//    gl_FragColor = vec4(vec3(color1 color2), 1.0);
    
}

